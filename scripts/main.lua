local UEHelpers = require("UEHelpers")
local Quests = require("quests")

print("[PS2RandomizerMod] Mod Loaded\n")

local NewGame = false;
local MConnUnlocked = false;

-- These Classes receive BeginPlay calls near the end of a level loading so code can run assuming most items are loaded
local lateLevelActors = { 
    ["COLU_C"] = true, 
    ["HOLL_CLASS_C"] = true, 
    ["HQIN_C"] = true, 
    ["LOBO_C"] = true,
}
-- Using the Actor class names as level names to make checking/switching levels easier
local CurrentLevel = "HQIN_C"

function UnlockTumbler()
    ---@type UCoTalker | UObject
    local talker = StaticFindObject("/Game/Maps/HQIN/HQIN_DES.HQIN_DES:PersistentLevel.GMO_GEN_FastTravel_BrainTumbler_2.COMP_Talker_Solo_BrainTumbler")
    if talker:IsValid() then
        local KismetSystem = UEHelpers.GetKismetSystemLibrary()
        talker.m_DialogTreeConditionalData.m_rReqCompletedQuest = KismetSystem:Conv_SoftObjPathToSoftObjRef(KismetSystem:MakeSoftObjectPath("None"))
        print("Removed quest requirement from Brain Tumbler\n")
    end
end

