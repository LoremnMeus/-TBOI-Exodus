local g = require("EdenAndNether_Extra_scripts.core.globals")
local save = require("EdenAndNether_Extra_scripts.core.savedata")
local enums = require("EdenAndNether_Extra_scripts.core.enums")
local auxi = require("EdenAndNether_Extra_scripts.auxiliary.functions")
local Damage_holder = require("EdenAndNether_Extra_scripts.others.Damage_holder")
local sound_tracker = require("EdenAndNether_Extra_scripts.auxiliary.sound_tracker")
local delay_buffer = require("EdenAndNether_Extra_scripts.auxiliary.delay_buffer")

local item = {
	ToCall = {},
    own_key = "EAN_The_Grow_Chain_",
    entity = enums.Enemies.The_Grow_Chain,

    segmentLength = 12,
    physicsParams = {
        stiffness = 0.1,  -- 弹簧刚度
        damping = 0.2,    -- 阻尼系数
        mass = 1.0,        -- 分段质量
        minControlInfluence = 0.1,
        maxControlInfluence = 0.5,
    }
}

--l local Grow = require("EdenAndNether_Extra_scripts.enemies.The_Grow_Chain") ent = Grow.release_grow(Game():GetPlayer(0)) ent.Position = Vector(200,200) ent.Velocity = Vector(0,0)
--l local Grow = require("EdenAndNether_Extra_scripts.enemies.The_Grow_Chain") Grow.physicsParams.maxControlInfluence = 0.5

function item.release_grow(ent, dir, params)
    params = params or {}
    local d = ent:GetData()
    
    -- 创建藤蔓末端实体
    local endEnt = Isaac.Spawn(909, item.entity, 0, params.startpos or ent.Position, Vector(0,0), ent):ToNPC()
    local endData = endEnt:GetData()
    
    -- 初始化藤蔓数据
    endData[item.own_key.."effect"] = {
        linker = ent,  -- 起点实体
        linkee = {},   -- 分段实体
        direction = dir or Vector(1,0),  -- 发射方向
        speed = params.speed or 10,      -- 发射速度
        maxLength = params.maxLength or 200,  -- 最大长度
        currentLength = 0,
        isPlayerSource = ent.Type == EntityType.ENTITY_PLAYER,  -- 添加是否为玩家发射的标记
        retractTimer = params.retractTimer,
        startpos = params.startpos,
        negfirst = params.negfirst,
        noCatch = params.noCatch,
        depthoffset = params.depthoffset,
    }
    
    if ent:HasEntityFlags(EntityFlag.FLAG_FRIENDLY) then endData[item.own_key.."effect"].isPlayerSource = true end

    -- 设置碰撞属性
    if endData[item.own_key.."effect"].isPlayerSource then
        -- 玩家发射时，与敌人和障碍物碰撞
        endEnt.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ENEMIES
        --endEnt.GridCollisionClass = GridCollisionClass.COLLISION_WALL
    else
        -- 非玩家发射时，仅与玩家相关物体碰撞
        endEnt.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYEROBJECTS
        endEnt.GridCollisionClass = GridCollisionClass.COLLISION_NONE
    end
    
    -- 设置初始速度
    endEnt.Velocity = endData[item.own_key.."effect"].direction:Resized(endData[item.own_key.."effect"].speed)
    sound_tracker.PlayStackedSound(SoundEffect.SOUND_MEATHEADSHOOT,1,1,false,0,2) 
    return endEnt
end

table.insert(item.ToCall,#item.ToCall + 1,{CallBack = ModCallbacks.MC_ENTITY_TAKE_DMG, params = 909,
Function = function(_,ent,amt,flag,source,cooldown)
    if ent.Variant == item.entity then
        return false
    end
end,
})

