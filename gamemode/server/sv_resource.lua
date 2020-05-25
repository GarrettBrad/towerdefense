
// ******************************
// * Tower Defense Gamemode Base *
// ******************************
// sv_resource.lua - Loads serverside resource functionality

function resource.AddDir( dir )
	local files, dirs = file.Find( dir .. "/*", "DATA" ) -- throw away dirs

	if files then 

		for _, f in pairs(files) do
			resource.AddFile( dir .. "/" .. f )
		end

	else
		local callstack = debug.traceback()
		ErrorNoHalt("Failed to include directory: ", dir, "\n", callstack, "\n")
	end
end

resource.AddDir( "materials/gui/td" )