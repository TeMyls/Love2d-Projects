require "maps.testmap2"
require "tile"
require "player"

local bump = require 'lib.bump'
world = bump.newWorld()
lume = require 'lib.lume'
flux = require 'lib.flux'
Grid = require ("lib.jumper.grid")
Pathfinder = require ("lib.jumper.pathfinder")

tileset_path = "assets/stonetileset.png"
player_image_path = "assets/toledo.png"
TILESIZE = 16


screen_width = love.graphics.getWidth()
screen_height = love.graphics.getHeight()
level = map_tiles
level_width = #map_tiles[1]
level_height = #map_tiles

true_tile_size = TILESIZE
true_level_width = level_width * true_tile_size
true_level_height = level_height * true_tile_size




love.graphics.setDefaultFilter("nearest", "nearest")

camera_zoom_factor = 3
--json = require "lib/json"
local gamera = require "lib.gamera"
local camera = require "lib.hump.camera"
--gam = gamera.new(0,0,100,100)
cam =  camera()
cam:zoom(camera_zoom_factor)
require "unitconverter"





view_box = {
  b1 = 0,
  b2 = 0
  }
tiles = {}
p_attack = {}
protag = {}

turn_stack = {}


function auto_tile(array_2d,y,x)
  
end

function display(array2d)
  local s = ""
  for y = 1, #array2d do
      s = s.."["
      for x = 1, #array2d[y] do
          s = s.." "..tostring(array2d[y][x])..", "
      end
      s = s.."]".."\n"
  end
  print(s)
end

function AABB_collision(a, b)
  return a.x < b.x + b.w --is the left of 'a' less than the right of 'b'
  and b.x < a.x + a.w  -- is the right of 'a' greater than the left of 'b'
  and a.y < b.y + b.h  -- is the top of 'a' less than the bottom of 'b'
  and b.y  < a.y + a.w -- is the bottom of 'a' greater than the top of 'b'   
end

function mouse_AABB_collision(mx, my, b)
  return mx < b.x + b.w --is the left of 'a' less than the right of 'b'
  and b.x < mx  -- is the right of 'a' greater than the left of 'b'
  and my < b.y + b.h  -- is the top of 'a' less than the bottom of 'b'
  and b.y  < a.y + a.w -- is the bottom of 'a' greater than the top of 'b'   
end


function load_map(array_2d)
  for y = 1,#array_2d do
    for x = 1,#array_2d[y] do
      if array_2d[y][x] == 1  then
        local positions = {x = x*TILESIZE-TILESIZE, y = y*TILESIZE-TILESIZE}
        local dimesions = {w = TILESIZE, h = TILESIZE}
        local t = Tile(
          positions,
          dimesions,
          0,
          tileset_path,
          0,
          0,
          true,
          tiles
          )
        
        --table.insert(tiles,t)
      elseif array_2d[y][x] == 9 then
        local positions = {x = x*TILESIZE-TILESIZE, y = y*TILESIZE-TILESIZE}
        local dimesions = {w = TILESIZE, h = TILESIZE}
        local t = Player(
          positions,
          dimesions,
          10,
          nil,
          0,
          0,
          true,
          protag
        )
        --table.insert(protag,t)
        array_2d[y][x] = 0
      end
      
    end
  end
end

function love.wheelmoved(x, y)
  if #protag > 0 then
    --if protag[1].button_tile_input or protag[1].mouse_tile_input then 
      local temp = {x = camera_zoom_factor}
      local max_zoom = 10
      local min_zoom = 1
      local zoom_dir = 0
      local zoom_speed = 20
      if y > 0 then
        --up
          camera_zoom_factor = camera_zoom_factor + zoom_speed * protag[1].delta_time
        
      elseif y < 0 then
        --down
          camera_zoom_factor = camera_zoom_factor - zoom_speed * protag[1].delta_time
        
        
      end
      --flux.to(, .5, { x = camera_zoom_factor }):ease("circout"):delay(1)
      camera_zoom_factor = lume.clamp(camera_zoom_factor,min_zoom,max_zoom)
      
      --if camera_zoom_factor <= max_zoom and camera_zoom_factor >= min_zoom then
        --flux.to(temp, 0.2, {x = camera_zoom_factor})
      --end
      cam:zoomTo(temp.x)
      --gam:setScale(temp.x)
    --end
  end
