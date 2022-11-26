function ZonePet_shouldSummonSamePet()
  -- existing pet ID already confirmed
  if ZonePet_LockPet == true then
    if ZonePet_userIsFree() == 'yes' then
      C_PetJournal.SummonPetByGUID(ZonePet_LastPetID)
      ZonePet_checkSummon(ZonePet_LastPetID)
      ZonePet_checkSummonedPet(GetZoneText())
    end
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
    ZonePet_checkSummon(ZonePet_LastPetID)
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
    return ZonePet_summonPet(zone)
  end
  return 'no zone'
end

function ZonePet_summonPreviousPet()
  if InCombatLockdown() == true or UnitIsDeadOrGhost("player") then
    return
  end

  if ZonePet_PrevPetID ~= nil then
    ZonePet_LockPet = true
    C_PetJournal.SummonPetByGUID(ZonePet_PrevPetID)
    ZonePet_checkSummon(ZonePet_PrevPetID)
    local zone = GetZoneText()
    ZonePet_checkSummonedPet(zone)
  end
end

function ZonePet_lockCurrentPet()
  ZonePet_LockPet = true
end

function ZonePet_summonPet(zoneName)
  if InCombatLockdown() == true then
    return 'in combat'
  end
  if UnitIsDeadOrGhost("player") then
    return 'dead'
  end

  if ZonePet_Stealthed == true or IsStealthed() then
    -- if ZonePet_isInPvP() then
      ZonePet_dismissCurrentPet()
    -- end
    -- ZonePet_displayMessage("|c0000FF00ZonePet: " .. "|c0000FFFFStealth - no pet summoned.")
    return 'in stealth'
  end

  if ZonePet_userIsFree() ~= 'yes' then
    return ZonePet_userIsBusyReason()
  end

  C_PetJournal.SetAllPetTypesChecked(true)
  C_PetJournal.SetAllPetSourcesChecked(true)
  C_PetJournal.ClearSearchFilter()

  local numPets, numOwned = C_PetJournal.GetNumPets()
  local summonedPetGUID = C_PetJournal.GetSummonedPetGUID()
  local validPets = {}
  local preferredCount = 12
  local allowPet = true
  local validZone = false
  local isSpecial = false
  local specialPets = {}

  for n = 1, numOwned do
    local petID, speciesID, owned, customName, level, favorite, isRevoked,
    speciesName, icon, petType, companionID, tooltip, description,
    isWild, canBattle, isTradeable, isUnique, obtainable = C_PetJournal.GetPetInfoByIndex(n)

    -- NEVER summon Disgusting Oozeling as it has negative effect
    allowPet = true
    if petID == nil or petID == 'BattlePet-0-0000122C75EA' or speciesName == 'Disgusting Oozeling' or speciesID == 114 then
      allowPet = false
    end

    -- faction specific pets
    if allowPet and (speciesName == 'Gillvanas' or speciesName == 'Finduin' or speciesID == 2777 or speciesID == 2778) then
      allowPet = false
    end

    -- ignored names
    if allowPet and speciesName and zonePetMiniMap.ignores then
      for n = 1, #zonePetMiniMap.ignores do
        if zonePetMiniMap.ignores[n] then
          local testName = string.lower(zonePetMiniMap.ignores[n])
          local index = string.find(string.lower(speciesName), testName)
          if index then
            allowPet = false
          end
        end
      end
    end

    validZone = false
    isSpecial = false
    if tooltip then 
      if string.find(tooltip, zoneName) then
        validZone = true
      elseif string.find(tooltip, 'Trading Card Game') then
        validZone = true
        isSpecial = true
      elseif string.find(tooltip, 'Game Shop') then
        validZone = true
        isSpecial = true
      elseif string.find(tooltip, 'Promotion') then
        validZone = true
        isSpecial = true
      end
    end

    if allowPet and owned and tooltip and validZone then
      if zonePetMiniMap.favsOnly == false or favorite == true then
        local isMatch = true
        if zonePetMiniMap.noSpiders then
          if ZonePet_petIsSpider(speciesName) then
            isMatch = false
          end
        end
        if isMatch then
          if isSpecial then
            specialPets[#specialPets + 1] = { name = speciesName, ID = petID }
          else
            validPets[#validPets + 1] = { name = speciesName, ID = petID }
          end
        end
      end
    end
  end
  -- print("|c0000FF00ZonePet: " .. "|c0000FFFFYou own " .. #validPets .. " pets from " .. zoneName)

  -- for n = 1, #validPets do
  --   print(validPets[n].name)
  -- end

  if #specialPets > 0 then
    local specialIndex, specialName, special_id

    specialIndex = math.random(#specialPets)
    specialName = specialPets[specialIndex].name
    special_id = specialPets[specialIndex].ID

    validPets[#validPets + 1] = { name = specialName, ID = special_id }
  end


  if #validPets == 0 then
    -- print('No pets for zone ' .. zoneName)
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
    ZonePet_checkSummon(id)
    ZonePet_checkSummonedPet(zoneName)
  end

  return ''
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
        ZonePet_checkSummon(favPetId)
      end
    )
  else
    -- print('Using built-in random')
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

    if petID and owned then
      if zonePetMiniMap.favsOnly == false or favorite == true then
        local isMatch = true
        if zonePetMiniMap.noSpiders then
          if ZonePet_petIsSpider(speciesName) then
            isMatch = false
          end
        end
        if isMatch then
          petList[#petList + 1] = { name = speciesName, ID = petID }
        end
      end
    end
  end

  -- if #petList == 0 then
  --   print('No random pets')
  --   return -1
  -- end

  if #petList == 0 then
    return {}
  end

  if #petList == 1 then
    summonedPetGUID = ''
    return petList[1].ID
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

    if petID and owned then
      if zonePetMiniMap.favsOnly == false or favorite == true then
        local isMatch = true
        if zonePetMiniMap.noSpiders then
          if ZonePet_petIsSpider(speciesName) then
            isMatch = false
          end
        end
        if isMatch then
          petList[#petList + 1] = { name = speciesName, ID = petID }
        end
      end
    end
  end

  if #petList == 0 then
    return {}
  end

  -- for n = 1, #petList do
  --   print(petList[n].name)
  -- end

  local petIndex
  repeat
    petIndex = math.random(#petList)
    validPets[#validPets + 1] = petList[petIndex]
  until #validPets == count
  return validPets
end

function ZonePet_checkSummonedPet(zoneName)
  if zonePetMiniMap.hideInfo then
    return
  end

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
        ZonePet_showTooltip(ZonePet_Tooltip)
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

  ZonePet_ShowWelcome()

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

function ZonePet_checkSummon(petID)
  C_Timer.After(1,
    function()
      local summonedPetGUID = C_PetJournal.GetSummonedPetGUID()
      if not summonedPetGUID and petID then
        C_PetJournal.SummonPetByGUID(petID)
        ZonePet_checkSummon(petID)
      end
    end
  )
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

function ZonePet_petIsSpider(petName)
  local spiderNames = {'spider', 'tarantula', 'broodling', 'smolderweb', 'mechantula', 'swarmer', 'crypt', 'creepling', 'webspinner', 'venomspitter'}
  local exceptions = {"Yu'la"}

  for n = 1, #exceptions do
    local foundMatch = string.find(string.lower(petName), exceptions[n])
    if foundMatch then
      return false
    end
  end

  for n = 1, #spiderNames do
    local foundMatch = string.find(string.lower(petName), spiderNames[n])
    if foundMatch then
      return true
    end
  end

  return false
end

function ZonePet_isInPvP()
  if UnitIsPVP("player") then
    -- print("UnitIsPVP")
    ZonePet_IsPvP = true
    return true
  end

  local _, instanceType = IsInInstance()
  -- print('Instance type: ' .. instanceType)
  if instanceType == 'pvp' or instanceType == 'arena' then
    ZonePet_IsPvP = true
    return true
  end

  if C_PvP.IsBattleground() or C_PvP.IsActiveBattlefield() or C_PvP.IsInBrawl() or C_PvP.IsWarModeActive() then
    -- if C_PvP.IsBattleground() then
    --   print('in battleground')
    -- end
    -- if C_PvP.IsActiveBattlefield() then
    --   print('in battlefield')
    -- end
    -- if C_PvP.IsInBrawl() then
    --   print('in brawl')
    -- end
    -- if C_PvP.IsWarModeActive() then
    --   print('in war mode')
    -- end

    ZonePet_IsPvP = true
    return true
  end

  ZonePet_IsPvP = false
  return false
end

function ZonePet_isGrouped()
  if IsInGroup() or IsInRaid() then
    -- if IsInGroup() then
    --   print('in group')
    -- end
    -- if IsInRaid() then
    --   print('in raid')
    -- end

    return true
  end

  if UnitInAnyGroup() then
    -- print('in any group')
    return true
  end

  return false
end

function ZonePet_changePvPOption(newSetting)
  zonePetMiniMap.notInPvP = newSetting
  if ZonePet_isInPvP() then
    if newSetting == true then
      ZonePet_dismissCurrentPet()
    else
      ZonePet_summonForZone()
    end
  end
end

function ZonePet_changeGroupOption(newSetting)
  zonePetMiniMap.notInGroup = newSetting
  if ZonePet_isGrouped() then
    if newSetting == true then
      ZonePet_dismissCurrentPet()
    else
      ZonePet_summonForZone()
    end
  end
end

function ZonePet_Tests()
  C_PetJournal.SetAllPetTypesChecked(true)
  C_PetJournal.SetAllPetSourcesChecked(true)
  C_PetJournal.ClearSearchFilter()

  local numPets, numOwned = C_PetJournal.GetNumPets()
  print('numPets: ' .. numPets)
  print('numOwned: ' .. numOwned)

  local petID, speciesID, owned, customName, level, favorite, isRevoked,
  speciesName, icon, petType, companionID, tooltip, description,
  isWild, canBattle, isTradeable, isUnique, obtainable = C_PetJournal.GetPetInfoByIndex(numPets)
  print('Last pet:', speciesName, petID, speciesID)

  petID, speciesID, owned, customName, level, favorite, isRevoked,
  speciesName, icon, petType, companionID, tooltip, description,
  isWild, canBattle, isTradeable, isUnique, obtainable = C_PetJournal.GetPetInfoByIndex(numOwned)
  print('Last owned pet:', speciesName, petID, speciesID)

  local badIDCount = 0

  for n = 1, numPets do
    local petID, speciesID, owned, customName, level, favorite, isRevoked,
    speciesName, icon, petType, companionID, tooltip, description,
    isWild, canBattle, isTradeable, isUnique, obtainable = C_PetJournal.GetPetInfoByIndex(n)

      if speciesName == 'Gillvanas' or speciesName == 'Finduin' or speciesName == 'Disgusting Oozeling' then
        --   print(tooltip)
        print(speciesName, speciesID, petID)
      end
      -- if not petID then
      --   badIDCount = badIDCount + 1
      --   print('no id')
      -- end
  end
  print('Pets with no ID:' .. badIDCount)
end
