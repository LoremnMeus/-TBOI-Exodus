local g = require("EdenAndNether_Extra_scripts.core.globals")
local save = require("EdenAndNether_Extra_scripts.core.savedata")
local enums = require("EdenAndNether_Extra_scripts.core.enums")
local auxi = require("EdenAndNether_Extra_scripts.auxiliary.functions")
local Damage_holder = require("EdenAndNether_Extra_scripts.others.Damage_holder")
local sound_tracker = require("EdenAndNether_Extra_scripts.auxiliary.sound_tracker")
local delay_buffer = require("EdenAndNether_Extra_scripts.auxiliary.delay_buffer")
local Base_holder = require("EdenAndNether_Extra_scripts.others.Base_holder")
local Knife_info = require("EdenAndNether_Extra_scripts.others.Knife_info")

local item = {
	ToCall = {},
    own_key = "EAN_Blossoms_",
    entity = enums.Enemies.Blossoms1,
    mx_buffs = 5,
    rocket_frame = 40,
    copy_attributes = {
        Height = true,
        ProjectileFlags = true,
        Scale = true,
        Acceleration = true,
        FallingSpeed = true,
        FallingAccel = true,
    },
    unbuffinfo = {
        [1] = {
            init = function(ent,td,info,item)
                local q = Isaac.Spawn(613,enums.Enemies.Blossom_Baby,2,ent.Position,Vector(0,0),ent):ToNPC()
                local qs = q:GetSprite() qs:Play("IdleRight",true) 
                local qd = q:GetData() qd[item.own_key.."effect"] = {linker = ent,}
                td.linkee = td.linkee or {}
                table.insert(td.linkee,q)
                td.finish = nil
            end,
            update = function(ent,td,info,item)
                td.linkee = td.linkee or {}
                for i = #td.linkee,1,-1 do
                    local v = td.linkee[i]
                    if auxi.check_all_exists(v) ~= true then table.remove(td.linkee,i) end
                end
                local last_one = ent
                for i = #td.linkee,1,-1 do
                    local v = td.linkee[i]
                    v:GetData()[item.own_key.."effect"] = v:GetData()[item.own_key.."effect"] or {linker = ent,}
                    local vd = v:GetData()[item.own_key.."effect"]
                    vd.prev = last_one
                    vd._id = i
                    vd._mid = #td.linkee
                    last_one = v
                end
                if #td.linkee <= 0 then
                    info.finish(ent,td,info,item)
                end
            end,
            finish = function(ent,td,info,item)
                if not td.finish then 
                    td.finish = {counter = 0,}
                end
            end,
        },
        [2] = {
            init = function(ent,td,info,item)
                local q = Isaac.Spawn(613,enums.Enemies.Blossom_Baby,0,ent.Position,Vector(0,0),ent):ToNPC()
                local qd = q:GetData() qd[item.own_key.."effect"] = {linker = ent,}
                td.linkee = td.linkee or {}
                table.insert(td.linkee,q)
                td.finish = nil
            end,
            update = function(ent,td,info,item)
                td.linkee = td.linkee or {}
                for i = #td.linkee,1,-1 do
                    local v = td.linkee[i]
                    if auxi.check_all_exists(v) ~= true then table.remove(td.linkee,i) end
                end
                local last_one = ent
                for i = #td.linkee,1,-1 do
                    local v = td.linkee[i]
                    v:GetData()[item.own_key.."effect"] = v:GetData()[item.own_key.."effect"] or {linker = ent,}
                    local vd = v:GetData()[item.own_key.."effect"]
                    vd.prev = last_one
                    last_one = v
                end
                if #td.linkee <= 0 then
                    info.finish(ent,td,info,item)
                end
            end,
            finish = function(ent,td,info,item)
                if not td.finish then 
                    td.finish = {counter = 0,}
                end
            end,
        },
        [3] = {
            init = function(ent,td,info,item)
                td.counter = (td.counter or 0) + 1
                td.finish = nil
            end,
            ondeath = function(ent,td,info,item)
                local cnt = td.counter or 1
                td.counter = 0
                for i = 1,cnt do
                    local q = Isaac.Spawn(1000,enums.Entities.Blossom_Seeds,0,ent.Position,Vector(0,0),nil):ToEffect() local qs = q:GetSprite()
                    qs:ReplaceSpritesheet(0,"gfx/monsters/blossoms/seed_"..tostring(3)..".png") qs:LoadGraphics() qs:Play("Idle",true)
                    q:GetData()[item.own_key.."effect"] = {tg = ent,mx_time = auxi.choose(15,20,25),height = auxi.choose(20,40,60,80,100),id = id,tgpos = ent.Position + auxi.random_r() * (auxi.random_1() * 0.5 + 0.5) * (30 + i * 4),on_death = function(et)
                        Game():BombExplosionEffects(et.Position,1,0,Color(0,1,0,1,0,1,0),et)
                    end,}
                end
                info.finish(ent,td,info,item)
            end,
            finish = function(ent,td,info,item)
                if not td.finish then 
                    td.finish = {counter = 0,}
                end
            end,
        },
        [4] = {
            init = function(ent,td,info,item)
                local q = Isaac.Spawn(613,enums.Enemies.Blossom_Baby,3,ent.Position,Vector(0,0),ent):ToNPC()
                local qd = q:GetData() qd[item.own_key.."effect"] = {linker = ent,}
                td.linkee = td.linkee or {}
                table.insert(td.linkee,q)
                td.finish = nil
            end,
            update = function(ent,td,info,item)
                td.linkee = td.linkee or {}
                for i = #td.linkee,1,-1 do
                    local v = td.linkee[i]
                    if auxi.check_all_exists(v) ~= true then table.remove(td.linkee,i) end
                end
                local last_one = ent
                for i = #td.linkee,1,-1 do
                    local v = td.linkee[i]
                    v:GetData()[item.own_key.."effect"] = v:GetData()[item.own_key.."effect"] or {linker = ent,}
                    local vd = v:GetData()[item.own_key.."effect"]
                    vd.prev = last_one
                    last_one = v
                end
                if #td.linkee <= 0 then
                    info.finish(ent,td,info,item)
                end
            end,
            finish = function(ent,td,info,item)
                if not td.finish then 
                    td.finish = {counter = 0,}
                end
            end,
        },
        [5] = {
            init = function(ent,td,info,item)
                local q = Isaac.Spawn(613,enums.Enemies.Blossom_Baby,1,ent.Position,Vector(0,0),ent):ToNPC()
                local qs = q:GetSprite() qs:Play("Idle",true)
                local qd = q:GetData() qd[item.own_key.."effect"] = {linker = ent,}
                td.linkee = td.linkee or {}
                table.insert(td.linkee,q)
                td.finish = nil
            end,
            update = function(ent,td,info,item)
                td.linkee = td.linkee or {}
                for i = #td.linkee,1,-1 do
                    local v = td.linkee[i]
                    if auxi.check_all_exists(v) ~= true then table.remove(td.linkee,i) end
                end
                for i = #td.linkee,1,-1 do
                    local v = td.linkee[i]
                    v:GetData()[item.own_key.."effect"] = v:GetData()[item.own_key.."effect"] or {linker = ent,}
                    local vd = v:GetData()[item.own_key.."effect"]
                    vd._id = i
                    vd._mid = #td.linkee
                end
                if #td.linkee <= 0 then
                    info.finish(ent,td,info,item)
                end
            end,
            finish = function(ent,td,info,item)
                if not td.finish then 
                    td.finish = {counter = 0,}
                end
            end,
        },
    },
    decay_alpha = {
        {frame = 0,val = 1,},
        {frame = 30,val = 0,},
    },
}

