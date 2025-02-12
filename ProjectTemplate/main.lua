require "maps.testmap2"
require "tile"
require "player"


--local libraries
--scene manager


--Global libraries
Vector2 = require "lib.hump.vector"
lume = require 'lib.lume'
flux = require 'lib.flux'
gamera = require "lib.gamera"
camera = require "lib.hump.camera"


--camera setip
--gam = gamera.new(0,0,100,100)
CAMERA_ZOOM = 3
cam =  camera()
cam:zoom(CAMERA_ZOOM)

--images
local tileset_path = "assets/stonetileset.png"
local player_image_path = "assets/toledo.png"

--Global Constants
TILESIZE = 16
SCREEN_WIDTH = love.graphics.getWidth()
SCREEN_HEIGHT = love.graphics.getHeight()
LEVEL = map_tiles
LEVEL_WIDTH = #map_tiles[1]
LEVEL_HEIGHT = #map_tiles
WORLD_LEVEL_WIDTH = LEVEL_WIDTH * TILESIZE
WORLD_LEVEL_HEIGHT = LEVEL_HEIGHT * TILESIZE

--Global groups for objects
tiles = {}
protag = {}

love.graphics.setDefaultFilter("nearest", "nearest")

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


function debug_statements()
  local num = ""
  if #protag > 0 then
    
    

    love.graphics.setColor(1, 0, 0)

    num = ("CAMX: %.2f"):format(((cam.x)))
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

        
    local boxx = math.floor((protag[1].mx/WORLD_LEVEL_WIDTH) * LEVEL_WIDTH) + 1
    local boxy = math.floor((protag[1].my/WORLD_LEVEL_HEIGHT) * LEVEL_HEIGHT) + 1
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

    local ax = lume.round(((protag[1].position.x/WORLD_LEVEL_WIDTH) * LEVEL_WIDTH)) + 1
    num = ("AX: %.2f"):format(ax)
    love.graphics.print(num,
          10,
          90)

    local ay =  lume.round(((protag[1].position.y/WORLD_LEVEL_HEIGHT) * LEVEL_HEIGHT)) + 1
    num = ("AY: %.2f"):format(ay)
    love.graphics.print(num,
          10,
          100)
          
    --num = ("Val: %.2f"):format(LEVEL[ay][ax])
    --[[love.graphics.print(num,
          10,
          130)]]--
    

    num = ("zoom: %.2f"):format(CAMERA_ZOOM)
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

    num = protag[1].angle_convert:radians_to_degrees(Vector2(protag[1].mx,protag[1].my):angleTo(protag[1].position + protag[1].dimension * 0.5))
    num = "Mouse Angle: " .. tostring(protag[1].angle)
    love.graphics.print(num,
          10,
          150)

    num = protag[1].velocity.x
    num = "velocity x: " .. tostring(num)
    love.graphics.print(num,
          10,
          160)

    num = protag[1].velocity.y
    num = "velocity y: " .. tostring(num)
    love.graphics.print(num,
          10,
          170)

    num = protag[1].last_y 
    num = "Last Y: " .. tostring(num)
    love.graphics.print(num,
          10,
          180)

    num = protag[1].grounded
    num = "Ground: " .. tostring(num)
    love.graphics.print(num,
          10,
          190)

          
    

    love.graphics.setColor(1, 1, 1)
  
  end
end

function love.wheelmoved(x, y)
  if #protag > 0 then
    --if protag[1].button_tile_input or protag[1].mouse_tile_input then 
      local temp = {x = CAMERA_ZOOM}
      local max_zoom = 10
      local min_zoom = 1
      local zoom_dir = 0
      local zoom_speed = 20
      if y > 0 then
        --up
          CAMERA_ZOOM = CAMERA_ZOOM + zoom_speed * protag[1].delta_time
        
      elseif y < 0 then
        --down
          CAMERA_ZOOM = CAMERA_ZOOM - zoom_speed * protag[1].delta_time
        
        
      end
      --flux.to(, .5, { x = CAMERA_ZOOM }):ease("circout"):delay(1)
      CAMERA_ZOOM = lume.clamp(CAMERA_ZOOM,min_zoom,max_zoom)
      
      --if CAMERA_ZOOM <= max_zoom and CAMERA_ZOOM >= min_zoom then
        --flux.to(temp, 0.2, {x = CAMERA_ZOOM})
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
    display(LEVEL)
  end
end

function love.load()
  
  --basic_quad =  love.graphics.newQuad(0,1,16,16,tileset)
  load_map(map_tiles)
  if #protag > 0 then
    --protag[1].map_reference = map_tiles
  end

  if #protag == 0 then
    
    cam:lookAt((LEVEL_WIDTH*CAMERA_ZOOM)/2,(LEVEL_HEIGHT*CAMERA_ZOOM)/2)
  end
  --gam:setWorld(0,0,WORLD_LEVEL_WIDTH,WORLD_LEVEL_HEIGHT)
end

function love.update(dt)
  


  if #protag > 0 then
    
    --local bx,by = cam:cameraCoords(SCREEN_WIDTH/4,SCREEN_HEIGHT/4)
    --local bw,bh = cam:cameraCoords(LEVEL_WIDTH,LEVEL_HEIGHT) 
    --cam.x = lume.lamp(cam.x,bx,bw)
    --cam.y = lume.clamp(cam.y,by,bh)
    
    protag[1]:update(dt)
    

  end
  
end



function love.draw()
  
  
  cam:attach()
  --gam:draw(function ()
    


    love.graphics.circle("line",cam.x,cam.y,6)
    if #protag > 0 then
      
      protag[1]:draw()

    end
    
    for i,v in ipairs(tiles) do
      
      v:draw()
         
    end


  --end
  cam:detach()


  --debug
  debug_statements()
  
end