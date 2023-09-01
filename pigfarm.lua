local MASTER_SERVER = 12
local MAX_MEAT_COUNT = 3
local MAX_CARROT_COUNT = 10

-- Deposit all items
function depositItems()
    for i = 1, 16 do
        turtle.select(i)
        local itemDetail = turtle.getItemDetail()
        if itemDetail then
            turtle.drop()
        end
    end
end

-- Inspect and take action based on the turtle routine
function action(routine)

    if routine == "Cull" then
        print("Culling.")
        turtle.attackDown()

        -- Before we do anything else, check if we have enough meat

        local meat_count = 0;
        for i = 1,16 do
            meat_count = meat_count + turtle.getItemCount(i)
        end

        if meat_count >= MAX_MEAT_COUNT then
            print("Cull successful.")
            return "Return"
        else
            return "Cull"
        end
    elseif routine == "Nourish" then

        local response = "Command 'Nourish' acknowledged."
        rednet.send(MASTER_SERVER, response)

        carrot_count = turtle.getItemCount(1)

        -- If starting with 0 carrots, grab carrots from chest
        if carrot_count == 0 then
            turtle.turnRight()
            local success, data = turtle.inspect()
            if success and data.name == "minecraft:chest" then
                turtle.select(1)
                turtle.suck(MAX_CARROT_COUNT)
            end
            turtle.turnLeft()
        end

        if carrot_count >= 1 then
                turtle.select(1)
                turtle.placeDown()
        end
        
        carrot_count = turtle.getItemCount(1)

        if carrot_count <= 0 then
            local response = "Command 'Nourish' complete."
            rednet.send(MASTER_SERVER, response)
            print(response)
            return "Return"
        else
            return "Nourish"
        end
    else
        return routine
    end
end

function reset(routine)
    if routine == "Return" then
        local success, data = turtle.inspect()
        if success and data.name == "minecraft:chest" then
            depositItems()
            turtle.turnLeft()
            local response = "Awaiting Command."
            rednet.send(MASTER_SERVER, response)
            print(response)
            return "End"
        else
            return "Return"
        end
    else
        print("Searching.")
        return routine
    end
end
-- Move the turtle based on its mode
function move()
    local success, data = turtle.inspect()
    if success then
        turtle.turnLeft()
        success, data = turtle.inspect()
        if success then
            turtle.turnLeft()
            return
        else
            return
        end
    else
        turtle.forward()
        return
    end
end

-- Main function to orchestrate farming
function main()
    rednet.open("left")  -- Replace "side" with the side where the modem is placed.

    while true do
        local senderID, command = rednet.receive()
        print("Received message from" .. senderID .. ": " .. command)

        local routine = command

        while routine == "Cull" do
            move()
            routine = action(routine)
        end

        while routine == "Nourish" do
            routine = action(routine)
            move()
        end

        while routine == "Return" do
            move()
            routine = reset(routine)
        end
    end

    rednet.close()
end

-- Start the farming
main()
