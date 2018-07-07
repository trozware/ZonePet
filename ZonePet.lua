local ZonePet_EventFrame = CreateFrame("Frame")
ZonePet_EventFrame:RegisterEvent("PLAYER_LOGIN")
ZonePet_EventFrame:RegisterEvent("ZONE_CHANGED")
ZonePet_EventFrame:RegisterEvent("ZONE_CHANGED_NEW_AREA")
ZonePet_EventFrame:RegisterEvent("PLAYER_MOUNT_DISPLAY_CHANGED")
-- ZonePet_EventFrame:RegisterEvent("UPDATE_SHAPESHIFT_FORM")

local ZonePet_LastPetChange = 0
local ZonePet_LastEventTrigger = 0
local ZonePet_LastError = 0

-- Summon flying pet during flight?

-- "|c000000FF" = blue
-- "|c0000FF00" = green
-- "|c00FF0000" = red
-- "|c0000FFFF" = cyan
-- leading FF - not sure what that does
-- "|cFFFFFF00"  = yellow


ZonePet_EventFrame:SetScript("OnEvent",
    function(self, event, ...)
        if event == "PLAYER_LOGIN" then
            -- data not ready immediately but force update
            C_Timer.After(1,
                function()
                    ZonePet_LastPetChange = 0
                    processEvent()
                end
        )
        elseif event == "PLAYER_MOUNT_DISPLAY_CHANGED" or event == "UPDATE_SHAPESHIFT_FORM" then
             C_Timer.After(3,
                function()
                    processMountEvent()
                end
            )
        else
            processEvent()
        end
    end
)

function processEvent()
    spellName, _, _, _, _, _, _, _, _, _ = UnitCastingInfo("player")
    channelName, _, _, _, _, _, _, _ = UnitChannelInfo("player")

     if InCombatLockdown() == true or UnitIsDeadOrGhost("player") == true or
        spellName ~= nil or channelName ~= nil then
        C_Timer.After(5,
            function()
                processEvent()
            end
        )
        return
    end

    now = time()           -- time in seconds
    if now - ZonePet_LastEventTrigger < 3 then
        return
    end
    ZonePet_LastEventTrigger = now

    if IsFlying() == true then -- or IsMounted() == true then
        return
    end

    if C_PetJournal.GetSummonedPetGUID() ~= nil then
        if now - ZonePet_LastPetChange < 300 then
            return
        end
    elseif now - ZonePet_LastError < 60 then
        return
    end

    local zone = GetZoneText()
    if zone ~= nil and zone ~= "" then
        summonPet(zone)
    end
end

function processMountEvent()
    if C_PetJournal.GetSummonedPetGUID() == nil then
        ZonePet_LastError = 0
        processEvent()
    end
end

function summonPet(zoneName)
    C_PetJournal.SetAllPetSourcesChecked(true)
    C_PetJournal.SetAllPetTypesChecked(true)
    C_PetJournal.ClearSearchFilter()

    numPets, numOwned = C_PetJournal.GetNumPets()
    summonedPetGUID = C_PetJournal.GetSummonedPetGUID()
    validPets = {}

    for n = 1, numOwned do
        petID, speciesID, owned, customName, level, favorite, isRevoked,
        speciesName, icon, petType, companionID, tooltip, description,
        isWild, canBattle, isTradeable, isUnique, obtainable = C_PetJournal.GetPetInfoByIndex(n)

        if owned and tooltip and string.find(tooltip, zoneName) then
            validPets[#validPets + 1] = { name = speciesName, ID = petID }
        end
    end
    -- print("|c0000FF00ZonePet: " .. "|c0000FFFFYou own " .. #validPets .. " pets from " .. zoneName)

    if #validPets == 0 then
        summonRandomPet(zoneName, 0)
     else
        if #validPets < 4 then
            goRandom = math.random(3)
            if goRandom > 1 then
                summonRandomPet(zoneName, #validPets)
                return
            end
            if #validPets < 2 then
                -- otherwise will never pass the next test
                summonedPetGUID = nil
            end
        end

        repeat
            petIndex = math.random(#validPets)
            name = validPets[petIndex].name
            id = validPets[petIndex].ID
        until id ~= summonedPetGUID

        ZonePet_LastPetChange = now
        -- .. ". You own " .. #validPets .. " pets from this zone.")

        C_PetJournal.SummonPetByGUID(id)
        checkSummonedPet(zoneName)
    end
end

function summonRandomPet(zoneName, count)
    ZonePet_LastPetChange = now
    -- message = count == 1 and ". You own 1 pet from this zone." or ". You own " .. count .. " pets from this zone."
    -- print("|c0000FF00ZonePet: " .. "|c0000FFFFSummoning a random pet for " .. zoneName .. ".")
    C_PetJournal.SummonRandomPet()
    checkSummonedPet("")
 end

function checkSummonedPet(zoneName)
    C_Timer.After(1,
        function()
            summonedPetGUID = C_PetJournal.GetSummonedPetGUID()
            if summonedPetGUID then
                speciesID, customName, level, xp, maxXp, displayID, isFavorite,
                name, icon, petType, creatureID, sourceText, description,
                isWild, canBattle, tradable, unique, obtainable = C_PetJournal.GetPetInfoByPetID(summonedPetGUID)
                if zoneName == "" then
                    print("|c0000FF00ZonePet: " .. "|c0000FFFFSummoned random pet: " .. name .. ".")
                else
                    print("|c0000FF00ZonePet: " .. "|c0000FFFFSummoned " .. name .. " from " .. zoneName.. ".")
                end
                ZonePet_LastError = 0
            else
                ZonePet_LastError = time()
            end
        end
    )
end
