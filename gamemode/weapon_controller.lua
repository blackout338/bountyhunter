WEAPON = {}

--Weapon_Controller.lua
MAP_WEAPONS = {"hi"}
--MAP_WEAPONS = {ents.Create("stone"), ents.Create("stick")}
MAP_WEAPONS_LIMIT = 1
function WEAPON:SpawnWeapons(tbl)
	for i=0, MAP_WEAPONS_LIMIT, 1 do
		local crowbar = ents.Create("weapon_crowbar")

		crowbar:SetPos(Vector(-2014.169189 -1681.934692 -33.968750))
		crowbar:Spawn()
		crowbar:SetVelocity(Vector(0,0,0))
	end
end
