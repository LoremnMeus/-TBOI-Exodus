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
    own_key = "EAN_Mega_Host_",
    entity = enums.Enemies.Mega_Host,
    scale_addon = {
        {frame = 1,val = 3,},
        {frame = 3,val = 1,},
        {frame = 5,val = 0.2,},
        {frame = 7,val = 0,},
    },
}

function item.is_mega_host(ent)
    if ent.Variant == item.entity or (ent.Variant == 1 and ent.SubType == 747) then return true end
end

table.insert(item.ToCall,#item.ToCall + 1,{CallBack = ModCallbacks.MC_POST_NPC_INIT, params = 27,
Function = function(_,ent)
    if item.is_mega_host(ent) then
        local s = ent:GetSprite()
        local d = ent:GetData()
        local anim = s:GetAnimation()
        ent:AddEntityFlags(EntityFlag.FLAG_NO_KNOCKBACK | EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK)
        ent.PositionOffset = Vector(0,5)
    end
end,
})

table.insert(item.ToCall,#item.ToCall + 1,{CallBack = ModCallbacks.MC_NPC_UPDATE, params = 27,
Function = function(_,ent)
    if item.is_mega_host(ent) then
        local s = ent:GetSprite()
        local d = ent:GetData()
        local anim = s:GetAnimation()
        if ent.Variant == item.entity then
            if anim == "Shoot" and (s:WasEventTriggered("Open") and not s:WasEventTriggered("Close")) then ent.CollisionDamage = 2
            else ent.CollisionDamage = 0 end
        else 
            if d[item.own_key.."collisiondamage"] then 
                d[item.own_key.."collisiondamage"] = d[item.own_key.."collisiondamage"] - 1
                if d[item.own_key.."collisiondamage"] <= 0 then d[item.own_key.."collisiondamage"] = nil end
                ent.CollisionDamage = 0
            else
                ent.CollisionDamage = 2 
            end
        end
        for i = 1,3 do
            if s:IsEventTriggered("Shoot"..tostring(i)) then
                local cnt = i * 2 - 1
                if ent.Variant == 1 then cnt = cnt + 2 end
                local scale_adder = auxi.check_lerp(cnt,item.scale_addon).val
                local tg = auxi.get_acceptible_target(ent)
                local dir = (tg.Position - ent.Position):Normalized()
                for j = 1,cnt do
                    local vj = j - (cnt + 1)/2
                    local ddir = auxi.get_by_rotate(dir,90/cnt * vj)
                    local q = Isaac.Spawn(9,0,0,ent.Position,ddir * (7 + i),ent):ToProjectile()
                    if auxi.random_1() > 0.25 then
                        sound_tracker.PlayStackedSound(SoundEffect.SOUND_BOSS_LITE_SLOPPY_ROAR,1,1,false,0,2) 
                    else
                        sound_tracker.PlayStackedSound(SoundEffect.SOUND_BOSS_SPIT_BLOB_BARF,1,1,false,0,2) 
                    end
                    q:AddScale(scale_adder)
                end
            end
        end
        if s:IsEventTriggered("Open") then
            sound_tracker.PlayStackedSound(SoundEffect.SOUND_BOSS_LITE_ROAR,1,1,false,0,2) 
        end
        if s:IsEventTriggered("Close") then
            Game():ShakeScreen(15)
            local tg = auxi.get_acceptible_target(ent)
            local dir = (tg.Position - ent.Position):Normalized()
            local q = Isaac.Spawn(1000,67,0,ent.Position,Vector(0,-6) + dir * 10,ent)
            --l local player = Game():GetPlayer(0) local q = Isaac.Spawn(2,40,140747,player.Position,Vector(0,0),player):ToTear() local qs = q:GetSprite() qs:Load("gfx/monsters/tainted/mega_host_tear.anm2") qs:Play("Rock1",true) Game():GetRoom():Update() player:UseActiveItem(604, false, false, true, false)
            --l local delay_buffer = require("EdenAndNether_Extra_scripts.auxiliary.delay_buffer") delay_buffer.addeffe(function(params) local player = Game():GetPlayer(0) local q = Isaac.Spawn(2,40,140747,player.Position,Vector(0,0),player):ToTear() local qs = q:GetSprite() qs:Load("gfx/monsters/tainted/mega_host_tear.anm2") qs:Play("Rock1",true) Game():GetRoom():Update() player:UseActiveItem(604, false, false, true, false) end,{},1)
        end
    end
end,
})

table.insert(item.ToCall,#item.ToCall + 1,{CallBack = ModCallbacks.MC_PRE_USE_ITEM, params = 604,
Function = function(_,colid, rng, player, flags, slot, data)
    if item.lock then return end
    local tgs = auxi.getothers(nil,27,item.entity)
    for u,v in pairs(tgs) do
        if (v.Position - player.Position):Length() <= player.Size + v.Size then
            v.Variant = 1
            v.SubType = 747
            v:GetData()[item.own_key.."collisiondamage"] = 30
            local vs = v:GetSprite() vs:ReplaceSpritesheet(0,"gfx/monsters/tainted/skulless_mega_host.png") vs:LoadGraphics()
            item.lock = true 
            delay_buffer.addeffe(function(params)
                local player = Game():GetPlayer(0)
                local q = Isaac.Spawn(2,40,140747,player.Position,Vector(0,0),player):ToTear() q.CollisionDamage = 100
                local qs = q:GetSprite() qs:Load("gfx/monsters/tainted/mega_host_tear.anm2",true) qs:Play("Rock1",true)
                Game():GetRoom():Update() 
                player:UseActiveItem(604, false, false, true, false)
                item.lock = nil
            end,{},1)
            return true
        end
    end
end,
})

table.insert(item.ToCall,#item.ToCall + 1,{CallBack = ModCallbacks.MC_PRE_TEAR_COLLISION, params = 40,
Function = function(_,ent,col,low)
    if ent.SubType == 140747 and col.Type == 27 and col:GetData()[item.own_key.."collisiondamage"] then
        return true
    end
end,
})

table.insert(item.ToCall,#item.ToCall + 1,{CallBack = ModCallbacks.MC_POST_ENTITY_REMOVE, params = 2,
Function = function(_,ent)
    if ent.Variant == 40 and ent.SubType == 140747 then
        if ent.FrameCount > 5 then 
            Game():ShakeScreen(15)
            local q = Isaac.Spawn(1000,61,0,ent.Position,Vector(0,0),Game():GetPlayer(0)):ToEffect()
            q.MinRadius = 50
            --l local q = Isaac.Spawn(1000,61,0,Vector(200,200),Vector(0,0),Game():GetPlayer(0)):ToEffect() print(q.MaxRadius) q.MaxRadius = 100 print(q.MinRadius) q.MinRadius = 10
        end
        local tgs = auxi.getothers(nil,1000,4,1)
        for u,v in pairs(tgs) do
            local vs = v:GetSprite()
            if vs:GetFilename() == "gfx/monsters/tainted/mega_host_tear.anm2" then
                vs:Load("gfx/grid/grid_rock.anm2",true) vs:ReplaceSpritesheet(0,"gfx/grid/rocks_depths.png") vs:LoadGraphics()
                vs:SetFrame("rubble_alt",auxi.choose(0,1,2,3))
                vs.Scale = Vector(1.5,1.5)
            end
        end
    end
end,
})

return item