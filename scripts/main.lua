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
    ["QUAR_C"] = true,
}

-- These Classes receive
local colu_door_actors = {
    ["GMO_GEN_COLU_BobDoor_C"] = true,
    ["GMO_GEN_COLU_CassieDoor_C"] = true,
    ["GMO_GEN_COLU_ComptonDoor_C"] = true,
    ["GMO_GEN_COLU_FordDoor_C"] = true,
    ["GMO_GEN_COLU_FordVistaDoor_C"] = true,
    ["GMO_GEN_COLU_GristolDoor_C"] = true,
    ["GMO_GEN_COLU_HelmutDoor_C"] = true,
    ["GMO_GEN_COLU_HollisDoor_C"] = true,
    ["GMO_GEN_COLU_LobotoDoor_C"] = true,
    ["GMO_GEN_COLU_MaligulaDoor_C"] = true,
}

-- Using the Actor class names as level names to make checking/switching levels easier
local current_level = "QUAR_C"

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
    --print(string.format("BeginPlay: %s\n", Actor:get():GetFullName()))
    local ClassName = Actor:get():GetClass():GetFName():ToString()

    if late_level_actors[ClassName] == true then
        -- Track current level for level specific control
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

    -- When entering COLU make all doors invisible
    if colu_door_actors[ClassName] == true then
        -- Handle FordDoor differently
        if ClassName == "GMO_GEN_COLU_FordDoor_C" then
            -- Make door visible
            RegisterHook("/Game/Gameplay/LevelSpecific/COLU/GMO_GEN_COLU_FordDoor.GMO_GEN_COLU_FordDoor_C:HasVisitedFordBrain", function (context, bVisitedParam)
                bVisitedParam:set(true)
            end)
            -- Set which destinations are available
            local ford_ft_dest = StaticFindObject("/Game/Gameplay/FastTravelData/UIData/COLU/UIData_FTCOLU_Ford.UIData_FTCOLU_Ford")
            if ford_ft_dest:IsValid() then
                ford_ft_dest.Destinations:ForEach(function (_, elem)
                    local destination = elem:get()
                    -- Can change this to make specific ford brains (in)accessable if you haven't been there
                    if destination.FastTravelID:ToString() ~= "Nevermind" then
                        destination.bNoVisitRequired = true
                        elem:set(destination)
                    end
                end)
            else
                print("Couldn't find UIData_FTCOLU_Ford")
            end

        -- Handle HollisDoor differently
        elseif ClassName == "GMO_GEN_COLU_HollisDoor_C" then
            -- Lock/Unlock Destinations
            local holl_ft_dest = StaticFindObject("/Game/Gameplay/FastTravelData/UIData/COLU/UIData_FTCOLU_HOLL.UIData_FTCOLU_HOLL")
            if holl_ft_dest:IsValid() then
                holl_ft_dest.Destinations:ForEach(function (_, elem)
                    local destination = elem:get()
                    if destination.FastTravelID:ToString() ~= "Nevermind" then
                        -- Can change this to make specific hollis sections (in)accessable if you haven't been there
                        destination.bNoVisitRequired = true
                        elem:set(destination)
                    end
                end)
            else
                print("Couldn't find UIData_FTCOLU_Ford")
            end
        else
            -- All other doors can be controled via LockedCutsceneInteraction (Lobo still appears but doesn't work)
            local locked_cutscene_class = StaticFindObject("/Game/Gameplay/Components/COMP_LockedCutsceneInteraction.COMP_LockedCutsceneInteraction_C")
            if locked_cutscene_class:IsValid() then
                local locked_cutscene = Actor:get():GetComponentByClass(locked_cutscene_class)
                if locked_cutscene:IsValid() then
                    local kismet_system = UEHelpers.GetKismetSystemLibrary()
                    local unlock_completed_quest = kismet_system:Conv_SoftObjectReferenceToString(locked_cutscene.UnlockCompletedQuest):ToString()
                    local replacement_completed_quest = kismet_system:Conv_SoftObjPathToSoftObjRef(kismet_system:MakeSoftObjectPath("None"))
                    --local replacement_completed_quest = kismet_system:Conv_SoftObjPathToSoftObjRef(kismet_system:MakeSoftObjectPath("/Game/Gameplay/Quests/HUB1/QUEST_HUB1_4010_Postgame.QUEST_HUB1_4010_Postgame"))
                    locked_cutscene.UnlockCompletedQuest = replacement_completed_quest
                    local replacement_active_quest = kismet_system:Conv_SoftObjPathToSoftObjRef(kismet_system:MakeSoftObjectPath("None"))
                    --local replacement_active_quest = kismet_system:Conv_SoftObjPathToSoftObjRef(kismet_system:MakeSoftObjectPath("/Game/Gameplay/Quests/HUB1/QUEST_HUB1_4010_Postgame.QUEST_HUB1_4010_Postgame"))
                    locked_cutscene.UnlockActiveQuest = replacement_active_quest

                else
                    print(string.format("Actor component was invalid for %s\n", ClassName))
                end
            else
                print("Could not find locked cutscene class")
            end
        end
    end
end)

