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

  print("Processing Tiles. Size: " .. tileSize .. " rows: " .. rows .. " columns: " .. columns)
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
    for column = 1, rows, 1 do
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
    for column = 1, this.rows, 1 do
        tile = this:getPosition(column, row)
        if tile.type ~= TILE_TYPE.EMPTY then
          x, y = world.camera:worldToCamera((column - 1) * this.tileSize, (row - 1) * this.tileSize)
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
    for column = 1, this.rows, 1 do
      tile = this:getPosition(column, row)
      x, y = world.camera:worldToCamera((column - 1) * this.tileSize, (row - 1) * this.tileSize)
      if tile.left == EDGE_TYPE.BLOCKING then
        love.graphics.line(x, y, x, y + this.tileSize)
      end

      if tile.right == EDGE_TYPE.BLOCKING then
        love.graphics.line(x + this.tileSize, y, x + this.tileSize, y + this.tileSize)
      end

      if tile.bottom == EDGE_TYPE.BLOCKING then
        love.graphics.line(x, y + this.tileSize, x + this.tileSize, y + this.tileSize)
      end

      if tile.top == EDGE_TYPE.BLOCKING then
        love.graphics.line(x, y, x + this.tileSize, y)
      end
    end
  end
end

return gridMap
