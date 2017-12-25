local chromosome = {}

local function generate_random_chromosome(size, previous_chromosomes)
    local out = {}

    if not size then
        size = CONFIG.INITIAL_MAX_CHROMOSOME_SIZE
    end
    if not previous_chromosomes then
        previous_chromosomes = {}
    end
    table.insert(previous_chromosomes, out)

    -- food
    out[true] = (size > 0 and math.random() > 0.2) and generate_random_chromosome(size - 1, previous_chromosomes)
        or previous_chromosomes[math.random(#previous_chromosomes)]

    -- no food
    out[false] = (size > 0 and math.random() > 0.2) and generate_random_chromosome(size - 1, previous_chromosomes)
        or previous_chromosomes[math.random(#previous_chromosomes)]

    assert(out[true])
    assert(out[false])

    out.action = chromosome.possible_actions[math.random(#chromosome.possible_actions)]

    return out
end

function load_actions(ant)
    chromosome.possible_actions = {
        function() ant:move() end,
        function() ant:turnLeft() end,
        function() ant:turnRight() end
    }
end

local function generate(fields, bestSpecies)
    assert(CONFIG.POPULATION == #fields)

    if (bestSpecies) then
        local children = {}
        local toAdd = CONFIG.POPULATION - CONFIG.SURVIVAL_RATE
        assert(toAdd >= 0)

        -- TODO: finish

        return bestSpecies
    else
        local population = {}

        for i = 1, CONFIG.POPULATION do
            local field = fields[i]
            load_actions(field.ant)
            table.insert(population, {
                chromosome = generate_random_chromosome(),
                field = field
            } )
        end

        return population
    end
end


return generate