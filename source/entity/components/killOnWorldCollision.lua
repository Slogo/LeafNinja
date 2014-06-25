local killOnWorldCollision = {
}

killOnWorldCollision.initialize = function(this, entity)
  entity:registerEvent("worldCollision", resolveCollision)
end

killOnWorldCollision.update = function(this, entity, dt)

end

killOnWorldCollision.resolveCollision = function(entity, params)
end

return killOnWorldCollision