local UEHelpers = require("UEHelpers")
local quests = require("quests")

print("[PS2RandomizerMod] Mod Loaded\n")

local new_game = false;
local first_load = true;
local MConnUnlocked = false;

-- These Classes receive BeginPlay calls near the end of a level loading so code can run assuming most items are loaded
local late_level_actors = { 
    ["COLU_C"] = true, 
    ["HOLL_CLASS_C"] = true, 
    ["HQIN_C"] = true, 
    ["LOBO_C"] = true,
}
-- Using the Actor class names as level names to make checking/switching levels easier
local current_level = "HQIN_C"

function UnlockTumbler()
    ---@type UCoTalker | UObject
    local talker = StaticFindObject("/Game/Maps/HQIN/HQIN_DES.HQIN_DES:PersistentLevel.GMO_GEN_FastTravel_BrainTumbler_2.COMP_Talker_Solo_BrainTumbler")
    if talker:IsValid() then
        local kismet_system = UEHelpers.GetKismetSystemLibrary()
        talker.m_DialogTreeConditionalData.m_rReqCompletedQuest = kismet_system:Conv_SoftObjPathToSoftObjRef(kismet_system:MakeSoftObjectPath("None"))
        print("Removed quest requirement from Brain Tumbler\n")
    end
end

RegisterBeginPlayPreHook(function(Actor)
    if first_load then
        --- @class P2Quest
        local root_quest = StaticFindObject("/Game/Gameplay/Quests/HUB1/QUEST_HUB1_0000_ROOT.QUEST_HUB1_0000_ROOT")
        if root_quest:IsValid() then
            root_quest.m_bSubQuestsSequential = false
            first_load = false
        end
    end
    --print(string.format("BeginPlay: %s\n", Actor:get():GetClass():GetFName():ToString()))
    local ClassName = Actor:get():GetClass():GetFName():ToString()

    if late_level_actors[ClassName] == true then
        -- Track current level for quest managing
        current_level = ClassName
        print(string.format("current_level changed to : %s\n", current_level))

        local blueprint_library = StaticFindObject("/Script/Psychonauts2.Default__P2BlueprintLibrary")
        if not blueprint_library:IsValid() then
            print("No instance of class 'Default__P2BlueprintLibrary' was found.")
            return
        end
        local persistent_level = UEHelpers:GetPersistentLevel()
        local level_script_actor = persistent_level.LevelScriptActor

        -- On NewGame load fix starting items
        if new_game then
            -- Remove auto added Mental Health 
            local mind_hp = StaticFindObject("/Game/Gameplay/Inventory/Upgrades/Minds/INV_Mind_HP.INV_Mind_HP")
            if mind_hp:IsValid() then
                blueprint_library:RemoveFromRazInventory(level_script_actor, mind_hp, 18)
            else
                print("Couldn't find Mind HP")
            end

            -- Remove auto added Abilities
            local all_powerkeys = FindAllOf("POWERKEY_Base_C")
            if not all_powerkeys then
            print("No instances of 'POWERKEY_Base_C' were found\n") 
            else
                for _, powerkey in pairs(all_powerkeys) do
                    if powerkey:IsValid() then
                        print(string.format("Found POWERKEY: %s", powerkey:GetFullName()))
                        blueprint_library:RemoveFromRazInventory(level_script_actor, powerkey, 30)
                    end
                end
            end

            -- Remove auto added Psitanium pocket upgrades
            local pocket_psi_1 = StaticFindObject("/Game/Gameplay/Inventory/Pockets/INV_POCKET_Psitanium_1.INV_POCKET_Psitanium_1")
            if pocket_psi_1:IsValid() then
                blueprint_library:RemoveFromRazInventory(level_script_actor, pocket_psi_1, 1)
            else
                print("Couldn't find INV_POCKET_Psitanium_1")
            end
            local pocket_psi_2 = StaticFindObject("/Game/Gameplay/Inventory/Pockets/INV_POCKET_Psitanium_2.INV_POCKET_Psitanium_2")
            if pocket_psi_2:IsValid() then
                blueprint_library:RemoveFromRazInventory(level_script_actor, pocket_psi_2, 1)
            else
                print("Couldn't find INV_POCKET_Psitanium_2")
            end

            new_game = false
        end

        -- Before fully unlocking, Add Mental Connection power when in COLU, remove when leaving
        if not MConnUnlocked then
            local PK_Mconn = StaticFindObject("/Game/Gameplay/Inventory/Powers/POWERKEY_MConn.POWERKEY_MConn")
            if not PK_Mconn:IsValid() then
                print ("Couldn't find Mental Connection Powerkey")
                return
            end
            if ClassName == "COLU_C" then
                blueprint_library:AddToRazInventory(level_script_actor, PK_Mconn, 1)
            else
                --blueprint_library:RemoveFromRazInventory(level_script_actor, PK_Mconn, 1)
            end
        end

        -- When entering HQIN remove the quest check from the Brain Tumbler
        if ClassName == "HQIN_C" then
            UnlockTumbler()
        end

    end
end)

