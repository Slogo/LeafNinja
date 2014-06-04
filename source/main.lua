require("uimanager/uimanager")
require("hitboxer/hitboxes") --Library for handling animations and hitboxes

require("lang/lang") -- Language Strings
require("ui/uiConstants") --UI Constants

require("world/world")

local mainMenuManager = require("ui/mainMenuManager")

--Load function to kick things off
love.load = function()
  love.graphics.setColor(uiConstants.COLOR_DEFAULT)
  mainMenuManager.load()
end

--Update loop
love.update = function(dt)
  uimanager.update(dt)
  world:update(dt)
end

--Draw Loop
love.draw = function()
  uimanager.draw()
  world:draw()
end

--Handlers for mouse and keyboard events

love.mousepressed = function(x, y, button)
  uimanager.mousepressed(x, y, button)
end

love.mousereleased = function(x, y, button)
  uimanager.mousereleased(x, y, button)
end

love.keypressed = function(key)
  uimanager.keypressed(key)
end

love.textinput = function(text)
  uimanager.textinput(text)
end