table.insert(item.ToCall,#item.ToCall + 1,{CallBack = ModCallbacks.MC_POST_NPC_INIT, params = 909,
Function = function(_,ent)
    if ent.Variant == item.entity then
        local s = ent:GetSprite()
        local d = ent:GetData()
        local anim = s:GetAnimation()
        ent.State = 12
        ent.PositionOffset = Vector(0,-3)
        s:Play("None",true)
    end
end,
})

table.insert(item.ToCall,#item.ToCall + 1,{CallBack = ModCallbacks.MC_POST_NPC_RENDER, params = 909,
Function = function(_,ent)
    if (Game():GetRoom():GetRenderMode() ~= RenderMode.RENDER_WATER_REFLECT) then
        if ent.Variant == item.entity then
            local d = ent:GetData()
            if d[item.own_key.."effect"] then
                -- 获取路径信息
                local path = d[item.own_key.."effect"].springSegments or {}
                local s = Sprite() 
                s:Load("gfx/monsters/grow.anm2", true)
                if (d[item.own_key.."Block"] or 0) == 1 then 
                    s:ReplaceSpritesheet(0,"gfx/monsters/grow_fall.png") s:LoadGraphics()
                    --s.Color = auxi.AddColor(s.Color,Color(1,0.5,0.5,1),0.5,0.5) 
                end
                
                local segmentLength = item.segmentLength
                -- 渲染每个分段
                for i = 1, #path - 1 do
                    local frame = (#path - i - 2) % 8  -- 计算帧数
                    local pos = path[i].position
                    local nextPos = path[i+1].position
                    
                    -- 计算角度
                    local dir = (nextPos - pos):Normalized()
                    local angle = dir:GetAngleDegrees() - 90
                    
                    -- 计算拉伸比例
                    local dist = pos:Distance(nextPos)
                    local stretch = dist / segmentLength
                    
                    -- 约束拉伸比例
                    local minStretch = 0.75
                    local maxStretch = 3.0
                    stretch = math.min(math.max(stretch, minStretch), maxStretch)
                    
                    -- 计算缩放比例
                    local xScale = math.sqrt(math.sqrt(1/stretch))
                    local yScale = stretch
                    
                    -- 设置旋转和缩放
                    s.Rotation = angle
                    s.Scale = Vector(xScale, yScale)
                    
                    -- 设置帧并渲染
                    if i == 1 then 
                        s:SetFrame("WhipStart",0)
                    elseif i == #path - 1 then
                        s:SetFrame("WhipEnd",0)
                        s.Scale = Vector(1,1)
                        if d[item.own_key.."effect"].fix_dir then s.Rotation = d[item.own_key.."effect"].fix_dir - 90 end
                        if d[item.own_key.."effect"].add_dir then s.Rotation = s.Rotation + 180 end
                    else
                        s:SetFrame("WhipSliced", frame)
                    end
                    s:Render(Isaac.WorldToScreen(pos + ent.PositionOffset), Vector(0,0), Vector(0,0))
                end
            end
        end
    end
end,
})

function item.try_remove_Grow(ent)
    local d = ent:GetData()
    for u,v in pairs(d[item.own_key.."effect"].linkee) do
        if auxi.check_all_exists(v.ent) then v.ent:Remove() end
    end
end

function item.remove_Grow(ent)
    local d = ent:GetData()
    for u,v in pairs(d[item.own_key.."effect"].linkee) do
        if auxi.check_all_exists(v.ent) then v.ent:Remove() end
    end
    ent:Remove() 
end

table.insert(item.ToCall,#item.ToCall + 1,{CallBack = ModCallbacks.MC_PRE_NPC_COLLISION, params = 909,
Function = function(_,ent,col,low)
    if ent.Variant == item.entity then
        local d = ent:GetData()
        if col:ToPlayer() then
            local player = col:ToPlayer()
            if auxi.check_all_exists(player:GetData()[item.own_key.."effect"]) == true then
                return false
            end
        end 
        if d[item.own_key.."effect"] and d[item.own_key.."effect"].retractState ~= "retracting" and not d[item.own_key.."effect"].noCatch then
            local s = ent:GetSprite()
            local d = ent:GetData()
            local anim = s:GetAnimation()
            if col:ToPlayer() then
                local player = col:ToPlayer()
                if auxi.check_all_exists(player:GetData()[item.own_key.."effect"]) ~= true then
                    d[item.own_key.."effect"].retractState = "retracting"
                    d[item.own_key.."effect"].retractTimer = 0
                    d[item.own_key.."effect"].fix_dir = ent.Velocity:GetAngleDegrees()
                    player:GetData()[item.own_key.."effect"] = ent
                end
            end
        end
    end
end,
})

