-- ####################################################################################################################
-- ##### Setup and Locals #############################################################################################
-- ####################################################################################################################

---@type string, Opt
local optName, Opt = ...
local LUI = Opt.LUI
local L = LUI.L

local IsShiftKeyDown = _G.IsShiftKeyDown

-- ####################################################################################################################
-- ##### Utility Functions ############################################################################################
-- ####################################################################################################################

local function GenerateModuleButtons()
    local args = {}
    for name, mod in LUI:IterateModules() do
        if mod.enableButton then
			args[name] = Opt:EnableButton(name, L["Core_ModuleClickHint"], nil,
				function() return mod:IsEnabled() end,
				function(info, btn)
					if IsShiftKeyDown() then
						mod.db:ResetProfile()
						mod:ModPrint(L["Core_ModuleReset"])
					else
						if mod.VToggle then mod:VToggle()
						elseif mod.Toggle then mod:Toggle()
						end
						mod:ModPrint( (mod:IsEnabled()) and L["API_BtnEnabled"] or L["API_BtnDisabled"])
						StaticPopup_Show("RELOAD_UI")
					end
				end
			)
        end
    end
    return args
end

local infotext = LUI:GetModule("Infotext", true)
local function GenerateInfotextButtons()
	local args = {}
	for name, obj in infotext.LDB:DataObjectIterator() do
		args[name] = Opt:EnableButton(name, nil, nil,
			function() return true end,
			function() infotext:ToggleInfotext(name) end
		)
	end
	return args
end

local addonMod = LUI:GetModule("Addons", true)
local function GenerateAddonSupportButtons()
	local args = {}
	args.Desc = Opt:Desc(L["CPanel_AddonDesc"], 1)
	args.Break = Opt:Spacer(2, "full")
	for name, mod in addonMod:IterateModules() do
		args[name] = Opt:Execute(format(L["CPanel_AddonReset"], name), nil, nil,
			function()
				--addonMod.db.Installed[name] = nil
				addonMod:OnEnable()
			end
		)
	end
	return args
end

-- ####################################################################################################################
-- ##### Options Tables ###############################################################################################
-- ####################################################################################################################

Opt.options.args.CPanel = Opt:Group("Control Panel", nil, 3, "tab")
Opt.options.args.CPanel.handler = LUI
local CPanel = {
	Modules = Opt:Group(L["CPanel_Modules"], nil, 1),
	Infotext = Opt:Group(L["CPanel_Infotext"], nil, 2, nil, function() return infotext and infotext.registered end),
	Addons = Opt:Group(L["CPanel_Addons"], nil, 3, nil, function() return addonMod and addonMod.registered end),
}

CPanel.Modules.args = GenerateModuleButtons()
if infotext and infotext.registered then CPanel.Infotext.args = GenerateInfotextButtons() end
if addonMod and addonMod.registered then CPanel.Addons.args = GenerateAddonSupportButtons() end

Opt.options.args.CPanel.args = CPanel