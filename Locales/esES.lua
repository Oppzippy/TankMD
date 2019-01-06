if GetLocale() ~= "esES" and GetLocale() ~= "esMX" then return end

local _, addon = ...
local config = addon.config

local _, class = UnitClass("player")
-- Misdirect
local misdirectSpell = config.misdirectSpells[class] or config.misdirectSpells["HUNTER"]
local misdirectLocalized = GetSpellInfo(misdirectSpell)

-- Role
local roleMap = {
	["TANK"] = "tanque",
	["HEALER"] = "curador",
	["DAMAGER"] = "dañador",
}
local role = config.targets[class] or config.targets["HUNTER"]
local roleLocalized = roleMap[role]

_G["BINDING_HEADER_TANKMD"] = "TankMD"

_G["BINDING_NAME_CLICK MisdirectTankButton:LeftButton"] = string.format("%s al primer %s", misdirectLocalized, roleLocalized)
_G["BINDING_NAME_CLICK MisdirectTank2Button:LeftButton"] = string.format("%s al segundo %s", misdirectLocalized, roleLocalized)