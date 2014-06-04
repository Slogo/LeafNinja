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

world.addEntity = function(this, id, entity) 
  this.entities[id] = entity
end

world.getEntity = function(this, id)
  return this.entitiesToAdd[id]
end

world.removeEntity = function(this, id)
  table.insert(this.entitiesToRemove, id)
end

world.loadLevel = function(this, level)
  print("Loading Level: " .. level)
  this.levelName = level
  this.update = this.levelUpdate --Defer load until next frame
end

world.loadLevelCompleted = function(this, level)
  print("Level Loaded complete")
  this.levelData = level
  this.switchLevels = true
end

world.levelUpdate = function(this, dt)
  print("level Update!")
  local levelData = resources.level.load(this.levelName)
  this.entities = {}
  this.entitiesToAdd = {}
  this.entitiesToRemove = {}
  this.spatialManager:initializeBuckets(256, levelData.columns * levelData.tileSize, levelData.rows * levelData.tileSize)
  this.gridMap:processTiles(levelData.tileSize, levelData.rows, levelData.columns, levelData.tiles)
  this.camera.bounds.x = levelData.tileSize * levelData.columns
  this.camera.bounds.y = levelData.tileSize * levelData.rows
  this.update = this.worldUpdate
  print(levelData.tileSize .. " " .. levelData.tileSize)
end

world.worldUpdate = function(this, dt)
  for index, id in pairs(this.entitiesToRemove) do
    this.entities[id] = nil
  end

  for id, entity in ipairs(this.entitiesToAdd) do
    this.entities[id] = entity
  end

  this.spatialManager:update(dt)
end

world.update = function(this, dt)
  --do nothing in uninitialized state
end

world.draw = function(this)
  if this.gridMap then
    this.gridMap:draw()
  end
end

