---@type AddonNamespace
local addon = select(2, ...)
local luaunit = require("luaunit")

TestClassTargetSelectors = {}

local tests = {
	{
		name = "Tanks only ignores main tank role",
		class = { "HUNTER", "ROGUE", "EVOKER" },
		tankSelectionMethod = "tanksOnly",
		prioritizeFocus = false,
		group = {
			{ name = "b", role = "TANK",   isMainTank = false },
			{ name = "a", role = "TANK",   isMainTank = true },
			{ name = "c", role = "HEALER", isMainTank = true },
		},
		expected = { "a", "b" },
		expectedHUNTER = { "a", "b", "pet" },
		expectedEVOKER = { "a", "b", "player" },
	},
	{
		name = "Tanks and Main Tanks sorts both groups together",
		class = { "HUNTER", "ROGUE", "EVOKER" },
		tankSelectionMethod = "tanksAndMainTanks",
		prioritizeFocus = false,
		group = {
			{ name = "d", role = "TANK",   isMainTank = false },
			{ name = "c", role = "HEALER", isMainTank = true },
			{ name = "b", role = "TANK",   isMainTank = false },
			{ name = "a", role = "HEALER", isMainTank = true },
		},
		expected = { "a", "b", "c", "d" },
		expectedHUNTER = { "a", "b", "c", "d", "pet" },
		expectedEVOKER = { "a", "b", "c", "d", "player" },
	},
	{
		name = "Prioritize Main Tanks sorts tanks and main tanks independently",
		class = { "HUNTER", "ROGUE", "EVOKER" },
		tankSelectionMethod = "prioritizeMainTanks",
		prioritizeFocus = false,
		group = {
			{ name = "b", role = "TANK",   isMainTank = false },
			{ name = "a", role = "TANK",   isMainTank = false },
			{ name = "d", role = "HEALER", isMainTank = true },
			{ name = "c", role = "HEALER", isMainTank = true },
		},
		expected = { "c", "d", "a", "b" },
		expectedHUNTER = { "c", "d", "a", "b", "pet" },
		expectedEVOKER = { "c", "d", "a", "b", "player" },
	},
	{
		name = "Prioritize Main Tanks counts people with both tank and main tank as main tanks",
		class = { "HUNTER", "ROGUE", "EVOKER" },
		tankSelectionMethod = "prioritizeMainTanks",
		prioritizeFocus = false,
		group = {
			{ name = "a", role = "TANK", isMainTank = false },
			{ name = "b", role = "TANK", isMainTank = true },
		},
		expected = { "b", "a" },
		expectedHUNTER = { "b", "a", "pet" },
		expectedEVOKER = { "b", "a", "player" },
	},
	{
		name = "Main tanks only does not exclude tanks with main tank role",
		class = { "HUNTER", "ROGUE", "EVOKER" },
		tankSelectionMethod = "mainTanksOnly",
		prioritizeFocus = false,
		group = {
			{ name = "a", role = "TANK", isMainTank = false },
			{ name = "b", role = "TANK", isMainTank = true },
		},
		expected = { "b" },
		expectedHUNTER = { "b", "pet" },
		expectedEVOKER = { "b", "player" },
	},
	{
		name = "Main tanks only includes other roles",
		class = { "HUNTER", "ROGUE", "EVOKER" },
		tankSelectionMethod = "mainTanksOnly",
		prioritizeFocus = false,
		group = {
			{ name = "a", role = "HEALER", isMainTank = true },
			{ name = "b", role = "TANK",   isMainTank = true },
		},
		expected = { "a", "b" },
		expectedHUNTER = { "a", "b", "pet" },
		expectedEVOKER = { "a", "b", "player" },
	},
	{
		name = "Druid targets healers",
		class = "DRUID",
		prioritizeFocus = false,
		group = {
			{ name = "c", role = "HEALER", isMainTank = true },
			{ name = "b", role = "TANK",   isMainTank = true },
			{ name = "a", role = "HEALER", isMainTank = false },
		},
		expected = { "a", "c" },
	}
}

---@param unit string
local function getUnitIndex(test, unit)
	for i, groupMember in next, test.group do
		if groupMember.name == unit then
			return i
		end
	end
	local indexString = unit:match("%a+(%d+)")
	return tonumber(indexString)
end

for _, test in ipairs(tests) do
	local classes
	if type(test.class) == "string" then
		classes = { test.class }
	else
		classes = test.class
	end
	for _, class in next, classes do
		TestClassTargetSelectors[string.format("Test_%s_%s", class, test.name)] = function()
			---@diagnostic disable-next-line: missing-fields
			addon.db = { profile = { tankSelectionMethod = test.tankSelectionMethod, prioritizeFocus = test.prioritizeFocus } }

			function IsInRaid()
				return true
			end

			function UnitName(unit)
				local index = getUnitIndex(test, unit)
				return test.group[index] and test.group[index].name
			end

			function UnitGUID(unit)
				unit = unit:lower()
				if unit == "focus" then
					return
				end
				local index = getUnitIndex(test, unit)
				return test.group[index] and test.group[index].name .. "GUID"
			end

			function UnitGroupRolesAssigned(unit)
				local index = getUnitIndex(test, unit)
				return test.group[index] and test.group[index].role
			end

			function GetPartyAssignment(assignment, unit)
				if assignment == "MAINTANK" then
					local index = getUnitIndex(test, unit)
					return test.group[index] and test.group[index].isMainTank
				end
				return false
			end

			local selector = addon.ClassTargetSelectors[class]()
			local results = addon.TargetSelector.Evaluate(selector)
			local expected = test["expected" .. class] or test.expected
			luaunit.assertEquals(results, expected)
		end
	end
end
