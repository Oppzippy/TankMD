---@class AddonNamespace
local addon = select(2, ...)

local TargetSelectionStrategy = addon.TargetSelectionStrategy
local TargetSelector = addon.TargetSelector

local LGIST = LibStub("LibGroupInSpecT-1.1", true)
local AceAddon = LibStub("AceAddon-3.0")

---@class TankMD: AceAddon, AceEvent-3.0
local TankMD = AceAddon:NewAddon("TankMD", "AceEvent-3.0")
---@type MisdirectButton[]
TankMD.buttons = {}
TankMD.isUpdateQueued = false

local classTargetSelectorChains = {
	HUNTER = TargetSelector.Chain({
		TargetSelector.Group(TargetSelectionStrategy.Role("TANK")),
		TargetSelector.Pet(),
	}),
	ROGUE = TargetSelector.Group(TargetSelectionStrategy.Role("TANK")),
	EVOKER = TargetSelector.Chain({
		TargetSelector.Group(TargetSelectionStrategy.Role("TANK")),
		TargetSelector.Player(),
	}),
	DRUID = TargetSelector.Group(TargetSelectionStrategy.Role("TANK")),
}

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
	self.isUpdateQueued = true
	self:ProcessTankUpdate()
end

function TankMD:ProcessTankUpdate()
	if not self.isUpdateQueued or InCombatLockdown() then return end
	self.isUpdateQueued = false

	local i = 0
	for target in self:GetTargetSelector() do
		i = i + 1
		local button = self.buttons[i]
		if button ~= nil then
			button:SetTarget(target)
		else
			break
		end
	end
end

function TankMD:CreateMisdirectButtons()
	if #self.buttons > 0 then return end -- only run once

	local _, class = UnitClass("player")
	local spell = self:GetMisdirectSpellID(class)

	for i = 1, 5 do
		local button = addon:CreateMisdirectButton(spell, i)
		self.buttons[i] = button
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

---@return TargetSelector
function TankMD:GetTargetSelector()
	local class = UnitClass("player")
	return classTargetSelectorChains[class] or TargetSelector.Chain({})
end
