require("globals")

local trainer = require("trainer")

local tickRate = CONFIG.TICK_RATE
local time = 0

function love.load()
    math.randomseed(os.time())

    trainer:load()
end

function love.update(dt)
    time = time + dt

    if (time > tickRate) then
        trainer:update()
        time = 0
    end
end

function love.draw()
    trainer:render()
end


function love.keypressed(key)
    if key == "escape" or key == "q" then
        love.event.quit()
    end
    if key == "-" then
        tickRate = tickRate / 2
    elseif key == "=" or key == "+" then
        tickRate = tickRate * 2
    elseif key == "0" then
        tickRate = CONFIG.TICK_RATE
    end

    trainer:keypressed(key)
end