local g = require("EdenAndNether_Extra_scripts.core.globals")
local save = require("EdenAndNether_Extra_scripts.core.savedata")
local enums = require("EdenAndNether_Extra_scripts.core.enums")
local auxi = require("EdenAndNether_Extra_scripts.auxiliary.functions")
local Damage_holder = require("EdenAndNether_Extra_scripts.others.Damage_holder")
local sound_tracker = require("EdenAndNether_Extra_scripts.auxiliary.sound_tracker")
local delay_buffer = require("EdenAndNether_Extra_scripts.auxiliary.delay_buffer")
local Base_holder = require("EdenAndNether_Extra_scripts.others.Base_holder")
local PathFinding = require("EdenAndNether_Extra_scripts.others.Path_Finding")

local item = {
	ToCall = {},
    own_key = "EAN_Sandstone_Globin_",
    entity = enums.Enemies.Sandstone_Globin,
	MoveDir = {
		[Direction.NO_DIRECTION] = "Hori",
		[Direction.LEFT] = "Hori",
		[Direction.UP] = "Vert",
		[Direction.RIGHT] = "Hori",
		[Direction.DOWN] = "Vert",
	},
    State2Hp = {
        [1] = {hp = 1,},
        [2] = {hp = 0.75,},
        [3] = {hp = 0.5,},
        [4] = {hp = 0.25,},
    },
}

table.insert(item.ToCall,#item.ToCall + 1,{CallBack = ModCallbacks.MC_POST_UPDATE, params = nil,
Function = function(_)
    --local Sfx = SFXManager() for i = 1,1000 do if Sfx:IsPlaying(i) then print(i) end end
end,
})

table.insert(item.ToCall,#item.ToCall + 1,{CallBack = ModCallbacks.MC_POST_NPC_INIT, params = 613,
Function = function(_,ent)
    if ent.Variant == item.entity then
        local s = ent:GetSprite()
        local d = ent:GetData()
        local anim = s:GetAnimation()
        if ent.SubType == 1 then
            s:Play(auxi.choose("Sandrock1","Sandrock2"),true)
        end
    end
end,
})


local function MoveToTarget(ent, moveTarget, maxCooldown, params)
	params = params or {}
    maxCooldown = maxCooldown or 40
	ent:GetData()["MOVE_DATA"] = ent:GetData()["MOVE_DATA"] or {}
    local data = ent:GetData()["MOVE_DATA"]
    local room = Game():GetRoom()
    local target = moveTarget;
    local canDirectlyWalk, newPos = room:CheckLine(ent.Position, target, 0);
    if (not canDirectlyWalk) then
        local targetIndex = room:GetGridIndex(target);
        -- Search Path.
        local currentIndex = room:GetGridIndex(ent.Position);
        if (data.Cooldown or maxCooldown <= 0) then
            data.Cooldown = maxCooldown;
            local nodes = PathFinding:FindPath(currentIndex, targetIndex,{
				PassCheck = function(index)
					return PathFinding:CanPass(index)
				end,
				MaxStartCost = -1,
				MaxCost = -1,
				bestmatch = true,
			});
            data.Nodes = nodes
            local node = nil;
            if (nodes) then
                local num = #nodes;
                for i = num - 2, num do
                    local index = nodes[i];
                    if (index) then
                        local gridEnt = room:GetGridEntity(index);
                        if (not gridEnt or gridEnt.CollisionClass == GridCollisionClass.COLLISION_NONE) then
                            node = index;
                            break;
                        end
                    end
                end
            end
            data.Node = node;
        end


        local cancelMove = false;
        if (data.Node and data.Node ~= room:GetGridIndex(ent.Position)) then
            target = room:GetGridPosition(data.Node);
        else
            -- Path is blocked.
            cancelMove = true;
        end

        if (cancelMove) then
            return false;
        end

    end

    local moveDir = (target - ent.Position):Normalized();
    local moveSpeed = math.min((target - ent.Position):Length(),params.speed or 6);
    if params.stepby then moveSpeed = math.min(moveSpeed,ent.Velocity:Length() + params.stepby) end
	moveSpeed = auxi.check_if_any(params.on_move,target - ent.Position,moveSpeed) or moveSpeed
    ent.Velocity = moveDir * moveSpeed;
    return true;
