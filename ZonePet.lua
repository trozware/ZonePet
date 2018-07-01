local ZonePet_EventFrame = CreateFrame("Frame")
ZonePet_EventFrame:RegisterEvent("PLAYER_LOGIN")
ZonePet_EventFrame:RegisterEvent("ZONE_CHANGED")
ZonePet_EventFrame:RegisterEvent("ZONE_CHANGED_NEW_AREA")
-- ZonePet_EventFrame:RegisterEvent("ZONE_CHANGED_INDOORS")
-- ZonePet_EventFrame:RegisterEvent("PLAYER_MOUNT_DISPLAY_CHANGED")

ZonePet_LastPetChange = 0

-- "|c000000FF" = blue
-- "|c0000FF00" = green
-- "|c00FF0000" = red
-- "|c0000FFFF" = cyan
-- leading FF - not sure what that does
-- "|cFFFFFF00"  = yellow


ZonePet_EventFrame:SetScript("OnEvent",
    function(self, event, ...)
        if event == "PLAYER_LOGIN" then
            -- data not ready immediately
        C_Timer.After(3, 
                function()
                    processEvent()
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

    -- local subZone = GetSubZoneText()

    -- if zone ~= "" then
    --     if subZone ~= "" then
    --         print("|cFF00FFFF" .. subZone .. ", " .. zone)
    --      else
    --         print("|cFF00FFFF" .. zone)
    --     end

    --     if event == "ZONE_CHANGED" then
    --         getPetData(zone)
    --     end
    -- else
    --     print("|cFF00FFFF" .. "Unknown zone")
    -- end

    -- if IsMounted() then
    --     mountName, mountID = getMountData()
    --     if mountName == nil then
    --         print("|cFFFFFF00" .. "Scheduled flight")
    --         return
    --     else
    --         print("|cFFFFFF00" .. mountName .. " (ID: " .. mountID .. ")")
    --     end

    --     if IsFlying() then
    --         print("|cFFFFFF00" .. "Mounted & flying")
    --     else
    --         print("|cFFFFFF00" .. "Mounted, not flying")
    --     end
    -- elseif IsFlying() then
    --     print("|cFFFFFF00" .. "Flying, not mounted")
    -- else
    --     print("|cFFFFFF00" .. "Not mounted")
    -- end
end

-- function getMountData() 
--     mountCount = C_MountJournal.GetNumDisplayedMounts()
--     for m = 1, mountCount do
--         creatureName, spellID, icon, active, isUsable, sourceType, isFavorite, isFactionSpecific, faction, hideOnChar, isCollected, mountID  = C_MountJournal.GetDisplayedMountInfo(m)
--         if active then
--             return creatureName, mountID
--         end
--     end
--     return nil
-- end

function summonRandomPet(zoneName)
    numPets, numOwned = C_PetJournal.GetNumPets()
    validPets = {}

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
    else
        -- print("You own " .. #validPets .. " pets that live in " .. zoneName)
        petIndex = math.random(#validPets)

        name = validPets[petIndex].name
        id = validPets[petIndex].ID

        print("|c0000FF00ZonePet: " .. "|c0000FFFFSummoning " .. name)
        C_PetJournal.SummonPetByGUID(id)
        ZonePet_LastPetChange = now
    end
end
