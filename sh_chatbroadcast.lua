CB = {} -- Chat Broadcast
if SERVER then
	util.AddNetworkString("AddChat")
end

if ( SERVER ) then
	
	function CB:AddChat(...)
		local ply
		local arg = {...}
		
		if ( type( arg[1] ) == "Player" or arg[1] == NULL ) then ply = arg[1] end
		
		if ( ply != NULL ) then
			net.Start( "AddChat" )
				net.WriteUInt( #arg, 16 )
				for _, v in ipairs( arg ) do
					if ( type( v ) == "string" ) then
						net.WriteBit(false)
						net.WriteString( v )
					elseif ( type ( v ) == "table" ) then
						net.WriteBit(true)
						net.WriteUInt( v.r, 8 )
						net.WriteUInt( v.g, 8 )
						net.WriteUInt( v.b, 8 )
						net.WriteUInt( v.a, 8 )
					end
				end
			if ply ~= nil then
				net.Send(ply)
			else
				net.Broadcast()
			end
		end
		
		local str = ""
		for _, v in ipairs( arg ) do
			if ( type( v ) == "string" ) then str = str .. v end
		end
		
	end
	
else

	function CB:AddChat( ... )
		local arg = { ... }
		
		args = {}
		for _, v in ipairs( arg ) do
			if ( type( v ) == "string" or type( v ) == "table" ) then table.insert( args, v ) end
		end
		
		chat.AddText( unpack( args ) )
	end
	
	net.Receive( "AddChat", function( length )
		local argc = net.ReadUInt(16)
		local args = {}
		for i = 1, argc do
			if net.ReadBit() == 1 then
				table.insert( args, Color( net.ReadUInt(8), net.ReadUInt(8), net.ReadUInt(8), net.ReadUInt(8) ) )
			else
				table.insert( args, net.ReadString() )
			end
		end
		
		chat.AddText( unpack( args ) )
	end )
end