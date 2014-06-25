--[[
--	The main menu manager is responsible for handling the main menu
--	interactions and demo mode
--]]
local mainMenuManager = {
  view = nil
}

--[[
--	load the main menu manager
--]]
mainMenuManager.load = function()
	mainMenuManager.view = require("ui/views/mainMenu")
	mainMenuManager.view:load()
	if not mainMenuManager.hasSavedGame() then
		mainMenuManager.view.continue:disable()
	end
end

--[[
--	Whether or not there is a saved game to continue from
--]]
mainMenuManager.hasSavedGame = function()
	return false
end

-- Handles the New Game option
love.handlers.selectNewGame = function()
  mainMenuManager.view:hide()
  world:initialize()
  world:loadLevel("test")
end

-- Handles the Continue option
love.handlers.loadSavedGame = function()
  mainMenuManager.view:hide()
end

return mainMenuManager