local AceAddon = LibStub("AceAddon-3.0")
local AceLocale = LibStub("AceLocale-3.0")

local L = AceLocale:GetLocale("TankMD")
local TankMD = AceAddon:GetAddon("TankMD")
---@cast TankMD TankMD

local _, class = UnitClass("player")
local spellId = TankMD:GetMisdirectSpellID(class)
local spell = GetSpellInfo(spellId)
local roleKey = TankMD:GetMisdirectTargetRole(class)

_G["BINDING_HEADER_TANKMD"] = L.title

_G["BINDING_NAME_CLICK TankMDButton1:LeftButton"] = L.toFirst:format(spell, L[roleKey])
_G["BINDING_NAME_CLICK TankMDButton2:LeftButton"] = L.toSecond:format(spell, L[roleKey])
_G["BINDING_NAME_CLICK TankMDButton3:LeftButton"] = L.toThird:format(spell, L[roleKey])
_G["BINDING_NAME_CLICK TankMDButton4:LeftButton"] = L.toFourth:format(spell, L[roleKey])
_G["BINDING_NAME_CLICK TankMDButton5:LeftButton"] = L.toFifth:format(spell, L[roleKey])
