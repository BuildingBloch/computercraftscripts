local modem = peripheral.find("modem")
local tagBlock = "minecraft:diorite"
local generalChannel = 69

-- Open general channel
modem.open(generalChannel)

math.randomseed(os.time())

local function getInventoryStatus()
    local status = {}
    for i = 1, 16 do
        turtle.select(i)
        local item = turtle.getItemDetail()
        status[i] = item and item.name or nil
    end
    return status
end

while true do
    local success, data = turtle.inspectDown()

    -- Check for the 'tag' block
    if success and data.name == tagBlock then
        local randomChannel = math.random(1000, 9999)
        modem.open(randomChannel)

        local inventoryStatus = getInventoryStatus()
        modem.transmit(generalChannel, randomChannel, textutils.serialize({command = "ping", inventory = inventoryStatus}))

        local event, side, channel, replyChannel, message, distance
        repeat
            event, side, channel, replyChannel, message, distance = os.pullEvent("modem_message")
        until channel == randomChannel

        local response = textutils.unserialize(message)
        if response.stationID == "central" then
            turtle.turnLeft()
            for i = 1, 16 do
                turtle.select(i)
                turtle.drop()
            end
            turtle.turnRight()
        else
            print("Received response from station: " .. response.stationID)
            repeat
                event, side, channel, replyChannel, message, distance = os.pullEvent("modem_message")
            until message == "done"
        end

        modem.close(randomChannel)
    end

    local success, _ = turtle.inspect()
    if success then
        turtle.turnRight()
    else
        turtle.forward()
    end
end
