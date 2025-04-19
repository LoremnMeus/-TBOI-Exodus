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
    own_key = "EAN_White_Wizoob_",
    entity = enums.Enemies.White_Wizoob,
    directionMap = {
        ShootUp = Vector(0, -1),    -- 向上
        ShootDown = Vector(0, 1),   -- 向下
        ShootLeft = Vector(-1, 0),  -- 向左
        ShootRight = Vector(1, 0)   -- 向右
    },
}

table.insert(item.ToCall,#item.ToCall + 1,{CallBack = ModCallbacks.MC_POST_NPC_INIT, params = 285,
Function = function(_,ent)
    if ent.Variant == 0 then
        Base_holder.try_convert(ent,{type = 219,variant = item.entity,subtype = 0,})
    end
end,
})

table.insert(item.ToCall,#item.ToCall + 1,{CallBack = ModCallbacks.MC_POST_NPC_INIT, params = 219,
Function = function(_,ent)
    if StageAPI then
        if Base_holder.TheEden:IsStage() and ent.Variant ~= item.entity then
            if ent:IsChampion() then ent:Morph(219,item.entity,0,ent:GetChampionColorIdx())
            else ent:Morph(219,item.entity,0,-1) end
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

--l local n_entity = Isaac.GetRoomEntities() for u,v in pairs(n_entity) do if v.Type == 1000 and v.Variant == 94 then print(1) if v.SpawnerEntity then print(v.SpawnerType) end end end
table.insert(item.ToCall,#item.ToCall + 1,{CallBack = ModCallbacks.MC_NPC_UPDATE, params = 219,
Function = function(_,ent)
    if ent.Variant == item.entity then
        local s = ent:GetSprite()
        local d = ent:GetData()
        local anim = s:GetAnimation()
        
        if s:IsEventTriggered("Fire") then
            local direction = item.directionMap[anim] or Vector(0, 0)
            local room = Game():GetRoom()
            local startPos = ent.Position
            local endPos = item.findWallPosition(startPos, direction)
            
            -- 计算路径长度
            local pathLength = (endPos - startPos):Length()
            
            -- 设置圣光发射点的间隔距离
            local interval = 40  -- 每个圣光之间的像素距离
            local numLights = math.floor(pathLength / interval)
            
            -- 沿路径生成圣光
            for i = 1, numLights do
                local lightPos = startPos + direction * (interval * (i))
                delay_buffer.addeffe(function()
                    local q = Isaac.Spawn(1000, 19, 0, lightPos, Vector(0, 0), ent)
                    q.Parent = ent
                end,{},i * 2,{remove_now = true,})
            end
        end
    end
end,
})

return item