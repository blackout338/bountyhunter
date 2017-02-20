DeriveGamemode("base")
GM.Name = "Bounty Hunter"
GM.Author = "Right Behind U & Connor"

TEAM_HUNTER = 1


function GM:CreateTeams()
	team.SetUp(TEAM_HUNTER, "Hunter", Color(0,255,0,255),true)
	--team.SetUp(TEAM_SPECTATOR, "Spectator", Color(112,128,244,255), true)
end