end

function love.mousepressed(x, y, button, istouch)
  if #protag > 0 then
    if #protag[1].tile_path > 0 then 
      protag[1].canceled_path = true
    end
  end

end

function love.keypressed(key, scancode, isrepeat)
  if key == "space" then
    display(level)
  end
end

function love.load()
  
  --basic_quad =  love.graphics.newQuad(0,1,16,16,tileset)
  load_map(map_tiles)
  if #protag > 0 then
    --protag[1].map_reference = map_tiles
  end

  if #protag == 0 then
    
    cam:lookAt((level_width*zoom_factor)/2,(level_height*zoom_factor)/2)
  end
  --gam:setWorld(0,0,true_level_width,true_level_height)
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





function love.draw()
  --love.graphics.draw(tileset,basic_quad)
  --love.graphics.rectangle("line",10,10,100,10)
  local num = ""
  
  cam:attach()
  --gam:draw(function ()
    
    
    
    --love.graphics.scale(scale_factor)
    
    love.graphics.circle("line",cam.x,cam.y,6)
    if #protag > 0 then
      
  
      --((p.x + p.w/2)*scale_factor)%(SW*scale_factor)
      
      
      
      --p:display("line")
      protag[1]:draw()
    end
    
    for i,v in ipairs(tiles) do
      --love.graphics.setColor(1, 0, 0)
      v:draw()
         
    end
  --end
  cam:detach()
  --debug
  if #protag > 0 then
    
    

    love.graphics.setColor(1, 0, 0)

    local num = ("CAMX: %.2f"):format(((cam.x)))
    love.graphics.print(num,
          10,
          10)
        
    num = ("CAMY: %.2f"):format(((cam.y)))
    love.graphics.print(num,
          10,
          20)
          
    num = ("X: %.2f"):format((protag[1].position.x))--.x+protag[1].w)/2)
    love.graphics.print(num,
          10,
          30)
        
    num = ("Y: %.2f"):format((protag[1].position.y))--.y+protag[1].h)/2)
    love.graphics.print(num,
          10,
          40)

        
    local boxx = math.floor((protag[1].mx/true_level_width) * level_width) + 1
    local boxy = math.floor((protag[1].my/true_level_height) * level_height) + 1
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

    local ax = lume.round(((protag[1].position.x/true_level_width) * level_width)) + 1
    num = ("AX: %.2f"):format(ax)
    love.graphics.print(num,
          10,
          90)

    local ay =  lume.round(((protag[1].position.y/true_level_height) * level_height)) + 1
    num = ("AY: %.2f"):format(ay)
    love.graphics.print(num,
          10,
          100)
          
    --num = ("Val: %.2f"):format(level[ay][ax])
    --[[love.graphics.print(num,
          10,
          130)]]--
    

    num = ("zoom: %.2f"):format(camera_zoom_factor)
    love.graphics.print(num,
          10,
          110)

    num = "Tweening: " .. tostring(protag[1].is_tweening)
    love.graphics.print(num,
          10,
          120)

    num = "Path Canceled: " .. tostring(protag[1].canceled_path)
    love.graphics.print(num,
          10,
          140)

    num = radians_to_degrees(Vector2(protag[1].mx,protag[1].my):angleTo(protag[1].position + protag[1].dimension * 0.5))
    num = "Mouse Angle: " .. tostring(protag[1].angle)
    love.graphics.print(num,
          10,
          150)

    num = protag[1].velocity
    num = "velocity: " .. tostring(num)
    love.graphics.print(num,
          10,
          160)

    

    love.graphics.setColor(1, 1, 1)
  
  end
  
end