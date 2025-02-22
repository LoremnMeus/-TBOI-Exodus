local MODitem = RegisterMod("EDEN_AND_Nether",1)
local manager = require("EdenAndNether_Extra_scripts.core.manager_manager")
manager.Init(MODitem)

Exodus____ = {
    modref = MODitem,
}

local item = {
}

item.GoodStageAPI = StageAPI and StageAPI.Loaded
item.GoodRGON = REPENTOGON
item.showWarning = true
item.warningTimer = 0

MODitem:AddCallback(ModCallbacks.MC_POST_RENDER, function()
    if item.showWarning then
        local yOffset = 78
        
        if not item.GoodStageAPI then
            Isaac.RenderText("Exodus requires StageAPI to function fully", 100, yOffset, 255, 0, 0, 1)
            yOffset = yOffset + 12
            Isaac.RenderText("Please install StageAPI for the complete experience", 100, yOffset, 255, 0, 0, 1)
            yOffset = yOffset + 12
        end
        
        if not item.GoodRGON then
            Isaac.RenderText("Exodus recommends using Repentogon for the best experience", 100, yOffset, 255, 0, 0, 1)
            yOffset = yOffset + 12
        end
        
        -- 更新计时器
        item.warningTimer = item.warningTimer + 1
        if item.warningTimer > 600 then  -- 大约10秒后消失（60帧/秒）
            item.showWarning = false
        end
    end
end)

return item