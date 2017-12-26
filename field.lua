local xy_mapSpawner = require("xy_map")
local antSpawner = require("ant")


local function f()
    local field = {}
    field.food = xy_mapSpawner()
    field.ant = antSpawner()

    function field:load()
        local file = assert(io.open("food.txt", "r"))

        local structure = {}
        for line in file:lines() do
            table.insert(structure, line)
        end

        -- Parse structure
        for y = 1, #structure do
            local line = structure[y]
            for x = 1, line:len() do
                local material = line:sub(x, x)
                if (material == ".") then
                    -- do nothing
                elseif (material == "#") then
                    field.food:add(x, y)
                elseif (material == "a") then
                    field.ant:spawn(x, y, field.food)
                else
                    error("Unexpected item: " .. material)
                end
            end
        end

        file:close()
    end

    local function drawFood(x, y)
        love.graphics.setColor(CONFIG.GRAPHICS.FOOD_COLOR)
        love.graphics.rectangle("fill",
        x * CONFIG.GRAPHICS.TILE_SIZE,
        y * CONFIG.GRAPHICS.TILE_SIZE,
        CONFIG.GRAPHICS.TILE_SIZE,
        CONFIG.GRAPHICS.TILE_SIZE)
    end

    local function drawAnt()
        love.graphics.setColor(CONFIG.GRAPHICS.ANT_COLOR)

        if (field.ant.direction == "east") then
            love.graphics.polygon("fill",
            field.ant.x * CONFIG.GRAPHICS.TILE_SIZE, field.ant.y * CONFIG.GRAPHICS.TILE_SIZE,
            field.ant.x * CONFIG.GRAPHICS.TILE_SIZE, (field.ant.y + 1) * CONFIG.GRAPHICS.TILE_SIZE,
            (field.ant.x + 1) * CONFIG.GRAPHICS.TILE_SIZE, (field.ant.y + 0.5) * CONFIG.GRAPHICS.TILE_SIZE)
        elseif (field.ant.direction == "south") then
            love.graphics.polygon("fill",
            field.ant.x * CONFIG.GRAPHICS.TILE_SIZE, field.ant.y * CONFIG.GRAPHICS.TILE_SIZE,
            (field.ant.x + 1) * CONFIG.GRAPHICS.TILE_SIZE, field.ant.y * CONFIG.GRAPHICS.TILE_SIZE,
            (field.ant.x + 0.5) * CONFIG.GRAPHICS.TILE_SIZE, (field.ant.y + 1) * CONFIG.GRAPHICS.TILE_SIZE)
        elseif (field.ant.direction == "west") then
            love.graphics.polygon("fill",
            (field.ant.x + 1) * CONFIG.GRAPHICS.TILE_SIZE, field.ant.y * CONFIG.GRAPHICS.TILE_SIZE,
            (field.ant.x + 1) * CONFIG.GRAPHICS.TILE_SIZE, (field.ant.y + 1) * CONFIG.GRAPHICS.TILE_SIZE,
            field.ant.x * CONFIG.GRAPHICS.TILE_SIZE, (field.ant.y + 0.5) * CONFIG.GRAPHICS.TILE_SIZE)
        elseif (field.ant.direction == "north") then
            love.graphics.polygon("fill",
            field.ant.x * CONFIG.GRAPHICS.TILE_SIZE, (field.ant.y + 1) * CONFIG.GRAPHICS.TILE_SIZE,
            (field.ant.x + 1) * CONFIG.GRAPHICS.TILE_SIZE, (field.ant.y + 1) * CONFIG.GRAPHICS.TILE_SIZE,
            (field.ant.x + 0.5) * CONFIG.GRAPHICS.TILE_SIZE, field.ant.y * CONFIG.GRAPHICS.TILE_SIZE)
        end
    end

    function field:render(cx, cy)
        love.graphics.origin()

        local size = CONFIG.FIELD_SIZE * (CONFIG.GRAPHICS.TILE_SIZE + 1)

        love.graphics.translate(cx * size, cy * size)

        field.food:forEach(function (x, y)
            drawFood(x, y)
        end)
        drawAnt()

        love.graphics.origin()
    end

    function field:keypressed(key)
        if DEBUG then
            if (key == "left") then
                field.ant:turnLeft()
            elseif (key == "right") then
                field.ant:turnRight()
            elseif (key == "up") then
                field.ant:move()
            end
        end
    end

    function field:reset()
        field.food = xy_mapSpawner()
        field.ant = antSpawner()

        field:load()
    end

    return field
end

return f