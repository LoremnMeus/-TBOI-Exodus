local g = require("EdenAndNether_Extra_scripts.core.globals")
local save = require("EdenAndNether_Extra_scripts.core.savedata")
local enums = require("EdenAndNether_Extra_scripts.core.enums")
local auxi = require("EdenAndNether_Extra_scripts.auxiliary.functions")
local sound_tracker = require("EdenAndNether_Extra_scripts.auxiliary.sound_tracker")
local AI = require("EdenAndNether_Extra_scripts.bosses.Boss_All")

local item = {
	ToCall = {},
	entity = enums.Enemies.Maid_in_the_Mist,
	own_key = "Boss_Maid_in_the_Mist_",
	Swapper = {
		["Appear"] = "Idle",
	},
	SwapperOverlay = {
		["FireLargeLight"] = "FireLarge",
		["FireLargeGone"] = "Fire",
	},
	AnimInfo = {
		["Default"] = {
			{frame = 0,offset = 0,sx = 1,sy = 1,},
		},
		["Idle"] = {
			{frame = 0,offset = 0,sx = 1,sy = 1,},
			{frame = 2,offset = 1,sx = 1.05,sy = 0.95,},
			{frame = 6,offset = 0,sx = 1,sy = 1,},
			{frame = 8,offset = -1,sx = 0.95,sy = 1.05,},
		},
		["Attack"] = {
			{frame = 0,offset = 0,sx = 1,sy = 1,},
			{frame = 2,offset = 2,sx = 1,sy = 1,},
			{frame = 3,offset = 2,sx = 0.9,sy = 1.1,},
			{frame = 4,offset = 2,sx = 0.95,sy = 1.05,},
			{frame = 5,offset = 2,sx = 1,sy = 1,},
			{frame = 12,offset = 2,sx = 0.9,sy = 1.1,},
			{frame = 15,offset = 2,sx = 0.8,sy = 1.2,},
			{frame = 17,offset = 0,sx = 1,sy = 1,},
		},
	},
	dir2vec = {
		Left = Vector(-1,0),
		Right = Vector(1,0),
		Up = Vector(0,-1),
		Down = Vector(0,1),
	},
}

function item.all_finish(ent)
	local tgs = Isaac.GetRoomEntities() 
	for u,v in pairs(tgs) do
		if v.SpawnerEntity and auxi.check_for_the_same(v.SpawnerEntity,ent) == true and (v.Position - ent.Position):Length() < 200 then return false end
	end
	return true
end

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

table.insert(item.ToCall,#item.ToCall + 1,{CallBack = ModCallbacks.MC_POST_PROJECTILE_UPDATE, params = nil,
Function = function(_,ent)
	local d = ent:GetData()
	if ent:IsDead() and d[item.own_key.."kill"] then ent:Remove() return end
	if d[item.own_key.."fade"] then
		ent.Color = auxi.AddColor(ent.Color,Color(0,0,0,-0.04),1,1)
		if ent.Color.A < 0.05 then ent:Remove() return end
	end
	if d[item.own_key.."effect"] then
		if ent.FrameCount % 10 == 5 then
			local q = Isaac.Spawn(9,0,0,ent.Position,Vector(0,0),ent):ToProjectile()
			local qs = q:GetSprite() local qd = q:GetData() q:Update() 
			if d[item.own_key.."effect"].blue then
				qs:Load("gfx/bosses/maid_of_the_mist/blue_fly_proj.anm2",true) qs:Play("Idle",true)
			else
				qs:Load("gfx/bosses/maid_of_the_mist/yellow_fly_proj.anm2",true) qs:Play("Idle",true)
			end
			qd[item.own_key.."kill"] = true
			qd[item.own_key.."fade"] = true
			--q:GetSprite().Color = Color(46/255,164/255,179/255,1,46/255,164/255,179/255)
		end
		ent.FallingAccel = -0.1
		ent.GridCollisionClass = 0
		local tg = d[item.own_key.."effect"].linker
		if d[item.own_key.."effect"].surround ~= true and d[item.own_key.."effect"].blue ~= true then
			if auxi.check_all_exists(tg) then
				local dpos = tg.Position - ent.Position
				if dpos:Length() < 40 + ent.FrameCount * 3 then
					d[item.own_key.."effect"].surround = true 
				end
			end
		end
		if d[item.own_key.."effect"].surround and auxi.check_all_exists(tg) then
			local tgpos = auxi.get_by_rotate(tg.Position - ent.Position,90,d[item.own_key.."effect"].vel:Length())
			local tpos = auxi.get_by_rotate(tg.Position - ent.Position,-90,d[item.own_key.."effect"].vel:Length())
			if (tpos - ent.Velocity):Length() < (tgpos - ent.Velocity):Length() then tgpos = tpos end
			ent.Velocity = ent.Velocity * 0.75 + 0.25 * tgpos * 1.5
		else
			ent.Velocity = ent.Velocity * 0.9 + 0.1 * (d[item.own_key.."effect"].vel or ent.Velocity)
		end

		local room = Game():GetRoom()
		if (room:IsPositionInRoom(ent.Position,0) ~= true and ent.FrameCount > 300) or ent.FrameCount > 9000 then
			ent.Color = auxi.AddColor(ent.Color,Color(0,0,0,-0.02),1,1)
			if ent.Color.A < 0.1 then ent:Remove() return end
		end
	end
end,
})

