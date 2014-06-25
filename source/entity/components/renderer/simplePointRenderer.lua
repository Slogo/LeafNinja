local simplePointRenderer = {}

simplePointRenderer.initialize = function(this, entity)

end

simplePointRenderer.draw = function(this, entity)
  local x
  local y
  love.graphics.setPointSize(5)
  x, y = world.camera:worldToCamera( entity.position.x, entity.position.y)
  love.graphics.point(x, y)
  love.graphics.setPointSize(1)

  --Also draw first hitbox for now
  if #entity.hitWorld then
    love.graphics.rectangle("line", x + entity.hitWorld[1].x, y + entity.hitWorld[1].y,
        entity.hitWorld[1].width, entity.hitWorld[1].height)
  end
end

return simplePointRenderer