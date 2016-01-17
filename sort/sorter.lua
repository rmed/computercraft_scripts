-- Sorting turtle catalog
-- Rafael Medina - https://github.com/rmed/computercraft_scripts
--

-- Load API
os.loadAPI("catalog")


-- Turtle information

-- Currently looking at

-- North and south are Z
-- East and west are X
-- 0 = south +
-- 1 = west -
-- 2 = north -
-- 3 = east +
looking = catalog.START.dir

-- Current position
-- Same as starting position
current = {
    x = catalog.START.x,
    y = catalog.START.y,
    z = catalog.START.z,
    f = catalog.START.f
}


-- MOVEMENT FUNCTIONS

-- Rotate and update looking status
function rotate(dir)
    while looking ~= dir do
        turtle.turnRight()
        looking = looking + 1

        -- Overflow
        if looking == -1 then looking = 3
        elseif looking == 4 then looking = 0 end
    end
end

-- Go forward, up or down
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
-- North and south are Z
-- East and west are X
-- 0 = south +
-- 1 = west -
-- 2 = north -
-- 3 = east +
function move_cardinal(dir)
    rotate(dir)
    go_to("front")

    if dir == 0 then
        current.z = current.z + 1
    elseif dir == 1 then
        current.x = current.x - 1
    elseif dir == 2 then
        current.z = current.z - 1
    elseif dir == 3 then
        current.x = current.x + 1
    end
end

-- Move to a position in the same floor
function move_to(x, z)
    -- First move in X
    while current.x ~= x do
        if current.x < x then
            move_cardinal(3)
        elseif current.x > x then
            move_cardinal(1)
        end
    end

    -- Move in Z
    while current.z ~= z do
        if current.z < z then
            move_cardinal(0)
        elseif current.z > z then
            move_cardinal(2)
        end
    end
end

-- Go to the specified floor
function go_floor(dest_floor)
    -- Move to elevator space
    move_to(catalog.ELEVATOR.x, catalog.ELEVATOR.z)

    local height = catalog.FLOORS[dest_floor]

    -- Ascend / descend
    while current.y ~= height do
        if current.y > height then
            go_to("down")
            current.y = current.y - 1
        elseif current.y < height then
            go_to("up")
            current.y = current.y + 1
        end
    end

    current.f = dest_floor
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
        looking = looking + 1

        -- Overflow
        if looking == -1 then looking = 3
        elseif looking == 4 then looking = 0 end

        _, data = turtle.inspect()
    end
end

-- Meta function for performing sorts
function do_sort(dest_chest)
    move_to(dest_chest.x, dest_chest.z)

    -- Find chest
    find_chest()

    -- Drop items
    local has_dropped = turtle.drop()
    if not has_dropped then
        -- Go to the chest above
        go_to("up")
        turtle.drop()
        go_to("down")
    end
end

-- Main subroutine starts here

-- Continue until chest is empty
finished = false
while not finished do
    -- Gather items from chest
    for i=1,15 do
        turtle.select(i)

        -- Gather a stack
        local sucked = turtle.suck()
        if not sucked then
            finished = true
            break
        end
    end

    -- Last item slot reserved for fuel
    for i=1,15 do
        turtle.select(i)

        -- No more items to organize
        if turtle.getItemCount() == 0 then break end

        -- Get chest
        local dest_chest = catalog.get_chest(turtle.getItemDetail().name)

        -- Find the floor
        local dest_floor = dest_chest.f

        -- Need to change floors?
        if dest_floor ~= current.f then go_floor(dest_floor) end

        -- Sort
        do_sort(dest_chest)
    end

    -- Move to floor 1
    if current.f ~= 1 then go_floor(1) end

    -- Move to starting position
    move_to(catalog.START.x, catalog.START.z)

    -- Face starting dir
    rotate(catalog.START.dir)
end
