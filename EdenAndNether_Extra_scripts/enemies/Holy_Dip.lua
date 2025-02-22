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
    own_key = "EAN_Holy_Dip_",
    entity = enums.Enemies.Holy_Dip,
}

table.insert(item.ToCall,#item.ToCall + 1,{CallBack = ModCallbacks.MC_NPC_UPDATE, params = 15,
Function = function(_,ent)
    if StageAPI and ent.Variant == 1 then
        if Base_holder.TheEden:IsStage() and ent.Variant == 2 then
            if ent:IsChampion() then ent:Morph(217,item.entity,0,ent:GetChampionColorIdx())
            else ent:Morph(217,item.entity,0,-1) end
        end
    end
end,
})

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

--l local n_entity = Isaac.GetRoomEntities() for u,v in pairs(n_entity) do if v.Type == 1000 and v.Variant == 94 then print(1) if v.SpawnerEntity then print(v.SpawnerType) end end end
table.insert(item.ToCall,#item.ToCall + 1,{CallBack = ModCallbacks.MC_NPC_UPDATE, params = 217,
Function = function(_,ent)
    if StageAPI and ent.Variant == 0 then
        if Base_holder.TheEden:IsStage() then
            if ent:IsChampion() then ent:Morph(217,item.entity,0,ent:GetChampionColorIdx())
            else ent:Morph(217,item.entity,0,-1) end
        end
    end
    if ent.Variant == item.entity then
        local s = ent:GetSprite()
        local d = ent:GetData()
        local anim = s:GetAnimation()
        d[item.own_key.."effect"] = d[item.own_key.."effect"] or {}
        if d[item.own_key.."effect"].should_leave then
            ent.Velocity = ent.Velocity * 0.1
            ent.State = 12
            if anim == "Idle" then s:Play("Die",true) end
            if anim == "Die" and s:IsFinished(anim) then
                s:Play("RingAttack",true)
            end
            if anim == "RingAttack" and s:IsFinished(anim) then
                local tg = auxi.get_acceptible_target(ent)
                local q = Isaac.Spawn(1000,19,2,tg.Position,Vector(0,0),nil)
				local s = q:GetSprite()
				s.Color = Color(1,1,1,1,0,0,0)
				Game():MakeShockwave(tg.Position,0.035,0.025,10) 
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