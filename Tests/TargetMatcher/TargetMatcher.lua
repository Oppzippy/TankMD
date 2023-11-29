local _, addon = ...
local luaunit = require("luaunit")

TestTargetMatcher = {}

function TestTargetMatcher:TestGetSortedGroupMembers()
	local testCases = {
		-- Basic case
		{
			isRaid = false,
			input = { "Unit1", "Unit2", "Unit3" },
			output = { "Unit1", "Unit2", "Unit3" },
		},
		-- Nil slots
		{
			isRaid = false,
			input = { "Unit1", "Unit2", nil, "Unit4" },
			output = { "Unit1", "Unit2", "Unit4" },
		},
		-- Group members with name Unknown
		{
			isRaid = false,
			input = { "Unit1", "Unit2", UNKNOWNOBJECT, "Unit4", UNKNOWNOBJECT },
			output = { "Unit1", "Unit2", "Unit4" },
		},
		-- Unsorted group members
		{
			isRaid = false,
			input = { "Unit2", "Unit3", "Unit1" },
			output = { "Unit1", "Unit2", "Unit3" },
		},
		-- Full party
		{
			isRaid = false,
			input = { "Unit1", "Unit2", "Unit3", "Unit4", "Unit5" },
			output = { "Unit1", "Unit2", "Unit3", "Unit4", "Unit5" },
		},
		-- Basic raid
		{
			isRaid = true,
			input = { "Unit1", "Unit2", "Unit3" },
			output = { "Unit1", "Unit2", "Unit3" },
		},
		-- Full raid
		{
			isRaid = true,
			input = {
				"Unit01", "Unit02", "Unit03", "Unit04", "Unit05", "Unit06", "Unit07", "Unit08", "Unit09", "Unit10",
				"Unit11", "Unit12", "Unit13", "Unit14", "Unit15", "Unit16", "Unit17", "Unit18", "Unit19", "Unit20",
				"Unit21", "Unit22", "Unit23", "Unit24", "Unit25", "Unit26", "Unit27", "Unit28", "Unit29", "Unit30",
				"Unit31", "Unit32", "Unit33", "Unit34", "Unit35", "Unit36", "Unit37", "Unit38", "Unit39", "Unit40"
			},
			output = {
				"Unit01", "Unit02", "Unit03", "Unit04", "Unit05", "Unit06", "Unit07", "Unit08", "Unit09", "Unit10",
				"Unit11", "Unit12", "Unit13", "Unit14", "Unit15", "Unit16", "Unit17", "Unit18", "Unit19", "Unit20",
				"Unit21", "Unit22", "Unit23", "Unit24", "Unit25", "Unit26", "Unit27", "Unit28", "Unit29", "Unit30",
				"Unit31", "Unit32", "Unit33", "Unit34", "Unit35", "Unit36", "Unit37", "Unit38", "Unit39", "Unit40"
			},
		},
	}

	local targetMatcher = setmetatable({}, { __index = addon.TargetMatcherPrototype })
	for i, case in ipairs(testCases) do
		IsInRaid = function() return case.isRaid end
		UnitName = function(unit)
			local index = -1
			local prefix, groupIndexString = unit:match("^([A-Za-z]+)(%d*)$")
			prefix = prefix:lower()
			local groupIndex = tonumber(groupIndexString)

			if prefix == "player" then
				index = 1
			elseif prefix == "raid" and groupIndex then
				index = groupIndex
			elseif prefix == "party" and groupIndex then
				index = groupIndex + 1
			else
				error(string.format("no handler for unit %s with prefix %s and groupIndex %s", unit, prefix,
					tostring(groupIndex)))
			end

			local name = case.input[index]
			return name
		end
		local groupMembers = targetMatcher:GetSortedGroupMembers()
		luaunit.assertEquals(groupMembers, case.output, "test case " .. i)
	end
end