table.insert(item.ToCall,#item.ToCall + 1,{CallBack = ModCallbacks.MC_NPC_UPDATE, params = 613,
Function = function(_,ent)
	if ent.Variant == item.entity then
		local s = ent:GetSprite()
		local d = ent:GetData()
		local anim = s:GetAnimation()
		local frame = s:GetFrame()
		local overlayanim = s:GetOverlayAnimation()
		ent.GridCollisionClass = 0
		local hprate = ent.HitPoints/ent.MaxHitPoints
		d[item.own_key.."render_Update"] = true
		d[item.own_key.."counter"] = (d[item.own_key.."counter"] or 30)
		if item.all_finish(ent) and anim == "Idle" and d[item.own_key.."effect"] == nil then
			d[item.own_key.."counter"] = d[item.own_key.."counter"] + 1
			if d[item.own_key.."counter"] >= 60 then	--!! 1
				local dir = auxi.choose("Left","Right","Up","Down")
				local action = "Attack"..dir
				d[item.own_key.."effect"] = {dir = dir,cnt = 0,mxcnt = auxi.choose(2,3,4),}
				if hprate < 0.33 then 
					d[item.own_key.."effect"].v1 = auxi.choose(1,2)
					d[item.own_key.."effect"].v2 = 1
					d[item.own_key.."effect"].basecnt = auxi.choose(1,2,3)
				elseif hprate < 0.66 then
					d[item.own_key.."effect"].v1 = auxi.choose(1,2)
					d[item.own_key.."effect"].basecnt = auxi.choose(0,1,2)
				else
					d[item.own_key.."effect"].v1 = 1
				end
				s:Play(action,true)
				d[item.own_key.."counter"] = 0
			end 
		end

		for _ = 1,1 do 
		if d[item.own_key.."effect"] then
			if hprate < 0.66 then d[item.own_key.."effect"].move = true end
			d[item.own_key.."effect"].cnt = (d[item.own_key.."effect"].cnt or 0) + 1
			if d[item.own_key.."effect"].cnt % 40 == 39 then
				d[item.own_key.."effect"].nowcnt = (d[item.own_key.."effect"].nowcnt or 0) + 1
				if d[item.own_key.."effect"].v2 == 1 then d[item.own_key.."effect"].v1 = auxi.choose(1,2) end
				if d[item.own_key.."effect"].nowcnt > (d[item.own_key.."effect"].mxcnt or 2) then
					d[item.own_key.."effect"] = nil
					break
				else
					local dir = auxi.choose("Left","Right","Up","Down")
					local action = "Attack"..dir
					d[item.own_key.."effect"].dir = dir
					s:Play(action,true)
				end
			end
			if d[item.own_key.."effect"].v1 == 1 then
				if d[item.own_key.."effect"].cnt % 40 == 5 then
					local room = Game():GetRoom()
					local dir = item.dir2vec[d[item.own_key.."effect"].dir]
					local endPos = item.findWallPosition((ent.Position + room:GetCenterPos()) * 0.5,- dir) + dir * 10
					local p1 = item.findWallPosition(endPos,auxi.get_by_rotate(dir,90))
					local p2 = item.findWallPosition(endPos,auxi.get_by_rotate(dir,-90))
					local mx_dpos = endPos - p1
					if (endPos - p2):Length() > mx_dpos:Length() then
						mx_dpos = p2 - endPos
					end
					d[item.own_key.."effect"].count = auxi.choose(3,4) + (d[item.own_key.."effect"].nowcnt or 0) + (d[item.own_key.."effect"].basecnt or 0)
					--if d[item.own_key.."effect"].flip then d[item.own_key.."effect"].count = (d[item.own_key.."effect"].count or 3) - 1
					--else d[item.own_key.."effect"].count = (d[item.own_key.."effect"].count or 3) + 1 end
					local cnt = d[item.own_key.."effect"].count
					local st = endPos - mx_dpos local delta = mx_dpos * 2/cnt
					local uiv = auxi.choose(0,1,2)
					local rnd = auxi.choose(0,1,2)
					local rcnt = math.random(cnt + 1)
					local rcnt2 = math.random(cnt + 4)
					for i = 1,cnt do
						local ui = math.abs(i - (cnt + 1)/2)/(cnt + 1/2) + 0.5
						if uiv == 0 then ui = math.sqrt(ui) elseif uiv == 2 then ui = ui * ui end
						local rpos = st + delta * (i - 0.5)
						local q = Isaac.Spawn(9,0,0,rpos - dir * (60 - ui * 20),dir * 0.5,ent):ToProjectile() q:Update()
						local qs = q:GetSprite() local qd = q:GetData()
						qd[item.own_key.."kill"] = true	qd[item.own_key.."effect"] = {linker = ent,dir = dir,vel = dir * (4 + rnd + 6 * ui)}
						if rcnt == i or rcnt2 == i then 
							qd[item.own_key.."effect"].blue = true
							qs:Load("gfx/bosses/maid_of_the_mist/blue_fly.anm2",true) qs:Play("Idle",true)
						else
							qs:Load("gfx/bosses/maid_of_the_mist/yellow_fly.anm2",true) qs:Play("Idle",true)
						end
					end
					--if cnt >= 8 then d[item.own_key.."effect"].flip = true end
					--if cnt <= 3 then d[item.own_key.."effect"].flip = nil end
				end
			elseif d[item.own_key.."effect"].v1 == 2 then
				if d[item.own_key.."effect"].cnt % 40 == 5 then
					local room = Game():GetRoom()
					local basedir = item.dir2vec[d[item.own_key.."effect"].dir]
					local cnt = 8
					local rnd = auxi.choose(0,1,2)
					local rcnt = nil
					for i = 1,cnt do
						local dir = auxi.get_by_rotate(nil,i/cnt * 360,1)
						if auxi.do_t(dir,basedir) > 0.8 then rcnt = i end
						local stpos = ent.Position - dir * 400
						local q = Isaac.Spawn(9,0,0,stpos,dir * 0.5,ent):ToProjectile() q:Update()
						local qs = q:GetSprite() local qd = q:GetData()
						qd[item.own_key.."kill"] = true	qd[item.own_key.."effect"] = {linker = ent,dir = dir,vel = dir * (8 + rnd)}
						if rcnt == i then 
							qd[item.own_key.."effect"].blue = true
							qs:Load("gfx/bosses/maid_of_the_mist/blue_fly.anm2",true) qs:Play("Idle",true)
						else
							qs:Load("gfx/bosses/maid_of_the_mist/yellow_fly.anm2",true) qs:Play("Idle",true)
						end
					end
				end
			end
			if d[item.own_key.."effect"].move then
				local tg = auxi.get_acceptible_target(ent)
				if d[item.own_key.."effect"].movecnt then 
					d[item.own_key.."effect"].movecnt = d[item.own_key.."effect"].movecnt - 1
					if d[item.own_key.."effect"].movecnt < 0 then d[item.own_key.."effect"].movecnt = nil end
				end
				if AI.is_clear(ent,{endname = "MoveInval",}) and not d[item.own_key.."effect"].movecnt and ((d[item.own_key.."effect"].cnt or 0) % 40 >= 30) then
					local dir = tg.Position - ent.Position
					local stpos = ent.Position
					local id = auxi.choose(1,-1)
					local endpos = Game():GetRoom():GetClampedPosition(auxi.get_by_rotate(dir,id * auxi.choose(0,15,30),auxi.choose(60,80,100,120)) + tg.Position,-20)
					local p1 = auxi.get_by_rotate(dir,180 - id * auxi.choose(60,75,90),auxi.choose(80,100,120)) + tg.Position
					local p2 = auxi.get_by_rotate(dir,id * auxi.choose(60,75,90),auxi.choose(100,120,140)) + tg.Position
					local tbl = auxi.make_lerp({cnt = 1,mul = 20,})
					tbl = auxi.set_to(tbl,auxi.cut_by(function(val) return auxi.Bezier({stpos,stpos,stpos,p1,p2,endpos,endpos,endpos,},val) end,20),"pos")
					local totaltime = auxi.choose(60,75,90,120)
					AI.move_in_inval(ent,tbl,totaltime)
					ent.TargetPosition = endpos
					d[item.own_key.."effect"].movecnt = totaltime + 30
				end
			end
		end
		end

		if s:IsFinished(anim) then
			local tg = auxi.check_if_any(item.Swapper[anim],ent) or "Idle"
			s:Play(tg,true)
		end
		if d[item.own_key.."render_sprite_flame"] then
			local os = d[item.own_key.."render_sprite_flame"] local overlayanim = os:GetAnimation()
			if os:IsFinished(overlayanim) then
				local tg = auxi.check_if_any(item.SwapperOverlay[overlayanim],ent) or "Fire"
				os:Play(tg,true)
			end
			if overlayanim == "Fire" and hprate < 0.66 and hprate > 0.33 then
				os:Play("FireLargeLight",true)
                sound_tracker.PlayStackedSound(SoundEffect.SOUND_FLAME_BURST,1,1,false,0,2)
			elseif overlayanim == "FireLarge" and hprate < 0.33 then
				os:Play("FireLargeGone",true)
			end
		end
		--d[item.own_key.."overlayanim"] = 
		--[[
		if overlayanim ~= "" and s:IsOverlayFinished(overlayanim) then
			local tg = auxi.check_if_any(item.SwapperOverlay[overlayanim],ent) or "Fire"
			s:PlayOverlay(tg,true)
		end
		if overlayanim == "Fire" and hprate < 0.66 and hprate > 0.33 then
			s:PlayOverlay("FireLargeLight",true)
		elseif overlayanim == "FireLarge" and hprate < 0.33 then
			s:PlayOverlay("FireLargeGone",true)
		end
		]]
		AI.Control_Move(ent)
		ent.Velocity = auxi.apply_friction(ent.Velocity,1)
	end
end,
})

