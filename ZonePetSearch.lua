function ZonePet_searchForPet(command)
  if InCombatLockdown() == true or UnitIsDeadOrGhost("player") then
    return
  end

  local petname = string.lower(command)
  local searchterm = command

  local firstWord = string.sub(command, 0, 7)
  if firstWord == 'search ' then
    searchterm = string.sub(command, 8)
    petname = string.lower(searchterm)
  end

  local totalMatch = nil
  local goodMatch = {}
  local fairMatch = {}

  C_PetJournal.SetAllPetTypesChecked(true)
  C_PetJournal.SetAllPetSourcesChecked(true)
  C_PetJournal.ClearSearchFilter()

  local numPets, numOwned = C_PetJournal.GetNumPets()

  for n = 1, numOwned do
    local petID, speciesID, owned, customName, level, favorite, isRevoked,
    speciesName, icon, petType, companionID, tooltip, description,
    isWild, canBattle, isTradeable, isUnique, obtainable = C_PetJournal.GetPetInfoByIndex(n)

    if string.lower(speciesName) == petname then
      totalMatch = petID
      break
    else
      local strLocation1 = string.find(string.lower(speciesName), petname)
      local strLocation2 = string.find(string.lower(speciesName), ' ' .. petname)
      if strLocation1 == 1 or strLocation2 ~= nil then
        goodMatch[#goodMatch + 1] = { name = speciesName, ID = petID }
      elseif strLocation1 ~= nil then
        fairMatch[#fairMatch + 1] = { name = speciesName, ID = petID }
      end
    end
  end

  local matchingID = nil

  if totalMatch ~= nil then
    matchingID = totalMatch
  elseif #goodMatch > 0 then
    petIndex = math.random(#goodMatch)
    matchingID = goodMatch[petIndex].ID
  elseif #fairMatch > 0 then
    petIndex = math.random(#fairMatch)
    matchingID = fairMatch[petIndex].ID
  end

  if matchingID ~= nil then
    ZonePet_LockPet = true
    C_PetJournal.SummonPetByGUID(matchingID)
    local zone = GetZoneText()
    ZonePet_checkSummonedPet(zone)
  else
    ZonePet_displayMessage("|c0000FF00ZonePet: " .. "|c0000FFFFCan't find a pet with a name like |c00FFD100" .. searchterm .. ".")
  end
end