table.insert(item.ToCall,#item.ToCall + 1,{CallBack = ModCallbacks.MC_NPC_UPDATE, params = 613,
Function = function(_,ent)
    if ent.Variant == enums.Enemies.Blossom_Baby then
        local s = ent:GetSprite()
        local d = ent:GetData()
        local anim = s:GetAnimation() local fr = s:GetFrame() local finished = s:IsFinished(anim)
        ent:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
        if not d[item.own_key.."effect"] then return end
        if ent.SubType == 0 then 
            local state = "Float" if anim:sub(1,10) == "FloatShoot" then state = "FloatShoot" end
            if state == "FloatShoot" and fr == 15 then state = "Float" fr = 0 end
            if state == "Float" then 
                d[item.own_key.."effect"].counter = (d[item.own_key.."effect"].counter or 0) + 1
                if d[item.own_key.."effect"].counter > 32 then 
                    d[item.own_key.."effect"].counter = 0
                    state = "FloatShoot"
                    fr = 0
                end
            end
            if auxi.check_all_exists(d[item.own_key.."effect"].linker) ~= true then
                d[item.own_key.."effect"] = nil
                ent:Kill()
                return
            end
            local tg = d[item.own_key.."effect"].linker
            if auxi.check_all_exists(d[item.own_key.."effect"].prev) then tg = d[item.own_key.."effect"].prev end
            local dir = tg.Position - ent.Position
            local rdir = math.max(0,dir:Length() - 20) * dir:Normalized()
            if ent.FrameCount > 15 and rdir:Length() > 100 then 
                ent.Position = ent.Position + rdir
                rdir = Vector(0,0)
            end
            ent.Velocity = rdir
            ent.Velocity = auxi.apply_friction(ent.Velocity,1)
            
            local lk = d[item.own_key.."effect"].linker
            local lktg = auxi.get_acceptible_target(lk)
            local dir = lktg.Position - lk.Position
            local ang = auxi.GetDirectionByAngle(dir:GetAngleDegrees())
            local anm = auxi.GetDirName(ang)
            if ang == Direction.LEFT then s.FlipX = true else s.FlipX = false end
            if (state .. anm) ~= anim then
                anim = state .. anm
                s:SetFrame(anim,fr) s:Play(anim,true)
            end
            if state == "FloatShoot" and fr == 6 then
                local dir = auxi.getanglefromdir(ang)
                local vel = dir * 7.5 + ent.Velocity
                local q = Isaac.Spawn(9,0,0,ent.Position,vel,ent):ToProjectile() local qs = q:GetSprite()
                qs:Load("gfx/monsters/blossoms/MudTears.anm2",true) qs:Play("RegularTear6",true) q:Update()
                sound_tracker.PlayStackedSound(SoundEffect.SOUND_TEARS_FIRE,1,1,false,0,2)
            end
        end
        if ent.SubType == 1 then        --魂火
            if auxi.check_all_exists(d[item.own_key.."effect"].linker) ~= true then
                d[item.own_key.."effect"] = nil
                ent:Kill()
                return
            end
            s.Color = Color(1,1,0,1,0.3,0.1,0) 
            local tg = d[item.own_key.."effect"].linker
            if auxi.check_all_exists(d[item.own_key.."effect"].prev) then tg = d[item.own_key.."effect"].prev end
            if d[item.own_key.."effect"]._id and d[item.own_key.."effect"]._mid then
                local rot = 360 * d[item.own_key.."effect"]._id/d[item.own_key.."effect"]._mid + tg.FrameCount * 5
                local dir_pos = tg.Position + auxi.get_by_rotate(nil,rot,tg.Size + 10)
                ent.Velocity = dir_pos - ent.Position
            else 
                ent.Velocity = tg.Position - ent.Position
            end
            ent.Velocity = auxi.apply_friction(ent.Velocity,1)
        end
        if ent.SubType == 2 then        --大宝剑
            if anim == "AttackRight" then
                if finished then
                    d[item.own_key.."effect"].flip_id = (d[item.own_key.."effect"].flip_id or 0) + 1
                    s:Play("IdleRight",true)
                    anim = "IdleRight"
                end
            end
            if anim == "IdleRight" then
                s:SetFrame("IdleRight",0)
                d[item.own_key.."effect"].counter = (d[item.own_key.."effect"].counter or 0) + 1
                d[item.own_key.."effect"].mxcounter = d[item.own_key.."effect"].mxcounter or auxi.choose(30,60,90,120)
                if d[item.own_key.."effect"].counter > d[item.own_key.."effect"].mxcounter then 
                    d[item.own_key.."effect"].mxcounter = auxi.choose(30,60,90,120)
                    d[item.own_key.."effect"].counter = 0
                    s:Play("AttackRight",true)
                    anim = "AttackRight"
                end
            end
            ent.DepthOffset = -10
            if auxi.check_all_exists(d[item.own_key.."effect"].linker) ~= true then
                d[item.own_key.."effect"] = nil
                ent:Kill()
                return
            end
            local lk = d[item.own_key.."effect"].linker
            local lktg = auxi.get_acceptible_target(lk)
            local dir = lktg.Position - lk.Position
            local idir = 1
            s.Rotation = dir:GetAngleDegrees() + 180
            if d[item.own_key.."effect"]._id and d[item.own_key.."effect"]._mid then
                if (d[item.own_key.."effect"]._id + (d[item.own_key.."effect"].flip_id or 0)) % 2 == 0 then 
                    if anim == "AttackRight" then s.Rotation = s.Rotation - 90 end
                    s.Rotation = 180 - s.Rotation
                    s.FlipX = true 
                    idir = -1
                else
                    s.FlipX = false
                    if anim == "AttackRight" then s.Rotation = s.Rotation + 90 end
                end
                s.Rotation = s.Rotation + 60 * (d[item.own_key.."effect"]._id/d[item.own_key.."effect"]._mid - 0.5) * idir
            end
            if anim == "AttackRight" and fr == 2 then 
                sound_tracker.PlayStackedSound(SoundEffect.SOUND_SWORD_SPIN,1,1,false,0,2)
            end
            Knife_info.calculate_hitbox(ent,{collide = function(player,ent,box)
                player:TakeDamage(1,0,EntityRef(ent),30)
            end,})
            ent.Velocity = lk.Position - ent.Position
        end
        if ent.SubType == 3 then        --多维宝宝
            if auxi.check_all_exists(d[item.own_key.."effect"].linker) ~= true then
                d[item.own_key.."effect"] = nil
                ent:Kill()
                return
            end
            local tg = d[item.own_key.."effect"].linker
            if auxi.check_all_exists(d[item.own_key.."effect"].prev) then tg = d[item.own_key.."effect"].prev end
            d[item.own_key.."effect"].recordwindow = d[item.own_key.."effect"].recordwindow or {}
            local mx_val = 15
            if #d[item.own_key.."effect"].recordwindow < mx_val then 
                for i = #d[item.own_key.."effect"].recordwindow + 1,mx_val do
                    d[item.own_key.."effect"].recordwindow[i] = auxi.Vector2Table(tg.Position)
                end
            end
            table.insert(d[item.own_key.."effect"].recordwindow,auxi.Vector2Table(tg.Position))
            local dpos = auxi.ProtectVector(d[item.own_key.."effect"].recordwindow[1])
            table.remove(d[item.own_key.."effect"].recordwindow,1)
            local dir = dpos - ent.Position
            local rdir = math.max(0,dir:Length() - 20) * dir:Normalized()
            if ent.FrameCount > 15 and rdir:Length() > 100 then 
                ent.Position = ent.Position + rdir
                rdir = Vector(0,0)
            end
            ent.Velocity = rdir
            ent.Velocity = auxi.apply_friction(ent.Velocity,1)
            
            local tgs = Isaac.FindInRadius(ent.Position,14,1<<1)
            for u,v in pairs(tgs) do
                if v.SpawnerType ~= 9 then
                    local succ = true
                    if v:GetData()[item.own_key.."multieffect"] then
                        if v:GetData()[item.own_key.."multieffect"].banish then succ = false end
                        if v:GetData()[item.own_key.."multieffect"][ent.InitSeed] then succ = false end
                    end
                    if succ then
                        v:GetData()[item.own_key.."multieffect"] = v:GetData()[item.own_key.."multieffect"] or {}
                        v:GetData()[item.own_key.."multieffect"][ent.InitSeed] = true
                        v:GetData()[item.own_key.."multieffect"].counter = (v:GetData()[item.own_key.."multieffect"].counter or 0) + 1
                        local cnt = v:GetData()[item.own_key.."multieffect"].counter
                        local q = Isaac.Spawn(9,0,0,v.Position,v.Velocity * math.max(0.3,(1 - cnt * 0.05)),ent):ToProjectile() local qs = q:GetSprite()
                        qs:Load("gfx/monsters/blossoms/MudTears.anm2",true) qs:Play("RegularTear6",true) q:Update()
                        local qd = q:GetData() qd[item.own_key.."multieffect"] = {banish = true,}
                        for u_,v_ in pairs(item.copy_attributes) do
                            q[u_] = v:ToProjectile()[u_]
                        end
                    end
                end
            end
        end
    end
end,
})


