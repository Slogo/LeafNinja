local entity = {
  id: 0,
  position: {x: 0, y: 0},
  velocity: {x: 0, y: 0},
  behavior: [],
  physics: [],
  renderer: [],
  events: [],
}

entity.addComponent = function(this, type, component)
  if this.type then
    table.insert(this.type, component)
    component:initialize(this)
  end
end

entity.removeComponent = function(this, type, component)

end

entity.registerEvent = function(this, event, callback)
  if not events[event] then
    this.events[event] = []
  end
  table.insert(this.events[event], callback)
end

entity.removeEvent = function(this, event, callback)
  if this.events[event] then
    --Remove event
  end
end

entity.triggerEvent = function(this, event)
  if this.events[event] then
    for index, callback in pairs(this.events[event]) do
      callback(callback, this)
    end
  end
end

entity.initialize = function(this)
end

entity.update = function(this, dt)
  for index, component in pairs(behavior) do
    component:update(this, dt)
  end

  for index, component in pairs(physics) do
    component:preUpdate(this, dt)
  end

  --Move the unit based on velocity here

  for index, component in pairs(physics) do
    component:postUpdate(this, dt)
  end
end

entity.draw = function(this)
  for index, component in pairs(behavior) do
    if component.draw then 
      component:draw(this, dt)
    end
  end
  for index, component in pairs(renderer) do
    component:draw(this, dt)
  end
end