---@class AddonNamespace
local addon = select(2, ...)

local LGIST = LibStub("LibGroupInSpecT-1.1", true)

local TargetSelectionStrategy = {}
addon.TargetSelectionStrategy = TargetSelectionStrategy

---@alias TargetSelectionStrategy fun(unit: string): boolean

---@param strategies (TargetSelectionStrategy)[]
---@return TargetSelectionStrategy
function TargetSelectionStrategy.Any(strategies)
	return function(unit)
		if #strategies == 0 then return true end
		for _, strategy in ipairs(strategies) do
			if strategy(unit) then
				return true
			end
		end
		return false
	end
end

---@param strategies (TargetSelectionStrategy)[]
---@return TargetSelectionStrategy
function TargetSelectionStrategy.All(strategies)
	return function(unit)
		for _, strategy in ipairs(strategies) do
			if not strategy(unit) then
				return false
			end
		end
		return true
	end
end

---@param targetRole "TANK"|"HEALER"|"DAMAGER"
---@return TargetSelectionStrategy
function TargetSelectionStrategy.Role(targetRole)
	return function(unit)
		local role = UnitGroupRolesAssigned(unit)
		if role ~= "NONE" then
			return targetRole == role
		elseif LGIST then
			local guid = UnitGUID(unit)
			local inspectInfo = LGIST:GetCachedInfo(guid)
			if inspectInfo then
				return targetRole == inspectInfo.spec_role
			end
		end
		return false
	end
end

---@return TargetSelectionStrategy
function TargetSelectionStrategy.MainTank()
	return function(unit)
		local isMainTank = GetPartyAssignment("MAINTANK", unit, true)
		return isMainTank
	end
end
