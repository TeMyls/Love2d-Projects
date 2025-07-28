local raycast = {}
raycast.__index = raycast

local _floor, _cos, _sin, _max, _abs, _sqrt = math.floor, math.cos, math.sin, math.max, math.abs, math.sqrt

function raycast:new()
    return setmetatable( {} , self)
end

--this function is copied from lume in libs
function raycast:get_distance(x1, y1, x2, y2)
    local dx = x1 - x2
    local dy = y1 - y2
    local s = dx * dx + dy * dy
    return _sqrt(s)
end

function raycast:in_bounds(x, y, grid_w, grid_h)
    return 1 <= x and x < grid_w - 1 and  1 <= y and x < grid_h - 1
end

function raycast:DDA(x1, y1, x2, y2)
    --digital differential analyzer
    --draws a line from one point ot another
  
    local dx = x2 - x1
    local dy = y2 - y1
    local steps = _max(_abs( dx ), _abs( dy ))
  
    local x_inc = dx/steps
    local y_inc = dy/steps
  
    local _x = x1
    local _y = y1
    local _t = {_x, _y}
    
  
    for i = 1, steps do
  
      _x = _x + x_inc
      _y = _y + y_inc
      
      table.insert(_t, _x)
      table.insert(_t, _y)
    end
  
  
  end



--only works in tiled worlds
function raycast:DDA_raycast(x1, y1, radians, max_length, all_cells, grid, grid_width, grid_height)
    --assumes grid like
    --{{0, 0, 0}, 
    --{0, 0, 0},
    --{0, 0, 0}} 
    --with a tile assigned as floor and wall tiles
    --alls cells should be set up like {1 = true 2 = false, 3 = true}, 
    --2 would be an invalid cell in this case
    --sigfigy
    --cast a ray from one point to another

    local x_inc = _cos(radians)
    local y_inc = _sin(radians)
  
    
    local cur_cell = grid[_floor(y1)][_floor(x1)]
    local og_cell = cur_cell
    local _x = x1
    local _y = y1
    while cur_cell == og_cell or all_cells[cur_cell] == true and self:get_distance(x1, y1, _x, _y) < max_length do
      _x = _x + x_inc
      _y = _y + y_inc
      if self:in_bounds(_x, _y, grid_width, grid_height) then
        cur_cell = grid[_floor(_y)][_floor(_x)]
      else
        return {dist = self:get_distance(x1, y1,  _x - x_inc, _y - y_inc), 
                coords = {x = _x - x_inc, y = _y - y_inc}
            }

      end

      if all_cells[cur_cell] == false then
        return {dist = self:get_distance(x1, y1,  _x - x_inc, _y - y_inc), 
                coords = {x = _x - x_inc, y = _y - y_inc}
            }
      end
      
    end
  end
  
return raycast