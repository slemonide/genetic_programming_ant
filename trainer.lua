local fieldSpawner = require("field")
local chromosomeSpawner = require("chromosome")

local trainer = {}

trainer.fields = {}
trainer.fitness = {} -- best results from the previous generation
trainer.chromosomes = {}
trainer.states = {} -- states of automatas

function trainer:resetFields()
    trainer.fields = {}

    for i = 1, CONFIG.POPULATION do
        local field = fieldSpawner()
        field:load()
        table.insert(trainer.fields, field)
    end
end

function trainer:resetStates()
    trainer.states = {}

    for i = 1, CONFIG.POPULATION do
        table.insert(trainer.states, 1) -- 1 is the starting state for all automatas
    end
end

-- Reset the current generation round
function trainer:resetRound()
    trainer:resetFields()
    trainer:resetStates()
end

function trainer:load()
    trainer.chromosomes = chromosomeSpawner()

    trainer:resetRound()

    trainer.generation = 1
    trainer.move = 0
end

function trainer:render()
    trainer.fields[1]:render(0,0)
    trainer.fields[2]:render(1,0)
    trainer.fields[3]:render(0,1)
    trainer.fields[4]:render(1,1)

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

    if (#trainer.fitness > 0) then
        love.graphics.print("Best results so far:", size * 2 + 10, 40)
        love.graphics.print("Food eaten:        Adaptation:", size * 2 + 10, 65)

        for i = 1, math.min(#trainer.fitness, CONFIG.GRAPHICS.MAX_BEST_SPECIES) do
            love.graphics.print(string.format("%d                 %.2f %s",
                trainer.fitness[i].fitness,
                trainer.fitness[i].fitness / (CONFIG.MAX_FOOD + 1) * 100, "%"),
                size * 2 + 30, 65 + i * 15)

            -- debug
            if (trainer.fitness[i].fitness == CONFIG.MAX_FOOD and not done_activated) then
                print("Done!")
                print("Generation: ", trainer.generation)

                done_activated = true
            end
        end
    end
end

function trainer:keypressed(key)

end

function trainer:update()
    for i = 1, #trainer.chromosomes do
        local chromosome = trainer.chromosomes[i]
        local field = trainer.fields[i] -- the world in which chromosome acts
        local state = trainer.states[i]

        field.ant[chromosome[field.ant:isLookingAtFood()].actions[state]]()
        trainer.states[i] = chromosome[field.ant:isLookingAtFood()].transitions[state]
    end

    trainer.move = trainer.move + 1

    if (trainer.move > CONFIG.MAX_TURNS) then
        -- compute fitness function
        trainer.fitness = {}

        for i = 1, #trainer.fields do
            local world = trainer.fields[i]

            table.insert(trainer.fitness, {
                fitness = world.ant.food_eaten + (200 - world.ant.numLastFoodEaten) / 200,
                chromosome = i
            })
        end

        table.sort(trainer.fitness, function(a, b) return a.fitness > b.fitness end) -- greatest go first

        trainer:resetRound()
        trainer.generation = trainer.generation + 1
        trainer.move = 0

        local prev_chromosomes = trainer.chromosomes

        trainer.chromosomes = {}


        for i = 1, math.ceil(CONFIG.SURVIVAL_RATE * CONFIG.POPULATION) do
            table.insert(trainer.chromosomes, prev_chromosomes[trainer.fitness[i].chromosome])
        end

        print(chromosome:getDot(trainer.chromosomes[1]))

        -- generate new chromosomes from the best ones
        chromosomeSpawner(trainer.chromosomes)

        --print("SIZE: ", #trainer.chromosomes)
    end
end

return trainer