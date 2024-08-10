local Object = require("lib.classic")
require "unitconverter"
--lume = require "lib.lume"
--flux = require "lib.flux"
Entity = Object.extend(Object)




function Entity:new(x,y,w,h,hp,img,quad_x,quad_y,in_world,group)
  
  --general
  self.x = x
  self.y = y
  self.w = w
  self.h = h
    
  --quad position
  self.qx = quad_x 
  self.qy = quad_y 
 
  
  self.img = img 
  self.quad = nil
  if self.img ~= nil then
    self.img = love.graphics.newImage(img)
    self.quad = love.graphics.newQuad(self.qx,self.qy,self.w,self.h,self.img)
  end
  self.hp = hp 
  --tile based stuff
  self.tile_path = {}
  self.canceled_path = false
  self.start_cell_x = 0
  self.start_cell_y = 0
  self.end_cell_x = 0
  self.end_cell_y = 0
  self.map_reference = {}
  self.delta_time = 0

  
  --tweens and stuff
  self.is_tweening = false
  self.og_tween_time = .15
  self.tween_time = self.og_tween_time

  
  --mode bools
  self.mouse_tile_input = false
  self.single_tile_input = false
  self.plaforming = false
  self.grounded = true

  --animation without anim8
  --t is time to next frame qx and qy are the startinf quads
  self.sample_anim = {t = .125, qx = 0, qy = 0, ot = .125, oqx = 0, oqy = 0, f = 4, name = "walk"}
  self.frame_size = nil

 
  --orientation
  --flipx and flipy
  self.fx = 1
  self.fy = 1
  
  
  self.sin = 0
  self.cos = 0
  --mouse coords
  self.mx = 0
  self.my = 0
  
  
  --movement code
  self.jump_height = -100
  self.gravity = -400
  self.friction = 2
  --velocity x and y 
  self.vy = -1
  self.vx = 0
  --normalization stuff
  self.dx = 1
  self.dy = 1
  self.rotation_speed = 300
  self.move_speed = 150
  self.acceleration = 550

  --calc in degrees and converted to radians
  self.angle = 0
  
  
  --terminal velocity
  self.vt = 300
  
  --classifcation
  if in_world == true 
  and not self.single_tile_input 
  or self.mouse_tile_input then
    world:add(self, x,y,w,h)
  end
  
  if group ~= nil then
    table.insert(group,self)
  end
  
  
  self.line = {
    x1 = 0,
    y1 = 0,
    x2 = 0,
    y2 = 0,
    length = 50
  }
  
end

function love.mousepressed(x, y, button, istouch)
  if #protag > 0 then
    if #protag[1].tile_path > 0 then 
      protag[1].canceled_path = true
    end
  end
  
end


function love.wheelmoved(x, y)
  
  if #protag > 0 then
    --if protag[1].single_tile_input or protag[1].mouse_tile_input then 
      local temp = {x = camera_zoom_factor}
      local max_zoom = 10
      local min_zoom = .05
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
      --cam:zoomTo(temp.x)
      gam:setScale(temp.x)
    --end
  end
end

function Entity:array2d_to_world(x,y)
  x = (x - 1) * TILESIZE
  y = (y - 1) * TILESIZE
  return x , y
end

function Entity:world_to_array2d(x,y)
  x = math.floor(((x/true_level_width) * level_width)) + 1
  y = math.floor(((y/true_level_height) * level_height)) + 1
  return x , y
end

