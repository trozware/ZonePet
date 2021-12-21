-- use this command in game to get the version number
-- /run print((select(4, GetBuildInfo())));

ZonePet = {} 
ZonePet_LastPetChange = 0
ZonePet_LastEventTrigger = 0
ZonePet_LastError = 0
ZonePet_LastPetID = nil
ZonePet_PrevPetID = nil
ZonePet_LockPet = false

ZonePet_Stealthed = IsStealthed()
ZonePet_PreviousMessage = ""
ZonePet_HaveDismissed = false
ZonePet_TooltipVisible = false
ZonePet_IsChannelling = false
ZonePet_IsPvP = false
ZonePet_Icon = nil
ZonePet_Tooltip = nil
ZonePet_InterfaceMinimapButton = nil

function ZonePet_displayMessage(msg)
  if msg ~= ZonePet_PreviousMessage then
    ZonePet_PreviousMessage = msg
    ChatFrame1:AddMessage(msg)
  end
end

-----------------------------------------------------------------
-- MINIMAP BUTTON FUNCTIONS
-----------------------------------------------------------------

function ZonePet:Initialize()
  SLASH_ZONEPET1, SLASH_ZONEPET2 = "/zonepet", "/zp"
  SlashCmdList["ZONEPET"] = ZonepetCommandHandler

	if not zonePetMiniMap then
		zonePetMiniMap = {
      Hidden = false,
      favsOnly = false,
      noSpiders = false,
      notInPvP = true,
      notInGroup = false,
      hideInfo = false
		}
	end

  ZonePet_addInterfaceOptions()
  ZonePet_initMiniMapButton()
end

function ZonePet_initMiniMapButton()
  local miniButton = LibStub("LibDataBroker-1.1"):NewDataObject("ZonePet", {
    type = "data source",
    text = "ZonePet",
    icon = "Interface\\ICONS\\Tracking_WildPet",
    OnClick = function(self, button)
      if button == "RightButton" then
        if IsAltKeyDown() then
          zonePetMiniMap.Hidden=true
          zonePetMiniMap.hide = true
          ZonePet_Icon:Hide("ZonePet")
          ZonepetCommandHandler('help')
          ZonePet_TooltipVisible = false
          if ZonePet_InterfaceMinimapButton then 
            ZonePet_InterfaceMinimapButton:SetChecked(zonePetMiniMap.Hidden == false)
          end
        else
          ZonePet_HaveDismissed = true
          ZonePet_dismissCurrentPet()
        end
      else
        if IsAltKeyDown() then
          ZonePet_lockCurrentPet()
          ZonePet_showTooltip(ZonePet_Tooltip)
        elseif IsShiftKeyDown() then
          ZonePet_summonPreviousPet()
        else
          ZonePet_LockPet = false
          local noSummonReason = ZonePet_summonForZone()
          ZonePet_showReasonForNotSummoning(noSummonReason)
        end
      end
    end,
    OnTooltipShow = function(tooltip)
      ZonePet_Tooltip = tooltip
      if not tooltip or not tooltip.AddLine then return end
      ZonePet_showTooltip(tooltip)
    end,
  })

  ZonePet_Icon = LibStub("LibDBIcon-1.0", true)
  ZonePet_Icon:Register("ZonePet", miniButton, zonePetMiniMap)

  C_Timer.After(0.5,
    function()
      if zonePetMiniMap.Hidden then
        zonePetMiniMap.hide = true
        ZonePet_Icon:Hide("ZonePet")
      end
    end
  )
end

function ZonePet_showTooltip(tooltip)
  if not tooltip or not tooltip.AddLine then return end

  local petData = ZonePet_dataForCurrentPet()
  tooltip:ClearLines()
  tooltip:SetText("ZonePet", 1, 1, 1)

  if petData then
    tooltip:AddLine(" ")
    tooltip:AddLine(" ")
    tooltip:AddTexture(petData.icon, {width = 32, height = 32})
    tooltip:AddLine(" ")
    tooltip:AddLine(petData.name, 0, 1, 0, true)
    tooltip:AddLine(petData.desc, 0, 1, 1, true)

    local interaction = ZonePet_interaction(petData.name)
    if interaction and interaction ~= "" then
      tooltip:AddLine("Target " .. petData.name .. " and type " .. interaction .. " to interact.", 1, 1, 1, true)
    end
  elseif ZonePet_HaveDismissed then
    tooltip:AddLine(" ")
    local msg = "You have dismissed your pet. No new pet will be summoned until you left-click here or use '/zp new'."
    tooltip:AddLine(msg , 0, 1, 1, true)
  end
  
  tooltip:AddLine("\nLeft-click to summon a new pet, from this zone if possible.")

  if ZonePet_PrevPetID ~= nil then
    tooltip:AddLine("Shift + Left-click to go back to the previous pet.")
  end

  if petData then
    if ZonePet_LockPet == true then
      tooltip:AddLine("You have locked in your current pet.")
      tooltip:AddLine("Left-click to summon a different pet.")
    else
      tooltip:AddLine("Alt + Left-click to lock in this pet.")
    end
  end

  tooltip:AddLine(" ")
  tooltip:AddLine("Right-click to dismiss your current pet.")

  tooltip:Show()
  ZonePet_TooltipVisible = true
