local MAX_ITEMS = 0
local MAX_LEVEL = 0

local quadTree = {
  enabled = true,
  level = 0,
  parent = nil,
  children = [],
  items = [],
  numberOfItems = 0,

  bounds = {x = 0,
           y = 0,
           width = 0,
           height = 0 }
}

quadTree.addItem = function(this, item)
  if numberOfItems > MAX_ITEMS then
    this.splitTree()
  end
end

quadTree.splitTree = function(this)

end

quadTree.update = function()

end