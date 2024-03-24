---@class AddonNamespace
local addon = select(2, ...)

local TargetSelector = {}
addon.TargetSelector = TargetSelector

---@alias TargetSelector (fun(): string|nil)

---@param selector TargetSelector
function TargetSelector.Evaluate(selector)
	local seen = {}
	local targets = {}
	for target in selector do
		-- Split uniqueness checking out into TargetSelector.Unique if there is ever a reason to not always be unique
		if not seen[target] then
			seen[target] = true
			targets[#targets + 1] = target
		end
	end
	return targets
end

---@param selectors TargetSelector[]
---@return TargetSelector
function TargetSelector.Chain(selectors)
	return coroutine.wrap(function()
		for _, selector in ipairs(selectors) do
			-- Split sorting out into TargetSelector.Sort if there is ever a reason to not always sort
			local targets = TargetSelector.Evaluate(selector)
			table.sort(targets)

			for _, target in ipairs(targets) do
				coroutine.yield(target)
			end
		end
	end)
end

---@param strategy TargetSelectionStrategy
---@return fun(): string|nil
function TargetSelector.Group(strategy)
	return coroutine.wrap(function()
		for name in addon.Util.IterateGroupMemberNames() do
			if strategy(name) then
				coroutine.yield(name)
			end
		end
	end)
end

---@return TargetSelector
function TargetSelector.Player()
	return addon.Util.IterateTable({ "player" })
end

---@return TargetSelector
function TargetSelector.Pet()
	return addon.Util.IterateTable({ "pet" })
end
