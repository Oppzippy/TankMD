local luaunit = require("luaunit")

require("Tests.WoWEnvironment")

ExecuteWoWLuaFile("Tests/Util.lua")
ExecuteWoWLuaFile("Tests/TargetSelector.lua")

os.exit(luaunit.LuaUnit.run())