table.insert(item.ToCall,#item.ToCall + 1,{CallBack = ModCallbacks.MC_PRE_NPC_COLLISION, params = 613,
Function = function(_,ent,col,low)
    if ent.Variant == enums.Enemies.Blossom_Baby then
        if col:ToNPC() then
            return true
        end
    end
end,
})

table.insert(item.ToCall,#item.ToCall + 1,{CallBack = ModCallbacks.MC_POST_NPC_INIT, params = 88,
Function = function(_,ent)
    if ent.Variant == item.entity then
        local s = ent:GetSprite()
        local d = ent:GetData()
        local anim = s:GetAnimation()
        if ent.SubType == 4 then 
            s:SetOverlayRenderPriority(true)
            s:PlayOverlay("Fire",true)
        end
    end
end,
})

function item.is_blossoms(ent)
    if ent.Type == 613 and ent.Variant == enums.Enemies.Blossom_Baby then return true end
    if ent.Type == 88 and ent.Variant == item.entity then return true else return false end
end

function item.has_buff(ent,id)
    id = id or 1
    local d = ent:GetData()
    if d[item.own_key.."unbuff"..tostring(id)] then return true end
end

function item.get_buff_targets(id)
    return auxi.getenemies(nil,function(et)
        if item.has_buff(et,id) ~= true and not item.is_blossoms(et) then return true else return false end
    end)
