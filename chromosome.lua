local chromosome = {}
chromosome.possible_actions = {"move", "turnLeft", "turnRight"}

--[[
    Chromosome is:
    {
      transitions = {{true = Natural, false = Natural}}, -- automata transitions, indexes are states,
                                                            first state has index 1
      actions = {String} -- actions on transitions
    }
    interp. a chromosome representing an algorithm

    Examples:

    c1 = {
        transitions = {{true = 1, false = 1}},
        actions = {"move"}
    }


    c2 = {
        transitions = {{true = 2, false = 3}, {true = 3, false = 4}, {true = 4, false = 1}, {true = 1, false = 1}},
        actions = {"move", "turnLeft", "move", "turnRight"}
    }
--]]

function chromosome:validate(chromosome)
    assert(chromosome)
    assert(chromosome.transitions)
    assert(chromosome.actions)

    assert(#chromosome.transitions == #chromosome.actions)
end

local function generate_random_chromosome(size, previous_chromosomes)
    if not size then
        size = CONFIG.INITIAL_MAX_CHROMOSOME_SIZE
    end


    local cs = {}

    cs.transitions = {}
    cs.actions = {}

    for i = 1, size do
        table.insert(cs.actions, chromosome.possible_actions[math.random(#chromosome.possible_actions)])

        cs.transitions[i] = {}
        cs.transitions[i][true] = math.random(size)
        cs.transitions[i][false] = math.random(size)
    end

    chromosome:validate(cs)
    return cs
end

-- mix two species into new specie
local function mix(s1, s2)
    local cs = {}

    cs.transitions = {}
    cs.actions = {}

    for i = 1, math.min(#s1.actions, #s2.actions) do
        -- Action is taken either from the dad or from the mom
        table.insert(cs.actions, math.random() > 0.5 and s1.actions[i] or s2.actions[i])

        cs.transitions[i] = {}
        -- Transition is taken either from the dad or from the mom
        cs.transitions[i][true] = math.random() > 0.5 and s1.transitions[i][true] or s2.transitions[i][true]
        cs.transitions[i][false] = math.random() > 0.5 and s1.transitions[i][false] or s2.transitions[i][false]
    end

    chromosome:validate(cs)
    return cs
end

-- mix two species into new specie, deep version
local function mixDeep(s1, s2)
    local cs = {}

    cs.transitions = {}
    cs.actions = {}

    local size = math.min(#s1.actions, #s2.actions)
    for i = 1, size do
        -- Action is taken either from the dad or from the mom
        table.insert(cs.actions, math.random() > 0.5 and s1.actions[i] or s2.actions[i])

        cs.transitions[i] = {}
        -- Transition is taken either from the dad or from the mom
        cs.transitions[i][true] = math.random() > 0.5 and s1.transitions[math.random(size)][true] or s2.transitions[math.random(size)][true]
        cs.transitions[i][false] = math.random() > 0.5 and s1.transitions[math.random(size)][false] or s2.transitions[math.random(size)][false]
    end

    chromosome:validate(cs)
    return cs
end

local function mutateInitialState(s)
    local oldInitialState = s.transitions[1]
    local newStateIndex = math.random(#s.transitions)

    -- todo: think about this one
    s.transitions[1] = s.transitions[newStateIndex]
    s.transitions[newStateIndex] = oldInitialState
end

local function mutateActionOnTransition(s)
    s.actions[math.random(#s.actions)] = chromosome.possible_actions[math.random(#chromosome.possible_actions)]
end

local function mutateTransition(s)
    -- todo: think about this one as well
    s.transitions[math.random(#s.transitions)] = s.transitions[math.random(#s.transitions)]
end

local function mutateTransitionCondition(s)
    local transition = s.transitions[math.random(#s.transitions)]

    local t = transition[true]

    transition[true] = transition[false]
    transition[false] = t
end

local function mutate(s)
    local choice = math.random(4)
    if (choice == 1) then
        mutateInitialState(s)
    elseif (choice == 2) then
        mutateActionOnTransition(s)
    elseif (choice == 3) then
        mutateTransition(s)
    elseif (choice == 4) then
        mutateTransitionCondition(s)
    end
end

local function generate(species)
    if (species) then
        local children = {}
        local toAdd = CONFIG.POPULATION - #species
        assert(toAdd >= 0)

        while (toAdd > 0) do
            local s1 = species[math.random(#species)]
            local s2 = species[math.random(#species)]
            if (s1 ~= s2) then
                if (math.random() < CONFIG.DEEP_BREED_CHANCE) then
                    table.insert(children, mixDeep(s1, s2))
                else
                    table.insert(children, mix(s1, s2))
                end
                toAdd = toAdd - 1
            end
        end

        for _, child in ipairs(children) do
            if (math.random() < CONFIG.MUTATION_CHANCE) then
                mutate(child)
            end
        end

        for _, child in ipairs(children) do
            table.insert(species, child)
        end
    else
        local population = {}

        for i = 1, CONFIG.POPULATION do
            table.insert(population, generate_random_chromosome())
        end

        return population
    end
end


return generate