function Entity:continuous_tile_mouse_movement(dt,walkable_tile)
  --?protag[1].x = lume.round((protag[1].x/(level_width * TILESIZE)) * (level_width)) * TILESIZE
  --protag[1].y = lume.round((protag[1].y/(level_height * TILESIZE)) * (level_height)) * TILESIZE

  local in_bounds = false
  --real world coordinates getting translated into array coords

 
  local start_cell_x, start_cell_y = self:world_to_array2d(self.x, self.y)
  local end_cell_x,end_cell_y = self:world_to_array2d(self.mx, self.my)
  local player_tile = 9
  --local walkable_tile = walkable_tile
  --if #protag[1].tile_path == 0 then
  
  if love.mouse.isDown(1) then
    if #self.tile_path == 0 then
      
      

      
      --in_bounds = next_x <= true_level_width and next_x >= 0 and next_y <= true_level_height and next_y >= 0
      in_bounds = end_cell_x <= level_width and end_cell_x > 0 and end_cell_y <= level_height and end_cell_y > 0
      
    --[[
    elseif #self.tile_path > 0 
    and not self.canceled_path then
      
      self.canceled_path = true]]--
    end
  end

    -- Pretty-printing the results
  if #self.tile_path == 0 then
    if in_bounds then
    --and start_cell_x ~= end_cell_x 
    --and start_cell_y ~= end_cell_y  then
      
      local myFinder = Pathfinder(Grid(level), 'ASTAR', walkable_tile)
      local path = myFinder:getPath(start_cell_x, start_cell_y, end_cell_x, end_cell_y)
      --myFinder:setMode('ORTHOGONAL')
    --if start_cell_x ~= end_cell_x 
    --and start_cell_y ~= end_cell_y 
    --and not protag[1].canceled_path then
      if path then
        
        
        --print(path:nodes())
        
        --print(('Path found! Length: %.2f'):format(path:getLength()))
        for node, count in path:nodes() do
          local x_,y_ = self:array2d_to_world(node:getX(),node:getY())
          table.insert(self.tile_path,{x_,y_})
          --print(('Step: %d - x: %d - y: %d'):format(count, node:getX(), node:getY()))
        end
        local new_coords = table.remove(self.tile_path,1)
        local prev_array_x, prev_array_y = self:world_to_array2d(self.x,self.y)
        
        flux.to(self, self.og_tween_time, {x = new_coords[1], y = new_coords[2]}):oncomplete(function () 
      

          self.x = lume.round((self.x/(level_width * TILESIZE)) * (level_width)) * TILESIZE
          self.y = lume.round((self.y/(level_height * TILESIZE)) * (level_height)) * TILESIZE
          level[prev_array_y][prev_array_x] = walkable_tile
      
          local current_array_x, current_array_y = self:world_to_array2d(self.x,self.y)
          

          level[current_array_y][current_array_x] = player_tile
        end)
        
      end
    end
  elseif #self.tile_path >= 0  then
    
    
    self.tween_time = self.tween_time - dt
    if self.tween_time <= 0 then
        self.tween_time = self.og_tween_time
        local new_coords = table.remove(self.tile_path,1)
        local prev_array_x, prev_array_y = self:world_to_array2d(self.x,self.y)
       
        flux.to(self, self.og_tween_time, {x = new_coords[1], y = new_coords[2]}):oncomplete(function () 
          
          if not self.canceled_path then 
            self.x = lume.round((self.x/(level_width * TILESIZE)) * (level_width)) * TILESIZE
            self.y = lume.round((self.y/(level_height * TILESIZE)) * (level_height)) * TILESIZE

            level[prev_array_y][prev_array_x] = walkable_tile
            
            
            local current_array_x, current_array_y = self:world_to_array2d(self.x,self.y)
            level[current_array_y][current_array_x] = player_tile
          else
            lume.clear(self.tile_path)
            self.x = lume.round((self.x/(level_width * TILESIZE)) * (level_width)) * TILESIZE
            self.y = lume.round((self.y/(level_height * TILESIZE)) * (level_height)) * TILESIZE
            level[prev_array_y][prev_array_x] = walkable_tile
            local current_array_x, current_array_y = self:world_to_array2d(self.x,self.y)
            self.canceled_path = false
            level[current_array_y][current_array_x] = player_tile
          end

        end)
   
    end
    
  end
flux.update(dt)
  --else
    --lume.clear(protag[1].tile_path)
  --end
  
end

