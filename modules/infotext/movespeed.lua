-- Movement Speed Infotext

-- ####################################################################################################################
-- ##### Setup and Locals #############################################################################################
-- ####################################################################################################################

---@type string, LUIAddon
local _, LUI = ...
local L = LUI.L

---@type InfotextModule
local module = LUI:GetModule("Infotext")
local element = module:NewElement("MoveSpeed", "AceEvent-3.0")

-- ####################################################################################################################
-- ##### Module Functions #############################################################################################
-- ####################################################################################################################

function element:SetMoveSpeed()
	local baseSpeed = BASE_MOVEMENT_SPEED
	local speed, runSpeed = GetUnitSpeed("player")
	if speed == 0 then
		speed = runSpeed
	end

	element.text = format("Speed: %d%%", speed / baseSpeed * 100)
	element:UpdateTooltip()
end

-- ####################################################################################################################
-- ##### Infotext Display #############################################################################################
-- ####################################################################################################################

-- ####################################################################################################################
-- ##### Framework Events #############################################################################################
-- ####################################################################################################################

function element:OnCreate()
	-- module:SetMoveSpeed()
	element:AddUpdate("SetMoveSpeed", 1)
end
