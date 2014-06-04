local gravityComponent = {
  enabled = true
  halfGravity = 0.0 --Use a half gravity measure to apply
}

gravityComponent.initialize = function(this, entity)

end

gravityComponent.preUpdate = function(this, entity, dt)
  this:halfUpdate(entity, dt)
end

gravityComponent.postUpdate = function(this, entity, dt)
  this:halfUpdate(entity, dt)
end

gravityComponent.halfUpdate = function(this, entity, dt)
  entity.velocity.y = entity.velocity.y + this.halfGravity * dt/2
end