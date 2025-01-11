require "matrixmath"
require "matrix_math"

local screen_width = love.graphics.getWidth()
local screen_height = love.graphics.getHeight()


--libraries
--HUMP's camera and lume
--https://hump.readthedocs.io/en/latest/camera.html
--https://github.com/rxi/lume/blob/master/lume.lua

local camera = require "camera"
local lume = require 'lume'
local matrix = require("matrix")

local camera_zoom_factor = 1
local cam =  camera()
cam:zoom(camera_zoom_factor)
local delta_time = 0
local mx, my = 0

local delta = 0
local space_pressed = false
local has_printed = false


self = {
    angle = 0,
    rotation_speed = 40,
    velocity = {x = 0, y = 0},
    friction = 1,
    move_speed = 200,
    --the player position 
    texture_position = {x = screen_width/2, y = screen_width/2},
    box_dimensions = {w = 170, h = 70},
    --box polygon
    box_vertices = {},
    acceleration = 1,
    direction = {x = 0, y = 0}

}



function love.wheelmoved(x, y)
    
    --if protag[1].button_tile_input or protag[1].mouse_tile_input then 
  local temp = {x = camera_zoom_factor}
  local max_zoom = 100
  local min_zoom = .5
  local zoom_dir = 0
  local zoom_speed = 20
  if y > 0 then
      --up
      camera_zoom_factor = camera_zoom_factor + zoom_speed * delta
      
  elseif y < 0 then
      --down
      camera_zoom_factor = camera_zoom_factor - zoom_speed * delta
      
      
  end
  
  camera_zoom_factor = lume.clamp(camera_zoom_factor,min_zoom,max_zoom)
  cam:zoomTo(temp.x)

  
end

function degrees_to_radians(degree)
  return (degree * math.pi) / 180
end

function radians_to_degrees(radian)
  return radian * ( 180 / math.pi )
end

