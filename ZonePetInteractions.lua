function ZonePet_interaction(petName)
  local cats = { "Black Tabby Cat", "Bombay Cat", "Calico Cat", "Cat", "Cheetah Cub", "Cinder Kitten", 
  "Cornish Rex Cat", "Cursed Birman", "Darkmoon Cub", "Felclaw Marsuul", 
  "Feline Familiar", "Fluxfire Feline", "Mr. Bigglesworth", "Nightsaber Cub", 
  "Orange Tabby Cat", "Orphaned Marsuul", "Panther Cub", "Pygmy Marsuul", 
  "Risen Saber Kitten", "Sanctum Cub", "Sand Kitten", "Sapphire Cub", "Savage Cub", 
  "Shadow", "Siamese Cat", "Silver Tabby Cat", "Smoochums", "Snow Cub", 
  "Spectral Tiger Cub", "White Kitten", "Widget the Departed", "Winterspring Cub", "Jiggles" }
  if ZonePet_inTable(cats, petName) == true then
    return "/sit"
  end

  local parrots = { "Cap'n Crackers", "Crackers", "Feathers" }
  if ZonePet_inTable(parrots, petName) == true then
    return "/whistle"
  end

  local moonkin = { "Mini Tyrael", "Moon Moon", "Moonkin Hatchling" }
  if ZonePet_inTable(moonkin, petName) == true then
    return "/dance"
  end

  local penguins = { "Mr. Chilly", "Pengu" }
  if ZonePet_inTable(penguins, petName) == true then
    return "/sexy"
  end

  local oddities = { "Discarded Experiment", "Faceless Mindlasher", "Faceless Minion" }
  if ZonePet_inTable(oddities, petName) == true then
    return "/dance or /roar"
  end

  if petName == "Alterac Brandy" then
    return "/helpme"
  elseif petName == "Graves" then
    return "/cheer, /talk, /roar or /dance"
  elseif petName == "Mischief" then
    return "/sit or /dance"
  elseif petName == "Mojo" then
    return "/kiss"
  elseif petName == "Pandaren Monk" then
    return "/bow or /drink"
  elseif petName == "Tiny Snowman" then
    return "/wave, /dance or /kiss"
  elseif petName == "Mojo" then
    return "/kiss"
  elseif petName == "Tottle" then
    return "/roar"
  elseif petName == "Trunks" then
    return "/wave"
  elseif petName == "Twilight" then
    return "/dance or /sit"
  elseif petName == "Zeradar" then
    return "/cheer"
  elseif petName == "Daisy" then
    return "/beckon"
  end

  return ""
end

function ZonePet_inTable(tbl, item)
  for key, value in pairs(tbl) do
      if value == item then return true end
  end
  return false
end
