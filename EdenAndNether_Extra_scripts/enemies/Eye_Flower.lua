local g = require("EdenAndNether_Extra_scripts.core.globals")
local save = require("EdenAndNether_Extra_scripts.core.savedata")
local enums = require("EdenAndNether_Extra_scripts.core.enums")
local auxi = require("EdenAndNether_Extra_scripts.auxiliary.functions")
local Damage_holder = require("EdenAndNether_Extra_scripts.others.Damage_holder")
local sound_tracker = require("EdenAndNether_Extra_scripts.auxiliary.sound_tracker")
local delay_buffer = require("EdenAndNether_Extra_scripts.auxiliary.delay_buffer")
local Base_holder = require("EdenAndNether_Extra_scripts.others.Base_holder")
local Grow_holder = require("EdenAndNether_Extra_scripts.enemies.The_Grow_Chain")

local item = {
	ToCall = {},
    own_key = "EAN_Eye_Flower_",
    entity = enums.Enemies.Eye_Flower,
    id2dir = {
        Vector(1,0),
        Vector(-1,0),
        Vector(0,1),
        Vector(0,-1),
    },
}

table.insert(item.ToCall,#item.ToCall + 1,{CallBack = ModCallbacks.MC_POST_NPC_INIT, params = 60,
Function = function(_,ent)
    if StageAPI then
        if Base_holder.TheEden:IsStage() and (ent.Variant ~= item.entity or ent.SubType ~= 747) then
            if ent:IsChampion() then ent:Morph(60,item.entity,747,ent:GetChampionColorIdx())
            else ent:Morph(60,item.entity,747,-1) end
        end
    end
    if ent.Variant == item.entity and ent.SubType == 747 then
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

table.insert(item.ToCall,#item.ToCall + 1,{CallBack = ModCallbacks.MC_NPC_UPDATE, params = 60,
Function = function(_,ent)
    if ent.Variant == item.entity and ent.SubType == 747 then
        local s = ent:GetSprite()
        local d = ent:GetData()
        local anim = s:GetAnimation()
        if s:GetFrame() == 1 then
            d[item.own_key.."rnd"] = auxi.choose(1,2,3)
            d[item.own_key.."rnd2"] = auxi.choose(1,-1)
            d[item.own_key.."cnt"] = 0
            d[item.own_key.."list"] = {1,2,3,4,}
        end
        if s:IsEventTriggered("Fire") then
            local rnd = d[item.own_key.."rnd"]
            d[item.own_key.."cnt"] = (d[item.own_key.."cnt"] or 0) + 1
            local cnt = d[item.own_key.."cnt"] - 1
            local react_time = 60 - cnt * 2
            local tg = auxi.get_acceptible_target(ent)
            local dir = (tg.Position - ent.Position):Normalized()
            if rnd == 1 then
                local rnd2 = auxi.choose(1,1,1,1,1,2)
                for i = 1,rnd2 do
                    local dir = auxi.random_r()
                    local tgpos = item.findWallPosition(tg.Position,dir)
                    local leg = auxi.choose(200,250,300)
                    if (tgpos - tg.Position):Length() < leg then tgpos = tg.Position + dir * leg end
                    local q = Grow_holder.release_grow(ent,-dir,{retractTimer = react_time,startpos = tgpos,negfirst = true,noCatch = true,}) q.PositionOffset = Vector(0,-5)
                end
            elseif rnd == 2 then
                local q = Grow_holder.release_grow(ent,auxi.get_by_rotate(dir,60 - cnt * 13),{retractTimer = react_time,}) q.PositionOffset = Vector(0,-5)
                local q = Grow_holder.release_grow(ent,auxi.get_by_rotate(dir,-(60 - cnt * 13)),{retractTimer = react_time,}) q.PositionOffset = Vector(0,-5)
            else
                local index = math.random(1, #d[item.own_key.."list"])
                local id = d[item.own_key.."list"][index] or 1
                table.remove(d[item.own_key.."list"], index)  -- 移除已选择的元素
                local dir = item.id2dir[id]
                local tgpos = item.findWallPosition(tg.Position,-dir) - dir * 80 --+ cnt * d[item.own_key.."rnd2"] * Vector(10,0)
                local q = Grow_holder.release_grow(ent,dir,{retractTimer = react_time,startpos = tgpos,negfirst = true,noCatch = true,}) 
            end
        end
        d[item.own_key.."state"] = d[item.own_key.."state"] or {}
        if ent.State ~= 3 then
            local tgs = auxi.getothers(nil,60,item.entity,747)
            for u,v in pairs(tgs) do 
                if (v:ToNPC().State ~= 3 or (((v:GetData()[item.own_key.."state"] or {}).counter or 0) > 0)) and auxi.check_for_the_same(ent,v) ~= true then
                    d[item.own_key.."state"].start = true
                end
            end
            if d[item.own_key.."state"].start then ent.State = 3 s:Play("Idle",true)
            else d[item.own_key.."state"] = {counter = 60,} end
        end
        if ent.State == 3 then 
            if (d[item.own_key.."state"].counter or 0) > 0 then
                d[item.own_key.."state"].start = true
                d[item.own_key.."state"].counter = (d[item.own_key.."state"].counter or 0) - 1
            else 
                d[item.own_key.."state"] = nil
            end
        end
        --s:Play("Idle",true)
        --ent.PositionOffset = Vector(0,-3)
    end
end,
})

--l local n_entity = Isaac.GetRoomEntities() for u,v in pairs(n_entity) do if v.Type == 1000 then print(v.Variant) end end

return item