local lateralComponent = {
  enabled = true
  lateralThreshold = 0.0
  halflateral = 0.0 --Use a half gravity measure to apply
}

lateralComponent.initialize = function(this, entity)

end

lateralComponent.preUpdate = function(this, entity, dt)
  this:halfUpdate(entity, dt)
end

lateralComponent.postUpdate = function(this, entity, dt)
  this:halfUpdate(entity, dt)
end

lateralComponent.halfUpdate = function(this, entity, dt)
  
end