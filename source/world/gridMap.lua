--[[
  Grid Map
  Handles the collision grid map
--]]
--Tile edges
local EDGE_TYPE = {
  NONE = 0,
  BLOCKING = 1,
  INTERESTING = 2
}

--Tile types
local TILE_TYPE = {
  EMPTY = 0, --No collision
  BLOCK = 1  --Full collision
}

--The map itself
local gridMap = {
  tileSize = 0,
  columns = 0,
  rows = 0,
  map = {},

  mapLength = 0
}

--Maps a tile position (i.e. 1, 2, 3) to a world coordinate
--(i.e. 0, 32, 64, 96)
gridMap.getWorldPosition = function(this, tileCoordinate)
  return (tileCoordinate - 1) * this.tileSize
end

gridMap.getFarEdgeWorldPosition = function(this, tileCoordinate)
  return (tileCoordinate) * this.tileSize - 1
end

--Gets the x, y grid cell for the given position
gridMap.getPositionCoordinates = function(this, x, y)
  return math.ceil(x / this.tileSize), math.ceil(y / this.tileSize)
end

--Gets the table index for the given tile
gridMap.getTablePosition = function(this, x, y)
  return (y - 1)*this.columns + x
end

--Gets the tile at the given grid position
gridMap.getPosition = function(this, x, y)
  local pos = this:getTablePosition(x, y)
  return this.map[pos]
end

--Create a new tile of type for position x & y
gridMap.newTile = function(this, type, x, y)
  local tile = { type = (type or TILE_TYPE.EMPTY)}

  --Set the initial edges based on selected tile type
  if type == TILE_TYPE.BLOCK then
    tile.left = EDGE_TYPE.BLOCKING
    tile.right = EDGE_TYPE.BLOCKING
    tile.top = EDGE_TYPE.BLOCKING
    tile.bottom = EDGE_TYPE.BLOCKING
  elseif type == TILE_TYPE.EMPTY then
    tile.left = EDGE_TYPE.NONE
    tile.right = EDGE_TYPE.NONE
    tile.top = EDGE_TYPE.NONE
    tile.bottom = EDGE_TYPE.NONE
  end

  --Add the tile to the map and return it
  this.map[this:getTablePosition(x, y)] = tile
  return tile
end

