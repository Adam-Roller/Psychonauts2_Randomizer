local M = {}
-- These Classes receive BeginPlay calls near the end of a level loading so code can run assuming most items are loaded
M.late_level_actors = { 
    ["COLU_C"] = true, 
    ["HOLL_CLASS_C"] = true, 
    ["HQIN_C"] = true, 
    ["LOBO_C"] = true,
    ["QUAR_C"] = true,
    ["QAEX_C"] = true,
    ["HUB2_C"] = true,
}

-- These Classes are used to control COLU door access
M.colu_door_actors = {
    ["GMO_GEN_COLU_BobDoor_C"] = false,
    ["GMO_GEN_COLU_CassieDoor_C"] = false,
    ["GMO_GEN_COLU_ComptonDoor_C"] = false,
    ["GMO_GEN_COLU_FordVistaDoor_C"] = false,
    ["GMO_GEN_COLU_GristolDoor_C"] = false,
    ["GMO_GEN_COLU_HelmutDoor_C"] = false,
    ["GMO_GEN_COLU_LobotoDoor_C"] = false,
    ["GMO_GEN_COLU_MaligulaDoor_C"] = false,
}

-- These doors require a differnt COLU door unlock method
M.colu_special_doors = {
    ["GMO_GEN_COLU_FordDoor_C"] = "/Game/Gameplay/FastTravelData/UIData/COLU/UIData_FTCOLU_Ford.UIData_FTCOLU_Ford",
    ["GMO_GEN_COLU_HollisDoor_C"] = "/Game/Gameplay/FastTravelData/UIData/COLU/UIData_FTCOLU_HOLL.UIData_FTCOLU_HOLL",
}
M.colu_special_door_sublevels_enabled = {
    ["GMO_GEN_COLU_FordDoor_C"] = {
        ["FT_COLU_FORH"] = false,
        ["FT_COLU_FORC"] = false,
        ["FT_COLU_FORB"] = false,
        ["FT_COLU_FORG"] = false,
        ["FT_COLU_START"] = false,
        ["Nevermind"] = true
    },
    ["GMO_GEN_COLU_HollisDoor_C"] = {
        ["FT_COLU_HOLL_Classroom"] = false,
        ["FT_COLU_HOLL_Casino"] = false,
        ["FT_COLU_START"] = false,
        ["Nevermind"] = true
    },
}

M.ft_dest_unlocked = {
    ["FT_HQIN_SASHA"] = true,
    ["FT_HQIN_InternWing"] = true,
    ["FT_HQIN_Atrium"] = true,
    ["FT_HQIN_Truman"] = true,
    ["FT_QUAR_Quarry"] = false,
    ["FT_QUAR_Lab"] = false,
    ["FT_QUAR_PIC"] = false,
    ["FT_QAEX_Lot"] = false,
    ["FT_HUB2_Heptadome"] = false,
}

local ft_dest_mapping = {
    ["Questionable Area Access"] = {
        "FT_QUAR_Quarry",
        "FT_QUAR_Lab",
        "FT_QUAR_PIC",
        "FT_QAEX_Lot",
    },
    ["Green Needle Gulch Access"] = {
        "FT_HUB2_Heptadome",
    },
}

M.final_boss_unlocked = false

function M.UnlockBrainLevel(accessString)
    if M.colu_door_actors[accessString] ~= nil then
       M.colu_door_actors[accessString] = true 
    elseif M.colu_special_door_sublevels_enabled["GMO_GEN_COLU_FordDoor_C"][accessString] ~= nil then
        M.colu_special_door_sublevels_enabled["GMO_GEN_COLU_FordDoor_C"][accessString] = true
    elseif M.colu_special_door_sublevels_enabled["GMO_GEN_COLU_HollisDoor_C"][accessString] ~= nil then
        M.colu_special_door_sublevels_enabled["GMO_GEN_COLU_HollisDoor_C"][accessString] = true
    else
        print(string.format("Invalid brain type ap item: %s", accessString))
    end
end

function M.UnlockHubLevel(accessString)
    for _, ele in pairs(ft_dest_mapping[accessString]) do
        M.ft_dest_unlocked[ele] = true
    end
end

return M