end

function ZonepetCommandHandler(msg) 
  if msg == "mini" then
    if zonePetMiniMap.Hidden == true then
      ZonePet_Icon:Show("ZonePet")
      zonePetMiniMap.Hidden=false
      zonePetMiniMap.hide = false
    else
      ZonePet_Icon:Hide("ZonePet")
      zonePetMiniMap.Hidden=true
      zonePetMiniMap.hide = true
    end
    if ZonePet_InterfaceMinimapButton then 
      ZonePet_InterfaceMinimapButton:SetChecked(zonePetMiniMap.Hidden == false)
    end
  elseif msg == "dismiss" then
    ZonePet_HaveDismissed = true
    ZonePet_dismissCurrentPet()
  elseif msg == "change" or msg == "new" then
    ZonePet_LockPet = false
    local noSummonReason = ZonePet_summonForZone()
    ZonePet_showReasonForNotSummoning(noSummonReason)
  elseif msg == "all" then
    zonePetMiniMap.favsOnly = false
    ZonePet_summonForZone()
  elseif msg == "fav" or msg == "favs" then
    zonePetMiniMap.favsOnly = true
    ZonePet_summonForZone()
  elseif msg == "dupe" or msg == "dup" then
    ZonePet_showDuplicates()
  elseif msg == "back" then
    ZonePet_summonPreviousPet()
  elseif msg == "lock" then
    ZonePet_lockCurrentPet()
  elseif msg == "about" then
    ZonePet_displayInfoForCurrentPet()
  elseif msg == '' or msg == 'help' then
    ZonePet_displayHelp()
  else
    ZonePet_searchForPet(msg)
  end
end

function ZonePet_showReasonForNotSummoning(reason)
  if reason ~= '' then
    ZonePet_displayMessage("|c0000FF00ZonePet: " .. "|c0000FFFFNo pet summoned because you are " .. reason .. ".")
    ZonePet_PreviousMessage = ''
  end
end

function ZonePet_displayHelp()
  local msg
  msg = "|c0000FF00ZonePet: " .. "|c0000FFFFType |cFFFFFFFF/zp new|c0000FFFF to summon a different pet."
  ChatFrame1:AddMessage(msg)
  msg = "|c0000FF00ZonePet: " .. "|c0000FFFFType |cFFFFFFFF/zp about|c0000FFFF to show some info about your pet."
  ChatFrame1:AddMessage(msg)
  msg = "|c0000FF00ZonePet: " .. "|c0000FFFFType |cFFFFFFFF/zp back|c0000FFFF to summon your previous pet."
  ChatFrame1:AddMessage(msg)
  msg = "|c0000FF00ZonePet: " .. "|c0000FFFFType |cFFFFFFFF/zp lock|c0000FFFF to lock in your current pet."
  ChatFrame1:AddMessage(msg)
  msg = "|c0000FF00ZonePet: " .. "|c0000FFFFType |cFFFFFFFF/zp _name_|c0000FFFF to search for a pet by name."
  ChatFrame1:AddMessage(msg)
  msg = "|c0000FF00ZonePet: " .. "|c0000FFFFType |cFFFFFFFF/zp dismiss|c0000FFFF to dismiss your current pet."
  ChatFrame1:AddMessage(msg)
  msg = "|c0000FF00ZonePet: " .. "|c0000FFFFCheck out |cFFFFFFFFInterface > AddOns|c0000FFFF for more settings."
  ChatFrame1:AddMessage(msg)
end

