local g = require("EdenAndNether_Extra_scripts.core.globals")
local save = require("EdenAndNether_Extra_scripts.core.savedata")
local enums = require("EdenAndNether_Extra_scripts.core.enums")
local auxi = require("EdenAndNether_Extra_scripts.auxiliary.functions")
local Attribute_holder = require("EdenAndNether_Extra_scripts.others.Attribute_holder")
local Base_holder = require("EdenAndNether_Extra_scripts.others.Base_holder")

local item = {
	ToCall = {},
	entity = enums.Enemies.Mixturer,
	prefix1 = "gfx/bosses/mixture/output/",
	prefix2 = "resources.gfx.bosses.mixture.output.",
	targets = {
		["Left"] = {
			[1] = {
				id = 1,
				type = 20,
				variant = 0,
				subtype = 0,
				tg_layer = 0,
				anm2 = "gfx/bosses/mixture/Monstro.anm2",
				anm2_data = require("resources.gfx.bosses.mixture.020_000_monstro"),
				order = function(ent)
					if ent.State == 8 then return -1
					else return 1 end
				end,
			},
			[2] = {
				id = 2,
				type = 43,
				variant = 0,
				subtype = 0,
				tg_layer = 0,
				anm2 = "gfx/bosses/mixture/043.000_monstro ii_left.anm2",
				anm2_data = require("resources.gfx.bosses.mixture.043_000_monstro ii"),
				order = function(ent)
					if ent.State == 8 then return -1
					else return 1 end
				end,
			},
		},
		["Right"] = {
			[1] = {
				id = 1,
				type = 67,
				variant = 0,
				subtype = 0,
				tg_layer = 0,
				anm2 = "gfx/bosses/mixture/the duke of flies.anm2",
				anm2_back = "gfx/bosses/mixture/the duke of flies backward.anm2",
				anm2_data = require("resources.gfx.bosses.mixture.067_000_the duke of flies"),
				order = function(ent)
					return 0
				end,
				FlipHelper = true,		--有这个标签意味着不会自动翻转，因此不必模仿。
			},
			[2] = {
				id = 2,
				type = 67,
				variant = 1,
				subtype = 0,
				tg_layer = 0,
				anm2 = "gfx/bosses/mixture/067.001_the husk_right.anm2",
				anm2_data = require("resources.gfx.bosses.mixture.067_001_the husk"),
				order = function(ent)
					return 0
				end,
				FlipHelper = true,		--有这个标签意味着不会自动翻转
			},
		},
	},
	own_key = "Boss_Mixturer_",
	swap2rate = {		--这里的参数比想象中奇怪
		{frame = 0,val = 0.9,},
		--{frame = 1,val = 0.6,},
		--{frame = 2,val = 0.45,},
		--{frame = 3,val = 0.3,},
		{frame = 30,val = 0,},
	},
	defaultval =  {
		{
			XPosition = 0,
			YPosition = -999,
			XScale = 100,
			YScale = 100,
			CombinationID = 1,
			frame = 0,
			Interpolated = true,
		},
	}
}

function item.process_entity(entity)
	local tg = {
        id = #item.targets.Left + 1,  -- 使用索引作为 ID
        type = entity.type,
        variant = entity.variant,
        subtype = entity.subtype,
        tg_layer = entity.tg_layer,
        anm2 = item.prefix1 .. entity.name .. "_left.anm2",
        anm2_data = require(item.prefix2 .. entity.name:gsub("%.", "_")),
        order = entity.order,
    }
	table.insert(item.targets.Left,tg)
	local tg = {
        id = #item.targets.Right + 1,  -- 使用索引作为 ID
        type = entity.type,
        variant = entity.variant,
        subtype = entity.subtype,
        tg_layer = entity.tg_layer,
        anm2 = item.prefix1 .. entity.name .. "_right.anm2",
        anm2_data = require(item.prefix2 .. entity.name:gsub("%.", "_")),
        order = entity.order,
    }
	table.insert(item.targets.Right,tg)
end

table.insert(item.ToCall,#item.ToCall + 1,{CallBack = ModCallbacks.MC_ENTITY_TAKE_DMG, params = nil,
Function = function(_,ent,amt,flag,source,cooldown)
	local d = ent:GetData()
    if d[item.own_key.."linkee"] then 
        return false
    end
end,
})

table.insert(item.ToCall,#item.ToCall + 1,{CallBack = ModCallbacks.MC_PRE_NPC_COLLISION, params = nil,
Function = function(_,ent,col,low)
	local d = ent:GetData()
    if d[item.own_key.."linkee"] then 
        return true
    end
end,
})

