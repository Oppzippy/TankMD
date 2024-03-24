local _, addon = ...

---@class MisdirectButton
---@field button Frame|SecureActionButtonTemplate
---@field index integer
---@field targetMatchers TargetMatcher[]
local MisdirectButton = {}
local metatable = {
	__index = MisdirectButton,
}

---@param buttonName string Global button that is created
---@param spell integer Spell id
---@param index integer Match index to target
---@param targetMatchers TargetMatcher[]
---@return table
function addon:CreateMisdirectButton(buttonName, spell, index, targetMatchers)
	local misdirectButton = setmetatable({
		index = index,
		targetMatchers = targetMatchers,
	}, metatable)

	local button = CreateFrame("Button", buttonName, UIParent, "SecureActionButtonTemplate")
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

function MisdirectButton:UpdateTarget()
	local target = self:FindTarget()
	if target then
		self:SetEnabled(true)
		self.button:SetAttribute("unit", target)
	else
		self:SetEnabled(false)
	end
end

function MisdirectButton:FindTarget()
	local currentIndex = 0
	for _, targetMatcher in ipairs(self.targetMatchers) do
		local targets = targetMatcher:FindTargets()
		if currentIndex + #targets > self.index then
			return targets[self.index - currentIndex]
		end
	end
end

function MisdirectButton:SetEnabled(enabled)
	if enabled then
		self.button:SetAttribute("type", "spell")
	else
		self.button:SetAttribute("type", nil)
	end
end
