--[[
    Ball should bounce off the walls, paddle and bricks.
    It should also have fifferent skins. ]]

Ball = Class{}

function Ball:init(skin)
    -- positional and dimensional values
    self.width = 8
    self.height = 8

    -- keeps track of velocity in X and Y axis
    self.dy = 0
    self.dx = 0

    -- index of the color for the ball to reference in quads
    self.skin = skin
end

--[[
    collision detects if a target overlaps with the ball
    and returns true.
]]
function Ball:collides(target)
    --checks if the left edge of either is farther to the right
    --than the right edge of the other
    if self.x > target.x + target.width or target.x > self.x + self.width then
        return false
    end

    --checks if botton edge of either is higher than the top
    --edge of the other
    if self.y > target.y + target.height or target.y > self.y + self.height then
        return false
    end

    --if the above are false then there's a collision
    return true
end

--[[
    Places the ball in the middle of screen with no movement
]]

function Ball:reset()
    self.x = VIRTUAL_WIDTH / 2 - 2
    self.y = VIRTUAL_HEIGHT / 2 - 2
    self.dx = 0
    self.dy = 0
end

function Ball:update(dt)
    self.x = self.x + self.dx * dt
    self.y = self.y + self.dy * dt

    --handle bouncing off walls
    if self.x <= 0 then
        self.x = 0
        self.dx = -self.dx
        gSounds['wall_hit']:play()
    end

    if self.x >= VIRTUAL_WIDTH - 8 then
        self.x = VIRTUAL_WIDTH - 8
        self.dx = -self.dx
        gSounds['wall_hit']:play()
    end

    if self.y <= 0 then
        self.y = 0
        self.dy = -self.dy
        gSounds['wall_hit']:play()
    end
end

function Ball:render()
    --gTexture is the global texture for all blocks
    --gBallFrames is a table of quads mapping to each individual ball skin
    love.graphics.draw(gTextures['main'], gFrames['balls'][self.skin],
        self.x, self.y)
end