table.insert(item.ToCall,#item.ToCall + 1,{CallBack = ModCallbacks.MC_POST_NPC_INIT, params = nil,
Function = function(_,ent)
	if item.invisible_flag then ent.Visible = false end
end,
})

table.insert(item.ToCall,#item.ToCall + 1,{CallBack = ModCallbacks.MC_NPC_UPDATE, params = nil,
Function = function(_,ent)
	local d = ent:GetData()
	if d[item.own_key.."linkee"] then 
		if auxi.check_all_exists(d[item.own_key.."linkee"].linker) ~= true then ent:Remove() return end
	end
end,
})

if REPENTOGON then

table.insert(item.ToCall,#item.ToCall + 1,{CallBack = ModCallbacks.MC_PRE_NPC_RENDER, params = 20,
Function = function(_,ent)
	if ent.Variant == item.entity then
		local d = ent:GetData()
		ent:RenderShadowLayer(Vector(0,0))
		item.deal_with_mixture(ent)
	end
end,
})

else

table.insert(item.ToCall,#item.ToCall + 1,{CallBack = ModCallbacks.MC_POST_NPC_RENDER, params = 20,
Function = function(_,ent)
    if ent.Variant == item.entity then
		local d = ent:GetData()
		item.deal_with_mixture(ent)
	end
end,
})

end

table.insert(item.ToCall,#item.ToCall + 1,{CallBack = ModCallbacks.MC_ENTITY_TAKE_DMG, params = 20,
Function = function(_,ent,amt,flag,source,cooldown)
    if ent.Variant == item.entity then
		if source and source.Entity then 
			local d = source.Entity:GetData()
			if d[item.own_key.."linkee"] and auxi.check_for_the_same(d[item.own_key.."linkee"].linker,ent) then 
				return false
			end
		end
    end
end,
})

table.insert(item.ToCall,#item.ToCall + 1,{CallBack = ModCallbacks.MC_PRE_NPC_COLLISION, params = 20,
Function = function(_,ent,col,low)
    if ent.Variant == item.entity then
		local cd = col:GetData()
		if cd[item.own_key.."linkee"] then return true end
    end
end,
})

table.insert(item.ToCall,#item.ToCall + 1,{CallBack = ModCallbacks.MC_POST_NPC_INIT, params = 20,
Function = function(_,ent)
	if ent.Variant == item.entity then
		local s = ent:GetSprite()
		local d = ent:GetData()
	end
end,
})

function item.select_valid(val1,val2,type,pv1,pv2)
	if pv1 == nil then return val2 end
	if pv2 == nil then return val1 end
	if pv1 < -900 then return val2 end
	if pv2 < -900 then return val1 end
	if type == "min" then return math.min(val1,val2)
	else return math.max(val1,val2) end
end

