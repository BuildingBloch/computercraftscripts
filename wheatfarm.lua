-- Constants for fuel
local FUEL_THRESHOLD = 10
local REFUEL_SLOT = 16

-- Function to check and refuel the turtle
function checkFuel()
    if turtle.getFuelLevel() < FUEL_THRESHOLD then
        print("Low fuel! Attempting to refuel...")
        turtle.select(REFUEL_SLOT)
        while turtle.getFuelLevel() < FUEL_THRESHOLD do
            turtle.refuel(1)
            os.sleep(10)
        end
        print("Refueled!")
    end
end

-- Inspect and take action based on the block below the turtle
function inspect()
    -- Check fuel before any action
    checkFuel()

    local success, data = turtle.inspectDown()

    if success and data.name == "minecraft:wheat" then
        print("Harvesting...")
        if data.metadata == 7 then
            turtle.digDown()
        end
        turtle.select(1)
        turtle.placeDown()

        return
    end

    turtle.down()
    success, data = turtle.inspectDown()
    if success and data.name == "minecraft:farmland" then
        print("Planting on tilled land...")
        turtle.up()
        turtle.select(1)
        turtle.placeDown()
        return
    elseif success and (data.name == "minecraft:dirt" or data.name == "minecraft:grass_block") then
        print("Tilling and planting...")
        turtle.up()
        turtle.digDown()
        turtle.select(1)
        turtle.placeDown()
        return
    else
        turtle.up()
    end
end

-- Move the turtle based on its mode
function move(mode)
    -- Check fuel before moving
    checkFuel()

    local success, data = turtle.inspect()
    
    if success and data.name == "minecraft:cobblestone" then
        if mode == "forward" then
            print("Turning right from forward mode")
            turtle.turnRight()
            success, data = turtle.inspect()
            if success and data.name == "minecraft:cobblestone" then
                turtle.turnRight()
                print("Moving to backward mode")
                return "backward"
            else
                turtle.forward()
                turtle.turnRight()
                return "backward"
            end
        elseif mode == "backward" then
            print("Turning left from backward mode")
            turtle.turnLeft()
            success, data = turtle.inspect()
            if success and data.name == "minecraft:cobblestone" then
                turtle.turnRight()
                print("Completed the farm, moving to returning mode")
                return "returning"
            else
                turtle.forward()
                turtle.turnLeft()
                return "forward"
            end
        elseif mode == "returning" then
            print("Returning to start")
            success, data = turtle.inspect()
            if success and data.name == "minecraft:cobblestone" then
                turtle.turnRight()
                print("Reached the start, moving to forward mode")
                os.sleep(60)
                return "forward"
            else
                turtle.forward()
                return "returning"
            end
        end
    else
        turtle.forward()
        return mode
    end
end

-- Main function to orchestrate farming
function main()
    local mode = "forward"
    while true do
        inspect()
        mode = move(mode)
    end
end

-- Start the farming
main()
