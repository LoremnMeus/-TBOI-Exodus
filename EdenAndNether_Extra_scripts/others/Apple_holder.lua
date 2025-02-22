local g = require("EdenAndNether_Extra_scripts.core.globals")
local save = require("EdenAndNether_Extra_scripts.core.savedata")
local enums = require("EdenAndNether_Extra_scripts.core.enums")
local auxi = require("EdenAndNether_Extra_scripts.auxiliary.functions")
local Base_holder = require("EdenAndNether_Extra_scripts.others.Base_holder")
local sound_tracker = require("EdenAndNether_Extra_scripts.auxiliary.sound_tracker")

local item = {
	ToCall = {},
	myToCall = {},
	own_key = "EAN_Apple_holder_",
	entity = enums.Pickups.Apple,
	val2chance = {
		[1] = 1/4,
		[2] = 1/2,
		[3] = 3/4,
	},
	buffs = {
		[1] = {name = "speed",cache = CacheFlag.CACHE_SPEED,
			toget = function(player) return player.MoveSpeed end,mul = 0.05,},
		[2] = {name = "tear",cache = CacheFlag.CACHE_FIREDELAY,
			toget = function(player) return 30 / (player.MaxFireDelay + 1) end,mul = 0.25,},
		[3] = {name = "damage",cache = CacheFlag.CACHE_DAMAGE,
			toget = function(player) return player.Damage end,mul = 0.5,},
		[4] = {name = "range",cache = CacheFlag.CACHE_RANGE,
			toget = function(player) return player.TearRange end,mul = 1 * 40,},
		[5] = {name = "luck",cache = CacheFlag.CACHE_LUCK,
			toget = function(player) return player.Luck end,mul = 1,},
	},
	buff2icon = {
		[-3] = "c_1.png",
		[3] = "c_2.png",
		[-4] = "c_3.png",
		[4] = "c_4.png",
		[-2] = "c_5.png",
		[2] = "c_6.png",
		[-1] = "c_7.png",
		[1] = "c_8.png",
		[-5] = "c_9.png",
		[5] = "c_10.png",
	},
	cache2buffid = {
		[CacheFlag.CACHE_SPEED] = 1,
		[CacheFlag.CACHE_FIREDELAY] = 2,  -- 添加tear
		[CacheFlag.CACHE_DAMAGE] = 3,     -- 添加damage
		[CacheFlag.CACHE_RANGE] = 4,      -- 添加range
		[CacheFlag.CACHE_LUCK] = 5        -- 添加luck
	},
	vel2chance = {
		{frame = 0,chance = 0,},
		{frame = 1,chance = 0.2,},
		{frame = 5,chance = 1,},
	},
	weilist = {
		{id = 1,weigh = 10,},
		{id = 2,weigh = 10,},
		{id = 3,weigh = 10,},
		{id = 4,weigh = 2,},
		{id = 5,weigh = 6,},
		{id = 9,weigh = 8,},
		{id = 10,weigh = 6,},
	},
}

table.insert(item.ToCall,#item.ToCall + 1,{CallBack = ModCallbacks.MC_POST_PICKUP_INIT, params = item.entity,
Function = function(_,ent)
	local d = ent:GetData()
	local s = ent:GetSprite()
	if ent.SubType == 0 then 
		local rng = ent:GetDropRNG()
		ent.SubType = auxi.random_in_weighed_table(item.weilist,rng).id
	end
	local str = "gfx/effects/apple_"..tostring(ent.SubType)..".png"
	if ent.SubType == 4 then str = "gfx/effects/dragon.png" end
	if ent.SubType == 9 then str = "gfx/effects/breadfruit.png" end
	if ent.SubType == 10 then str = "gfx/effects/kiwi.png" end
	if ent.SubType >= 5 and ent.SubType <= 8 then str = "gfx/effects/watermelon_"..tostring(ent.SubType - 4)..".png" end
	s:ReplaceSpritesheet(0,str) s:ReplaceSpritesheet(1,str) s:LoadGraphics()
	if Game():GetRoom():GetFrameCount() < 0 then s:Play("Idle",true)
	else s:Play("Appear",true) end
	ent.PositionOffset = Vector(0,-5)
end,
})

function item.init_buffs(ent)
	local d = ent:GetData()
	if d[item.own_key.."buff"] == nil then 
		local chance = item.val2chance[ent.SubType] or 1/2
		rng = auxi.seed_rng(ent.InitSeed)
		if chance > rng:RandomFloat() then d[item.own_key.."buff"] = 1
		else d[item.own_key.."buff"] = -1 end
	end
end