function Entity:continuous_tile_button_movement(dt,walkable_tile,unreachable_tile)
  
  --self.x = lume.round((protag[1].x/(level_width * TILESIZE)) * (level_width)) * TILESIZE
  --self.y = lume.round((protag[1].y/(level_height * TILESIZE)) * (level_height)) * TILESIZE
  

  local up = {love.keyboard.isDown('up','w'), {x = 0, y = -1}}
  local down = {love.keyboard.isDown('down','s'), {x = 0, y = 1}}
  local right = {love.keyboard.isDown('right','d'), {x = 1, y = 0}}
  local left = {love.keyboard.isDown('left','a'), {x = -1, y = 0}} 
  local up_right = up[1] and right[1]
  local up_left = up[1] and left[1]
  local down_right = down[1] and right[1]
  local down_left = down[1] and left[1]

  local player_tile = 9
  

  local true_tile_size = TILESIZE
  local true_level_width = level_width * true_tile_size
  local true_level_height = level_height * true_tile_size
  --(self.x + self.w/2)
  --and not has_inputted
  local cur_x = self.x
  local cur_y = self.y

  

  
  flux.update(dt)

  if not self.is_tweening then
    if up[1] then
      
      local next_x = cur_x + up[2].x * true_tile_size
      local next_y = cur_y + up[2].y * true_tile_size
      local in_bounds = next_x <= true_level_width and next_x >= 0 and next_y <= true_level_height and next_y >= 0
      
      local prev_array_x, prev_array_y = self:world_to_array2d(cur_x,cur_y)
      local next_array_x, next_array_y = self:world_to_array2d(next_x, next_y)

      

      
      local array_in_bounds = next_array_x <= level_width and next_array_x > 0 and next_array_y <= level_height and next_array_y > 0
      local is_valid = true 
      if array_in_bounds then
        is_valid = level[next_array_y][next_array_x] ~= unreachable_tile
      end
      if in_bounds and is_valid and array_in_bounds then 
        cur_x = next_x --* (self.x + self.w/2)
        cur_y = next_y --* (self.y + self.h/2)
        self.is_tweening = true
        self.tween_time = self.og_tween_time
        level[prev_array_y][prev_array_x] = walkable_tile
        level[next_array_y][next_array_x] = player_tile
        --level[array_y][array_x] = 9
      end


      
    end
    
    if down[1]  then
      local next_x = cur_x + down[2].x * true_tile_size
      local next_y = cur_y + down[2].y * true_tile_size
      local in_bounds = next_x <= true_level_width and next_x >= 0 and next_y <= true_level_height and next_y >= 0
      
      local prev_array_x, prev_array_y = self:world_to_array2d(cur_x,cur_y)
      local next_array_x, next_array_y = self:world_to_array2d(next_x, next_y)

      

      
      local array_in_bounds = next_array_x <= level_width and next_array_x > 0 and next_array_y <= level_height and next_array_y > 0
      local is_valid = true 
      if array_in_bounds then
        is_valid = level[next_array_y][next_array_x] ~= unreachable_tile
      end
      if in_bounds and is_valid and array_in_bounds then 
        cur_x = next_x --* (self.x + self.w/2)
        cur_y = next_y --* (self.y + self.h/2)
        self.is_tweening = true
        self.tween_time = self.og_tween_time
        level[prev_array_y][prev_array_x] = walkable_tile
        level[next_array_y][next_array_x] = player_tile
        --level[array_y][array_x] = 9
      end

    
    end
    
    if left[1] then
      local next_x = cur_x + left[2].x * true_tile_size
      local next_y = cur_y + left[2].y * true_tile_size
      local in_bounds = next_x <= true_level_width and next_x >= 0 and next_y <= true_level_height and next_y >= 0
      
      local prev_array_x, prev_array_y = self:world_to_array2d(cur_x,cur_y)
      local next_array_x, next_array_y = self:world_to_array2d(next_x, next_y)

      

      
      local array_in_bounds = next_array_x <= level_width and next_array_x > 0 and next_array_y <= level_height and next_array_y > 0
      local is_valid = true 
      if array_in_bounds then
        is_valid = level[next_array_y][next_array_x] ~= unreachable_tile
      end
      if in_bounds and is_valid and array_in_bounds then 
        cur_x = next_x --* (self.x + self.w/2)
        cur_y = next_y --* (self.y + self.h/2)
        self.is_tweening = true
        self.tween_time = self.og_tween_time
        level[prev_array_y][prev_array_x] = walkable_tile
        level[next_array_y][next_array_x] = player_tile
        --level[array_y][array_x] = 9
      end


      
    end 
    if right[1] then
      
      
      local next_x = cur_x + right[2].x * true_tile_size
      local next_y = cur_y + right[2].y * true_tile_size
      local in_bounds = next_x <= true_level_width and next_x >= 0 and next_y <= true_level_height and next_y >= 0
      
      local prev_array_x, prev_array_y = self:world_to_array2d(cur_x,cur_y)
      local next_array_x, next_array_y = self:world_to_array2d(next_x, next_y)

      

      
      local array_in_bounds = next_array_x <= level_width and next_array_x > 0 and next_array_y <= level_height and next_array_y > 0
      local is_valid = true 
      if array_in_bounds then
        is_valid = level[next_array_y][next_array_x] ~= unreachable_tile
      end
      if in_bounds and is_valid and array_in_bounds then 
        cur_x = next_x --* (self.x + self.w/2)
        cur_y = next_y --* (self.y + self.h/2)
        self.is_tweening = true
        self.tween_time = self.og_tween_time
        level[prev_array_y][prev_array_x] = walkable_tile
        level[next_array_y][next_array_x] = player_tile
        --level[array_y][array_x] = 9
      end

    end
  end
    
        
      
    




    --local num = ("iNPUTTED: %.2f"..tostring(has_inputted))
    if self.is_tweening then
      if self.tween_time == self.og_tween_time then  
        flux.to(self, self.tween_time, {x = cur_x, y = cur_y}):oncomplete(function ()
          self.x = lume.round((protag[1].x/(level_width * TILESIZE)) * (level_width)) * TILESIZE
          self.y = lume.round((protag[1].y/(level_height * TILESIZE)) * (level_height)) * TILESIZE
        end)
      end
      self.tween_time = self.tween_time - dt
      if self.tween_time <= 0 then
        self.is_tweening = false
        self.tween_time = self.og_tween_time
      end
    end

    
    --[[
    local x,y,vx,vy= new_x,new_y,protag[1].vx,protag[1].vy
    local futureX =  x --+ vx * dt
    local futureY =  y --+ vy * dt
    local nextX,nextY,cols,len = world:move(protag[1],new_x,new_y)
    ]]--
    --protag[1].x = cur_x
    --protag[1].y = cur_y