RegisterBeginPlayPreHook(function(Actor)
    --print(string.format("BeginPlay: %s\n", Actor:get():GetClass():GetFName():ToString()))
    local ClassName = Actor:get():GetClass():GetFName():ToString()

    if lateLevelActors[ClassName] == true then
        -- Track current level for quest managing
        CurrentLevel = ClassName
        print(string.format("CurrentLevel changed to : %s\n", CurrentLevel))

        local Blueprint_Library = StaticFindObject("/Script/Psychonauts2.Default__P2BlueprintLibrary")
        if not Blueprint_Library:IsValid() then
            print("No instance of class 'Default__P2BlueprintLibrary' was found.")
            return
        end
        local Persistent_Level = UEHelpers:GetPersistentLevel()
        local Level_Script_Actor = Persistent_Level.LevelScriptActor

        -- On NewGame load add basic items
        if NewGame then
            local Smelling_Salts = StaticFindObject("/Game/Gameplay/Inventory/INV_SmellingSalts.INV_SmellingSalts")
            if not Smelling_Salts:IsValid() then
                print("No item called 'INV_SmellingSalts' was found.")
                return
            end
            Blueprint_Library:AddToRazInventory(Level_Script_Actor, Smelling_Salts, 1)
            
            local AbilityRadial = StaticFindObject("/Game/Characters/Raz/Abilities/INV_AbilityRadialMenu.INV_AbilityRadialMenu")
            if not AbilityRadial:IsValid() then
                print("Couldn't find Ability Radial")
                return
            end
            Blueprint_Library:AddToRazInventory(Level_Script_Actor, AbilityRadial, 1)

            --[[
            local InternTag = StaticFindObject("/Game/Gameplay/Inventory/UniqueItems/INV_Unique_InternNameTag.INV_Unique_InternNameTag")
            if not InternTag:IsValid() then
                print("Couldn't find Intern Tag")
                return
            end
            Blueprint_Library:AddToRazInventory(Level_Script_Actor, InternTag, 1)
            ]]

            NewGame = false
        end

        -- Before fully unlocking, Add Mental Connection power when in COLU, remove when leaving
        if not MConnUnlocked then
            local PK_Mconn = StaticFindObject("/Game/Gameplay/Inventory/Powers/POWERKEY_MConn.POWERKEY_MConn")
            if not PK_Mconn:IsValid() then
                print ("Couldn't find Mental Connection Powerkey")
                return
            end
            if ClassName == "COLU_C" then
                Blueprint_Library:AddToRazInventory(Level_Script_Actor, PK_Mconn, 1)
            else
                Blueprint_Library:RemoveFromRazInventory(Level_Script_Actor, PK_Mconn, 1)
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
    if Quests.AlwaysCompleteQuests[rQuest_AssetPathName] == true then
        return true
    end
    -- Attempt to use our own quest tracking to lie that quests are complete
    if Quests[CurrentLevel][rQuest_AssetPathName] == true then
        print("Quest tables working (complete)")
        return true
    end
end

function HookedIsQuestActiveNew(Context, WorldContextObjectParam, rQuestParam)
    local rQuest_AssetPathName = rQuestParam:Get():GetObjectID():GetAssetPathName():ToString()
    -- Attempt to use our own quest tracking to lie that quests are active
    if Quests[CurrentLevel][rQuest_AssetPathName] == "active" then
        print("Quest tables working (active)")
        return true
    end
end

function HookedCompleteQuestNew(Context, WorldContextObjectParam, rQuestParam)
    local rQuest_AssetPathName = rQuestParam:Get():GetObjectID():GetAssetPathName():ToString()
    -- If the game tries to complete a quest, we should mark it complete internally
    Quests:CompleteAndAdvanceQuest(CurrentLevel, rQuest_AssetPathName)
end

function HookedP2OpenLevel(Context, WorldContextParam, LevelParam, CutscenesToPreloadParam, DestinationPlayerStartParam, 
    FadeParamsParam, bOverrideLoadingLevelParam, LoadingLevelParam, bSaveGameParam, SaveAutoBackupNameParm, bRestoreRazToFullHealthParam)
    -- LoadingLevel 2 is NewGame
    if LoadingLevelParam:Get() == 2 then
        -- Replace the target map for NewGame loads to be HQIN
        local KismetSystem = UEHelpers.GetKismetSystemLibrary()
        local HQINMapSoft = KismetSystem:Conv_SoftObjPathToSoftObjRef(KismetSystem:MakeSoftObjectPath("/Game/Maps/HQIN/HQIN.HQIN"))
        local DefaultStartSoft = KismetSystem:Conv_SoftObjPathToSoftObjRef(KismetSystem:MakeSoftObjectPath("/Game/Gameplay/StartPoints/HQIN/START_HQIN_Default.START_HQIN_Default"))
        LevelParam:Set(HQINMapSoft)
        DestinationPlayerStartParam:Set(DefaultStartSoft)
        -- Set NewGame flag to allow BeginPlay hooks to handle initial game setup
        NewGame = true;
    end
end

RegisterHook("/Script/Psychonauts2.P2BlueprintLibrary:P2OpenLevel", HookedP2OpenLevel)
RegisterHook("/Script/Psychonauts2.P2BlueprintLibrary:IsQuestCompleteNew", HookedIsQuestCompleteNew)
RegisterHook("/Script/Psychonauts2.P2BlueprintLibrary:IsQuestActiveNew", HookedIsQuestActiveNew)
RegisterHook("/Script/Psychonauts2.P2BlueprintLibrary:CompleteQuestNew", HookedCompleteQuestNew)

-- Keybinds
----------------

-- Give yourself MentalConnection in case it's taken away
RegisterKeyBind(Key.F3, {ModifierKey.CONTROL}, function()
    local Blueprint_Library = StaticFindObject("/Script/Psychonauts2.Default__P2BlueprintLibrary")
    if not Blueprint_Library:IsValid() then
        print("No instance of class 'Default__P2BlueprintLibrary' was found.")
        return
    end
    local Persistent_Level = UEHelpers:GetPersistentLevel()
    local Level_Script_Actor = Persistent_Level.LevelScriptActor

    local PK_Mconn = StaticFindObject("/Game/Gameplay/Inventory/Powers/POWERKEY_MConn.POWERKEY_MConn")
    if not PK_Mconn:IsValid() then
        print ("Couldn't find Mental Connection Powerkey")
        return
    end
    Blueprint_Library:AddToRazInventory(Level_Script_Actor, PK_Mconn, 1)
end)
