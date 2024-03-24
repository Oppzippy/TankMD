local namespace = {}
---@param path string
function ExecuteWoWLuaFile(path)
	local func, err = loadfile(path)
	if err then
		error(err)
	end
	if not func then
		error(string.format("error loading %s: function is nil", path))
	end
	func("TankMD", namespace)
end

function LibStub() end

MAX_RAID_MEMBERS = 40
MAX_PARTY_MEMBERS = 4
UNKNOWNOBJECT = "Unknown"

--- Internal
ExecuteWoWLuaFile("TargetSelectionFilter.lua")
ExecuteWoWLuaFile("TargetSelector.lua")
ExecuteWoWLuaFile("Util.lua")