end

function item.add_buff(ent,id,params)
    params = params or {}
    local d = ent:GetData()
    d[item.own_key.."unbuff"..tostring(id)] = d[item.own_key.."unbuff"..tostring(id)] or {}
    local td = d[item.own_key.."unbuff"..tostring(id)]
    if params.pos then
        local q = Isaac.Spawn(1000,enums.Entities.Blossom_Seeds,0,params.pos,Vector(0,0),nil):ToEffect() local qs = q:GetSprite()
        qs:ReplaceSpritesheet(0,"gfx/monsters/blossoms/seed_"..tostring(id)..".png") qs:LoadGraphics() qs:Play("Idle",true)
        q:GetData()[item.own_key.."effect"] = {tg = ent,mx_time = auxi.choose(35,40,45),height = auxi.choose(160,200,240),id = id,}
        if not td.inited then
            td.inited = true
            td.init = {linker = q,counter = 0,}
        end
    end
end

table.insert(item.ToCall,#item.ToCall + 1,{CallBack = ModCallbacks.MC_POST_EFFECT_UPDATE, params = enums.Entities.Blossom_Seeds,
Function = function(_,ent)
    local d = ent:GetData()
    if d[item.own_key.."effect"] then
        local tg = d[item.own_key.."effect"].tg 
        if auxi.check_all_exists(tg) ~= true then d[item.own_key.."effect"].tg = nil tg = ent end
        local tgpos = d[item.own_key.."effect"].tgpos or tg.Position
        local dir = tgpos - ent.Position
        d[item.own_key.."effect"].counter = (d[item.own_key.."effect"].counter or 0) + 1
        local cnt = d[item.own_key.."effect"].counter
        local mx_time = d[item.own_key.."effect"].mx_time or item.rocket_frame
        local div = (mx_time - cnt) if math.abs(div) < 1 then div = 1 end
        ent.Velocity = dir/div
        local height = - auxi.calculate_height_base_on_rate(cnt/mx_time,d[item.own_key.."effect"].height or 200)
        ent.PositionOffset = Vector(0,height - 20)
        local delta = Vector(0,- height - auxi.calculate_height_base_on_rate((cnt + 1)/mx_time,d[item.own_key.."effect"].height or 200)) + ent.Velocity
        ent:GetSprite().Rotation = delta:GetAngleDegrees() - 90
        if cnt > mx_time then 
            if auxi.check_all_exists(d[item.own_key.."effect"].tg) then 
                local id = d[item.own_key.."effect"].id or 0
                local tinfo = item.unbuffinfo[id] or {}
                auxi.check_if_any(tinfo.init,d[item.own_key.."effect"].tg,d[item.own_key.."effect"].tg:GetData()[item.own_key.."unbuff"..tostring(id)] or {},tinfo,item)      --这个时机是否正确？
            end
            auxi.check_if_any(d[item.own_key.."effect"].on_death,ent)
            ent:Remove() return 
        end
    end
end,
})

