Multiworld = {}

local UEHelpers = require("UEHelpers")
local AP = require "lua-apclientpp"
local items = require("items")
local levels = require("levels")
local item_map = require("ap_item_map")
local loc_map = require("ap_loc_map")

if AP == nil then
    error("lua-apclientpp not found!")
    return
end

local ap = nil
local LocWaiting = {}
-- local IsAPGrant = false
local ItemsReceivedIndex = 0 -- tracks items received

function Multiworld:Connect(host, slot, password)
    if ap then
        print("[AP] Already connected or connection in progress\n")
        ap = nil
        return
    end

    ap = AP("", "Psychonauts 2", host)
    print("[AP] Attempting connection to server as " .. slot .. "\n")

    ap:set_socket_connected_handler(function() print("[AP] Socket connected\n") end)
    ap:set_socket_disconnected_handler(function() print("[AP] Socket disconnected\n"); ap = nil end)
    ap:set_socket_error_handler(function(msg) print("[AP] Socket error: " .. msg .. "\n") end)

    ap:set_room_info_handler(function()
        print("[AP] Room info received. Authenticating\n")
        -- 7 tells the server we want to both Send and Receive items
        ap:ConnectSlot(slot, password or "", 7, {"Psychonauts 2 Client"}, {0, 6, 7})
    end)

    ap:set_slot_connected_handler(function(slot_data)
        print("[AP] Connected to slot successfully!\n")
    end)

    ap:set_slot_refused_handler(function(reasons)
        print("[AP ERROR] Slot refused: " .. table.concat(reasons, ", ") .. "\n")
        ap = nil
    end)

    -- Handle INCOMING items from the server
    ap:set_items_received_handler(function(items)
        -- only process new ones
        for i, item in ipairs(items) do
            -- if i > ItemsReceivedIndex then
            print("[AP] Received item from server: " .. item.item .. "\n")
            Multiworld:ReceiveItem(item.item)
            ItemsReceivedIndex = ItemsReceivedIndex + 1
        end
        
        -- debugging
        print("[AP] Received: " .. tostring(#items) .. " from server\n")
        for _, item in ipairs(items) do 
            print("[AP] Received item from server: " .. tostring(item.item) .. "\n")
        end
    end)
end

function Multiworld:PrintToGame(text)
    local kismet_system = UEHelpers.GetKismetSystemLibrary()
    if not kismet_system then 
        print("[AP ERROR] Could not find KismetSystemLibrary.")
        return 
    end
    
    -- Using GetWorld() instead of LevelScriptActor guarantees 
    -- the text is drawn to the player's active screen context.
    local world = UEHelpers.GetWorld()
    
    if world and world:IsValid() then
        print("[AP DEBUG] Firing PrintString to World...\n")
        
        kismet_system:PrintString(
            world, 
            tostring(text), 
            true,  -- Print to screen
            false, -- Don't print to UE4 log
            {R=0.0, G=1.0, B=1.0, A=1.0}, -- Standard Cyan
            15.0   -- Duration
        )
    else
        print("[AP ERROR] World context was invalid, could not print.")
    end
end



-- ==========================================
-- Polling engine 
-- ==========================================
-- polls 20 times a second
LoopAsync(50, function()
    ExecuteInGameThread(function()
        if ap then
            -- Wrap the polling in a protected call to prevent silent thread crashes
            local success, err = pcall(function()
                ap:poll()
                if #LocWaiting > 0 then
                    ap:LocationsChecks(LocWaiting)
                    LocWaiting = {}
                end
            end)
            
            -- If the network loop crashes, YELL at us in the console
            if not success then
                print("[AP POLLING ERROR] " .. tostring(err) .. "\n")
            end
        end
    end)
    -- Returning false keeps the loop running 
    return false
end)

function Multiworld:SendLocationCheck(location_id)
    if not ap then return end
    print("[AP] Sending location ID " .. tostring(location_id) .. "\n")
    if ap then
        local success, err = pcall(function()
            -- Send the check immediately as a table
            ap:LocationChecks({location_id})
        end)

        if success then
            print("[AP] Packet successfully left the client!\n")
        else
            print("[AP ERROR] Failed to send packet: " .. tostring(err) .. "\n")
        end
    end
end

function Multiworld:ReceiveItem(item_id)
    print(item_id)
    local item = AP_Item_Map[item_id]
    if item.type == "brain" then
        levels.UnlockBrainLevel(item.path)
    elseif item.type == "item" then
        items.AddToRaz(item.path, 1)
    elseif item.type == "hub" then
        levels.UnlockHubLevel(item.path)
    elseif item.type == "boss" then
        levels.final_boss_unlocked = true
    else
        print("[AP ERROR] Unknown Item ID received: " .. tostring(item_id) .. "\n")
    end
end

return Multiworld