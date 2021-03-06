--import push library
push = require 'lib/push'
--import class library
Class = require 'lib/class'

--import global constants
require 'src/constants'

-- import paddle
require 'src/Paddle'

-- state machine to allow us to transition game states
require 'src/StateMachine'

-- utility functions, mainly for splitting our sprite sheet into various Quads
-- of differing sizes for paddles, balls, bricks, etc.
require 'src/Util'

-- each of the individual states our game can be in at once; each state has
-- its own update and render methods that can be called by our state machine
-- each frame, to avoid bulky code in main.lua
require 'src/states/BaseState'
require 'src/states/PlayState'
require 'src/states/StartState'