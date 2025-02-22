local g = require("EdenAndNether_Extra_scripts.core.globals")
local save = require("EdenAndNether_Extra_scripts.core.savedata")
local enums = require("EdenAndNether_Extra_scripts.core.enums")
local auxi = require("EdenAndNether_Extra_scripts.auxiliary.functions")
local grid_trapdoor = require("EdenAndNether_Extra_scripts.grids.grid_trapdoor")
local Achievement_Display_holder = require("EdenAndNether_Extra_scripts.others.Achievement_Display_holder")
--local base = require("EdenAndNether_Extra_scripts.others.Base_holder")
local item = {
	ToCall = {},
	myToCall = {},
	own_key = "EAN_Base_holder_",
	closed = {
		Closed = true,
		CoinClosed = true,
		KeyClosed = true,
	},
	room_iconlist = {
		[RoomType.ROOM_NULL] = {id = -1, horn = 0},
		[RoomType.ROOM_DEFAULT] = {id = -1, horn = 0},
		[RoomType.ROOM_SHOP] = {id = 5, horn = 1},
		[RoomType.ROOM_ERROR] = {id = -1, horn = 0},
		[RoomType.ROOM_TREASURE] = {id = 12, horn = 1},
		[RoomType.ROOM_BOSS] = {id = 8, horn = 0},
		[RoomType.ROOM_MINIBOSS] = {id = 8, horn = 0},
		[RoomType.ROOM_SECRET] = {id = 1, horn = 0,offset = 1,},
		[RoomType.ROOM_SUPERSECRET] = {id = 1, horn = 0,offset = 1,},
		[RoomType.ROOM_ARCADE] = {id = 6, horn = 1},
		[RoomType.ROOM_CURSE] = {id = 9, horn = 0},
		[RoomType.ROOM_CHALLENGE] = {id = 3, horn = 0},
		[RoomType.ROOM_LIBRARY] = {id = 11, horn = 1},
		[RoomType.ROOM_SACRIFICE] = {id = 4, horn = 0},
		[RoomType.ROOM_DEVIL] = {id = 2, horn = 0},
		[RoomType.ROOM_ANGEL] = {id = 10, horn = 0},
		[RoomType.ROOM_DUNGEON] = {id = -1, horn = 0},
		[RoomType.ROOM_BOSSRUSH] = {id = -1, horn = 0},
		[RoomType.ROOM_ISAACS] = {id = 11, horn = 1},
		[RoomType.ROOM_BARREN] = {id = 11, horn = 1},
		[RoomType.ROOM_CHEST] = {id = 13, horn = 1},
		[RoomType.ROOM_DICE] = {id = 14, horn = 1},
		[RoomType.ROOM_BLACK_MARKET] = {id = -1, horn = 0},
		[RoomType.ROOM_GREED_EXIT] = {id = 15, horn = 0},
		--[RoomType.NUM_ROOMTYPES] = {id = 24, horn = 0}
		
		-- Repentance
		[RoomType.ROOM_PLANETARIUM] = {id = 7, horn = 1},
		[RoomType.ROOM_TELEPORTER] = {id = 15, horn = 0},		-- Mausoleum teleporter entrance, currently unused
		[RoomType.ROOM_TELEPORTER_EXIT] = {id = 15, horn = 0},	-- Mausoleum teleporter exit, currently unused
		[RoomType.ROOM_SECRET_EXIT] = {id = 15, horn = 0,},		-- Trapdoor room to the alt path floors
		[RoomType.ROOM_BLUE] = {id = -1, horn = 0},				-- Blue Womb rooms spawned by Blue Key
		[RoomType.ROOM_ULTRASECRET] = {id = 15, horn = 0,offset = 1,},		-- Red secret rooms
	},
	replace_level = {
		[LevelStage.STAGE4_2] = true,
		[LevelStage.STAGE4_3] = true,
	},
	Eden_Color = Color(0.2,1,0.2,1),
	STAGE_API_LOADED = {
		["Initialized"] = true,
		["FirstLoad"] = true,
		["VisitCount"] = true,
	},
	Eden_Backdrop = "",
}

