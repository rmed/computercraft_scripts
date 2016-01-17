-- Sorting turtle catalog
-- Rafael Medina - https://github.com/rmed/computercraft_scripts
--

--
-- Positions
--
-- Floors
FLOORS = {85, 89}
-- Elevator space
ELEVATOR = {x = -966, z = 37}
-- Starting position
START = {x = -968, y = 85, z = 37, f = 1, dir = 0}

--
-- Chests
--
local MINECRAFT = {
    chests = {
        ["food"] = {x = -973, z = 37, f = 1},
        ["ore"] = {x = -977, z = 27, f = 1},
        ["plant"] = {x = -976, z = 37, f = 1},
        ["stone"] = {x = -977, z = 33, f = 1},
        ["wood"] = {x = -977, z = 36, f = 1},
        ["tool"] = {x = -977, z = 30, f = 1},
    },

    items = {
        ["gravel"] = "stone",
        ["furnace"] = "stone",
        ["obsidian"] = "stone",
        ["planks"] = "wood",
        ["log"] = "wood",
        ["fence"] = "wood",
        ["chest"] = "wood",
        ["trapped_chest"] = "wood",
        ["crafting_table"] = "wood",
        ["fence_gate"] = "wood",
        ["log2"] = "wood",
        ["boat"] = "wood",
        ["sign"] = "wood",
        ["stick"] = "wood",
        ["gold_block"] = "ore",
        ["iron_block"] = "ore",
        ["diamond_block"] = "ore",
        ["emerald_block"] = "ore",
        ["diamond"] = "ore",
        ["coal"] = "ore",
        ["bow"] = "tool",
        ["flint_and_steel"] = "tool",
        ["shears"] = "tool",
        ["fishing_rod"] = "tool",
        ["bread"] = "food",
        ["wheat"] = "food",
        ["carrot"] = "food",
        ["potato"] = "food",
        ["baked_potato"] = "food",
        ["poisonous_potato"] = "food",
        ["golden_carrot"] = "food",
        ["pumpkin_pie"] = "food",
        ["cake"] = "food",
        ["beef"] = "food",
        ["cooked_beef"] = "food",
        ["chicken"] = "food",
        ["cooked_chicken"] = "food",
        ["melon"] = "food",
        ["cookie"] = "food",
        ["sugar"] = "food",
        ["egg"] = "food",
        ["sapling"] = "plant",
        ["reeds"] = "plant",

    },

    patterns = {
        ["(.*)stone(.*)"] = "stone",
        ["(.*)brick(.*)"] = "stone",
        ["(.*)clay(.*)"] = "stone",
        ["(.*)quartz(.*)"] = "stone",
        ["(.*)wood(.*)"] = "wood",
        ["(.*)oak(.*)"] = "wood",
        ["(.*)spruce(.*)"] = "wood",
        ["(.*)jungle(.*)"] = "wood",
        ["(.*)birch(.*)"] = "wood",
        ["(.*)ore(.*)"] = "ore",
        ["(.*)ingot(.*)"] = "ore",
        ["(.*)sword(.*)"] = "tool",
        ["(.*)hoe(.*)"] = "tool",
        ["(.*)axe(.*)"] = "tool",
        ["(.*)shovel(.*)"] = "tool",
        ["(.*)pickaxe(.*)"] = "tool",
        ["(.*)seed(.*)"] = "plant",
    }
}

-- Misc chests
local MISC = {x = -966, z = 35, f = 1}

-- Get the chest for this item
local function parse(item_set, item_name)
    local chest_id = item_set.items[item_name] or nil

    -- Try to get general case
    if chest_id ~= nil then
        return item_set.chests[chest_id]
    end

    -- Special cases (regexp)
    for pattern, value in pairs(item_set.patterns) do
        if item_name:find(pattern) then
            return item_set.chests[value]
        end
    end

    -- Not found
    return nil
end

-- Get chest for the given item
function get_chest(item_id)
    -- Get mod
    local mod_name = ""
    local item_name = ""

    mod_name, item_name = item_id:match("([^,]+):([^,]+)")

    -- Specific parsing
    local result = nil

    if mod_name == "minecraft" then result = parse(MINECRAFT, item_name)

    end

    if result then return result end

    -- Unknown?
    print("Unknown item: ", item_id)
    return MISC
end
