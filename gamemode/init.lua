include("shared.lua")
include("sv_rounds.lua")
include("sh_chatbroadcast.lua")
--include("weapon_controller.lua")
include("sv_weps.lua")
AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("sh_chatbroadcast.lua")
AddCSLuaFile("cl_chatbroadcast.lua")

--[-----------------------------------------------------------------------------------------------------------------------------------------------------]--
--[                                                             GLOBAL INIT VARIABLES                                                                   ]--
--[-----------------------------------------------------------------------------------------------------------------------------------------------------]-- 
PLAYER_LIST = {}

if(#player.GetAll() > 1) then
	for k,v in pairs(player.GetAll()) do
		newPlayerObject = {}
		newPlayerObject.target = nil
		newPlayerObject.targeted = false
		newPlayerObject.object = v
		newPlayerObject.id = v:UniqueID()
		newPlayerObject.score = 0
		newPlayerObject.spawned = false

		PLAYER_LIST[v:UniqueID()] = newPlayerObject		
	end
end

playerModels = { //Citizen
"models/player/Group01/Male_01.mdl",
"models/player/Group01/male_02.mdl",
"models/player/Group01/male_03.mdl",
"models/player/Group01/Male_04.mdl",
"models/player/Group01/Male_05.mdl",
"models/player/Group01/male_06.mdl",
"models/player/Group01/male_07.mdl",
"models/player/Group01/male_08.mdl",
"models/player/Group01/male_09.mdl",
"models/player/Group01/male_09.mdl",
"models/player/Group01/Male_01.mdl",
"models/player/Group01/male_03.mdl",
"models/player/Group01/Male_05.mdl",
"models/player/Group01/male_09.mdl"
}

--This variable will be populated later when we use the newly made concommand "entity_pos" to retrieve appropriate locations.
spawn_table_locations = {Vector(-2014.169189 -1681.934692 -33.968750)}

function GM:Initialize()
	ROUND:SetRound(ROUND_WAIT)
end

--[-----------------------------------------------------------------------------------------------------------------------------------------------------]--
--[                                                            PLAYER CONNECTION LOGIC                                                                  ]--
--[-----------------------------------------------------------------------------------------------------------------------------------------------------]-- 

function GM:PlayerAuthed(ply, steamId, UniqueID)
	print("Authenticating player " .. ply:Nick())
	newPlayerObject = {}
	newPlayerObject.target = nil
	newPlayerObject.targeted = false
	newPlayerObject.object = ply
	newPlayerObject.id = UniqueID
	newPlayerObject.steamId = steamId
	newPlayerObject.score = 0
	newPlayerObject.spawned = false

	PLAYER_LIST[UniqueID] = newPlayerObject
	--[[
	ply:SetTeam(2)
	ply:Spectate( OBS_MODE_ROAMING )
	ply:SetMoveType(MOVETYPE_NOCLIP)
	ply:SetNotSolid(true)
	]]--
end
--[-----------------------------------------------------------------------------------------------------------------------------------------------------]--
--[                                                              PLAYER SPAWN LOGIC                                                                     ]--
--[-----------------------------------------------------------------------------------------------------------------------------------------------------]-- 
function GM:PlayerInitialSpawn(ply)
	print("Running 1 " .. ply:Nick())
	print("Player " .. ply:Nick() .. " is a player: " .. tostring(ply:IsPlayer()))
	if ply:IsBot() then
		newPlayerObject = {}
		newPlayerObject.target = nil
		newPlayerObject.targeted = false
		newPlayerObject.object = ply
		newPlayerObject.id = ply:UniqueID()
		newPlayerObject.score = 0
		newPlayerObject.spawned = false

		PLAYER_LIST[ply:UniqueID()] = newPlayerObject
		
		print("Added bot to player list named '" .. ply:Nick() .. "'")
	end
	if PLAYER_LIST[ply:UniqueID()].target == nil and ROUND:GetRound() != 0 then
		getNewBounty(PLAYER_LIST[ply:UniqueID()])
	end
	if ROUND:GetRound() == 0 then
		ply:SetTeam(TEAM_SPECTATOR)
	else
		print "SETTING TEAM TO HUNTER!"
		ply:SetTeam(TEAM_HUNTER)
	end
	--[[if ply:Team() == TEAM_SPECTATOR then
		ply:Spectate(OBS_MODE_ROAMING)
	return
	end]]
	--timer.Simple(1, function() ply:KillSilent() end)
end



function GM:PlayerSpawn(ply)
	if ROUND:GetRound() == 0 then
		ply:StripWeapons()
		ply:StripAmmo()
		ply:Spectate( OBS_MODE_ROAMING )
	else 
		ply:UnSpectate()
		ply:SetTeam(1)
		ply:SetModel(table.Random(playerModels))
	end
	print "PLAYER SPAWNED"
	--ply:SetTeam(TEAM_SPECTATOR)
	--local player = PLAYER_LIST[ply:UniqueID()]
	--getNewBounty(player)
	--	if ply:Team() == TEAM_SPECTATOR then
	--		ply:Spectate(OBS_MODE_ROAMING)
	--	return
	--end
end

function GM:PlayerDisconnected(ply)
	PLAYER_LIST[ply:UniqueID()] = nil
end
--[-----------------------------------------------------------------------------------------------------------------------------------------------------]--
--[                                                         PLAYER DAMAGING & DEATH                                                                     ]--
--[-----------------------------------------------------------------------------------------------------------------------------------------------------]-- 
--[[function GM:PlayerDeath(victim, inflictor, attacker)
	local victim = PLAYER_LIST[victim:UniqueID()]
	
	if attacker:IsPlayer() then
		victim.targeted = false
		victim.target = nil
		PLAYER_LIST[victim.target].targeted = false
		local attacker = PLAYER_LIST[attacker:UniqueID()]
		attacker.target = nil
		getNewBounty(attacker)
	end
	
end]]
--[[function GM:EntityTakeDamage(victim, dmgInfo)
	if IsValid(victim) and victim:IsPlayer() then
		local attacker = dmgInfo:GetAttacker()
		local victimId = victim:UniqueID()
		print("Attacker: " .. attacker:Nick() .. ", Victim: " .. victim:Nick() .. ", Damage: " .. tostring(dmgInfo:GetDamage()) .. ", Inflictor: " .. tostring(dmgInfo:GetInflictor()))
	    attacker:TakeDamage(dmgInfo:GetDamage(), attacker, dmgInfo:GetInflictor())
		print("done")
	end
end]]

function GM:PlayerHurt(victim, attacker, hpleft, hptaken)
	if(attacker:IsPlayer()) then
		local attackerObject = PLAYER_LIST[attacker:UniqueID()]
		if attackerObject.target != victim:UniqueID() then
			attacker:TakeDamage(hptaken)
		end

	end
end


--[-----------------------------------------------------------------------------------------------------------------------------------------------------]--
--[                                                          CHAT COMMANDS AND LISTENERS                                                                 ]--
--[-----------------------------------------------------------------------------------------------------------------------------------------------------]-- 

function GM:PlayerSay( ply, text )

	local text2 = string.lower(text)
	if text2 == "!bounty" then
		CB:AddChat(ply,Color(255,255,255),"Your current bounty is: ",Color(255,0,0), PLAYER_LIST[PLAYER_LIST[ply:UniqueID()].target].object:Nick())
		return ""
	end

	return self.BaseClass:PlayerSay(ply, text)

end


function GM:Think()
	self.BaseClass:Think()
	--CB:AddChat(Color(255,255,255), GetGlobalInt("roundTime"))
	--self:RoundThink()
end

--[-----------------------------------------------------------------------------------------------------------------------------------------------------]--
--[                                                        Other Custom init.lua Functons                                                               ]--
--[-----------------------------------------------------------------------------------------------------------------------------------------------------]-- 



function tableLength(tableArg) 
	length = 0
	for k, v in pairs(tableArg) do
		length = length + 1
	end
	return length
end





