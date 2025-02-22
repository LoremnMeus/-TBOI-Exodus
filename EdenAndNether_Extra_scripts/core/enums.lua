local enums = {}

enums.Players = {
}

enums.Items = {
}

enums.Trinkets = {
}

enums.Callbacks = {
	POST_PICKUP_COLLETIBILE = "POST_PICKUP_COLLETIBILE",
	POST_GAIN_COLLECTIBLE = "POST_GAIN_COLLECTIBLE",
	POST_LOSE_COLLECTIBLE = "POST_LOSE_COLLECTIBLE",
	POST_CHANGE_COLLECTIBLE = "POST_CHANGE_COLLECTIBLE",
	POST_CHANGE_ALL_COLLECTIBLE = "POST_CHANGE_ALL_COLLECTIBLE",
	POST_PICKUP_TRINKET = "POST_PICKUP_TRINKET",
	POST_GAIN_TRINKET = "POST_GAIN_TRINKET",
	POST_LOSE_TRINKET = "POST_LOSE_TRINKET",
	POST_CHANGE_TRINKET = "POST_CHANGE_TRINKET",
	POST_CHANGE_ALL_TRINKET = "POST_CHANGE_ALL_TRINKET",
	POST_PICKUP_POCKET_ITEM = "POST_PICKUP_POCKET_ITEM",
	POST_CHANGE_POCKET_ITEM = "POST_CHANGE_POCKET_ITEM",
	PRE_GET_TELEPORT = "PRE_GET_TELEPORT",
	POST_CHANGE_BASIC = "POST_CHANGE_BASIC",
	POST_CHANGE_ALL_BASIC = "POST_CHANGE_ALL_BASIC",
	PRE_DESCRIPT_ITEM = "PRE_DESCRIPT_ITEM",
	POST_DESCRIPT_ITEM = "POST_DESCRIPT_ITEM",
	PRE_TELL_FORTUNE = "PRE_TELL_FORTUNE",
	PRE_PRE_NEW_LEVEL = "PRE_PRE_NEW_LEVEL",
	PRE_NEW_LEVEL = "PRE_NEW_LEVEL",
	PRE_NEW_ROOM = "PRE_NEW_ROOM",
	PRE_PRE_GAME_STARTED = "PRE_PRE_GAME_STARTED",
	POST_INHERIT_SAVE = "POST_INHERIT_SAVE",
	POST_CLEAR_SAVE = "POST_CLEAR_SAVE",
	PRE_GAME_STARTED = "PRE_GAME_STARTED",
	POST_PRE_GAME_STARTED = "POST_PRE_GAME_STARTED",
	POST_PLAYER_INIT_OVER = "POST_PLAYER_INIT_OVER",
	POST_SLOT_INIT = "POST_SLOT_INIT",
	POST_SLOT_UPDTAE = "POST_SLOT_UPDTAE",
	POST_SLOT_COLLISION = "POST_SLOT_COLLISION",
	POST_SLOT_KILL = "POST_SLOT_KILL",
	POST_EVERY_ENTITY_INIT = "POST_EVERY_ENTITY_INIT",
	POST_EVERY_ENTITY_UPDTAE = "POST_EVERY_ENTITY_UPDTAE",
	MC_EVALUATE_IMITATE_ITEM = "MC_EVALUATE_IMITATE_ITEM",
	POST_REASSIGN_IMITATE_ITEM = "POST_REASSIGN_IMITATE_ITEM",
	PRE_CHECK_PRICE = "PRE_CHECK_PRICE",
	PRE_PLAYER_KILL = "PRE_PLAYER_KILL",
	POST_REWIND = "POST_REWIND",
	PRE_CHECK_ITEMPOOL = "PRE_CHECK_ITEMPOOL",
	PRE_GET_COLLECTIBLE = "PRE_GET_COLLECTIBLE",
	PRE_GET_COLLECTIBLE_FROM_POOL = "PRE_GET_COLLECTIBLE_FROM_POOL",
	PRE_QINGS_KNIFE_COLLISION = "PRE_QINGS_KNIFE_COLLISION",
	PRE_ANNAS_PORTAL_COLLISION = "PRE_ANNAS_PORTAL_COLLISION",
	POST_ANNAS_PORTAL_UPDATE = "POST_ANNAS_PORTAL_UPDATE",
	POST_CHECK_PLAYER_POSITIONOFFSET = "POST_CHECK_PLAYER_POSITIONOFFSET",
	POST_PLAYER_SHIFT = "POST_PLAYER_SHIFT",
	POST_GRID_UPDTAE = "POST_GRID_UPDTAE",
	PRE_SLOT_RENDER = "PRE_SLOT_RENDER",
	POST_SLOT_RENDER = "POST_SLOT_RENDER",
	POST_PICKUP_MORPH = "POST_PICKUP_MORPH",
	POST_LASER_INIT_2_UPDATE = "POST_LASER_INIT_2_UPDATE",
	POST_FIRE_TRIGGER = "POST_FIRE_TRIGGER",
	POST_FIRE_TRIGGER_IN_FRAME = "POST_FIRE_TRIGGER_IN_FRAME",
	POST_TRIGGER_BOMB_EFFECT = "POST_TRIGGER_BOMB_EFFECT",
}

