-- Constants
local MAX_HEIGHT = 2  -- Maximum height of the chest stack
local TURTLE_SLOTS = 16  -- Number of inventory slots in the turtle
local CHEST_SLOTS = 54  -- Number of slots in a double chest

-- Initialize starting chest
local startingChest = peripheral.wrap("back")

-- Mapping of item types to their corresponding forward positions
local itemToForwardMapping = {
    ["minecraft:wheat"] = 1,
    ["minecraft:wheat_seeds"] = 2,
    ["minecraft:iron_ore"] = 3
}

-- Moves the turtle to the specified forward position
local function goToPosition(forwardIndex)
    for i = 1, 1 + forwardIndex do
        turtle.forward()
    end
end

-- Returns the turtle to the starting position
local function returnToStart(forwardIndex, currentHeightIndex)
    for i = 1, currentHeightIndex do
        turtle.down()
    end
    for i = 1, 1 + forwardIndex do
        turtle.back()
    end
end

-- Checks if the turtle can deposit items into a chest at the given side
local function canDeposit(side)
    local chest = peripheral.wrap(side)
    if not chest then return false end
    for slot = 1, CHEST_SLOTS do
        if not chest.getItemDetail(slot) then return true end
    end
    return false
end

-- Deposits an item into the appropriate chest
local function depositItem(item)
    local forwardIndex = itemToForwardMapping[item]
    if not forwardIndex then
        print("Unmapped item: " .. item)
        return
    end

    local currentHeightIndex = 0
    local isDeposited = false

    goToPosition(forwardIndex)

    while not isDeposited and currentHeightIndex < MAX_HEIGHT do
        if canDeposit("left") then
            turtle.turnLeft()
            turtle.drop()
            turtle.turnRight()
            isDeposited = true
        elseif canDeposit("right") then
            turtle.turnRight()
            turtle.drop()
            turtle.turnLeft()
            isDeposited = true
        else
            turtle.up()
            currentHeightIndex = currentHeightIndex + 1
        end
    end

    if not isDeposited then
        print("Chest overflow for item: " .. item)
    else
        returnToStart(forwardIndex, currentHeightIndex)
    end
end

-- Function to unload items from starting chest to turtle's inventory
local function unloadFromStartChest()
    for slot = 1, startingChest.size() do
        -- Check if turtle's inventory is full
        local isFull = true
        for tSlot = 1, TURTLE_SLOTS do
            if turtle.getItemCount(tSlot) == 0 then
                isFull = false
                break
            end
        end

        -- Stop unloading if turtle is full
        if isFull then
            print("Turtle's inventory is full.")
            return
        end

        local itemDetail = startingChest.getItemDetail(slot)
        if itemDetail then
            startingChest.pushItems("right", slot, 64)
        end
    end
end

local function depositAllItems()
    for i = 1, TURTLE_SLOTS do
        turtle.select(i)
        local itemDetail = turtle.getItemDetail()
        if itemDetail then
            depositItem(itemDetail.name)
        end
    end
end


local function main()
    -- Main loop
    while true do
        startingChest = peripheral.wrap("back")
        -- print startingChest's peripherals
        print("Starting chest's peripherals:")

        unloadFromStartChest()
        depositAllItems()
        os.sleep(5)
    end
end

main()
