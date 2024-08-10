

local up = {x = 0, y = -1}
local down = {x = 0, y = 1}
local right = {x = 1, y = 0}
local left = {x = -1, y = 0}

local up_right = {x = right.x, y = up.y}
local down_right = {x = right.x, y = down.y}
local down_left = {x = left.x, y = down.y}
local up_left = {x = left.x, y = up.y}
--North NorthWest East SouthEast South SouthWest West, SouthWest
local directions = {up, up_right, right, down_right,down, down_left, left, up_left}




-- Binary Space Partitioning function to split a 2D area into smaller rectangles
-- floor: 2D array representing the map
-- splits: number of smaller rectangles to create
-- Thanks ChatGPT for rewriting my Python code.
function map_maker(rows,cols,default_val)
    local grid = {}
    for y = 1,rows do
      table.insert(grid,{})
      for x = 1,cols do
        table.insert(grid[y],default_val)
        
      end
    end
    
    --array_2d[2][2] = 0
    return grid
    
end

function console_array2d_print(array_2d)
  for y = 1, #array_2d do
    local s = ""
    for x = 1, #array_2d[y] do
      s = s..tostring(array_2d[y][x]).." "
    end
    print(s)
    
  end
end

function array_2d_bounds(array_2d, x, y)
  return x < level_width + 1 and x > 0 and y < level_height + 1 and y > 0


end


function minimumSpanningTree(points, d)
  local n = #points
  if n == 0 then return {} end
  if n == 1 then return { points[1] } end

  -- Initialize MST and visited set
  local mst = {}
  local visited = {}
  local totalWeight = 0

  -- Start from the first point (can start from any point)
  visited[1] = true

  while #mst < n - 1 do
      local minWeight = math.huge
      local minEdge

      -- Find the minimum weight edge connecting visited and unvisited nodes
      for i = 1, n do
          if visited[i] then
              for j = 1, n do
                  if not visited[j] then
                      local weight = d(points[i], points[j])
                      if weight < minWeight then
                          minWeight = weight
                          minEdge = {i, j}
                      end
                  end
              end
          end
      end

      -- Add the minimum edge to the MST
      if minEdge then
          local u, v = minEdge[1], minEdge[2]
          table.insert(mst, {points[u], points[v]})
          visited[v] = true
          totalWeight = totalWeight + minWeight
      end
  end
  -- Find leaf nodes in the MST

  return mst, totalWeight
end

function findLeafNodes(mst)
  local leafNodes = {}
  local degree = {}

  -- Initialize degree for each node
  for _, edge in ipairs(mst) do
      local u, v = edge[1], edge[2]
      degree[u] = (degree[u] or 0) + 1
      degree[v] = (degree[v] or 0) + 1
  end

  -- Collect leaf nodes (nodes with degree 1)
  for node, deg in pairs(degree) do
      if deg == 1 then
          table.insert(leafNodes, node)
      end
  end

  return leafNodes
end


-- Define the distance function (assuming Euclidean distance for simplicity)
local function distance(point1, point2)
  local dx = point1[1] - point2[1]
  local dy = point1[2] - point2[2]
  return math.sqrt(dx*dx + dy*dy)
