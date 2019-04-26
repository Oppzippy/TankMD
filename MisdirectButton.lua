local _, addon = ...

local MisdirectButtonPrototype = {}
MisdirectButtonPrototype.__index = MisdirectButtonPrototype

-- @string buttonName Global button that is created
-- @number spell spell id
-- @number index: Number of matches to skip
-- @param matchFunc function(unit) that returns true if the unit should be targetable
function addon.CreateMisdirectButton(buttonName, spell, index, matchFunc)
	local misdirectButton = {}
	setmetatable(misdirectButton, MisdirectButtonPrototype)
	misdirectButton.index = index
	misdirectButton.matchFunc = matchFunc

	local button = CreateFrame("Button", buttonName, UIParent, "SecureActionButtonTemplate")
	button:SetAttribute("type", "spell")
	button:SetAttribute("spell", spell)
	button:SetAttribute("checkselfcast", false)
	button:SetAttribute("checkfocuscast", false)
	button:SetAttribute("allowVehicleTarget", false)

	misdirectButton.button = button

	return misdirectButton
end

do
	local party = {"player", "party1", "party2", "party3", "party4"}
	local raid = {
		"raid1", "raid2", "raid3", "raid4", "raid5", "raid6", "raid7", "raid8", "raid9", "raid10",
		"raid11", "raid12", "raid13", "raid14", "raid15", "raid16", "raid17", "raid18", "raid19", "raid20",
		"raid21", "raid22", "raid23", "raid24", "raid25", "raid26", "raid27", "raid28", "raid29", "raid30",
		"raid31", "raid32", "raid33", "raid34", "raid35", "raid36", "raid37", "raid38", "raid39", "raid40"
	}
	function MisdirectButtonPrototype:GetSortedGroupMembers()
		local groupMembers = {}
		local units = IsInRaid() and raid or party
		for i = 1, GetNumGroupMembers() do
			local unit = units[i]
			local name = UnitName(unit)
			groupMembers[i] = name
		end

		table.sort(groupMembers)

		return groupMembers
	end
end

function MisdirectButtonPrototype:FindTarget()
	local groupMembers = self:GetSortedGroupMembers()

	local targetCount = 0
	for i, unit in ipairs(groupMembers) do
		if self.matchFunc(unit) then
			targetCount = targetCount + 1
			if targetCount == self.index then
				return unit
			end
		end
	end
end

function MisdirectButtonPrototype:UpdateTarget()
	local target = self:FindTarget()
	if target then
		self:SetEnabled(true)
		self.button:SetAttribute("unit", target)
	else
		self:SetEnabled(false)
	end
end

function MisdirectButtonPrototype:SetEnabled(enabled)
	if enabled then
		self.button:SetAttribute("type", "spell")
	else
		self.button:SetAttribute("type", nil)
	end
end
