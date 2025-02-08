local Object = require("lib.classic")

Entity = Object.extend(Object)

function Entity:new(position_table,dimesion_table,hp,img,quad_x,quad_y,in_world,group)
  
  --general
  self.position = Vector2(position_table.x, position_table.y)
  self.velocity = Vector2(0, 0)
  self.dimension = Vector2(dimesion_table.w, dimesion_table.h)
  self.direction =  Vector2(0, 0)
  --if acceleration or friction is set to one it will immediately start and stop
  self.friction = 1
  self.acceleration = 1


  --either rectangle, circle, or lines
  self.shape = ""
  self.lines = {}

  
 
    
  --quad positions
  self.qx = quad_x 
  self.qy = quad_y 
 
  
  self.img = img 
  self.quad = nil
  if self.img ~= nil then
    self.img = love.graphics.newImage(img)
    self.quad = love.graphics.newQuad(self.qx,self.qy,self.dimension.x,self.dimension.y,self.img)
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
  self.og_tween_time = .3
  self.tween_time = self.og_tween_time

  
  --mode bools
  self.mouse_tile_input = false
  self.button_tile_input = false
  self.plaforming = false
  self.grounded = false

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
  self.jump_height = 48
  self.jump_time_to_peak = 0.5
  self.jump_time_to_descent = 0.8

  local jv = ((2.0 * self.jump_height)/ self.jump_time_to_peak) * -1.0
  local jg = ((-2.0 * self.jump_height)/ (self.jump_time_to_peak*self.jump_time_to_peak)) * -1.0
  local fg = ((-2.0 * self.jump_height)/ (self.jump_time_to_descent*self.jump_time_to_descent)) * -1.0

  self.jump_velocity = jv
  self.jump_gravity =  jg
  self.fall_gravity = fg


  self.last_y = 0
  self.rotation_speed = 300
  self.move_speed = 150
  

  --calc in degrees and converted to radians
  self.angle = 0
  
  
  --terminal velocity
  self.terminal_velocity = fg * 1.5
  
  --classifcation
  if in_world == true 
  and not self.button_tile_input 
  or self.mouse_tile_input then
    world:add(self, self.position.x,self.position.y,self.dimension.x,self.dimension.y)
  end
  
  if group ~= nil then
    table.insert(group,self)
  end
  
  
  self.hitbox = {
    self.position.x                   , self.position.y, 
    self.position.x                   , self.position.y + self.dimension.y,
    
    self.position.x + self.dimension.x, self.position.y + self.dimension.y,
    self.position.x + self.dimension.x,  self.position.y
  
  
}

  self.line = {
    x1 = 0,
    y1 = 0,
    x2 = 0,
    y2 = 0,
    length = 50
  }
  
end


function Entity:array2d_to_world(x,y)
  local x = (x - 1) * TILESIZE
  local y = (y - 1) * TILESIZE
  return x , y
end

function Entity:world_to_array2d(x,y)
  local x = math.floor(((x/true_level_width) * level_width)) + 1
  local y = math.floor(((y/true_level_height) * level_height)) + 1
  return x , y
end

function Entity:continuous_tile_mouse_movement(dt,walkable_tile)
  
  self.mouse_tile_input = true
  local in_bounds = false
  --real world coordinates getting translated into array coords
  local start_cell_x, start_cell_y = self:world_to_array2d(self.position.x, self.position.y)
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
        local prev_array_x, prev_array_y = self:world_to_array2d(self.position.x,self.position.y)
        
        flux.to(self.position, self.og_tween_time, {x = new_coords[1], y = new_coords[2]}):oncomplete(function () 
      

          self.position.x = lume.round((self.position.x/(level_width * TILESIZE)) * (level_width)) * TILESIZE
          self.position.y = lume.round((self.position.y/(level_height * TILESIZE)) * (level_height)) * TILESIZE
          level[prev_array_y][prev_array_x] = walkable_tile
      
          local current_array_x, current_array_y = self:world_to_array2d(self.position.x,self.position.y)
          

          level[current_array_y][current_array_x] = player_tile
        end)
        
      end
    end
  elseif #self.tile_path >= 0  then
    
    
    self.tween_time = self.tween_time - dt
    if self.tween_time <= 0 then
        self.tween_time = self.og_tween_time
        local new_coords = table.remove(self.tile_path,1)
        local prev_array_x, prev_array_y = self:world_to_array2d(self.position.x,self.position.y)
       
        flux.to(self.position, self.og_tween_time, {x = new_coords[1], y = new_coords[2]}):oncomplete(function () 
          
          if not self.canceled_path then 
            self.position.x = lume.round((self.position.x/(level_width * TILESIZE)) * (level_width)) * TILESIZE
            self.position.y = lume.round((self.position.y/(level_height * TILESIZE)) * (level_height)) * TILESIZE

            level[prev_array_y][prev_array_x] = walkable_tile
            
            
            local current_array_x, current_array_y = self:world_to_array2d(self.position.x,self.position.y)
            level[current_array_y][current_array_x] = player_tile
          else
            lume.clear(self.tile_path)
            self.position.x = lume.round((self.position.x/(level_width * TILESIZE)) * (level_width)) * TILESIZE
            self.position.y = lume.round((self.position.y/(level_height * TILESIZE)) * (level_height)) * TILESIZE
            level[prev_array_y][prev_array_x] = walkable_tile
            local current_array_x, current_array_y = self:world_to_array2d(self.position.x,self.position.y)
            self.canceled_path = false
            level[current_array_y][current_array_x] = player_tile
          end

        end)
   
    end
    
  end