if REPENTOGON then		--懒得写非RGON版了，反正不影响战斗
	table.insert(item.ToCall,#item.ToCall + 1,{CallBack = ModCallbacks.MC_PRE_NPC_RENDER, params = 613,
	Function = function(_,ent,offset)
		if ent.Variant == item.entity then
			local s = ent:GetSprite()
			local d = ent:GetData()
			local anim = s:GetAnimation()
			local frame = s:GetFrame()
			if d[item.own_key.."render_sprite"] == nil then
				local s2 = auxi.copy_sprite(s,nil,{SetOverLayFrame = true,})
				s2:Play("Soul",true)
				d[item.own_key.."render_sprite"] = s2
			end
			local s2 = d[item.own_key.."render_sprite"]
			if d[item.own_key.."render_Update"] then s2:Update() end
			local room = Game():GetRoom()
			if (room:GetRenderMode() ~= RenderMode.RENDER_WATER_REFLECT) then
				s2:Render(Isaac.WorldToScreen(ent.Position + ent.PositionOffset) + offset - room:GetRenderScrollOffset() - Game().ScreenShakeOffset)
			end
			--if d[item.own_key.."render_Update"] then d[item.own_key.."render_Update"] = nil end
		end
	end,
	})
end

table.insert(item.ToCall,#item.ToCall + 1,{CallBack = ModCallbacks.MC_POST_NPC_RENDER, params = 613,
Function = function(_,ent,offset)
	if ent.Variant == item.entity then
		local s = ent:GetSprite()
		local d = ent:GetData()
		local anim = s:GetAnimation()
		local frame = s:GetFrame()

		if d[item.own_key.."render_sprite_flame"] == nil then
			local s2 = auxi.copy_sprite(s)
			s2:Play("Fire",true)
			d[item.own_key.."render_sprite_flame"] = s2
		end
		local s2 = d[item.own_key.."render_sprite_flame"]
		if d[item.own_key.."render_Update"] then s2:Update() end
		local animinfo = item.AnimInfo[anim] or item.AnimInfo["Default"]
		if anim:sub(1,6) == "Attack" then animinfo = item.AnimInfo["Attack"] end
		local frameinfo = auxi.check_lerp(frame,animinfo)
		local room = Game():GetRoom()
		if (room:GetRenderMode() ~= RenderMode.RENDER_WATER_REFLECT) then
			s2.Scale = Vector(frameinfo.sx,frameinfo.sy)
			s2.Offset = Vector(0,frameinfo.offset)
			s2:Render(Isaac.WorldToScreen(ent.Position + ent.PositionOffset) + offset - room:GetRenderScrollOffset() - Game().ScreenShakeOffset)
			s2.Scale = Vector(1,1)
			s2.Offset = Vector(0,0)
		end

		if d[item.own_key.."render_Update"] then d[item.own_key.."render_Update"] = nil end
	end
end,
})

table.insert(item.ToCall,#item.ToCall + 1,{CallBack = ModCallbacks.MC_POST_NPC_INIT, params = 613,
Function = function(_,ent)
	if ent.Variant == item.entity then
		local s = ent:GetSprite()
		local d = ent:GetData()
		ent.PositionOffset = Vector(0,-10)
		--s:PlayOverlay("Fire",true)
		s.PlaybackSpeed = 0.5
		ent.TargetPosition = Game():GetRoom():GetCenterPos()
		AI.basic(ent,{special = function(et)
			local dir = et.TargetPosition - et.Position
			et.Velocity = dir:Normalized() * math.min(dir:Length(),4)
		end,})
	end
end,
})

if HPBars then
	local path = HPBars.iconPath.."exodus/"
	local ID = "613."..item.entity
	HPBars.BossDefinitions[ID] = {
		sprite = path .. "motm.png",
		offset = Vector(-5, 0)
	};
end

return item