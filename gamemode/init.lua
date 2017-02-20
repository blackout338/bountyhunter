include("shared.lua")
include("sv_rounds.lua")
AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")

--[-----------------------------------------------------------------------------------------------------------------------------------------------------]--
--[                                                             GLOBAL INIT VARIABLES                                                                   ]--
--[-----------------------------------------------------------------------------------------------------------------------------------------------------]-- 
PLAYER_LIST = {}

playerModels = { //Citizen
"models/humans/Group01/Male_01.mdl",
"models/humans/Group01/male_02.mdl",
"models/humans/Group01/male_03.mdl",
"models/humans/Group01/Male_04.mdl",
"models/humans/Group01/Male_05.mdl",
"models/humans/Group01/male_06.mdl",
"models/humans/Group01/male_07.mdl",
"models/humans/Group01/male_08.mdl",
"models/humans/Group01/male_09.mdl",
"models/humans/Group01/male_09.mdl",
"models/humans/Group01/Male_01.mdl",
"models/humans/Group01/male_03.mdl",
"models/humans/Group01/Male_05.mdl",
"models/humans/Group01/male_09.mdl"
}

--This variable will be populated later when we use the newly made concommand "entity_pos" to retrieve appropriate locations.
spawn_table_locations = {}

function GM:Initialize()
	ROUND:SetRound(ROUND_WAIT)
end

--[-----------------------------------------------------------------------------------------------------------------------------------------------------]--
--[                                                            PLAYER CONNECTION LOGIC                                                                  ]--
--[-----------------------------------------------------------------------------------------------------------------------------------------------------]-- 

function GM:PlayerAuthed(ply, steamId, UniqueID)
		
	newPlayerObject = {}
	newPlayerObject.target = nil
	newPlayerObject.targeted = false
	newPlayerObject.object = ply
	newPlayerObject.id = UniqueID
	newPlayerObject.steamId = steamId
	newPlayerObject.score = 0

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
	if ROUND:GetRound() == 0 then
		ply:SetTeam(TEAM_SPECTATOR)
	else
		print "SETTING TEAM TO HUNTER!"
		ply:SetTeam(TEAM_HUNTER)
	end
	print (ROUND:GetRound())
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
--[[
function GM:EntityTakeDamage(victim, dmgInfo)
	local attacker = dmgInfo:GetAttacker()
	local attackerObject = PLAYER_LIST[attacker:UniqueID()]
	local victimId = victim:UniqueID()
	
	if IsValid(attacker) and attacker:IsPlayer() and victim:IsPlayer() and victimId != attackerObject.target then
		attacker:TakeDamage(dmgInfo:GetDamage(), attacker, dmgInfo:GetInflictor())
	else 
		attackerObject.score = math.Round(attackerObject.score + (dmgInfo:GetDamage()/10))
	end
end
]]--

--[-----------------------------------------------------------------------------------------------------------------------------------------------------]--
--[                                                          CHAT COMMANDS AND LISTNERS                                                                 ]--
--[-----------------------------------------------------------------------------------------------------------------------------------------------------]-- 

function GM:PlayerSay(sender, message, senderTeam)
	if IsValid(message) then
		local message = String.lower(message)
		if message == "!bounty" then
			--Use 
		end
	end
end	


function GM:Think()
	self.BaseClass:Think()
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





