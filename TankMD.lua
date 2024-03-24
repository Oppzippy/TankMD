local _, addon = ...

local LGIST = LibStub("LibGroupInSpecT-1.1", true)
local AceAddon = LibStub("AceAddon-3.0")

---@class TankMD: AceAddon, AceEvent-3.0
local TankMD = AceAddon:NewAddon("TankMD", "AceEvent-3.0")
---@type MisdirectButton[]
TankMD.buttons = {}
---@type table<MisdirectButton, boolean>
TankMD.updateQueued = {}

function TankMD:OnInitialize()
	self:RegisterEvent("GROUP_ROSTER_UPDATE", "QueueTankUpdate")
	self:RegisterEvent("PLAYER_ENTERING_WORLD", "QueueTankUpdate")

	self:RegisterEvent("PLAYER_REGEN_ENABLED", "ProcessTankUpdate")
end

function TankMD:OnEnable()
	self:RegisterLGIST()
	self:CreateMisdirectButtons()
end

function TankMD:RegisterLGIST()
	if LGIST then
		local inspectHandler = {
			GroupInSpecT_Update = function()
				self:QueueTankUpdate()
			end,
		}

		LGIST.RegisterCallback(inspectHandler, "GroupInSpecT_Update")
	end
end

function TankMD:QueueTankUpdate()
	for _, button in pairs(self.buttons) do
		self.updateQueued[button] = true
	end

	self:ProcessTankUpdate()
end

function TankMD:ProcessTankUpdate()
	if InCombatLockdown() then return end

	for _, button in pairs(self.buttons) do
		if self.updateQueued[button] then
			button:UpdateTarget()
			self.updateQueued[button] = nil
		end
	end
end

function TankMD:CreateMisdirectButtons()
	if #self.buttons > 0 then return end -- only run once

	local _, class = UnitClass("player")
	local spell = self:GetMisdirectSpellID(class)
	local role = self:GetMisdirectTargetRole(class)

	local targetMatcher
	if class == "HUNTER" then
		targetMatcher = addon:CreateRoleOrPetTargetMatcher(role)
	elseif class == "EVOKER" then
		targetMatcher = addon:CreateRoleOrSelfTargetMatcher(role)
	else
		targetMatcher = addon:CreateRoleTargetMatcher(role)
	end

	for i = 1, 5 do
		-- Modern button naming
		local buttonName = string.format("TankMDButton%d", i)
		local button = addon:CreateMisdirectButton(buttonName, spell, i, targetMatcher)
		self.buttons[#self.buttons + 1] = button

		-- Backwards compatibility with old button naming
		local compatibilityName = "MisdirectTankButton"
		if i > 2 then
			compatibilityName = string.format("MisdirectTank%dButton", i)
		end
		local compatibilityButton = addon:CreateMisdirectButton(compatibilityName, spell, i, targetMatcher)
		self.buttons[#self.buttons + 1] = compatibilityButton
	end
end

do
	local misdirectSpells = {
		["HUNTER"] = 34477,
		["ROGUE"] = 57934,
		["DRUID"] = 29166,
		["EVOKER"] = 360827,
	}

	---@param class string
	---@return integer spellID Spell id for the class's misdirect. Defaults to Misdirection if the class does not have a misdirect.
	function TankMD:GetMisdirectSpellID(class)
		return misdirectSpells[class] or misdirectSpells["HUNTER"]
	end
end

do
	-- What role to target with the ability
	local targets = {
		["HUNTER"] = "TANK",
		["ROGUE"] = "TANK",
		["DRUID"] = "HEALER",
		["EVOKER"] = "TANK",
	}

	---@param class string
	---@return "TANK"|"HEALER" role Target role for the class's misdirect. Defaults to TANK if the class does not have a misdirect.
	function TankMD:GetMisdirectTargetRole(class)
		return targets[class] or "TANK"
	end
end