table.insert(item.ToCall,#item.ToCall + 1,{CallBack = ModCallbacks.MC_POST_PLAYER_UPDATE, params = nil,
Function = function(_,player)
    local d = player:GetData()
    if d[item.own_key.."effect"] then
        if auxi.check_all_exists(d[item.own_key.."effect"]) then
            local tg = d[item.own_key.."effect"]
            local dtg = tg:GetData()
            if dtg[item.own_key.."effect"] and dtg[item.own_key.."effect"].springSegments then 
                local list = dtg[item.own_key.."effect"].springSegments
                if list[#list - 1] then 
                    player.Position = Game():GetRoom():GetClampedPosition(list[#list - 1].position,-20)
                    player.Velocity = list[#list - 1].velocity
                else 
                    player.Position = Game():GetRoom():GetClampedPosition(tg.Position,-20)
                    player.Velocity = tg.Velocity
                end
            else
                player.Position = Game():GetRoom():GetClampedPosition(tg.Position,-20)
                player.Velocity = tg.Velocity
            end
            player.Velocity = Vector(0,0)
        else d[item.own_key.."effect"] = nil end
    end
end,
})

table.insert(item.ToCall,#item.ToCall + 1,{CallBack = ModCallbacks.MC_POST_PLAYER_RENDER, params = nil,
Function = function(_,player,offset)
    if (Game():GetRoom():GetRenderMode() ~= RenderMode.RENDER_WATER_REFLECT) then
        local d = player:GetData()
        if d[item.own_key.."effect"] then
            if auxi.check_all_exists(d[item.own_key.."effect"]) then
                local s = Sprite() 
                s:Load("gfx/monsters/grow.anm2", true)
                s:SetFrame("WallImpact",0)
                s.Scale = player:GetSprite().Scale
                s:Render(Isaac.WorldToScreen(player.Position + player.PositionOffset + Vector(0,-10)), Vector(0,0), Vector(0,0))
            end
        end
    end
end,
})

table.insert(item.ToCall,#item.ToCall + 1,{CallBack = ModCallbacks.MC_NPC_UPDATE, params = 909,
Function = function(_,ent)
    if ent.Variant == item.entity then
        local s = ent:GetSprite()
        local d = ent:GetData()
        local anim = s:GetAnimation()
        if d[item.own_key.."effect"] then
            local linker = d[item.own_key.."effect"].linker
            if auxi.check_all_exists(linker) ~= true then
                item.remove_Grow(ent) return
            end
            ent.DepthOffset = (d[item.own_key.."effect"].depthoffset or 0) + linker.DepthOffset - (ent.Position.Y + ent.Velocity.Y - linker.Position.Y - linker.Velocity.Y) - 2
            ent.Velocity = d[item.own_key.."effect"].direction:Resized(d[item.own_key.."effect"].speed)

            local startPos = d[item.own_key.."effect"].startpos or (linker.Position + (ent.Position - linker.Position):Normalized() * 5)
            local endPos = ent.Position
            local path = {}
            local segmentLength = item.segmentLength  -- 每个分段长度
            local totalLength = startPos:Distance(endPos)
            -- 计算目标节点数
            local targetSegmentCount = math.ceil(totalLength / segmentLength)
            targetSegmentCount = math.max(targetSegmentCount, 2)  -- 确保至少有2个分段
            
            -- 平滑过渡节点数
            local currentSegmentCount = #(d[item.own_key.."effect"].springSegments or {})
            local maxChange = 1  -- 每帧最多增加/删除1个节点
            if currentSegmentCount < targetSegmentCount then
                segmentCount = math.min(currentSegmentCount + maxChange, targetSegmentCount)
            elseif currentSegmentCount > targetSegmentCount then
                segmentCount = math.max(currentSegmentCount - maxChange, targetSegmentCount)
            else
                segmentCount = currentSegmentCount
            end
            segmentCount = math.max(segmentCount, 2)  -- 确保至少有2个分段
            -- 弹簧参数
            local stiffness = d[item.own_key.."effect"].stiffness or item.physicsParams.stiffness
            local damping = d[item.own_key.."effect"].damping or item.physicsParams.damping
            local mass = d[item.own_key.."effect"].mass or item.physicsParams.mass
            local startSpeed = (startPos - (d[item.own_key.."effect"].lastStartPos or startPos)):Length()
            local endSpeed = (endPos - (d[item.own_key.."effect"].lastEndPos or endPos)):Length()
            d[item.own_key.."effect"].lastStartPos = startPos
            d[item.own_key.."effect"].lastEndPos = endPos

            d[item.own_key.."Block"] = d[item.own_key.."Block"] or auxi.choose(0,1)
            ent.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE

            -- 根据移动速度动态调整controlInfluence
            local maxSpeed = 10  -- 最大参考速度
            local speedFactor = math.min((startSpeed + endSpeed) / 2 / maxSpeed, 1.0)
            local dynamicInfluence = auxi.Lerp(
                item.physicsParams.minControlInfluence or 0.1,
                item.physicsParams.maxControlInfluence or 0.5,
                speedFactor
            )
            
            -- 使用动态调整后的controlInfluence
            local controlInfluence = d[item.own_key.."effect"].controlInfluence or dynamicInfluence
            
            -- 初始化或获取现有分段数据
            d[item.own_key.."effect"].springSegments = d[item.own_key.."effect"].springSegments or {}
            
            -- 从头端插入/删除节点
            if #d[item.own_key.."effect"].springSegments < segmentCount then
                -- 需要增加节点
                local addCount = segmentCount - #d[item.own_key.."effect"].springSegments
                for i = 1, addCount do
                    table.insert(d[item.own_key.."effect"].springSegments, 1, {
                        position = startPos,
                        velocity = Vector(0,0)
                    })
                end
            elseif #d[item.own_key.."effect"].springSegments > segmentCount then
                -- 需要删除节点
                local removeCount = #d[item.own_key.."effect"].springSegments - segmentCount
                for i = 1, removeCount do
                    table.remove(d[item.own_key.."effect"].springSegments, 1)
                end
                if #d[item.own_key.."effect"].springSegments > 0 then
                    local firstSegment = d[item.own_key.."effect"].springSegments[1]
                    
                    -- 计算中点位置
                    local midPoint = (startPos + firstSegment.position) * 0.5
                    
                    -- 直接移动到中点位置
                    firstSegment.position = midPoint
                end
            end
            
            --[[
            if #d[item.own_key.."effect"].springSegments > 0 then
                d[item.own_key.."effect"].springSegments[1].position = startPos
                d[item.own_key.."effect"].springSegments[#d[item.own_key.."effect"].springSegments].position = endPos
            end
            d[item.own_key.."effect"].springSegments = d[item.own_key.."effect"].springSegments or {}
            for i = #d[item.own_key.."effect"].springSegments,segmentCount + 1,-1 do
                d[item.own_key.."effect"].springSegments[i] = nil
            end
            for i = 1, segmentCount do
                local t = (i-1) / (segmentCount-1)
                d[item.own_key.."effect"].springSegments[i] = d[item.own_key.."effect"].springSegments[i] or {
                    position = auxi.Lerp(startPos, endPos, t),
                    velocity = Vector(0,0)
                }
            end
            d[item.own_key.."effect"].springSegments = d[item.own_key.."effect"].springSegments or {}
            
            if #d[item.own_key.."effect"].springSegments ~= segmentCount then
                -- 初始情况处理
                if #d[item.own_key.."effect"].springSegments <= 1 then
                    -- 初始化节点数组
                    d[item.own_key.."effect"].springSegments = {}
                    for i = 1, segmentCount do
                        local t = (i-1) / (segmentCount-1)
                        d[item.own_key.."effect"].springSegments[i] = {
                            position = auxi.Lerp(startPos, endPos, t),
                            velocity = Vector(0,0)
                        }
                    end
                else
                    d[item.own_key.."effect"].springSegments[1].position = d[item.own_key.."effect"].springSegments[1].position * 0.5 + 0.5 * startPos
                    d[item.own_key.."effect"].springSegments[#d[item.own_key.."effect"].springSegments].position = d[item.own_key.."effect"].springSegments[#d[item.own_key.."effect"].springSegments].position * 0.5 + 0.5 * endPos
                    -- 计算总长度
                    local totalLength = 0
                    local lengths = {}
                    for i = 2, #d[item.own_key.."effect"].springSegments do
                        local dist = d[item.own_key.."effect"].springSegments[i-1].position:Distance(d[item.own_key.."effect"].springSegments[i].position)
                        table.insert(lengths, dist)
                        totalLength = totalLength + dist
                    end
                    
                    -- 计算新的节点间距
                    local newSpacing = totalLength / (segmentCount - 1)
                    
                    -- 重新分配节点
                    local newSegments = {}
                    local accumulatedDist = 0
                    local oldIndex = 1
                    
                    for i = 1, segmentCount do
                        -- 计算目标距离
                        local targetDist = (i-1) * newSpacing
                        
                        -- 找到对应的旧节点位置
                        while oldIndex < #lengths and accumulatedDist + lengths[oldIndex] < targetDist do
                            accumulatedDist = accumulatedDist + lengths[oldIndex]
                            oldIndex = oldIndex + 1
                        end
                        
                        -- 计算插值比例并用max/min限制范围
                        local t = (targetDist - accumulatedDist) / lengths[oldIndex]
                        t = math.max(0, math.min(1, t))  -- 替代math.clamp
                        
                        -- 使用auxi.Lerp直接插值Vector
                        local newPos = auxi.Lerp(d[item.own_key.."effect"].springSegments[oldIndex].position, d[item.own_key.."effect"].springSegments[oldIndex+1].position, t)
                        local newVel = auxi.Lerp(d[item.own_key.."effect"].springSegments[oldIndex].velocity, d[item.own_key.."effect"].springSegments[oldIndex+1].velocity, t)
                        
                        -- 创建新节点
                        newSegments[i] = {
                            position = newPos,
                            velocity = newVel
                        }
                    end
                    
                    -- 更新节点数组
                    d[item.own_key.."effect"].springSegments = newSegments
                end
            end
            
            --]]
            -- 弹簧物理模拟
            for i = 1, segmentCount do
                local seg = d[item.own_key.."effect"].springSegments[i]
                
                -- 计算目标位置
                local targetPos
                if i == 1 then
                    targetPos = startPos  -- 第一个分段固定在起点
                elseif i == segmentCount then
                    targetPos = endPos    -- 最后一个分段固定在终点
                else
                    -- 中间分段的目标位置是前后分段的中点
                    local prevSeg = d[item.own_key.."effect"].springSegments[i-1]
                    local nextSeg = d[item.own_key.."effect"].springSegments[i+1]
                    targetPos = (prevSeg.position + nextSeg.position) * 0.5
                end
                
                -- 计算弹簧力
                local displacement = targetPos - seg.position
                local springForce = displacement * stiffness
                
                -- 计算阻尼力
                local dampingForce = -seg.velocity * damping
                
                local t = (i-1)/(segmentCount-1)
                
                -- 添加全局目标位置
                local globalTarget = auxi.Lerp(startPos, endPos, t)
                local globalDisplacement = globalTarget - seg.position
                
                -- 将全局约束力加入计算
                local globalForce = globalDisplacement * (controlInfluence * stiffness)
                
                -- 更新加速度计算
                local acceleration = (springForce + dampingForce + globalForce) / mass
                seg.velocity = seg.velocity + acceleration
                seg.position = seg.position + seg.velocity
                
                -- 将结果存入path
                table.insert(path, {
                    position = seg.position,
                    frame = (i-1) % 8 + 1
                })
            end

            d[item.own_key.."effect"].linkee = (d[item.own_key.."effect"].linkee or {})
            for u,v in pairs(d[item.own_key.."effect"].linkee) do
                if auxi.check_all_exists(v.ent) ~= true then 
                    v.ent = Isaac.Spawn(909,item.entity,0,ent.Position,Vector(0,0),ent):ToNPC() 
                    v.ent:GetData()[item.own_key.."linker"] = ent
                    v.ent:GetData()[item.own_key.."Block"] = d[item.own_key.."Block"]

                    v.ent.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYEROBJECTS  -- 设置碰撞类型
                    v.ent.GridCollisionClass = GridCollisionClass.COLLISION_NONE  -- 禁用网格碰撞
                end
            end
            
            -- 计算需要的碰撞箱数量（每3个节点一个）
            local collisionCnt = math.ceil(#path / 3)
            
            -- 更新碰撞箱数量
            if #(d[item.own_key.."effect"].linkee) < collisionCnt then
                for i = #(d[item.own_key.."effect"].linkee) + 1, collisionCnt do
                    local newEnt = Isaac.Spawn(909,item.entity,0,ent.Position,Vector(0,0),ent):ToNPC()
                    newEnt:GetData()[item.own_key.."linker"] = ent
                    newEnt:GetData()[item.own_key.."Block"] = d[item.own_key.."Block"]
                    -- 根据发射者类型设置碰撞属性
                    if d[item.own_key.."effect"].isPlayerSource then
                        newEnt.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ENEMIES
                        --newEnt.GridCollisionClass = GridCollisionClass.COLLISION_WALL
                    else
                        newEnt.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYEROBJECTS
                        newEnt.GridCollisionClass = GridCollisionClass.COLLISION_NONE
                    end
                    
                    d[item.own_key.."effect"].linkee[i] = {
                        ent = newEnt,
                    }
                end
            elseif #(d[item.own_key.."effect"].linkee) > collisionCnt then
                for i = collisionCnt + 1, #(d[item.own_key.."effect"].linkee) do
                    d[item.own_key.."effect"].linkee[i].ent:Remove()
                    d[item.own_key.."effect"].linkee[i] = nil
                end
            end
            
            -- 更新碰撞箱位置
            for i = 1, collisionCnt do
                local linkee = d[item.own_key.."effect"].linkee[i]
                if linkee and linkee.ent then
                    -- 使用第i*3个节点的位置
                    local pathIndex = math.min(i * 3, #path)
                    linkee.ent.Position = path[pathIndex].position
                    linkee.ent.Velocity = Vector(0,0)  -- 防止物理引擎干扰
                    
                    -- 更新碰撞属性（防止中途改变发射者状态）
                    if d[item.own_key.."effect"].isPlayerSource then
                        linkee.ent.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ENEMIES
                        --linkee.ent.GridCollisionClass = GridCollisionClass.COLLISION_WALL
                    else
                        linkee.ent.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYEROBJECTS
                        linkee.ent.GridCollisionClass = GridCollisionClass.COLLISION_NONE
                    end
                end
            end

            d[item.own_key.."effect"].retractState = d[item.own_key.."effect"].retractState or "growing"  -- growing/retracting
            d[item.own_key.."effect"].retractTimer = d[item.own_key.."effect"].retractTimer or 0

            local room = Game():GetRoom()
            if room:IsPositionInRoom(ent.Position, 0) ~= true then  -- or segmentCount > 60
                -- 碰到墙壁，开始收回
                if d[item.own_key.."effect"].negfirst and ent.FrameCount < 30 then
                else
                    if d[item.own_key.."effect"].retractState == "growing" then
                        d[item.own_key.."effect"].retractState = "retracting"
                        d[item.own_key.."effect"].retractTimer = d[item.own_key.."effect"].retractTimer or 6 * 30  -- 设置收回时间（30帧）
                        d[item.own_key.."effect"].fix_dir = ent.Velocity:GetAngleDegrees()
                        d[item.own_key.."effect"].should_reset = true
                    end
                    
                    -- 停止移动
                    ent.Velocity = Vector(0, 0)
                end
            elseif d[item.own_key.."effect"].negfirst == true then
                d[item.own_key.."effect"].negfirst = nil
            end
            
            -- 处理收回状态
            if d[item.own_key.."effect"].retractState == "retracting" then
                d[item.own_key.."effect"].retractTimer = d[item.own_key.."effect"].retractTimer - 1
                if d[item.own_key.."effect"].retractTimer < 0 then
                    -- 计算飞向起点的方向
                    if d[item.own_key.."effect"].should_reset then
                        d[item.own_key.."effect"].fix_dir = nil
                        d[item.own_key.."effect"].add_dir = true
                        d[item.own_key.."effect"].should_reset = nil
                    end
                    local moveDir = (startPos - ent.Position):Normalized()
                    
                    -- 设置快速移动速度
                    local retractSpeed = math.min((startPos - ent.Position):Length() * 0.5,20)  -- 收回速度
                    ent.Velocity = moveDir * retractSpeed
                    if (startPos - ent.Position):Length() < 20 then 
                        d[item.own_key.."effect"].remove_counter = math.min(d[item.own_key.."effect"].remove_counter or 5,5)
                    end
                    if (startPos - ent.Position):Length() < 10 then 
                        d[item.own_key.."effect"].remove_counter = math.min(d[item.own_key.."effect"].remove_counter or 3,3)
                        d[item.own_key.."effect"].remove_counter = d[item.own_key.."effect"].remove_counter - 1
                    end
                    if (startPos - ent.Position):Length() < 5 then 
                        d[item.own_key.."effect"].remove_counter = math.min(d[item.own_key.."effect"].remove_counter or 2,2)
                        d[item.own_key.."effect"].remove_counter = d[item.own_key.."effect"].remove_counter - 1
                    end
                    if d[item.own_key.."effect"].remove_counter then
                        d[item.own_key.."effect"].remove_counter = d[item.own_key.."effect"].remove_counter - 1
                        if d[item.own_key.."effect"].remove_counter < 0 then
                            item.remove_Grow(ent)
                            return
                        end
                    end
                end
            end


        end 
        if d[item.own_key.."linker"] then
            if auxi.check_all_exists(d[item.own_key.."linker"]) ~= true then ent:Remove() return end
        end
        if d[item.own_key.."linker"] == nil and d[item.own_key.."effect"] == nil then ent:Remove() return end
    end
end,
})

table.insert(item.ToCall,#item.ToCall + 1,{CallBack = ModCallbacks.MC_POST_NEW_ROOM, params = nil,
Function = function(_)
	local tgs = auxi.getothers(nil,909,item.entity)
	for u,v in pairs(tgs) do 
        v:Remove()
	end
end,
})

table.insert(item.ToCall,#item.ToCall + 1,{CallBack = ModCallbacks.MC_PRE_TEAR_COLLISION, params = nil,	--防止橡皮擦
Function = function(_,ent,col,low)
    if ent.Type == 45 then
        if col.Variant == item.entity and col.Type == 909 then
            return true
        end
    else
        local d = col:GetData()
        if col.Variant == item.entity and d[item.own_key.."Block"] and d[item.own_key.."Block"] == 1 then return true end
    end
end,
})

return item