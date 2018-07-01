local ZonePet_EventFrame = CreateFrame("Frame")
ZonePet_EventFrame:RegisterEvent("PLAYER_LOGIN")
ZonePet_EventFrame:RegisterEvent("ZONE_CHANGED")
ZonePet_EventFrame:RegisterEvent("ZONE_CHANGED_NEW_AREA")
ZonePet_EventFrame:RegisterEvent("PLAYER_MOUNT_DISPLAY_CHANGED")

ZonePet_LastPetChange = 0

-- "|c000000FF" = blue
-- "|c0000FF00" = green
-- "|c00FF0000" = red
-- "|c0000FFFF" = cyan
-- leading FF - not sure what that does
-- "|cFFFFFF00"  = yellow


ZonePet_EventFrame:SetScript("OnEvent",
    function(self, event, ...)
        if event == "PLAYER_LOGIN" or event == "ZONE_CHANGED_NEW_AREA" then
            ZonePet_LastPetChange = 0

            -- data not ready immediately but force update
            C_Timer.After(3, 
                function()
                    processEvent()
                end
        )
        elseif event == "PLAYER_MOUNT_DISPLAY_CHANGED" then
            C_Timer.After(1, 
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
    now = time()             -- time in seconds
    if now - ZonePet_LastPetChange < 300 then
        return
    end

    local zone = GetZoneText()
    if zone ~= nil and zone ~= "" then
        summonRandomPet(zone)
    end
end

function processMountEvent()
    if IsFlying() == true then
        ZonePet_LastPetChange = 0
        return
    end

    if IsMounted() == false and C_PetJournal.GetSummonedPetGUID() == nil then
        ZonePet_LastPetChange = 0
        processEvent()
    end
end

function summonRandomPet(zoneName)
    numPets, numOwned = C_PetJournal.GetNumPets()
    validPets = {}
    summonedPetGUID = C_PetJournal.GetSummonedPetGUID()

    for n = 1, numOwned do
        petID, speciesID, owned, customName, level, favorite, isRevoked, 
        speciesName, icon, petType, companionID, tooltip, description, 
        isWild, canBattle, isTradeable, isUnique, obtainable = C_PetJournal.GetPetInfoByIndex(n)

        if owned and string.find(tooltip, zoneName) then
            validPets[#validPets + 1] = { name = speciesName, ID = petID }
        end
    end

    if #validPets == 0 then
        print("|c0000FF00ZonePet: " .. "|c0000FFFFYou don't own any pets from this zone - go tame some!")
        C_PetJournal.SummonRandomPet()
    else
        -- print("You own " .. #validPets .. " pets that live in " .. zoneName)
        if #validPets == 1 then
            petIndex = math.random(1)
            name = validPets[1].name
            id = validPets[1].ID
        else
            repeat
                petIndex = math.random(#validPets)
                name = validPets[petIndex].name
                id = validPets[petIndex].ID
            until id ~= summonedPetGUID
        end

        print("|c0000FF00ZonePet: " .. "|c0000FFFFSummoning " .. name)
        C_PetJournal.SummonPetByGUID(id)
        ZonePet_LastPetChange = now
    end
end
