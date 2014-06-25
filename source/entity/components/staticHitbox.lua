local staticHitbox = {
  x = 0,
  y = 0,
  width = 0,
  height =0
}

staticHitbox.initialize = function(this, entity)
  table.insert(entity.hitWorld, {x = this.x, y = this.y, width = this.width, height = this.height})
  logger.log("hitWorld has: " .. #entity.hitWorld, logger.DEBUG)
end

staticHitbox.update = function(this, entity, dt)

end

staticHitbox.draw = function(this, entity)
end

return staticHitbox