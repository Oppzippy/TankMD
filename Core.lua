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