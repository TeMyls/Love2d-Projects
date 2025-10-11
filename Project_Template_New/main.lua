require "maps.testmap"
require "tile"
require "player"


--Global libraries
Gamestate = require "lib.hump.gamestate"
Vector2 = require "lib.hump.vector"
Camera = require "lib.hump.camera"

Gamera = require "lib.gamera"
lume = require 'lib.lume'
flux = require 'lib.flux'


--Camera setip
--gam = gamera.new(0,0,100,100)
CAMERA_ZOOM = 3
CAM =  Camera()
CAM:zoom(CAMERA_ZOOM)


--Global Constants
TILESIZE = 16
SCREEN_WIDTH = love.graphics.getWidth()
SCREEN_HEIGHT = love.graphics.getHeight()
LEVEL = map_tiles
LEVEL_WIDTH = #map_tiles[1]
LEVEL_HEIGHT = #map_tiles
WORLD_LEVEL_WIDTH = LEVEL_WIDTH * TILESIZE
WORLD_LEVEL_HEIGHT = LEVEL_HEIGHT * TILESIZE
CIRCLE_ARENA = {fill = "line", x = 0, y=0, r = 500}

--Global groups for objects
Tiles = {}
Protag = {}
Projectiles = {}
Enemies = {}

--scenes
local menu = {}
local paused = {}
local game = {}

--images
local tileset_path = "assets/pc.png"
local player_image_path = "assets/pc.png"

local r, g, b = love.math.colorFromBytes(172, 170, 189)
love.graphics.setBackgroundColor(r, g, b)
love.graphics.setDefaultFilter("nearest", "nearest")

function menu:draw()
  love.graphics.print("Press Enter to continue\nSpace to Pause in Game",  SCREEN_WIDTH/2, SCREEN_HEIGHT/2)
end

function menu:update()
  
end

function menu:keyreleased(key, code)
  if key == 'return' then
      Gamestate.switch(game)
  end
end

function paused:draw()
  love.graphics.print("Paused\nBackspace to Menu\nAny to continue", SCREEN_WIDTH/2, SCREEN_HEIGHT/2)
end

function paused:update()
  
end

function paused:keypressed(key, code)
  if key == "return" then
    Gamestate.switch(game)
  end
  
  if key == "backspace" then
    Gamestate.switch(menu)
  end
  
end

function game:display(array2d)
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

function game:init()
  --basic_quad =  love.graphics.newQuad(0,1,16,16,tileset)
  
  map_tiles = game:create_2D_array(10, 10, 0)
  game:display(map_tiles)
  map_tiles = game:add_2D_array_walls(map_tiles, 1)
  game:display(map_tiles)
  game:load_map(map_tiles)
  if #Protag == 0 then
    --P[1].map_reference = map_tiles
    game:place_player(map_tiles)
  end
  game:load_map(map_tiles)
  if #Protag == 0 then
    
    CAM:lookAt((LEVEL_WIDTH*CAMERA_ZOOM)/2,(LEVEL_HEIGHT*CAMERA_ZOOM)/2)
  end
  --gam:setWorld(0,0,WORLD_LEVEL_WIDTH,WORLD_LEVEL_HEIGHT)
end

