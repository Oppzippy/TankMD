---@class AddonNamespace
local addon = select(2, ...)

local ClassTargetSelectors = {}
addon.ClassTargetSelectors = ClassTargetSelectors

local TargetSelector = addon.TargetSelector
local TargetSelectionStrategy = addon.TargetSelectionStrategy

---@type fun(strategyName: string): TargetSelector
local getTankSelector
do
	local tankSelectionFactories = {
		tankRoleOnly = function()
			return TargetSelector.Sort(TargetSelector.PartyOrRaid(TargetSelectionStrategy.Role("TANK")))
		end,
		tanksAndMainTanks = function()
			return TargetSelector.Sort(TargetSelector.PartyOrRaid(
				TargetSelectionStrategy.Any({
					TargetSelectionStrategy.MainTank(),
					TargetSelectionStrategy.Role("TANK"),
				})
			))
		end,
		prioritizeMainTanks = function()
			return TargetSelector.Chain({
				TargetSelector.Sort(TargetSelector.PartyOrRaid(TargetSelectionStrategy.MainTank())),
				TargetSelector.Sort(TargetSelector.PartyOrRaid(TargetSelectionStrategy.Role("TANK"))),
			})
		end,
		mainTanksOnly = function()
			return TargetSelector.Sort(TargetSelector.PartyOrRaid(TargetSelectionStrategy.MainTank()))
		end,
	}

	getTankSelector = function(method)
		return (tankSelectionFactories[method] or tankSelectionFactories.tankRoleOnly)()
	end
end

---@param selector TargetSelector
---@return TargetSelector
local function chainWithFocus(selector)
	if addon.db.profile.prioritizeFocus then
		return TargetSelector.Chain({
			TargetSelector.Focus(),
			selector,
		})
	end
	return selector
end

function ClassTargetSelectors.HUNTER()
	return chainWithFocus(TargetSelector.Chain({
		getTankSelector(addon.db.profile.tankSelectionStrategy),
		TargetSelector.Pet()
	}))
end

function ClassTargetSelectors.ROGUE()
	return chainWithFocus(getTankSelector(addon.db.profile.tankSelectionStrategy))
end

function ClassTargetSelectors.EVOKER()
	return chainWithFocus(TargetSelector.Chain({
		TargetSelector.PartyOrRaid(TargetSelectionStrategy.Role("TANK")),
		TargetSelector.Player(),
	}))
end

function ClassTargetSelectors.DRUID()
	return chainWithFocus(TargetSelector.PartyOrRaid(TargetSelectionStrategy.Role("TANK")))
end