end

table.insert(item.ToCall,#item.ToCall + 1,{CallBack = ModCallbacks.MC_PRE_NPC_COLLISION, params = 613,
Function = function(_,ent,col,low)
    if ent.Variant == item.entity then
        if col.Type == 613 and col.Variant == item.entity and col.SubType == 1 and col.FrameCount > 30 then
            local d = ent:GetData() d[item.own_key.."state"] = d[item.own_key.."state"] or 1
            if ent.SubType == 0 and d[item.own_key.."state"] > 1 then
                ent.HitPoints = ent.HitPoints + 0.25 * ent.MaxHitPoints
                d[item.own_key.."state"] = d[item.own_key.."state"] - 1
                if d[item.own_key.."evade"] then
                    d[item.own_key.."evade"] = nil
                end
                local e = Isaac.Spawn(1000,59,0,ent.Position,Vector(0,0),nil):ToEffect() e.LifeSpan = 10 e.Timeout = 10 e.Color = Color(1,0.75,0.5)
                --local e = Isaac.Spawn(1000,15,0,ent.Position,Vector(0,0),ent):ToEffect()
                col:Remove()
                sound_tracker.PlayStackedSound(SoundEffect.SOUND_STONE_IMPACT,1,1,false,0,2)
                return
            end
            if ent.SubType == 1 and not auxi.check_all_exists(ent.SpawnerEntity) then
                if ent.InitSeed > col.InitSeed then
                    local q = Isaac.Spawn(613,item.entity,0,(ent.Position + col.Position) * 0.5,Vector(0,0),ent):ToNPC()
                    q:ClearEntityFlags(EntityFlag.FLAG_APPEAR) q.HitPoints = q.MaxHitPoints * 0.5 
                    local qd = q:GetData() qd[item.own_key.."state"] = 3 
                    local e = Isaac.Spawn(1000,59,0,q.Position,Vector(0,0),nil):ToEffect() e.LifeSpan = 10 e.Timeout = 10 e.Color = Color(1,0.75,0.5)
                    ent:Remove()
                    col:Remove()
                    q:Update()
                    sound_tracker.PlayStackedSound(SoundEffect.SOUND_STONE_IMPACT,1,1,false,0,2)
                    return
                end
            end
        end
    end
end,
})

