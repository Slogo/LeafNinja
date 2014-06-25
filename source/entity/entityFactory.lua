local baseEntity = require("entity/entity")
--A list of entity base types and their default configuration
local entityTypes = require("entity/entityPrefabs")

--Map of component names and types.
local componentMap = {
  playerController = {type = "behavior", name = "entity/components/playerController"},
  worldCollisionResolver = {type = "behavior", name = "entity/components/worldCollisionResolver"},
  staticHitbox = {type = "behavior", name = "entity/components/staticHitbox"},

  friction = {type = "physics", name =  "entity/components/physics/friction"},
  gravity = {type = "physics", name =  "entity/components/physics/gravity"},
  lateral = {type = "physics", name =  "entity/components/physics/lateral"},

  simplePointRenderer = {type = "renderer", name = "entity/components/renderer/simplePointRenderer"}
}

--The factory constructor
local entityFactory = {
  id = 0
}

--[[
Factory for entities. Will take in a configuration
and build out the appropriate entity then add it to the
world.
]]--
entityFactory.initialize = function(this)
  this.id = 0
end

--Processes an list of entities adding them all to the world
entityFactory.processEntities = function(this, entities)
  for i, entityData in pairs(entities) do
    world:addEntity(this:createEntity(entityData.type, entityData.id, entityData.options))
  end
end

--Creates an entity from raw data
--id - the id to use for the entity, otherwise the next random id is used
--type - the type of entity to create. type will determine what properties
--       are pulled from entity prefab
--options - specific override options that go on top of the entity prefab
entityFactory.createEntity = function(this, id, type, options)
  local newEntity = {}
  for key, value in pairs(baseEntity) do
    newEntity[key] = value
  end

  newEntity.id = id or this.id
  if not id then
    this.id = this.id + 1 --Increment id
  end

  --Copy the velocity as properties into a new object
  if options.velocity then
    newEntity.velocity = {x = options.velocity.x, y = options.velocity.y}
  else
    newEntity.velocity = {x = 0, y = 0}
  end

  --Same for position
  if options.position then
    newEntity.position = {x = options.position.x, y = options.position.y}
    newEntity.oldPosition = {x = options.position.x, y = options.position.y}
  else
    newEntity.position = {x = 0, y = 0}
    newEntity.oldPosition = {x = 0, y = 0}
  end

  local components = {}

  --Copy prefab component settings
  if type and entityTypes[type] then
    for key, value in pairs(entityTypes[type]) do
      components[key] = value
    end
  end

  --Override with settings
  if options.components then
    for key, value in pairs(options.components) do
      components[key] = options.components
    end
  end

  if components then
    for i, componentOptions in pairs(components) do
      this:createAndAddComponent(newEntity, i, componentOptions)
    end
  end

  --Add entity to world and return
  world:addEntity(newEntity)
  logger.log("Added entity of: " .. newEntity.id, logger.INFO)
  return newEntity
end

--Creats a component out of a set of options
--entity - the entity to attach the component to
--id - the id of the component
--options - a list of values for the component's properties
entityFactory.createAndAddComponent = function(this, entity, id, options)
  local componentEntry = componentMap[id]

  if not componentEntry then
    logger.log("Could not find component: " .. id, logger.WARNING)
    return
  end
  local componentType = require(componentEntry.name)
  local component = {}

  for key, value in pairs(componentType) do
    component[key] = value
  end

  if options then
    for i, option in pairs(options) do
      component[i] = option
    end
  end

  entity:addComponent(componentEntry.type, component)
end

return entityFactory