local enums = require("EdenAndNether_Extra_scripts.core.enums")
local auxi = require("EdenAndNether_Extra_scripts.auxiliary.functions")
local delay_buffer = require("EdenAndNether_Extra_scripts.auxiliary.delay_buffer")
local item = {
	ToCall = {},
}

if EID then
local languages = {
	["en_us"] = "EdenAndNether_Extra_scripts.translations.EID_en",
	["zh_cn"] = "EdenAndNether_Extra_scripts.translations.EID_zh",
}

local item_buff_map = {
	["bookOfVirtuesWisps"] = "BookOfVirtues",
	["bookOfBelialBuffs"] = "BookOfBelial",
	["abyssSynergies"] = "AbyssSynic",
}
local pickup_buff_map = {
	["reverieSeijaBuffs"] = "SeijaBuff",
	["reverieSeijaNerfs"] = "SeijaNerf",
}

for u,v in pairs(languages) do
	local EIDInfo = include(v)
	local languageCode = u
	for id, pk in pairs(EIDInfo.Pickups) do
		EID:addEntity(5, pk.Variant, pk.SubType, pk.Name, pk.Description, languageCode)
	end

	if EIDInfo.Slots then
		for u, v in pairs(EIDInfo.Slots) do
			EID:addEntity(6, u, 0, v.Name, v.Description, languageCode)
		end
	end
end

end

return item