function item.add_buffs(cnt,id,params)
    params = params or {}
    id = id or 1
    cnt = cnt or 1
    local tgs = auxi.randomTable(item.get_buff_targets(id))
    for i = 1,math.min(#tgs,cnt) do
        local v = tgs[i]
        item.add_buff(v,id,params)
    end
    if cnt > #tgs then
        local mcnt = cnt - #tgs
        local tgs2 = auxi.randomTable(auxi.getenemies(nil,function(et)
            if not item.is_blossoms(et) then return true else return false end
        end))
        for i = 1,math.min(#tgs2,mcnt) do
            local v = tgs2[i]
            item.add_buff(v,id,params)
        end
    end
end

function item.get_render_list(ent)
    local d = ent:GetData()
    local tbl = {}
    for id = 1,item.mx_buffs do
        if d[item.own_key.."unbuff"..tostring(id)] and not (d[item.own_key.."unbuff"..tostring(id)].init) then
            table.insert(tbl,id)
        end
        local vid = 1000 + id
        if d[item.own_key.."unbuff"..tostring(vid)] and not (d[item.own_key.."unbuff"..tostring(vid)].init)  then
            table.insert(tbl,vid)
        end
    end
    return tbl
end

local Buff_spr = Sprite() Buff_spr:Load("gfx/effects/unbuff/Buffs.anm2",true) Buff_spr:Play("Idle",true)
table.insert(item.ToCall,#item.ToCall + 1,{CallBack = ModCallbacks.MC_POST_NPC_RENDER, params = nil,
Function = function(_,ent,offset)
    local d = ent:GetData()
    local buff_renders = item.get_render_list(ent)
    local room = Game():GetRoom()
    if #buff_renders > 0 and (room:GetRenderMode() ~= RenderMode.RENDER_WATER_REFLECT) then
        local offsetY = -20
        if REPENTOGON then
            local s = ent:GetSprite()
            local overlay = s:GetNullFrame("OverlayEffect")
            if overlay then 
                if overlay:IsVisible() == false then return end
                offsetY = overlay:GetPos().Y 
            end
        end
        for i = 1,#buff_renders do
            local v = buff_renders[i]
            local vi = (i - (#buff_renders + 1)/2)/(math.sqrt(#buff_renders))
            local alpha = 1
            if (d[item.own_key.."unbuff"..tostring(v)] or {}).finish then
                alpha = auxi.check_lerp(d[item.own_key.."unbuff"..tostring(v)].finish.counter or 0,item.decay_alpha).val
            end
            Buff_spr.Color = Color(1,1,1,alpha)
			Buff_spr:ReplaceSpritesheet(0,"gfx/effects/unbuff/unbuff_"..tostring(v)..".png")
		    Buff_spr:LoadGraphics()
            Buff_spr:SetFrame("Idle",(i * 3 + ent.FrameCount) % 16)
            local offset = Vector(20 * vi,offsetY)
			Buff_spr:Render(Isaac.WorldToScreen(ent.Position + ent.PositionOffset) + offset - room:GetRenderScrollOffset() - Game().ScreenShakeOffset)
            Buff_spr.Color = Color(1,1,1,1)
        end
    end
end,
})

table.insert(item.ToCall,#item.ToCall + 1,{CallBack = ModCallbacks.MC_NPC_UPDATE, params = nil,
Function = function(_,ent)
    local d = ent:GetData()
    for id = 1,item.mx_buffs do
        if d[item.own_key.."unbuff"..tostring(id)] then
            local td = d[item.own_key.."unbuff"..tostring(id)]
            local tinfo = item.unbuffinfo[id] or {}
            if td.init then
                td.init.counter = (td.init.counter or 0) + 1
                if (auxi.check_exists(td.init.linker) ~= true) or td.init.counter > 240 then 
                    td.init = nil 
                    --auxi.check_if_any(tinfo.init,ent,td,tinfo,item)
                end
            else
                auxi.check_if_any(tinfo.update,ent,td,tinfo,item)
                if ent:HasMortalDamage() then
                    auxi.check_if_any(tinfo.ondeath,ent,td,tinfo,item)
                end
                if td.finish then 
                    td.finish.counter = (td.finish.counter or 0) + 1
                    if td.finish.counter >= 30 then
                        d[item.own_key.."unbuff"..tostring(id)] = nil 
                    end
                end
            end
        end
    end
end,
})

table.insert(item.ToCall,#item.ToCall + 1,{CallBack = ModCallbacks.MC_NPC_UPDATE, params = 88,
Function = function(_,ent)
    if ent.Variant == item.entity then
        local s = ent:GetSprite()
        local d = ent:GetData()
        local anim = s:GetAnimation()
        if ent.SubType == 2 then
            if s:IsFinished("Shoot") then
                Game():BombExplosionEffects(ent.Position,1,0,Color(0,1,0,1,0,1,0),ent)
                item.add_buffs(auxi.choose(3,4,5),3,{pos = ent.Position,})
                ent:Kill()
            end
        end
        if s:IsEventTriggered("Shoot2") then
            local st = ent.SubType + 1
            item.add_buffs(1,st,{pos = ent.Position,})
        end
    end
end,
})

return item