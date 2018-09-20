--[[
    Brick that ball can collide with. With different colors, and point
    values
]]

Brick = Class{}

--some of the colors in our palette (to be used with particle systems)
paletteColors = {
    --blue
    [1] = {
        ['r'] = 0,
        ['g'] = 0,
        ['b'] = 255
    },
    --green
    [2] = {
        ['r'] = 0,
        ['g'] = 255,
        ['b'] = 0
    },
    --red
    [3] = {
        ['r'] = 255,
        ['g'] = 0,
        ['b'] = 00
    },
    --purple
    [4] = {
        ['r'] = 100,
        ['g'] = 0,
        ['b'] = 255
    },
    [5] = {
        ['r'] = 251,
        ['g'] = 242,
        ['b'] = 54
    }
}

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

    --particle system belonging to the brick, emmited on hit
    self.psystem = love.graphics.newParticleSystem(gTextures['particle'], 64)

    --various behaviour-determining functions for the particle system
    -- https://love2d.org/wiki/ParticleSystem


    --lasts between 0.5-1 seconds seconds
    self.psystem:setParticleLifetime(0.5, 1)

    -- give it an acceleration of anywhere between X1,Y1 and X2,Y2 (0, 0) and (80, 80) here
    -- gives generally downward end
    self.psystem:setLinearAcceleration(-15, 0, 15, 80)

    --spread of particles; normal looks more natural than uniform which is clumpy; numbers
    --are amount of standard deviation away in X and Y axis
    self.psystem:setEmissionArea('normal', 10, 10)
end
--[[
    Handles the brick getting hit
]]
function Brick:hit()
    --set the particle system to interpolate between two colors; in this case, we give
    --it our self.color but with varying alpha; brighter for higher tiers, fading to 0
    --over the particle's lifetime (the second color)
    self.psystem:setColors(
        paletteColors[self.color].r,
        paletteColors[self.color].g,
        paletteColors[self.color].b,
        55 * (self.tier + 1),
        paletteColors[self.color].r,
        paletteColors[self.color].g,
        paletteColors[self.color].b,
        0
    )
    self.psystem:emit(64)

    gSounds['brick-hit-2']:stop()
    gSounds['brick-hit-2']:play()

    --if we're at a higher tier than the base, we need to go down a tier
    --if we're already at the lowest color, else just go down a color
    if self.tier > 0 then
        if self.color == 1 then
            self.tier = self.tier - 1
            self.color = 5
        else
            self.color = self.color - 1
        end
    else
        --if we're in the first tier and the base color, remove brick
        if self.color == 1 then
            self.inPlay = false
        else
            self.color = self.color - 1
        end
    end

        --play a second layer sound if the brick is destroyed
    if not self.inPlay then
        gSounds['brick-hit-1']:stop()
        gSounds['brick-hit-1']:play()
    end
end

function Brick:update(dt)
    self.psystem:update(dt)
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

--[[
    Need a separate render function for our particles so it can be called after all bricks are drawn;
    otherwise, some bricks would render over other bricks' particle systems.
]]
function Brick:renderParticles()
    love.graphics.draw(self.psystem, self.x + 16, self.y + 8)
end