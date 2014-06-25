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
  world.camera.mode = world.camera.targetFreely
  world.camera:setFocalEntity(entity)
end

playerController.update = function(this, entity, dt)

  --DEBUG TEST MOVEMENT
  if love.keyboard.isDown("a") then
    entity.velocity.x = -40
  elseif love.keyboard.isDown("d") then
    entity.velocity.x = 40
  else
    entity.velocity.x = 0
  end
end

return playerController