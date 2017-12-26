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
                if (math.random() < CONFIG.DEEP_BREED_CHANCE) then
                    --table.insert(children, mixDeep(s1, s2))
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

-- Export given chromosome to dot format
function chromosome:getDot(s)
    local str = "digraph G {\n"

    for i = 1, #s[true].transitions do
        str = str .. string.format('    %d -> %d [label = "T|%s"]\n', i, s[true].transitions[i],
            nameAction(s[true].actions[i]))
        str = str .. string.format('    %d -> %d [label = "F|%s"]\n', i, s[false].transitions[i],
            nameAction(s[false].actions[i]))
    end

    str = str .. "}"

    return str
end


return generate