--Processes the given tiles to create a map
gridMap.processTiles = function(this, tileSize, rows, columns, tiles)
  local tile, leftTile, rightTile, topTile, bottomTile

  logger.log("Processing Tiles. Size: " .. tileSize .. " rows: " .. rows .. " columns: " .. columns, logger.DEBUG)
  print(#tiles)
  --Clear the current map
  this.map = {}

  --Set the map dimensions
  this.tileSize = tileSize
  this.rows = rows
  this.columns = columns
  this.mapLength = rows * columns

  for row = 1, rows, 1 do
    --reset tiles for new row
    leftTile = nil
    tile = nil
    for column = 1, columns, 1 do
      --Process tiles left to right keeping track of previous tile
      leftTile = tile
      tile = this:newTile(tiles[this:getTablePosition(column, row)], column, row);

      --Check tiles above to handle vertical edges
      topTile = this:getPosition(column, row - 1);

      --If the tile has a blocking left edge and
      --the left tile has a blocking edge, both
      --can be set to none (interior edge)
      if tile.left == EDGE_TYPE.BLOCKING then
        if leftTile then
          if leftTile.right == EDGE_TYPE.BLOCKING then
            tile.left = EDGE_TYPE.NONE
            leftTile.right = EDGE_TYPE.NONE
          end
        else
          tile.left = EDGE_TYPE.NONE
        end
      end

      --Check the above tile in the same way
      if tile.top == EDGE_TYPE.BLOCKING then
        if topTile then
          if topTile.bottom == EDGE_TYPE.BLOCKING then
            tile.top = EDGE_TYPE.NONE
            topTile.bottom = EDGE_TYPE.NONE
          end
        else
          tile.top = EDGE_TYPE.NONE
        end
      end
    end
  end
end

--Checks an entity for collisions against the world
gridMap.checkCollisions = function(this, entity)
  local tile = nil
  local sx = 0
  local sy = 0
  local ex = 0
  local xy = 0
  local collisionDistance = 0

  --bounds for the new position
  local boxBounds = {
    left = 0,
    right = 0,
    top = 0,
    bottom = 0
  }

  --bounds based on the old position
  local oldBoxBounds = {
    right = 0,
    left = 0,
    top = 0,
    bottom = 0
  }

  local collisions = {
    right = nil,
    left = nil,
    top = nil,
    bottom = nil
  }

  for i, box in ipairs(entity.hitWorld) do
    --Calculate new position
    boxBounds.left = box.x + entity.position.x
    boxBounds.right = box.width + boxBounds.left
    boxBounds.top = box.y + entity.position.y
    boxBounds.bottom = box.height + boxBounds.top

    --Need to calculate old position as well
    oldBoxBounds.left = box.x + entity.oldPosition.x
    oldBoxBounds.right = box.width + oldBoxBounds.left
    oldBoxBounds.top = box.y + entity.oldPosition.y
    oldBoxBounds.bottom = box.height + oldBoxBounds.top

    sx, sy = this:getPositionCoordinates(boxBounds.left, boxBounds.top)
    ex, ey = this:getPositionCoordinates(boxBounds.right, boxBounds.bottom)

    --For each tile the entity occupies check for collisions
    for i = sx, ex, 1 do
      for j = sy, ey, 1 do
        tile = this:getPosition(i, j)
        --We have a collision!
        if tile.type == TILE_TYPE.BLOCK then
          --logger.log("Occupied tile is blocking: " .. i .. " , " .. j , logger.DEBUG)
          if tile.left == EDGE_TYPE.BLOCKING and boxBounds.right > this:getWorldPosition(i) and
             oldBoxBounds.right <=  this:getWorldPosition(i) then
            --logger.log("Left Collision on tile: " .. i .. " , " .. j , logger.DEBUG)
            --Collision on a tile's left edge.
            collisionDistance = boxBounds.right - this:getWorldPosition(i)
            if not collisions.left or collisionDistance > collisions.left.distance then
              collisions.left = {distance = collisionDistance}
            end
          end

          if tile.right == EDGE_TYPE.BLOCKING and boxBounds.left < this:getFarEdgeWorldPosition(i) and
             oldBoxBounds.left >= this:getFarEdgeWorldPosition(i) then
            --logger.log("Right Collision on tile: " .. i .. " , " .. j , logger.DEBUG)
            --Collision on a tile's right edge
            collisionDistance =  this:getFarEdgeWorldPosition(i) - boxBounds.left
            if not collisions.right or collisionDistance > collisions.right.distance then
              collisions.right = {distance = collisionDistance}
            end
          end

          if tile.top == EDGE_TYPE.BLOCKING and boxBounds.bottom > this:getWorldPosition(j) and
             oldBoxBounds.bottom <= this:getWorldPosition(j) then
            --Collision on a tile's top edge
            collisionDistance = boxBounds.bottom - this:getWorldPosition(j)
            if not collisions.top or collisionDistance > collisions.top.distance then
              collisions.top = {distance = collisionDistance}
            end
          end

          if tile.bottom == EDGE_TYPE.BLOCKING and boxBounds.top < this:getFarEdgeWorldPosition(j) and
             oldBoxBounds.top >= this:getFarEdgeWorldPosition(j) then
            --Collision on a tile's top edge
            collisionDistance = this:getFarEdgeWorldPosition(j) - boxBounds.top
            if not collisions.bottom or collisionDistance > collisions.bottom.distance then
              collisions.bottom = {distance = collisionDistance}
            end
          end
        end
      end
    end
  end

  --oldPosition collision results
  local isLeftCollisions = collisions.left and 1 or 0
  local isRightCollisions = collisions.right and 1 or 0
  local isTopCollisions = collisions.top and 1 or 0
  local isBottomCollisions = collisions.bottom and 1 or 0
  local collisionSidesTotal = isLeftCollisions + isRightCollisions + isTopCollisions + isBottomCollisions

  --Handle collisions with one tile side
  if collisionSidesTotal == 1 then
    if isLeftCollisions ~= 0 then
      --Push Left
      --logger.log("Collision, push left", logger.DEBUG)
      entity:triggerEvent("worldCollision", {x = -1 * collisions.left.distance})
    elseif isRightCollisions ~= 0 then
      --Push Right
      --logger.log("Collision, push right", logger.DEBUG)
      entity:triggerEvent("worldCollision", {x = collisions.right.distance})
    elseif isTopCollisions ~= 0 then
      --Push Up
      --logger.log("Collision, push up", logger.DEBUG)
      entity:triggerEvent("worldCollision", {y = -1 * collisions.top.distance})
    else
      --Push Down
      --logger.log("Collision, push down", logger.DEBUG)
      entity:triggerEvent("worldCollision", {y = collisions.bottom.distance})
    end
  elseif collisionSidesTotal == 2 then
    --logger.log("Double Collision", logger.DEBUG)
    if isLeftCollisions ~= 0 and isRightCollisions ~= 0 then
      if entity.position.x < entity.oldPosition.x  then
        --Moving left, ignore left collision and push right
        entity:triggerEvent("worldCollision", {x = collisions.right.distance})
      elseif entity.position.x > entity.oldPosition.x then
        --Moving right, ignore right collision and push left
        entity:triggerEvent("worldCollision", {x = -1 * collisions.left.distance})
      elseif collisions.left.distance <= collisions.right.distance then
        --Use left because it's less distance
        --Give slight priority to left collision because maps are expected to be
        --left to right
        entity:triggerEvent("worldCollision", {x = -1 * collisions.left.distance})
      else
        --Use right because it's less distance
        entity:triggerEvent("worldCollision", {x = collisions.right.distance})
      end
    elseif isTopCollisions ~= 0 and isBottomCollisions ~= 0 then
      if entity.position.y < entity.oldPosition.y then
        --Moving up, ignore top collision and push down
        entity:triggerEvent("worldCollision", {y = collisions.bottom.distance})
      elseif entity.position.y > entity.oldPosition.y then
        --Moving down, ignore bottom collision and push up
        entity:triggerEvent("worldCollision", {y = -1 * collisions.top.distance})
      elseif collisions.top.distance <= collisions.bottom.distance then
        --Use top because the distance is less. Give slight priority to top
        --so we push the player up onto platforms more often.
        entity:triggerEvent("worldCollision", {y = -1 * collisions.top.distance})
      else
        --Use bottom because it is less distance
        entity:triggerEvent("worldCollision", {y = collisions.bottom.distance})
      end
    else
      this:resolveCornerCollision(entity, collisions)
    end
  elseif collisionSidesTotal > 2 then
    --logger.log("Three or Four Collision", logger.DEBUG)
    --This resolves both 3 and 4 edge collisions. We know that
    --for 3 sided collisions we should be able to eliminate either a top or
    --bottom collision making it a corner collision. For 4 sided collisions
    --we can eliminate 2 sides to make it a corner collision
    if isLeftCollisions and isRightCollisions then
      --Remove either left or right depending on velocity
      if entity.position.x < entity.oldPosition.x then
        --Moving left, ignore right collision
        collisions.right = nil
      elseif entity.position.x > entity.oldPosition.x then
        --Moving right, ignore left collision
        collisions.left = nil
      elseif collisions.left.distance <= collisions.right.distance then
        collisions.right = nil
      else
        collisions.left = nil
      end
    end

    if isTopCollisions and isBottomCollisions then
      --Remove either top or bottom depending on velocity
      if entity.position.y < entity.oldPosition.y then
        --Moving up, ignore bottom collision
        collisions.bottom = nil
      elseif entity.position.y > entity.oldPosition.y then
        --Moving down, ignore top collision
        collisions.top = nil
      elseif collisions.top.distance < collisions.bottom.distance then
        collisions.bottom = nil
      else
        collisions.top = nil
      end
    end

    --Now resolve the corner collision we are left with
    this:resolveCornerCollision(entity, collisions)
  end
end

gridMap.resolveCornerCollision = function(this, entity, collisions)
  local xDiff = entity.position.x - entity.oldPosition.x
  local yDiff = entity.position.y - entity.oldPosition.y
  local x = 0
  local y = 0
  if xDiff == 0 then
    if yDiff == 0 then
      --Player isn't moving, take shortest push
      --
    --Player is moving only on the y axis, so resolve collision
    --on that axis only
    elseif collisions.bottom then
      entity:triggerEvent("worldCollision", {y = collisions.bottom.distance})
    else
      --Player is moving only on the y axis
      entity:triggerEvent("worldCollision", {y = -1 * collisions.top.distance})
    end
  elseif yDiff == 0 then
    --Player is moving only on the x axis
    if collisions.right then
      entity:triggerEvent("worldCollision", {x = collisions.right.distance})
    else
      entity:triggerEvent("worldCollision", {x = -1 * collisions.left.distance})
    end
  else
    --For right now just apply both directions
    if collisions.left then
      x = -1 * collisions.left.distance
    else
      x = collisions.right.distance
    end

    if collisions.top then
      y = -1 * collisions.top.distance
    else
      y = collisions.bottom.distance
    end
    entity:triggerEvent("worldCollision", {x = x, y = y})
  end

end

--Draw (only contains debug drawing)
gridMap.draw = function(this)
  this:drawTileTypes()
  this:drawTileEdges()
end

--Debug drawing of the tile types
gridMap.drawTileTypes = function(this)
  local tile = nil
  local x, y
  for row = 1, this.rows, 1 do
    for column = 1, this.columns , 1 do
        tile = this:getPosition(column, row)
        if tile.type ~= TILE_TYPE.EMPTY then
          x, y = world.camera:worldToCamera(gridMap:getWorldPosition(column), gridMap:getWorldPosition(row))
          --love.graphics.rectangle("line", x, y, this.tileSize, this.tileSize)
          love.graphics.print(tile.type, x + this.tileSize/2, y + this.tileSize /2)
        end
    end
  end
end

--Debug drawing of the tile edges that determine the walkable surfaces
gridMap.drawTileEdges = function(this)
  local tile = nil
  local x, y
  for row = 1, this.rows, 1 do
    for column = 1, this.columns, 1 do
      tile = this:getPosition(column, row)
      x, y = world.camera:worldToCamera(gridMap:getWorldPosition(column), gridMap:getWorldPosition(row))
      ex, ey = world.camera:worldToCamera(gridMap:getFarEdgeWorldPosition(column), gridMap:getFarEdgeWorldPosition(row))
      if tile.left == EDGE_TYPE.BLOCKING then
        love.graphics.line(x, y, x, ey)
      end

      if tile.right == EDGE_TYPE.BLOCKING then
        love.graphics.line(ex, y, ex, ey)
      end

      if tile.bottom == EDGE_TYPE.BLOCKING then
        love.graphics.line(x, ey, ex, ey)
      end

      if tile.top == EDGE_TYPE.BLOCKING then
        love.graphics.line(x, y, ex, y)
      end
    end
  end
end

return gridMap
