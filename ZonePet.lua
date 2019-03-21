local ZonePet_EventFrame = CreateFrame("Frame")
ZonePet_EventFrame:RegisterEvent("PLAYER_LOGIN")
ZonePet_EventFrame:RegisterEvent("ZONE_CHANGED")
ZonePet_EventFrame:RegisterEvent("ZONE_CHANGED_NEW_AREA")
ZonePet_EventFrame:RegisterEvent("PLAYER_MOUNT_DISPLAY_CHANGED")
ZonePet_EventFrame:RegisterEvent("UPDATE_STEALTH")
ZonePet_EventFrame:RegisterEvent("VARIABLES_LOADED")

local ZonePet = {} 
local ZonePet_LastPetChange = 0
local ZonePet_LastEventTrigger = 0
local ZonePet_LastError = 0

local ZonePet_Stealthed = IsStealthed()
local ZonePet_PreviousMessage = ""
local ZonePet_HaveDismissed = false
local ZonePet_TooltipVisible = false


ZonePet_EventFrame:SetScript("OnEvent",
  function(self, event, ...)
    -- print(event)
    if event == "VARIABLES_LOADED" then
      ZonePet:Initialize()
      ZonePet:MinimapUpdatePosition()
    elseif event == "UPDATE_STEALTH" then
      ZonePet_Stealthed = IsStealthed()
      if ZonePet_Stealthed == true and UnitIsPVP("player") == true then
        ZonePet_dismissCurrentPet()
      end
    elseif event == "PLAYER_LOGIN" then
      -- data not ready immediately but force update in 5 seconds
      C_Timer.After(5,
        function()
          ZonePet_LastPetChange = 0
          ZonePet_processEvent()
        end
      )
    elseif event == "PLAYER_MOUNT_DISPLAY_CHANGED" or event == "UPDATE_SHAPESHIFT_FORM" then
      C_Timer.After(3,
          function()
          ZonePet_processMountEvent()
          end
      )
    else
      ZonePet_processEvent()
    end  
  end
)

function ZonePet_processEvent()
  if ZonePet_HaveDismissed == true then
    return
  end

  spellName, _, _, _, _, _, _, _, _, _ = UnitCastingInfo("player")
  channelName, _, _, _, _, _, _, _ = UnitChannelInfo("player")
  inCombat = InCombatLockdown()
  isDead = UnitIsDeadOrGhost("player") 
  if inCombat == true or isDead == true or spellName ~= nil or channelName ~= nil then
    C_Timer.After(5,
      function()
        ZonePet_processEvent()
      end
    )
    return
  end

  if IsFlying() == true or 
    UnitInVehicle("player") == true or
    UnitOnTaxi("player") == true then
      return
  end

  now = GetTime()           -- time in seconds
  if now - ZonePet_LastEventTrigger < 3 then
    return
  end
  ZonePet_LastEventTrigger = now

  if C_PetJournal.GetSummonedPetGUID() ~= nil then
    if now - ZonePet_LastPetChange < 300 then
      return
    end
  elseif now - ZonePet_LastError < 60 then
    return
  end

  ZonePet_summonForZone()
end 

function ZonePet_processMountEvent()
  if ZonePet_HaveDismissed == true then
    return
  end

  currentPetID = C_PetJournal.GetSummonedPetGUID()
  if currentPetID == nil then
    ZonePet_LastError = 0
    ZonePet_processEvent()
  else
    -- petFromZone = ZonePet_petIsFromThisZone(currentPetID)
    -- if petFromZone == false then
    --   -- if landed from flight in a different zone and 
    --   -- this pet is not from the new zone, force a change
    --   ZonePet_LastPetChange = 0
    --   ZonePet_LastEventTrigger = 0
    --   ZonePet_LastError = 0
    --   ZonePet_processEvent()
    -- end
  end
end

