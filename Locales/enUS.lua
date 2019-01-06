-- Default locale if others aren't present
-- if GetLocale() ~= "enUS" then return end

local _, addon = ...
local config = addon.config

local _, class = UnitClass("player")
-- Misdirect
local misdirectSpell = config.misdirectSpells[class] or config.misdirectSpells["HUNTER"]
local misdirectLocalized = GetSpellInfo(misdirectSpell)

-- Role
local roleMap = {
	["TANK"] = "tank",
	["HEALER"] = "healer",
	["DAMAGER"] = "damager",
}
local role = config.targets[class] or config.targets["HUNTER"]
local roleLocalized = roleMap[role]

_G["BINDING_HEADER_TANKMD"] = "TankMD"

_G["BINDING_NAME_CLICK MisdirectTankButton:LeftButton"] = string.format("%s to first %s", misdirectLocalized, roleLocalized)
_G["BINDING_NAME_CLICK MisdirectTank2Button:LeftButton"] = string.format("%s to second %s", misdirectLocalized, roleLocalized)