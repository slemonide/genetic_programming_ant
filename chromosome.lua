local chromosome = {}
chromosome.possible_actions = {"move", "turnLeft", "turnRight"}

--[[
    Chromosome is:
    {
      states = {Natural}, -- automata states, first element is the starting state
      transitions = {{true = Natural, false = Natural}}, -- automata transitions
      actions = {String} -- actions on transitions
    }
    interp. a chromosome representing an algorithm

    Examples:

    c1 = {
        states = {1},
        transitions = {{true = 1, false = 1}},
        actions = {"move"}
    }


    c2 = {
        states = {1, 2, 3, 4},
        transitions = {{true = 2, false = 3}, {true = 3, false = 4}, {true = 4, false = 1}, {true = 1, false = 1}},
        actions = {"move", "turnLeft", "move", "turnRight"}
    }
--]]

function chromosome:validate(chromosome)
    assert(chromosome)
    assert(chromosome.states)
    assert(chromosome.transitions)
    assert(chromosome.actions)

    assert(#chromosome.states == #chromosome.transitions)
    assert(#chromosome.transitions == #chromosome.actions)
end

local function generate_random_chromosome(size, previous_chromosomes)
    if not size then
        size = CONFIG.INITIAL_MAX_CHROMOSOME_SIZE
    end


    local cs = {}

    cs.states = {}
    cs.transitions = {}
    cs.actions = {}

    for i = 1, size do
        table.insert(cs.states, i)
        table.insert(cs.actions, chromosome.possible_actions[math.random(#chromosome.possible_actions)])

        cs.transitions[i] = {}
        cs.transitions[i][true] = math.random(size)
        cs.transitions[i][false] = math.random(size)
    end

    chromosome:validate(cs)
    return cs
end

-- mix two species into new specie
local function mix(s1, s2, visited, depth)
    --local out = {}
    --
    --out.action = math.random() > 0.5 and s1.action or s2.action
    --
    --if (not visited) then
    --    visited = {}
    --elseif (visited[s1] or visited[s2]) then
    --    out[true] = visited[math.random(#visited)]
    --    out[false] = visited[math.random(#visited)]
    --end
    --if (not depth) then
    --    depth = 2
    --elseif depth == 0 then
    --    out[true] = visited[math.random(#visited)]
    --    out[false] = visited[math.random(#visited)]
    --end
    --
    --
    --visited[s1] = true
    --visited[s2] = true
    --
    --out[true] = mix(s1[true], s2[true], visited, depth)
    --out[false] = mix(s1[false], s2[false], visited, depth)
    --
    ---- TODO: make recursive
    --return out
end

local function mutate()
    -- TODO: finish
end

local function generate(next_generation, species)
    if (next_generation and species) then
        --[[
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
        --]]
    else
        local population = {}

        for i = 1, CONFIG.POPULATION do
            table.insert(population, generate_random_chromosome())
        end

        return population
    end
end


return generate