table.insert(item.ToCall,#item.ToCall + 1,{CallBack = ModCallbacks.MC_NPC_UPDATE, params = 613,
Function = function(_,ent)
    if ent.Variant == item.entity then
        local s = ent:GetSprite()
        local d = ent:GetData()
        local anim = s:GetAnimation() local frame = s:GetFrame()
        if ent.SubType == 1 or d[item.own_key.."evade"] then
            if ent.FrameCount > 15 then
                if auxi.check_all_exists(ent.SpawnerEntity) then
                    local sd = ent.SpawnerEntity:GetData()
                    if sd[item.own_key.."evade"] then
                        MoveToTarget(ent,ent.SpawnerEntity.Position,-1,{speed = 4,stepby = 2,})
                    end
                else
                    local tgs = auxi.getothers(nil,613,item.entity) local tg = nil
                    for u,v in pairs(tgs) do if auxi.check_for_the_same(v,ent) ~= true then
                        if tg == nil or (tg.Position - ent.Position):Length() > (v.Position - ent.Position):Length() then
                            tg = v
                        end
                    end end
                    if tg then MoveToTarget(ent,tg.Position,-1,{speed = 4,stepby = 2,}) end
                end
            end
            ent.Velocity = auxi.apply_friction(ent.Velocity,1)
            return 
        end
        local tg = auxi.get_acceptible_target(ent)
        if auxi.check_all_exists(tg) then MoveToTarget(ent,tg.Position,-1,{speed = 7,stepby = 2,}) end
		ent.Velocity = auxi.apply_friction(ent.Velocity,1)
        
        local hprate = ent.HitPoints/ent.MaxHitPoints

        d[item.own_key.."state"] = d[item.own_key.."state"] or 1
        for i = d[item.own_key.."state"] + 1,4 do
            local dinfo = item.State2Hp[i]
            if dinfo.hp > hprate then
                d[item.own_key.."state"] = i
                local q = Isaac.Spawn(613,item.entity,1,ent.Position,auxi.random_r() * 3,ent):ToNPC() q.HitPoints = 6 q.MaxHitPoints = 6
                q:ClearEntityFlags(EntityFlag.FLAG_APPEAR) 
                local e = Isaac.Spawn(1000,59,0,q.Position,Vector(0,0),nil):ToEffect() e.LifeSpan = 10 e.Timeout = 10 e.Color = Color(1,0.75,0.5)
                --local e = Isaac.Spawn(1000,15,0,ent.Position,Vector(0,0),ent):ToEffect()
                d[item.own_key.."drop"] = 5
                sound_tracker.PlayStackedSound(SoundEffect.SOUND_ROCK_CRUMBLE,1,1,false,0,2)
                sound_tracker.PlayStackedSound(SoundEffect.SOUND_STONE_IMPACT,1,1,false,0,2)
            end
        end
        if ent.FrameCount % 3 == 1 and d[item.own_key.."drop"] then
            local e = Isaac.Spawn(1000,22,0,ent.Position,Vector(0,0),ent):ToEffect() local se = e:GetSprite()
            se:Load("gfx/effects/sand_power.anm2",true) se:Play("SmallBlood0"..auxi.choose("1","2","3","4","5","6"),true)
            d[item.own_key.."drop"] = d[item.own_key.."drop"] - 1
            if d[item.own_key.."drop"] <= 0 then d[item.own_key.."drop"] = nil end
        end
        local revive_state = d[item.own_key.."state"]

        local dir = ent.Velocity
		local dir_name = auxi.GetDirName(auxi.GetDirectionByAngle(ent.Velocity:GetAngleDegrees()),item.MoveDir)
        if ent.Velocity:Length() > 3 then 
            tanim = "Walk" .. dir_name .. tostring(revive_state)
            if tanim ~= anim then s:SetFrame(tanim,frame) s:Play(tanim,true) end 
        else
            dir = tg.Position - ent.Position
            dir_name = auxi.GetDirName(auxi.GetDirectionByAngle((tg.Position - ent.Position):GetAngleDegrees()),item.MoveDir)
            tanim = "Walk" .. dir_name .. tostring(revive_state)
            if tanim ~= anim then s:SetFrame(tanim,frame) s:Play(tanim,true) end 
        end
        if dir.X < -1 then s.FlipX = true 
        elseif dir.X > 1 then s.FlipX = false end
        if ent:HasMortalDamage() then
            ent.HitPoints = 6
            d[item.own_key.."evade"] = true
            s:Play("Sandrock1",true)
            sound_tracker.PlayStackedSound(SoundEffect.SOUND_ROCK_CRUMBLE,1,1,false,0,2)
        end
    end
end,
})

table.insert(item.ToCall,#item.ToCall + 1,{CallBack = ModCallbacks.MC_ENTITY_TAKE_DMG, params = 613,
Function = function(_,ent,amt,flag,source,cooldown)
    if ent.Variant == item.entity then
--        if auxi.choose(0,0,1) == 1 then
        sound_tracker.PlayStackedSound(SoundEffect.SOUND_STONE_IMPACT,1,1,false,0,2)
    end
end,
})

return item