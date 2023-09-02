-- Main function
function main()
    rednet.open("left")  -- Replace "side" with the side where the modem is placed.

    local turtleID = 11

    while true do

        local command = io.read()
        rednet.send(turtleID, command)

        local senderID, response = rednet.receive()
        print("Turtle " .. senderID .. ": " .. response)

        while response ~= "Awaiting commmand." do 

            local senderID, response = rednet.receive()

            if response == "Need next instruction." then
                
                local senderID, response = rednet.receive()
                print("Turtle " .. senderID .. ": " .. response)
                local command = io.read()
                rednet.send(turtleID, command)
            end

            print("Turtle " .. senderID .. ": " .. response)
        end
    end

    rednet.close()
end

-- Start the farming
main()
