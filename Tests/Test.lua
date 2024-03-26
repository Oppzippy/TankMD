local luaunit = require("luaunit")

require("Tests.WoWEnvironment")

ExecuteWoWLuaFile("Tests/Util.lua")
ExecuteWoWLuaFile("Tests/TargetSelector.lua")
ExecuteWoWLuaFile("Tests/ClassTargetSelectors.lua")

os.exit(luaunit.LuaUnit.run())
