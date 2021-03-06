--[[
        Represents the state of the game in which we are actively playing;
    player should control the paddle, with the ball actively bouncing between
    the bricks, walls, and the paddle. If the ball goes below the paddle, then
    the player should lose one point of health and be taken either to the Game
    Over screen if at 0 health or the Serve screen otherwise.
]]

PlayState = Class{__includes = BaseState}

function PlayState:enter(params)
    --initialize paddle
    self.paddle = params.paddle
    --initialize ball with skin #1
    self.ball = params.ball
    self.score = params.score
    self.highScores = params.highScores
    self.lives = params.lives
    self.level = params.level

    self.pause = false

    --ball's random starting velocity
    self.ball.dx = math.random(-200, 200)
    self.ball.dy = math.random(-50, -60)

    --give ball position in the center
    -- self.ball.x = VIRTUAL_WIDTH / 2 - 4
    -- self.ball.y = VIRTUAL_HEIGHT - 42

    --use the "static" createMap function to generate bricks
    self.bricks = params.bricks
end

function PlayState:update(dt)
    if self.pause then
        if love.keyboard.wasPressed('space') then
            self.pause = false
            gSounds['pause']:play()
        else
            return
        end
    elseif love.keyboard.wasPressed('space') then
        self.pause = true
        gSounds['pause']:play()
        return
    end

    --update position based on velocity
    self.paddle:update(dt)
    self.ball:update(dt)

    if self.ball:collides(self.paddle) then
        --raise ball above paddle in case it goes below it then reverse dy
        self.ball.dy = self.paddle.y - 8
        self.ball.dy = -self.ball.dy

        --tweak angle depending on where it hits the paddle

        --left side hit while moving left
        if self.ball.x < self.paddle.x + (self.paddle.width / 2) and self.paddle.dx < 0 then
            self.ball.dx = -50 + -(8 * (self.paddle.x + self.paddle.width / 2 - self.ball.x))
        
        --right side hit while moving right
        elseif self.ball.x > self.paddle.x + (self.paddle.width / 2) and self.paddle.dx > 0 then
            self.ball.dx = 50 + (8 * math.abs(self.paddle.x + self.paddle.width / 2 - self.ball.x))
        end
        
        gSounds['paddle_hit']:play()
    end

    --detects collision across all bricks with the ball
    for k, brick in pairs(self.bricks) do
        --only check collision if brick is inPlay
        if brick.inPlay and self.ball:collides(brick) then
            --add to score
            self.score = self.score + (brick.tier * 200 + brick.color * 25)
            --trigger brick's hit function
            brick:hit()

            --go to victory state if there are no more bricks left
            if self:checkVictory() then
                gSounds['victory']:play()

                gStateMachine:change('victory', {
                    level = self.level,
                    paddle = self.paddle,
                    lives = self.lives,
                    score = self.score,
                    ball = self.ball
                })
            end

             -- we check to see if the opposite side of our velocity is outside of the brick;
            -- if it is, we trigger a collision on that side. else we're within the X + width of
            -- the brick and should check to see if the top or bottom edge is outside of the brick,
            -- colliding on the top or bottom accordingly 
            --

            -- left edge; only check if we're moving right
            if self.ball.x + 2 < brick.x and self.ball.dx > 0 then

                --flip x velocity and reset position outside of brick
                self.ball.dx = -self.ball.dx
                self.ball.x = brick.x - 8

                --right edge; only check if we're moving left
            elseif self.ball.x + 6 > brick.x + brick.width and self.ball.dx < 0 then

                --flip x velocity and reset position outside of brick
                self.ball.dx = -self.ball.dx
                self.ball.x = brick.x + 32

                --top edge if no X collisions, always check
            elseif self.ball.y < brick.y then

                --flip y velocity and reset position outside of brick
                self.ball.dy = -self.ball.dy
                self.ball.y = brick.y - 8

                --bottom edge if no X collisions or top collisions, last possibility
            else

                --flip y velocity and reset position outside of brick
                self.ball.dy = -self.ball.dy
                self.ball.y = brick.y + 16
            end

            --slightly scale the y velocity to speed up the game
            self.ball.dy = self.ball.dy * 1.02

            --only allow colliding with one brick, for corners
            break
        end
    end

    -- if ball goes below bounds
    if self.ball.y >= VIRTUAL_HEIGHT then
        gSounds['hurt']:play()
        self.lives = self.lives - 1
        if self.lives <= 0 then
            gStateMachine:change('game_over', {
                score = self.score,
                highScores = self.highScores
            })
        else
            gStateMachine:change('serve', {
                paddle = self.paddle,
                score = self.score,
                highScores = self.highScores,
                lives = self.lives,
                bricks = self.bricks,
                level = self.level
            })
        end
    end

    --for rendering particle systems
    for k, brick in pairs(self.bricks) do
        brick:update(dt)
    end

    if love.keyboard.wasPressed('escape') then
        love.event.quit()
    end
end

function PlayState:render()
    --render bricks
    for k, brick in pairs(self.bricks) do
        brick:render()
    end

    --render all particle systems
    for k, brick in pairs(self.bricks) do
        brick:renderParticles()
    end

    self.paddle:render()
    self.ball:render()

    renderScore(self.score)
    renderLives(self.lives)

    --pause text, if paused
    if self.pause then
        love.graphics.setFont(gFonts['large'])
        love.graphics.printf("PAUSED", 0, VIRTUAL_HEIGHT / 2 - 16, VIRTUAL_WIDTH, 'center')
    end
end

function PlayState:checkVictory()
    for k, brick in pairs(self.bricks) do
        if brick.inPlay then
            return false
        end
    end

    return true
end