--Require all dependencies
require 'src/Dependencies'

function love.load()
    --avoids bluriness  
    love.graphics.setDefaultFilter('nearest', 'nearest')

    --set seed for random values
    math.randomseed(os.time())

    --application title
    love.window.setTitle('Breakout')

    --setup fonts
    gFonts = {
        ['small'] = love.graphics.newFont('fonts/font.ttf', 8),
        ['medium'] = love.graphics.newFont('fonts/font.ttf', 16),
        ['large'] = love.graphics.newFont('fonts/font.ttf', 32)
    }
    love.graphics.setFont(gFonts['small'])

    --load graphics
    gTextures = {
        ['background'] = love.graphics.newImage('graphics/background.png'),
        ['main'] = love.graphics.newImage('graphics/breakout.png'),
        ['arrows'] = love.graphics.newImage('graphics/arrows.png'),
        ['hearts'] = love.graphics.newImage('graphics/hearts.png'),
        ['particle'] = love.graphics.newImage('graphics/particle.png')
    }

    --initialize virtual resolution, which will be rendered
    -- within the actual window
    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
        vsync = true,
        fullscreen = false,
        resizable = true
    })

    --setup sound effects
    gSounds = {}

    --initialize stateMachine to handle game states
    gStateMachine = StateMachine {
        ['start'] = function() return StartState() end
    }
    gStateMachine:change('start')
    
    --keeps track of keys pressed this frame
    love.keyboard.keysPressed = {}
end

--resize window handler
function love.resize(w, h)
    push:resize(w, h)
end

function love.update(dt)
    --pass dt to the state being currently used
    gStateMachine:update(dt)

    -- reset keys pressed
    love.keyboard.keysPressed = {}
end

-- adds keystrokes this frame to keysPressed obj
function love.keypressed(key)
    love.keyboard.keysPressed[key] = true
end

--function to test individual keystrokes
function love.keyboard.wasPressed(key)
    if love.keyboard.keysPressed[key] then
        return true
    else
        return false
    end
end

function love.draw()
    --draw in virtual resolution
    push:apply('start')

    --background drawn regardless of state, scaled
    --to fit virtual resolution
    local backgroundWidth = gTextures['background']:getWidth()
    local backgroundHeight = gTextures['background']:getHeight()

    love.graphics.draw(gTextures['background'],
    --draw at coordinates 0, 0
    0, 0,
    --no rotation
    0,
    --scale factors on X and Y axis so it fills the screen
    VIRTUAL_WIDTH / (backgroundWidth - 1), VIRTUAL_HEIGHT / (backgroundHeight - 1))

    --use state machine to defer rendering to the current state
    gStateMachine:render()

    --display FPS for debugging; simply comment out to remove
    displayFPS()

    push:apply('end')
end

--function to render FPS
function displayFPS()
    love.graphics.setFont(gFonts['small'])
    love.graphics.setColor(0, 255, 0, 255)
    love.graphics.print('FPS: ' .. tostring(love.timer.getFPS()), 5, 5)
end
