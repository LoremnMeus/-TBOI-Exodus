local g = require("EdenAndNether_Extra_scripts.core.globals")
local save = require("EdenAndNether_Extra_scripts.core.savedata")
local enums = require("EdenAndNether_Extra_scripts.core.enums")
local auxi = require("EdenAndNether_Extra_scripts.auxiliary.functions")
local Damage_holder = require("EdenAndNether_Extra_scripts.others.Damage_holder")
local sound_tracker = require("EdenAndNether_Extra_scripts.auxiliary.sound_tracker")
local delay_buffer = require("EdenAndNether_Extra_scripts.auxiliary.delay_buffer")
local Base_holder = require("EdenAndNether_Extra_scripts.others.Base_holder")
local Blossoms = require("EdenAndNether_Extra_scripts.enemies.Blossoms")

local item = {
	ToCall = {},
    own_key = "EAN_Eater_Flower_",
    entity = enums.Enemies.Eater_Flower,
	Swapper = {
		["Attack"] = "Idle2",
		["Idle2"] = "GoingUp",
	},
    offset_info = {
        [1] = {
            {frame = 0,val = -5,speed = 0,},
            {frame = 5,val = -10,speed = 0.1,},
            {frame = 15,val = -240,speed = 0.9,},
            {frame = 20,val = -250,speed = 1,},
        },
        [2] = {
            {frame = 0,val = -250,speed = 1,},
            {frame = 7,val = -240,speed = 1,},
            {frame = 15,val = -10,speed = 0.1,},
            {frame = 17,val = 10,speed = 0,},
        },
    },
}

table.insert(item.ToCall,#item.ToCall + 1,{CallBack = ModCallbacks.MC_POST_NPC_INIT, params = 613,
Function = function(_,ent)
    if ent.Variant == item.entity then
        local s = ent:GetSprite()
        local d = ent:GetData()
        local anim = s:GetAnimation()
        ent.TargetPosition = ent.Position
    end
end,
})

