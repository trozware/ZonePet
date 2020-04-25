function ZonePet_shouldSummonSamePet()
  -- existing pet ID already confirmed
  if ZonePet_LockPet == true and ZonePet_userIsFree() == 'yes' then
    C_PetJournal.SummonPetByGUID(ZonePet_LastPetID)
    ZonePet_checkSummonedPet(GetZoneText())
    return
  end

  -- was it summoned less than 5 minutes ago
  local now = GetTime()           -- time in seconds
  if now - ZonePet_LastPetChange >= 300 then
    ZonePet_processEvent()
    return
  end

  -- is it from this zone
  local isFromZone = ZonePet_petIsFromThisZone(ZonePet_LastPetID)
  if isFromZone == false then
    ZonePet_processEvent()
    return
  end 

  if ZonePet_userIsFree() == 'yes' then
    C_PetJournal.SummonPetByGUID(ZonePet_LastPetID)
  end
end

function ZonePet_petIsFromThisZone(currentPetID)
  local speciesID, customName, level, xp, maxXp, displayID, isFavorite,
  name, icon, petType, creatureID, sourceText, description,
  isWild, canBattle, tradable, unique, obtainable = C_PetJournal.GetPetInfoByPetID(currentPetID)

  local zoneName = GetZoneText()
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

function ZonePet_summonPreviousPet()
  if InCombatLockdown() == true or UnitIsDeadOrGhost("player") then
    return
  end

  if ZonePet_PrevPetID ~= nil then
    ZonePet_LockPet = true
    C_PetJournal.SummonPetByGUID(ZonePet_PrevPetID)
    local zone = GetZoneText()
    ZonePet_checkSummonedPet(zone)
  end
end

function ZonePet_lockCurrentPet()
  ZonePet_LockPet = true
end

function ZonePet_summonPet(zoneName)
  if InCombatLockdown() == true or UnitIsDeadOrGhost("player") then
    return
  end

  if ZonePet_Stealthed == true then
    if UnitIsPVP("player") == true then
      ZonePet_dismissCurrentPet()
    end
    ZonePet_displayMessage("|c0000FF00ZonePet: " .. "|c0000FFFFStealth - no pet summoned.")
    return
  end

  if ZonePet_userIsFree() ~= 'yes' then
    return
  end

  C_PetJournal.SetAllPetTypesChecked(true)
  C_PetJournal.SetAllPetSourcesChecked(true)
  C_PetJournal.ClearSearchFilter()

  local numPets, numOwned = C_PetJournal.GetNumPets()
  local summonedPetGUID = C_PetJournal.GetSummonedPetGUID()
  local validPets = {}
  local preferredCount = 12

  for n = 1, numOwned do
    local petID, speciesID, owned, customName, level, favorite, isRevoked,
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
  
    local petIndex, name, id
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

  if ZonePet_userIsFree() ~= 'yes' then
    return
  end

  local favPetId = ZonePet_pickRandomPet(zonePetMiniMap.favsOnly, startingPets)
  if favPetId ~= '-1' then
    pcall(
      function()
        C_PetJournal.SummonPetByGUID(favPetId)
      end
    )
  else
    C_PetJournal.SummonRandomPet(true)
  end

  ZonePet_checkSummonedPet(zoneName)
end

