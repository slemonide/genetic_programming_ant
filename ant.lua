local function f()
    local ant = {}

    ant.food_eaten = 0

    ant.direction = "east"
    -- directions in the clockwise order
    ant.directions = {
        --  dir      prev     next
        east = {"north", "south"},
        south = {"east", "west"},
        west = {"south", "north"},
        north = {"west", "east"}}

    -- Where to move depending to directions
    ant.directions_position_changes = {
        east = {x = 1, y = 0},
        south = {x = 0, y = 1},
        west = {x = -1, y = 0},
        north = {x = 0, y = -1}
    }

    -- Spawn ant at (x, y) on the food field
    function ant:spawn(x, y, food)
        ant.x = x
        ant.y = y
        ant.food = food
    end

    -- Returns true if there is food exactly in front of ant looking direction
    function ant:isLookingAtFood()
        local x = ant.x + ant.directions_position_changes[ant.direction].x
        local y = ant.y + ant.directions_position_changes[ant.direction].y

        return ant.food:contains(x, y) and true or false
    end

    -- Move and forward
    function ant:move()
        ant.x = ant.x + ant.directions_position_changes[ant.direction].x
        ant.y = ant.y + ant.directions_position_changes[ant.direction].y

        if ant.x < 1 then
            ant.x = ant.x + CONFIG.FIELD_SIZE
        end

        if ant.y < 1 then
            ant.y = ant.y + CONFIG.FIELD_SIZE
        end

        if ant.x > CONFIG.FIELD_SIZE then
            ant.x = ant.x - CONFIG.FIELD_SIZE
        end

        if ant.y > CONFIG.FIELD_SIZE then
            ant.y = ant.y - CONFIG.FIELD_SIZE
        end

        if ant.food:contains(ant.x, ant.y) then
            ant.food_eaten = ant.food_eaten + 1
            ant.food:remove(ant.x, ant.y)
        end
    end

    -- Rotate and to the left
    function ant:turnLeft()
        ant.direction = ant.directions[ant.direction][1]
    end

    -- Rotate ant to the right
    function ant:turnRight()
        ant.direction = ant.directions[ant.direction][2]
    end

    return ant
end

return f