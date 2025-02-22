local g = require("EdenAndNether_Extra_scripts.core.globals")
local save = require("EdenAndNether_Extra_scripts.core.savedata")
local enums = require("EdenAndNether_Extra_scripts.core.enums")
local auxi = require("EdenAndNether_Extra_scripts.auxiliary.functions")
local Damage_holder = require("EdenAndNether_Extra_scripts.others.Damage_holder")
local sound_tracker = require("EdenAndNether_Extra_scripts.auxiliary.sound_tracker")
local delay_buffer = require("EdenAndNether_Extra_scripts.auxiliary.delay_buffer")
local Base_holder = require("EdenAndNether_Extra_scripts.others.Base_holder")

local item = {
	ToCall = {},
    own_key = "EAN_Losy_",
    entity = enums.Enemies.Losy,
    bulletBehavior = {
        {frame = 0, speed = 1,},  -- 初始状态
        {frame = 10, speed = 1,}, -- 飞行10帧后开始减速
        {frame = 20, speed = -1,} -- 反向加速至原速度
    }
}

table.insert(item.ToCall,#item.ToCall + 1,{CallBack = ModCallbacks.MC_POST_NPC_INIT, params = 227,
Function = function(_,ent)
    if StageAPI then
        if Base_holder.TheEden:IsStage() and ent.Variant ~= item.entity then
            if ent:IsChampion() then ent:Morph(227,item.entity,0,ent:GetChampionColorIdx())
            else ent:Morph(227,item.entity,0,-1) end
        end
    end
    if ent.Variant == item.entity then
        local s = ent:GetSprite()
        local d = ent:GetData()
        local anim = s:GetAnimation()
        --s:Play("Idle",true)
        --ent.PositionOffset = Vector(0,-3)
    end
end,
})

function item.make_behavior(frame)
    return {
        {frame = 0, speed = 1,},  -- 初始状态
        {frame = frame, speed = 1,}, -- 飞行10帧后开始减速
        {frame = frame + 10, speed = -1,} -- 反向加速至原速度
    }
end

table.insert(item.ToCall,#item.ToCall + 1,{CallBack = ModCallbacks.MC_POST_PROJECTILE_UPDATE, params = nil,
Function = function(_,ent)
	local d = ent:GetData()
    if ent.FrameCount == 1 and ent.SpawnerEntity and ent.SpawnerEntity.Type == 227 and ent.SpawnerEntity.Variant == item.entity then
        local target = auxi.get_acceptible_player_target(ent)
        if target then
            d[item.own_key.."effect"] = {speed = auxi.Vector2Table(ent.Velocity),behavior = item.make_behavior(auxi.choose(10,15,18,20)),}--auxi.Vector2Table((auxi.Flip2XorY(target.Position - ent.Position)):Normalized()),}
            ent.FallingAccel = -0.05
        end
    end
    if d[item.own_key.."effect"] then
        -- 使用check_lerp计算当前速度和方向
        local behavior = auxi.check_lerp(ent.FrameCount, d[item.own_key.."effect"].behavior or item.bulletBehavior)
        local currentSpeed = behavior.speed * auxi.ProtectVector(d[item.own_key.."effect"].speed)

        -- 更新子弹速度
        ent.Velocity = currentSpeed
    end
end,
})
--l local q = Isaac.Spawn(9,0,0,Vector(200,200),Vector(10,0),nil):ToProjectile() q:AddProjectileFlags(1<<32 | 1<<33 | 1<<28) q.ChangeFlags = 1<<27 q.ChangeTimeout = 15 q.FallingAccel = 0 q.ChangeVelocity = 0.1
return item