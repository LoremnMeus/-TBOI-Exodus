local g = require("EdenAndNether_Extra_scripts.core.globals")
local save = require("EdenAndNether_Extra_scripts.core.savedata")
local enums = require("EdenAndNether_Extra_scripts.core.enums")
local auxi = require("EdenAndNether_Extra_scripts.auxiliary.functions")
local Damage_holder = require("EdenAndNether_Extra_scripts.others.Damage_holder")
local sound_tracker = require("EdenAndNether_Extra_scripts.auxiliary.sound_tracker")
local delay_buffer = require("EdenAndNether_Extra_scripts.auxiliary.delay_buffer")

local item = {
	ToCall = {},
    own_key = "EAN_Cursed_Dip_",
    entity = enums.Enemies.Cursed_Dip,
}

table.insert(item.ToCall,#item.ToCall + 1,{CallBack = ModCallbacks.MC_POST_NPC_INIT, params = 217,
Function = function(_,ent)
    if ent.Variant == item.entity then
        local s = ent:GetSprite()
        local d = ent:GetData()
        local anim = s:GetAnimation()
        s:Play("Idle",true)
        ent.PositionOffset = Vector(0,-3)
    end
end,
})

--[[
table.insert(item.ToCall,#item.ToCall + 1,{CallBack = ModCallbacks.MC_POST_EFFECT_INIT, params = 94,
Function = function(_,ent)
    local tgs = auxi.getothers(nil,1000,96,nil,function(v) if v:GetData()[item.own_key.."effect"] and (v.Position - ent.Position):Length() < 80 then return true else return false end end)
    if #tgs > 0 then
        ent:GetData()[item.own_key.."effect"] = {}
        ent:SetColor(Color(1,0,0,1),-1,1,true,true)
    end
end,
})

table.insert(item.ToCall,#item.ToCall + 1,{CallBack = ModCallbacks.MC_POST_EFFECT_UPDATE, params = 94,
Function = function(_,ent)
    if ent:GetData()[item.own_key.."effect"] and ent.FrameCount < 4 then
        ent:SetColor(Color(1,0,0,1),-1,1,true,true)
    end
end,
})

--]]
table.insert(item.ToCall,#item.ToCall + 1,{CallBack = ModCallbacks.MC_POST_EFFECT_UPDATE, params = 96,
Function = function(_,ent)
    local d = ent:GetData()
    if d[item.own_key.."effect"] then 
        if ent.Timeout < 1 then     --似乎没法修复
            delay_buffer.addeffe(function()
                local tgs = auxi.getothers(nil,1000,94)
                for u,v in pairs(tgs) do 
                    if v.FrameCount <= 1 and (v.Position - ent.Position):Length() < 80 then
                        v:ToEffect():SetColor(Color(1,0,0,1),-1,1,true,true)
                    end
                end
            end,{},2)
        end
        local tgs = auxi.getothers(nil,1000,94)
        for u,v in pairs(tgs) do 
            if v.FrameCount <= 1 and (v.Position - ent.Position):Length() < 80 then
                v:ToEffect():SetColor(Color(1,0,0,1),-1,1,true,true)
            end
        end
    end
end,
})
--l local n_entity = Isaac.GetRoomEntities() for u,v in pairs(n_entity) do if v.Type == 1000 and v.Variant == 94 then print(1) if v.SpawnerEntity then print(v.SpawnerType) end end end
table.insert(item.ToCall,#item.ToCall + 1,{CallBack = ModCallbacks.MC_NPC_UPDATE, params = 217,
Function = function(_,ent)
    if ent.Variant == item.entity then
        local s = ent:GetSprite()
        local d = ent:GetData()
        local anim = s:GetAnimation()
        d[item.own_key.."effect"] = d[item.own_key.."effect"] or {}
        if d[item.own_key.."effect"].should_leave then
            ent.Velocity = ent.Velocity * 0.1
            ent.State = 12
            if anim == "Idle" then s:Play("LaserStart",true) end
            if anim == "LaserStart" and s:IsFinished(anim) then
                local q = Isaac.Spawn(1000,101,0,ent.Position,ent.Velocity,ent):ToEffect()
                q.Parent = ent q.IsFollowing = true q:GetSprite().Scale = Vector(0.5,1) q:SetTimeout(90) q:SetColor(Color(1,0,0,1),-1,1,true,true)
                q.ParentOffset = Vector(0,5) q:GetSprite().Offset = Vector(0,-10) q:Update()
                d[item.own_key.."effect"].Laser = q

                local q = Isaac.Spawn(1000,96,0,auxi.get_acceptible_target(ent).Position + auxi.random_r() * (auxi.random_1() * 200 + 100),Vector(0,0),ent):ToEffect() 
                q:GetSprite().Scale = Vector(1,1) q:SetTimeout(90) q:SetColor(Color(1,0,0,1),-1,1,true,true) q:Update()
                d[item.own_key.."effect"].target = q
                local qd = q:GetData()
                qd[item.own_key.."effect"] = {}
                s:Play("Laser",true)
                sound_tracker.PlayStackedSound(SoundEffect.SOUND_BLOOD_LASER_LARGE,1,1,false,0,2)
            end
            if d[item.own_key.."effect"].Laser and auxi.check_exists(d[item.own_key.."effect"].Laser) then
                local q = d[item.own_key.."effect"].Laser
                if ent.FrameCount % 2 == 1 then 
                    q.ParentOffset = Vector(0,5)
                else 
                    q.ParentOffset = Vector(1,5)
                end
            end
            if d[item.own_key.."effect"].Laser and d[item.own_key.."effect"].target and auxi.check_exists(d[item.own_key.."effect"].Laser) ~= true then
                s:Play("LaserOver",true)
                d[item.own_key.."effect"].Laser = nil
            end
            if anim == "LaserOver" and s:IsFinished(anim) then
                ent:Kill()
                return
            end
        end
    end
end,
})


table.insert(item.ToCall,#item.ToCall + 1,{CallBack = ModCallbacks.MC_ENTITY_TAKE_DMG, params = 217,
Function = function(_,ent,amt,flag,source,cooldown)
	if ent.Variant == item.entity then
		local d = ent:GetData()
        d[item.own_key.."effect"] = d[item.own_key.."effect"] or {}
		if d[item.own_key.."effect"].should_leave then return false end
		local total_damage = Damage_holder.on_damage(ent,amt,flag,source,cooldown)
		if total_damage > ent.HitPoints then 
			d[item.own_key.."effect"].should_leave = true 
			ent.HitPoints = 1 return false 
		end
	end
end,
})

return item