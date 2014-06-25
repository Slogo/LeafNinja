--[[
  Simple logger functionality
]]--
logger = {
  --Log levels
  ERROR = 0,
  WARNING = 1,
  INFO =  2,
  DEBUG = 3,

  --Current logging level
  level = 0,

  --[[
    Log a message if the current logging level is
    higher than the message
    message {String} the message to log
    level {int} the level of the message to log
  ]]--
  log = function(message, level)
    level = level or 0
    if level <= logger.level then
      print(message)
    end
  end
}