end








function Entity:timer(time_to, dt)
  time_to = time_to - dt
  if time_to <= 0  then
    
    return 0
      
  end
end

function Entity:animate(dt,anim_array)
  
  
  
  if anim_array.f ~= 1 then
    anim_array.t = anim_array.t - dt
  end
    
  if anim_array.t <= 0  then
        
        
        
      anim_array.qx = anim_array.qx + 1 
      anim_array.t = anim_array.ot
      if anim_array.qx == anim_array.f then
        anim_array.qx = anim_array.oqx
        
      end
      
  end
  self.quad:setViewport(
    self.frame_size * anim_array.qx,
    self.frame_size * anim_array.qy,
    self.frame_size,
    self.frame_size
    )
  
end


function Entity:update_line_angle(dt)
  --shows the actually line the players pointing in
   
  self.sin = math.sin(degrees_to_radians(self.angle))
  self.cos = math.cos(degrees_to_radians(self.angle)) 
  self.line.x1 = self.x + self.w/2 
  self.line.y1 = self.y + self.h/2 
  self.line.x2 = self.x + self.w/2 + self.line.length*self.cos
  self.line.y2 = self.y + self.h/2 + self.line.length*self.sin
end





function Entity:follow_mouse_click_movement(mouse_x,mouse_y,dt)
  --mouse movement
  

  if love.mouse.isDown(1) then
    
  --distance between the two objects
    
    local HorDiz = mouse_x - self.x + (self.w/2)
    local VertDiz = mouse_y - self.y + (self.h/2)
    local angle = math.atan2(mouse_y - (self.y+self.h/2),mouse_x - (self.x+self.w/2))
    self.angle = radians_to_degrees(angle)
    --love.graphics.print(tostring(angle),self.x -10,self.y)
    local a = HorDiz ^ 2
    local b = VertDiz ^ 2
    
    local c = a + b
    
    if c > 5 then
 

      
      
      local mouse_siny = math.sin(angle)
      local mouse_cosx = math.cos(angle)
      self.vx = self.move_speed * mouse_cosx
      self.vy = self.move_speed * mouse_siny
    end
  else
    self.vx = 0
    self.vy = 0
  end
  self:collide(dt)
