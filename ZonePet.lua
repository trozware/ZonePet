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
			dragable = true,
			angle = 222,
			radius = 80,
			rounding = 10,
      Hidden = false,
      favsOnly = false,
      noSpiders = false
		}
	end

  -- MinimapFrame
	local f = CreateFrame("Frame", "ZonePet".."Minimap", Minimap)
	f:SetFrameStrata("LOW")
	f:SetWidth(33)
	f:SetHeight(33)
	f:SetPoint("CENTER")
	f:EnableMouse(true)
	self.Minimap = f
	
	-- Minimap
	local b = CreateFrame("Button", nil, f)
	b:SetAllPoints(f)
	b:SetHighlightTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight")
  if zonePetMiniMap.Hidden then
    b:Hide()
  else
    b:Show()
  end
  zonePetMiniMap.Button = b

	-- MinimapIcon
	local t = b:CreateTexture(nil, "BACKGROUND")
	t:SetWidth(20)
	t:SetHeight(20)
	t:SetPoint("CENTER")
	MinimapIconTexture = t
	t:SetTexture("Interface\\ICONS\\Tracking_WildPet")
	
	-- MinimapBorder
	t = b:CreateTexture(nil, "OVERLAY")
	t:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")
	t:SetWidth(52)
	t:SetHeight(52)
	t:SetPoint("TOPLEFT")
	
	-- set some scripts
  b:SetScript("OnClick", function(self, button, down)
    if button == "RightButton" then
      if IsAltKeyDown() then
        zonePetMiniMap.Button:Hide()
        zonePetMiniMap.Hidden=true
        ZonepetCommandHandler('help')
        ZonePet_TooltipVisible = false
      else
        ZonePet_HaveDismissed = true
        ZonePet_dismissCurrentPet()
      end
    else
      if IsAltKeyDown() then
        ZonePet_lockCurrentPet()
        ZonePet_showTooltip()
      elseif IsShiftKeyDown() then
        ZonePet_summonPreviousPet()
      else
        ZonePet_LockPet = false
        ZonePet_summonForZone()
      end
    end
  end)

	b:SetScript("OnDragStart", function(self,event)
    if(zonePetMiniMap.dragable) then
      self.dragme = true
      ZonePet_TooltipVisible = false
      self:LockHighlight()
    end
	end)

	b:SetScript("OnDragStop", function(self, event)
    self.dragme = false
    ZonePet_TooltipVisible = false
    self:UnlockHighlight()
  end)

	b:SetScript("OnUpdate", function(self, event)
    if self.dragme == true then
      ZonePet_TooltipVisible = false
      ZonePet:MinimapBeingDragged()
    end
  end)

  b:SetScript("OnEnter", function(self, event)
    ZonePetTooltip:SetOwner(self, "ANCHOR_NONE")
    ZonePetTooltip:SetPoint("TOPRIGHT", self, "BOTTOM")
    ZonePetTooltip:SetScript("OnHide", function(self, event)
      -- this should make sure it never appears in the wrong place
      ZonePet_TooltipVisible = false
    end)
    ZonePet_showTooltip(self)
  end)

  b:SetScript("OnLeave", function(self,event)
    ZonePetTooltip:Hide()
  end)

  b:RegisterForDrag("LeftButton")
  b:RegisterForClicks("LeftButtonUp", "RightButtonUp")
  b.dragme = false
  
  CreateFrame("GameTooltip", "ZonePetTooltip", UIParent, "GameTooltipTemplate")

  ZonePet_addInterfaceOptions()
end

function ZonePet_showTooltip(self)
  local petData = ZonePet_dataForCurrentPet()
  ZonePetTooltip:ClearLines()
  ZonePetTooltip:SetText("ZonePet", 1, 1, 1)

  if petData then
    ZonePetTooltip:AddLine(" ")
    ZonePetTooltip:AddLine(" ")
    ZonePetTooltip:AddTexture(petData.icon, {width = 32, height = 32})
    ZonePetTooltip:AddLine(" ")
    ZonePetTooltip:AddLine(petData.name, 0, 1, 0, true)
    ZonePetTooltip:AddLine(petData.desc, 0, 1, 1, true)

    local interaction = ZonePet_interaction(petData.name)
    if interaction and interaction ~= "" then
      ZonePetTooltip:AddLine("Target " .. petData.name .. " and type " .. interaction .. " to interact.", 1, 1, 1, true)
    end
  elseif ZonePet_HaveDismissed then
    ZonePetTooltip:AddLine(" ")
    local msg = "You have dismissed your pet. No new pet will be summoned until you left-click here or use '/zp new'."
    ZonePetTooltip:AddLine(msg , 0, 1, 1, true)
  end
  
  ZonePetTooltip:AddLine("\nLeft-click to summon a new pet, from this zone if possible.")

  if ZonePet_PrevPetID ~= nil then
    ZonePetTooltip:AddLine("Shift + Left-click to go back to the previous pet.")
  end

  if petData then
    if ZonePet_LockPet == true then
      ZonePetTooltip:AddLine("You have locked in your current pet.")
      ZonePetTooltip:AddLine("Left-click to summon a different pet.")
    else
      ZonePetTooltip:AddLine("Alt + Left-click to lock in this pet.")
    end
  end

  ZonePetTooltip:AddLine(" ")
  ZonePetTooltip:AddLine("Right-click to dismiss your current pet.")

  ZonePetTooltip:Show()
  ZonePet_TooltipVisible = true