function item.deal_with_mixture(ent)
	local s = ent:GetSprite()
	local d = ent:GetData()
	if d[item.own_key.."effect"] == nil or d[item.own_key.."effect"]["baseinfo"] == nil then return end
	local baseinfo = d[item.own_key.."effect"]["baseinfo"]
	local tg = d[item.own_key.."effect"][baseinfo.tg]
	if (tg == nil) or (auxi.check_all_exists(ent) ~= true) then return end
	local tginfo = item.targets[baseinfo.tg][tg.infoid]
	local tgs = tg.ent:GetSprite() 
	--print(tg.ent.Type.." "..tg.ent.Variant.." "..tgs:GetAnimation())
	local edval = -999 + 60
	local dedval = -999 + 60
	local stval = -999
	local now_edval = nil
	local now_stval = nil

	local tganiminfo__ = tginfo.anm2_data.Animations[tgs:GetAnimation()]
	local layer_ids = tganiminfo__.Layersheet or {tginfo.tg_layer,}
	local tglerpedinfo = nil
	local tganminfo = nil
	local g_ed_tg = nil
	for _,layer_id in pairs(layer_ids) do
		local tganiminfo = tganiminfo__.LayerAnimations[layer_id]
		if #tganiminfo == 0 then tganiminfo = item.defaultval end		--比较特殊的一点是，当overlaysprite获取好后，如果当前anim不存在，且overlaysprite存在，就要放弃获得的默认值。
		--11这类敌人把血作为overlay
		--像264超级胖胖这样的敌人需要有2个以上的tg_layer
		local i_tglerpedinfo = auxi.check_lerp(tgs:GetFrame(),tganiminfo,{banlist = {["CombinationID"] = true,["Interpolated"] = true,},shouldlerp = function(v1,v2) if v1.Interpolated == true then return true else return false end end,})
		local tgcid = i_tglerpedinfo.CombinationID
		local i_tganminfo = tginfo.anm2_data.AttributeCombinations[tginfo.anm2_data.Layers[layer_id]][tgcid]

		local tgoffsetinfo = tginfo.anm2_data.AttributeDetail[tginfo.anm2_data.Layers[layer_id]][tgcid]
		local sedval = (tgoffsetinfo['ed'] - i_tganminfo['YPivot']) * i_tglerpedinfo['YScale']/100 + i_tglerpedinfo.YPosition
		local sstval = (tgoffsetinfo['st'] - i_tganminfo['YPivot']) * i_tglerpedinfo['YScale']/100 + i_tglerpedinfo.YPosition
		edval = item.select_valid(edval,sedval,"max",now_edval,tgoffsetinfo['ed'])
		if edval == sedval then dedval = (tgoffsetinfo['ed'] - i_tganminfo['YPivot']) * i_tglerpedinfo['YScale']/100 end
		stval = item.select_valid(stval,sstval,"min",now_stval,tgoffsetinfo['st'])
		now_edval = item.select_valid(now_edval,tgoffsetinfo['ed'],"max",now_edval,tgoffsetinfo['ed'])
		now_stval = item.select_valid(now_stval,tgoffsetinfo['st'],"min",now_stval,tgoffsetinfo['st'])

		local succ = false
		if g_ed_tg == nil then succ = true
		elseif g_ed_tg < -900 and tgoffsetinfo['ed'] > -900 then succ = true end
		if succ then
			g_ed_tg = tgoffsetinfo['ed']
			tglerpedinfo = tglerpedinfo or i_tglerpedinfo
			tganminfo = tganminfo or i_tganminfo
		end
	end

	if tgs:GetOverlayAnimation() ~= "" and tginfo.anm2_data.Animations[tgs:GetAnimation()].NullAnimations then		--存在overlay
		--local nid = tginfo.anm2_data.Animations[tgs:GetAnimation()].NullAnimations.ID
		--local naniminfo = tginfo.anm2_data.Animations[tgs:GetAnimation()].NullAnimations[nid].Frames
		--local nanimlerpedinfo = auxi.check_lerp(tgs:GetFrame(),naniminfo,{banlist = {["Visible"] = true,["Interpolated"] = true,},})	--shouldlerp = function(v1,v2) if v1.Interpolated == true then return true else return false end end,

		--print("Overlayanim " .. tgs:GetOverlayAnimation())
		
		local tganiminfo_overlay__ = tginfo.anm2_data.Animations[tgs:GetOverlayAnimation()]
		local layer_ids = tganiminfo_overlay__.Layersheet or {tginfo.tg_layer,}
		for _,layer_id in pairs(layer_ids) do
			local tg_overlay_sheetid = tginfo.anm2_data.Layers[layer_id]
			local tganiminfo_overlay = tganiminfo_overlay__.LayerAnimations[layer_id]
			if #tganiminfo_overlay == 0 then print("NO Aniamtion Data!") end
			local tglerpedinfo_overlay = auxi.check_lerp(tgs:GetOverlayFrame(),tganiminfo_overlay,{banlist = {["CombinationID"] = true,["Interpolated"] = true,},shouldlerp = function(v1,v2) if v1.Interpolated == true then return true else return false end end,})
			local tgcid_overlay = tglerpedinfo_overlay.CombinationID
			local tganminfo_overlay = tginfo.anm2_data.AttributeCombinations[tg_overlay_sheetid][tgcid_overlay]
			local tgoffsetinfo_overlay = tginfo.anm2_data.AttributeDetail[tg_overlay_sheetid][tgcid_overlay]
			--nanimlerpedinfo.YPosition +
			local sedval = (tgoffsetinfo_overlay['ed'] - tganminfo_overlay['YPivot']) * tglerpedinfo_overlay['YScale']/100 + tglerpedinfo_overlay.YPosition
			local sstval = (tgoffsetinfo_overlay['st'] - tganminfo_overlay['YPivot']) * tglerpedinfo_overlay['YScale']/100 + tglerpedinfo_overlay.YPosition
			edval = item.select_valid(edval,sedval,"max",now_edval,tgoffsetinfo_overlay['ed'])
			if edval == sedval then dedval = (tgoffsetinfo_overlay['ed'] - tganminfo_overlay['YPivot']) * tglerpedinfo_overlay['YScale']/100 end
			stval = item.select_valid(stval,sstval,"min",now_stval,tgoffsetinfo_overlay['st'])
			now_edval = item.select_valid(now_edval,tgoffsetinfo_overlay['ed'],"max",now_edval,tgoffsetinfo_overlay['ed'])
			now_stval = item.select_valid(now_stval,tgoffsetinfo_overlay['st'],"min",now_stval,tgoffsetinfo_overlay['st'])
			
		end
	end

	--print(edval.." "..stval)
	d[item.own_key.."effect"][baseinfo.tg].recordlist = {scale = auxi.Vector2Table(tgs.Scale),offset = auxi.Vector2Table(tgs.Offset),flipX = auxi.Bool2str(tgs.FlipX),color = auxi.color2table(tgs.Color),}

	local val_real = 0
	tgs.Scale = Vector(tgs.Scale.X,d[item.own_key.."scaleoffset"] or tgs.Scale.Y)
	local yscaleoffset = 1
	--local tgoffset = (tgoffsetinfo['ed'] - tganminfo['YPivot']) * tglerpedinfo['YScale']/100 * tgs.Scale.Y
	for u,v in pairs(item.targets) do
		if d[item.own_key.."effect"][u] and auxi.check_all_exists(d[item.own_key.."effect"][u].ent) then
			if u == baseinfo.tg then
			else 
				local this = d[item.own_key.."effect"][u]
				local thiss = this.ent:GetSprite() local thisd = this.ent:GetData()
				d[item.own_key.."effect"][u].recordlist = {scale = auxi.Vector2Table(thiss.Scale),offset = auxi.Vector2Table(thiss.Offset),flipX = auxi.Bool2str(thiss.FlipX),color = auxi.color2table(thiss.Color),}
				local thisinfo = item.targets[u][this.infoid]
				--print(this.ent.Type.." "..this.ent.Variant.." "..thiss:GetAnimation())
				local edval_ = -999 + 60
				local dedval_ = -999 + 60
				local sstval = -999
				local now_edval_ = nil
				local now_stval_ = nil			
				local g_thislerpedinfo = nil
				local g_thisanminfo = nil
				local g_ed_tg = nil

				local thisaniminfo__ = thisinfo.anm2_data.Animations[thiss:GetAnimation()]
				local layer_ids = thisaniminfo__.Layersheet or {thisinfo.tg_layer,}
				for _,layer_id in pairs(layer_ids) do
					local thisaniminfo = thisaniminfo__.LayerAnimations[layer_id]
					if #thisaniminfo == 0 then thisaniminfo = item.defaultval end
					local thislerpedinfo = auxi.check_lerp(thiss:GetFrame(),thisaniminfo,{banlist = {["CombinationID"] = true,["Interpolated"] = true,},shouldlerp = function(v1,v2) if v1.Interpolated == true then return true else return false end end,})
					local thiscid = thislerpedinfo.CombinationID
					local thisanminfo = thisinfo.anm2_data.AttributeCombinations[thisinfo.anm2_data.Layers[layer_id]][thiscid]
					local thisoffsetinfo = thisinfo.anm2_data.AttributeDetail[thisinfo.anm2_data.Layers[layer_id]][thiscid]

					local sedval_ = (thisoffsetinfo['ed'] - thisanminfo['YPivot']) * thislerpedinfo['YScale']/100 + thislerpedinfo.YPosition
					local sstval_ = (thisoffsetinfo['st'] - thisanminfo['YPivot']) * thislerpedinfo['YScale']/100 + thislerpedinfo.YPosition
					edval_ = item.select_valid(edval_,sedval_,"max",now_edval_,thisoffsetinfo['ed'])
					if edval_ == sedval_ then dedval_ = (thisoffsetinfo['ed'] - thisanminfo['YPivot']) * thislerpedinfo['YScale']/100 end
					stval_ = item.select_valid(stval_,sstval_,"min",now_stval_,thisoffsetinfo['st'])
					now_edval_ = item.select_valid(now_edval_,thisoffsetinfo['ed'],"max",now_edval_,thisoffsetinfo['ed'])
					now_stval_ = item.select_valid(now_stval_,thisoffsetinfo['st'],"min",now_stval_,thisoffsetinfo['st'])

					local succ = false
					if g_ed_tg == nil then succ = true
					elseif g_ed_tg < -900 and thisoffsetinfo['ed'] > -900 then succ = true end
					if succ then
						g_ed_tg = thisoffsetinfo['ed']
						g_thislerpedinfo = thislerpedinfo
						g_thisanminfo = thisanminfo
					end
				end
				
				--local edval_ = (thisoffsetinfo['ed'] - thisanminfo['YPivot']) * thislerpedinfo['YScale']/100
				--local stval_ = (thisoffsetinfo['st'] - thisanminfo['YPivot']) * thislerpedinfo['YScale']/100
				--875这个敌人非常特殊
				--存在问题。例如燃烧胖胖的火焰是在另一个overlayeffect上。
				if thiss:GetOverlayAnimation() ~= "" and thisinfo.anm2_data.Animations[thiss:GetAnimation()].NullAnimations then		--存在overlay
					--local nid = thisinfo.anm2_data.Animations[thiss:GetAnimation()].NullAnimations.ID
					--local naniminfo = thisinfo.anm2_data.Animations[thiss:GetAnimation()].NullAnimations[nid].Frames
					--local nanimlerpedinfo = auxi.check_lerp(thiss:GetFrame(),naniminfo,{banlist = {["Visible"] = true,["Interpolated"] = true,},})	--shouldlerp = function(v1,v2) if v1.Interpolated == true then return true else return false end end,
			
					--print("Overlayanim " .. thiss:GetOverlayAnimation())
					
					local thisaniminfo_overlay__ = thisinfo.anm2_data.Animations[thiss:GetOverlayAnimation()]
					local layer_ids = thisaniminfo_overlay__.Layersheet or {thisinfo.tg_layer,}
					for _,layer_id in pairs(layer_ids) do
						local this_overlay_sheetid = thisinfo.anm2_data.Layers[layer_id]
						local thisaniminfo_overlay = thisaniminfo_overlay__.LayerAnimations[layer_id]
						if #thisaniminfo_overlay == 0 then print("NO Aniamtion Data!") end
						local thislerpedinfo_overlay = auxi.check_lerp(thiss:GetOverlayFrame(),thisaniminfo_overlay,{banlist = {["CombinationID"] = true,["Interpolated"] = true,},shouldlerp = function(v1,v2) if v1.Interpolated == true then return true else return false end end,})
						local thiscid_overlay = thislerpedinfo_overlay.CombinationID
						local thisanminfo_overlay = thisinfo.anm2_data.AttributeCombinations[this_overlay_sheetid][thiscid_overlay]
						local thisoffsetinfo_overlay = thisinfo.anm2_data.AttributeDetail[this_overlay_sheetid][thiscid_overlay]
						--nanimlerpedinfo.YPosition +
						local sedval = (thisoffsetinfo_overlay['ed'] - thisanminfo_overlay['YPivot']) * thislerpedinfo_overlay['YScale']/100 + thislerpedinfo_overlay.YPosition
						local sstval = (thisoffsetinfo_overlay['st'] - thisanminfo_overlay['YPivot']) * thislerpedinfo_overlay['YScale']/100 + thislerpedinfo_overlay.YPosition
						edval_ = item.select_valid(edval_,sedval,"max",now_edval_,thisoffsetinfo_overlay['ed'])
						if edval_ == sedval then dedval_ = (thisoffsetinfo_overlay['ed'] - thisanminfo_overlay['YPivot']) * thislerpedinfo_overlay['YScale']/100 end
						stval_ = item.select_valid(stval_,sstval,"min",now_stval_,thisoffsetinfo_overlay['st'])
						now_edval_ = item.select_valid(now_edval_,thisoffsetinfo_overlay['ed'],"max",now_edval_,thisoffsetinfo_overlay['ed'])
						now_stval_ = item.select_valid(now_stval_,thisoffsetinfo_overlay['st'],"min",now_stval_,thisoffsetinfo_overlay['st'])
					end
				end

				--print(edval_.." "..stval_)

				if (now_edval_ or -999) < -900 then val_real = now_edval_ end

				local delta = (edval - stval) / (edval_ - stval_) * tgs.Scale.Y
				thiss.Scale = Vector(thiss.Scale.X,math.sqrt(delta))		--thiss.Scale = Vector(thiss.Scale.X,delta)
				yscaleoffset = yscaleoffset / math.sqrt(delta)			--换成这样就没法做三切割，必须是十字切割
				
				local thisoffset = dedval_ * thiss.Scale.Y
				
				if tginfo.FlipHelper ~= true then 		--如何扩展成2个以上的敌人呢？
					thiss.FlipX = tgs.FlipX 
				else tgs.FlipX = thiss.FlipX end
				if g_thislerpedinfo.XScale < 0 then thiss.FlipX = not thiss.FlipX end

				thisd[item.own_key.."TMPrecord"] = {XPosition = g_thisanminfo['Width']/2 - g_thisanminfo['XPivot'] + g_thislerpedinfo.XPosition,YPosition = g_thislerpedinfo.YPosition,offset = thisoffset,}		--thisanminfo['Height']/2 - thisanminfo['YPivot'] + 
				--thiss.Offset = Vector(tglerpedinfo.XPosition * tgs.Scale.X - thislerpedinfo.XPosition * thiss.Scale.X,tglerpedinfo.YPosition * tgs.Scale.Y - thiss.Scale.Y * thislerpedinfo.YPosition + (tgoffset - thisoffset))
			end
		end
	end
	if tglerpedinfo.XScale < 0 then tgs.FlipX = not tgs.FlipX end
	tgs.Scale = Vector(tgs.Scale.X,yscaleoffset * (d[item.own_key.."scaleoffset"] or tgs.Scale.Y))
	local tgoffset_new = (dedval) * tgs.Scale.Y
	local swaprate = auxi.check_lerp(d[item.own_key.."swap_counter"] or 0,item.swap2rate).val
	d[item.own_key.."swap_val"] = (d[item.own_key.."swap_val"] or 0)
	if d[item.own_key.."swap_enable"] then
		d[item.own_key.."swap_enable"] = nil
		if d[item.own_key.."swap_counter"] == 0 then
			d[item.own_key.."swap_val"] = (d[item.own_key.."swaped_val"] or 0) - tgoffset_new		--起到润滑的作用
			--print(d[item.own_key.."swap_val"])
		end
		d[item.own_key.."swaped_val"] = tgoffset_new
	end
	local real_val = d[item.own_key.."swap_val"] * swaprate + val_real
	tgs.Offset = Vector(0,real_val)		-- + tgoffset_new - tgoffset
	--print(tgs.Offset)
	for u,v in pairs(item.targets) do
		if d[item.own_key.."effect"][u] and auxi.check_all_exists(d[item.own_key.."effect"][u].ent) then
			if u == baseinfo.tg then
			else 
				local this = d[item.own_key.."effect"][u]
				local thiss = this.ent:GetSprite() local thisd = this.ent:GetData()
				local iinfo = thisd[item.own_key.."TMPrecord"]
				if iinfo then 
					thiss.Offset = Vector((tganminfo['Width']/2 - tganminfo['XPivot'] + tglerpedinfo.XPosition) * tgs.Scale.X - iinfo.XPosition * thiss.Scale.X,(tglerpedinfo.YPosition) * tgs.Scale.Y - thiss.Scale.Y * iinfo.YPosition + real_val + tgoffset_new - iinfo.offset)		--tganminfo['Height']/2 - tganminfo['YPivot'] + 
				end
			end
		end
	end
	local c = nil if not auxi.equalcolor(ent:GetSprite().Color,Color(1,1,1,1)) then c = ent:GetSprite().Color end
	local offset = (d[item.own_key.."recordposoffset"] or Vector(0,0)) - (d[item.own_key.."posoffset"] or Vector(0,0))
	for u,v in pairs(item.targets) do
		local vv = d[item.own_key.."effect"][u] local vd = vv.ent:GetData() local vs = vv.ent:GetSprite()
		local info = v[vv.infoid]
		if info.anm2_back then
			local render_offset = Isaac.WorldToScreen(ent.Position + ent.PositionOffset) + offset
			local s2 = auxi.copy_sprite(vs,nil,{filename = info.anm2_back,})
			s2:Render(render_offset)
		end
	end
	for i = 1,2 do 
		local u = "Left" if i == 2 then u = "Right" end
		local v = item.targets[u]
	--for u,v in pairs(item.targets) do
		if d[item.own_key.."effect"] and d[item.own_key.."effect"][u] and auxi.check_all_exists(d[item.own_key.."effect"][u].ent) then
			local vv = d[item.own_key.."effect"][u]
			vv.ent:GetSprite().Color = c or vv.ent:GetSprite().Color
			vv.ent.Visible = true
			local room = Game():GetRoom()
			local delta = Isaac.WorldToScreen(ent.Position + ent.PositionOffset) - Isaac.WorldToScreen(vv.ent.Position) + room:GetRenderScrollOffset() + Game().ScreenShakeOffset
			local render_offset = Isaac.WorldToScreen(ent.Position + ent.PositionOffset) + offset
			vv.ent:Render(offset + delta)
			vv.ent.Visible = false
			local ves = vv.ent:GetSprite()
			ves.Scale = auxi.ProtectVector(vv.recordlist.scale or ves.Scale)
			ves.Offset = auxi.ProtectVector(vv.recordlist.offset or ves.Offset)
			ves.FlipX = auxi.str2Bool(vv.recordlist.flipX or ves.FlipX)
			ves.Color = auxi.table2color(vv.recordlist.color or ves.Color)
		end
	end