end

function Entity:tank_movement(dt)
  local up = love.keyboard.isDown('up','w')
  local down = love.keyboard.isDown('down','s')
  local right = love.keyboard.isDown('right','d')
  local left = love.keyboard.isDown('left','a')
  
  if right then
    
    
    self.angle = self.angle + self.rotation_speed * dt 
    if self.angle > 360 then
      self.angle = 0
    end
   
  elseif left then
   
    self.angle = self.angle - self.rotation_speed *dt 
    if self.angle < 0 then
      self.angle = 360
    end
    
  end

  
  
  local foward_y = math.sin(degrees_to_radians(self.angle))
  local foward_x = math.cos(degrees_to_radians(self.angle))
  
  local left_y = math.sin(degrees_to_radians(self.angle - 90))
  local left_x = math.cos(degrees_to_radians(self.angle - 90))
  
  local right_y = math.sin(degrees_to_radians(self.angle + 90))
  local right_x = math.cos(degrees_to_radians(self.angle + 90))
  
  local back_y = math.sin(degrees_to_radians(self.angle - 180))
  local back_x = math.cos(degrees_to_radians(self.angle - 180))
  
  if up then
    --self.dy = -1
    self.vy = self.move_speed * foward_y --* self.dy
    self.vx = self.move_speed * foward_x --* self.dx
  elseif down then
    --self.dy =  1
    self.vy = self.move_speed * back_y --* self.dy
    self.vx = self.move_speed * back_x --* self.dx
  else
    self.vy = 0
    self.vx = 0
  end
  self:collide(dt)
end


function Entity:topdown_2d_movement(dt)
  local up = love.keyboard.isDown('up','w')
  local down = love.keyboard.isDown('down','s')
  local right = love.keyboard.isDown('right','d')
  local left = love.keyboard.isDown('left','a')
  --keyboard movement
  --classic up button movement going up left right and down with regards to player angle feels clunky
  --dx and dy are meant to be normalization vectors so when the character moves diagonally they don't go faster from the x and y speed together
  
  if up then
    self.dy = -1
    self.vy = self.move_speed * self.dy
  
  elseif down then
    self.dy =  1
    self.vy = self.move_speed * self.dy
  else
    self.dy = 0
    self.vy = 0
  end
  
  if left then
    self.dx = -1
    self.vx = self.move_speed * self.dx
  elseif right then
    self.dx = 1
    self.vx = self.move_speed * self.dx
  else
    self.dx = 0
    self.vx = 0
  end
  
  if self.dx == 1 then
    local length = math.sqrt(self.dx^2+self.dy^2)
    
    
    if self.dy == 1 then
      self.dx = self.dx/length
      self.dy = self.dy/length
      self.vy = self.vy * self.dy
      self.vx = self.vx * self.dx
    elseif self.dy == -1 then
      self.dx = self.dx/length
      self.dy = self.dy/length
      self.vy = self.vy * -self.dy
      self.vx = self.vx * self.dx
    end
    

  end  
  if self.dx == -1 then
    local length = math.sqrt(self.dx^2+self.dy^2)
    if self.dy == 1 then
      self.dx = self.dx/length
    
    
      self.dy = self.dy/length
      self.vy = self.vy * self.dy
      self.vx = self.vx * -self.dx
    elseif self.dy == -1 then
      self.dx = self.dx/length
      self.dy = self.dy/length
      self.vy = self.vy * -self.dy
      self.vx = self.vx * -self.dx
    end
    
    
  end
  
  
  
  self:collide(dt)
