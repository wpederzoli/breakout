--[[
    Represents the state the game is in when we've just started; should
    simply display "Breakout" in large text, as well as a message to press
    Enter to begin.
]]

-- inherits all empty methods from BaseState
StartState = Class{__includes = BaseState}

--whether "Start" or "High Scores" is highlighted
local highlighted = 1

function StartState:update(dt)
    --toggle highlighted option
    if love.keyboard.wasPressed('up') or love.keyboard.wasPressed('down') then
        highlighted = highlighted == 1 and 2 or 1
        gSounds['move_select']:play()
    end

    --confirm whichever option selected
    if love.keyboard.wasPressed('enter') or love.keyboard.wasPressed('return') then
        gSounds['confirm']:play()

        if highlighted == 1 then
            gStateMachine:change('serve', {
                paddle = Paddle(1),
                bricks = LevelMaker.createMap()
            })
        end
    end

    -- quit game when if esc is pressed
    if love.keyboard.wasPressed('escape') then
        love.event.quit()
    end
end

function StartState:render()
    --title
    love.graphics.setFont(gFonts['large'])
    love.graphics.printf("BREAKOUT", 0, VIRTUAL_HEIGHT / 3,
        VIRTUAL_WIDTH, 'center')

    --instructions
    love.graphics.setFont(gFonts['medium'])

    --if 1 highlighted render that option blue
    if highlighted == 1 then
        love.graphics.setColor(0, 50, 255, 255)
    end
    love.graphics.printf("START", 0, VIRTUAL_HEIGHT / 2 + 70,
        VIRTUAL_WIDTH, 'center')

    -- reset the color
    love.graphics.setColor(255, 255, 255, 255)

    --if 2 highlighted renter it blue
    if highlighted == 2 then
        love.graphics.setColor(0, 50, 255, 255)
    end
    love.graphics.printf("HIGH SCORES", 0, VIRTUAL_HEIGHT / 2 + 90, 
        VIRTUAL_WIDTH, 'center')

    love.graphics.setColor(255, 255, 255, 255)
end