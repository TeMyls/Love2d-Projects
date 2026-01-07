--https://www.jeffreythompson.org/collision-detection/table_of_contents.php
--collisions
--floats preferable on all arguments

local collider = {}
collider.__index = collider
local _abs, _sqrt = math.abs, math.sqrt
local lim = 3


function collider:new()
  return setmetatable( {} , self)
end


--this is copied from lume in libs
function collider:get_distance(x1, y1, x2, y2)
    local dx = x1 - x2
    local dy = y1 - y2
    local s = dx * dx + dy * dy
    return _sqrt(s)
end

function collider:point_point(x1, y1, x2, y2, buffer)
    --exact points
    --buffer
    local b = buffer or lim
    if x1 + b <= x2 <= x1 - b and 
    y1 + b <= y2 <= y1 - b then 
        return true
    else 
        return false
    end
  end
  
  
function collider:point_circle(px, py, cx, cy, r)
    --get distance between the point and the circle's center
    local dist = collider:get_distance(px, py, cx, cy)
    --if the distance is less than the circle's radius,
    --the point is inside
    if dist <= r then
        return true
    end
    return false
end
  
  function collider:circle_circle(cx1, cy1, cr1, cx2, cy2, cr2)
    --get distance between the circle's centers
    local dist = collider:get_distance(cx1, cy1, cx2, cy2)
    --if the distance is less the circle's
    --radii, the circles are touching
    if dist <= cr1 + cr2 then
        return true
    end
    return false
  
  end
  
function collider:point_rectangle(px, py, rx, ry, rw, rh)
    --is the point inside the rectangles bounds
    if px >= rx and --right ot the left edge
    px <= rx + rw and --left of the right edge
    py >= ry and --below the top 
    py <= ry + rh then --above the bottom
      return true
    end
    return false
  end
  
function collider:rectangle_rectangle(rx1, ry1, rw1, rh1, rx2, ry2, rw2, rh2)
    --AABB
    --or axis aligned bounding box
    if rx1 + rw1 >= rx2 and
    rx1 <= rx2 + rw2 and
    ry1 + rh1 >= ry2 and
    ry1 <= ry2 + rh2 then
      return true
    end
    return false
  end
  
function collider:circle_rectangle(cx, cy, r, rx, ry, rw, rh)

    local test_x = cx
    local test_y = cy
  
    --which edge is closest
    if cx < rx then --test left edge
      test_x = rx
    elseif cx > rx + rw then --test right edge
      test_x = rx + rw
    end
  
    if cy < ry then --test top edge
      test_y = ry
    elseif cy > ry + rh then --test bottom edge
      test_y = ry + rh
    end
  
    local dist = collider:get_distance(cx, cy, test_x, test_y)
  
    --if the distance is less than the radius collision
    if dist <= r then
      return true
    end
    return false
  
end
  
function collider:line_point(x1, y1, x2, y2, px, py, buffer)
    --distance from the point to the two ends of the line
    
    local dist_1 = collider:get_distance(px, py, x1, y1)
    local dist_2 = collider:get_distance(px, py, x2, y2)
   
    --the length of the line segment
    local line_len = collider:get_distance(x1, y1, x2, y2)
    --buffer
    local b = buffer or lim
    if dist_1 + dist_2 >=  line_len - b and 
    dist_1 + dist_2 <=  line_len + b then
      return true
    end
    return false
end
  
function collider:line_circle(x1, y1, x2, y2, cx, cy, r)
    --is either end inside the circle
    --if so return true immediately
    local inside_1 = collider:point_circle(x1, y1, cx, cy, r)
    local inside_2 = collider:point_circle(x2, y2, cx, cy, r)
  
    if inside_1 or inside_2 then
      return true
    end
    --getting the length the line
    local line_len = collider:get_distance(x1, y1, x2, y2)
  
    --getting the dot product of the line and circle
    local dot = (((cx - x1) * (x2 * x1)) + ((cy - y1) * (y2 - y1))) /  (line_len * line_len)
    --closest point on the line
    local closest_x = x1 + (dot * (x2 - x1))
    local closest_y = y1 + (dot * (y2 - y1))
    --is the point actually on the line segment
    --if so keep going if not return false
    local on_segment = collider:line_point(x1, y1, x2, y2, closest_x, closest_y)
  
    if not on_segment then
      return false
    end
  
    local dist = collider:get_distance(cx, cy, closest_x, closest_y)
  
    if dist <= r then
      return true
    end
    return false
  