if StageAPI then
	if StageAPI.StageOverride["Cathedral"] == nil then		--修一下bug
		StageAPI.Cathedral = StageAPI.CustomStage("Cathedral", nil, true)
		--StageAPI.Cathedral:SetStageMusic(Music.MUSIC_Cathedral)
		StageAPI.Cathedral:SetStageNumber(LevelStage.STAGE5)
		StageAPI.Cathedral.GenerateLevel = StageAPI.GenerateBaseLevel
		StageAPI.Cathedral.DisplayName = "Cathedral"

		StageAPI.AddOverrideStage("Cathedral",LevelStage.STAGE5,StageType.STAGETYPE_WOTL,StageAPI.Cathedral,false)
	end
	if StageAPI.StageOverride["SHEOL"] == nil then
		StageAPI.SHEOL = StageAPI.CustomStage("SHEOL", nil, true)
		--StageAPI.SHEOL:SetStageMusic(Music.MUSIC_SHEOL)
		StageAPI.SHEOL:SetStageNumber(LevelStage.STAGE5)
		StageAPI.SHEOL.GenerateLevel = StageAPI.GenerateBaseLevel
		--StageAPI.SHEOL.DisplayName = "SHEOL"

		StageAPI.AddOverrideStage("SHEOL",LevelStage.STAGE5,StageType.STAGETYPE_ORIGINAL,StageAPI.SHEOL,false)
	end


	item.BlushGrid = StageAPI.CustomGrid("ExodusBlush", {
		BaseType = GridEntityType.GRID_POOP,
		Anm2 = "gfx/backdrops/blush.anm2",
		RemoveOnAnm2Change = true,
		Animation = "State1",
		OverrideGridSpawns = true,
		PoopExplosionColor = Color(0,0,0,0.7,55 / 255,148 / 255,110 / 255),
		PoopGibSheet = "gfx/backdrops/effect_blush.png",
		SpawnerEntity = {Type = 747, Variant = 1001,}
	})

	local gridReplacementRNG = RNG()
	table.insert(item.ToCall,#item.ToCall + 1,{CallBack = ModCallbacks.MC_POST_NEW_ROOM, params = nil,
	Function = function(_)
		local room = Game():GetRoom()
		local currentRoom = StageAPI.GetCurrentRoom()
		if room:IsFirstVisit() and (not currentRoom or currentRoom.VisitCount == 1) then
			gridReplacementRNG:SetSeed(room:GetSpawnSeed(), 0) -- grid rng is broken for reward plates, so lets just do this
			for i = 0, room:GetGridSize() do
				local grid = room:GetGridEntity(i)
				if grid and not StageAPI.IsCustomGrid(i) then
					if grid.Desc.Type == GridEntityType.GRID_POOP and grid.Desc.Variant == 0 then
						if gridReplacementRNG:RandomFloat() <= 0.25 then
							item.BlushGrid:Spawn(i, false, true)
						end
					end
				end
			end
		end
	end,
	})
	
	StageAPI.AddCallback("Exodus", "POST_CUSTOM_GRID_DESTROY", 1, function(customGrid, projectile)
		local pos = customGrid.Position
		local rng = customGrid.RNG
		local chance = rng:RandomFloat()

		if chance < 0.01 and save.elses[item.own_key.."Eden_Blessing"] == nil then
			save.elses[item.own_key.."Eden_Blessing"] = true
			local q = Isaac.Spawn(5,100,381,pos,Vector(0,0),nil)
		end
	end, "ExodusBlush")

	StageAPI.AddCallback("Exodus", "POST_SPAWN_CUSTOM_GRID", 1, function(customGrid)
		local grid = customGrid.GridEntity
		local sprite = grid:GetSprite()
		auxi.SetPoopSpriteState(grid, sprite)
	end, "ExodusBlush")

	StageAPI.AddCallback("Exodus", "POST_CUSTOM_GRID_POOP_GIB_SPAWN", 1, function(customGrid, effect)
		local pos = customGrid.Position
		local rng = customGrid.RNG
		local chance = rng:RandomFloat()
		if chance < 0.33 then
			local q = Isaac.Spawn(5,enums.Pickups.Apple,0,pos,effect.Velocity,nil):ToPickup()
		end
	end, "ExodusBlush")

	local suffix = ""
	if Options.Language == "zh" then suffix = "_cn" end
	item.StageAPIBosses = {
		Mixstro = StageAPI.AddBossData("Exodus Mixstro", {
			Name = "Mixstro",
			Portrait = "gfx/ui/boss/mixstro.png",
			Bossname = "gfx/ui/boss/mixstro_name"..suffix..".png",
			Offset = Vector(8,-15),
			Weight = 1,
			Rooms = StageAPI.RoomsList("Exodus Mixstro Rooms", require("resources.luarooms.Mixture_room")),
			Entity = {Type = 20, Variant = 747,},
		}),
	}
	
	function item.AddAllBosses()
		StageAPI.AddBossToBaseFloorPool({BossID = "Exodus Mixstro", Weight = 1.5}, LevelStage.STAGE1_1, StageType.STAGETYPE_ORIGINAL)
		StageAPI.AddBossToBaseFloorPool({BossID = "Exodus Mixstro", Weight = 1.5}, LevelStage.STAGE1_1, StageType.STAGETYPE_WOTL)
	end

	if true then
		item.AddAllBosses()
	end

	item.EdenWalls = StageAPI.BackdropHelper({{
			Walls = {"","_1","_2"},
			NFloors = {"_nfloor"},
			LFloors = {"_lfloor"},
			Corners = {"_corner"}
		},
	}, "gfx/backdrops/Eden", ".png")
	item.EdenGrid = StageAPI.GridGfx()
	item.EdenGrid:AddDoors("gfx/backdrops/Eden_Door.png", StageAPI.DefaultDoorSpawn)
	item.EdenGrid:SetDecorations("gfx/backdrops/Eden_props.png", "gfx/grid/props_05_depths.anm2", 43)
	item.EdenGrid:SetRocks("gfx/backdrops/Eden_grids_2.png")
	--item.EdenGrid:SetPits("gfx/grid/grid_pit_ashpit.png",
	item.EdenGrid:SetPits("gfx/backdrops/eden_pit_2.png",{{File = "gfx/backdrops/eden_pit_2.png"}},false)

	item.EdenFallWalls = StageAPI.BackdropHelper({{
			Walls = {"_fall","_fall_1","_fall_2"},
			NFloors = {"_fall_nfloor"},
			LFloors = {"_fall_lfloor"},
			Corners = {"_fall_corner"}
		},
	}, "gfx/backdrops/Eden", ".png")
	item.EdenFallGrid = StageAPI.GridGfx()
	item.EdenFallGrid:AddDoors("gfx/backdrops/Eden_Fall_Door.png", StageAPI.DefaultDoorSpawn)
	item.EdenFallGrid:SetDecorations("gfx/backdrops/Eden_props.png", "gfx/grid/props_05_depths.anm2", 43)
	item.EdenFallGrid:SetRocks("gfx/backdrops/Eden_fall_grids_2.png")
	item.EdenFallGrid:SetPits("gfx/backdrops/eden_pit_2.png",{{File = "gfx/backdrops/eden_pit_2.png"}},false)

	
	if REPENTOGON then
		item.EdenGrid:SetPits("gfx/grid/grid_pit_ashpit.png",{{File = "gfx/grid/grid_pit_ashpit_.png"}},false)
		item.EdenFallGrid:SetPits("gfx/grid/grid_pit_ashpit.png",{{File = "gfx/grid/grid_pit_ashpit_.png"}},false)
		local s2 = Sprite() s2:Load("gfx/pit_Misc.anm2",true) s2:Play("pit",true) --s2:PlayOverlay("highlights",true) s2:ReplaceSpritesheet(1,"")
		table.insert(item.ToCall,#item.ToCall + 1,{CallBack = ModCallbacks.MC_PRE_GRID_ENTITY_PIT_RENDER, params = nil,
		Function = function(_,pit)
			if item.TheEden:IsStage() then
				local s = pit:GetSprite() 
				s2:SetFrame(s:GetFrame())
				local cap1 = 628.318531 local cap2 = 7000
				local base_val = BASE_VAL or Game():GetFrameCount()
				local val = base_val % cap1
				--if base_val % (cap1 * 2) >= cap1 then val = cap1 - val end
				val = (val + 1)/cap2

				local rpos = Isaac.WorldToScreen(pit.Position) - Game().ScreenShakeOffset
				if (Game():GetRoom():GetRenderMode() == RenderMode.RENDER_WATER_REFRACT) then
					rpos = (MOVE_OFFSET or auxi.GetWaterRenderOffset()) + Isaac.WorldToScreen(pit.Position) - Game().ScreenShakeOffset
				end

				--local srpos = auxi.check_screen_size(rpos/256)
				local room = Game():GetRoom()
				local wid = room:GetGridWidth() local gidx = room:GetGridIndex(pit.Position)
				local xval = (gidx % wid)
				local yval = ((gidx - xval)/wid)
				local move_rate = MOVE_RATE or 30
				s2.Color = Color(val,xval / move_rate,yval / move_rate,1)
				--local layer = s2:GetLayer(0)
				local path = "shaders/water_shader"
				if item.Eden_Backdrop == "Fall" then path = "shaders/water_shader_Fall" end
				if not s2:HasCustomShader(path) then s2:SetCustomShader(path) end
				s2:Render(rpos)--s2:RenderLayer(0,rpos)
				return false
			end
		end,
		})
	end

	item.EdenBackdrop = StageAPI.RoomGfx(item.EdenWalls, item.EdenGrid, "_default", "stageapi/shading/shading")
	item.EdenFallBackdrop = StageAPI.RoomGfx(item.EdenFallWalls, item.EdenFallGrid, "_default", "stageapi/shading/shading")
	item.EdenBackdrop.EAN_ID = "Base"
	item.EdenFallBackdrop.EAN_ID = "Fall"

	item.EdenRooms = {
		RoomFiles = {
			"Eden_room",
			--"base_room1",
			"base_room2",
			"EdenFall_room_",
		}
	}
