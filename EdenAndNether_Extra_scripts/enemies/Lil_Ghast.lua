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
    own_key = "EAN_Lil_Ghast_",
    entity = enums.Enemies.Lil_Ghast,
	Swapper = {
		["GetClose"] = "IdleBig",
	},
    Closeinfo = {
        {frame = 0,val1 = 0,val2 = 0,},
        {frame = 11,val1 = 1,val2 = 0,},
    },
    offset = Vector(0,-5),
}

table.insert(item.ToCall,#item.ToCall + 1,{CallBack = ModCallbacks.MC_NPC_UPDATE, params = 613,
Function = function(_,ent)
	if ent.Variant == item.entity then
		local s = ent:GetSprite()
		local d = ent:GetData()
		local anim = s:GetAnimation()
		local frame = s:GetFrame()
		local overlayanim = s:GetOverlayAnimation()
        ent.DepthOffset = math.min(2000,ent.DepthOffset + 5)
        if s.Color.A < 1 then s.Color = auxi.AddColor(s.Color,Color(0,0,0,1),1,0.02) end
        if s.Color.A >= 0.85 then 
            if anim == "IdleSmall" then
                s:Play("GetClose",true)
            end
        else ent.Velocity = ent.Velocity * 0.5 end
        if anim == "IdleBig" then
            d[item.own_key.."effect"] = (d[item.own_key.."effect"] or 0) + 1
            if d[item.own_key.."effect"] >= 5 * 30 then
                s:Play("Disappear",true)
            end
        end
        if d[item.own_key.."pos"] == nil then 
            local sz = auxi.GetScreenSize()
            d[item.own_key.."pos"] = Vector(sz.X * (auxi.random_1() * 0.6 + 0.2),sz.Y * (auxi.random_1() * 0.6 + 0.2))
        end
        if anim == "GetClose" then
            local p1 = auxi.real_ScreenToWorld(d[item.own_key.."pos"])
            local mxy = math.max(ent.Position.Y,p1.Y)
            local p2 = Vector((p1 + ent.Position).X/2,mxy + 500)
            local val = frame/22
            ent.PositionOffset = item.offset + auxi.Bezier({ent.Position,ent.Position,p2,p1,p1,},val) - ent.Position
        elseif anim == "Disappear" or anim == "IdleBig" then
            local p1 = auxi.real_ScreenToWorld(d[item.own_key.."pos"])
            ent.PositionOffset = item.offset + p1 - ent.Position
        else ent.PositionOffset = item.offset
        end
		if s:IsFinished(anim) then
			local tg = auxi.check_if_any(item.Swapper[anim],ent) or "Idle"
			s:Play(tg,true)
            if anim == "Disappear" then ent:Remove() return end
        end
    end
end,
})

table.insert(item.ToCall,#item.ToCall + 1,{CallBack = ModCallbacks.MC_POST_NPC_INIT, params = 613,
Function = function(_,ent)
    if ent.Variant == item.entity then
        local s = ent:GetSprite()
        local d = ent:GetData()
        local anim = s:GetAnimation()
        s:Play("IdleSmall",true)
        s.Color = Color(1,1,1,0)
        ent.PositionOffset = item.offset
        ent.EntityCollisionClass = 0
        ent.GridCollisionClass = 0
    end
end,
})

return item