function ZonePet_pickRandomPet(favsOnly, startingPets)
  if InCombatLockdown() == true or UnitIsDeadOrGhost("player") then
    return
  end

  local numPets, numOwned = C_PetJournal.GetNumPets()
  local petList = startingPets

  for n = 1, numOwned do
    local petID, speciesID, owned, customName, level, favorite, isRevoked,
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

  local summonedPetGUID = C_PetJournal.GetSummonedPetGUID()
  local petIndex, name, id
  repeat
    petIndex = math.random(#petList)
    name = petList[petIndex].name
    id = petList[petIndex].ID
  until id ~= summonedPetGUID

  return id
end

function ZonePet_addRandomPets(validPets, favsOnly, count)
  local numPets, numOwned = C_PetJournal.GetNumPets()
  local petList = {}

  for n = 1, numOwned do
    local petID, speciesID, owned, customName, level, favorite, isRevoked,
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

  local petIndex
  repeat
    petIndex = math.random(#petList)
    validPets[#validPets + 1] = petList[petIndex]
  until #validPets == count
  return validPets
end

function ZonePet_checkSummonedPet(zoneName)
  C_Timer.After(2,
    function()
      if ZonePet_userIsFree() ~= 'yes' then
        return
      end

      local summonedPetGUID = C_PetJournal.GetSummonedPetGUID()
      ZonePet_PrevPetID = ZonePet_LastPetID
      ZonePet_LastPetID = summonedPetGUID

      if summonedPetGUID then
        local speciesID, customName, level, xp, maxXp, displayID, isFavorite,
        name, icon, petType, creatureID, sourceText, description,
        isWild, canBattle, tradable, unique, obtainable = C_PetJournal.GetPetInfoByPetID(summonedPetGUID)

        -- cover summoning random pet from this zone
        local zoneMatches = false
        if sourceText and string.find(sourceText, zoneName) then
          zoneMatches = true
        end

        local favText = ''
        if zonePetMiniMap.favsOnly then
          favText = 'favorite '
        end
        if zoneMatches == false or zoneName == '' then
            ZonePet_displayMessage("|c0000FF00ZonePet: " .. "|c0000FFFFSummoned random " .. favText .. "pet: " .. "|c00FFD100" .. name .. ".")
        else
            ZonePet_displayMessage("|c0000FF00ZonePet: " .. "|c0000FFFFSummoned " .. favText .. "|c00FFD100" .. name .. "|c0000FFFF from " .. zoneName .. ".")
        end
        if description and description ~= "" then
          ZonePet_displayMessage("|c0000FFFF" .. description)
        end
        local interaction = ZonePet_interaction(name)
        if interaction and interaction ~= "" then
          ZonePet_displayMessage("|c0000FFFFTarget |c0000FF00" .. name .. " |c0000FFFFand type |cFFFFFFFF" .. interaction .. " to interact.")
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
  if InCombatLockdown() == true or UnitIsDeadOrGhost("player") then
    return
  end

  local summonedPetGUID = C_PetJournal.GetSummonedPetGUID()
  if summonedPetGUID then
    local speciesID, customName, level, xp, maxXp, displayID, isFavorite,
      name, icon, petType, creatureID, sourceText, description,
      sWild, canBattle, tradable, unique, obtainable = C_PetJournal.GetPetInfoByPetID(summonedPetGUID)
    return { name = name, desc = description, icon = icon }
  end
  return nil
end

function ZonePet_displayInfoForCurrentPet()
  if InCombatLockdown() == true or UnitIsDeadOrGhost("player") then
    return
  end

  local summonedPetGUID = C_PetJournal.GetSummonedPetGUID()
  if summonedPetGUID then
    ZonePet_chatDescription(summonedPetGUID)
  else
    msg = "|c0000FF00ZonePet: " .. "|c0000FFFFYou have no pet active right now."
    ZonePet_displayMessage(msg)
  end
end

function ZonePet_chatDescription(summonedPetGUID)
  local speciesID, customName, level, xp, maxXp, displayID, isFavorite,
  name, icon, petType, creatureID, sourceText, description,
  isWild, canBattle, tradable, unique, obtainable = C_PetJournal.GetPetInfoByPetID(summonedPetGUID)

  ZonePet_displayMessage("|c0000FF00ZonePet: " .. name .. ".")
  if description and description ~= "" then
    ZonePet_displayMessage("|c0000FFFF" .. description)
  end
  
  local interaction = ZonePet_interaction(name)
  if interaction and interaction ~= "" then
    ZonePet_displayMessage("|c0000FFFFYou can interact with |c0000FF00" .. name .. " |c0000FFFFby targetting it and typing |cFFFFFFFF" .. interaction .. ".")
  end
end

function ZonePet_dismissCurrentPet()
  if InCombatLockdown() == true or UnitIsDeadOrGhost("player") then
    return
  end

  local summonedPetGUID = C_PetJournal.GetSummonedPetGUID()
  if summonedPetGUID then
    C_PetJournal.SummonPetByGUID(summonedPetGUID)
    ZonePet_displayMessage("|c0000FF00ZonePet: " .. "|c0000FFFFDismissing pet.")
    ZonePet_checkSummonedPet('')
  end
end

function ZonePet_showDuplicates()
  if InCombatLockdown() == true or UnitIsDeadOrGhost("player") then
    return
  end

  C_PetJournal.SetAllPetTypesChecked(true)
  C_PetJournal.SetAllPetSourcesChecked(true)
  C_PetJournal.ClearSearchFilter()

  local numPets, numOwned = C_PetJournal.GetNumPets()
  local summonedPetGUID = C_PetJournal.GetSummonedPetGUID()
  local allPets = {}
  local dupePets = {}

  for n = 1, numOwned do
    local petID, speciesID, owned, customName, level, favorite, isRevoked,
    speciesName, icon, petType, companionID, tooltip, description,
    isWild, canBattle, isTradeable, isUnique, obtainable = C_PetJournal.GetPetInfoByIndex(n)

    if allPets[speciesName] ~= nil then
      dupePets[#dupePets + 1] = speciesName
    end
    allPets[speciesName] = petID
  end
  
  local msg
  if #dupePets == 0 then
    msg = "|c0000FF00ZonePet: " .. "|c0000FFFFAll your pets are unique."
    ChatFrame1:AddMessage(msg)
  else
    msg = "|c0000FF00ZonePet: " .. "|c0000FFFFYou have " .. #dupePets .. " duplicate pets:"
    ChatFrame1:AddMessage(msg)
    for n = 1, #dupePets do
      ChatFrame1:AddMessage("    |c00FFD100" .. dupePets[n])
    end
  end
end
