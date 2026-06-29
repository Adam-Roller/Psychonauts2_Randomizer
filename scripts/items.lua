local UEHelpers = require("UEHelpers")

local M = {}

M.item_to_allow = nil

function M.AddToRaz(itemPath, amount)
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
    M.item_to_allow = item_to_add:GetFullName()
    blueprint_library:AddToRazInventory(level_script_actor, item_to_add, amount)
end

function M.RemoveFromRaz(itemPath, amount)
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

function M.RemoveAllClassFromRaz(className, amount)
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

return M