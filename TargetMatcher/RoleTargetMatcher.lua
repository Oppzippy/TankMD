local _, addon = ...
local RoleTargetMatcherPrototype = setmetatable({}, addon.TargetMatcherPrototype)
addon.RoleTargetMatcherPrototype = RoleTargetMatcherPrototype
RoleTargetMatcherPrototype.__index = RoleTargetMatcherPrototype

function addon:CreateRoleTargetMatcher(role)
	local targetMatcher = setmetatable({}, RoleTargetMatcherPrototype)
	targetMatcher.role = role
	return targetMatcher
end

function RoleTargetMatcherPrototype:Matches(unit)
	return self.role == UnitGroupRolesAssigned(unit)
end
