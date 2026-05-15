function ZonePet_interaction(petName)
  local cats = {
    "Black Tabby Cat",
    "Bombay Cat",
    "Calico Cat",
    "Cat",
    "Cheetah Cub",
    "Cinder Kitten",
    "Cornish Rex Cat",
    "Cursed Birman",
    "Darkmoon Cub",
    "Felclaw Marsuul",
    "Feline Familiar",
    "Fluxfire Feline",
    "Jingles",
    "Mr. Bigglesworth",
    "Nightsaber Cub",
    "Orange Tabby Cat",
    "Orphaned Marsuul",
    "Panther Cub",
    "Pygmy Marsuul",
    "Risen Saber Kitten",
    "Sanctum Cub",
    "Sand Kitten",
    "Sapphire Cub",
    "Savage Cub",
    "Shadow",
    "Siamese Cat",
    "Silver Tabby Cat",
    "Sinheart",
    "Smoochums",
    "Snow Cub",
    "Spectral Tiger Cub",
    "White Kitten",
    "Widget the Departed",
    "Winterspring Cub"
  }
  if ZonePet_inTable(cats, petName) == true then
    return "/sit"
  end

  local parrots = {"Cap'n Crackers", "Crackers", "Feathers"}
  if ZonePet_inTable(parrots, petName) == true then
    return "/whistle"
  end

  local dancers = {
    "Blinky",
    "Blueloo",
    "Elmer",
    "Flooftalon",
    "Glamrok",
    "Mini Tyrael",
    "Moon Moon",
    "Moonkin Hatchling",
    "Pale Slumbertooth",
    "Slumbertooth",
    "Snaggletoof",
    "Snoots"
  }
  if ZonePet_inTable(dancers, petName) == true then
    return "/dance"
  end

  local helps = {"Alterac Brandy", "Alterac Brew-Pup"}
  if ZonePet_inTable(helps, petName) == true then
    return "/helpme"
  end

  local penguins = {"Mr. Chilly", "Pengu"}
  if ZonePet_inTable(penguins, petName) == true then
    return "/sexy"
  end

  local waves = {"Trunks", "Sarge"}
  if ZonePet_inTable(waves, petName) == true then
    return "/wave"
  end

  local cheers = {"Zeradar", "Pebble"}
  if ZonePet_inTable(cheers, petName) == true then
    return "/cheers"
  end

  local petters = {"Scout", "Sunny"}
  if ZonePet_inTable(petters, petName) == true then
    return "/pet"
  end

  local patHug = {"Fun Guss", "Trootie", "Leafadore"}
  if ZonePet_inTable(patHug, petName) == true then
    return "/pat or /hug"
  end

  local danceRoar = {"Discarded Experiment", "Faceless Mindlasher", "Faceless Minion"}
  if ZonePet_inTable(danceRoar, petName) == true then
    return "/dance or /roar"
  end

  local danceSit = {"Mischief", "Twilight", "Brightpaw"}
  if ZonePet_inTable(danceSit, petName) == true then
    return "/dance or /sit"
  end

  local stewards = {"Lost Featherling", "Ruffle", "Steward Featherling"}
  if ZonePet_inTable(stewards, petName) == true then
    return "/sit, /roar or /talk"
  end

  local robots = {
    "Bilgewater Junkhauler",
    "Blackwater Kegmover",
    "Mr. DELVER",
    "Personal-Use Sapper",
    "Steamwheedle Flunkie",
    "Venture Companyman"
  }
  if ZonePet_inTable(robots, petName) == true then
    return "/dance, /hug or /cheer"
  end

  local littles = {"Lil' Maggz", "Lil' Ashlee", "Lil' Coalee"}
  if ZonePet_inTable(littles, petName) == true then
    return "/roar, /salute or /point"
  end

  local mechs = {"Crimson Mechasaur", "Fun-Size Flarendo", "Viridian Mechasaur", "Wavebreaker Mechasaur"}
  if ZonePet_inTable(mechs, petName) == true then
    return "/dance, /hug, /pet, /cheer or /roar"
  end

  local dogsCats = {"Eepy", "Foreman", "Goggles", "Marmaduke", "Mister Mans", "Mutt", "Thunder", "Tiberius", "Vanilla"}
  if ZonePet_inTable(dogsCats, petName) == true then
    return "/dance, /sit, /sleep, /hug, /pet, /cheer or /roar"
  end

  if petName == "Mojo" then
    return "/kiss"
  elseif petName == "Tottle" then
    return "/roar"
  elseif petName == "Daisy" then
    return "/beckon"
  elseif petName == "Uuna" then
    return "/hug"
  elseif petName == "Ysergle" then
    return "/sleep"
  elseif petName == "Pandaren Monk" then
    return "/bow or /drink"
  elseif petName == "Jiggles" then
    return "/pet or /sit"
  elseif petName == "Tiny Snowman" then
    return "/wave, /dance or /kiss"
  elseif petName == "Graves" then
    return "/cheer, /talk, /roar or /dance"
  elseif petName == "Murkastrasza" then
    return "/wave, /dance, /cheer or /silly"
  elseif petName == "Faithful Dog" then
    return "/pet, /woof, /kiss or /love"
  elseif petName == "Drakks" then
    return "/salute, /wave, /roar, /dance, /bow or /cheer"
  elseif petName == "Lil' Ursoc" then
    return "/roar, /sit, /dance, /bow, /kneel or /shy"
  elseif petName == "Bean" then
    return "/dance, /hug, /pet, /cheer, /roar or /sleep"
  elseif petName == "Micromancer" then
    return "/dance, /wave, /cheer, /rawr, /salute, /bow, /flex or /applaud"
  end

  return ""
