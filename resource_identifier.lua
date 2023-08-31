local STATION_ID = "farm_1"
local RESOURCES_IN = {}
local RESOURCES_OUT = {"minecraft:wheat", "minecraft:wheat_seeds"}

local modem = peripheral.find("modem")
local generalChannel = 69

-- Attach to the chest on the right
local chest = peripheral.wrap("right")

-- Open the general channel for communication
modem.open(generalChannel)

-- Helper function to check if a value exists in a table
function table.contains(table, element)
    for _, value in pairs(table) do
        if value == element then
            return true
        end
    end
    return false
end

while true do
    -- Wait for a modem message
    local event, side, channel, replyChannel, message, distance = os.pullEvent("modem_message")
    
    -- Check if the distance is <= 3
    if distance <= 3 then
        -- Deserialize the incoming message to get the command and inventory status
        local request = textutils.unserialize(message)

        if request.command == "ping" then
            -- Inventory status of the turtle
            local inventoryStatus = request.inventory

            -- Create a response object containing stationID and resources in and out
            local response = {
                stationID = STATION_ID,
                resourcesIn = RESOURCES_IN,
                resourcesOut = RESOURCES_OUT
            }

            -- Transmit the response back to the turtle
            modem.transmit(replyChannel, generalChannel, textutils.serialize(response))

            if STATION_ID ~= "central" then
                -- Logic to push items to the turtle based on `inventoryStatus`
                local nextEmptySlot = 1
                for slot = 1, chest.size() do
                    local itemDetail = chest.getItemDetail(slot)
                    if itemDetail and table.contains(response.resourcesOut, itemDetail.name) then
                        -- Find the next empty slot in the turtle's inventory
                        while inventoryStatus[nextEmptySlot] do
                            nextEmptySlot = nextEmptySlot + 1
                        end
                        -- If nextEmptySlot exceeds 16, the turtle is full
                        if nextEmptySlot > 16 then
                            break
                        end
                        chest.pushItems("front", slot, 64, nextEmptySlot)
                        inventoryStatus[nextEmptySlot] = itemDetail
                    end
                end
            end
            
            -- Once all is done, send a 'done' message back to the turtle to signal completion
            modem.transmit(replyChannel, generalChannel, "done")
        end
    end
end