end

  
function BSP(array_2d, splits)
    --splits a 2d array into several smaller sections
    local arr_x = 1
    local arr_y = 1
    local arr_w = #array_2d[1]
    local arr_h = #array_2d
    local areas = {{arr_x, arr_y, arr_w, arr_h}}
    local rng = love.math.newRandomGenerator()
    local prev = ""

    while #areas ~= splits do
        --local rand = rng:random(0,1) -- 0 for vertical split, 1 for horizontal split
        local rand = love.math.random(0, 100)  
        if rand >= 50 then
            local new_w = rng:random(math.floor(arr_w / 2), math.floor(arr_w * 0.6))
                table.insert(areas, {arr_x, arr_y, new_w, arr_h})
                table.insert(areas, {arr_x + new_w - 1, arr_y, arr_w - new_w + 1, arr_h})
            --[[
            if prev ~= "W" then
                prev = "W"
                local new_w = rng:random(math.floor(arr_w / 2), math.floor(arr_w * 0.6))
                table.insert(areas, {arr_x, arr_y, new_w, arr_h})
                table.insert(areas, {arr_x + new_w - 1, arr_y, arr_w - new_w + 1, arr_h})
            else
                rand = love.math.random(0, 100) 
                if rand <= 15 then
                    prev = "W"
                    local new_w = rng:random(math.floor(arr_w / 2), math.floor(arr_w * 0.6))
                    table.insert(areas, {arr_x, arr_y, new_w, arr_h})
                    table.insert(areas, {arr_x + new_w - 1, arr_y, arr_w - new_w + 1, arr_h})
                else
                    prev = "H"
                    local new_h = rng:random(math.floor(arr_h / 2), math.floor(arr_h * 0.6))
                    table.insert(areas, {arr_x, arr_y, arr_w, new_h})
                    table.insert(areas, {arr_x, arr_y + new_h - 1, arr_w, arr_h - new_h + 1})
                end
            end
            ]]--
            
        else
            local new_h = rng:random(math.floor(arr_h / 2), math.floor(arr_h * 0.6))
                table.insert(areas, {arr_x, arr_y, arr_w, new_h})
                table.insert(areas, {arr_x, arr_y + new_h - 1, arr_w, arr_h - new_h + 1})
            --[[
            if prev ~= "H" then
                prev = "H"
                local new_h = rng:random(math.floor(arr_h / 2), math.floor(arr_h * 0.6))
                table.insert(areas, {arr_x, arr_y, arr_w, new_h})
                table.insert(areas, {arr_x, arr_y + new_h - 1, arr_w, arr_h - new_h + 1})
            else 
                rand = love.math.random(0, 100) 
                if rand <= 15 then
                    prev = "H"
                    
                    local new_h = rng:random(math.floor(arr_h / 2), math.floor(arr_h * 0.6))
                    table.insert(areas, {arr_x, arr_y, arr_w, new_h})
                    table.insert(areas, {arr_x, arr_y + new_h - 1, arr_w, arr_h - new_h + 1})
                else
                    prev = "W"
                    local new_w = rng:random(math.floor(arr_w / 2), math.floor(arr_w * 0.6))
                    table.insert(areas, {arr_x, arr_y, new_w, arr_h})
                    table.insert(areas, {arr_x + new_w - 1, arr_y, arr_w - new_w + 1, arr_h})
                end
            end
            ]]--
                
        end
  
        table.remove(areas, 1)
        arr_x = areas[1][1]
        arr_y = areas[1][2]
        arr_w = areas[1][3]
        arr_h = areas[1][4]
    end
  
    return areas
end

function BSP_display(areas,array_2d,tiletype,griddy)
  --displays the borders for BSP the exact subsections the floor is split into
  
  
    for i = 1, #areas do
      local x = areas[i][1]
      local y = areas[i][2]
      local w = areas[i][3]
      local h = areas[i][4]
      --print(x,y,w,h,sep='_')
      
      --print(string.format("Area %d: x=%d, y=%d, width=%d, height=%d", i, x, y, w, h))
        
      
      for row = y, y + h - 1 do
        for col = x , x + w - 1 do
          --array_2d[row][col] = 1
          
          if col == x or col == x + w - 1 then
            array_2d[row][col] = tiletype
          elseif row == y or row == y + h - 1 then
            array_2d[row][col] = tiletype
          
          end
        end
      end
      
    end
  


  for y = 1,#array_2d do
    for x = 1,#array_2d[y] do
      if array_2d[y][x] == tiletype then 
        
        table.insert(batch_tiles,{
          x = (x - 1) * TILESIZE, 
          y = (y - 1) * TILESIZE,
          quad = griddy(1,1)[1]
        })
      end
    end
  end


