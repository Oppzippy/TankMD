local _, addon = ...
addon.buttons = {}

-- Queue updates for all buttons
function addon:QueueUpdate()
	for _, misdirect in pairs(self.buttons) do
		misdirect.updateQueued = true
	end
end

-- Update target for all buttons
function addon:Update()
	if InCombatLockdown() then return end

	for _, misdirect in pairs(self.buttons) do
		if misdirect.updateQueued then
			misdirect:UpdateTarget()
			misdirect.updateQueued = false
		end
	end
end

function addon:CreateButtons()
	if #addon.buttons > 0 then return end

	local _, class = UnitClass("player")
	local spell = self.config.misdirectSpells[class]
	local role = self.config.targets[class]
	local matchFunc = function(unit)
		return UnitGroupRolesAssigned(unit) == role
	end
	for i, buttonName in pairs(self.config.misdirectButtons) do
		local button = addon.CreateMisdirectButton(buttonName, spell, i, matchFunc)
		tinsert(addon.buttons, button)
	end
end