flux.update(dt)

  
end

function Entity:continuous_tile_button_movement(dt,walkable_tile,unreachable_tile)
  self.button_tile_input = true


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
  local cur_x = self.position.x
  local cur_y = self.position.y

  

  
  

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
        cur_x = next_x 
        cur_y = next_y 
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
        cur_x = next_x 
        cur_y = next_y 
        self.is_tweening = true
        self.tween_time = self.og_tween_time
        level[prev_array_y][prev_array_x] = walkable_tile
        level[next_array_y][next_array_x] = player_tile
        
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
        cur_x = next_x 
        cur_y = next_y 
        self.is_tweening = true
        self.tween_time = self.og_tween_time
        level[prev_array_y][prev_array_x] = walkable_tile
        level[next_array_y][next_array_x] = player_tile
        
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
        cur_x = next_x 
        cur_y = next_y 
        self.is_tweening = true
        self.tween_time = self.og_tween_time
        level[prev_array_y][prev_array_x] = walkable_tile
        level[next_array_y][next_array_x] = player_tile
        
      end

    end
  end
    
        
      
    




    --local num = ("iNPUTTED: %.2f"..tostring(has_inputted))
    if self.is_tweening then
      if self.tween_time == self.og_tween_time then  
        flux.to(self.position, self.tween_time, {x = cur_x, y = cur_y}):oncomplete(function ()
          --self.position.x = lume.round((self.position.x/(level_width * TILESIZE)) * (level_width)) * TILESIZE
          --self.position.y = lume.round((self.position.y/(level_height * TILESIZE)) * (level_height)) * TILESIZE
          self.position = (Vector2(self:world_to_array2d(self.position:unpack())) - Vector2(1,1)) * TILESIZE
          
        end)
      end
      self.tween_time = self.tween_time - dt
      if self.tween_time <= 0 then
        self.is_tweening = false
        self.tween_time = self.og_tween_time
      end
    end

    flux.update(dt)
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

