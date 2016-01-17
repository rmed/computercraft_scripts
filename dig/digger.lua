-- Digger turtle
-- Rafael Medina - https://github.com/rmed/computercraft_scripts
--

-- Initialization

-- Current position and looking direction
-- North and south are X
-- East and west are Z
-- 0 = north +
-- 1 = east +
-- 2 = south -
-- 3 = west -

-- Starts at x=0, y=0, z=0, l=2 (south, looking at chest)
-- .....................
-- .                   .
-- .                   .
-- .                   .
-- .                   .
-- .                   .
-- +....................
-- CC
CURRENT = {x = 0, y = 0, z = 0, l = 2}
END = {x = 0, y = 0, z = 0}

-- MOVEMENT FUNCTIONS

-- Rotate and update looking status
function rotate(dir)
    while CURRENT.l ~= dir do
        turtle.turnRight()
        CURRENT.l = (CURRENT.l + 1) % 4
    end
end

-- Go forward or up or down
function go_to(dir)
    -- Check fuel
    check_fuel()

    local moved = false

    if dir == "front" then
        while not moved do moved = turtle.forward() end
    elseif dir == "up" then
        while not moved do moved = turtle.up() end
    else
        while not moved do moved = turtle.down() end
    end
end

-- Rotate and move one block forward in a given cardinal direction
-- 0 = north
-- 1 = east
-- 2 = south
-- 3 = west
function move_cardinal(dir)
    rotate(dir)
    go_to("front")

    if dir == 0 then
        CURRENT.x = CURRENT.x + 1
    elseif dir == 1 then
        CURRENT.z = CURRENT.z + 1
    elseif dir == 2 then
        CURRENT.x = CURRENT.x - 1
    elseif dir == 3 then
        CURRENT.z = CURRENT.z - 1
    end
end

-- Move to a position in the same floor
function move_to(x, z)
    -- First move in Z
    while CURRENT.z ~= z do
        if CURRENT.z < z then
            move_cardinal(1)
        elseif CURRENT.z > z then
            move_cardinal(3)
        end
    end

    -- Move in X
    while CURRENT.x ~= x do
        if CURRENT.x < x then
            move_cardinal(0)
        elseif CURRENT.x > x then
            move_cardinal(2)
        end
    end
end

-- Go to the "elevator" space
function go_elevator()
    move_to(0, 0)
    -- Face north
    rotate(0)
end

-- Ascend to first level and drop all the items
function drop_items(must_return)
    local current_x = CURRENT.x
    local current_z = CURRENT.z
    local current_y = CURRENT.y
    local current_l = CURRENT.l

    go_elevator()

    while CURRENT.y ~= 0 do
        go_to("up")
        CURRENT.y = CURRENT.y - 1
    end

    -- Drop items
    find_chest()

    -- Last item slot reserved for fuel
    local dropped = false
    for i=1,15 do
        turtle.select(i)

        -- Items to drop?
        if turtle.getItemCount(turtle.getSelectedSlot()) > 0 then
            while dropped == false do
                dropped = turtle.drop()
            end
            -- Reset
            dropped = false
        end
    end

    if must_return then
        -- Return to floor
        while CURRENT.y ~= current_y do
            go_to("down")
            CURRENT.y = CURRENT.y + 1
        end

        -- Return to position
        move_to(current_x, current_z)

        -- Face block
        rotate(current_l)
    end
end

-- Start digging a level down
function level_down()
    local digged = true

    while true do
        digged = true
        -- Have to dig down?
        if turtle.detectDown() then
            digged = turtle.digDown()
        end

        -- Go down
        if digged then
            go_to("down")
            CURRENT.y = CURRENT.y + 1
            break

        else
            -- Cannot go down, full inventory?
            drop_items(true)
        end
    end
end

-- Dig block in front
function dig_in_front()
    local digged = false

    while digged == false do
        -- Block in front?
        if turtle.detect() then
            -- Check special cases
            local _, data = turtle.inspect()
            if (data.name == "minecraft:flowing_water"
                or data.name == "minecraft:water"
                or data.name == "minecraft:flowing_lava"
                or data.name == "minecraft.lava") then
                digged = true
            else
                digged = turtle.dig()
            end
        else
            -- Nothing to dig
            digged = true
        end

        if digged == false then
            -- Cannot dig, full inventory?
            drop_items(true)
        end
    end
end

-- Dig out a complete level
function dig_level()
    -- Face north
    rotate(0)
    local dir = 0

    dig_in_front()

    -- Primary lines are North-South
    while true do

        -- Advance if in bounds
        if dir == 0 then
            -- Going north
            if (CURRENT.x + 1) < END.x  then
                go_to("front")
                CURRENT.x = CURRENT.x + 1
            else
                if (CURRENT.z + 1) < END.z then
                    -- Mine east block and change dir
                    rotate(1)
                    dig_in_front()
                    go_to("front")

                    rotate(2)
                    dir = 2
                    CURRENT.z  = CURRENT.z + 1
                else
                    -- Finished
                    break
                end
            end

        elseif dir == 2 then
            -- Going down
            if (CURRENT.x - 1) >= 0 then
                go_to("front")
                CURRENT.x = CURRENT.x - 1
            else
                if (CURRENT.z + 1) < END.z then
                    -- Mine east block and change dir
                    rotate(1)
                    dig_in_front()
                    go_to("front")

                    rotate(0)
                    dir = 0
                    CURRENT.z  = CURRENT.z + 1
                else
                    -- Finished
                    break
                end
            end
        end
        dig_in_front()
    end
end

-- UTILITY FUNCTIONS

-- Check the fuel. Must be called in movement functions
function check_fuel()
    if turtle.getFuelLevel() < 1 then
        print("Need more fuel. Place it in slot 16")
        local current_slot = turtle.getSelectedSlot()

        while turtle.getFuelLevel() ~= "unlimited" and turtle.getFuelLevel() < 1 do
            turtle.select(16)
            -- Consume only one each time
            turtle.refuel(1)
        end
        turtle.select(current_slot)

        print("Current fuel level: ", turtle.getFuelLevel())
    end
end

-- Rotate until the turtle is facing the chest
function find_chest()
    local _, data = turtle.inspect()

    while data.name ~= "minecraft:chest" do
        turtle.turnRight()
        CURRENT.l = (CURRENT.l + 1) % 4

        _, data = turtle.inspect()
    end
end


-- Main subroutine starts here

-- Ask for input
print("Width of the area? [>]")
END.z = tonumber(read())

print("Height of the area? [^]")
END.x = tonumber(read())

print("Levels to dig?")
END.y = tonumber(read())

print("Levels to skip? (num)")
to_skip = tonumber(read())
END.y = END.y + to_skip

go_elevator()
drop_items(true)

while CURRENT.y ~= to_skip do
    level_down()
end


print("GO!")

-- Continue until all levels have been cleared
finished = false
while not finished do
    -- Check if at last level
    if CURRENT.y == END.y then
        finished = true
        break
    end

    -- Go down a level
    --go_elevator()
    --drop_items(true)
    level_down()
    dig_level()
    go_elevator()
    drop_items(true)
end

-- Drop items at chest
drop_items(false)

print("Finished digging " .. END.y .. " levels (" .. to_skip .. " skipped) in " .. END.z .. "x" .. END.x .. " area")
