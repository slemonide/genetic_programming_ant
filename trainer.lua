local fieldSpawner = require("field")
local chromosomeSpawner = require("chromosome")

local trainer = {}

trainer.fields = {}
trainer.bestSpecies = {} -- best species from the previous generation

function trainer:load()

    for i = 1, CONFIG.POPULATION do
        local field = fieldSpawner()
        field:load()
        table.insert(trainer.fields, field)
    end

    trainer.generations = {}
    table.insert(trainer.generations, chromosomeSpawner(trainer.fields))

    trainer.generation = 1
    trainer.move = 0
end

function trainer:render()
    trainer.fields[1]:render(0,0)
    trainer.fields[1]:render(1,0)
    trainer.fields[1]:render(0,1)
    trainer.fields[1]:render(1,1)
    --[[
    trainer.generations[trainer.generation][1].field:render(0,0)
    trainer.generations[trainer.generation][2].field:render(1,0)
    trainer.generations[trainer.generation][3].field:render(0,1)
    trainer.generations[trainer.generation][4].field:render(1,1)
    --]]

    local size = CONFIG.FIELD_SIZE * (CONFIG.GRAPHICS.TILE_SIZE + 1)

    love.graphics.setColor(CONFIG.GRAPHICS.SPLITTER_COLOR)
    love.graphics.line(size, 0, size, size * 2)
    love.graphics.line(0, size, size * 2, size)
    love.graphics.line(0, size * 2, size * 2, size * 2)
    love.graphics.line(size * 2, 0, size * 2, size * 2)
    love.graphics.line(0, 0, size * 2, 0)
    love.graphics.line(0, 0, 0, size * 2)

    love.graphics.setColor(CONFIG.GRAPHICS.TEXT_COLOR)
    love.graphics.print("Generation: " .. trainer.generation, size * 2 + 10, 10)
    love.graphics.print("Move: " .. trainer.move, size * 2 + 10, 25)

    if (#trainer.bestSpecies > 0) then
        love.graphics.print("Best species so far:", size * 2 + 10, 40)

        for i = 1, math.min(#trainer.bestSpecies, CONFIG.GRAPHICS.MAX_BEST_SPECIES) do
            love.graphics.print(
                string.format("%f %s", trainer.bestSpecies[i].field.ant.food_eaten / CONFIG.MAX_FOOD, "%"),
                size * 2 + 30, 55 + i * 15)
        end
    end
end

function trainer:keypressed(key)
end

function trainer:update()
    local generation = trainer.generations[trainer.generation]

    for i = 1, #generation do
        generation[i].chromosome.action()
        generation[i].chromosome = generation[i].chromosome[trainer.fields[i].ant:isLookingAtFood()]
    end

    trainer.move = trainer.move + 1

    if (trainer.move > CONFIG.MAX_TURNS) then
        --print("Next generation!")
        -- compute best species
        table.sort(trainer.generations[trainer.generation], function(a, b)
            return a.field.ant.food_eaten > b.field.ant.food_eaten
        end)

        for i = 1, CONFIG.SURVIVAL_RATE do
            trainer.bestSpecies[i] = trainer.generations[trainer.generation][i]
        end

        trainer.generation = trainer.generation + 1
        trainer.move = 0

        -- Clean up fields
        trainer.fields = {}
        for i =1, #trainer.generations[trainer.generation - 1] do
            trainer.generations[trainer.generation - 1][i].fields = nil
        end

        for i = 1, CONFIG.POPULATION do
            local field = fieldSpawner()
            field:load()
            table.insert(trainer.fields, field)
        end

        -- Move best species to new world
        for i = 1, #trainer.bestSpecies do
            trainer.bestSpecies[i].field = trainer.fields[i]
        end

        trainer.generations[trainer.generation] = trainer.generations[trainer.generation - 1]
        --table.insert(trainer.generations, chromosomeSpawner(trainer.fields, trainer.bestSpecies))
    end
end

return trainer