local luaunit = require("luaunit")

require("Tests.WoWEnvironment")

ExecuteWoWLuaFile("Tests/Util/Util.lua")

os.exit(luaunit.LuaUnit.run())
