local SpacialManager = {
  cellSize = 0,
  buckets = {},
  width = 0,
  height = 0
}

SpacialManager.initializeBuckets = function(this, cellSize, width, height)
  local rows = math.ceil(width / cellSize)
  local columns = math.ceil(height / cellSize)
  local index
  for index = 0, rows * columns, 1 do
    this.buckets[index] = {}
  end
end

SpacialManager.emptyBuckets = function(this)
  for i,bucket in pairs(this.buckets) do
    for j in pairs(bucket) do bucket[j]=nil end
  end
end

SpacialManager.getBucket = function(this, x, y)
  return this.buckets[Math.floor(x / cellSize) + Math.floor(y / cellSize) * this.width]
end

SpacialManager.addObjectToMap = function(this, id, rectangle, parent)
  local wrappedObject = {bounds = rectangle, object = parent}
  local right = rectangle.x + rectangle.width
  local bottom = rectangle.y + rectangle.height

  --Currently only check corners
  this:addObjectToBucket(this:getBucket(rectangle.x, rectangle.y), id, wrappedObject)
  this:addObjectToBucket(this:getBucket(right, rectangle.y), id, wrappedObject)
  this:addObjectToBucket(this:getBucket(rectangle.x, bottom), id, wrappedObject)
  this:addObjectToBucket(this:getBucket(right, bottom), id, wrappedObject)
end

SpacialManager.addObjectToBucket = function(this, bucket, id, wrappedObject)
  bucket[entity.id] = wrappedObject --Just overwrite the object if it already exists
end

return SpacialManager