end
  
function collider:line_line(x1, y1, x2, y2, x3, y3, x4, y4)
    -- calculate the distance to the intersection point
    local uA = ((x4-x3)*(y1-y3) - (y4-y3)*(x1-x3)) / ((y4-y3)*(x2-x1) - (x4-x3)*(y2-y1))
    local uB = ((x2-x1)*(y1-y3) - (y2-y1)*(x1-x3)) / ((y4-y3)*(x2-x1) - (x4-x3)*(y2-y1))
    --if uA and uB are between 0-1, lines are colliding
    if uA >= 0 and uA <= 1 and uB >= 0 and uB <= 1 then
      return true
    end
    return false

end
  
function collider:line_rectangle(x1, y1, x2, y2, rx, ry, rw, rh)
    -- check if the line has hit any of the rectangle's sides
    -- uses the Linefunction collider:above
    local left =   collider:line_line(x1,y1,x2,y2, rx,ry,rx, ry+rh)
    local right =  collider:line_line(x1,y1,x2,y2, rx+rw,ry, rx+rw,ry+rh)
    local top =    collider:line_line(x1,y1,x2,y2, rx,ry, rx+rw,ry)
    local bottom = collider:line_line(x1,y1,x2,y2, rx,ry+rh, rx+rw,ry+rh)

    -- if ANY of the above are true, the line
    -- has hit the rectangle
    if left or right or top or bottom then
      return true
    end
    return false
  
end
  
function collider:polygon_point(vertices, px, py)
    --vertices arranged in x, y, x, y to allow easy polygons 
    --the least amount of vertex a shape can have is 3, a triangle, meaning 3 pairs of x y coords
    local collision = false
    if #vertices >= 6 then
      
      for i = 1, #vertices, 2  do
          --current and next index
          local cx_ind = i
          local cy_ind = i + 1
          local nx_ind = i + 2
          local ny_ind = i + 3
          if nx_ind > #vertices then
            nx_ind = nx_ind % #vertices
          end
  
          if ny_ind > #vertices then
            ny_ind = ny_ind % #vertices
          end
  
          --if nxt == #vertices - 1 then nxt = 1 end
  
          local vcx = vertices[cx_ind]
          local vcy = vertices[cy_ind]
          local vnx = vertices[nx_ind]
          local vny = vertices[ny_ind]
          
          local bool_1 = vcy >= py and vny < py
          local bool_2 = vcy < py and vny >= py
          local bool_3 = px < (vnx-vcx)*(py-vcy) / (vny-vcy)+vcx
  
          if ((vcy >= py and vny < py) or (vcy < py and vny >= py)) and 
          px < (vnx-vcx)*(py-vcy) / (vny-vcy)+vcx then
              collision = not collision
          end
      
      end
    end
    return collision
  
end
  
function collider:polygon_circle(vertices, cx, cy, r)
    --vertices arranged in x, y, x, y to allow easy polygons 
    --the least amount of vertex a shape can have is 3, a triangle, meaning 3 pairs of x y coords
    local collision = false
    if #vertices >= 6 then
    
      for i = 1, #vertices, 2  do
        --current and next index
        local cx_ind = i
        local cy_ind = i + 1
        local nx_ind = i + 2
        local ny_ind = i + 3
        if nx_ind > #vertices then
          nx_ind = nx_ind % #vertices
        end
  
        if ny_ind > #vertices then
          ny_ind = ny_ind % #vertices
        end
  
        local vcx = vertices[cx_ind]
        local vcy = vertices[cy_ind]
        local vnx = vertices[nx_ind]
        local vny = vertices[ny_ind]
        
        collision = collider:line_circle(vcx, vcy, vnx, vny, cx, cy, r)
        if collision then
          return true
        end
    
      
      end
    end
    return false
  
