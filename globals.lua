DEBUG = true

CONFIG = {
    FIELD_SIZE = 32,
    TICK_RATE = 0,
    POPULATION = 1000, -- Population of chromosomes each generation. Should be at least 4 (because of graphics)
    SURVIVAL_RATE = 100, -- How many species will continue to the next generation (only the best ones are chosen)
    INITIAL_MAX_CHROMOSOME_SIZE = 10,
    MAX_TURNS = 200, -- 200
    MAX_FOOD = 89,

    GRAPHICS = {
        TILE_SIZE = 8,
        FOOD_COLOR = { 50, 255, 100 },
        ANT_COLOR = { 255, 50, 100 },
        SPLITTER_COLOR = {255, 255, 255},
        TEXT_COLOR = {255, 255, 255},
        MAX_BEST_SPECIES = 10
    }
}