--[[
--  The main menu view responsible for handling the main menu UI elements
--]]
local mainMenu = uimanager.newView(uiConstants.LAYER_MAIN_MENU, uiConstants.LAYER_MAIN_MENU_PRIORITY)
mainMenu.continue = nil

--[[
--  Initialize the main menu controls
--]]
mainMenu.initialize = function(this)
  local font = love.graphics.getFont()
  local controls = {}
  local options = {
    activated = true,
    draw = this.drawMenuOption,
    height = uiConstants.MENU_OPTION_LINE_HEIGHT,
  }

  --Continue
  options.title = lang.continue
  options.callback = mainMenu.doNothing
  options.width = font:getWidth(options.title)
  options.x = love.window.getWidth() * uiConstants.MENU_OPTION_START_X_PCT - options.width / 2
  options.y = love.window.getHeight() * uiConstants.MENU_OPTION_START_Y_PCT - 2 * uiConstants.MENU_OPTION_LINE_HEIGHT
  mainMenu.continue = uimanager.control.newButton(options)
  table.insert(controls, mainMenu.continue)

  --New Game
  options.title = lang.newGame
  options.callback = mainMenu.newGame
  options.width = font:getWidth(options.title)
  options.x = love.window.getWidth() * uiConstants.MENU_OPTION_START_X_PCT - options.width / 2
  options.y = options.y + uiConstants.MENU_OPTION_LINE_HEIGHT
  mainMenu.newGame = uimanager.control.newButton(options)
  table.insert(controls, mainMenu.newGame)

  --Options
  options.title = lang.options
  options.callback = mainMenu.doNothing
  options.width = font:getWidth(options.title)
  options.x = love.window.getWidth() * uiConstants.MENU_OPTION_START_X_PCT - options.width / 2
  options.y = options.y + uiConstants.MENU_OPTION_LINE_HEIGHT
  table.insert(controls, uimanager.control.newButton(options))

  --Quit
  options.title = lang.quit
  options.callback = love.event.quit
  options.width = font:getWidth(options.title)
  options.x = love.window.getWidth() * uiConstants.MENU_OPTION_START_X_PCT - options.width / 2
  options.y = options.y + uiConstants.MENU_OPTION_LINE_HEIGHT
  table.insert(controls, uimanager.control.newButton(options))

  uimanager.layer.addControls(this.layerName, controls)
end

mainMenu.newGame = function()
  love.event.push("selectNewGame")
end

--Temporary callback function
mainMenu.doNothing = function()

end

--[[
--  Draw a menu option
--]]
mainMenu.drawMenuOption = function(input)
  
  if input.focus then
    local currentColor = {}
    currentColor[1], currentColor[2], currentColor[3], currentColor[4] = love.graphics.getColor()
    love.graphics.setColor(uiConstants.COLOR_MENU_SELECTED)
    love.graphics.print(input.title, input.x, input.y)
    love.graphics.setColor(currentColor)
  elseif input.hover then
    --local currentColor = {}
    --currentColor[1], currentColor[2], currentColor[3], currentColor[4] = love.graphics.getColor()
    --love.graphics.setColor(uiConstants.COLOR_MENU_SELECTED)
    love.graphics.print(input.title, input.x, input.y)
    --love.graphics.setColor(currentColor)
  else
    love.graphics.print(input.title, input.x, input.y)
  end  
end

return mainMenu