end


function spawn_tunnels_from_BSP_MST(rooms, og_tile)
  --same thing but with a minimum spanning tree 
  --https://github.com/asundheim/lua_minimum_spanning_tree/tree/master
  room_centers = {}
  for i = 1, #rooms do
    local x = rooms[i].x
    local y = rooms[i].y
    local w = rooms[i].w
    local h = rooms[i].h
    --x, y , index of other rooms, distances of other rooms
    table.insert(room_centers,
    {
    x = lume.round((x + x + w)/2),
    y = lume.round((y + y + h)/2),
    ind = {},
    dist = {}

    })
    
  end
  local points = {}
  --local edges = {}

  --filling up the index and distance tables in room_centers
  for i = 1, #room_centers do
    table.insert(points,{room_centers[i].x,room_centers[i].y})
 
    for j = 1, #room_centers do
      if i ~= j then
        
        table.insert(room_centers[i].ind, j)
        table.insert(room_centers[i].dist, lume.distance(room_centers[i].x,room_centers[i].y,room_centers[j].x,room_centers[j].y,true))
      end
    end

  end

  --sorting the distances so the each room center has a sorted list of the rooms closest to it in order of distance 
  --and the indexes of those rooms in the
  
  for i = 1, #room_centers do
    local j = 1
    local unsorted = true 
    while unsorted do
      
      
      if room_centers[i].dist[j] > room_centers[i].dist[j + 1] then

        room_centers[i].dist[j], room_centers[i].dist[j + 1] = room_centers[i].dist[j + 1], room_centers[i].dist[j]
        room_centers[i].ind[j], room_centers[i].ind[j + 1] = room_centers[i].ind[j + 1], room_centers[i].ind[j]
        j = 0
      end
        
      if j == #room_centers[i].dist - 1 then
        unsorted = false
        
      end

      
      j = j + 1
    end

  end


  local mst, totalWeight = minimumSpanningTree(points,distance)

  --debug
  print("MST EDGES ROOM CENTER X1 Y1 to  ROOM CENTER X2 Y2")
  for _, edge in ipairs(mst) do
    local start_cell_x = edge[1][1]
    local start_cell_y = edge[1][2]
    local end_cell_x = edge[2][1]
    local end_cell_y = edge[2][2]

    print(("X1=%d, Y1=%d, X2=%d, Y2=%d"):format(start_cell_x, start_cell_y, end_cell_x, end_cell_y))
  end

  local leafNodes = findLeafNodes(mst)

  -- Print the leaf nodes
  print("Leaf Nodes:")
  for _, node in ipairs(leafNodes) do
      print(("X:%d Y:%d"):format(node[1], node[2])) -- Assuming nodes are 2D points
  end


  --[[
  print(#room_centers)
  --console debug
  for i = 1, #room_centers do
    for j = 1, #room_centers[i].ind do
      print(('Original Index: %d Distance: %d Connected Index: %d'):format(i, room_centers[i].dist[j], room_centers[i].ind[j]))
    end
    print("")
  end
  ]]--

  local tunnels = {}
  
  local myFinder = Pathfinder(Grid(level), 'ASTAR', og_tile)
  --digging the tunnels with the mst
  for _, edge in ipairs(mst) do
    local start_cell_x = edge[1][1]
    local start_cell_y = edge[1][2]
    --for j = 1, path_total do
      
      --local rand = love.math.random(1, #room_centers[i].ind)
      --local smmall_to_large = room_centers[i].ind[j]
      local end_cell_x = edge[2][1]
      local end_cell_y = edge[2][2]
      
      --note this walkable tile is before it gets paved 
      --an empty map starts with all 0s, tunnels and rooms are paved with 2s, and then those 2s are surrounded with 1s

      local walkable_tile = 0

      
      myFinder:setMode('ORTHOGONAL')
      local path = myFinder:getPath(start_cell_x, start_cell_y, end_cell_x, end_cell_y)
      

      
      if path then
        
        --local positions = {}
        --print(path:nodes())
        
        --print(('Path found! Length: %.2f'):format(path:getLength()))
        for node, count in path:nodes() do
          local x_ = node:getX()
          local y_ = node:getY()
          tunnels[tostring(x_)..tostring(y_)] = {x = x_,y = y_} 
          
          --print(('Step: %d - x: %d - y: %d'):format(count, x_, y_))
        end
        
        
        
      end
    --end

  

  

  
  end


  --connectinf the leaf nodes
  --digging the tunnels
  --[[
  for _, node in ipairs(leafNodes) do
    for i = 1, #room_centers do
      if room_centers[i].x == node[1] and room_centers[i].y == node[2] then
        local start_cell_x = room_centers[i].x
        local start_cell_y = room_centers[i].y
        --for j = 1, path_total do
        
        --local rand = love.math.random(1, #room_centers[i].ind)
        local smmall_to_large = room_centers[2].ind[2]
        local end_cell_x = room_centers[smmall_to_large].x
        local end_cell_y = room_centers[smmall_to_large].y
        
        --note this walkable tile is before it gets paved 
        --an empty map starts with all 0s, tunnels and rooms are paved with 2s, and then those 2s are surrounded with 1s

        local walkable_tile = 0

        
        myFinder:setMode('ORTHOGONAL')
        local path = myFinder:getPath(start_cell_x, start_cell_y, end_cell_x, end_cell_y)
        

        
        if path then
          
          --local positions = {}
          --print(path:nodes())
          
          --print(('Path found! Length: %.2f'):format(path:getLength()))
          for node, count in path:nodes() do
            local x_ = node:getX()
            local y_ = node:getY()
            tunnels[tostring(x_)..tostring(y_)] = {x = x_,y = y_} 
            
            --print(('Step: %d - x: %d - y: %d'):format(count, x_, y_))
          end
          
          
          
        end
      end

    

    end

  
  end
  ]]--
  --print(tostring(#tunnels))

  return tunnels



end

function spawn_tunnels_from_BSP(rooms, og_tile)
  --spawns where tunnels are supposed to be between rooms
  room_centers = {}
  for i = 1, #rooms do
    local x = rooms[i].x
    local y = rooms[i].y
    local w = rooms[i].w
    local h = rooms[i].h
    --x, y , index of other rooms, distances of other rooms
    table.insert(room_centers,
    {
    x = lume.round((x + x + w)/2),
    y = lume.round((y + y + h)/2),
    ind = {},
    dist = {}

    })
    
  end
  --filling up the index and distance tables in room_centers
  for i = 1, #room_centers do
    for j = 1, #room_centers do
      if i ~= j then
        table.insert(room_centers[i].ind,j)
        table.insert(room_centers[i].dist,lume.distance(room_centers[i].x,room_centers[i].y,room_centers[j].x,room_centers[j].y,true))
      end
    end

  end
  


  
  --sorting the distances so the each room center has a sorted list of the rooms closest to it in order of distance 
  --and the indexes of those rooms in the
  
  for i = 1, #room_centers do
    local j = 1
    local unsorted = true 
    while unsorted do
      
      
      if room_centers[i].dist[j] > room_centers[i].dist[j + 1] then

        room_centers[i].dist[j], room_centers[i].dist[j + 1] = room_centers[i].dist[j + 1], room_centers[i].dist[j]
        room_centers[i].ind[j], room_centers[i].ind[j + 1] = room_centers[i].ind[j + 1], room_centers[i].ind[j]
        j = 0
      end
        
      if j == #room_centers[i].dist - 1 then
        unsorted = false
        
      end

      
      j = j + 1
    end

  end
  


  --[[
  print(#room_centers)
  --console debug
  for i = 1, #room_centers do
    for j = 1, #room_centers[i].ind do
      print(('Original Index: %d Distance: %d Connected Index: %d'):format(i, room_centers[i].dist[j], room_centers[i].ind[j]))
    end
    print("")
  end
  ]]--

  --how many paths exend from a room, also the highest random number can't be more than the amount of rooms/splits
  local path_total = 3 --love.math.random(1,3)  
  local connected = {}
  local tunnels = {}
  
  local myFinder = Pathfinder(Grid(level), 'ASTAR', og_tile)
  --digging the tunnels
  for i = 1, #room_centers do
    local start_cell_x = room_centers[i].x
    local start_cell_y = room_centers[i].y
    for j = 1, path_total do
      
      local rand = love.math.random(1, #room_centers[i].ind)
      local smmall_to_large = room_centers[i].ind[j]
      local end_cell_x = room_centers[smmall_to_large].x
      local end_cell_y = room_centers[smmall_to_large].y
      
      --note this walkable tile is before it gets paved 
      --an empty map starts with all 0s, tunnels and rooms are paved with 2s, and then those 2s are surrounded with 1s

      local walkable_tile = 0

      
      myFinder:setMode('ORTHOGONAL')
      local path = myFinder:getPath(start_cell_x, start_cell_y, end_cell_x, end_cell_y)
      

      
      if path then
        
        --local positions = {}
        --print(path:nodes())
        
        --print(('Path found! Length: %.2f'):format(path:getLength()))
        for node, count in path:nodes() do
          local x_ = node:getX()
          local y_ = node:getY()
          tunnels[tostring(x_)..tostring(y_)] = {x = x_,y = y_} 
          
          --print(('Step: %d - x: %d - y: %d'):format(count, x_, y_))
        end
        
        
        
      end
    end

  

  

  
  end


  --print(tostring(#tunnels))

  return tunnels
end


function spawn_rooms_from_BSP(areas)
  -- body
  local rooms = {}
  local rng = love.math.newRandomGenerator()
  local plus_minus = {-1,1}
  for i = 1,#areas do

      local rand = love.math.random(0, 100)  
      --local room_w = 0
      --local room_h = 0
      local room_w = lume.round(areas[i][3] * rng:random(50,80)/100) --+ rng:random(1,2) * plus_minus
      local room_h = lume.round(areas[i][4] * rng:random(50,80)/100) --+ rng:random(1,2) * plus_minus

      --getting rid of skinny rooms
      local h_ratio = room_h/room_w
      local w_ratio = room_w/room_h 
      if h_ratio >= 2.3 then
          if room_w < 3 then
              room_w = room_w  -- room_w
          end
          room_h = room_w
      end
      if w_ratio >= 2.3 then
          if room_h < 3 then
              room_h = room_h -- room_h
          end
          room_w = room_h
      end
   
      local room_x = rng:random(areas[i][1] + 1,(areas[i][1] + areas[i][3] - room_w) - 1)
      local room_y = rng:random(areas[i][2] + 1,(areas[i][2] + areas[i][4] - room_h) - 1)

      print(string.format("room = %d , x=%d, y=%d, width=%d, height=%d", i, room_x, room_y, room_w, room_h))

      table.insert(rooms,{
        x = room_x, 
        y = room_y, 
        w = room_w,
        h = room_h})
  

  end

  --spawns boxes in the shape of the rooms
  --[[
  
  ]]--
  return rooms
end

function get_valid_tiles(array_2d,rooms,valid_tile)
  local tiles_valid = {}
  for i = 1, #rooms do
    local x = rooms[i].x
    local y = rooms[i].y
    local w = rooms[i].w
    local h = rooms[i].h
    for row = y, y + h - 1 do
        for col = x, x + w  - 1 do
          if array_2d[row][col] == valid_tile then
            table.insert(tiles_valid,{x = col, y = row})
          end
            
            
        
   
        end
    end
  end
  --[[
  for row = 1, #array_2d do
    for col = 1, #array_2d[row] do
      if array_2d[col][row] == valid_tile then
        table.insert(tiles_valid,{x = col, y = row})
      end
    end
  end]]--
  return tiles_valid 
end



function pave_rooms(rooms,tiletype,array_2d,invalid_neighhbors)
  --local tiles_valid = {}
  local coord_key = ""
  --paving both in a 2d array
  for i = 1, #rooms do
    local x = rooms[i].x
    local y = rooms[i].y
    local w = rooms[i].w
    local h = rooms[i].h
    for row = y, y + h - 1 do
        for col = x , x + w  - 1 do
          --if col > x - 1 and col < x + w and row > y - 1 and row < y + h then
          
            --coord_key = tostring(col)..tostring(row)
            array_2d[row][col] = tiletype
       
            
   
        end
    end


    

  end
  
  --return tiles_valid

end

function pave_tunnels(tunnels,tiletype,array_2d,invalid_neighhbors)
  
  --paving both in a 2d array
  for key, _ in pairs(tunnels) do
    
    array_2d[tunnels[key].y][tunnels[key].x] = tiletype

  end


end
  




function spawn_world_tiles(array_2d,invalid_neighbors,griddy)
  
  print("starting")
  
  local door_coord = {}
  for key, _ in pairs(invalid_neighbors) do
    --if the bottom tile isn't an invalid neighbor then it should be a bottom tile
      if array_2d_bounds(array_2d,invalid_neighbors[key].x + down.x, invalid_neighbors[key].y + down.y) then
        local coord_key = tostring(invalid_neighbors[key].x + down.x)..tostring(invalid_neighbors[key].y + down.y)
        if invalid_neighbors[coord_key] == nil then
          invalid_neighbors[key].qx = 2
          invalid_neighbors[key].qy = 1
        end
      end
      
      --[[
      local t = Tile(
          
      invalid_neighbors[key].x*TILESIZE-TILESIZE,
      invalid_neighbors[key].y*TILESIZE-TILESIZE,
      TILESIZE,
      TILESIZE,
      0,
      tileset_path,
      invalid_neighbors[key].qx,
      invalid_neighbors[key].qy
      )
      ]]--

      table.insert(batch_tiles,{
      x = (invalid_neighbors[key].x - 1) * TILESIZE, 
      y = (invalid_neighbors[key].y - 1) * TILESIZE,
      quad = griddy(invalid_neighbors[key].qx,invalid_neighbors[key].qy)[1]
    })
    
    
  end
  print("done")
 
  
end

function spawn_tiles_world(array_2d, og_tile,walkable_tile,unreachable_tile, griddy)
  for row = 1, #array_2d do
    for col = 1, #array_2d[row] do
      local btx = 0
      local bty = 0
      local btq = nil
      --[[
      if array_2d_bounds(array_2d,col + down.x, row + down.y) then
        if array_2d[row + down.y][col + down.x] == og_tile then
          table.insert(batch_tiles,{
            x = (col - 1) * TILESIZE, 
            y = (row - 1) * TILESIZE,
            quad = griddy(1,1)[1]
          })
        elseif array_2d[row + down.y][col + down.x] == walkable_tile then
            table.insert(batch_tiles,{
              x = (col - 1) * TILESIZE, 
              y = (row - 1) * TILESIZE,
              quad = griddy(2,1)[1]
            })
          end
        end
      end]]--
      --{up, up_right, right, down_right,down, down_left, left, up_left}
     
      local walkable_below = false
      local has_neighbors = false
      for dir = 1, #directions do
        local adjcent_x = col + directions[dir].x
        local adjcent_y = row + directions[dir].y
        
       
        if array_2d_bounds(array_2d,adjcent_x,adjcent_y) then
          
          if dir == 5 then
            if array_2d[adjcent_y][adjcent_x] == walkable_tile 
            and array_2d[row][col] == og_tile  then
              walkable_below = true
            end
          end

          if array_2d[adjcent_y][adjcent_x] == walkable_tile 
          and array_2d[row][col] == og_tile then 
            has_neighbors = true
          end
        

          
        end
      end


      if has_neighbors then
        if walkable_below then
          table.insert(batch_tiles,{
            x = (col - 1) * TILESIZE, 
            y = (row - 1) * TILESIZE,
            quad = griddy(2,1)[1]
          })
        else
          table.insert(batch_tiles,{
            x = (col - 1) * TILESIZE, 
            y = (row - 1) * TILESIZE,
            quad = griddy(1,1)[1]
          })
        end
      
      else
        --[[
        if array_2d[row][col] == walkable_tile then
          table.insert(batch_tiles,{
            x = (col - 1) * TILESIZE, 
            y = (row - 1) * TILESIZE,
            quad = griddy(3,1)[1]
          })
        else
          table.insert(batch_tiles,{
            x = (col - 1) * TILESIZE, 
            y = (row - 1) * TILESIZE,
            quad = griddy(1,1)[1]
          })
        end]]--

      end


    end
  end

end


  
function load_map(array_2d,walkable_tile,unreachable_tile)
  local valid_tiles = {}
    for y = 1,#array_2d do
      for x = 1,#array_2d[y] do
        if array_2d[y][x] == walkable_tile  then
          
          local t = Tile(
         
            x*TILESIZE-TILESIZE,
            y*TILESIZE-TILESIZE,
            TILESIZE,
            TILESIZE,
            0,
            tileset_path,
            0,
            0
            )
          table.insert(valid_tiles,{x = x, y = y})
          table.insert(tiles,t)
        elseif array_2d[y][x] == unreachable_tile  then
          
            local t = Tile(
           
              x*TILESIZE-TILESIZE,
              y*TILESIZE-TILESIZE,
              TILESIZE,
              TILESIZE,
              0,
              tileset_path,
              2,
              3
              )
            
            table.insert(tiles,t)
              
        end
        
      end
    end
    return valid_tiles
end
  
local function old_code(array_2d,y,x)
   --[[
  local up = {x = 0, y = -1}
  local down = {x = 0, y = 1}
  local right = {x = 1, y = 0}
  local left = {x = -1, y = 0}

  local up_right = {x = right.x, y = up.y}
  local down_right = {x = right.x, y = down.y}
  local down_left = {x = left.x, y = down.y}
  local up_left = {x = left.x, y = up.y}
  --North NorthWest East SouthEast South SouthWest West, SouthWest
  local directions = {up, up_right, right, down_right, down, down_left, left, up_left}
  local code_key = ""
 
 
  for dir = 1, #directions do
    local adjcent_x = x_coord + directions[dir].x
    local adjcent_y = y_coord + directions[dir].y
    
    if array_2d_bounds(array_2d,adjcent_x,adjcent_y) then
      
      if array_2d[adjcent_y][adjcent_x] == walkable_tile then
        
        code_key = code_key.."1"
        
        
      else

        array_2d[adjcent_y][adjcent_x] = unreachable_tile
        code_key = code_key.."0"
        break

      end
      
    end

  end
  
  return code_key

        local key_string = "near_"..key_maker(array_2d,x,y,walkable_tile)
        
        --{up, up_right, right, down_right, down, down_left, left, up_left}

      
       --print(key_string)
      --normal length
      if current_tileset_keys[key_string] ~= nil then 
          --the equivalent of down in the string
          --basically means down is walkable_tile
      
      
           
          local t = Tile(
                
            x*TILESIZE-TILESIZE,
            y*TILESIZE-TILESIZE,
            TILESIZE,
            TILESIZE,
            0,
            tileset_path,
            current_tileset_keys[key_string].col,
            current_tileset_keys[key_string].row
            )
          table.insert(tiles,t)
           
          if current_tileset_keys[key_string].col == 1
          or current_tileset_keys[key_string].col == 2
          and current_tileset_keys[key_string].row == 1
          then
            array_2d[y][x] = unreachable_tile
    
          end
          
        else 
          local t = Tile(
                
            x*TILESIZE-TILESIZE,
            y*TILESIZE-TILESIZE,
            TILESIZE,
            TILESIZE,
            0,
            tileset_path,
            1,
            1
            )
            table.insert(tiles,t)
        end]]--

  --[[
    local current_tileset_keys = {
    --CAUTION: THIS AUTOTILING IS TILESET SPECIFIC AND SHOULD BE CHANGED IN THE INSTANCE OF A NEW ONE
    --The cols and rows that are pointed to are vaible to change based on tileset_path

    --adjecency matrix in the for of xy,xy.... of the above directions
    --recording them will allow a tile to be picked from an image 
    --based the direction of the bordertile in relation to the current tile

    --this is equivalent toa single tile, surrounded by 8 walkable tiles in all directions
    --and points to column 2 row 1 of the image
    --{up, up_right, right, down_right, down, down_left, left, up_left}
    --1s are hits, meaning walkable tiles, 2s are everything else
    ["near_11111111"] = {col = 2, row = 1},
    --this is a tile with no walkable neighbors
    ["near_00000000"] = {col = 3, row = 1},
    --plus_sign
    ["near_01010101"] = {col = 1, row = 1},

    --vertical single strip
    --top
    
    ["near_11110111"] = {col = 1, row = 1},
    --middle
   
    ["near_01110111"] = {col = 1, row = 1},
    --down
    
    ["near_01111111"] = {col = 2, row = 1},

    --horizontal single strip
    --right
    
    ["near_11111101"] = {col = 2, row = 1},
    --middle
    
    ["near_11011101"] = {col = 2, row = 1},
    --left
    
    ["near_11011111"] = {col = 2, row = 1},

    --square edges
    --{up, up_right, right, down_right, down, down_left, left, up_left}
    ["near_01111101"] = {col = 2, row = 1},
    ["near_11010111"] = {col = 1, row = 1},
    ["near_11110101"] = {col = 1, row = 1},
    ["near_01011111"] = {col = 2, row = 1},

    --four block
    ["near_00011111"] = {col = 2, row = 1},
    ["near_11110001"] = {col = 1, row = 1},
    ["near_01111100"] = {col = 2, row = 1},
    ["near_11000111"] = {col = 1, row = 1},

    --the L spin shapes
    ["near_00111111"] = {col = 2, row = 1},
    ["near_11110011"] = {col = 1, row = 1},
    ["near_11111100"] = {col = 2, row = 1},
    ["near_11001111"] = {col = 2, row = 1},

    --six block
    ["near_00011100"] = {col = 2, row = 1},
    ["near_11000001"] = {col = 1, row = 1},
    ["near_01110000"] = {col = 1, row = 1},
    ["near_00000111"] = {col = 1, row = 1},

    --T spin
    ["near_01011101"] = {col = 2, row = 1},
    ["near_11010101"] = {col = 1, row = 1},
    ["near_01110101"] = {col = 1, row = 1},
    ["near_01010111"] = {col = 1, row = 1},

    --array edge 
    --top left,top right, bottom left, and bottom right all 
    --observe 3 tiles
    --{up, up_right, right, down_right, down, down_left, left, up_left}
    --top left has {right, down_right, down)
    --top right has {down,down_left, left}
    --bottom right has {up,left,up_left}
 
    ["near_111"] = {col = 2, row = 1},
    ["near_110"] = {col = 2, row = 1},
    ["near_101"] = {col = 2, row = 1},
    ["near_011"] = {col = 2, row = 1},
    ["near_100"] = {col = 2, row = 1},
    ["near_010"] = {col = 2, row = 1},
    ["near_001"] = {col = 2, row = 1},
    ["near_000"] = {col = 2, row = 1},


  
  ]]--
end
  