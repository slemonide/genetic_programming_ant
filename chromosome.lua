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

local function load_actions()
    chromosome.possible_actions = {"move", "turnLeft", "turnRight"}
end

-- mix two species into new specie
local function mix(s1, s2, depth)
    local out = {}
    out.action = math.random() > 0.5 and s1.action or s2.action
    out[true] = math.random() > 0.5 and s1[true] or s2[true]
    out[false] = math.random() > 0.5 and s1[false] or s2[false]

    -- TODO: make recursive
    return out
end

local function mutate()
    -- TODO: finish
end

local function generate(species)

    -- TODO: test everything, I don't trust this code anymore

    if (species) then
        local children = {}
        local toAdd = CONFIG.POPULATION - CONFIG.SURVIVAL_RATE
        assert(toAdd >= 0)

        while (toAdd > 0) do
            local s1 = species[math.random(#species)]
            local s2 = species[math.random(#species)]
            if (s1 ~= s2) then
                table.insert(children, mix(s1, s2))
                toAdd = toAdd - 1
            end
        end

        for _, child in ipairs(children) do
            table.insert(species, child)
        end

        for _, mutant in ipairs(species) do
            mutate(mutant)
        end
    else
        local population = {}

        for i = 1, CONFIG.POPULATION do
            load_actions()
            table.insert(population, generate_random_chromosome())
        end

        return population
    end
end


return generate