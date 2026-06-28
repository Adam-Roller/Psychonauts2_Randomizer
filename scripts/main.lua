local UEHelpers = require("UEHelpers")
local quests = require("quests")

print("[PS2RandomizerMod] Mod Loaded\n")

local new_game = false
local mental_connection_unlocked = false
local final_boss_unlocked = false
local item_to_allow = nil

-- These Classes receive BeginPlay calls near the end of a level loading so code can run assuming most items are loaded
local late_level_actors = { 
    ["COLU_C"] = true, 
    ["HOLL_CLASS_C"] = true, 
    ["HQIN_C"] = true, 
    ["LOBO_C"] = true,
    ["QUAR_C"] = true,
    ["QAEX_C"] = true,
    ["HUB2_C"] = true,
}

-- These Classes are used to control COLU door access
local colu_door_actors = {
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
local colu_special_doors = {
    ["GMO_GEN_COLU_FordDoor_C"] = "/Game/Gameplay/FastTravelData/UIData/COLU/UIData_FTCOLU_Ford.UIData_FTCOLU_Ford",
    ["GMO_GEN_COLU_HollisDoor_C"] = "/Game/Gameplay/FastTravelData/UIData/COLU/UIData_FTCOLU_HOLL.UIData_FTCOLU_HOLL",
}
local colu_special_door_sublevels_enabled = {
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

-- HQIN_FT destinations are used to unlock fast travel destinations
local ft_destinations = {
    ["HQIN_C"] = {
        "/Game/Gameplay/FastTravelData/UIData/RealWorld/UIData_FTRW_HQIN_Truman.UIData_FTRW_HQIN_Truman",
        "/Game/Gameplay/FastTravelData/UIData/RealWorld/UIData_FTRW_HQIN_Sasha.UIData_FTRW_HQIN_Sasha",
        "/Game/Gameplay/FastTravelData/UIData/RealWorld/UIData_FTRW_HQIN_Intern.UIData_FTRW_HQIN_Intern",
        "/Game/Gameplay/FastTravelData/UIData/RealWorld/UIData_FTRW_HQIN_Atrium.UIData_FTRW_HQIN_Atrium",
    },
    ["QUAR_C"] = {
        "/Game/Gameplay/FastTravelData/UIData/RealWorld/UIData_FTRW_PIC.UIData_FTRW_PIC",
        "/Game/Gameplay/FastTravelData/UIData/RealWorld/UIData_FTRW_OttoLab.UIData_FTRW_OttoLab",
        "/Game/Gameplay/FastTravelData/UIData/RealWorld/UIData_FTRW_QUAR.UIData_FTRW_QUAR",
    },
    ["QAEX_C"] = {
        "/Game/Gameplay/FastTravelData/UIData/RealWorld/UIData_FTRW_QAEX.UIData_FTRW_QAEX",
    },
    ["HUB2_C"] = {
        "/Game/Gameplay/FastTravelData/UIData/RealWorld/UIData_FTRW_Heptadome.UIData_FTRW_Heptadome",
    },
}

-- These startpoints are loaded by levels that don't load HQIN and need to be redirected
local level_complete_redirect_dests = {
    ["/Game/Gameplay/StartPoints/HOLL/START_HOLL_REAL_State2.START_HOLL_REAL_State2"] = true,
    ["/Game/Gameplay/StartPoints/QAEX/START_QAEX_FORGReturn.START_QAEX_FORGReturn"] = true,
    ["/Game/Gameplay/StartPoints/HUB2/START_HUB2_BobzHouse.START_HUB2_BobzHouse"] = true,
    ["/Game/Gameplay/StartPoints/HUB2/START_HUB2_CassieHouse.START_HUB2_CassieHouse"] = true,
    ["/Game/Gameplay/StartPoints/HUB2/START_HUB2_GristolHeptadome.START_HUB2_GristolHeptadome"] = true,
    ["/Game/Gameplay/StartPoints/HUB2/START_HUB2_Lathe.START_HUB2_Lathe"] = true,
}

-- conn for connection testing
RegisterConsoleCommandHandler("conn", function(FullCommand, Parameters, OutputDevice) 
    local host = Parameters[1]
    local slot_name = Parameters[2]
    local password = Parameters[3]

    if not host then
        OutputDevice:Log("Please specify a host")    
    end
    if not slot_name then
        OutputDevice:Log("Please specify a slot name")
    end
    Multiworld:Connect(host, slot_name, "")
    return true
end)

RegisterBeginPlayPreHook(function(Actor)
    --print(string.format("BeginPlay: %s\n", Actor:get():GetClass():GetFName():ToString()))
    --print(string.format("BeginPlay: %s\n", Actor:get():GetFullName()))
    --print(string.format("BeginPlay: %s\n", Actor:get():GetFName():ToString()))
    local actor_class_name = Actor:get():GetClass():GetFName():ToString()
    local actor_full_name = Actor:get():GetFullName()


    if late_level_actors[actor_class_name] == true then

        -- On NewGame load fix starting items
        if new_game then
            -- Remove auto added Abilities from quest system
            RemoveAllClassFromRaz("POWERKEY_Base_C", 1)

            -- Remove auto added Mental Health 
            RemoveFromRaz("/Game/Gameplay/Inventory/Upgrades/Minds/INV_Mind_HP.INV_Mind_HP", 18)

            -- Remove auto added Psitanium pocket upgrades
            RemoveFromRaz("/Game/Gameplay/Inventory/Pockets/INV_POCKET_Psitanium_1.INV_POCKET_Psitanium_1", 1)
            RemoveFromRaz("/Game/Gameplay/Inventory/Pockets/INV_POCKET_Psitanium_2.INV_POCKET_Psitanium_2", 1)

            -- Add Fast Travel Key
            AddToRaz("/Game/Gameplay/Inventory/FastTravel/INV_FTKey.INV_FTKey", 1)

            -- Add Ability radial
            AddToRaz("/Game/Characters/Raz/Abilities/INV_AbilityRadialMenu.INV_AbilityRadialMenu", 1)

            ------- Start Sidequests -----------
            -- Scavenger Hunt
            AddSideQuest("/Game/Gameplay/Quests/SIDEQUESTS/ScavengerHunt/QUEST_HUB1_ScavHunt_Root.QUEST_HUB1_ScavHunt_Root")
            -- Seismometer Vents
            AddSideQuest("/Game/Gameplay/Quests/SIDEQUESTS/QUEST_HUB1_GisuSidequest_Root.QUEST_HUB1_GisuSidequest_Root")

            new_game = false
        end

        -- Before fully unlocking, Add Mental Connection power when in COLU, remove when leaving
        if not mental_connection_unlocked then
            if actor_class_name == "COLU_C" then
                AddToRaz("/Game/Gameplay/Inventory/Powers/POWERKEY_MConn.POWERKEY_MConn", 1)
            else
                --RemoveFromRaz("/Game/Gameplay/Inventory/Powers/POWERKEY_MConn.POWERKEY_MConn", 1)
            end
        end

        -- Enable all exits for each fast travel entry point
        if ft_destinations[actor_class_name] ~= nil then
            for _, ele in pairs(ft_destinations[actor_class_name]) do
                ---@class UDestination
                local dest_obj = StaticFindObject(ele) 
                if dest_obj:IsValid() then
                    dest_obj.Destinations:ForEach(function (_, elem)
                        local destination = elem:get()
                        destination.bNoVisitRequired = true
                        elem:set(destination)
                    end)
                else
                    print(string.format("Couldn't find Object for %s\n", ele))
                end
            end
        end

        -- When entering HQIN remove the quest check from the Brain Tumbler
        if actor_class_name == "HQIN_C" then
            UnlockTumbler()
        end

    -- When entering COLU make FORD/HOLLIS doors (in)accessable
    elseif colu_special_doors[actor_class_name] ~= nil then
        ---@class UDestination
        local door_ft_dest = StaticFindObject(colu_special_doors[actor_class_name])
        if door_ft_dest:IsValid() then
            door_ft_dest.Destinations:ForEach(function (_, elem)
                -- Each destination can make specific sub-brains (in)accessable if you haven't been there
                local destination = elem:get()
                if colu_special_door_sublevels_enabled[actor_class_name][destination.FastTravelID:ToString()] == true then
                    destination.bNoVisitRequired = true
                else
                    destination.bNoVisitRequired = false
                end
                elem:set(destination)
            end)
        else
            print(string.format("Couldn't find door destination object: %s\n"), colu_special_doors[actor_class_name])
        end
        -- Ford door needs to be made visibile separately
        if actor_class_name == "GMO_GEN_COLU_FordDoor_C" then
            RegisterHook("/Game/Gameplay/LevelSpecific/COLU/GMO_GEN_COLU_FordDoor.GMO_GEN_COLU_FordDoor_C:HasVisitedFordBrain", function (context, bVisitedParam)
                bVisitedParam:set(true)
            end)
        end

    -- When entering COLU make all other doors (in)visible
    elseif colu_door_actors[actor_class_name] ~= nil then
        -- All these doors can be controled via LockedCutsceneInteraction (Lobo still appears but doesn't work)
        local locked_cutscene_class = StaticFindObject("/Game/Gameplay/Components/COMP_LockedCutsceneInteraction.COMP_LockedCutsceneInteraction_C")
        if locked_cutscene_class:IsValid() then
            local locked_cutscene = Actor:get():GetComponentByClass(locked_cutscene_class)
            if locked_cutscene:IsValid() then
                local quest_to_set = "None"
                if colu_door_actors[actor_class_name] == false then
                    quest_to_set = "/Game/Gameplay/Quests/HUB1/QUEST_HUB1_4000_BeginPostgame.QUEST_HUB1_4000_BeginPostgame"
                end
                local kismet_system = UEHelpers.GetKismetSystemLibrary()
                local replacement_completed_quest = kismet_system:Conv_SoftObjPathToSoftObjRef(kismet_system:MakeSoftObjectPath(quest_to_set))
                locked_cutscene.UnlockCompletedQuest = replacement_completed_quest
                local replacement_active_quest = kismet_system:Conv_SoftObjPathToSoftObjRef(kismet_system:MakeSoftObjectPath(quest_to_set))
                locked_cutscene.UnlockActiveQuest = replacement_active_quest
            else
                print(string.format("Actor component was invalid for %s\n", actor_class_name))
            end
        else
            print("Could not find locked cutscene class")
        end

    -- Enable Smelling Salts For MALI
    elseif actor_full_name == "P2WorldSettings /Game/Maps/MALI/MALI.MALI:PersistentLevel.P2WorldSettings" then
        Actor:get().bSmellingSaltsNoLevelExitOverride = false
        -- Disable the long cutscene as well (still works just takes longer without this)
        local none_soft = CreateSoftObject("None")
        Actor:get().SmellingSaltsLevelSequenceOverride = none_soft

    -- Force unlock storage room door to prevent soft lock
    elseif actor_full_name == "GMO_HQIN_StorageDoor_Exit_C /Game/Maps/HUB1/HQIN_STORAGE_ART.HQIN_STORAGE_ART:PersistentLevel.GMO_HQIN_StorageDoor_Exit_3" then
        local door_quest_status = StaticFindObject("/Game/Maps/HUB1/HQIN_STORAGE_ART.HQIN_STORAGE_ART:PersistentLevel.GMO_HQIN_StorageDoor_Exit_3.COMP_Interactible.P2Condition_QuestStatus_0")
        if door_quest_status:IsValid() then
            door_quest_status.m_bInvertCondition = true
        else
            print("Couldn't find storage room door quest status\n")
        end
    end


end)

function HookedIsQuestCompleteNew(Context, WorldContextObjectParam, rQuestParam)
    -- Access to Mailroom
    if WorldContextObjectParam:get():GetFName():ToString() == "GMO_HQIN_DoorScanner_AtriumToMailroom" then
        return true

    -- Access to QUAR Lobby
    elseif WorldContextObjectParam:get():GetFName():ToString() == "GMO_HQIN_DoorScanner_AtriumExitToLobby" then
        return true
    end
end

function HookedP2OpenLevel(Context, WorldContextParam, LevelParam, CutscenesToPreloadParam, DestinationPlayerStartParam, 
    FadeParamsParam, bOverrideLoadingLevelParam, LoadingLevelParam, bSaveGameParam, SaveAutoBackupNameParm, bRestoreRazToFullHealthParam)
    local player_start = DestinationPlayerStartParam:get():GetObjectID():GetAssetPathName():ToString()
    -- LoadingLevel 2 is NewGame
    if LoadingLevelParam:Get() == 2 then
        -- Replace the target map for NewGame loads to be HQIN
        local QUARMapSoft = CreateSoftObject("/Game/Maps/QUAR/QUAR.QUAR")
        local DefaultStartSoft = CreateSoftObject("/Game/Gameplay/StartPoints/QUAR/START_QUAR_FromHQIN.START_QUAR_FromHQIN")
        LevelParam:Set(QUARMapSoft)
        DestinationPlayerStartParam:Set(DefaultStartSoft)
        -- Set NewGame flag to allow BeginPlay hooks to handle initial game setup
        new_game = true;

    elseif level_complete_redirect_dests[player_start] == true then
        local HQINMapSoft = CreateSoftObject("/Game/Maps/HQIN/HQIN.HQIN")
        local DefaultStartSoft = CreateSoftObject("/Game/Gameplay/StartPoints/HQIN/START_HQIN_SashaLabTumbler.START_HQIN_SashaLabTumbler")
        LevelParam:Set(HQINMapSoft)
        DestinationPlayerStartParam:Set(DefaultStartSoft)
    elseif final_boss_unlocked and player_start == "/Game/Gameplay/StartPoints/QUAR/START_QUAR_FromHQIN.START_QUAR_FromHQIN" then
        local QAEX_soft = CreateSoftObject("/Game/Maps/QAEX/QAEX.QAEX")
        local boss_start_soft = CreateSoftObject("/Game/Gameplay/StartPoints/QAEX/START_QAEX_FromHUB2.START_QAEX_FromHUB2")
        LevelParam:Set(QAEX_soft)
        DestinationPlayerStartParam:Set(boss_start_soft)
    end
end

function HookedOnInventoryItemAmountChangedPost(Context, pInventoryItem, iOldAmount, iNewAmount, bFromLoad)
    if iOldAmount:get() < iNewAmount:get() then
        if not (pInventoryItem:get():GetFullName() == item_to_allow) then
            ---@class UP2BlueprintLibrary
            local blueprint_library = StaticFindObject("/Script/Psychonauts2.Default__P2BlueprintLibrary")
            if not blueprint_library:IsValid() then
                print("No instance of class 'Default__P2BlueprintLibrary' was found.")
                return
            end
            local persistent_level = UEHelpers:GetPersistentLevel()
            local level_script_actor = persistent_level.LevelScriptActor

            -- Remove what was just added
            local amount_to_remove = iNewAmount:get() - iOldAmount:get()
            blueprint_library:RemoveFromRazInventory(level_script_actor, pInventoryItem:get(), amount_to_remove)

            -- Tell Multiworld the item has been picked up
        else
            print("Yes the item to allow")
            item_to_allow = nil
        end
    end
end

RegisterHook("/Script/Psychonauts2.P2BlueprintLibrary:P2OpenLevel", HookedP2OpenLevel)
RegisterHook("/Script/Psychonauts2.P2BlueprintLibrary:IsQuestCompleteNew", HookedIsQuestCompleteNew)
RegisterHook("/Script/Psychonauts2.P2UpgradeManager:OnInventoryItemAmountChanged", function(_) end, HookedOnInventoryItemAmountChangedPost)

-- Keybinds
----------------

-- Add TimeBubble
RegisterKeyBind(Key.F2, {ModifierKey.CONTROL}, function()
    AddToRaz("/Game/Gameplay/Inventory/Powers/POWERKEY_TimeBubble.POWERKEY_TimeBubble", 1)
end)

-- Sanity Check of Hub quest statuses
RegisterKeyBind(Key.F3, {ModifierKey.CONTROL}, function()
    quests.print_all_quests()
end)

-- Give yourself MentalConnection in case it's taken away
RegisterKeyBind(Key.F4, {ModifierKey.CONTROL}, function()
    AddToRaz("/Game/Gameplay/Inventory/Powers/POWERKEY_MConn.POWERKEY_MConn", 1)
end)

-- Add Levitation
RegisterKeyBind(Key.F5, {ModifierKey.CONTROL}, function()
    AddToRaz("/Game/Gameplay/Inventory/Powers/POWERKEY_Levitation.POWERKEY_Levitation", 1)
end)

-- Add TK
RegisterKeyBind(Key.F6, {ModifierKey.CONTROL}, function()
    AddToRaz("/Game/Gameplay/Inventory/Powers/POWERKEY_Telekinesis.POWERKEY_Telekinesis", 1)
end)

-- Add Pyro
RegisterKeyBind(Key.F7, {ModifierKey.CONTROL}, function()
    AddToRaz("/Game/Gameplay/Inventory/Powers/POWERKEY_Pyrokinesis.POWERKEY_Pyrokinesis", 1)
end)

-- Add PSIBlast
RegisterKeyBind(Key.F8, {ModifierKey.CONTROL}, function()
    AddToRaz("/Game/Gameplay/Inventory/Powers/POWERKEY_PsiBlast.POWERKEY_PsiBlast", 1)
end)

-- Add Salts
RegisterKeyBind(Key.F9, {ModifierKey.CONTROL}, function()
    AddToRaz("/Game/Gameplay/Inventory/INV_SmellingSalts.INV_SmellingSalts", 1)
end)

-- Add Radial
RegisterKeyBind(Key.F10, {ModifierKey.CONTROL}, function()
    AddToRaz("/Game/Characters/Raz/Abilities/INV_AbilityRadialMenu.INV_AbilityRadialMenu", 1)
end)

------- Helper functions --------
function AddToRaz(itemPath, amount)
    --- @class UP2BlueprintLibrary
    local blueprint_library = StaticFindObject("/Script/Psychonauts2.Default__P2BlueprintLibrary")
    if not blueprint_library:IsValid() then
        print("No instance of class 'Default__P2BlueprintLibrary' was found.")
        return
    end
    local persistent_level = UEHelpers:GetPersistentLevel()
    local level_script_actor = persistent_level.LevelScriptActor

    --- @class UInventoryItem
    local item_to_add = StaticFindObject(itemPath)
    if not item_to_add:IsValid() then
        print(string.format("No object found with name: %s\n", itemPath))
        return
    end
    item_to_allow = item_to_add:GetFullName()
    blueprint_library:AddToRazInventory(level_script_actor, item_to_add, amount)
end

function RemoveFromRaz(itemPath, amount)
    --- @class UP2BlueprintLibrary
    local blueprint_library = StaticFindObject("/Script/Psychonauts2.Default__P2BlueprintLibrary")
    if not blueprint_library:IsValid() then
        print("No instance of class 'Default__P2BlueprintLibrary' was found.")
        return
    end
    local persistent_level = UEHelpers:GetPersistentLevel()
    local level_script_actor = persistent_level.LevelScriptActor

    --- @class UInventoryItem
    local item_to_remove = StaticFindObject(itemPath)
    if not item_to_remove:IsValid() then
        print(string.format("No object found with name: %s\n", itemPath))
        return
    end
    blueprint_library:RemoveFromRazInventory(level_script_actor, item_to_remove, amount)
end

function RemoveAllClassFromRaz(className, amount)
    ---@class UP2BlueprintLibrary
    local blueprint_library = StaticFindObject("/Script/Psychonauts2.Default__P2BlueprintLibrary")
    if not blueprint_library:IsValid() then
        print("No instance of class 'Default__P2BlueprintLibrary' was found.")
        return
    end
    local persistent_level = UEHelpers:GetPersistentLevel()
    local level_script_actor = persistent_level.LevelScriptActor

    -- Remove auto added Abilities
    local all_class_objects = FindAllOf(className)
    if not all_class_objects then
        print(string.format("No instances of '%s' were found\n", className))
    else
        for _, item in pairs(all_class_objects) do
            if item:IsValid() then
                blueprint_library:RemoveFromRazInventory(level_script_actor, item, amount)
            end
        end
    end
end

function AddSideQuest(questName)
    ---@class UP2BlueprintLibrary
    local blueprint_library = StaticFindObject("/Script/Psychonauts2.Default__P2BlueprintLibrary")
    if not blueprint_library:IsValid() then
        print("No instance of class 'Default__P2BlueprintLibrary' was found.")
        return
    end
    local persistent_level = UEHelpers:GetPersistentLevel()
    local level_script_actor = persistent_level.LevelScriptActor
    local kismet_system = UEHelpers.GetKismetSystemLibrary()

    -- Scavenger Hunt
    local soft_quest = kismet_system:Conv_SoftObjPathToSoftObjRef(kismet_system:MakeSoftObjectPath(questName))
    blueprint_library:AddQuestNew(level_script_actor, soft_quest, soft_quest)
end

function CreateSoftObject(pathString)
    local kismet_system = UEHelpers.GetKismetSystemLibrary()
    return kismet_system:Conv_SoftObjPathToSoftObjRef(kismet_system:MakeSoftObjectPath(pathString))
end

function UnlockTumbler()
    ---@type UCoTalker | UObject
    local talker = StaticFindObject("/Game/Maps/HQIN/HQIN_DES.HQIN_DES:PersistentLevel.GMO_GEN_FastTravel_BrainTumbler_2.COMP_Talker_Solo_BrainTumbler")
    if talker:IsValid() then
        local kismet_system = UEHelpers.GetKismetSystemLibrary()
        talker.m_DialogTreeConditionalData.m_rReqCompletedQuest = kismet_system:Conv_SoftObjPathToSoftObjRef(kismet_system:MakeSoftObjectPath("None"))
    end
end