end
  
function collider:polygon_rectangle(vertices, rx, ry, rw, rh)
    --vertices arranged in x, y, x, y to allow easy polygons 
    --the least amount of vertex a shape can have is 3, a triangle, meaning 3 pairs of x y coords
    local collision = false
    if #vertices >= 6 then
    
      
      for i = 1, #vertices, 2  do
        --current and next index
        local cx_ind = i
        local cy_ind = i + 1
        local nx_ind = i + 2
        local ny_ind = i + 3
        if nx_ind > #vertices then
          nx_ind = nx_ind % #vertices
        end
  
        if ny_ind > #vertices then
          ny_ind = ny_ind % #vertices
        end
  
        --if nxt == #vertices - 1 then nxt = 1 end
  
        local vcx = vertices[cx_ind]
        local vcy = vertices[cy_ind]
        local vnx = vertices[nx_ind]
        local vny = vertices[ny_ind]
        
        collision = collider:line_rectangle(vcx, vcy, vnx, vny, rx, ry, rw, rh)
        if collision then
          return true
        end

      end
    end
    return false
  
end
  
function collider:polygon_line(vertices, x1, y1, x2, y2)
    --vertices arranged in x, y, x, y to allow easy polygons 
    --the least amount of vertex a shape can have is 3, a triangle, meaning 3 pairs of x y coords
    local collision = false
    if #vertices >= 6 then
    

    
        for i = 1, #vertices, 2  do
            --current and next index
            local cx_ind = i
            local cy_ind = i + 1
            local nx_ind = i + 2
            local ny_ind = i + 3
            if nx_ind > #vertices then
            nx_ind = nx_ind % #vertices
            end

            if ny_ind > #vertices then
            ny_ind = ny_ind % #vertices
            end

            local vcx = vertices[cx_ind]
            local vcy = vertices[cy_ind]
            local vnx = vertices[nx_ind]
            local vny = vertices[ny_ind]
            
            collision = collider:line_line(x1, y1, x2, y2, vcx, vcy, vnx, vny)
            if collision then
              return true
            end
        
        end
    end
    return false
  
end
  
function collider:polygon_polygon(vertices, vertices_2)
    --vertices arranged in x, y, x, y to allow easy polygons 
    --the least amount of vertex a shape can have is 3, a triangle, meaning 3 pairs of x y coords
    local collision = false
    if #vertices >= 6 then
    
      
      for i = 1, #vertices, 2  do
        --current and next index
        local cx_ind = i
        local cy_ind = i + 1
        local nx_ind = i + 2
        local ny_ind = i + 3
        if nx_ind > #vertices then
          nx_ind = nx_ind % #vertices
        end
  
        if ny_ind > #vertices then
          ny_ind = ny_ind % #vertices
        end
  
        local vcx = vertices[cx_ind]
        local vcy = vertices[cy_ind]
        local vnx = vertices[nx_ind]
        local vny = vertices[ny_ind]
        
  
  
        collision = collider:polygon_line(vertices_2, vcx, vcy, vnx, vny)
        if collision then
          return true
        end
    
      
      end

    end
    return false
  
end
  
function collider:triangle_point(x1, y1, x2, y2, x3, y3, px, py)
  
    local areaOrig = _abs( (x2-x1)*(y3-y1) - (x3-x1)*(y2-y1) )
  
    --get the area of 3 triangles made between the point
    -- and the corners of the triangle
    local area1 =    _abs( (x1-px)*(y2-py) - (x2-px)*(y1-py) )
    local area2 =    _abs( (x2-px)*(y3-py) - (x3-px)*(y2-py) )
    local area3 =    _abs( (x3-px)*(y1-py) - (x1-px)*(y3-py) )
  
    -- if the sum of the three areas equals the original,
    -- we're inside the triangle!
    if area1 + area2 + area3 == areaOrig then
      return true
    end
    return false
    
end

return collider