end

function ZonePet_randomInteraction(petName)
  local result = ZonePet_interaction(petName)
  if result == "" then
    return ""
  end

  result = result:gsub(" or ", ", ")
  local options = {}
  for option in result:gmatch("[^,]+") do
    option = option:match("^%s*(.-)%s*$")
    if option ~= "" then
      options[#options + 1] = option
    end
  end

  local option = options[math.random(#options)]
  return option:sub(2)
end

function ZonePet_inTable(tbl, item)
  for key, value in pairs(tbl) do
    if value == item then
      return true
    end
  end
  return false
end

function ZonePet_extraUse(petName)
  if petName == "Disgusting Oozeling" then
    return "REDUCES ALL YOUR RESISTANCES!"
  elseif petName == "Ethereal Soul-Trader" then
    return "doubles as vendor with unique items sold only to owner."
  elseif petName == "Hearthy" then
    return "can be used as a hearthstone."
  elseif petName == "Lil' Ragnaros" or petName == "Pierre" then
    return "can be used as a cooking fire."
  elseif petName == "Wondrous Wisdomball" then
    return "can be used as a Magic 8 Ball."
  elseif petName == "Argent Gruntling" or petName == "Argent Squire" then
    return "with Argent Pony Bridle, pet becomes a mailbox, a bank, or a vendor every 4 hours."
  elseif petName == "Alterac Brandy" or petName == "Alterac Brew-Pup" then
    return "click on this pet to get Mulled Alterac Brandy."
  elseif petName == "Alvin the Anvil" then
    return "can be used as a blacksmithing anvil."
  elseif petName == "Guild Herald" or petName == "Guild Page" then
    return "acts as a guild reward vendor."
  elseif petName == "Pebble" then
    return "when hungry, feed it a WotLK fish to get a stone, possibly a Glowing Pebble."
  end

  return ""
end

function ZonePet_checkForPetTarget()
  if IsInInstance() or IsInRaid() then
    return
  end

  if zonePetMiniMap.interactOnSelection == false then
    return
  end

  local petData = ZonePet_dataForCurrentPet()
  if petData and UnitExists("target") then
    if UnitName("target") ~= petData.name then
      return
    end

    local name, id = UnitCreatureType("target")
    if id == 12 or id == 14 then
      -- Player has targeted their companion pet
      local interaction = ZonePet_randomInteraction(petData.name)
      if interaction then
        -- trigger the interaction, e.g. send the slash command to chat
        C_ChatInfo.PerformEmote(interaction)
      end
    else
      -- print("Creature type = " .. name .. id)
      return
    end
  end
end
