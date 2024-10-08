local ZonePet_EventFrame = CreateFrame("Frame")
ZonePet_EventFrame:RegisterEvent("PLAYER_LOGIN")
ZonePet_EventFrame:RegisterEvent("ZONE_CHANGED")
ZonePet_EventFrame:RegisterEvent("ZONE_CHANGED_NEW_AREA")
ZonePet_EventFrame:RegisterEvent("PLAYER_MOUNT_DISPLAY_CHANGED")
ZonePet_EventFrame:RegisterEvent("UPDATE_STEALTH")
ZonePet_EventFrame:RegisterEvent("VARIABLES_LOADED")
ZonePet_EventFrame:RegisterEvent("UNIT_SPELLCAST_CHANNEL_START")
ZonePet_EventFrame:RegisterEvent("UNIT_SPELLCAST_CHANNEL_STOP")
ZonePet_EventFrame:RegisterEvent("PVP_TIMER_UPDATE")
ZonePet_EventFrame:RegisterEvent("WAR_MODE_STATUS_UPDATE")
ZonePet_EventFrame:RegisterEvent("UNIT_FLAGS")

ZonePet_EventFrame:SetScript("OnEvent",
  function(self, event, ...)
    -- print(event)
    if event == "VARIABLES_LOADED" then
      ZonePet:Initialize()
    elseif event == "UPDATE_STEALTH" then
      ZonePet_Stealthed = IsStealthed()
      if ZonePet_isInPvP() == true then
        ZonePet_dismissCurrentPet()
      elseif ZonePet_Stealthed == false then      
        ZonePet_processEvent()
      end
    elseif event == "PLAYER_LOGIN" then
      -- data not ready immediately but force update in 5 seconds
      ZonePet_ShowWelcome()
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
    elseif event == "UNIT_SPELLCAST_CHANNEL_START" then
      ZonePet_IsChannelling = true
    elseif event == "UNIT_SPELLCAST_CHANNEL_STOP" then
      ZonePet_IsChannelling = false
    elseif event == "PVP_TIMER_UPDATE" or event == 'WAR_MODE_STATUS_UPDATE' or event == 'UNIT_FLAGS' then
      if zonePetMiniMap.notInPvP == true then
        local prevPvP = ZonePet_IsPvP
        if ZonePet_isInPvP() == true and prevPvP == false then
          ZonePet_dismissCurrentPet()
        elseif ZonePet_isInPvP() == false and prevPvP == true then
          ZonePet_summonForZone()
        end
      end
    else
      ZonePet_processEvent()
    end  
  end
)

function ZonePet_processEvent()
  local shouldProcess = ZonePet_shouldProcessEvent()
  if shouldProcess == 'no' then
    return
  elseif shouldProcess == 'delay' then
    C_Timer.After(5,
      function()
        ZonePet_processEvent()
      end
    )
    return
  end

  local now = GetTime()           -- time in seconds
  if now - ZonePet_LastEventTrigger < 5 then
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

  if ZonePet_LockPet == true and ZonePet_LastPetID then
    C_PetJournal.SummonPetByGUID(ZonePet_LastPetID)
    ZonePet_checkSummon(ZonePet_LastPetID)
    ZonePet_checkSummonedPet(GetZoneText())
  else
    ZonePet_LockPet = false
    ZonePet_summonForZone()
  end
end 

function ZonePet_processMountEvent()
  local shouldProcess = ZonePet_shouldProcessEvent()
  if shouldProcess == 'no' then
    return
  elseif shouldProcess == 'delay' then
      C_Timer.After(5,
      function()
        ZonePet_processMountEvent()
      end
    )
    return
  end

  local currentPetID = C_PetJournal.GetSummonedPetGUID()
  if currentPetID == nil then
    ZonePet_LastError = 0
    if ZonePet_LastPetID == nil then
      ZonePet_processEvent()
    elseif ZonePet_LockPet == true then
      C_PetJournal.SummonPetByGUID(ZonePet_LastPetID)
      ZonePet_checkSummon(ZonePet_LastPetID)
      ZonePet_checkSummonedPet(GetZoneText())
    else
      ZonePet_shouldSummonSamePet()
    end
  end
end

function ZonePet_ShowWelcome()
  local v = C_AddOns.GetAddOnMetadata("ZonePet", "Version") 
  ZonePet_displayMessage("|c0000FF00Welcome to ZonePet v" .. v .. ": " .. "|c0000FFFFType |c00FFD100/zp |c0000FFFFfor help.")
end

function ZonePet_shouldProcessEvent()
  if ZonePet_HaveDismissed == true then  
  -- or ZonePet_LockPet == true then
    return "no"
  end

  if UnitIsFeignDeath("player") then
    ZonePet_dismissCurrentPet()
    return "no"
  end

  return ZonePet_userIsFree()
end

function ZonePet_userIsFree()
  if zonePetMiniMap.notInPvP == true and ZonePet_isInPvP() == true then
    ZonePet_dismissCurrentPet()
    return 'no'
  end

  if zonePetMiniMap.notInGroup == true and ZonePet_isGrouped() == true then
    ZonePet_dismissCurrentPet()
    return 'no'
  end

  local spellName, _, _, _, _, _, _, _, _, _ = UnitCastingInfo("player")
  local channelName, _, _, _, _, _, _, _ = UnitChannelInfo("player")
  local inCombat = InCombatLockdown()
  local isDead = UnitIsDeadOrGhost("player") or UnitIsFeignDeath("player")
  local isStealthed = IsStealthed() or ZonePet_Stealthed
  local lootWindowCount = GetNumLootItems()

  if inCombat == true or isDead == true or spellName ~= nil or channelName ~= nil or 
    ZonePet_IsChannelling == true or isStealthed == true or lootWindowCount > 0 then
      return "delay"
  end

  if IsFlying() == true or 
    UnitInVehicle("player") == true or
    UnitOnTaxi("player") == true then
      return "no"
  end

  return "yes"
end

function ZonePet_userIsBusyReason()
  if zonePetMiniMap.notInPvP == true and ZonePet_isInPvP() == true then
    return 'in PvP'
  end

  if zonePetMiniMap.notInGroup == true and ZonePet_isGrouped() == true then
    return 'in a group'
  end

  if IsFlying() == true or 
    UnitInVehicle("player") == true or
    UnitOnTaxi("player") == true then
      return "in a vehicle"
  end

  local spellName, _, _, _, _, _, _, _, _, _ = UnitCastingInfo("player")
  local channelName, _, _, _, _, _, _, _ = UnitChannelInfo("player")
  local inCombat = InCombatLockdown()
  local isDead = UnitIsDeadOrGhost("player") or UnitIsFeignDeath("player")
  local isStealthed = IsStealthed() or ZonePet_Stealthed
  local lootWindowCount = GetNumLootItems()


  if inCombat == true then
      return "in combat"
  end
  if isDead == true then
      return "dead"
  end
  if spellName ~= nil or channelName ~= nil or ZonePet_IsChannelling == true then
      return "casting a spell"
  end
  if lootWindowCount > 0 then
    return "looting"
  end

  return ""
end