function print_rect_vertices()
    if not has_printed then
        for i, v in pairs(self.box_vertices) do
            if i < #self.box_vertices then
                
                print("\nX: " .. tostring(self.box_vertices[i]) .. " Y: " .. tostring(self.box_vertices[i + 1]))
            end
        end
        print(tostring(#self.box_vertices))
        has_printed = true
    end
end

function move_texture_pos(dt, using_tables)
  --move the actual pixel position inside the texture 

  local up = love.keyboard.isDown('up','w')
  local down = love.keyboard.isDown('down','s')
  local right = love.keyboard.isDown('right','d')
  local left = love.keyboard.isDown('left','a')
  local right_click = love.mouse.isDown(1)
  local left_click = love.mouse.isDown(2)
  local prev_angle = self.angle

  if right_click then
    
    
    self.angle = self.angle + self.rotation_speed * dt 
    if self.angle > 360 then
      self.angle = 0
    end
   
  elseif left_click then
   
    self.angle = self.angle - self.rotation_speed *dt 
    if self.angle < 0 then
      self.angle = 360
    end
    
  end

  if left_click or right_click then
      if using_tables == true then
        local origin_matrix = translation_matrix2D(-self.texture_position.x, -self.texture_position.y)
        local matrix_origin = translation_matrix2D(self.texture_position.x, self.texture_position.y)
        local rotation_matrix = rotation_matrix2D(degrees_to_radians(prev_angle - self.angle))
        
        for i = 1, #self.box_vertices, 2 do
          
          local x, y = self.box_vertices[i],self.box_vertices[i + 1] 
          --making origin centric
          local translate_matrix = matrix_multiply(origin_matrix, set_matrix2D(x, y))
          --applying transformation
          local matrix_rotated = matrix_multiply(translate_matrix, rotation_matrix)
          --moving back to original position
          local matrix_translate = matrix_multiply(
              matrix_rotated,
              matrix_origin
              
          
          )

          self.box_vertices[i], self.box_vertices[i + 1] = get_2D_vertices(matrix_translate)

        end
        
      else
        local angle_change = degrees_to_radians(prev_angle - self.angle)
        for i = 1, #self.box_vertices, 2 do
            local tx, ty = self.texture_position.x, self.texture_position.y
            local x, y = self.box_vertices[i], self.box_vertices[i + 1]
            --making origin centric
            x, y = translate_2D(-tx, -ty, x, y)
            --applying transformation
            x, y = rotate_2D(angle_change, x, y)
            --moving back to original position
            self.box_vertices[i], self.box_vertices[i + 1] = translate_2D(tx, ty, x, y)
        end
      end
    
    end
    
    
    if up then
      self.direction.y = -1
      --self.velocity.y = -self.mini
    elseif down then
      self.direction.y = 1
      --self.velocity.y = self.mini
    else
      self.direction.y = 0
    end
    
    if left then
      self.direction.x = -1
      --self.velocity.x = -self.mini
    elseif right then
      self.direction.x = 1
      --self.velocity.x = -self.mini
    else
      self.direction.x = 0
    end
    
    local normalizer = math.sqrt(self.direction.x ^ 2 + self.direction.y ^ 2)
    --if acceleration or friction is set to one it will immediately start and stop
    if self.direction.x ~= 0 then
      --applying acceleration
      

      self.velocity.x = lume.lerp(self.velocity.x, 
                                  self.direction.x/normalizer * self.move_speed, 
                                  self.acceleration)
    else 
      --applying friction
      self.velocity.x = lume.lerp(self.velocity.x, 
                                  0, 
                                  self.friction)
    end
  
    if self.direction.y ~= 0 then
      --applying acceleration
      
      self.velocity.y = lume.lerp(self.velocity.y, 
                                  self.direction.y/normalizer *  self.move_speed, 
                                  self.acceleration)
    else 
      --applying friction
      self.velocity.y = lume.lerp(self.velocity.y, 
                                  0, 
                                  self.friction)
    end
  

  --the actually collision code for the library used for the world
  local x,y,vx,vy= self.texture_position.x,self.texture_position.y,self.velocity.x,self.velocity.y
  local new_x = x + vx * dt
  local new_y = y + vy * dt

  self.texture_position.x = new_x
  self.texture_position.y = new_y
 
  
end



function love.load()
  --[[
    local testa = matrix({
      {1},
      {2},
      {3}

    })

    local testb = matrix({

      {6, 6, 2}

    })
   
    --testb = matrix.transpose(testb)

    local result = matrix.mul(testa, testb)
    matrix.print(testa)
    print("")
    matrix.print(testb)
    print("")
    matrix.print(matrix:new(3,3,8))
    ]]--
    --creating the box around the player
    for i = 0, 3 do
        local vert_x = self.texture_position.x + self.box_dimensions.w * math.cos(degrees_to_radians(45 + 90 * i))
        local vert_y = self.texture_position.y + self.box_dimensions.h * math.sin(degrees_to_radians(45 + 90 * i))
        table.insert(self.box_vertices, vert_x) 
        table.insert(self.box_vertices, vert_y) 

    end

end

function love.update(dt)
    mx,my = cam:worldCoords(love.mouse.getPosition())
    cam:lookAt(self.texture_position.x,self.texture_position.y)
    delta = dt
    move_texture_pos(dt, true)
    if love.keyboard.isDown("space") then
        space_pressed = true
    else
        has_printed = false
        space_pressed = false
    end

    if space_pressed and not has_printed then
        print_rect_vertices()
    end

    
    
end

function love.draw()


   cam:attach()
        --for i, v in ipairs(self.box_vertices) do
            --table.insert(vertices, self.box_vertices[i])
           
        --end
        love.graphics.circle("line",self.texture_position.x,self.texture_position.y,5)
        love.graphics.polygon("line", self.box_vertices)
        --vertices = lume.clear(vertices)
   cam:detach()


    num = ("zoom: %.2f"):format(camera_zoom_factor)
    love.graphics.print(num,
          10,
          10)
    
    num = ("MX: %.2f"):format(mx)
    love.graphics.print(num,
        10,
        20)
        
    num = ("MY: %.2f"):format(my)
    love.graphics.print(num,
        10,
        30)

    num = ("Angle: %.2f"):format(self.angle)
    love.graphics.print(num,
        10,
        40)

    num = ("FPS: %.2f"):format(love.timer.getFPS())
    love.graphics.print(num,
        10,
        50)

    num = "Arrow Keys or WASD to move"
    love.graphics.print(num,
            screen_width/3,
            10)

    num = "Left or Right Click to rotate"
    love.graphics.print(num,
            screen_width/3,
            20)
end