function Entity:animate(dt,anim_array, quad, dir)
  dir = dir or 1
  
  
  if anim_array.f ~= 1 then
    anim_array.t = anim_array.t - dt
  end
    
  if anim_array.t <= 0  then
        
        
        
      anim_array.qx = anim_array.qx + 1 * dir
      anim_array.t = anim_array.ot
      if anim_array.qx == anim_array.f then
        anim_array.qx = anim_array.oqx
        
      end
      
  end
  quad:setViewport(
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
  self.line.x1 = self.position.x + self.dimension.x/2 
  self.line.y1 = self.position.y + self.dimension.y/2 
  self.line.x2 = self.position.x + self.dimension.x/2 + self.line.length*self.cos
  self.line.y2 = self.position.y + self.dimension.y/2 + self.line.length*self.sin
end


function Entity:follow_target(a_vector,dt)
  --mouse movement
  

  
    
  --distance between the two objects
    

    --local angle = math.atan2(mouse_y - (self.y+self.h/2),mouse_x - (self.x+self.w/2))
    --local angle = mouse_vector:angleTo(self.position + (self.dimension * 0.5))
    --self.position.x + (self.dimension.x/2)
    local angle = lume.angle(self.position.x + (self.dimension.x/2),self.position.y + (self.dimension.y/2), a_vector.x, a_vector.y)
    self.angle = radians_to_degrees(angle)
    

    
    if not point_circle(self.position.x + (self.dimension.x/2), self.position.y + (self.dimension.y/2), a_vector.x, a_vector.y, 10) then
 

      
      
      local a_siny = math.sin(angle)
      local a_cosx = math.cos(angle)
      self.velocity.x = lume.lerp(self.velocity.x, 
                                  a_cosx *  self.move_speed, 
                                  self.acceleration)
      self.velocity.y = lume.lerp(self.velocity.y, 
                                  a_siny *  self.move_speed, 
                                  self.acceleration)
   
  else
    self.velocity.y = lume.lerp(self.velocity.y, 
                                0, 
                                self.friction)
    self.velocity.x = lume.lerp(self.velocity.x, 
                                0, 
                                self.friction)
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

    --applying acceleration
    self.velocity.y = lume.lerp(self.velocity.y, 
                                foward_y * self.move_speed, 
                                self.acceleration)

    self.velocity.x = lume.lerp(self.velocity.x, 
                                foward_x * self.move_speed, 
                                self.acceleration)

    
  elseif down then

    self.velocity.y = lume.lerp(self.velocity.y, 
                                back_y * self.move_speed, 
                                self.acceleration)

    self.velocity.x = lume.lerp(self.velocity.x, 
                                back_x * self.move_speed, 
                                self.acceleration)
  else
    --applying friction
    self.velocity.y = lume.lerp(self.velocity.y, 
                                0, 
                                self.friction)
    self.velocity.x = lume.lerp(self.velocity.x, 
                                0, 
                                self.friction)
  
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
    self.direction.y = -1
    
  elseif down then
    self.direction.y = 1
   
  else
    self.direction.y = 0
  end
  
  if left then
    self.direction.x = -1
    
  elseif right then
    self.direction.x = 1
    
  else
    self.direction.x = 0
  end
  self.direction:normalizeInplace()
  
  --if acceleration or friction is set to one it will immediately start and stop
  if self.direction.x ~= 0 then
    --applying acceleration
    
    self.velocity.x = lume.lerp(self.velocity.x, 
                                self.direction.x *  self.move_speed, 
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
                                self.direction.y *  self.move_speed, 
                                self.acceleration)
  else 
    --applying friction
    self.velocity.y = lume.lerp(self.velocity.y, 
                                0, 
                                self.friction)
  end

  --self.velocity = self.direction *  self.move_speed
  
  
  
  self:collide(dt)
end

function Entity:platformer_2d_movement(dt)
  --https://www.youtube.com/watch?v=IOe1aGY6hXA
  local up = love.keyboard.isDown('up','w')
  local right = love.keyboard.isDown('right','d')
  local left = love.keyboard.isDown('left','a')
  --keyboard movement
  self.plaforming = true
  
  if left then
    self.direction.x = -1
   
  elseif right then
    self.direction.x = 1
    
  else
    self.direction.x = 0
  end
  
  
  
  --if acceleration or friction is set to one it will immediately start and stop
  if self.direction.x ~= 0 then
    --applying acceleration
    
    self.velocity.x = lume.lerp(self.velocity.x, 
                                self.direction.x *  self.move_speed, 
                                self.acceleration)
  else 
    --applying friction
    self.velocity.x = lume.lerp(self.velocity.x, 
                                0, 
                                self.friction)
  end

  --applying gravity
  self.velocity.y = self.velocity.y  + self:get_gravity() * dt
  if self.velocity.y > self.terminal_velocity  then
    self.velocity.y = self.terminal_velocity
  end

  ---jumping
  --a non-variable one would just be velocity=jump velocity and 

  if self.grounded then 
    if up then
      self.velocity.y = self.jump_velocity
      self.grounded = false
    end
  end 

    

    
    --[[
    if self.vy ~= tiny then
      self.is_grounded = false
    end]]--
    
    
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
  
  self:collide(dt)
end


function Entity:get_gravity()
  if self.velocity.y < 0.0 then
    return self.jump_gravity 
  else
    return self.fall_gravity
  end
end

function Entity:apply_gravity(dt)
  --print("vx: "..tostring(self.vx))
  
  if self.grounded == false then
    --self.y = self.y + self.vy --* dt
    self.velocity.y = self.velocity.y + self:get_gravity() --* dt
  end
  
  
  

end


--without his function nothing that isn't tile-based moves
function Entity:collide(dt)
  
  --the actually collision code for the library used for the world
  self.last_y = self.position.y
  local x,y,vx,vy= self.position.x,self.position.y,self.velocity.x,self.velocity.y

  local futureX =  x + vx * dt
  local futureY =  y + vy * dt
  local nextX,nextY,cols,len = world:move(self,futureX,futureY)
  if self.plaforming then
    for i = 1 , len do
      local col = cols[i]
      local kind = col.other.class
       if col.normal.y == -1  then
  
        self.grounded = true
        self.velocity.y = 0
      
      
     
      end
      if col.normal.y == 1  then
  
        
        self.velocity.y = 0
      
      
      
      end

      if col.normal.y ~= -1  then
  
        
        self.grounded = false
      
      
      
      end
      

    end
  end

  self.position.x = nextX
  self.position.y = nextY
end

function Entity:add_in_world()

  world:add(self, self.position.x,self.position.y,self.dimension.x,self.dimension.y)

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
  love.graphics.draw(self.img,self.quad,self.position.x,self.position.y)
end

function Entity:display(mode)
  --mode used to take the place of argument 1
  love.graphics.rectangle(mode,self.position.x,self.position.y,self.dimension.x,self.dimension.y)
end