function HookedIsQuestCompleteNew(Context, WorldContextObjectParam, rQuestParam)
    local rQuest_AssetPathName = rQuestParam:Get():GetObjectID():GetAssetPathName():ToString()
    -- Some quests should always be considered complete
    if quests.AlwaysCompleteQuests[rQuest_AssetPathName] == true then
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

function HookedCompleteQuestNewPost(Context, WorldContextObjectParam, rQuestParam)
    local rQuest_AssetPathName = rQuestParam:Get():GetObjectID():GetAssetPathName():ToString()
    print(rQuest_AssetPathName)
end

function HookedP2OpenLevel(Context, WorldContextParam, LevelParam, CutscenesToPreloadParam, DestinationPlayerStartParam, 
    FadeParamsParam, bOverrideLoadingLevelParam, LoadingLevelParam, bSaveGameParam, SaveAutoBackupNameParm, bRestoreRazToFullHealthParam)
    -- LoadingLevel 2 is NewGame
    if LoadingLevelParam:Get() == 2 then
        -- Replace the target map for NewGame loads to be HQIN
        local kismet_system = UEHelpers.GetKismetSystemLibrary()
        --local HQINMapSoft = kismet_system:Conv_SoftObjPathToSoftObjRef(kismet_system:MakeSoftObjectPath("/Game/Maps/HQIN/HQIN.HQIN"))
        local QUARMapSoft = kismet_system:Conv_SoftObjPathToSoftObjRef(kismet_system:MakeSoftObjectPath("/Game/Maps/QUAR/QUAR.QUAR"))
        --local DefaultStartSoft = kismet_system:Conv_SoftObjPathToSoftObjRef(kismet_system:MakeSoftObjectPath("/Game/Gameplay/StartPoints/HQIN/START_HQIN_Default.START_HQIN_Default"))
        local DefaultStartSoft = kismet_system:Conv_SoftObjPathToSoftObjRef(kismet_system:MakeSoftObjectPath("/Game/Gameplay/StartPoints/QUAR/START_QUAR_FromHQIN.START_QUAR_FromHQIN"))
        LevelParam:Set(QUARMapSoft)
        --LevelParam:Set(QUARMapSoft)
        DestinationPlayerStartParam:Set(DefaultStartSoft)
        -- Set NewGame flag to allow BeginPlay hooks to handle initial game setup
        new_game = true;
    end
end

RegisterHook("/Script/Psychonauts2.P2BlueprintLibrary:P2OpenLevel", HookedP2OpenLevel)
RegisterHook("/Script/Psychonauts2.P2BlueprintLibrary:IsQuestCompleteNew", HookedIsQuestCompleteNew)
RegisterHook("/Script/Psychonauts2.P2BlueprintLibrary:IsQuestActiveNew", HookedIsQuestActiveNew)
--RegisterHook("/Script/Psychonauts2.P2BlueprintLibrary:CompleteQuestNew", function(Context) end, HookedCompleteQuestNewPost)

-- Keybinds
----------------

-- Sanity Check of Hub quest statuses
RegisterKeyBind(Key.F3, {ModifierKey.CONTROL}, function()
    quests.print_all_quests()
end)

