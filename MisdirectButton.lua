---@class AddonNamespace
local addon = select(2, ...)

---@class MisdirectButton
---@field index integer
---@field targetSelector TargetSelector
local MisdirectButton = {}
local metatable = {
	__index = MisdirectButton,
}

---@param name string
---@param spell integer
local function createButton(name, spell)
	local button = CreateFrame("Button", name, UIParent, "SecureActionButtonTemplate")
	button:Hide()
	button:SetAttribute("type", "spell")
	button:SetAttribute("spell", spell)
	button:SetAttribute("checkselfcast", false)
	button:SetAttribute("checkfocuscast", false)
	button:SetAttribute("allowVehicleTarget", false)
	button:RegisterForClicks("LeftButtonDown", "LeftButtonUp")
	return button
end

---@param spell integer Spell id
---@param index integer Match index to target
---@return table
function addon:CreateMisdirectButton(spell, index)
	local buttonName = string.format("TankMDButton%d", index)
	local legacyButtonName = "MisdirectTankButton"
	if index > 1 then
		legacyButtonName = string.format("MisdirectTank%dButton", index)
	end

	---@class MisdirectButton
	local misdirectButton = setmetatable({
		index = index,
		button = createButton(buttonName, spell),
		legacyButton = createButton(legacyButtonName, spell),
	}, metatable)

	return misdirectButton
end

---@param target string
function MisdirectButton:SetTarget(target)
	if target then
		self:SetEnabled(true)
		self.button:SetAttribute("unit", target)
		self.legacyButton:SetAttribute("unit", target)
	else
		self:SetEnabled(false)
	end
end

function MisdirectButton:SetEnabled(enabled)
	if enabled then
		self.button:SetAttribute("type", "spell")
		self.legacyButton:SetAttribute("type", "spell")
	else
		self.button:SetAttribute("type", nil)
		self.legacyButton:SetAttribute("type", nil)
	end
end
