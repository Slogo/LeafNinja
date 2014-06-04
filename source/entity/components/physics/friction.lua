local frictionComponent = {
  enabled = true
  frictionThreshold = 0.0
  halfFriction = 0.0 --Use a half gravity measure to apply
}

frictionComponent.initialize = function(this, entity)

end

frictionComponent.preUpdate = function(this, entity, dt)
  this:halfUpdate(entity, dt)
end

frictionComponent.postUpdate = function(this, entity, dt)
  this:halfUpdate(entity, dt)
end

frictionComponent.halfUpdate = function(this, entity, dt)
  if entity.isStanding() then
    if entity.velocity.x > entity.frictionThreshold then
      entity.velocity.x = Math.max(entity.velocity.x + this.halfFriction * dt/2,
                                   entity.frictionThreshold)
    elseif entity.velocity.x < -1 * entity.frictionThreshold then
      entity.velocity.x = Math.min(entity.velocity.x + -1 * this.halfFriction * dt/2,
                                   -1 * entity.frictionThreshold)
    end
  end
end