-- Credits https://github.com/na-stewart/Better-Excavate/blob/master/bexcavate.lua
local args = {...}
if #args < 3 then
    print("Usage: bexcavate <Width> <Length> <Depth>")
    return
end

local turn_right = true
local width = tonumber(args[1])
local length = tonumber(args[2])
local depth = tonumber(args[3])
 
local function rotate_right()
    turtle.turnRight()
    turtle.turnRight()
end

 
 
local function forward()
    while not turtle.forward() do
        turtle.dig()
        turtle.attack()
        sleep()
    end
end
 
 
local function turn_around()
    if turn_right then
        turtle.turnRight()
        turtle.dig()
        forward()
        turtle.turnRight()
        turn_right = false
    else    
        turtle.turnLeft()
        turtle.dig()
        forward()
        turtle.turnLeft()
        turn_right = true      
    end
end
 
 
local function reset()
    turtle.turnRight()
    if turn_right then
        turtle.turnRight()
        for z = 1, length, 1 do
            forward()
        end
        turtle.turnRight()
    end
    for x = 1, width - 1, 1 do
        forward()
    end
    turtle.turnRight()
    turtle.digDown()
    turtle.down()
end
 

print("Excavation initiated...")
for y = 1, depth do
    turtle.select(1)
    turtle.refuel()
    turn_right = true
    for x = 1, width, 1 do
        for z = 1, length, 1 do
            turtle.dig()
            forward()    
        end
        if x < width then
            turn_around()
        else
            reset()
        end
    end
    print("Layer completed, " .. depth - y .." left to go.")
end

print("Excavation complete.")