end
    
local MinimapShapes = {
	-- quadrant booleans (same order as SetTexCoord)
	-- {upper-left, lower-left, upper-right, lower-right}
	-- true = rounded, false = squared
	["ROUND"] 								= {true, true, true, true},
	["SQUARE"] 								= {false, false, false, false},
	["CORNER-TOPLEFT"] 				= {true, false, false, false},
	["CORNER-TOPRIGHT"] 			= {false, false, true, false},
	["CORNER-BOTTOMLEFT"] 		= {false, true, false, false},
	["CORNER-BOTTOMRIGHT"]	 	= {false, false, false, true},
	["SIDE-LEFT"] 						= {true, true, false, false},
	["SIDE-RIGHT"] 						= {false, false, true, true},
	["SIDE-TOP"] 							= {true, false, true, false},
	["SIDE-BOTTOM"] 					= {false, true, false, true},
	["TRICORNER-TOPLEFT"] 		= {true, true, true, false},
	["TRICORNER-TOPRIGHT"] 		= {true, false, true, true},
	["TRICORNER-BOTTOMLEFT"] 	= {true, true, false, true},
	["TRICORNER-BOTTOMRIGHT"] = {false, true, true, true},
}
  
function ZonePet:MinimapUpdatePosition()
	local radius, rounding, angle
	
	radius = zonePetMiniMap.radius
	rounding = zonePetMiniMap.rounding
	angle = math.rad(zonePetMiniMap.angle)
	
	local x = math.cos(angle)
	local y = math.sin(angle)
	local q = 1;
	if x < 0 then
		q = q + 1;	-- lower
	end
	if y > 0 then
		q = q + 2;	-- right
	end
	local minimapShape = GetMinimapShape and GetMinimapShape() or "ROUND"
	local quadTable = MinimapShapes[minimapShape]
	if quadTable[q] then
		x = x*radius
		y = y*radius
	else
		local diagRadius = math.sqrt(2*(radius)^2)-rounding
		x = math.max(-radius, math.min(x*diagRadius, radius))
		y = math.max(-radius, math.min(y*diagRadius, radius))
	end
	ZonePet.Minimap:SetPoint("CENTER", Minimap, "CENTER", x, y-1)
    if ZonePet.Minimap.Button then
        ZonePet.Minimap.Button:Show()
    end
end

function ZonePet:SetMinimapPosition(angle, radius, rounding)
	zonePetMiniMap.angle = angle
	if(radius) then
		zonePetMiniMap.radius = radius
	end
	if(rounding) then
		zonePetMiniMap.rounding = rounding
	end
	ZonePet:MinimapUpdatePosition()
end

function ZonePet:MinimapBeingDragged()
	local mx, my = Minimap:GetCenter()
	local mz = MinimapCluster:GetScale()
	local cx, cy = GetCursorPosition(UIParent)
	local cz = UIParent:GetEffectiveScale()
	local v = math.deg(math.atan2(cy / cz - my * mz, cx / cz - mx * mz))
	if v < 0 then
		v = v + 360
	elseif v > 360 then
		v = v - 360
	end
	ZonePet:SetMinimapPosition(v)
end

