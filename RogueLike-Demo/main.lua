require "maps.testmap2"
require "tile"
require "player"
require "generator"
require "unitconverter"

local bump = require 'lib.bump'
local anim8 = require "lib.anim8"
world = bump.newWorld()

lume = require 'lib.lume'
flux = require 'lib.flux'
Grid = require ("lib.jumper.grid")
Pathfinder = require ("lib.jumper.pathfinder")
--"assets/stonetileset.png"
--
tileset_path = "assets/tiles.png"
the_tile_image = love.graphics.newImage(tileset_path)



player_image_path = "assets/toledo.png"
TILESIZE = 32


screen_width = love.graphics.getWidth()
screen_height = love.graphics.getHeight()
level = map_tiles
level_width = #map_tiles[1]
level_height = #map_tiles

true_tile_size = TILESIZE
true_level_width = level_width * true_tile_size
true_level_height = level_height * true_tile_size
local tile




love.graphics.setDefaultFilter("nearest", "nearest")

camera_zoom_factor = 3
--json = require "lib/json"
local gamera = require "lib.gamera"
local camera = require "lib.hump.camera"
cam =  camera()
gam = gamera.new(0,0,100,100)
cam:zoom(camera_zoom_factor)






view_box = {
  b1 = 0,
  b2 = 0
  }
tiles = {}

batch_tiles = {}
local tile_sprite_batch 
p_attack = {}
protag = {}

turn_stack = {}

function display_BSP()
      local splits = 4

      level = map_maker(30,30,0)
      level_width = #level[1]
      level_height = #level
      
      true_tile_size = TILESIZE
      true_level_width = level_width * true_tile_size
      true_level_height = level_height * true_tile_size
      
      tile_sprite_batch = love.graphics.newSpriteBatch(love.graphics.newImage(tileset_path))
      tilesheet_grid = anim8.newGrid(TILESIZE,TILESIZE,the_tile_image:getWidth(),the_tile_image:getHeight(),0,0,0)

      print(level_width)
      print(level_height)
      local areas = BSP(level, splits)
      BSP_display(areas,level,2,tilesheet_grid)
end

function make_floor(map_width,map_height,room_num)
      local splits = room_num
      local og_tile = 0
      local walkable_tile = 2
      local unreachable_tile = 0
      local tunnel_room_walls = {}
      tile_sprite_batch = love.graphics.newSpriteBatch(love.graphics.newImage(tileset_path))
      tilesheet_grid = anim8.newGrid(TILESIZE,TILESIZE,the_tile_image:getWidth(),the_tile_image:getHeight(),0,0,0)
      level = map_maker(map_height,map_width,og_tile)
      level_width = #level[1]
      level_height = #level
      
      true_tile_size = TILESIZE
      true_level_width = level_width * true_tile_size
      true_level_height = level_height * true_tile_size
      
      --print(level_width)
      --print(level_height)
      
      local areas = BSP(level, splits)

      
      local rooms = spawn_rooms_from_BSP(areas)
      local tunnels = spawn_tunnels_from_BSP_MST(rooms, og_tile)
      --[[
      for key, _ in pairs(tunnels) do
            print((('tunnel x: %d - tunnel y: %d')):format(tunnels[key].x,tunnels[key].y))

      end
        ]]--
      

      pave_rooms(rooms,walkable_tile,level,tunnel_room_walls)
      pave_tunnels(tunnels,walkable_tile,level, tunnel_room_walls)
      
      
      
      
      spawn_tiles_world(level,og_tile,walkable_tile,unreachable_tile,tilesheet_grid)
      --spawn_world_tiles(level,tunnel_room_walls,tilesheet_grid)
      --local valid_tiles = spawn_world_tiles(level,walkable_tile,unreachable_tile)

      

      
      return areas, rooms, tunnels
end



