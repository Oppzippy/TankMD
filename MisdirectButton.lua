---@class AddonNamespace
local addon = select(2, ...)

---@class MisdirectButton
---@field index integer
---@field targetSelector TargetSelector
local MisdirectButton = {}
local metatable = {
	__index = MisdirectButton,
}

---@param spell integer Spell id
---@param index integer Match index to target
---@return table
function addon:CreateMisdirectButton(spell, index)
	---@class MisdirectButton
	local misdirectButton = setmetatable({
		index = index,
	}, metatable)

	local buttonName = string.format("TankMDButton%d", index)
	local button = CreateFrame("Button", buttonName, UIParent, "SecureActionButtonTemplate")
	-- TODO check if this works
	if index == 1 then
		MisdirectTankButton = button
	else
		_G[string.format("MisdirectTank%dButton", index)] = button
	end
	button:Hide()
	button:SetAttribute("type", "spell")
	button:SetAttribute("spell", spell)
	button:SetAttribute("checkselfcast", false)
	button:SetAttribute("checkfocuscast", false)
	button:SetAttribute("allowVehicleTarget", false)
	button:RegisterForClicks("LeftButtonDown", "LeftButtonUp")

	misdirectButton.button = button

	return misdirectButton
end

---@param target string
function MisdirectButton:SetTarget(target)
	if target then
		self:SetEnabled(true)
		self.button:SetAttribute("unit", target)
	else
		self:SetEnabled(false)
	end
end

function MisdirectButton:SetEnabled(enabled)
	if enabled then
		self.button:SetAttribute("type", "spell")
	else
		self.button:SetAttribute("type", nil)
	end
end
