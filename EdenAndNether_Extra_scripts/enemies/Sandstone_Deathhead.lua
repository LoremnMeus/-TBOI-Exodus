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
    own_key = "EAN_Sandstone_Deathhead_",
    entity = enums.Enemies.Sandstone_Deathhead,
	Swapper = {
		["Shoot"] = "Idle",
	},
}

table.insert(item.ToCall,#item.ToCall + 1,{CallBack = ModCallbacks.MC_NPC_UPDATE, params = 212,
Function = function(_,ent)
    if ent.Variant == item.entity and ent.SubType == 747 then
        local s = ent:GetSprite()
        local d = ent:GetData()
        local anim = s:GetAnimation() local frame = s:GetFrame()
        if ent.FrameCount % 120 == 25 and anim == "Idle" then
            ent.State = 111
            s:Play("Shoot",true)
        end
        if anim == "Shoot" and frame == 6 then
            local q = Isaac.Spawn(9,9,0,ent.Position,Vector(0,0),ent):ToProjectile()
            local qs = q:GetSprite() local qd = q:GetData()
            qs:Load("gfx/tears/sand_stone_tear.anm2",true) qs:Play("RegularTear10",true)
            qd[Sandstone.own_key.."effect"] = {cnt = 10,vel = 5,}
        end
		if s:IsFinished(anim) then
			local tg = auxi.check_if_any(item.Swapper[anim],ent) or "Idle"
            if anim == "Shoot" then ent.State = 4 end
			s:Play(tg,true)
		end
    end
end,
})

return item