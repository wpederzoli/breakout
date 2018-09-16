--[[
    Ball starts above the paddle and waits for the player
    to press enter to start moving. Instructions on screen should
    be rendered.
]]

ServeState = Class{__includes = BaseState}


function ServeState:enter(params)
    --get state from params
    self.paddle = params.paddle
    self.bricks = params.bricks
    self.score = params.score
    self.lives = params.lives
    self.level = params.level
    
    --init new ball (random color)
    self.ball = Ball()
    self.ball.skin = math.random(7)
end

function ServeState:update(dt)
    self.paddle:update(dt)
    self.ball.x = self.paddle.x + (self.paddle.width / 2) - 4
    self.ball.y = self.paddle.y - 8

    if love.keyboard.wasPressed('enter') or love.keyboard.wasPressed('return') then
        gStateMachine:change('play', {
            paddle = self.paddle,
            bricks = self.bricks,
            ball = self.ball,
            score = self.score,
            lives = self.lives,
            level = self.level
        })
    end

    if love.keyboard.wasPressed('escape') then
        love.event.quit()
    end
end

function ServeState:render()
    self.paddle:render()
    self.ball:render()

    renderScore(self.score)
    renderLives(self.lives)

    for k, brick in pairs(self.bricks) do
        brick:render()
    end

    love.graphics.setFont(gFonts['medium'])
    love.graphics.printf('Press Enter to serve!', 0, VIRTUAL_HEIGHT / 2, 
        VIRTUAL_WIDTH, 'center')
end