function ZonePet_petIsFromThisZone(currentPetID)
  speciesID, customName, level, xp, maxXp, displayID, isFavorite,
  name, icon, petType, creatureID, sourceText, description,
  isWild, canBattle, tradable, unique, obtainable = C_PetJournal.GetPetInfoByPetID(currentPetID)

  zoneName = GetZoneText()
  if zoneName == nil and zoneName == "" then
    return false
  end

  if sourceText and string.find(sourceText, zoneName) then
    return true
  end
  return false
end

function ZonePet_summonForZone()
  local zone = GetZoneText()
  if zone ~= nil and zone ~= "" then
    ZonePet_summonPet(zone)
  end
end

function ZonePet_summonPet(zoneName)
  if ZonePet_Stealthed == true then
    if UnitIsPVP("player") == true then
      ZonePet_dismissCurrentPet()
    end
    ZonePet_displayMessage("|c0000FF00ZonePet: " .. "|c0000FFFFStealth - no pet summoned.")
    return
  end

  C_PetJournal.SetAllPetTypesChecked(true)
  C_PetJournal.SetAllPetSourcesChecked(true)
  C_PetJournal.ClearSearchFilter()

  numPets, numOwned = C_PetJournal.GetNumPets()
  summonedPetGUID = C_PetJournal.GetSummonedPetGUID()
  validPets = {}

  for n = 1, numOwned do
    petID, speciesID, owned, customName, level, favorite, isRevoked,
    speciesName, icon, petType, companionID, tooltip, description,
    isWild, canBattle, isTradeable, isUnique, obtainable = C_PetJournal.GetPetInfoByIndex(n)

    if owned and tooltip and string.find(tooltip, zoneName) then
      if zonePetMiniMap.favsOnly == false or favorite == true then
        validPets[#validPets + 1] = { name = speciesName, ID = petID }
      end
    end
  end
  -- print("|c0000FF00ZonePet: " .. "|c0000FFFFYou own " .. #validPets .. " pets from " .. zoneName)

  if #validPets == 0 then
    ZonePet_summonRandomPet(zoneName, {})
  else
    if #validPets < 12 then
      preferredCount = 12
      if #validPets < 6 then
        preferredCount = #validPets * 2
      end
      if preferredCount < 6 then
        preferredCount = 6
      end
      -- list enough random pets to bring it up to a decent number, then choose
      validPets = ZonePet_addRandomPets(validPets, zonePetMiniMap.favsOnly, preferredCount)
    end
  
    repeat
      petIndex = math.random(#validPets)
      name = validPets[petIndex].name
      id = validPets[petIndex].ID
    until id ~= summonedPetGUID

    ZonePet_HaveDismissed = false
    ZonePet_LastPetChange = GetTime()
    -- .. ". You own " .. #validPets .. " pets from this zone.")

    C_PetJournal.SummonPetByGUID(id)
    ZonePet_checkSummonedPet(zoneName)
  end
end

function ZonePet_summonRandomPet(zoneName, startingPets)
  ZonePet_LastPetChange = GetTime()

  favPetId = ZonePet_pickRandomPet(zonePetMiniMap.favsOnly, startingPets)
  if favPetId ~= '-1' then
    C_PetJournal.SummonPetByGUID(id)
  else
    C_PetJournal.SummonRandomPet(true)
  end

  ZonePet_checkSummonedPet(zoneName)
end

function ZonePet_pickRandomPet(favsOnly, startingPets)
  numPets, numOwned = C_PetJournal.GetNumPets()
  petList = startingPets

  for n = 1, numOwned do
    petID, speciesID, owned, customName, level, favorite, isRevoked,
    speciesName, icon, petType, companionID, tooltip, description,
    isWild, canBattle, isTradeable, isUnique, obtainable = C_PetJournal.GetPetInfoByIndex(n)

    if owned then
      if favsOnly == false or favorite == true then
        petList[#petList + 1] = { name = speciesName, ID = petID }
      end
    end
  end

  if #petList == 0 then
    return -1
  end

  summonedPetGUID = C_PetJournal.GetSummonedPetGUID()
  if summonedPetGUID == nil then
    petIndex = math.random(#petList)
    name = petList[petIndex].name
    id = petList[petIndex].ID
    return id
  end

  repeat
    petIndex = math.random(#petList)
    name = petList[petIndex].name
    id = petList[petIndex].ID
  until id ~= summonedPetGUID

  return id
end

function ZonePet_addRandomPets(validPets, favsOnly, count)
  numPets, numOwned = C_PetJournal.GetNumPets()
  petList = {}

  for n = 1, numOwned do
    petID, speciesID, owned, customName, level, favorite, isRevoked,
    speciesName, icon, petType, companionID, tooltip, description,
    isWild, canBattle, isTradeable, isUnique, obtainable = C_PetJournal.GetPetInfoByIndex(n)

    if owned then
      if favsOnly == false or favorite == true then
        petList[#petList + 1] = { name = speciesName, ID = petID }
      end
    end
  end

  if #petList == 0 then
    return {}
  end

  repeat
    petIndex = math.random(#petList)
    validPets[#validPets + 1] = petList[petIndex]
  until #validPets == count
  return validPets
end

function ZonePet_checkSummonedPet(zoneName)
  C_Timer.After(2,
    function()
      summonedPetGUID = C_PetJournal.GetSummonedPetGUID()
      if summonedPetGUID then
        speciesID, customName, level, xp, maxXp, displayID, isFavorite,
        name, icon, petType, creatureID, sourceText, description,
        isWild, canBattle, tradable, unique, obtainable = C_PetJournal.GetPetInfoByPetID(summonedPetGUID)

        -- cover summoning random pet from this zone
        zoneMatches = false
        if sourceText and string.find(sourceText, zoneName) then
          zoneMatches = true
        end

        favText = ''
        if zonePetMiniMap.favsOnly then
          favText = 'favorite '
        end
        if zoneMatches == false then
            ZonePet_displayMessage("|c0000FF00ZonePet: " .. "|c0000FFFFSummoned random " .. favText .. "pet: " .. "|c00FFD100" .. name .. ".")
        else
            ZonePet_displayMessage("|c0000FF00ZonePet: " .. "|c0000FFFFSummoned " .. favText .. "|c00FFD100" .. name .. "|c0000FFFF from " .. zoneName.. ".")
        end
        if description and description ~= "" then
          ZonePet_displayMessage("|c0000FFFF" .. description)
        end
        ZonePet_LastError = 0
      else
        ZonePet_LastError = time()
      end

      if ZonePet_TooltipVisible == true then
        ZonePet_showTooltip()
      end
    end
  )
end

function ZonePet_dataForCurrentPet()
  summonedPetGUID = C_PetJournal.GetSummonedPetGUID()
  if summonedPetGUID then
    speciesID, customName, level, xp, maxXp, displayID, isFavorite,
      name, icon, petType, creatureID, sourceText, description,
      sWild, canBattle, tradable, unique, obtainable = C_PetJournal.GetPetInfoByPetID(summonedPetGUID)
    return { name = name, desc = description, icon = icon }
  end
  return nil
end

function ZonePet_dismissCurrentPet()
  summonedPetGUID = C_PetJournal.GetSummonedPetGUID()
  if summonedPetGUID then
    C_PetJournal.SummonPetByGUID(summonedPetGUID)
    ZonePet_displayMessage("|c0000FF00ZonePet: " .. "|c0000FFFFDismissing pet.")
  end
end

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
      if IsShiftKeyDown() then
        zonePetMiniMap.Button:Hide()
        zonePetMiniMap.Hidden=true
        ZonepetCommandHandler('help')
      else
        ZonePet_HaveDismissed = true
        ZonePet_dismissCurrentPet()
        ZonePet_checkSummonedPet('')
      end
    else
      if IsShiftKeyDown() then
        zonePetMiniMap.favsOnly = not zonePetMiniMap.favsOnly
        ZonePet_showTooltip()
      end
      ZonePet_summonForZone()
    end
  end)

	b:SetScript("OnDragStart", function(self,event)
    if(zonePetMiniMap.dragable) then
      self.dragme = true
      self:LockHighlight()
    end
	end)

	b:SetScript("OnDragStop", function(self,event)
    self.dragme = false
    self:UnlockHighlight()
  end)

	b:SetScript("OnUpdate", function(self,event)
    if self.dragme == true then
      ZonePet:MinimapBeingDragged()
    end
  end)

  b:SetScript("OnEnter", function(self,event)
    GameTooltip:SetOwner(self, "ANCHOR_NONE")
    GameTooltip:SetPoint("TOPRIGHT", self, "BOTTOM")
    GameTooltip:SetScript("OnHide", function(self, event)
      -- this should make sure it never appears in the wrong place
      ZonePet_TooltipVisible = false
    end)
    ZonePet_showTooltip()
  end)

  b:SetScript("OnLeave", function(self,event)
    GameTooltip:Hide()
  end)

  b:RegisterForDrag("LeftButton")
  b:RegisterForClicks("LeftButtonUp", "RightButtonUp")
	b.dragme = false
end

function ZonePet_showTooltip()
  GameTooltip:SetText("ZonePet", 1, 1, 1)
  
  petData = ZonePet_dataForCurrentPet()
  if petData then
    GameTooltip:AddLine('\n' .. petData.name, 0, 1, 0)
    GameTooltip:AddLine(petData.desc, 0, 1, 1, true)
  elseif ZonePet_HaveDismissed then
    msg = "You have dismissed your pet. No new pet will be summoned until you left-click here or use '/zp new'."
    GameTooltip:AddLine('\n' .. msg , 0, 1, 1, true)
  end
  
  GameTooltip:AddLine("\nLeft-click to summon a new pet, from this zone if possible.")
  GameTooltip:AddLine("Right-click to dismiss your current pet.")

  if zonePetMiniMap.favsOnly then
    GameTooltip:AddLine("\nSelecting from favorite pets only.")
    GameTooltip:AddLine("Shift + Left-click to select from all pets.")
  else
    GameTooltip:AddLine("\nSelecting from all pets.")
    GameTooltip:AddLine("Shift + Left-click to select from favorite pets only.")
  end

  GameTooltip:AddLine("\nShift + Right-click to hide this button.")
  GameTooltip:AddLine("Type '/zp mini' in Chat to show this button again.")

  GameTooltip:Show()
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
  if msg == "mini" or msg == "on" then 
    zonePetMiniMap.Button:Show()
    zonePetMiniMap.Hidden=false
  elseif msg == "dismiss" then
    ZonePet_HaveDismissed = true
    ZonePet_dismissCurrentPet()
    ZonePet_checkSummonedPet('')
  elseif msg == "change" or msg == "new" then
    ZonePet_summonForZone()
  elseif msg == "all" then
    zonePetMiniMap.favsOnly = false
    ZonePet_summonForZone()
  elseif msg == "fav" or msg == "favs" then
    zonePetMiniMap.favsOnly = true
    ZonePet_summonForZone()
  else
    msg = "|c0000FF00ZonePet: " .. "|c0000FFFFType |cFFFFFFFF/zp mini|c0000FFFF to show the ZonePet icon in the MiniMap."
    ChatFrame1:AddMessage(msg)
    msg = "|c0000FF00ZonePet: " .. "|c0000FFFFType |cFFFFFFFF/zp new|c0000FFFF to summon a different pet."
    ChatFrame1:AddMessage(msg)
    msg = "|c0000FF00ZonePet: " .. "|c0000FFFFType |cFFFFFFFF/zp dismiss|c0000FFFF to dismiss your current pet."
    ChatFrame1:AddMessage(msg)
    msg = "|c0000FF00ZonePet: " .. "|c0000FFFFType |cFFFFFFFF/zp all|c0000FFFF or |cFFFFFFFF/zp fav|c0000FFFF to switch between all pets and favorite pets."
    ChatFrame1:AddMessage(msg)
   end
end
