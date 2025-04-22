local g = require("EdenAndNether_Extra_scripts.core.globals")
local save = require("EdenAndNether_Extra_scripts.core.savedata")
local enums = require("EdenAndNether_Extra_scripts.core.enums")
local auxi = require("EdenAndNether_Extra_scripts.auxiliary.functions")
local Damage_holder = require("EdenAndNether_Extra_scripts.others.Damage_holder")
local sound_tracker = require("EdenAndNether_Extra_scripts.auxiliary.sound_tracker")
local delay_buffer = require("EdenAndNether_Extra_scripts.auxiliary.delay_buffer")
local Base_holder = require("EdenAndNether_Extra_scripts.others.Base_holder")
local Sandstone = require("EdenAndNether_Extra_scripts.enemies.Sandstone")

local item = {
	ToCall = {},
    own_key = "EAN_Cheese_Wheel_",
    entity = enums.Enemies.Cheese_Wheel,
    offset_info = {
        [1] = {
            {frame = 0,val = -5,speed = 0,},
            {frame = 5,val = -10,speed = 0.1,},
            {frame = 30,val = -240,speed = 0.9,},
            {frame = 35,val = -250,speed = 1,},
        },
        [2] = {
            {frame = 0,val = -250,speed = 1,},
            {frame = 5,val = -240,speed = 0.9,},
            {frame = 15,val = -10,speed = 0.1,},
            {frame = 17,val = 15,speed = 0,},
            {frame = 25,val = -5,speed = 0,},
        },
    },
}

table.insert(item.ToCall,#item.ToCall + 1,{CallBack = ModCallbacks.MC_POST_NPC_INIT, params = 613,
Function = function(_,ent)
    if ent.Variant == item.entity then
        local s = ent:GetSprite()
        local d = ent:GetData()
        local anim = s:GetAnimation()
        s:Play("Fly",true)
        ent.PositionOffset = Vector(0,-5)
        ent.GridCollisionClass = 0
    end
end,
})

table.insert(item.ToCall,#item.ToCall + 1,{CallBack = ModCallbacks.MC_NPC_UPDATE, params = 613,
Function = function(_,ent)
    if ent.Variant == item.entity then
        local s = ent:GetSprite()
        local d = ent:GetData()
        local anim = s:GetAnimation()
        d[item.own_key.."state"] = d[item.own_key.."state"] or {id = 1,counter = 0,}
        d[item.own_key.."state"].counter = d[item.own_key.."state"].counter + 1
        if d[item.own_key.."state"].id == 2 then
            if d[item.own_key.."state"].counter == 15 then
                s:Play("AttackIdle",true)
            end
            if d[item.own_key.."state"].counter == 17 then
                sound_tracker.PlayStackedSound(SoundEffect.SOUND_ROCK_CRUMBLE,1,1,false,0,2)
                for i = 1,6 do 
                    local q = Isaac.Spawn(9,9,0,ent.Position,auxi.get_by_rotate(nil,i/6 * 360,8),ent):ToProjectile()
                    local qs = q:GetSprite() local qd = q:GetData()
                    qs:Load("gfx/tears/sand_stone_tear.anm2",true) qs:Play("RegularTear10",true)
                    qd[Sandstone.own_key.."effect"] = {cnt = 10,}
                end
                Game():ShakeScreen(10)
                ent:TakeDamage(ent.MaxHitPoints * 0.21,0,EntityRef(ent),30)
            end
            if d[item.own_key.."state"].counter >= 30 then
                d[item.own_key.."state"] = {id = 1,counter = 0,}
                s:Play("Fly",true)
            end
        end
        local info = auxi.check_lerp(d[item.own_key.."state"].counter,item.offset_info[d[item.own_key.."state"].id])
        ent.PositionOffset = Vector(0,info.val)

        local tg = auxi.get_acceptible_target(ent)
        if tg then
            ent.Velocity = (tg.Position - ent.Position):Normalized() * 8 * info.speed
            if d[item.own_key.."state"].id == 1 and d[item.own_key.."state"].counter > 50 and (tg.Position - ent.Position):Length() < 20 then
                d[item.own_key.."state"] = {id = 2,counter = 0,}
                s:Play("Attack",true)
            end
        end
		ent.Velocity = auxi.apply_friction(ent.Velocity,1)

        ent.GridCollisionClass = 0
        if ent.PositionOffset.Y < -30 then 
            ent.EntityCollisionClass = 0
        else 
            ent.EntityCollisionClass = 4
        end
    end
end,
})

return item