function HookedIsQuestCompleteNew(Context, WorldContextObjectParam, rQuestParam)
    local rQuest_AssetPathName = rQuestParam:Get():GetObjectID():GetAssetPathName():ToString()
    -- Some quests should always be considered complete
    if quests.AlwaysCompleteQuests[rQuest_AssetPathName] == true then
        return true
    elseif current_level == "COLU_C" then
        return true
    elseif WorldContextObjectParam:get():GetFName():ToString() == "GMO_HQIN_DoorScanner_AtriumExitToLobby" then
        return true
    end
end

function HookedIsQuestActiveNew(Context, WorldContextObjectParam, rQuestParam)
    local rQuest_AssetPathName = rQuestParam:Get():GetObjectID():GetAssetPathName():ToString()
    if rQuest_AssetPathName == "/Game/Gameplay/Quests/HUB1/QUEST_HUB1_2005_COLU_Sidetrack.QUEST_HUB1_2005_COLU_Sidetrack" then
        return false
    end
end

function HookedP2OpenLevel(Context, WorldContextParam, LevelParam, CutscenesToPreloadParam, DestinationPlayerStartParam, 
    FadeParamsParam, bOverrideLoadingLevelParam, LoadingLevelParam, bSaveGameParam, SaveAutoBackupNameParm, bRestoreRazToFullHealthParam)
    -- LoadingLevel 2 is NewGame
    if LoadingLevelParam:Get() == 2 then
        -- Replace the target map for NewGame loads to be HQIN
        local kismet_system = UEHelpers.GetKismetSystemLibrary()
        local HQINMapSoft = kismet_system:Conv_SoftObjPathToSoftObjRef(kismet_system:MakeSoftObjectPath("/Game/Maps/HQIN/HQIN.HQIN"))
        local DefaultStartSoft = kismet_system:Conv_SoftObjPathToSoftObjRef(kismet_system:MakeSoftObjectPath("/Game/Gameplay/StartPoints/HQIN/START_HQIN_Default.START_HQIN_Default"))
        LevelParam:Set(HQINMapSoft)
        DestinationPlayerStartParam:Set(DefaultStartSoft)
        -- Set NewGame flag to allow BeginPlay hooks to handle initial game setup
        new_game = true;
    end
end

RegisterHook("/Script/Psychonauts2.P2BlueprintLibrary:P2OpenLevel", HookedP2OpenLevel)
RegisterHook("/Script/Psychonauts2.P2BlueprintLibrary:IsQuestCompleteNew", HookedIsQuestCompleteNew)
RegisterHook("/Script/Psychonauts2.P2BlueprintLibrary:IsQuestActiveNew", HookedIsQuestActiveNew)

-- Keybinds
----------------

-- Give yourself MentalConnection in case it's taken away
RegisterKeyBind(Key.F3, {ModifierKey.CONTROL}, function()
    local blueprint_library = StaticFindObject("/Script/Psychonauts2.Default__P2BlueprintLibrary")
    if not blueprint_library:IsValid() then
        print("No instance of class 'Default__P2BlueprintLibrary' was found.")
        return
    end
    local persistent_level = UEHelpers:GetPersistentLevel()
    local level_script_actor = persistent_level.LevelScriptActor

    local PK_Mconn = StaticFindObject("/Game/Gameplay/Inventory/Powers/POWERKEY_MConn.POWERKEY_MConn")
    if not PK_Mconn:IsValid() then
        print ("Couldn't find Mental Connection Powerkey")
        return
    end
    blueprint_library:AddToRazInventory(level_script_actor, PK_Mconn, 1)
end)

-- Sanity Check of Hub quest statuses
RegisterKeyBind(Key.F5, {ModifierKey.CONTROL}, function()
    quests.print_all_quests()
end)

-- Add Pyro
RegisterKeyBind(Key.F7, {ModifierKey.CONTROL}, function()
    --- @class UP2BlueprintLibrary
    local blueprint_library = StaticFindObject("/Script/Psychonauts2.Default__P2BlueprintLibrary")
    if not blueprint_library:IsValid() then
        print("No instance of class 'Default__P2BlueprintLibrary' was found.")
        return
    end
    local persistent_level = UEHelpers:GetPersistentLevel()
    local level_script_actor = persistent_level.LevelScriptActor

    local pyro = StaticFindObject("/Game/Gameplay/Inventory/Powers/POWERKEY_Pyrokinesis.POWERKEY_Pyrokinesis")
    if not pyro:IsValid() then
        print ("Couldn't find Pyrokinesis Powerkey")
        return
    end
    blueprint_library:AddToRazInventory(level_script_actor, pyro, 1)
end)