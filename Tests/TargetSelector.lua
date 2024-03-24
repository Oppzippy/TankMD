---@type AddonNamespace
local addon = select(2, ...)
local luaunit = require("luaunit")

local TargetSelector = addon.TargetSelector
local Util = addon.Util

TestTargetSelector = {}

function TestTargetSelector:TestChainDoesNotSeparateSelectors()
	local actual = TargetSelector.Evaluate(
		TargetSelector.Chain({ Util.IterateTable({ "b" }), Util.IterateTable({ "a" }) })
	)
	luaunit.assertEquals(actual, { "b", "a" })
end

function TestTargetSelector:TestSort()
	local actual = TargetSelector.Evaluate(
		TargetSelector.Sort(Util.IterateTable({ "b", "c" }))
	)
	luaunit.assertEquals(actual, { "b", "c" })
end

function TestTargetSelector:TestValuesAreUnique()
	local actual = TargetSelector.Evaluate(
		Util.IterateTable({ "a", "a" })
	)
	luaunit.assertEquals(actual, { "a" })
end