function ZonePet_addInterfaceOptions()
  local y = -16
  ZonePet.panel = CreateFrame("Frame", "ZonePetPanel", UIParent )
  ZonePet.panel.name = "ZonePet"
  InterfaceOptions_AddCategory(ZonePet.panel)

  local Title = ZonePet.panel:CreateFontString(nil, 'ARTWORK', 'GameFontNormalLarge')
  Title:SetJustifyV('TOP')
  Title:SetJustifyH('LEFT')
  Title:SetPoint('TOPLEFT', 16, y)
  local v = GetAddOnMetadata("ZonePet", "Version") 
  Title:SetText('ZonePet v' .. v)
  y = y - 44

  local btn1 = CreateFrame("CheckButton", nil, ZonePet.panel, "UICheckButtonTemplate")
	btn1:SetSize(26,26)
	btn1:SetHitRectInsets(-2,-160,-2,-2)
	btn1.text:SetText('  Show Minimap button')
	btn1.text:SetFontObject("GameFontNormal")
  btn1:SetPoint('TOPLEFT', 40, y)
  btn1:SetChecked(zonePetMiniMap.Hidden == false)
  btn1:SetScript("OnClick",function() 
    local isChecked = btn1:GetChecked()
    if isChecked then
      ZonePet_Icon:Show("ZonePet")
      zonePetMiniMap.hide = false
      zonePetMiniMap.Hidden=false
    else
      ZonePet_Icon:Hide("ZonePet")
      zonePetMiniMap.hide = true
      zonePetMiniMap.Hidden=true
    end
  end)
  ZonePet_InterfaceMinimapButton = btn1
  y = y - 40

  local btnFT = CreateFrame("CheckButton", nil, ZonePet.panel, "UICheckButtonTemplate")
	btnFT:SetSize(26,26)
	btnFT:SetHitRectInsets(-2,-200,-2,-2)
	btnFT.text:SetText('  Show pet info in Chat')
	btnFT.text:SetFontObject("GameFontNormal")
  btnFT:SetPoint('TOPLEFT', 40, y)
  btnFT:SetChecked(not zonePetMiniMap.hideInfo)
  btnFT:SetScript("OnClick",function() 
    local isChecked = btnFT:GetChecked()
    zonePetMiniMap.hideInfo = not isChecked
  end)
  y = y - 40

  local btn2 = CreateFrame("CheckButton", nil, ZonePet.panel, "UICheckButtonTemplate")
	btn2:SetSize(26,26)
	btn2:SetHitRectInsets(-2,-200,-2,-2)
	btn2.text:SetText('  Select from Favorites only')
	btn2.text:SetFontObject("GameFontNormal")
  btn2:SetPoint('TOPLEFT', 40, y)
  btn2:SetChecked(zonePetMiniMap.favsOnly)
  btn2:SetScript("OnClick",function() 
    local isChecked = btn2:GetChecked()
    zonePetMiniMap.favsOnly = isChecked
    ZonePet_summonForZone()
  end)
  y = y - 40

  local btn3 = CreateFrame("CheckButton", nil, ZonePet.panel, "UICheckButtonTemplate")
	btn3:SetSize(26,26)
	btn3:SetHitRectInsets(-2,-100,-2,-2)
	btn3.text:SetText('  NO SPIDERS!')
	btn3.text:SetFontObject("GameFontNormal")
  btn3:SetPoint('TOPLEFT', 40, y)
  btn3:SetChecked(zonePetMiniMap.noSpiders)
  btn3:SetScript("OnClick",function() 
    local isChecked = btn3:GetChecked()
    zonePetMiniMap.noSpiders = isChecked
    ZonePet_summonForZone()
  end)
  y = y - 40

  local btn9 = CreateFrame("CheckButton", nil, ZonePet.panel, "UICheckButtonTemplate")
	btn9:SetSize(26,26)
  btn9:SetHitRectInsets(-2,-200,-2,-2)
	btn9.text:SetText('  Do not summon pets while in PvP')
  btn9.text:SetFontObject("GameFontNormal")
  btn9:SetPoint('TOPLEFT', 40, y)
  btn9:SetChecked(zonePetMiniMap.notInPvP)
  btn9.tooltipTitle = 'List Duplicates'
  btn9.tooltipBody = 'Your duplicate pets will be listed in the chat.'
  btn9:SetScript("OnClick",function() 
    local isChecked = btn9:GetChecked()
    ZonePet_changePvPOption(isChecked)
  end)
  y = y - 40

  local btn10 = CreateFrame("CheckButton", nil, ZonePet.panel, "UICheckButtonTemplate")
	btn10:SetSize(26,26)
  btn10:SetHitRectInsets(-2,-200,-2,-2)
	btn10.text:SetText('  Do not summon pets while in a group or raid')
  btn10.text:SetFontObject("GameFontNormal")
  btn10:SetPoint('TOPLEFT', 40, y)
  btn10:SetChecked(zonePetMiniMap.notInGroup)
  btn10.tooltipTitle = 'List Duplicates'
  btn10.tooltipBody = 'Your duplicate pets will be listed in the chat.'
  btn10:SetScript("OnClick",function() 
    local isChecked = btn10:GetChecked()
    ZonePet_changeGroupOption(isChecked)
  end)
  y = y - 40

  local btn4 = CreateFrame("Button", nil, ZonePet.panel, "UIPanelButtonTemplate")
	btn4:SetSize(160,26)
	btn4:SetText('New Pet')
  btn4:SetPoint('TOPLEFT', 40, y)
  btn4:SetScript("OnClick",function() 
    ZonePet_summonForZone()
  end)

  local btn7 = CreateFrame("Button", nil, ZonePet.panel, "UIPanelButtonTemplate")
	btn7:SetSize(160,26)
	btn7:SetText('Previous Pet')
  btn7:SetPoint('TOPLEFT', 220, y)
  btn7:SetScript("OnClick",function() 
    ZonePet_summonPreviousPet()
  end)

  local btn5 = CreateFrame("Button", nil, ZonePet.panel, "UIPanelButtonTemplate")
	btn5:SetSize(160,26)
	btn5:SetText('Dismiss Pet')
  btn5:SetPoint('TOPLEFT', 400, y)
  btn5:SetScript("OnClick",function() 
    ZonePet_HaveDismissed = true
    ZonePet_dismissCurrentPet()
  end)
  y = y - 40

  local btn6 = CreateFrame("CheckButton", nil, ZonePet.panel, "UICheckButtonTemplate")
	btn6:SetSize(26,26)
	btn6:SetHitRectInsets(-2,-160,-2,-2)
	btn6.text:SetText('  Lock in current pet')
	btn6.text:SetFontObject("GameFontNormal")
  btn6:SetPoint('TOPLEFT', 40, y)
  btn6:SetChecked(ZonePet_LockPet)
  btn6:SetScript("OnClick",function() 
    local isChecked = btn6:GetChecked()
    if isChecked then
      ZonePet_lockCurrentPet()
      ZonePet_showTooltip(ZonePet_Tooltip)
    else
      ZonePet_LockPet = false
      ZonePet_summonForZone()
    end
  end)
  y = y - 40

  local searchTitle = ZonePet.panel:CreateFontString(nil, 'ARTWORK', 'GameFontNormal')
  searchTitle:SetJustifyV('TOP')
  searchTitle:SetJustifyH('LEFT')
  searchTitle:SetPoint('TOPLEFT', 40, y-6)
  searchTitle:SetText('Search for:')

  local searchBox = CreateFrame('editbox', nil, ZonePet.panel, 'InputBoxTemplate')
  searchBox:SetPoint('TOPLEFT', 120, y)
  searchBox:SetHeight(20)
  searchBox:SetWidth(140)
  searchBox:SetText('')
  searchBox:SetAutoFocus(false)
  searchBox:ClearFocus()
  searchBox:SetScript('OnEnterPressed', function(self)
    self:SetAutoFocus(false) -- Clear focus when enter is pressed because ketho said so
    self:ClearFocus()
    ZonePet_searchForPet(self:GetText())
    btn6:SetChecked(true)
  end)
  y = y - 40

  local btn9 = CreateFrame("Button", nil, ZonePet.panel, "UIPanelButtonTemplate")
	btn9:SetSize(160,26)
	btn9:SetText('Show Slash Commands')
  btn9:SetPoint('TOPLEFT', 40, y)
  btn9:SetScript("OnClick",function() 
    ZonePet_displayHelp()
  end)

  local btn8 = CreateFrame("Button", nil, ZonePet.panel, "UIPanelButtonTemplate")
	btn8:SetSize(160,26)
	btn8:SetText('List Duplicates in Chat')
  btn8:SetPoint('TOPLEFT', 220, y)
  btn8.tooltipTitle = 'List Duplicates'
  btn8.tooltipBody = 'Your duplicate pets will be listed in the chat.'
  btn8:SetScript("OnClick",function() 
    ZonePet_showDuplicates()
  end)

end
