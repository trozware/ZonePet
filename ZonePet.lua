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
      favsOnly = false
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
end

function ZonePet_showTooltip(self)
  petData = ZonePet_dataForCurrentPet()
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
    msg = "You have dismissed your pet. No new pet will be summoned until you left-click here or use '/zp new'."
    ZonePetTooltip:AddLine(msg , 0, 1, 1, true)
  end
  
  ZonePetTooltip:AddLine("\nLeft-click to summon a new pet, from this zone if possible.")

  if ZonePet_PrevPetID ~= nil then
    ZonePetTooltip:AddLine("Shift + Left-click to go back to the previous pet.")
  end


  if ZonePet_LockPet == true then
    ZonePetTooltip:AddLine("You have locked in your current pet.")
    ZonePetTooltip:AddLine("Left-click to summon a different pet.")
  else
    ZonePetTooltip:AddLine("Alt + Left-click to lock in this pet.")
  end

  ZonePetTooltip:AddLine(" ")
  ZonePetTooltip:AddLine("Right-click to dismiss your current pet.")

  ZonePetTooltip:AddLine(" ")
  ZonePetTooltip:AddLine("Alt + Right-click to hide this button.")
  ZonePetTooltip:AddLine("Type '/zp' in Chat to see all the possible commands.")

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
  else
    ZonePet_displayHelp()
  end
end

function ZonePet_displayHelp()
  msg = "|c0000FF00ZonePet: " .. "|c0000FFFFType |cFFFFFFFF/zp new|c0000FFFF to summon a different pet."
  ChatFrame1:AddMessage(msg)
  msg = "|c0000FF00ZonePet: " .. "|c0000FFFFType |cFFFFFFFF/zp about|c0000FFFF to show some info about your pet."
  ChatFrame1:AddMessage(msg)
  msg = "|c0000FF00ZonePet: " .. "|c0000FFFFType |cFFFFFFFF/zp back|c0000FFFF to summon your previous pet."
  ChatFrame1:AddMessage(msg)
  msg = "|c0000FF00ZonePet: " .. "|c0000FFFFType |cFFFFFFFF/zp lock|c0000FFFF to lock in your current pet."
  ChatFrame1:AddMessage(msg)
  msg = "|c0000FF00ZonePet: " .. "|c0000FFFFType |cFFFFFFFF/zp dismiss|c0000FFFF to dismiss your current pet."
  ChatFrame1:AddMessage(msg)
  msg = "|c0000FF00ZonePet: " .. "|c0000FFFFType |cFFFFFFFF/zp all|c0000FFFF or |cFFFFFFFF/zp fav|c0000FFFF to switch between all pets and favorite pets."
  ChatFrame1:AddMessage(msg)
  msg = "|c0000FF00ZonePet: " .. "|c0000FFFFType |cFFFFFFFF/zp dupe|c0000FFFF to list your duplicate pets."
  ChatFrame1:AddMessage(msg)
  msg = "|c0000FF00ZonePet: " .. "|c0000FFFFType |cFFFFFFFF/zp mini|c0000FFFF to show or hide the ZonePet icon in the MiniMap."
  ChatFrame1:AddMessage(msg)
end