end

function Entity:platformer_2d_movement(dt)
  
  local right = love.keyboard.isDown('right','d')
  local left = love.keyboard.isDown('left','a')
  --keyboard movement
 
  
  if left then
    self.dx = -1
    self.vx = self.move_speed * self.dx
  elseif right then
    self.dx = 1
    self.vx = self.move_speed * self.dx
  else
    self.dx = 0
    self.vx = 0
  end
  
  self:collide(dt)
end



function Entity:apply_gravity(dt)
  --print("vx: "..tostring(self.vx))
  
  if self.vy ~= 0 then
    --self.y = self.y + self.vy --* dt
    self.vy = self.vy - self.gravity * dt
  end
  
  
  if self.vy > self.vt  then
    self.vy = self.vt
  end

end

function Entity:apply_friction(dt)
  
  if self.vx > .0001 or self.vx < -.0001  then
    self.vx = self.vx * (1-math.min(dt * self.friction,1))
  end
end

function Entity:sample_jump()
      ---jumping
    --a non-variable one would just be vy=jump height and 
    --[[
    if self.is_grounded == true 
    and self.vy == tiny then 
      if love.keyboard.isDown('x') then
        self.vy = self.jump_height
        self.is_grounded = false
        
      end
    end 
    
    if self.vy ~= tiny then
      self.is_grounded = false
    end
    
    
    --if not love.keyboard.isDown('x') then
      --self.vy = tiny
    --end
    
    
    --variable jumping
    --if love.keyboard.isDown('x') 
   -- and self.vy < 0 
    --and self.jump_counter < self.jump_segments
    --then
        --self.jump_counter = self.jump_counter + 1 
        
          
        --local rest_of_jump = self.max_jump_height * dt --(self.jump_counter/self.jump_segments)
        --self.vy = self.min_jump_height + rest_of_jump
        --if rest_of_jump <= self.max_jump_height then
          --self.vy = tiny
          
        --end
    --else
      --self.jump_counter = self.jump_segments
    --end
    ]]--
end

function Entity:sample_acceleration(dt)
   if love.keyboard.isDown('left') then
      --cancels momentum from previous movement
      
      
      if self.vx > 0 then
        self.vx = -50
      end
      self.vx = math.min(self.vx - self.acceleration * dt)
      self.flipx = -1
      --self.anim = self.animations.roll
     
          
    elseif love.keyboard.isDown('right') 
    then
      --cancels momentum from previous movement
     
      if self.vx < 0 then
        self.vx = 50
      end
      self.vx = math.min(self.vx + self.acceleration * dt)
      self.flipx = 1
      
 
    else
      --immediately stops upon key release
      self.vx = 0
    end
end



--without his function nothing moves
function Entity:collide(dt)
  --the actually collision code for the library used for the world
  local x,y,vx,vy= self.x,self.y,self.vx,self.vy
  local futureX =  x + vx * dt
  local futureY =  y + vy * dt
  local nextX,nextY,cols,len = world:move(self,futureX,futureY)
  
  self.x = nextX
  self.y = nextY
end

function Entity:add_in_world()

  world:add(self, self.x,self.y,self.w,self.h)

end

function Entity:delete_in_world()
  world:remove(self)
end

function Entity:remove_from_group(group,ind)
  table.remove(group,ind)
  
end

--one actually draws the other draws a box
function Entity:draw_line()
  love.graphics.line(self.line.x1,self.line.y1,self.line.x2,self.line.y2)
end
function Entity:draw()
  love.graphics.draw(self.img,self.quad,self.x,self.y)
end

function Entity:display(mode)
  --mode used to take the place of argument 1
  love.graphics.rectangle(mode,self.x,self.y,self.w,self.h)
end