function love.load()
      local a = love.timer.getTime()
      love.math.setRandomSeed(a)



      local areas, rooms, tunnels = make_floor(30,30,4)
      local rand_room = rooms[love.math.random(1,#rooms)]
      local rand_room_x = love.math.random(rand_room.x,rand_room.x + rand_room.w - 1)
      local rand_room_y = love.math.random(rand_room.y,rand_room.y + rand_room.h - 1)




      local t = Player(
            
                  (rand_room_x) * TILESIZE,
                  (rand_room_y) * TILESIZE,
                  TILESIZE,
                  TILESIZE,
                  10,
                  nil,
                  0,
                  0
            )
      print(rand_room_x," ",rand_room_y)
      table.insert(protag,t)
      console_array2d_print(level)
      --display_BSP()
      --print(tostring(level_width), " ",tostring(level_height))

      table.insert(protag,t)
      gam:setWorld(0,0,true_level_width,true_level_height)
      --load_map(map_tiles)
end


function love.keypressed(key)
      if key == "space" then
            console_array2d_print(level)
      end
      
end

function love.update(dt)
  
  if #protag > 0 then
    
    --local bx,by = cam:cameraCoords(screen_width/4,screen_height/4)
    --local bw,bh = cam:cameraCoords(level_width,level_height) 
    
    
    --cam.x = clamp(cam.x,bx,bw)
    --cam.y = clamp(cam.y,by,bh)
    
    protag[1]:update(dt)
    

  end
  
end


function debug_statements(player_arr_index)
      love.graphics.setColor(1, 0, 0)
      local num = 0
      --[[
      local num = ("CAMX: %.2f"):format(((cam.x)))
      love.graphics.print(num,
            10,
            10)
            
      num = ("CAMY: %.2f"):format(((cam.y)))
      love.graphics.print(num,
            10,
            20)
            ]]--
      num = ("X: %.2f"):format((player_arr_index.x))--.x+protag[1].w)/2)
      love.graphics.print(num,
            10,
            30)
            
      num = ("Y: %.2f"):format((player_arr_index.y))--.y+protag[1].h)/2)
      love.graphics.print(num,
            10,
            40)

            
      local boxx = math.floor((player_arr_index.mx/true_level_width) * level_width) + 1
      local boxy = math.floor((player_arr_index.my/true_level_height) * level_height) + 1
      num = ("MX: %.2f"):format(boxx)
      love.graphics.print(num,
            10,
            50)
            
      num = ("MY: %.2f"):format(boxy)
      love.graphics.print(num,
            10,
            60)
            
      num = ("CAMX: %.2f"):format(((cam.x)))
      love.graphics.print(num,
            10,
            10)
            
      num = ("CAMY: %.2f"):format(((cam.y)))
      
      love.graphics.print(num,
            10,
            20)
            
      num = ("FPS: %.2f"):format(((love.timer.getFPS())))
      love.graphics.print(num,
            10,
            70)

      local ax = lume.round(((player_arr_index.x/true_level_width) * level_width)) + 1
      local amx = lume.round(((player_arr_index.mx/true_level_width) * level_width)) + 1
      num = ("AX: %.2f"):format(ax)
      love.graphics.print(num,
            10,
            90)

      local ay =  lume.round(((player_arr_index.y/true_level_height) * level_height)) + 1
      local amy = lume.round(((player_arr_index.my/true_level_width) * level_width)) + 1
      num = ("AY: %.2f"):format(ay)
      love.graphics.print(num,
            10,
            100)
            
      num = ("Val: %.2f"):format(level[ay][ax])
      love.graphics.print(num,
            10,
            130)
--[[
      num = ("Mouse Val: %.2f"):format(level[amy][amx])
      love.graphics.print(num,
            10,
            170)
      
            
      num = ("zoom: %.2f"):format(camera_zoom_factor)
      love.graphics.print(num,
            10,
            110)]]--
      num = ("zoom: %.2f"):format(camera_zoom_factor)
      love.graphics.print(num,
            10,
            110)

      num = "Tweening: " .. tostring(player_arr_index.is_tweening)
      love.graphics.print(num,
            10,
            120)

      num = "Path Canceled: " .. tostring(player_arr_index.canceled_path)
      love.graphics.print(num,
            10,
            140)
      num = "LH: " .. tostring(true_level_height)
      love.graphics.print(num,
            10,
            150)

      num = "LW: " .. tostring(true_level_width)
      love.graphics.print(num,
            10,
            160)

      

      love.graphics.setColor(1, 1, 1)
end


function love.draw()
  --love.graphics.draw(tileset,basic_quad)
  --love.graphics.rectangle("line",10,10,100,10)
  local num = ""
  
  --cam:attach()
  gam:draw(function ()
--love.graphics.scale(scale_factor)
    
    --love.graphics.circle("line",cam.x,cam.y,6)
    
    
    tile_sprite_batch:clear(batch_tiles)
      for i, v in ipairs(batch_tiles) do
            local cx,cy,cw,ch = gam:getVisible()
            if batch_tiles[i].x  < cx + cw + TILESIZE
            and cx - TILESIZE < batch_tiles[i].x + TILESIZE
            and batch_tiles[i].y < cy + ch + TILESIZE
            and cy - TILESIZE< batch_tiles[i].y + TILESIZE then
                  tile_sprite_batch:add(batch_tiles[i].quad, batch_tiles[i].x , batch_tiles[i].y - 1)
            end
      end
	-- Finally, draw the sprite batch to the screen.
      love.graphics.draw(tile_sprite_batch)
      
      if #protag > 0 then
      
  
            --((p.x + p.w/2)*scale_factor)%(SW*scale_factor)
            
            
            
            --p:display("line")
            protag[1]:draw()
          end
      --[[
    for i,v in ipairs(tiles) do
      v:draw()

      --love.graphics.setColor(1, 0, 0)
      
      
      --ooculsion culling tiles 
      if v.x  < cx + cw + TILESIZE
      and cx - TILESIZE < v.x + v.w
      and v.y < cy + ch + TILESIZE
      and cy - TILESIZE< v.y + v.h then
            v:draw()
      end
      
         
    end
    ]]--
  end)
    
    
    
    
  --cam:detach()
  --debug
  if #protag > 0 then
    debug_statements(protag[1])
    

      
  
  end
  
end