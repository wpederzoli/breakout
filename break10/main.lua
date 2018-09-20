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

    -- Quads we will generate for all of our textures; Quads allow us
    -- to show only part of a texture and not the entire thing
    gFrames = {
        ['paddles'] = GenerateQuadsPaddles(gTextures['main']),
        ['balls'] = GenerateQuadsBalls(gTextures['main']),
        ['bricks'] = GenerateQuadsBricks(gTextures['main']),
        ['hearts'] = GenerateQuads(gTextures['hearts'], 10, 9)
    }
    --initialize virtual resolution, which will be rendered
    -- within the actual window
    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
        vsync = true,
        fullscreen = false,
        resizable = true
    })

    --setup sound effects
    gSounds = {
        ['move_select'] = love.audio.newSource('sounds/move_select.wav', 'static'),
        ['pause'] = love.audio.newSource('sounds/pause.wav', 'static'),
        ['confirm'] = love.audio.newSource('sounds/confirm.wav', 'static'),
        ['wall_hit'] = love.audio.newSource('sounds/wall_hit.wav', 'static'),
        ['paddle_hit'] = love.audio.newSource('sounds/paddle_hit.wav', 'static'),
        ['brick-hit-1'] = love.audio.newSource('sounds/brick-hit-1.wav', 'static'),
        ['brick-hit-2'] = love.audio.newSource('sounds/brick-hit-2.wav', 'static'),
        ['hurt'] = love.audio.newSource('sounds/hurt.wav', 'static'),
        ['victory'] = love.audio.newSource('sounds/victory.wav', 'static')
    }

    --initialize stateMachine to handle game states
    gStateMachine = StateMachine {
        ['start'] = function() return StartState() end,
        ['high-scores'] = function() return HighScoresState() end,
        ['play'] = function() return PlayState() end,
        ['serve'] = function() return ServeState()  end,
        ['game_over'] = function() return GameOver() end,
        ['victory'] = function() return VictoryState() end
    }
    gStateMachine:change('start', {
        highScores = loadHighScores()
    })
    
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

--function to render score
function renderScore(score)
    love.graphics.setFont(gFonts['small'])
    love.graphics.print('Score:', VIRTUAL_WIDTH - 60, 5)
    love.graphics.printf(tostring(score), VIRTUAL_WIDTH - 50, 5, 40, 'right')
end

function loadHighScores()
    love.filesystem.setIdentity('breakout')

    --if the file doesn't exist, initialize it with some default socres
    if not love.filesystem.exists('breakout.lst') then
        local scores = ''
        for i = 10, 1, -1 do
            scores = scores .. 'CTO\n'
            scores = scores .. tostring(i * 1000) .. '\n'
        end

        love.filesystem.write('breakout.lst', scores)
    end

    --flag for whether we're reading a name or not
    local name = true
    local currentName = nil
    local counter = 1

    --initialize scores table with at least 10 blank entries
    local scores = {}

    for i = 1, 10 do
        --blank table; each will hold a name and a score
        scores[i] = {
            name = nil,
            score = nil
        }
    end

    --iterate over each line in the file, filling in names and scores
    for line in love.filesystem.lines('breakout.lst') do
        if name then
            scores[counter].name = string.sub(line, 1, 3)
        else
            scores[counter].score = tonumber(line)
            counter = counter + 1
        end

        --flip the name flag
        name = not name
    end

    return scores
end

--[[
    Renders hearts based on how many lives the player has. It renders
    full hearts representing the lives remaining and empty hearts representing
    the lost lives.
]]
function renderLives(lives)
    local livesX = VIRTUAL_WIDTH - 100
    
    -- render lives left
    for i = 1, lives do
        love.graphics.draw(gTextures['hearts'], gFrames['hearts'][1], livesX, 4)
        livesX = livesX + 11
    end

    --render missing lives
    for i = 1, 3 - lives do
        love.graphics.draw(gTextures['hearts'], gFrames['hearts'][2], livesX, 4)
        livesX = livesX + 11
    end
end

--function to render FPS
function displayFPS()
    love.graphics.setFont(gFonts['small'])
    love.graphics.setColor(0, 255, 0, 255)
    love.graphics.print('FPS: ' .. tostring(love.timer.getFPS()), 5, 5)
end
