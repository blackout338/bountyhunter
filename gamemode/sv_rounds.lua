--[-----------------------------------------------------------------------------------------------------------------------------------------------------]--
--[                                                              GLOBAL ROUND VARIABLES                                                                 ]--
--[-----------------------------------------------------------------------------------------------------------------------------------------------------]-- 

--Assigning values to round states. 
ROUND = {}
ROUD_WAIT = 0
ROUD_PREP = 1
ROUD_ACTIVE = 2
ROUD_END = 3

--Defining some important global round variables.
SetGlobalInt("roundPhase", ROUND_WAIT)
SetGlobalInt("roundTime", 0)

--[-----------------------------------------------------------------------------------------------------------------------------------------------------]--
--[                                                       ROUND VARIABLE MANIPULATION FUNCTIONS                                                         ]--
--[-----------------------------------------------------------------------------------------------------------------------------------------------------]-- 

--Sets Global Integer for 'roundTime'.
function ROUND:SetRoundTime(time)
	SetGlobalInt("roundTime", CurTime() + (tonumber(time or 5) or 5))
end

--Returns current Global Integer for 'roundTime'
function ROUND:GetRoundTime()
	local temptime = GetGlobalInt("roundTime")
	return math.Round(math.Max(temptime - CurTime(), 0))
end

--Returns current Global Integer for 'roundPhase'
function ROUND:GetRound()
	return GetGlobalInt("roundPhase")
end

--Sets Global Integer for 'roundPhase'. Runs associated Round Function.
function ROUND:SetRound(round, ...)
	if not RoundFunctions[round] then return end
	
	local args = {...}
	SetGlobalInt('roundPhase', round)
	--Unpack args as required
	RoundFunction[round](self)
end

--[-----------------------------------------------------------------------------------------------------------------------------------------------------]--
--[                                                   PLAYER ROUND SPAWN & BOUNTY LOGIC FUNCTIONS                                                       ]--
--[-----------------------------------------------------------------------------------------------------------------------------------------------------]-- 

--Spawns, and sets teams for all players. If the player does not have a bounty, assign them a new one.
function ROUND:SortPlayers(freezePlayers)
	for k,v in random pairs(player.getAll()) do
		v:SetTeam(TEAM_HUNTER)
		v:Spawn()
	end
	
	if freezePlayers then
		for k, v in pairs(player.getAll()) do
			v:AddFlags(FL_ATCONTROLS)
			v:SetJumpPower(0)
		end
	end
	
	for k, v in pairs(PLAYER_LIST) do
		if(PLAYER_LIST[k].target == nil)
			getNewBounty(PLAYER_LIST)
		end
	end
	
	
end

--Assigns a new bounty to the parsed player.
function getNewBounty(player)
	for k, v in random pairs(PLAYER_LIST) do
		local otherPlayer = v
		if !otherPlayer.targeted then
			player.target = otherPlayer.id
			return
		end
		if player.target = nil then
			player.target = PLAYER_LIST[0].id
		end
	end
end

--[-----------------------------------------------------------------------------------------------------------------------------------------------------]--
--[                                                           PRE ROUND PREPARATION FUNCTION                                                            ]--
--[-----------------------------------------------------------------------------------------------------------------------------------------------------]-- 

RoundFunctions = {
	[ROUND_WAITING] = function()
		
	end,
	[ROUND_PREP] = function()
		game.CleanUpMap()
		ROUND:SetRoundTime(5)
		ROUND:SortPlayers(true)
		WEAPON:SpawnWeapons(spawn_table_locations)
		--Spawn SWEPS
	end,
	[ROUND_ACTIVE] = function()
		ROUND:SetRoundTime(300)
		for k,v in pairs(player.getAll()) do
			v:RemoveFlags(FL_ATCONTROLS)
			v:SetJumpPower(270)
		end
	end,
	[ROUND_END] = function()
		ROUND:SetRoundTime(5)
	end
}

--[-----------------------------------------------------------------------------------------------------------------------------------------------------]--
--[                                                               ROUND THINK FUNCTIONS                                                                 ]--
--[-----------------------------------------------------------------------------------------------------------------------------------------------------]-- 

ThinkFunctions = {
	[ROUND_WAITING] = function()
		if(#player.getAll() > 1) then
			ROUND:SetRound(ROUND_PREP)
		end
	end,
	[ROUND_PREP] = function()
		local tempTime = ROUND:GetRoundTime()
		if(tempTime <= 0) then
			ROUND:SetRound(ROUND_ACTIVE)
		end
	end,
	[ROUND_ACTIVE] = function()
		local tempTime = ROUND:GetRoundTime()

		if(tempTime < 0) then
			ROUND:SetRound(ROUND_END)
		end
		
	end,
	[ROUND_END] = function()
		if ROUND:GetRoundTime <= 0 then
			ROUND:SetRound(ROUND_PREP)
			return
		end
	end
}

function RoundThink()
	local cur = ROUND:GetRound()
	
	if(#player.getAll() < 2) then
		ROUND:SetRound(ROUND_WAITING)
	end
	
	if ThinkFunctions[cur] then
		ThinkFunctions[cur](self)
	end
	
end

--[-----------------------------------------------------------------------------------------------------------------------------------------------------]--
--[                                                        OTHER CUSTOM ROUND FUNCTIONS                                                                 ]--
--[-----------------------------------------------------------------------------------------------------------------------------------------------------]-- 

--Returns the number of Alive players from a team.
local function GetAlivePlayersFromTeam(t)
	local counter = 0
	for k, v in pairs(team.GetPlayers(t)) do
		if v:Alive() then
			counter += 1
		end	
	end
	return counter
end