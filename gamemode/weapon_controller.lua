--Weapon_Controller.lua
MAP_WEAPONS = {ents.Create("stone"), ents.Create("stick")}
MAP_WEAPONS_LIMIT = 10
function WEAPON:SpawnWeapons(tbl)
	for i=0, MAP_WEAPONS_LIMIT, +1 do
		table.Random(MAP_WEAPONS):SetPos(table.Random(tbl))
		table.Random(MAP_WEAPONS):Spawn()
	end
end
