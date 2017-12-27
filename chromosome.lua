chromosome = {}
chromosome.possible_actions = {"move", "turnLeft", "turnRight"}

--[[
    Chromosome is:
    {
      true = { -- this path is chosen if there is food in front of the ant
        transitions = {Natural}, -- automata transitions, indexes are states,
                                                              first state has index 1
        actions = {String} -- actions on transitions
        },
      false = {
        transitions = {Natural},
        actions = {String}
        }
    }
    interp. a chromosome representing an algorithm

    Examples:

    c1 = {}
    c1[true] = {
        transitions = {1},
        actions = {"move"}
    }
    c1[false] = {
        transitions = {1},
        actions = {"move"}
    }


    c2 = {}
    c2[true] = {
        transitions = {2, 3, 4, 1},
        actions = {"move", "turnLeft", "move", "turnRight"}
    }
    c2[true] = {
        transitions = {2, 3, 4, 1},
        actions = {"move", "turnLeft", "move", "turnRight"}
    }
--]]

function chromosome:validate(chromosome)
    assert(chromosome)
    assert(chromosome[true])
    assert(chromosome[false])
    assert(chromosome[true].transitions)
    assert(chromosome[true].actions)
    assert(chromosome[false].transitions)
    assert(chromosome[false].actions)

    assert(#chromosome[true].transitions == #chromosome[true].actions)
    assert(#chromosome[false].transitions == #chromosome[false].actions)
    assert(#chromosome[true].transitions == #chromosome[false].actions)
end

local function generate_random_chromosome(size)
    if not size then
        size = CONFIG.INITIAL_MAX_CHROMOSOME_SIZE
    end


    local cs = {}

    for _, key in ipairs({true, false}) do
        cs[key] = {}
        local slice = cs[key]

        slice.transitions = {}
        slice.actions = {}

        for i = 1, size do
            table.insert(slice.actions, chromosome.possible_actions[math.random(#chromosome.possible_actions)])
            table.insert(slice.transitions, math.random(size))
        end
    end

    chromosome:validate(cs)
    return cs
end

-- mix two species into new specie
local function mix(s1, s2)
    local cs = {}

    for _, key in ipairs({true, false}) do
        cs[key] = {}
        local slice = cs[key]

        slice.transitions = {}
        slice.actions = {}

        for i = 1, CONFIG.INITIAL_MAX_CHROMOSOME_SIZE do
            table.insert(slice.actions, math.random() > 0.5 and
                s1[key].actions[i] or s2[key].actions[i])
            table.insert(slice.transitions, math.random() > 0.5 and
                s1[key].transitions[i] or s2[key].transitions[i])
        end
    end

    chromosome:validate(cs)
    return cs
end

local function mutateInitialState(s)
    local shift = math.random(CONFIG.INITIAL_MAX_CHROMOSOME_SIZE)

    for _, key in ipairs({true, false}) do
        local newStates = {}
        for i = 1, CONFIG.INITIAL_MAX_CHROMOSOME_SIZE do
            newStates[i] = s[key][(i + shift) % CONFIG.INITIAL_MAX_CHROMOSOME_SIZE + 1]
        end
    end
end

local function mutateActionOnTransition(s)
    local input = math.random() > 0.5

    s[input].actions[math.random(#s[input].actions)] = chromosome.possible_actions[math.random(#chromosome.possible_actions)]
end

local function mutateTransition(s)
    local input = math.random() > 0.5
    local newDirection = math.random() > 0.5

    s[input].transitions[math.random(#s[input].transitions)] = s[newDirection].transitions[math.random(#s[newDirection].transitions)]
end

local function mutateTransitionCondition(s)
    local index = math.random(#s[true].transitions)

    local trans = s[true].transitions[index]
    s[true].transitions[index] = s[false].transitions[index]
    s[false].transitions[index] = trans
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
            local s2 = math.random() < CONFIG.OUTSIDER_BREED_CHANCE
                and generate_random_chromosome()
                or species[math.random(#species)]
            if (s1 ~= s2) then
                table.insert(children, mix(s1, s2))
                toAdd = toAdd - 1
            end
        end

        for _, s in ipairs(children) do
            if (math.random() < CONFIG.MUTATION_CHANCE) then
                mutate(s)
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

---------------------------------------
-- export functions
---------------------------------------

-- Return a short alias for the given action
local function nameAction(action)
    if (action == "move") then
        return "M"
    elseif (action == "turnLeft") then
        return "L"
    elseif (action == "turnRight") then
        return "R"
    end
end

-- Convert an action to number
local function actionToNumber(action)
    if (action == "move") then
        return 100
    elseif (action == "turnLeft") then
        return 0
    elseif (action == "turnRight") then
        return 1000
    end
end

-- Export given chromosome to dot format
function chromosome:getDot(s)
    local str = "digraph G {\n"

    for i = 1, #s[true].transitions do
        str = str .. string.format('    %d -> %d [label = "T/%s"]\n', i, s[true].transitions[i],
            nameAction(s[true].actions[i]))
        str = str .. string.format('    %d -> %d [label = "F/%s"]\n', i, s[false].transitions[i],
            nameAction(s[false].actions[i]))
    end

    str = str .. "}"

    return str
end

-- Export given chromosome to gene string format
function chromosome:getGene(s)
    local str = ""
    for i = 1, #s[true].transitions do
        str = str .. s[true].transitions[i] .. nameAction(s[true].actions[i])
        str = str .. s[false].transitions[i] .. nameAction(s[false].actions[i]) .. " "
    end

    return str
end

-- Export given chromosome to a 2d vector
function chromosome:get2dVector(s)
    local big_vector = {}

    for i = 1, #s[true].transitions do
        table.insert(big_vector, s[true].transitions[i])
        table.insert(big_vector, actionToNumber(s[true].actions[i]))
        table.insert(big_vector, s[false].transitions[i])
        table.insert(big_vector, actionToNumber(s[false].actions[i]))
    end

    if not (chromosome.vector_weights) then
        chromosome.vector_weights = {}
        for key = 1, 2 do
            chromosome.vector_weights[key] = {}
            for i = 1, #big_vector do
                table.insert(chromosome.vector_weights[key], math.random())
            end
        end
    end

    local small_vector = {}

    for key = 1, 2 do
        for i = 1, #big_vector do
            small_vector[key] = small_vector[key] or 0 + big_vector[i] * chromosome.vector_weights[key][i]
        end
    end

    -- normalize it
    local mag = small_vector[1] + small_vector[2]
    small_vector[1] = small_vector[1] / mag
    small_vector[2] = small_vector[2] / mag

    return small_vector
end


return generate