-- Give yourself MentalConnection in case it's taken away
RegisterKeyBind(Key.F4, {ModifierKey.CONTROL}, function()
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

-- Add Levitation
RegisterKeyBind(Key.F5, {ModifierKey.CONTROL}, function()
    --- @class UP2BlueprintLibrary
    local blueprint_library = StaticFindObject("/Script/Psychonauts2.Default__P2BlueprintLibrary")
    if not blueprint_library:IsValid() then
        print("No instance of class 'Default__P2BlueprintLibrary' was found.")
        return
    end
    local persistent_level = UEHelpers:GetPersistentLevel()
    local level_script_actor = persistent_level.LevelScriptActor

    local levitation = StaticFindObject("/Game/Gameplay/Inventory/Powers/POWERKEY_Levitation.POWERKEY_Levitation")
    if not levitation:IsValid() then
        print ("Couldn't find Levitation Powerkey")
        return
    end
    blueprint_library:AddToRazInventory(level_script_actor, levitation, 1)
end)

-- Add TK
RegisterKeyBind(Key.F6, {ModifierKey.CONTROL}, function()
    --- @class UP2BlueprintLibrary
    local blueprint_library = StaticFindObject("/Script/Psychonauts2.Default__P2BlueprintLibrary")
    if not blueprint_library:IsValid() then
        print("No instance of class 'Default__P2BlueprintLibrary' was found.")
        return
    end
    local persistent_level = UEHelpers:GetPersistentLevel()
    local level_script_actor = persistent_level.LevelScriptActor

    local tk = StaticFindObject("/Game/Gameplay/Inventory/Powers/POWERKEY_Telekinesis.POWERKEY_Telekinesis")
    if not tk:IsValid() then
        print ("Couldn't find Telekinesis Powerkey")
        return
    end
    blueprint_library:AddToRazInventory(level_script_actor, tk, 1)
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

-- Add PSIBlast
RegisterKeyBind(Key.F8, {ModifierKey.CONTROL}, function()
    --- @class UP2BlueprintLibrary
    local blueprint_library = StaticFindObject("/Script/Psychonauts2.Default__P2BlueprintLibrary")
    if not blueprint_library:IsValid() then
        print("No instance of class 'Default__P2BlueprintLibrary' was found.")
        return
    end
    local persistent_level = UEHelpers:GetPersistentLevel()
    local level_script_actor = persistent_level.LevelScriptActor

    local psi_blast = StaticFindObject("/Game/Gameplay/Inventory/Powers/POWERKEY_PsiBlast.POWERKEY_PsiBlast")
    if not psi_blast:IsValid() then
        print ("Couldn't find PsiBlast Powerkey")
        return
    end
    blueprint_library:AddToRazInventory(level_script_actor, psi_blast, 1)
end)

-- Add Salts
RegisterKeyBind(Key.F9, {ModifierKey.CONTROL}, function()
    --- @class UP2BlueprintLibrary
    local blueprint_library = StaticFindObject("/Script/Psychonauts2.Default__P2BlueprintLibrary")
    if not blueprint_library:IsValid() then
        print("No instance of class 'Default__P2BlueprintLibrary' was found.")
        return
    end
    local persistent_level = UEHelpers:GetPersistentLevel()
    local level_script_actor = persistent_level.LevelScriptActor

    local smelling_salts = StaticFindObject("/Game/Gameplay/Inventory/INV_SmellingSalts.INV_SmellingSalts")
    if not smelling_salts:IsValid() then
        print("No item called 'INV_SmellingSalts' was found.")
        return
    end
    blueprint_library:AddToRazInventory(level_script_actor, smelling_salts, 1)
end)

-- Add Radial
RegisterKeyBind(Key.F10, {ModifierKey.CONTROL}, function()
    --- @class UP2BlueprintLibrary
    local blueprint_library = StaticFindObject("/Script/Psychonauts2.Default__P2BlueprintLibrary")
    if not blueprint_library:IsValid() then
        print("No instance of class 'Default__P2BlueprintLibrary' was found.")
        return
    end
    local persistent_level = UEHelpers:GetPersistentLevel()
    local level_script_actor = persistent_level.LevelScriptActor

    local ability_radial = StaticFindObject("/Game/Characters/Raz/Abilities/INV_AbilityRadialMenu.INV_AbilityRadialMenu")
    if not ability_radial:IsValid() then
        print("Couldn't find Ability Radial")
        return
    end
    blueprint_library:AddToRazInventory(level_script_actor, ability_radial, 1)
end)