enums.SoundEffect = {
}

enums.Slots = {
}

enums.Cards = {
}

enums.Costumes = {
}

enums.Familiars = {
}

enums.Enemies = {
	Cursed_Dip = Isaac.GetEntityVariantByName("Cursed Dip"),
	Holy_Dip = Isaac.GetEntityVariantByName("Holy Dip"),
	Cursed_Big_Dip = Isaac.GetEntityVariantByName("Cursed Big Dip"),
	Holy_Big_Dip = Isaac.GetEntityVariantByName("Holy Big Dip"),
	White_Wizoob = Isaac.GetEntityVariantByName("White Wizoob"),
	Eye_Flower = Isaac.GetEntityVariantByName("Eye Flower"),
    Grow_Maw = Isaac.GetEntityVariantByName("Grow Maw"),
    Grow_Horf = Isaac.GetEntityVariantByName("Grow Horf"),
    Grower = Isaac.GetEntityVariantByName("Grower"),
    Holy_Sucker = Isaac.GetEntityVariantByName("Holy Sucker"),
    Losy = Isaac.GetEntityVariantByName("Losy"),
    White_Boom_Fly = Isaac.GetEntityVariantByName("White Boom Fly"),
    The_Grow_Chain = Isaac.GetEntityVariantByName("The Grow Chain"),
    Mullibloom = Isaac.GetEntityVariantByName("Mullibloom"),
	Holy_Pooter = Isaac.GetEntityVariantByName("Holy Pooter"),
    Whity = Isaac.GetEntityVariantByName("Whity"),
    Shy_Knight = Isaac.GetEntityVariantByName("Shy Knight"),
    Lil_Ghast = Isaac.GetEntityVariantByName("Lil Ghast"),

	
    Mixturer = Isaac.GetEntityVariantByName("Mixstro"),
    Neoplasm = Isaac.GetEntityVariantByName("Neoplasm"),
    Neoplasm2 = Isaac.GetEntityVariantByName("Neoplasm Medium"),
    Neoplasm3 = Isaac.GetEntityVariantByName("Neoplasm Small"),
    Maid_in_the_Mist = Isaac.GetEntityVariantByName("Maid in the Mist"),
    --Mixture_Monstro = Isaac.GetEntityVariantByName("Mixture Monstro"),
    --Mixture_Duke_of_Flies = Isaac.GetEntityVariantByName("Mixture Duke of Flies"),
}

enums.Entities = {
    Heaven_Door_Misc = Isaac.GetEntityVariantByName("Heaven Door Misc"),
    EAN_Grid_Spawner = Isaac.GetEntityVariantByName("EAN Grid Spawner"),
}

enums.Pickups = {
    Apple = Isaac.GetEntityVariantByName("Apple"),
}

enums.Musics = {
	Eden = Isaac.GetMusicIdByName("The Mysterious Glasshouse"),
}

if REPENTOGON then
	enums.Achievements = {
		EdenUnlock = Isaac.GetAchievementIdByName("Unlock Eden!"),
	}
end

return enums