end

--l local q = Isaac.Spawn(20,747,0,Vector(360,280),Vector(0,0),nil):ToNPC() local mix = require("EdenAndNether_Extra_scripts.bosses.Boss_Mixturer") local d = q:GetData() d[mix.own_key.."effect"] = {} d[mix.own_key.."effect"]["Left"] = {infoid = 1,} d[mix.own_key.."effect"]["Right"] = {infoid = 1,}
table.insert(item.ToCall,#item.ToCall + 1,{CallBack = ModCallbacks.MC_NPC_UPDATE, params = 20,
Function = function(_,ent)
	if ent.Variant == item.entity then
		local s = ent:GetSprite()
		local d = ent:GetData()
		d[item.own_key.."effect"] = d[item.own_key.."effect"] or {}
		for u,v in pairs(item.targets) do
			if d[item.own_key.."effect"][u] == nil then
				local st = ent.SubType
				if st == 0 then info = v[1]
				elseif st == 1 then info = v[2]
				else info = auxi.random_in_table(v) end
				d[item.own_key.."effect"][u] = {infoid = info.id,}
			end

			local info = v[d[item.own_key.."effect"][u].infoid]
			if auxi.check_all_exists(d[item.own_key.."effect"][u].ent) ~= true then
				item.invisible_flag = true
				if d[item.own_key.."effect"][u].ent then d[item.own_key.."effect"][u].ent:Remove() end
				local tp = info.type local vr = info.variant or 0 local st = info.subtype or 0 local real_st = st 
				if real_st == 0 then real_st = 929 end
				item.locked = true
				local q = Isaac.Spawn(tp,vr,real_st,ent.Position,Vector(0,0),ent):ToNPC()
				if q.SubType ~= st then q.SubType = st end
				item.locked = nil
				q:GetData()[item.own_key.."linkee"] = {linker = ent,}
				--q:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
				local qs = q:GetSprite() local anim = qs:GetAnimation()
				if info.anm2 then qs:Load(info.anm2,true) qs:Play(anim,true) end
				d[item.own_key.."effect"][u].ent = q
				item.invisible_flag = false
			end
			d[item.own_key.."effect"][u].ent.Visible = false
		end
		d[item.own_key.."effect"]["baseinfo"] = d[item.own_key.."effect"]["baseinfo"] or {tg = "Left",}
		
		if not d[item.own_key.."effect"].init then
			d[item.own_key.."effect"].init = {}
			d[item.own_key.."effect"].size = d[item.own_key.."effect"].size or 0
			for u,v in pairs(item.targets) do
				local ve = d[item.own_key.."effect"][u]
				d[item.own_key.."effect"].size = math.max(d[item.own_key.."effect"].size,ve.ent.Size)
			end
		end
		ent.Size = d[item.own_key.."effect"].size
		if REPENTOGON then ent:SetShadowSize(ent.Size/100) end		--之后可以重写shadow图像，以操控非RGON的影子

		local baseinfo = d[item.own_key.."effect"]["baseinfo"]
		local tg = d[item.own_key.."effect"][baseinfo.tg]
		local tgname = baseinfo.tg
		local tginfo = item.targets[baseinfo.tg][tg.infoid]
		local largest_order = auxi.check_if_any(tginfo.order,tg.ent)
		d[item.own_key.."swap_counter"] = (d[item.own_key.."swap_counter"] or 0) + 1
		d[item.own_key.."swap_enable"] = true
		for u,v in pairs(item.targets) do
			local this = d[item.own_key.."effect"][u]
			local thisinfo = item.targets[u][this.infoid]
			local thisorder = auxi.check_if_any(thisinfo.order,this.ent)
			if thisorder > largest_order then 
				tg = this tgname = u
				largest_order = thisorder
				d[item.own_key.."swap_counter"] = 0
			end
		end
		if d[item.own_key.."swap_counter"] == 0 then
			for u,v in pairs(item.targets) do
				local this = d[item.own_key.."effect"][u]
				local thisd = this.ent:GetData()
				if thisd[item.own_key.."GridCollision"] then Attribute_holder.try_rewind_attribute(this.ent,"GridCollisionClass",thisd[item.own_key.."GridCollision"]) thisd[item.own_key.."GridCollision"] = nil end
			end
		end
		d[item.own_key.."effect"]["baseinfo"].tg = tgname
		d[item.own_key.."recordposoffset"] = (d[item.own_key.."recordposoffset"] or tg.ent.PositionOffset) * 0.9 + 0.1 * tg.ent.PositionOffset		--这里不对
		d[item.own_key.."posoffset"] = tg.ent.PositionOffset
		local baseinfo = d[item.own_key.."effect"]["baseinfo"]
		local tg = d[item.own_key.."effect"][baseinfo.tg]
		for u,v in pairs(item.targets) do
			--d[item.own_key.."effect"][u].ent.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
			if u == baseinfo.tg then
				d[item.own_key.."effect"][u].ent.Size = ent.Size
			else 
				d[item.own_key.."effect"][u].ent.Size = 0
				local this = d[item.own_key.."effect"][u]
				this.ent.Position = tg.ent.Position
				this.ent.TargetPosition = tg.ent.Position		--有一些敌人会把targetposition作为方向，这可真麻烦。我得去获取danger_data。
				this.ent.PositionOffset = tg.ent.PositionOffset + tg.ent.Position - this.ent.Position
				this.ent.Velocity = tg.ent.Velocity
			end
		end
		--item.deal_with_mixture(ent)
		d[item.own_key.."effect"]["Right"].ent.DepthOffset = -5
		local tgs = tg.ent:GetSprite() local scale_offset = tgs.Scale.Y
		
		for u,v in pairs(item.targets) do		--似乎反了，要转化为拉伸
			if u ~= baseinfo.tg then
				local this = d[item.own_key.."effect"][u]
				local thiss = this.ent:GetSprite() local thisd = this.ent:GetData()
				scale_offset = scale_offset * thiss.Scale.Y
				local thisd = this.ent:GetData()
				thisd[item.own_key.."GridCollision"] = thisd[item.own_key.."GridCollision"] or Attribute_holder.try_hold_attribute(this.ent,"GridCollisionClass",function(ent) return tg.ent.GridCollisionClass end)
			end
		end
		d[item.own_key.."scaleoffset"] = scale_offset
		ent.EntityCollisionClass = tg.ent.EntityCollisionClass
		ent.GridCollisionClass = tg.ent.GridCollisionClass
		ent.Position = tg.ent.Position
		ent.Velocity = tg.ent.Velocity
	end
end,
})

