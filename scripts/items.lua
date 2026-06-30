local UEHelpers = require("UEHelpers")

local M = {}

M.ability_enum_to_loc = {
    [0] = "/Game/Gameplay/Inventory/Powers/POWERKEY_Telekinesis.POWERKEY_Telekinesis",
    [1] = "/Game/Gameplay/Inventory/Powers/POWERKEY_PsiBlast.POWERKEY_PsiBlast",
    [2] = "/Game/Gameplay/Inventory/Powers/POWERKEY_Pyrokinesis.POWERKEY_Pyrokinesis",
    [3] = "/Game/Gameplay/Inventory/Powers/POWERKEY_Clairvoyance.POWERKEY_Clairvoyance",
    [4] = "/Game/Gameplay/Inventory/Powers/POWERKEY_MConn.POWERKEY_MConn",
    [5] = "/Game/Gameplay/Inventory/Powers/POWERKEY_TimeBubble.POWERKEY_TimeBubble",
    [7] = "/Game/Gameplay/Inventory/Powers/POWERKEY_Clone.POWERKEY_Clone",
    [15] = "/Game/Gameplay/Inventory/Powers/POWERKEY_Levitation.POWERKEY_Levitation",
}

M.item_to_allow = nil
M.mental_connection_unlocked = false

function M.AddToRaz(itemPath, amount)
    --- @class UP2BlueprintLibrary
    local blueprint_library = StaticFindObject("/Script/Psychonauts2.Default__P2BlueprintLibrary")
    if not blueprint_library:IsValid() then
        print("No instance of class 'Default__P2BlueprintLibrary' was found.")
        return
    end
    local persistent_level = UEHelpers:GetPersistentLevel()
    local level_script_actor = persistent_level.LevelScriptActor

    if itemPath == "/Game/Gameplay/Inventory/Powers/POWERKEY_MConn.POWERKEY_MConn" then
        M.mental_connection_unlocked = true
    end

    --- @class UInventoryItem
    local item_to_add = StaticFindObject(itemPath)
    if item_to_add:IsValid() then
        M.item_to_allow = item_to_add:GetFullName()
        blueprint_library:AddToRazInventory(level_script_actor, item_to_add, amount)
    else
        print(string.format("No object found with name: %s\n", itemPath))
        print("Attempting to load item...\n")

        local kismet_system = UEHelpers.GetKismetSystemLibrary()
        local soft_obj = kismet_system:Conv_SoftObjPathToSoftObjRef(kismet_system:MakeSoftObjectPath(itemPath))
        --- @class UInventoryItem
        local loaded_obj = kismet_system:LoadAsset_Blocking(soft_obj)
        M.item_to_allow = loaded_obj:GetFullName()
        blueprint_library:AddToRazInventory(level_script_actor, loaded_obj, amount)
    end

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