function ZonepetCommandHandler(msg) 
  if msg == "mini" then
    if zonePetMiniMap.Hidden == true then
      zonePetMiniMap.Button:Show()
      zonePetMiniMap.Hidden=false
    else
      zonePetMiniMap.Button:Hide()
      zonePetMiniMap.Hidden=true
    end
  elseif msg == "dismiss" then
    ZonePet_HaveDismissed = true
    ZonePet_dismissCurrentPet()
  elseif msg == "change" or msg == "new" then
    ZonePet_LockPet = false
    ZonePet_summonForZone()
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
  ZonePet.panel = CreateFrame("Frame", "ZonePetPanel", UIParent )
  ZonePet.panel.name = "ZonePet"
  InterfaceOptions_AddCategory(ZonePet.panel)

  local Title = ZonePet.panel:CreateFontString(nil, 'ARTWORK', 'GameFontNormalLarge')
  Title:SetJustifyV('TOP')
  Title:SetJustifyH('LEFT')
  Title:SetPoint('TOPLEFT', 16, -16)
  local v = GetAddOnMetadata("ZonePet", "Version") 
  Title:SetText('ZonePet v' .. v)

  local btn1 = CreateFrame("CheckButton", nil, ZonePet.panel, "UICheckButtonTemplate")
	btn1:SetSize(26,26)
	btn1:SetHitRectInsets(-2,-160,-2,-2)
	btn1.text:SetText('  Show Minimap button')
	btn1.text:SetFontObject("GameFontNormal")
  btn1:SetPoint('TOPLEFT', 40, -60)
  btn1:SetChecked(zonePetMiniMap.Hidden == false)
  btn1:SetScript("OnClick",function() 
    local isChecked = btn1:GetChecked()
    if isChecked then
      zonePetMiniMap.Button:Show()
      zonePetMiniMap.Hidden=false
    else
      zonePetMiniMap.Button:Hide()
      zonePetMiniMap.Hidden=true
    end
  end)
	-- button:SetScript("OnEnter",function(self) if not rematch:UIJustChanged() then rematch.ShowTooltip(self) end end)
	-- button.tooltipTitle = L["Enable Rematch"]
	-- button.tooltipBody = L["Check this to use Rematch in the pet journal."]

  local btn2 = CreateFrame("CheckButton", nil, ZonePet.panel, "UICheckButtonTemplate")
	btn2:SetSize(26,26)
	btn2:SetHitRectInsets(-2,-200,-2,-2)
	btn2.text:SetText('  Select from Favorites only')
	btn2.text:SetFontObject("GameFontNormal")
  btn2:SetPoint('TOPLEFT', 40, -100)
  btn2:SetChecked(zonePetMiniMap.favsOnly)
  btn2:SetScript("OnClick",function() 
    local isChecked = btn2:GetChecked()
    zonePetMiniMap.favsOnly = isChecked
    ZonePet_summonForZone()
  end)

  local btn3 = CreateFrame("CheckButton", nil, ZonePet.panel, "UICheckButtonTemplate")
	btn3:SetSize(26,26)
	btn3:SetHitRectInsets(-2,-100,-2,-2)
	btn3.text:SetText('  NO SPIDERS!')
	btn3.text:SetFontObject("GameFontNormal")
  btn3:SetPoint('TOPLEFT', 40, -140)
  btn3:SetChecked(zonePetMiniMap.noSpiders)
  btn3:SetScript("OnClick",function() 
    local isChecked = btn3:GetChecked()
    zonePetMiniMap.noSpiders = isChecked
    ZonePet_summonForZone()
  end)

  local btn4 = CreateFrame("Button", nil, ZonePet.panel, "UIPanelButtonTemplate")
	btn4:SetSize(160,26)
	btn4:SetText('New Pet')
  btn4:SetPoint('TOPLEFT', 40, -180)
  btn4:SetScript("OnClick",function() 
    ZonePet_summonForZone()
  end)

  local btn7 = CreateFrame("Button", nil, ZonePet.panel, "UIPanelButtonTemplate")
	btn7:SetSize(160,26)
	btn7:SetText('Previous Pet')
  btn7:SetPoint('TOPLEFT', 220, -180)
  btn7:SetScript("OnClick",function() 
    ZonePet_summonPreviousPet()
  end)

  local btn5 = CreateFrame("Button", nil, ZonePet.panel, "UIPanelButtonTemplate")
	btn5:SetSize(160,26)
	btn5:SetText('Dismiss Pet')
  btn5:SetPoint('TOPLEFT', 400, -180)
  btn5:SetScript("OnClick",function() 
    ZonePet_HaveDismissed = true
    ZonePet_dismissCurrentPet()
  end)

  local btn6 = CreateFrame("CheckButton", nil, ZonePet.panel, "UICheckButtonTemplate")
	btn6:SetSize(26,26)
	btn6:SetHitRectInsets(-2,-160,-2,-2)
	btn6.text:SetText('  Lock in current pet')
	btn6.text:SetFontObject("GameFontNormal")
  btn6:SetPoint('TOPLEFT', 40, -220)
  btn6:SetChecked(ZonePet_LockPet)
  btn6:SetScript("OnClick",function() 
    local isChecked = btn6:GetChecked()
    if isChecked then
      ZonePet_lockCurrentPet()
      ZonePet_showTooltip()
    else
      ZonePet_LockPet = false
      ZonePet_summonForZone()
    end
  end)


  local searchTitle = ZonePet.panel:CreateFontString(nil, 'ARTWORK', 'GameFontNormal')
  searchTitle:SetJustifyV('TOP')
  searchTitle:SetJustifyH('LEFT')
  searchTitle:SetPoint('TOPLEFT', 40, -274)
  searchTitle:SetText('Search for:')

  local searchBox = CreateFrame('editbox', nil, ZonePet.panel, 'InputBoxTemplate')
  searchBox:SetPoint('TOPLEFT', 120, -270)
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
  
  local btn9 = CreateFrame("Button", nil, ZonePet.panel, "UIPanelButtonTemplate")
	btn9:SetSize(160,26)
	btn9:SetText('Show Slash Commands')
  btn9:SetPoint('TOPLEFT', 40, -330)
  btn9:SetScript("OnClick",function() 
    ZonePet_displayHelp()
  end)

  local btn8 = CreateFrame("Button", nil, ZonePet.panel, "UIPanelButtonTemplate")
	btn8:SetSize(160,26)
	btn8:SetText('List Duplicates in Chat')
  btn8:SetPoint('TOPLEFT', 220, -330)
  btn8.tooltipTitle = 'List Duplicates'
  btn8.tooltipBody = 'Your duplicate pets will be listed in the chat.'
  btn8:SetScript("OnClick",function() 
    ZonePet_showDuplicates()
  end)
end
