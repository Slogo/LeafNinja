require("world/worldConstants")

local resources = require("resources/resourceManager")

world = {
  camera = nil,
  spatialManager = nil,
  gridMap = nil,

  levelName = nil,
  levelData = {},

  entities = {},
  entitiesToAdd = {},
  entitiesToRemove = {},
  paused = false
}

world.initialize = function(this)

  this.spatialManager = require("world/spatialManager")
  this.gridMap = require("world/gridMap")
  this.camera = require("libs/lovethecamera")
  this.entityFactory = require("entity/entityFactory")

  this.camera.viewport.width = CAMERA.WIDTH
  this.camera.viewport.height = CAMERA.HEIGHT
  this.camera.offset.x = CAMERA.OFFSET_X
  this.camera.offset.y = CAMERA.OFFSET_Y
  this.camera.wobble.x = CAMERA.WOBBLE_X
  this.camera.wobble.y = CAMERA.WOBBLE_Y
  this.camera.wobble.width = CAMERA.WOBBLE_WIDTH
  this.camera.wobble.height = CAMERA.WOBBLE_HEIGHT
  this.camera.box.width = CAMERA.BOX_WIDTH
  this.camera.box.height = CAMERA.BOX_HEIGHT
  this.camera.snapDistance = CAMERA.SNAP_DISTANCE
  this.camera.easeDuration = CAMERA.EASE_DURATION
end

world.getEntity = function(this, id)
  return this.entities[id]
end

world.addEntity = function(this, entity)
  table.insert(this.entitiesToAdd, entity)
end

world.removeEntity = function(this, id)
  table.insert(this.entitiesToRemove, id)
end

world.loadLevel = function(this, level)
  logger.log("Loading Level: " .. level, logger.INFO)
  this.levelName = level
  this.update = this.levelUpdate --Defer load until next frame
end

world.loadLevelCompleted = function(this, level)
  logger.log("Level Loaded complete", logger.DEBUG)
  this.levelData = level
  this.switchLevels = true
end

--Process the add and remove entity steps. Takes entities
--marked for addition or removal and actually performs the addition/removal
world.processEntitiesToAddAndRemove = function(this)
  for index, id in pairs(this.entitiesToRemove) do
    this.entities[id] = nil
  end

  for id, entity in ipairs(this.entitiesToAdd) do
    this.entities[id] = entity
  end
end

--[[
-- Update Methods.
]]--

--Update to handle loading a new level. Done here to defer the level until
--the next frame step
world.levelUpdate = function(this, dt)
  local levelData = resources.level.load(this.levelName)
  this.entities = {}
  this.entitiesToAdd = {}
  this.entitiesToRemove = {}
  this.spatialManager:initializeBuckets(256, levelData.columns * levelData.tileSize, levelData.rows * levelData.tileSize)
  this.gridMap:processTiles(levelData.tileSize, levelData.rows, levelData.columns, levelData.tiles)
  this.entityFactory:initialize()
  this.camera.bounds.x = levelData.tileSize * levelData.columns
  this.camera.bounds.y = levelData.tileSize * levelData.rows
  this.update = this.worldUpdate

  this.entityFactory:processEntities(levelData.entities)
  this:processEntitiesToAddAndRemove()
end

--Core world update run during the game. Updates all entities
--and other aspects of the game world.
world.worldUpdate = function(this, dt)
  this.camera:update(dt)
  this:processEntitiesToAddAndRemove()
  this.spatialManager:emptyBuckets()

  for i, entity in pairs(this.entities) do
    entity:update(dt)
    this.gridMap:checkCollisions(entity)
  end
end

--Empty initial update
world.update = function(this, dt)
  --do nothing in uninitialized state
end

world.draw = function(this)
  if this.gridMap then
    this.gridMap:draw()
  end

  for i, entity in pairs(this.entities) do
    entity:draw()
  end
end