table.insert(item.ToCall,#item.ToCall + 1,{CallBack = ModCallbacks.MC_POST_PICKUP_UPDATE, params = item.entity,
Function = function(_,ent)
	local d = ent:GetData()
	local s = ent:GetSprite()
	local anim = s:GetAnimation()
	if anim == "Appear" and s:WasEventTriggered("DropSound") == false then ent.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
	else ent.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL end
	if s:IsEventTriggered("DropSound") then
		sound_tracker.PlayStackedSound(SoundEffect.SOUND_MEAT_FEET_SLOW0,1,1,false,0,2)
	end
	item.init_buffs(ent)
	local bgchance = auxi.check_lerp(ent.Velocity:Length(),item.vel2chance).chance
	if auxi.random_1() < bgchance then
		local q = Isaac.Spawn(EntityType.ENTITY_EFFECT,EffectVariant.EMBER_PARTICLE,0,ent.Position + auxi.random_r() * auxi.random_1() * 10,auxi.get_by_rotate(ent.Velocity,-180 + auxi.random_1() * 60,ent.Velocity:Length() * 0.3),ent):ToEffect()
		--q.MinRadius = 0.15 q.MaxRadius = 0.15 q.Parent = ent 
		q.PositionOffset = Vector(0,0)
		if d[item.own_key.."buff"] < 0 then q.Color = Color(0,0,0,1)
		else q.Color = Color(1,0.5,0,1,1,0.5,0) end
		if ent.SubType == 4 then q.Color = Color(1,0,0,1) end
		if ent.SubType == 9 then q.Color = Color(1,0.6,0.3,1) end
		if ent.SubType == 10 then q.Color = Color(0,0.6,1,1) end
		local qs = q:GetSprite() qs:Play("Idle2",true)
	end
	ent.Velocity = auxi.apply_friction(ent.Velocity,1)
	if s:IsFinished("Appear") then 
		s:Play("Idle",true)
	end
end,
})

function item.add_random_buff(player,val)
	local d = player:GetData()
	local idx = d.__Index
	save.elses[item.own_key.."buffs"] = save.elses[item.own_key.."buffs"] or {}
	save.elses[item.own_key.."buffs"][idx] = save.elses[item.own_key.."buffs"][idx] or {}
	local rng = player:GetCollectibleRNG(33)
	local rnd = auxi.random_in_table({1,2,3,4,5},rng)
	save.elses[item.own_key.."buffs"][idx][rnd] = (save.elses[item.own_key.."buffs"][idx][rnd] or 0) + val
	player:AddCacheFlags(item.buffs[rnd].cache)
	player:EvaluateItems()
	if val > 0 then player:AnimateHappy()
	else player:AnimateSad() end
	local crnd = rnd * auxi.get_id(val)
	local cstr = "gfx/effects/"..item.buff2icon[crnd]
	local q = Isaac.Spawn(1000,49,0,player.Position,Vector(0,0),player):ToEffect() 
	local qs = q:GetSprite() qs:Load("gfx/Apple_buffs.anm2",true)
	qs:ReplaceSpritesheet(0,cstr) qs:LoadGraphics() qs:Play("Appear",true)
	local qd = q:GetData() qd[item.own_key.."effect"] = {linker = player,}
	d[item.own_key.."linker"] = q
end

table.insert(item.ToCall,#item.ToCall + 1,{CallBack = ModCallbacks.MC_POST_EFFECT_UPDATE, params = 49,
Function = function(_,ent)
	local d = ent:GetData() local s = ent:GetSprite()
	if d[item.own_key.."effect"] then
		if auxi.check_all_exists(d[item.own_key.."effect"].linker) then  
			ent.Position = d[item.own_key.."effect"].linker.Position
			ent.PositionOffset = d[item.own_key.."effect"].linker.PositionOffset + Vector(0,-60) * d[item.own_key.."effect"].linker.SpriteScale.Y
		end
		if s:IsFinished("Appear") then ent:Remove() end
	end
end,
})

