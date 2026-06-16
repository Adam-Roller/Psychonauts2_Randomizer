local UEHelpers = require("UEHelpers")

local M = {}
M.AlwaysCompleteQuests = {
    ["/Game/Gameplay/Quests/HUB1/QUEST_HUB1_1005_CheckinFrontDesk.QUEST_HUB1_1005_CheckinFrontDesk"] = true,
    --["/Game/Gameplay/Quests/HUB1/QUEST_HUB1_1020_EscapeTheClosetWrapper.QUEST_HUB1_1020_EscapeTheClosetWrapper"] = true,
    ["/Game/Gameplay/Quests/HUB1/QUEST_HUB1_1030_EnterBuilding.QUEST_HUB1_1030_EnterBuilding"] = true,
    --["/Game/Gameplay/Quests/HUB1/QUEST_HUB1_1040_InternResume.QUEST_HUB1_1040_InternResume"] = true,
    --["/Game/Gameplay/Quests/HUB1/QUEST_HUB1_2070_ReturnToTruman.QUEST_HUB1_2070_ReturnToTruman"] = true,
}

function M.get_quest_status(quest_name)
    --- @class UP2BlueprintLibrary
    local blueprint_library = StaticFindObject("/Script/Psychonauts2.Default__P2BlueprintLibrary")
    if not blueprint_library:IsValid() then
        print("No instance of class 'Default__P2BlueprintLibrary' was found.")
        return
    end
    local persistent_level = UEHelpers:GetPersistentLevel()
    local level_script_actor = persistent_level.LevelScriptActor

    local kismet_system = UEHelpers.GetKismetSystemLibrary()
    local quest_soft = kismet_system:Conv_SoftObjPathToSoftObjRef(kismet_system:MakeSoftObjectPath(quest_name))

    --- @type EP2QuestStatus
    local quest_status = blueprint_library:GetQuestStatus(level_script_actor, quest_soft)
    return quest_status
end

function M.print_all_quests()
    local all_quests = FindAllOf("P2Quest")
    if not all_quests then
    print("No instances of 'P2Quest' were found\n") 
    else
        for _, quest_obj in pairs(all_quests) do
            if quest_obj:IsValid() then
                local path_name = string.match(quest_obj:GetFullName(), "^%S+%s+(%S+)")
                print(string.format("Found quest: %s", path_name))
                print(string.format("Status: %s\n", M.get_quest_status(path_name)))
            end
        end
    end
end

return M