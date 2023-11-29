local luaunit = require("luaunit")

require("Tests.WoWEnvironment")

ExecuteWoWLuaFile("Tests/TargetMatcher/TargetMatcher.lua")

os.exit(luaunit.LuaUnit.run())
