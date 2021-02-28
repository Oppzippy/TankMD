local _, addon = ...
local GroupInspectTargetMatcher = setmetatable({}, addon.TargetMatcherPrototype)
addon.GroupInspectTargetMatcher = GroupInspectTargetMatcher
GroupInspectTargetMatcher.__index = GroupInspectTargetMatcher

local LGIST = LibStub("LibGroupInSpecT-1.1")

function addon:CreateGroupInspectTargetMatcher(role)
	local targetMatcher = setmetatable({}, GroupInspectTargetMatcher)
	targetMatcher.role = role
	return targetMatcher
end

function GroupInspectTargetMatcher:Matches(unit)
	local guid = UnitGUID(unit)
	local inspectInfo = LGIST:GetCachedInfo(guid)
	if inspectInfo then
		return self.role == inspectInfo.spec_role
	end
end