function game:place_player(array_2d)
  local lx = love.math.random(2, #array_2d[1] - 1)
  local ly = love.math.random(2, #array_2d - 1)


  local positions = { 
                      x = lx * TILESIZE-TILESIZE, 
                      y = ly * TILESIZE-TILESIZE
                    }
  print(("Map Width: %d Map Height: %d\nPlayer X: %d Player: %d \nLevel X: %d Level Y: %d \n"):format(
                                                                        #array_2d[1], #array_2d,
                                                                        positions.x, positions.y,
                                                                        lx, ly
                                                                      ))
  local dimesions = {w = TILESIZE, h = TILESIZE}
  local t = Player(
        positions,
        dimesions,
        10,
        player_image_path,
        0 ,
        0 ,
        true,
        Protag
      )
end

function game:enter()
    
end

function game:create_2D_array(width, height, filler)
  local array_2d = {}

  for y = 1, height do
    table.insert( array_2d, {})
    for x = 1, width do
      table.insert( array_2d[y], filler)
    end
  end

  return array_2d
end

function game:add_2D_array_walls(array_2d, wall_filler)
  --vertical walls

  local y = 1
  while y <= #array_2d do
    array_2d[y][1] = wall_filler
    array_2d[y][#array_2d[y]] = wall_filler
    y = y + 1
  end

  --horizontal walls
  local x = 1
  while x <= #array_2d do
    array_2d[1][x] = wall_filler
    array_2d[#array_2d][x] = wall_filler
    x = x + 1
  end
  return array_2d
end

function game:wave_function_collapse(array_2d)

end

function game:load_map(array_2d)
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
          3 * TILESIZE,
          8 * TILESIZE,
          false,
          Tiles
          )
        
        --table.insert(Tiles,t)
      elseif array_2d[y][x] == 9 then
        local positions = {x = x*TILESIZE-TILESIZE, y = y*TILESIZE-TILESIZE}
        local dimesions = {w = TILESIZE, h = TILESIZE}
        local t = Player(
          positions,
          dimesions,
          10,
          player_image_path,
          0 * TILESIZE,
          0 * TILESIZE,
          true,
          Protag
        )
        --table.insert(P,t)
        array_2d[y][x] = 0
      end
      
    end
  end
end


function game:debug_statements()
  local num = ""
  if #Protag > 0 then
    
    

    love.graphics.setColor(1, 0, 0)

    num = ("CAMX: %.2f"):format(((CAM.x)))
    love.graphics.print(num,
          10,
          10)
        
    num = ("CAMY: %.2f"):format(((CAM.y)))
    love.graphics.print(num,
          10,
          20)
          
    num = ("X: %.2f"):format((Protag[1].position.x))--.x+P[1].w)/2)
    love.graphics.print(num,
          10,
          30)
        
    num = ("Y: %.2f"):format((Protag[1].position.y))--.y+P[1].h)/2)
    love.graphics.print(num,
          10,
          40)

        
    local boxx = math.floor((Protag[1].mx/WORLD_LEVEL_WIDTH) * LEVEL_WIDTH) + 1
    local boxy = math.floor((Protag[1].my/WORLD_LEVEL_HEIGHT) * LEVEL_HEIGHT) + 1
    num = ("MX: %.2f"):format(boxx)
    love.graphics.print(num,
          10,
          50)
        
    num = ("MY: %.2f"):format(boxy)
    love.graphics.print(num,
          10,
          60)
        
    num = ("CAMX: %.2f"):format(((CAM.x)))
    love.graphics.print(num,
          10,
          10)
        
    num = ("CAMY: %.2f"):format(((CAM.y)))
    
    love.graphics.print(num,
          10,
          20)
        
    num = ("FPS: %.2f"):format(((love.timer.getFPS())))
    love.graphics.print(num,
          10,
          70)

    local ax = lume.round(((Protag[1].position.x/WORLD_LEVEL_WIDTH) * LEVEL_WIDTH)) + 1
    num = ("AX: %.2f"):format(ax)
    love.graphics.print(num,
          10,
          90)

    local ay =  lume.round(((Protag[1].position.y/WORLD_LEVEL_HEIGHT) * LEVEL_HEIGHT)) + 1
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

    num = "Tweening: " .. tostring(Protag[1].is_tweening)
    love.graphics.print(num,
          10,
          120)

    num = "Path Canceled: " .. tostring(Protag[1].canceled_path)
    love.graphics.print(num,
          10,
          140)

    num = Protag[1].angle_convert:radians_to_degrees(Vector2(Protag[1].mx,Protag[1].my):angleTo(Protag[1].position + Protag[1].dimension * 0.5))
    num = "Mouse Angle: " .. tostring(Protag[1].angle)
    love.graphics.print(num,
          10,
          150)

    num = Protag[1].velocity.x
    num = "velocity x: " .. tostring(num)
    love.graphics.print(num,
          10,
          160)

    num = Protag[1].velocity.y
    num = "velocity y: " .. tostring(num)
    love.graphics.print(num,
          10,
          170)

    num = Protag[1].last_y 
    num = "Last Y: " .. tostring(num)
    love.graphics.print(num,
          10,
          180)

    num = Protag[1].grounded
    num = "Ground: " .. tostring(num)
    love.graphics.print(num,
          10,
          190)


    num = Protag[1].state
    num = "State: " .. num
    love.graphics.print(num,
          10,
          200)

          
    

    love.graphics.setColor(1, 1, 1)
  
  end
