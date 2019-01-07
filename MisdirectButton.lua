local _, addon = ...

local MisdirectButtonPrototype = {}
MisdirectButtonPrototype.__index = MisdirectButtonPrototype

function addon.CreateMisdirectButton(index, buttonName, spell, role)
	local misdirectButton = {}
	setmetatable(misdirectButton, MisdirectButtonPrototype)
	misdirectButton.index = index
	misdirectButton.role = role

	local button = CreateFrame("Button", buttonName, UIParent, "SecureActionButtonTemplate")
	button:SetAttribute("type", "spell")
	button:SetAttribute("spell", spell)
	button:SetAttribute("checkselfcast", false)
	button:SetAttribute("checkfocuscast", false)
	button:SetAttribute("allowVehicleTarget", false)

	misdirectButton.button = button

	return misdirectButton
end

function MisdirectButtonPrototype:GetSortedGroupMembers()
	local groupMembers = {}

	local groupType = IsInRaid() and "raid" or "party"
	-- Player is not included in party members, but it is for raid
	if groupType == "party" then
		local name = UnitName("player")
		tinsert(groupMembers, name)
	end
	for i = 1, GetNumGroupMembers() do
		local unit = groupType .. i
		local name = UnitName(unit)
		tinsert(groupMembers, name)
	end

	table.sort(groupMembers)

	return groupMembers
end

function MisdirectButtonPrototype:FindTarget()
	local groupMembers = self:GetSortedGroupMembers(groupMembers)

	local targetCount = 0
	for i, unit in ipairs(groupMembers) do
		if UnitGroupRolesAssigned(unit) == self.role then
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
