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
    own_key = "EAN_White_Boom_Fly_",
    entity = enums.Enemies.White_Boom_Fly,
}

table.insert(item.ToCall,#item.ToCall + 1,{CallBack = ModCallbacks.MC_POST_NPC_INIT, params = 25,
Function = function(_,ent)
    Base_holder.try_convert(ent,{type = 25,variant = item.entity,subtype = 0,})
    if ent.Variant == item.entity then
        local s = ent:GetSprite()
        local d = ent:GetData()
        local anim = s:GetAnimation()
        --s:Play("Idle",true)
        --ent.PositionOffset = Vector(0,-3)
    end
end,
})

function item.findWallPosition(startPos, direction)
    local minDist = 0
    local maxDist = 1000  -- 假设最大距离为1000
    local epsilon = 1  -- 精度阈值
    local room = Game():GetRoom()

    while maxDist - minDist > epsilon do
        local midDist = (minDist + maxDist) / 2
        local testPos = startPos + direction * midDist
        
        if room:IsPositionInRoom(testPos, 0) then
            minDist = midDist
        else
            maxDist = midDist
        end
    end
    
    return startPos + direction * minDist
end

table.insert(item.ToCall,#item.ToCall + 1,{CallBack = ModCallbacks.MC_POST_ENTITY_KILL, params = 25,
Function = function(_,ent)
    if ent.Variant == item.entity then
        local s = ent:GetSprite()
        local d = ent:GetData()
        local anim = s:GetAnimation()
        local room = Game():GetRoom()
        local startPos = ent.Position
        local tg = auxi.get_acceptible_target(ent)
        local direction = (tg.Position - ent.Position):Normalized()
        local endPos = item.findWallPosition(startPos, direction)
        -- 计算路径长度
        local pathLength = (endPos - startPos):Length()
        
        -- 设置圣光发射点的间隔距离
        local interval = 60  -- 每个圣光之间的像素距离
        local numLights = math.ceil(pathLength / interval)
        
        -- 沿路径生成圣光
        for i = 1, numLights do
            local lightPos = startPos + direction * (interval * (i - 1))
            delay_buffer.addeffe(function()
                local interval = 30 + i * 5
                local numLights = 2 + i
                local rnd = auxi.random_1() * 360
                for j = 1, numLights do
                    local direction = auxi.MakeVector(j * 360/numLights + rnd)
                    local lightPos2 = lightPos + direction * interval
                    local q = Isaac.Spawn(1000, 19, 0, lightPos2, Vector(0, 0), ent)
                    q.Parent = ent
                end
            end,{},i * 8 - 3,{remove_now = true,})
        end

    end
end,
})

table.insert(item.ToCall,#item.ToCall + 1,{CallBack = ModCallbacks.MC_POST_PROJECTILE_INIT, params = nil,
Function = function(_,ent)
	local d = ent:GetData()
    if ent.SpawnerEntity and ent.SpawnerEntity.Type == 25 and ent.SpawnerEntity.Variant == item.entity then
        ent:Remove() return
    end
end,
})

table.insert(item.ToCall,#item.ToCall + 1,{CallBack = ModCallbacks.MC_POST_EFFECT_INIT, params = 7,
Function = function(_,ent)
    if ent.SpawnerEntity and ent.SpawnerEntity.Type == 25 and ent.SpawnerEntity.Variant == item.entity then
        ent:SetColor(Color(1,1,1,1,1,1,1),-1,1,true,true)
    end
end,
})

return item