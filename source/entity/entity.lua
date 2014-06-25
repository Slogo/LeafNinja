--[[
  Entity is the basic shell for all game objects.
]]--
local entity = {
  id = 0,

   --The following will be set to {x= -, y = -} when a new entity is created
  position = nil,
  oldPosition = nil,
  velocity = nil,

  --List of components attached to the entity
  behavior = {}, --Behavior components
  physics = {}, --Components responsible for physics & locomotion
  renderer = {},
  events = {},

  hitWorld = {},
  hitEntity = {}
}

--Adds a new component to the entity
entity.addComponent = function(this, type, component)
  if this[type] then
    table.insert(this[type], component)
    component:initialize(this)
  end
end

--Removes a component from the entity
entity.removeComponent = function(this, type, component)

end

--Registers an event handler for the given event
--Callback will be triggered when the event is
entity.registerEvent = function(this, event, callback)
  print("Handle event registration: " .. event)
  if not this.events[event] then
    this.events[event] = {callback}
  else
    table.insert(this.events[event], callback)
  end
end

entity.removeEvent = function(this, event, callback)
  if this.events[event] then
    --Remove event
  end
end

--Trigger entity event handling
entity.triggerEvent = function(this, event, params)
  if this.events[event] then
    for index, callback in pairs(this.events[event]) do
      callback(this, params)
    end
  --If there are no registered events try
  --the entity for a handler
  elseif this[event] then
    this[event](this, params)
  end
end

--Cap the entities velocity based on its max speed
entity.capVelocity = function(this)
  this.velocity.x = math.min(this.velocity.x, 100)
  this.velocity.y = math.min(this.velocity.y, 100)
end

--Destroy the entity (remove it from the world)
entity.destroy = function(this)
  world:removeEntity(this.id)
end

--Entity initialization
entity.initialize = function(this)
end

--Update cycle for the entity
entity.update = function(this, dt)
  --Track the old position for resolving collisions
  --properly
  this.oldPosition.x = this.position.x
  this.oldPosition.y = this.position.y

  --Update the components
  for index, component in pairs(this.behavior) do
    component:update(this, dt)
  end

  --Each physics component gets two updates, one before and
  --one after moving
  for index, component in pairs(this.physics) do
    component:preUpdate(this, dt/2)
  end

  this:capVelocity()

  --Move the unit based on velocity here
  this.position.x = this.position.x + this.velocity.x * dt
  this.position.y = this.position.y + this.velocity.y * dt

  --2nd Physics update after the entity has been moved
  for index, component in pairs(this.physics) do
    component:postUpdate(this, dt/2)
  end
end

--Draws the entity
entity.draw = function(this)
  --Draw any behavior components (THIS IS FOR DEBUG)
  for index, component in ipairs(this.behavior) do
    if component.draw then
      component:draw(this, dt)
    end
  end

  --Draw each renderer
  for index, component in ipairs(this.renderer) do
    component:draw(this, dt)
  end
end

return entity