table.insert(item.ToCall,#item.ToCall + 1,{CallBack = ModCallbacks.MC_POST_PLAYER_UPDATE, params = nil,
Function = function(_,player)
	local d = player:GetData()
	if d[item.own_key.."effect"] then
		d[item.own_key.."effect"].counter = (d[item.own_key.."effect"].counter or 0) - 1
		if d[item.own_key.."effect"].counter < 0 or player:IsExtraAnimationFinished() then
			if d[item.own_key.."effect"].id == 4 then
				local q = player:AddWisp(556,player.Position,true)
				player:AnimateHappy()
			elseif d[item.own_key.."effect"].id <= 3 then
				item.add_random_buff(player,d[item.own_key.."effect"].val)
			elseif d[item.own_key.."effect"].id <= 8 then
				item.add_random_buff(player,d[item.own_key.."effect"].val)
				if d[item.own_key.."effect"].id < 8 then
					local stid = d[item.own_key.."effect"].id + 1
					d[item.own_key.."eaten"] = {id = stid,counter = 30,buff = d[item.own_key.."effect"].val,seed = d[item.own_key.."effect"].seed}
				end
			elseif d[item.own_key.."effect"].id == 9 then
				local rnd = auxi.choose(2,3,4)
				for i = 1,rnd do
					local q = Isaac.Spawn(5,10,0,player.Position,auxi.MakeVector(i/rnd * 360) * 5,nil):ToPickup()
				end
				player:AnimateHappy()
			elseif d[item.own_key.."effect"].id == 10 then
				player:AnimateHappy()
				player:UseActiveItem(712, false, false, true, false)
			end
			d[item.own_key.."effect"] = nil
		end
	end
	if d[item.own_key.."eaten"] then
		d[item.own_key.."eaten"].counter = (d[item.own_key.."eaten"].counter or 0) - 1
		if d[item.own_key.."eaten"].counter < 0 or player:IsExtraAnimationFinished() then 
			local q = Game():Spawn(5,item.entity,player.Position,auxi.random_r() * 5,nil,d[item.own_key.."eaten"].id,d[item.own_key.."eaten"].seed)
			--Isaac.Spawn(5,item.entity,d[item.own_key.."eaten"].id,player.Position,auxi.random_r() * 5,nil):ToPickup()
			--q:GetData()[item.own_key.."buff"] = d[item.own_key.."eaten"].buff
			--q:GetSprite():Play("Idle",true)
			d[item.own_key.."eaten"] = nil
		end
	end
	if d[item.own_key.."linker"] then
		if auxi.check_all_exists(d[item.own_key.."linker"]) then d[item.own_key.."linker"].Position = player.Position
		else d[item.own_key.."linker"] = nil end
	end
end,
})

table.insert(item.ToCall,#item.ToCall + 1,{CallBack = ModCallbacks.MC_PRE_PICKUP_COLLISION, params = item.entity,
Function = function(_,ent,col,low)
	local player = col:ToPlayer()
	if player and player:IsExtraAnimationFinished() then
		local d = ent:GetData()
		item.init_buffs(ent)
		player:GetData()[item.own_key.."effect"] = {val = d[item.own_key.."buff"],counter = 30,id = ent.SubType,seed = ent.InitSeed,}
		ent.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
		player:AnimatePickup(ent:GetSprite())
		ent:Remove()
		--auxi.remove_others_option_pickup(ent)
	end
end,
})

table.insert(item.ToCall,#item.ToCall + 1,{CallBack = ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD, params = nil,
Function = function(_,rng,pos)
	local room = Game():GetRoom()
	if Base_holder.TheEden:IsStage() and rng:RandomFloat() > 0.5 and not room:GetType() == RoomType.ROOM_BOSS then
		local room = Game():GetRoom()
		local q = Isaac.Spawn(5,item.entity,0,room:FindFreePickupSpawnPosition(pos,10,true),Vector(0,0),nil)
	end
end,
})

table.insert(item.ToCall,#item.ToCall + 1,{CallBack = ModCallbacks.MC_EVALUATE_CACHE, params = nil,
Function = function(_,player,cacheFlag)
	local d = player:GetData()
	local idx = d.__Index
	save.elses[item.own_key.."buffs"] = save.elses[item.own_key.."buffs"] or {}
	if save.elses[item.own_key.."buffs"][idx] then
		local mul = save.elses[item.own_key.."buffs"][idx][item.cache2buffid[cacheFlag] or 0] or 0
		if cacheFlag == CacheFlag.CACHE_SPEED then
			player.MoveSpeed = player.MoveSpeed + mul * item.buffs[1].mul
		end
		if cacheFlag == CacheFlag.CACHE_FIREDELAY then
			player.MaxFireDelay = auxi.TearsUp(player.MaxFireDelay,auxi.get_mxdelay_multiplier(player) * mul * item.buffs[2].mul)
		end
		if cacheFlag == CacheFlag.CACHE_DAMAGE then
			player.Damage = player.Damage + auxi.get_damage_multiplier(player) * mul * item.buffs[3].mul
		end
		if cacheFlag == CacheFlag.CACHE_RANGE then
			player.TearRange = player.TearRange + mul * item.buffs[4].mul
		end
		if cacheFlag == CacheFlag.CACHE_LUCK then
			player.Luck = player.Luck + mul * item.buffs[5].mul
		end
	end
end,
})

table.insert(item.myToCall,#item.myToCall + 1,{CallBack = enums.Callbacks.PRE_GAME_STARTED, params = nil,
Function = function(_,continue)
	if continue then else save.elses[item.own_key.."buffs"] = {} end
	save.elses[item.own_key.."buffs"] = save.elses[item.own_key.."buffs"] or {}
end,
})

return item