--l local base = require("EdenAndNether_Extra_scripts.others.Base_holder") StageAPI.ChangeRoomGfx(base.EdenBackdrop)
	item.EdenRoomlist = {}

	for _, roomName in ipairs(item.EdenRooms.RoomFiles) do
		local ret = require("resources.luarooms." .. roomName)
		item.EdenRooms.RoomFiles[roomName] = ret
		if roomName == "EdenFall_room_" then 
			for u,v in pairs(ret) do if type(v) == "table" then v.SUBTYPE = 400 end end
		end
		item.EdenRoomlist[#item.EdenRoomlist + 1] = ret
	end

	local EdenRoomsReal = StageAPI.RoomsList("EdenRooms", table.unpack(item.EdenRoomlist))

	item.TheEden = StageAPI.CustomStage("Eden")
	item.TheEden:SetName("Eden")
	item.TheEden.DisplayName = "Eden"
	item.EdenBosslist = {
		"Isaac",
	}
	
	--item.TheEden:SetBosses(item.EdenBosslist, true,true)
	item.TheEden:SetSpots("gfx/stage/bossspot_eden.png","gfx/stage/playerspot_eden.png")
	--item.TheEden:SetPregenerationEnabled(true)
	item.TheEden:SetTransitionIcon(
        "gfx/stage/cstage_eden.png", 
        "gfx/stage/bossspot_eden.png"
    )
	item.TheEden:SetRoomGfx(item.EdenBackdrop, {RoomType.ROOM_BOSS,RoomType.ROOM_DEFAULT, RoomType.ROOM_TREASURE, RoomType.ROOM_MINIBOSS})
	item.TheEden:SetRooms({
		[RoomType.ROOM_DEFAULT] = EdenRoomsReal,
	})
	item.TheEden:SetStageNumber(10,2)
	item.TheEden.GenerateLevel = StageAPI.GenerateBaseLevel
	item.TheEden:SetStageMusic(enums.Musics.Eden)
	item.TheEden:SetMusic(enums.Musics.Eden, {"Eden"})
	--item.TheEden:SetBossMusic(Music.MUSIC_BOSS3, Music.MUSIC_BOSS_OVER, Music.MUSIC_JINGLE_BOSS, Music.MUSIC_JINGLE_BOSS_OVER3)
	item.TheEden:SetTransitionMusic(Music.MUSIC_JINGLE_NIGHTMARE)
	--item.TheEden:SetMusic(Isaac.GetMusicIdByName("The Mysterious Glasshouse"), {RoomType.ROOM_DEFAULT})
	item.TheEden:SetReplace(StageAPI.StageOverride["Cathedral"])
	--item.TheEden:SetReplace(StageAPI.StageOverride.CatacombsOne)		--为了让音乐一致，只好换一个楼层？
	item.TheEden:SetLevelgenStage(LevelStage.STAGE5, StageType.STAGETYPE_WOTL)
	--item.TheEden:SetNextStage(StageAPI.Chest)
	--StageAPI.GotoCustomStage(StageAPI.CurrentStage, true)
	---[[
	---]]

	StageAPI.AddCallback("EdenAndNether", "POST_STAGEAPI_NEW_ROOM_GENERATION", 1, function(currentRoom, justGenerated, currentListIndex, boss, currentDimension)
		if item.TheEden:IsStage() and Game():GetRoom():IsCurrentRoomLastBoss() then
			return {Boss = StageAPI.GetBossData("Isaac"),}
		end
		
	end)

	StageAPI.AddCallback("EdenAndNether", "PRE_CHANGE_ROOM_GFX", 1, function(currentRoom, usingGfx, onRoomLoad)
		if item.TheEden:IsStage() then
			if usingGfx then
				local room = Game():GetRoom()
				local roomDesc = Game():GetLevel():GetCurrentRoomDesc()
				local rng = RNG()
				rng:SetSeed(room:GetDecorationSeed(), 35)
				local alpha = rng:RandomFloat() * 0.15 + 0.2
				StageAPI.ChangeStageShadow("gfx/overlay/eden/",5,0.85 * alpha,true)
				StageAPI.ChangeStageShadow("gfx/overlay/eden/",5,0.45 * alpha,true,true,3)
				StageAPI.ChangeStageShadow("gfx/overlay/eden/",5,0.25 * alpha,true,true,6)
				rng:SetSeed(room:GetDecorationSeed(), 35)
				local mul = rng:RandomInt(5) local room = Game():GetRoom()
				for i = 1,mul do 
					local pos = room:GetRandomPosition(20)
					local q = Isaac.Spawn(1000,65,0,pos,Vector(0,0),nil)
				end
				rng:SetSeed(room:GetDecorationSeed(), 35)
				local is_fall = false
				if rng:RandomFloat() < 0.1 then is_fall = true end
				local roominfo = StageAPI.GetCurrentRoom()
				if roominfo and roominfo.Layout and roominfo.Layout.SubType == 400 then is_fall = true end
				if is_fall then
					item.Eden_Backdrop = "Fall"
					item.TheEden:SetRoomGfx(item.EdenFallBackdrop, {RoomType.ROOM_BOSS,RoomType.ROOM_DEFAULT, RoomType.ROOM_TREASURE, RoomType.ROOM_MINIBOSS})
					return item.EdenFallBackdrop
				else 
					item.Eden_Backdrop = ""
					item.TheEden:SetRoomGfx(item.EdenBackdrop, {RoomType.ROOM_BOSS,RoomType.ROOM_DEFAULT, RoomType.ROOM_TREASURE, RoomType.ROOM_MINIBOSS})
					return item.EdenBackdrop
				end
			end
		end
	end)

	StageAPI.ChangeStageShadow = function(prefix, count, opacity, useBlendMode, DontRemove, UpdateTime)
		local shared = require("scripts.stageapi.shared")
		prefix = prefix or "stageapi/floors/catacombs/overlays/"
		count = count or 5
		opacity = opacity or 1
		
		if type(count) == "number" then
			count = {["1x1"] = count, ["1x2"] = count, ["2x1"] = count, ["2x2"] = count}
		end
	
		if DontRemove ~= true then
			local shadows = Isaac.FindByType(StageAPI.E.StageShadow.T, StageAPI.E.StageShadow.V, -1, false, false)
			for _, e in ipairs(shadows) do
				e:Remove()
			end
		end
	
		local roomShape = shared.Room:GetRoomShape()
		local anim
	
		if roomShape == RoomShape.ROOMSHAPE_1x1 or roomShape == RoomShape.ROOMSHAPE_IH or roomShape == RoomShape.ROOMSHAPE_IV then anim = "1x1"
		elseif roomShape == RoomShape.ROOMSHAPE_1x2 or roomShape == RoomShape.ROOMSHAPE_IIV then anim = "1x2"
		elseif roomShape == RoomShape.ROOMSHAPE_2x1 or roomShape == RoomShape.ROOMSHAPE_IIH then anim = "2x1"
		elseif roomShape == RoomShape.ROOMSHAPE_2x2 or roomShape == RoomShape.ROOMSHAPE_LBL or roomShape == RoomShape.ROOMSHAPE_LBR or roomShape == RoomShape.ROOMSHAPE_LTL or roomShape == RoomShape.ROOMSHAPE_LTR then anim = "2x2"
		end
	
		if anim then
			StageAPI.StageShadowRNG:SetSeed(shared.Room:GetDecorationSeed(), 0)
			for i = 1,(UpdateTime or 0) do
				StageAPI.StageShadowRNG:Next()
			end
			local shapecount = count[anim]
			local usingShadow = StageAPI.Random(1, shapecount, StageAPI.StageShadowRNG)
			local sheet = prefix .. anim .. "_overlay_" .. tostring(usingShadow) .. ".png"
	
			local shadowEntity = Isaac.Spawn(StageAPI.E.StageShadow.T, StageAPI.E.StageShadow.V, 0, Vector.Zero, Vector.Zero, nil)
			shadowEntity:GetData().Sheet = sheet
			shadowEntity:GetData().Animation = anim
			shadowEntity.Position = StageAPI.Lerp(shared.Room:GetTopLeftPos(), shared.Room:GetBottomRightPos(), 0.5)
			shadowEntity.Color = Color(1,1,1,opacity)
			shadowEntity.DepthOffset = 99999
			shadowEntity:GetSprite():ReplaceSpritesheet(0, sheet)
			shadowEntity:GetSprite():LoadGraphics()
			shadowEntity:GetSprite():SetFrame(anim, 0)
			if useBlendMode and REPENTOGON then
				local blendMode = shadowEntity:GetSprite():GetLayer(0):GetBlendMode()
				blendMode.Flag1 = 4
				blendMode.Flag2 = 7
				blendMode.Flag3 = 4
				blendMode.Flag4 = 7
			end
			shadowEntity:AddEntityFlags(EntityFlag.FLAG_DONT_OVERWRITE)
		end
	end

	item.NetherWalls = StageAPI.BackdropHelper({
		ID = "Nether",
		Walls = {"","_1","_2",},
		NFloors = {"_nfloor"},
		LFloors = {"_lfloor"},
		Corners = {"_corner"}
	}, "gfx/backdrops/Nether", ".png")
	item.NetherGrid = StageAPI.GridGfx()
	item.NetherGrid.DoorSprites = {{
		Anm2 = "gfx/backdrops/Nether_Door/Door.anm2",
		LoadGraphics = true,
		--[[
		OverlayAnm2 = "gfx/backdrops/Nether_Door/Door.anm2",
		States = {
			["Base"] = {
				["OverlayAnim"] = "Fireball",
			},
			["Default"] = "Base",
			["DefaultPayToPlay"] = "Base",
			["DefaultCleared"] = "Base",
			["DefaultUncleared"] = "Base",
		},
		--]]
	}}
	item.NetherGrid.DoorSpawns = {{Sprite = 1,}}
	--item.NetherGrid:AddDoors("gfx/backdrops/Nether_Door.png", StageAPI.DefaultDoorSpawn)
	--item.NetherGrid.DoorSprites = {{Anm2 = "gfx/backdrops/door_nether.anm2",}}
	--item.NetherGrid.DoorSpawns = {{Sprite = 1,}}
	
	function item.check_door(door)
		local current, target = door.CurrentRoomType, door.TargetRoomType
		local isBossAmbush, isPayToPlay = Game():GetLevel():HasBossChallenge(), door:IsTargetRoomArcade() and target ~= RoomType.ROOM_ARCADE
		local isSurpriseMiniboss = Game():GetLevel():GetCurrentRoomDesc().SurpriseMiniboss
		local varData = door.VarData
		local targetRoomIndex = door.TargetRoomIndex
		return StageAPI.DoesDoorMatch(door,{},current, target, isBossAmbush, isPayToPlay, isSurpriseMiniboss, varData, targetRoomIndex)
	end

	function item.target_room2icon(door)
		local targetRoomIndex = door.TargetRoomIndex
		local target = door.TargetRoomType
		return item.room_iconlist[target] or item.room_iconlist[1]
	end

	function item.horn2str(hornid)
		if hornid == 0 then return "gfx/backdrops/Nether_Door/nether_door_harmful.png"
		elseif hornid == 1 then return "gfx/backdrops/Nether_Door/nether_door_peaceful.png"
		else return "gfx/backdrops/Nether_Door/nether_door_nohorn.png" end
	end

	StageAPI.AddCallback("EdenAndNether", "POST_ROOM_LOAD", 1, function(currentRoom, usingGfx, onRoomLoad)
		if item.TheEden:IsStage() and Game():GetRoom():IsClear() then
			for i = 0, 7 do
				local door = Game():GetRoom():GetDoor(i)
				if door and item.check_door(door) then
					local s = door:GetSprite()
					if s:GetAnimation() == "Close" and s:GetFrame() < 4 then
						s:Play("Opened",true)
--						print("fixed")
					end
				end
			end
		end
	end)

	table.insert(item.ToCall,#item.ToCall + 1,{CallBack = ModCallbacks.MC_POST_RENDER, params = nil,
	Function = function(_)
		if item.TheNether:IsStage() then
			for i = 0, 7 do
				local door = Game():GetRoom():GetDoor(i)
				if door then
					local s = door:GetSprite()
					if item.check_door(door) then
						if s:IsFinished("Close") or (s:GetAnimation() == "Close" and s:GetFrame() == 11)then 
							--s:Load("gfx/backdrops/Nether_Door/Door.anm2",true)
							s:Play("Closed",true) 
						end
						if item.closed[s:GetAnimation()] then
							s:Play(s:GetAnimation(),true) 
							s:SetFrame(Game():GetRoom():GetFrameCount() % 12)
						end
						---[[
						local iconinfo = item.target_room2icon(door)
						local horn_str = item.horn2str(iconinfo.horn) if iconinfo.id == -1 then horn_str = item.horn2str(1) end
						s:ReplaceSpritesheet(2,horn_str)
						s:LoadGraphics()
						if iconinfo.id > 0 and s:GetAnimation() ~= "" then
							if iconinfo.offset == 1 then s.Offset = auxi.get_by_rotate(Vector(0,-20),(i - 3) * 90) end
							s:ReplaceSpritesheet(3,"gfx/backdrops/Nether_Door/nether_icon_"..tostring(iconinfo.id)..".png")
							s:LoadGraphics()
							if s:GetOverlayAnimation() ~= "Fireball" then
								--print(s:GetOverlayAnimation())
								s:PlayOverlay("Fireball",true)
								s:SetOverlayFrame(Game():GetRoom():GetFrameCount() % 12)
							end
						end
						---]]
					end
				end
			end
		end
	end,
	})

	table.insert(item.ToCall,#item.ToCall + 1,{CallBack = ModCallbacks.MC_POST_EFFECT_INIT, params = 39,
	Function = function(_,ent)
		if ent.SubType == 0 then
			local level = Game():GetLevel()
			if item.replace_level[level:GetAbsoluteStage()] then
				local rng = ent:GetDropRNG()
				if save.UnlockData[item.own_key.."EdenUnlocked"] and rng:RandomFloat() < (save.UnlockData[item.own_key.."EdenChance"] or 0.5) then 
					local q = Isaac.Spawn(1000,enums.Entities.Heaven_Door_Misc,0,ent.Position,Vector(0,0),nil):ToEffect()
					save.elses[item.own_key.."door_record"] = save.elses[item.own_key.."door_record"] or {}
					local didx = auxi.get_acceptible_index()
					save.elses[item.own_key.."door_record"][didx] = save.elses[item.own_key.."door_record"][didx] or {}
					table.insert(save.elses[item.own_key.."door_record"][didx],{pos = auxi.Vector2Table(ent.Position),})
					ent:Remove()
				end
			end
		end
	end,
	})

	table.insert(item.myToCall,#item.myToCall + 1,{CallBack = enums.Callbacks.PRE_NEW_LEVEL, params = nil,
	Function = function(_)
		save.elses[item.own_key.."door_record"] = {}
	end,
	})

	table.insert(item.myToCall,#item.myToCall + 1,{CallBack = enums.Callbacks.PRE_GAME_STARTED, params = nil,
	Function = function(_,continue)
		if continue then else save.elses[item.own_key.."door_record"] = {} end
		save.elses[item.own_key.."door_record"] = save.elses[item.own_key.."door_record"] or {}
	end,
	})

	table.insert(item.ToCall,#item.ToCall + 1,{CallBack = ModCallbacks.MC_POST_NEW_ROOM, params = nil,
	Function = function(_)
		local didx = auxi.get_acceptible_index()
		if (save.elses[item.own_key.."door_record"] or {})[didx] then
			for u,v in pairs(save.elses[item.own_key.."door_record"][didx]) do
				local q = Isaac.Spawn(1000,enums.Entities.Heaven_Door_Misc,0,auxi.ProtectVector(v.pos),Vector(0,0),nil):ToEffect()
			end
		end
	end,
	})

	table.insert(item.ToCall,#item.ToCall + 1,{CallBack = ModCallbacks.MC_POST_EFFECT_INIT, params = enums.Entities.Heaven_Door_Misc,
	Function = function(_,ent)
		local s = ent:GetSprite()
		s:Play("Appear",true)		
	end,
	})
	
	table.insert(item.ToCall,#item.ToCall + 1,{CallBack = ModCallbacks.MC_POST_EFFECT_UPDATE, params = enums.Entities.Heaven_Door_Misc,
	Function = function(_,ent)
		ent.Velocity = Vector(0,0)
		local d = ent:GetData() local s = ent:GetSprite() local anim = s:GetAnimation()
		if not Game():GetRoom():IsClear() and anim == "Appear" then s:Play("Disappear",true) end
		if Game():GetRoom():IsClear() and anim == "Disappear" then s:Play("Appear",true) end
		if anim == "Appear" and s:IsFinished(anim) then
			d[grid_trapdoor.own_key.."effect"] = d[grid_trapdoor.own_key.."effect"] or {pos = ent.Position,}
			ent.Position = d[grid_trapdoor.own_key.."effect"].pos or ent.Position
			if auxi.check_all_exists(d[grid_trapdoor.own_key.."effect"].catcher) then else
				local room = Game():GetRoom()
				local gidx = room:GetGridIndex(ent.Position)
				for playerNum = 1, Game():GetNumPlayers() do
					local player = Game():GetPlayer(playerNum - 1)
					if room:GetGridIndex(player.Position) == gidx and player:IsExtraAnimationFinished() then
						d[grid_trapdoor.own_key.."effect"].catcher = player
						player:GetData()[grid_trapdoor.own_key.."effect"] = {linker = ent,anim = "LightTravel",check_trip = function(player,s)
							if player:IsExtraAnimationFinished() or (s:GetAnimation() ~= "LightTravel") or (s:GetFrame() >= 34) then return true
							else return false end
						end,on_finish = function(player)
							StageAPI.GotoCustomStage(StageAPI.CustomStages["Eden"], true)
						end,}
					end
				end
			end
		end
	end,
	})

	--l local auxi = require("EdenAndNether_Extra_scripts.auxiliary.functions") local tgs = auxi.getothers(nil,1000,39) for u,v in pairs(tgs) do v:Remove() end
	--item.NetherGrid:SetDecorations("gfx/backdrops/Nether_props.png", "gfx/grid/props_05_depths.anm2", 43)
	--item.NetherGrid:SetRocks("gfx/secret/shhhhh/nothing to see here/Netheroratory_Rocks.png")
	--item.NetherGrid:SetPits("gfx/grid/grid_pit_mines_cursed.png",nil,false)
	item.NetherGrid:SetPits("gfx/grid/grid_pit_ashpit.png",{{File = "gfx/grid/grid_pit_ashpit_.png"}},false)
	if REPENTOGON then
		item.NetherWalls[1].WallAnm2 = "gfx/backdrops/WallBackdrop_Cover.anm2"
	end
	item.NetherBackdrop = StageAPI.RoomGfx(item.NetherWalls, item.NetherGrid, "_default", "stageapi/shading/shading")
	item.NetherBackdrop.EAN_ID = "Nether"

	item.NetherRooms = {
		RoomFiles = {
			--"theNether"
		}
	}

	item.NetherRoomlist = {}

	for _, roomName in ipairs(item.NetherRooms.RoomFiles) do
		item.NetherRooms.RoomFiles[roomName] = require("resources.luarooms." .. roomName)
		item.NetherRoomlist[#item.NetherRoomlist + 1] = item.NetherRooms.RoomFiles[roomName]
	end

	local NetherRoomsReal = StageAPI.RoomsList("Rooms", table.unpack(item.NetherRoomlist))

	item.TheNether = StageAPI.CustomStage("Nether")
	item.TheNether:SetName("Nether")
	item.TheNether.DisplayName = "Nether"
	item.TheNether:SetPregenerationEnabled(true)
	--if Options.Language == "zh" then item.TheNether.DisplayName = "下界" end
	item.TheNether:SetRoomGfx(item.NetherBackdrop, {RoomType.ROOM_BOSS,RoomType.ROOM_DEFAULT, RoomType.ROOM_TREASURE, RoomType.ROOM_MINIBOSS})
	--item.TheNether:SetRooms(NetherRoomsReal)
	item.TheNether:SetRooms({}, RoomType.ROOM_DEFAULT)
	item.TheNether.GenerateLevel = StageAPI.GenerateBaseLevel
	--item.TheNether:SetMusic(Isaac.GetMusicIdByName("NetherTheme"), {RoomType.ROOM_DEFAULT})
	item.TheNether:SetReplace({
		OverrideStage = LevelStage.STAGE5,
		OverrideStageType = StageType.STAGETYPE_ORIGINAL
	})

	function item.decide_with_id(id)
		if REPENTOGON then
			if id == "Base" then
				local fx = Game():GetRoom():GetFXParams()
				fx.LightColor = KColor(0,1,0,1)
				fx.ShadowColor = KColor(0,1,0,1)
				fx.ShadowAlpha = 0.5
			elseif id == "Fall" then
				local fx = Game():GetRoom():GetFXParams()
				fx.LightColor = KColor(1,1,0,1)
				fx.ShadowColor = KColor(1,1,0,1)
				fx.ShadowAlpha = 0.5
			elseif id == "Nether" then
				local fx = Game():GetRoom():GetFXParams()
				fx.LightColor = KColor(1,0,0,1)
				fx.ShadowColor = KColor(1,0,0,1)
				fx.ShadowAlpha = 0.5
			end
		end
	end

	
	StageAPI.AddCallback("EdenAndNether", "POST_CHANGE_ROOM_GFX", 1, function(currentRoom, usingGfx, onRoomLoad)
		if usingGfx and usingGfx.EAN_ID then
			item.decide_with_id(usingGfx.EAN_ID)
		end
	end)
--[[
	StageAPI.ChangeRoomGfx = function(roomgfx)
		local shared = require("scripts.stageapi.shared")
		local INNER_ID = ""
		StageAPI.BackdropRNG:SetSeed(shared.Room:GetDecorationSeed(), 0)
		if roomgfx.Backdrops then
			if type(roomgfx.Backdrops) ~= "number" and #roomgfx.Backdrops > 0 then
				local backdrop = StageAPI.Random(1, #roomgfx.Backdrops, StageAPI.BackdropRNG)
				local tgbackdrop = roomgfx.Backdrops[backdrop]
				--auxi.PrintTable(tgbackdrop)
				INNER_ID = tgbackdrop.ID
				StageAPI.ChangeBackdrop(tgbackdrop)
			else
				StageAPI.ChangeBackdrop(roomgfx.Backdrops)
			end
		end
	
		if roomgfx.Grids then
			StageAPI.ChangeGrids(roomgfx.Grids)
		end

		item.decide_with_id(INNER_ID)
	end
	]]

	if REPENTOGON then
		function item.UpdateOverlay(currentRoom, usingGfx, onRoomLoad, currentDimension)
			local succ = false
			if item.TheNether:IsStage() then
				if Options.Language == "zh" then
					Game():GetLevel():SetName("下界")
				else 
					Game():GetLevel():SetName("Nether")
				end
				succ = true
			end
			if item.TheEden:IsStage() then
				if Options.Language == "zh" then
					Game():GetLevel():SetName("伊甸园")
				else 
					Game():GetLevel():SetName("Eden")
				end
				succ = true
				local roomConfigStage = RoomConfig.GetStage(StbType.CATHEDRAL)
				roomConfigStage:SetMusic(enums.Musics.Eden)
				item.Eden_music_seted = true
			else 
				if item.Eden_music_seted then
					local roomConfigStage = RoomConfig.GetStage(StbType.CATHEDRAL)
					roomConfigStage:SetMusic(Music.MUSIC_CATHEDRAL)
				end
			end
			if succ then
				item.Name_Seted = true
			elseif item.Name_Seted then
				Game():GetLevel():SetName("")
			end
		end
		
		StageAPI.AddCallback("EdenAndNether", StageAPI.Enum.Callbacks.POST_CHANGE_ROOM_GFX, 0, item.UpdateOverlay)
		StageAPI.AddCallback("EdenAndNether", StageAPI.Enum.Callbacks.PRE_STAGEAPI_NEW_ROOM, 0, item.UpdateOverlay)

		item.ShapeTosuffix = {
			[RoomShape.ROOMSHAPE_IV] = "_iv",
			[RoomShape.ROOMSHAPE_1x2] = "_1x2",
			[RoomShape.ROOMSHAPE_2x2] = "_2x2",
			[RoomShape.ROOMSHAPE_IH] = "_ih",
			[RoomShape.ROOMSHAPE_LTR] = "_ltr",
			[RoomShape.ROOMSHAPE_LTL] = "_ltl",
			[RoomShape.ROOMSHAPE_2x1] = "_2x1",
			[RoomShape.ROOMSHAPE_1x1] = "",
			[RoomShape.ROOMSHAPE_LBL] = "_lbl",
			[RoomShape.ROOMSHAPE_LBR] = "_lbr",
			[RoomShape.ROOMSHAPE_IIH] = "_iih",
			[RoomShape.ROOMSHAPE_IIV] = "_iiv"
		}
		
		--通过复写StageAPI的函数注入shader
		StageAPI.LoadBackdropSprite = function(sprite, backdrop, mode) -- modes are 1 (walls A), 2 (floors), 3 (walls B)
			local shared = require("scripts.stageapi.shared")
			local Callbacks = require("scripts.stageapi.enums.Callbacks")
			sprite = sprite or Sprite()
		
			local needsExtra
			local usedData = {}
			local roomShape = shared.Room:GetRoomShape()
			local shapeName = StageAPI.ShapeToName[roomShape]
			if StageAPI.ShapeToWallAnm2Layers[shapeName .. "X"] then
				needsExtra = true
			end
		
			if mode == 3 then
				shapeName = shapeName .. "X"
			end
		
			if backdrop.PreLoadFunc then
				local ret = backdrop.PreLoadFunc(sprite, backdrop, mode, shapeName)
				if ret then
					mode = ret
				end
			end
		
			if mode == 1 or mode == 3 then
				sprite:Load(backdrop.WallAnm2 or "stageapi/WallBackdrop.anm2", false)
				if backdrop.PreWallSheetFunc then
					backdrop.PreWallSheetFunc(sprite, backdrop, mode, shapeName)
				end
				
				local corners
				local walls
				if backdrop.WallVariants then
					walls = backdrop.WallVariants[StageAPI.Random(1, #backdrop.WallVariants, StageAPI.BackdropRNG)]
					corners = walls.Corners or backdrop.Corners
				else
					walls = backdrop.Walls
					corners = backdrop.Corners
				end
		
				if walls then
					for num = 1, StageAPI.ShapeToWallAnm2Layers[shapeName] do
						local wall_to_use = walls[StageAPI.Random(1, #walls, StageAPI.BackdropRNG)]
						sprite:ReplaceSpritesheet(num, wall_to_use)
						usedData[num] = wall_to_use
					end
				end
		
				if corners and string.sub(shapeName, 1, 1) == "L" then
					local corner_to_use = corners[StageAPI.Random(1, #corners, StageAPI.BackdropRNG)]
					sprite:ReplaceSpritesheet(0, corner_to_use)
				end
		
				
				if backdrop.WallAnm2 == "gfx/backdrops/WallBackdrop_Cover.anm2" then
					sprite:ReplaceSpritesheet(62, "gfx/backdrops/anti/shading"..item.ShapeTosuffix[roomShape]..".png")
					local layer = sprite:GetLayer(62)
					layer:SetCustomShader("shaders/anti_shader")
					
					local blendMode = layer:GetBlendMode() 
					blendMode.Flag1 = 0
					blendMode.Flag2 = 6
					blendMode.Flag3 = 0
					blendMode.Flag4 = 1
					for i = 0, 63 do
						local layer = sprite:GetLayer(i)
						if layer and i ~= 62 then
							layer:SetCustomShader("shaders/augmentative_shader")
						end
					end
				end
			elseif mode == 2 then
				sprite:Load(backdrop.FloorAnm2 or "stageapi/FloorBackdrop.anm2", false)
		
				if backdrop.PreFloorSheetFunc then
					backdrop.PreFloorSheetFunc(sprite, backdrop, mode, shapeName)
				end
		
				local floors
				if backdrop.FloorVariants then
					floors = backdrop.FloorVariants[StageAPI.Random(1, #backdrop.FloorVariants, StageAPI.BackdropRNG)]
				else
					floors = backdrop.Floors or backdrop.Walls
				end
		
				if floors then
					local numFloors
					if roomShape == RoomShape.ROOMSHAPE_1x1 then
						numFloors = 4
					elseif roomShape == RoomShape.ROOMSHAPE_1x2 or roomShape == RoomShape.ROOMSHAPE_2x1 then
						numFloors = 8
					elseif roomShape == RoomShape.ROOMSHAPE_2x2 then
						numFloors = 16
					end
		
					if numFloors then
						for i = 0, numFloors - 1 do
							sprite:ReplaceSpritesheet(i, floors[StageAPI.Random(1, #floors, StageAPI.BackdropRNG)])
						end
					end
				end
		
				if backdrop.NFloors and string.sub(shapeName, 1, 1) == "I" then
					for num = 18, 19 do
						sprite:ReplaceSpritesheet(num, backdrop.NFloors[StageAPI.Random(1, #backdrop.NFloors, StageAPI.BackdropRNG)])
					end
				end
		
				if backdrop.LFloors and string.sub(shapeName, 1, 1) == "L" then
					for num = 16, 17 do
						sprite:ReplaceSpritesheet(num, backdrop.LFloors[StageAPI.Random(1, #backdrop.LFloors, StageAPI.BackdropRNG)])
					end
				end
			end
		
			sprite:LoadGraphics()
		
			local renderPos = shared.Room:GetTopLeftPos()
			if mode ~= 2 then
				renderPos = renderPos - Vector(80, 80)
			end
		
			sprite:Play(shapeName, true)
		
			if mode ~= 2 then
				StageAPI.CallCallbacks(Callbacks.POST_SELECT_BACKDROP_WALL, nil, sprite, backdrop, usedData)
			end
			
			return renderPos, needsExtra, sprite
		end
	end

	
	StageAPI.AddCallback("EdenAndNether", "EARLY_NEW_ROOM", -5, function()
		if item.should_load then
			item.should_load = nil
			if item.StageAPI_SAVE_STRING then
				--print(item.StageAPI_SAVE_STRING)
				StageAPI.LoadSaveString(item.StageAPI_SAVE_STRING)
				StageAPI.SaveModData()
			end
			for u,v in pairs(item.StageAPI_SAVE_INIT) do
				if StageAPI.LevelRooms[u] then
					for uu,vv in pairs(StageAPI.LevelRooms[u]) do
						if v[uu] == nil then StageAPI.LevelRooms[u][uu] = nil 
						else 
							for i,_ in pairs(item.STAGE_API_LOADED) do
								if v[uu][i] ~= nil then StageAPI.LevelRooms[u][uu][i] = v[uu][i] end
							end
						end
					end
				end
			end
		end
		local should_save = true
		local level = Game():GetLevel()
		if level:GetStage() == LevelStage.STAGE1_2 and (level:GetStageType() == StageType.STAGETYPE_REPENTANCE or level:GetStageType() == StageType.STAGETYPE_REPENTANCE_B) then
			local desc = level:GetCurrentRoomDesc()
			if desc.Data.Type == RoomType.ROOM_DEFAULT and desc.Data.Variant >= 10000 and desc.Data.Variant <= 10500 then		--镜子房间，不进行存储。
				should_save = false
			end
		end
		if should_save then
			item.StageAPI_SAVE_STRING = StageAPI.GetSaveString()
			local tbl = {}
			for u,v in pairs(StageAPI.LevelRooms) do
				tbl[u] = {}
				for uu,vv in pairs(v) do
					tbl[u][uu] = {}
					for i,_ in pairs(item.STAGE_API_LOADED) do
						tbl[u][uu][i] = vv[i]
					end
				end
			end
			item.StageAPI_SAVE_INIT = tbl
		end
	end)

	table.insert(item.ToCall,#item.ToCall + 1,{CallBack = ModCallbacks.MC_USE_ITEM, params = CollectibleType.COLLECTIBLE_GLOWING_HOUR_GLASS,
	Function = function(_, colid, rng, player, flags, slot, data)
		item.should_load = true
	end,
	})

	function item.deal_with_unlock()
		save.UnlockData[item.own_key.."EdenUnlocked"] = true
		if Options.Language == "zh" then
			Achievement_Display_holder.PlayAchievement("gfx/ui/achievement/holier_cn.png")
		else
			Achievement_Display_holder.PlayAchievement("gfx/ui/achievement/holier.png")
		end
		if REPENTOGON then
			Isaac.GetPersistentGameData():TryUnlock(enums.Achievements.EdenUnlock,true)
		end
	end

	function item.deal_with_lock()
		save.UnlockData[item.own_key.."EdenUnlocked"] = nil
		if REPENTOGON then
			Isaac.ExecuteCommand("lockachievement "..tostring(enums.Achievements.EdenUnlock))
		end
	end
	
	table.insert(item.ToCall,#item.ToCall + 1,{CallBack = ModCallbacks.MC_POST_UPDATE, params = nil,
	Function = function()
		if save.UnlockData[item.own_key.."EdenUnlocked"] or (not auxi.is_normal_game()) then return end
		local room = Game():GetRoom()
		local level = Game():GetLevel()
		local desc = level:GetCurrentRoomDesc()
		local difficulty = Game().Difficulty
		if difficulty <= Difficulty.DIFFICULTY_HARD and room:GetType() == RoomType.ROOM_BOSS then
			if room:IsClear() and desc.SafeGridIndex > 0 then
				local stageType = level:GetStageType()
				local stage = level:GetStage()
				if stage == LevelStage.STAGE5 and stageType == StageType.STAGETYPE_WOTL then
					local time = Game().TimeCounter
					if time < 40 * 60 * 30 then 
						item.deal_with_unlock()
					end
				end
			end
		end
	end,
	})

	
	table.insert(item.ToCall,#item.ToCall + 1,{CallBack = ModCallbacks.MC_EXECUTE_CMD, params = nil,
	Function = function(_,cmd,params)
		if string.lower(cmd) == "exodus" and params ~= nil then
			local args={}
			for str in string.gmatch(params, "([^ ]+)") do
				table.insert(args, str)
			end
			if args[1] and args[1] == "unlock" then
				if args[2] and args[2] == "eden" then
					item.deal_with_unlock()
					print("Successfully set unlock")
				end
			end
			if args[1] and args[1] == "eden" then
				if args[2] and args[2] == "chance" then
					local val = 0.5
					if args[3] then val = tonumber(args[3]) or val end
					val = math.max(0,math.min(1,val))
					print("Set to "..tostring(val).." (Clamp to 0-1), default value is 0.5.")
					save.UnlockData[item.own_key.."EdenChance"] = val
				end
			end
			if args[1] and args[1] == "lock" then
				if args[2] and args[2] == "eden" then
					item.deal_with_lock()
					print("Successfully set locked")
				end
			end
		end
	end,
	})	
end

if REPENTOGON and Options.Language == "zh" then		--标题替换
	table.insert(item.ToCall,#item.ToCall + 1,{CallBack = ModCallbacks.MC_MAIN_MENU_RENDER, params = nil,
	Function = function(_)
		local s = TitleMenu.GetSprite()
		if s then 
			s:ReplaceSpritesheet(2,"gfx/ui/main menu/logo_cn.png")
			s:ReplaceSpritesheet(3,"gfx/ui/main menu/logo_cn.png")
			s:LoadGraphics()
		end

	end,
	})
end


if REPENTOGON then		--成就替换
	item.Locked_data = {
		en = {
		},
		zh = {
		},
	}
	item.reverse_locked_datamap = {}
	for u,v in pairs(enums.Achievements) do 
		local data = XMLData.GetEntryById(XMLNode.ACHIEVEMENT,v)
		if data then
			local en_name = "gfx/ui/achievement/"..data.gfx
			local zh_name = "gfx/ui/achievement/"..data.gfx:gsub("%.png$", "_cn.png")
			item.Locked_data.en[v] = en_name
			item.Locked_data.zh[v] = zh_name
			item.reverse_locked_datamap[en_name] = v
			item.reverse_locked_datamap[zh_name] = v
			item.reverse_locked_datamap[data.gfx] = v
			item.reverse_locked_datamap["gfx/ui/achievement/"..data.gfx] = v
		end
	end
	table.insert(item.ToCall,#item.ToCall + 1,{CallBack = ModCallbacks.MC_MAIN_MENU_RENDER, params = nil,
	Function = function(_)
		local s = StatsMenu.GetSecretsMenuSprite() 
		if s then
			local s3 = s:GetLayer(3) local s3path = s3:GetSpritesheetPath() 
			if item.reverse_locked_datamap[s3path] then
				local language = "en" if Options.Language == "zh" then language = "zh" end
				local tg = item.Locked_data[language][item.reverse_locked_datamap[s3path]] or s3path
				local anim = s:GetAnimation() local frame = s:GetFrame() s:Load("gfx/ui/achievement display api/achievements.anm2",true) s:ReplaceSpritesheet(3,tg) s:ReplaceSpritesheet(2,"gfx/ui/achievement/paper_.png") s:LoadGraphics() s:Play(anim,true) s:SetFrame(frame)
				item.seted_locked_data = true
			elseif item.seted_locked_data and s:GetFilename() ~= "gfx/ui/achievement/achievements.anm2" then
				local s3 = s:GetLayer(3) local s3path = s3:GetSpritesheetPath() local frame = s:GetFrame() 
				local anim = s:GetAnimation() s:Load("gfx/ui/achievement/achievements.anm2",true)
				s:ReplaceSpritesheet(3,s3path) s:LoadGraphics() s:Play(anim,true) s:SetFrame(frame)
			end
		end
	end,
	})
	
	local s1 = Sprite() s1:Load("gfx/ui/main menu/Extra_content.anm2",true) s1:Play("Idle",true)
	table.insert(item.ToCall,#item.ToCall + 1,{CallBack = ModCallbacks.MC_MAIN_MENU_RENDER, params = nil,
	Function = function(_)
		--print(MenuManager.GetViewPosition())
		if save.UnlockData[item.own_key.."EdenUnlocked"] then
			local pos1 = MenuManager.GetViewPosition()
			local s = TitleMenu.GetSprite()
			local pos = pos1 + Vector(86 * s.Scale.X,166 * s.Scale.Y)
			--local sz = auxi.GetScreenSize() local pos = Vector(86/480 * sz.X,166/272 * sz.Y)
			s1:Render(pos)
		end
	end,
	})

end

return item