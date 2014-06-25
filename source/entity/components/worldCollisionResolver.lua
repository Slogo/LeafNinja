local worldCollisionResolver = {
}

worldCollisionResolver.initialize = function(this, entity)
  entity:registerEvent("worldCollision", this.resolveCollision)
end

worldCollisionResolver.update = function(this, entity, dt)

end

worldCollisionResolver.resolveCollision = function(entity, collision)
  if collision.x then
    entity.position.x = entity.position.x + collision.x
    entity.velocity.x = 0
  end

  if collision.y then
    entity.position.y = entity.position.y + collision.y
    entity.velocity.y = 0
  end
end

return worldCollisionResolver