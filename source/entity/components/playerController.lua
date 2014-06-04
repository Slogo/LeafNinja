local inputManager = nil

local ACTION_NAMES = {
  left = "l",
  right = "r",
  down = "d",
  up = "u",
  jump = "j",
  attack = "a",
  special = "b"
}

local playerController = {
  enabled = true
}

playerController.initialize = function(this, entity)
  
end

playerController.update = function(this, entity, dt)
  if(inputManager.getAction()
end