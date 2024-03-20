local _, addon = ...
local RoleTargetMatcherPrototype = setmetatable({}, addon.TargetMatcherPrototype)
addon.RoleTargetMatcherPrototype = RoleTargetMatcherPrototype
RoleTargetMatcherPrototype.__index = RoleTargetMatcherPrototype

-- Not compatible with classic
local LGIST = LibStub("LibGroupInSpecT-1.1", true)

function addon:CreateRoleTargetMatcher(role)
	local targetMatcher = setmetatable({}, RoleTargetMatcherPrototype)
	targetMatcher.role = role
	return targetMatcher
end

function RoleTargetMatcherPrototype:Matches(unit)
	if UnitIsDeadOrGhost(unit) then return false end
	local role = UnitGroupRolesAssigned(unit)
	local raidTank = GetPartyAssignment("MAINTANK",unit)
	local focus = UnitExists("focus") and UnitIsUnit(unit,"focus")
	if focus then
		return true
	elseif role ~= "NONE" then
		if IsInRaid() then
			return (self.role == "TANK") and raidTank or (self.role == role)
		else
			return self.role == role
		end
	elseif LGIST then
		local guid = UnitGUID(unit)
		local inspectInfo = LGIST:GetCachedInfo(guid)
		if inspectInfo then
			return self.role == inspectInfo.spec_role
		end
	end
end
