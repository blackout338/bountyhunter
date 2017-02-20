--[-----------------------------------------------------------------------------------------------------------------------------------------------------]--
--[                                                              GLOBAL ROUND VARIABLES                                                                 ]--
--[-----------------------------------------------------------------------------------------------------------------------------------------------------]-- 

--Assigning values to round states. 
ROUND = {}
ROUND_WAIT = 0
ROUND_PREP = 1
ROUND_ACTIVE = 2
ROUND_END = 3
print "Initialized Rounds File"
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
print "1"
--Returns current Global Integer for 'roundTime'
function ROUND:GetRoundTime()
	local temptime = GetGlobalInt("roundTime")
	return math.Round(math.Max(temptime - CurTime(), 0))
end
print "2"
--Returns current Global Integer for 'roundPhase'
function ROUND:GetRound()
	return GetGlobalInt("roundPhase")
end
print "3"
--Sets Global Integer for 'roundPhase'. Runs associated Round Function.
function ROUND:SetRound(round, ...)
	num = round + 1
	if not RoundFunctions[num] then 
		--print("cuntsfucked")
		return 
	end
	
	SetGlobalInt('roundPhase', round)
	--Unpack args as required
	RoundFunctions[num](self)
end
print "4"

--[-----------------------------------------------------------------------------------------------------------------------------------------------------]--
--[                                                   PLAYER ROUND SPAWN & BOUNTY LOGIC FUNCTIONS                                                       ]--
--[-----------------------------------------------------------------------------------------------------------------------------------------------------]-- 

--Spawns, and sets teams for all players. If the player does not have a bounty, assign them a new one.
function ROUND:SortPlayers(freezePlayers)
	for k,v in pairs(player.GetAll()) do
		v:SetTeam(TEAM_HUNTER)
		v:Spawn()
	end
	
	if freezePlayers then
		for k, v in pairs(player.GetAll()) do
			v:AddFlags(FL_ATCONTROLS)
			v:SetJumpPower(0)
		end
	end
	
	--Set Targets Here
	
	
end
print "5"

--Assigns a new bounty to the parsed player.
function getNewBounty(player)
	for k, v in RandomPairs(PLAYER_LIST) do
		local otherPlayer = v
		if !otherPlayer.targeted then
			player.target = otherPlayer.id
			return
		end
		if player.target == nil then
			player.target = PLAYER_LIST[0].id
		end
	end
end
print "6"
--[-----------------------------------------------------------------------------------------------------------------------------------------------------]--
--[                                                           PRE ROUND PREPARATION FUNCTION                                                            ]--
--[-----------------------------------------------------------------------------------------------------------------------------------------------------]-- 

round_RoundWait = function()
	print "wait"
	ROUND:SetRoundTime(0)
end

round_RoundPrep = function()
	game.CleanUpMap()
	print "Gone to prep"
	ROUND:SetRoundTime(5)
	ROUND:SortPlayers(true)
end

round_RoundActive = function()
	print "Running Round Active stuffs"
	ROUND:SetRoundTime(300)
	for k,v in pairs(player.GetAll()) do
		v:RemoveFlags(FL_ATCONTROLS)
		v:SetJumpPower(270)
	end
end
round_RoundEnd = function()
	ROUND:SetRoundTime(5)
end

RoundFunctions = { round_RoundWait, round_RoundPrep, round_RoundActive, round_RoundEnd } 
--[[
RoundFunctions = {
	[ROUND_WAIT] = function()
		ROUND:SetRoundTime(0)
	end,
	[ROUND_PREP] = function()
		game.CleanUpMap()
		ROUND:SetRoundTime(5)
		ROUND:SortPlayers(true)
		WEAPON:SpawnWeapons(spawn_table_locations)
		Spawn SWEPS
	end,
	[ROUND_ACTIVE] = function()
		ROUND:SetRoundTime(300)
		for k,v in pairs(player.GetAll()) do
			v:RemoveFlags(FL_ATCONTROLS)
			v:SetJumpPower(270)
		end
	end,
	[ROUND_END] = function()
		ROUND:SetRoundTime(5)
	end
}
]]
print "7"
--[-----------------------------------------------------------------------------------------------------------------------------------------------------]--
--[                                                               ROUND THINK FUNCTIONS                                                                 ]--
--[-----------------------------------------------------------------------------------------------------------------------------------------------------]-- 
think_RoundWait = function()
	--print "hi"
	if(#player.GetAll() > 1) then
		print "hi again"
		ROUND:SetRound(ROUND_PREP)
	end
end

think_RoundPrep = function()
	local temptime = ROUND:GetRoundTime()
	if(temptime <= 0) then
		ROUND:SetRound(ROUND_ACTIVE)
	end
end

think_RoundActive = function()
	--print "ACTIVE ROUND"
	local timeTemp = ROUND:GetRoundTime()
	if(timeTemp < 0) then
		ROUND:SetRound(ROUND_END)
	end
	if (#player.GetAll() == 1) then
			ROUND:SetRound(ROUND_WAIT)
			print "SET ROUND TO WAIT"
			for k, v in pairs(player.GetAll()) do
				v:SetTeam(1)
				v:Spawn()
			end
	end
end

think_RoundEnd = function()
	if ROUND:GetRoundTime() <= 0 then
		ROUND:SetRound(ROUND_PREP)
		return
	end
end
ThinkFunctions = {think_RoundWait, think_RoundPrep, think_RoundActive, think_RoundEnd}
--[[ThinkFunctions = {
	[ROUND_WAIT] = function()
		if(#player.GetAll() > 1) then
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
		if ROUND:GetRoundTime() <= 0 then
			ROUND:SetRound(ROUND_PREP)
			return
		end
	end
}

]]--


function RoundThink()

	local cur = ROUND:GetRound() + 1
	
	
	
	if ThinkFunctions[cur] then
		--print "Stop 2"
		ThinkFunctions[cur](self)
	end	
	--print "END ROUND THINK"
end
hook.Add("Think", "fuckingroundthink", RoundThink)

print "9"
--[-----------------------------------------------------------------------------------------------------------------------------------------------------]--
--[                                                        OTHER CUSTOM ROUND FUNCTIONS                                                                 ]--
--[-----------------------------------------------------------------------------------------------------------------------------------------------------]-- 

--Returns the number of Alive players from a team.
local function GetAlivePlayersFromTeam(t)
	local counter = 0
	for k, v in pairs(team.GetPlayers(t)) do
		if v:Alive() then
			counter = counter+1
		end	
	end
	return counter
end
print "10"