end

function game:wheelmoved(x, y)
  if #Protag > 0 then
    --if P[1].button_tile_input or P[1].mouse_tile_input then 
      local temp = {x = CAMERA_ZOOM}
      local max_zoom = 10
      local min_zoom = 1
      local zoom_dir = 0
      local zoom_speed = 20
      if y > 0 then
        --up
          CAMERA_ZOOM = CAMERA_ZOOM + zoom_speed * Protag[1].delta_time
        
      elseif y < 0 then
        --down
          CAMERA_ZOOM = CAMERA_ZOOM - zoom_speed * Protag[1].delta_time
        
        
      end
      --flux.to(, .5, { x = CAMERA_ZOOM }):ease("circout"):delay(1)
      CAMERA_ZOOM = lume.clamp(CAMERA_ZOOM,min_zoom,max_zoom)
      
      --if CAMERA_ZOOM <= max_zoom and CAMERA_ZOOM >= min_zoom then
        --flux.to(temp, 0.2, {x = CAMERA_ZOOM})
      --end
      CAM:zoomTo(temp.x)
      --gam:setScale(temp.x)
    --end
  end
end

function game:mousepressed(x, y, button, istouch)
  if #Protag > 0 then
    if #Protag[1].tile_path > 0 then 
      Protag[1].canceled_path = true
    end
  end

end

function game:keypressed(key)
  if key == "space" then

    Gamestate.switch(paused)
  end
end

function game:load()
  

end

function game:update(dt)
  


  if #Protag > 0 then
    
    --local bx,by = CAM:cameraCoords(SCREEN_WIDTH/4,SCREEN_HEIGHT/4)
    --local bw,bh = CAM:cameraCoords(LEVEL_WIDTH,LEVEL_HEIGHT) 
    --CAM.x = lume.lamp(CAM.x,bx,bw)
    --CAM.y = lume.clamp(CAM.y,by,bh)
    
    Protag[1]:update(dt)
    

  end

  for _, v in ipairs(Projectiles) do
    v:update(dt)
  end
  
end

function game:keypressed(key)
  if #Protag > 0  then
    --restart
    if key == "r" then
        Protag[1]:reset(map_tiles, 0)
    end
    
  end

end

function game:draw()
  
  
  CAM:attach()
  --gam:draw(function ()
    


    love.graphics.circle("line",CAM.x,CAM.y,6)
    
    
    for i,v in ipairs(Tiles) do
      
      v:draw()
         
    end

    for _, v in ipairs(Projectiles) do
      v:draw()
    end

    if #Protag > 0 then
      
      Protag[1]:draw()

    end

  --end
  CAM:detach()


  --debug
  game:debug_statements()
  
end

function love.load()
  Gamestate.registerEvents()
  Gamestate.switch(menu)
end

-- love callback will still be invoked
function love.update(dt)
  


  -- no need for Gamestate.update(dt)
  
end

function love.draw()
  --if Gamestate.current() == game then
    Gamestate.draw()
  --end
end