table.insert(item.ToCall,#item.ToCall + 1,{CallBack = ModCallbacks.MC_POST_NPC_INIT, params = 20,
Function = function(_,ent)
    if StageAPI then
        if ent.Variant == 0 and not item.locked then
			local hp = ent.MaxHitPoints
			Base_holder.try_convert(ent,{type = 20,variant = item.entity,subtype = 0,})
			ent.HitPoints = hp
			ent.MaxHitPoints = hp
        end
    end
end,
})

table.insert(item.ToCall,#item.ToCall + 1,{CallBack = ModCallbacks.MC_POST_NPC_INIT, params = 67,
Function = function(_,ent)
    if StageAPI then
        if ent.Variant == 0 and not item.locked then
			local hp = ent.MaxHitPoints
			Base_holder.try_convert(ent,{type = 20,variant = item.entity,subtype = 0,})
			ent.HitPoints = hp
			ent.MaxHitPoints = hp
        end
    end
end,
})

if HPBars then
	for u,v in pairs(item.targets) do
		for uu,vv in pairs(v) do
			local ID = vv.type.."."..vv.variant
			HPBars.BossIgnoreList[ID] = auxi.add_function(HPBars.BossIgnoreList[ID] or function() return nil end,function(ent)
				if ent:GetData()[item.own_key.."linkee"] then return true end
			end)
		end
	end
	local path = HPBars.iconPath.."exodus/"
	local ID = "20."..item.entity
	HPBars.BossDefinitions[ID] = {
		sprite = path .. "mixstro.png",
		offset = Vector(-5, 0)
	};
end

return item