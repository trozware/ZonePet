function ZonePet_interaction(petName)
  local cats = { 
    "Black Tabby Cat",
    "Bombay Cat",
    "Brightpaw",
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

  local parrots = { "Cap'n Crackers", "Crackers", "Feathers" }
  if ZonePet_inTable(parrots, petName) == true then
    return "/whistle"
  end

  local dancers = { "Mini Tyrael", "Moon Moon", "Moonkin Hatchling", "Blinky" }
  if ZonePet_inTable(dancers, petName) == true then
    return "/dance"
  end

  local penguins = { "Mr. Chilly", "Pengu" }
  if ZonePet_inTable(penguins, petName) == true then
    return "/sexy"
  end

  local stewards = { "Lost Featherling", "Ruffle", "Steward Featherling" }
  if ZonePet_inTable(stewards, petName) == true then
    return "/sit, /roar or /talk"
  end

  local treehuggers = { "Fun Guss", "Trootie", "Leafadore" }
  if ZonePet_inTable(treehuggers, petName) == true then
    return "/pat or /hug"
  end

  local oddities = { "Discarded Experiment", "Faceless Mindlasher", "Faceless Minion" }
  if ZonePet_inTable(oddities, petName) == true then
    return "/dance or /roar"
  end

  if petName == "Alterac Brandy" then
    return "/helpme"
  elseif petName == "Mojo" then
    return "/kiss"
  elseif petName == "Tottle" then
    return "/roar"
  elseif petName == "Trunks" then
    return "/wave"
  elseif petName == "Zeradar" or petName == "Pebble" then
    return "/cheer"
  elseif petName == "Daisy" then
    return "/beckon"
  elseif petName == "Scout" or petName == "Sunny" then
    return "/pet"
  elseif petName == "Uuna" then
    return "/hug"
  elseif petName == "Ysergle" then
    return "/sleep"
  elseif petName == "Mischief" or petName == "Twilight" then
    return "/dance or /sit"
  elseif petName == "Pandaren Monk" then
    return "/bow or /drink"
  elseif petName == "Jiggles" then
    return "/pet or /sit"
  elseif petName == "Tiny Snowman" then
    return "/wave, /dance or /kiss"
  elseif petName == "Lil' Maggz" then
    return "/roar, /salute or /point"
  elseif petName == "Graves" then
    return "/cheer, /talk, /roar or /dance"
  elseif petName == "Murkastrasza" then
    return "/wave, /dance, /cheer or /silly"
  elseif petName == "Drakks" then
    return "/salute, /wave, /roar, /dance, /bow or /cheer"
  elseif petName == "Lil' Ursoc" then
    return "/roar, /sit, /dance, /bow, /kneel or /shy"
  elseif petName == "Micromancer" then
    return "/dance, /wave, /cheer, /rawr, /salute, /bow, /flex or /applaud"
  end

  return ""
end

function ZonePet_inTable(tbl, item)
  for key, value in pairs(tbl) do
      if value == item then return true end
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
  end

  return ""
end