table.insert(item.ToCall,#item.ToCall + 1,{CallBack = ModCallbacks.MC_NPC_UPDATE, params = 613,
Function = function(_,ent)
    if ent.Variant == item.entity then
        local s = ent:GetSprite()
        local d = ent:GetData()
        local anim = s:GetAnimation() local frame = s:GetFrame()
        if (anim == "Attack" and frame >= 15) or (anim == "GoingUp" and frame <= 10) or anim == "Idle2" then
            ent.EntityCollisionClass = 4
        else
            ent.EntityCollisionClass = 0
        end
        ent.Velocity = ent.TargetPosition - ent.Position
		ent.Velocity = auxi.apply_friction(ent.Velocity,1)
        
        d[item.own_key.."state"] = d[item.own_key.."state"] or {id = 1,counter = 0,}
        d[item.own_key.."state"].counter = d[item.own_key.."state"].counter + 1
        local info = auxi.check_lerp(d[item.own_key.."state"].counter,item.offset_info[d[item.own_key.."state"].id])
        ent.PositionOffset = Vector(0,info.val)

        if anim == "Idle" and (d[item.own_key.."state"].counter > 20) then
            local tg = auxi.get_acceptible_target(ent)
            if tg then
                if (tg.Position - ent.Position):Length() < 20 then  --d[item.own_key.."state"].id == 1 and d[item.own_key.."state"].counter > 50 and
                    d[item.own_key.."state"] = {id = 2,counter = 0,}
                    s:Play("Attack",true)
                end
            end
        end
        if anim == "Attack" and frame == 10 then 
            if ent.SubType ~= 2 then
                sound_tracker.PlayStackedSound(SoundEffect.SOUND_ISAAC_ROAR,1,1,false,0,2)
            end
        end
        if ent.SubType == 3 and anim == "Idle2" and (frame == 6 or frame == 12 or frame == 18) then
            local tg = auxi.get_acceptible_target(ent)
            if tg then
                if (d[item.own_key.."stateid"] or 0) % 2 == 0 then
                    local dir = tg.Position - ent.Position
                    local cnt = auxi.choose(1,2)
                    for i = 1,cnt do 
                        local ui = i - cnt/2 - 0.5
                        local q = Isaac.Spawn(9,0,0,ent.Position,auxi.get_by_rotate(dir,ui * 7.5,8),ent):ToProjectile()
                    end
                else
                    local dir = tg.Position - ent.Position
                    local cnt = auxi.choose(1,2,3)
                    for i = 1,cnt do 
                        local ui = i - cnt/2 - 0.5
                        for k = -1,1,2 do
                            local q = Isaac.Spawn(9,0,0,ent.Position,auxi.get_by_rotate(dir,ui * 7.5 + k * 45,8),ent):ToProjectile()
                        end
                    end
                end
            end
            sound_tracker.PlayStackedSound(SoundEffect.SOUND_MONSTER_GRUNT_4,1,1,false,0,2)
        end
        if ent.SubType == 3 and anim == "GoingUp" and frame == 8 then
            local succ = Blossoms.add_buffs(1,auxi.choose(1,2,3,4,5),{pos = ent.Position,NoForce = true,check_blossoms = function(et,params) 
                if auxi.check_for_the_same(et,ent) then return false end
            end,})
            if succ then sound_tracker.PlayStackedSound(SoundEffect.SOUND_MONSTER_GRUNT_4,1,1,false,0,2) end
        end
        if anim == "Idle2" and frame == 6 then 
            if ent.SubType == 1 then
                local tg = auxi.get_acceptible_target(ent)
                if tg then
                    local dir = tg.Position - ent.Position
                    local cnt = 4
                    for i = 1,cnt do 
                        local ui = i - cnt/2 - 0.5
                        local q = Isaac.Spawn(9,0,0,ent.Position,auxi.get_by_rotate(dir,ui * 15,8),ent):ToProjectile()
                    end
                end
                sound_tracker.PlayStackedSound(SoundEffect.SOUND_MONSTER_GRUNT_4,1,1,false,0,2)
            end
        end
        if anim == "Attack" and frame == 17 then 
            if ent.SubType ~= 1 then
                Game():ShakeScreen(10)
            end
            if ent.SubType == 2 then
                sound_tracker.PlayStackedSound(SoundEffect.SOUND_HELLBOSS_GROUNDPOUND,1,1,false,0,2)
                Game():MakeShockwave(ent.Position,0.1,0.025,15)
                for playerNum = 1, Game():GetNumPlayers() do
                    local player = Game():GetPlayer(playerNum - 1)
                    player:AddVelocity((player.Position - ent.Position):Normalized() * 10)
                end
            end
        end
        if anim == "GoingUp" and frame == 54 then 
            d[item.own_key.."state"] = {id = 1,counter = 0,}
            d[item.own_key.."stateid"] = (d[item.own_key.."stateid"] or 0) + 1
        end
		if s:IsFinished(anim) then
			local tg = auxi.check_if_any(item.Swapper[anim],ent) or "Idle"
			s:Play(tg,true)
		end
    end
end,
})

table.insert(item.ToCall,#item.ToCall + 1,{CallBack = ModCallbacks.MC_POST_NPC_DEATH, params = 613,
Function = function(_,ent)
    if ent.Variant == item.entity then
        for i = 1,8 do
            local q = Isaac.Spawn(1000,58,0,ent.Position,auxi.random_r() * auxi.random_1() * 5,ent):ToEffect() local qs = q:GetSprite()
            qs:Load("gfx/backdrops/blush_particle.anm2",true) qs:Play(auxi.choose("Leaf","Leaf2","Leaf","Leaf2","Root","Root2"),true)
            qs.Rotation = auxi.random_1() * 360
            if ent.SubType == 1 then qs.Color = Color(1,0.6,0.6,1,0.2,0,0) end
        end
    end
end,
})

return item