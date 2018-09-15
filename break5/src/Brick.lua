--[[
    Brick that ball can collide with. With different colors, and point
    values
]]

Brick = Class{}

function Brick:init(x, y)
    --color and score value
    self.tier = 0
    self.color = 1

    self.x = x
    self.y = y
    self.width = 32
    self.height = 16

    --checks if brick should be rendered
    self.inPlay = true
end

--[[
    Handles the brick getting hit
]]
function Brick:hit()
    gSounds['brick_hit']:play()

    self.inPlay = false
end

function Brick:render()
    if self.inPlay then
        love.graphics.draw(gTextures['main'],
             -- multiply color by 4 (-1) to get our color offset, then add tier to that
            -- to draw the correct tier and color brick onto the screen
            gFrames['bricks'][1 + ((self.color - 1) * 4) + self.tier],
            self.x, self.y)
            
        end
    end