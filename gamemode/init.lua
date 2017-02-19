include("shared.lua")
AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")

--[-----------------------------------------------------------------------------------------------------------------------------------------------------]--
--[                                                             GLOBAL INIT VARIABLES                                                                   ]--
--[-----------------------------------------------------------------------------------------------------------------------------------------------------]-- 
PLAYER_LIST = {}


--This variable will be populated later when we use the newly made concommand "entity_pos" to retrieve appropriate locations.
spawn_table_locations = {}

--[-----------------------------------------------------------------------------------------------------------------------------------------------------]--
--[                                                            PLAYER CONNECTION LOGIC                                                                  ]--
--[-----------------------------------------------------------------------------------------------------------------------------------------------------]-- 

function GM:PlayerAuthed(ply, steamId, UniqueId)
		
	newPlayerObject = {}
	newPlayerObject.target = nil
	newPlayerObject.targeted = false
	newPlayerObject.object = ply
	newPlayerObject.id = UniqueId
	newPlayerObject.steamId = steamId
	newPlayerObject.score = 0

	PLAYER_LIST[UniqueId] = newPlayerObject

end
--[-----------------------------------------------------------------------------------------------------------------------------------------------------]--
--[                                                              PLAYER SPAWN LOGIC                                                                     ]--
--[-----------------------------------------------------------------------------------------------------------------------------------------------------]-- 
function GM:PlayerInitialSpawn(ply)
	
	ply:SetTeam(TEAM_HUNTER)

end

function GM:PlayerSpawn(ply)
	local player = PLAYER_LIST[ply:UniqueId()]
	getNewBounty(player)
end
--[-----------------------------------------------------------------------------------------------------------------------------------------------------]--
--[                                                         PLAYER DAMAGING & DEATH                                                                     ]--
--[-----------------------------------------------------------------------------------------------------------------------------------------------------]-- 
function GM:PlayerDeath(victim, inflictor, attacker)
	local victim = PLAYER_LIST[victim:UniqueId()]
	
	if attacker:IsPlayer() then
		victim.targeted = false
		victim.target = nil
		PLAYER_LIST[victim.target].targeted = false
		local attacker = PLAYER_LIST[attacker:UniqueId()]
		attacker.target = nil
		getNewBounty(attacker)
	end
	
end

function GM:EntityTakeDamage(victim, dmgInfo)
	local attacker = dmgInfo:GetAttacker()
	local attackerObject = PLAYER_LIST[attacker:UniqueId()]
	local victimId = victim:UniqueId()
	
	if IsValid(attacker) and attacker:IsPlayer() and victim:IsPlayer() and victimId != attackerObject.target then
		attacker:TakeDamage(dmgInfo:GetDamage(), attacker, dmgInfo:GetInflictor())
	else 
		attackerObject.score = math.Round(attackerObject.score + (dmgInfo:GetDamage()/10))
	end
end

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





