require "entity"
require "bullet"
local gauge = require "gauge"

Player = Entity:extend()



function Player:new(position_table,dimension_table,hp,image_path,quad_x,quad_y,in_world,group_table)
  Player.super.new(self,
    position_table,
    dimension_table,
    hp,
    image_path,
    quad_x,
    quad_y,
    in_world,
    group_table)
  
  --size of single frame in spritesheer
  
  --self.frame_size = 24
  self.max_speed = 200
  self.rotation_speed = 200
  self.button_tile_input = true
  self.mouse_tile_input = false
  --mouse offeset
  self.mx = 0
  self.my = 0
  self.vy = 0

  self.walkable_tile = 0
  self.unreachable_tile = 1
  self.mouse_vector = Vector2(self.mx, self.my)
  self.target_position = self.position

  --size of cell in the spritesheet
  self.frame_size = TILESIZE
  --player animations
  self.idle_anim = {t = .3, qx = 0, qy = 4, ot = .3, oqx = 0, oqy = 0, f = 2, name = "idle"}
  self.walk_anim = {t = .15, qx = 0, qy = 0, ot = .15, oqx = 0, oqy = 0, f = 4, name = "walk"}
  self.hurt_anim = {t = .125, qx = 0, qy = 6, ot = .125, oqx = 0, oqy = 0, f = 1, name = "hurt"}
  self.dead_anim =  {t = .3, qx = 0, qy = 6, ot = .3, oqx = 1, oqy = 0, f = 2, name = "dead"}
  self.hit_anim =  {t = .125, qx = 0, qy = 5, ot = .125, oqx = 0, oqy = 0, f = 3, name = "hit"}
  self.dfnd_anim = {t = .125, qx = 0, qy = 1, ot = .125, oqx = 0, oqy = 0, f = 2, name = "defend"}
  self.cast_anim = {t = .125, qx = 0, qy = 2, ot = .125, oqx = 0, oqy = 0, f = 2, name = "cast"}

  self.fade_time = 0
  self.state = "idle"
  self.states = {
    "idle",
    "walk",
    "hurt",
    "attack",
    "dead",
    "defend"
  }


  --shader stuff
  self.flash_shader = love.graphics.newShader("flash.glsl")
  self.fade_shader = love.graphics.newShader("fade.glsl")
  self.fade_duration = 1.0

  self.bullet_img_path = "assets/pc.png"
  self.og_hurt_t = 0.3
  self.hurt_timer = 0.3
  
  self.defend_timer = 0.5
  self.dead_timer = self.dead_anim.ot * self.dead_anim.f
  self.is_defending = false
  self.is_hurting = false
  self.is_dying = false
  self.is_dead = false
  --slash hitbox stuff
  self.slash_timer = self.hit_anim.ot * self.hit_anim.f
  self.slash_mode = 'line'
  self.is_slashing = false
  local hitbox_dist = 12
  --the slash hitbox, a trapezoid
  local tx1 = self.position.x + self.dimension.x/2 + hitbox_dist
  local ty1 = self.position.y + self.dimension.y/2 - self.frame_size/1.5

  local tx2 = self.position.x + self.dimension.x/2 + hitbox_dist
  local ty2 = self.position.y + self.dimension.y/2 + self.frame_size/1.5
  
  local tx3 = self.position.x + self.dimension.x/2 + hitbox_dist + self.frame_size/2 
  local ty3 = math.abs(ty2 - ty1) - (math.abs(ty2 - ty1)/4) + ty1

  local tx4 = self.position.x + self.dimension.x/2 + hitbox_dist + self.frame_size/2 
  local ty4 = math.abs(ty2 - ty1)/4 + ty1

  self.slash_anim = {t = .125, qx = 3, qy = 5, ot = .125, oqx = 3, oqy = 5, f = 1, name = "slash"}
  self.slash_img = love.graphics.newImage("assets/pc.png")
  self.slash_quad = love.graphics.newQuad(3 * TILESIZE, 5 * TILESIZE, TILESIZE,TILESIZE,self.slash_img)
  
  --x , y, x, y, etc
  self.slash_verts = {
    tx1, ty1, 
    tx2, ty2,  
    tx3, ty3, 
    tx4, ty4
  }

  --
  self.total_ammo = 25
  self.current_ammo = 0
  self.fire_rate = 0.08
  self.refill_rate = 0.23
  
  
  
  --gauge examples
  self.ammo_value = gauge:new(self.position.x - self.dimension.x/2, 
                              self.position.y - self.dimension.y, 
                              self.dimension.x  * 2,
                            6,
                              2*math.pi,
                              15,
                              self.total_ammo,
                              nil)
  self.ammo_bar = gauge:new(self.position.x - self.dimension.x/2, 
                            self.position.y - self.dimension.y, 
                            self.dimension.x  * 2,
                            6,
                            2*math.pi,
                            15,
                            self.total_ammo,
                            nil)


  self.ammo_value_w = gauge:new(self.position.x + self.dimension.x/2, 
                              self.position.y - self.dimension.y*(3/2), 
                              self.dimension.x  * 2,
                              6,
                              2*math.pi,
                              5,
                              self.total_ammo,
                              nil)
  self.ammo_wheel = gauge:new(self.position.x + self.dimension.x/2, 
                            self.position.y - self.dimension.y*(3/2), 
                            self.dimension.x  * 2,
                            6,
                            0,
                            5,
                            self.total_ammo,
                            nil)
  

  self.hp_bar = gauge:new(self.position.x - self.dimension.x/2, 
                          self.position.y - self.dimension.y/2, 
                          self.dimension.x  * 2,
                          6,
                          2*math.pi,
                          15,
                          self.hp,
                          nil)
  self.hp_value = gauge:new(self.position.x - self.dimension.x/2, 
                            self.position.y - self.dimension.y/2, 
                            self.dimension.x  * 2,
                            6,
                            2*math.pi,
                            15,
                            self.hp,
                            nil)
    
  
  self.last_x = 0
  self.last_y = 0
  self.current_anim = self.idle_anim
end


function Player:update_other_hitbox()
  
    --moving the slash hitbox

    local hitbox_dist = 12
    local tx1 = self.position.x + self.dimension.x/2 + hitbox_dist
    local ty1 = self.position.y + self.dimension.y/2 - self.frame_size/1.5

    local tx2 = self.position.x + self.dimension.x/2 + hitbox_dist
    local ty2 = self.position.y + self.dimension.y/2 + self.frame_size/1.5
    
    local tx3 = self.position.x + self.dimension.x/2 + hitbox_dist + self.frame_size/2 
    local ty3 = math.abs(ty2 - ty1) - (math.abs(ty2 - ty1)/4) + ty1

    local tx4 = self.position.x + self.dimension.x/2 + hitbox_dist + self.frame_size/2 
    local ty4 = math.abs(ty2 - ty1)/4 + ty1

    self.slash_verts[1] = tx1
    self.slash_verts[2] = ty1
    self.slash_verts[3] = tx2
    self.slash_verts[4] = ty2
    self.slash_verts[5] = tx3
    self.slash_verts[6] = ty3
    self.slash_verts[7] = tx4
    self.slash_verts[8] = ty4

    
    for i = 1, #self.slash_verts, 2  do
      local x_ind = i
      local y_ind = i + 1
      
      
      --self.slash_verts[x_ind] = self.slash_verts[x_ind] + self.velocity.x * dt
      --self.slash_verts[y_ind] = self.slash_verts[y_ind] + self.velocity.y * dt
    
      --moving the positions
      local x,y = self.slash_verts[x_ind], self.slash_verts[y_ind]
      --rotating the hitbox
      local tx, ty = self.position.x + self.dimension.x/2,  self.position.y + self.dimension.y/2
      --making origin centric
      x, y = self.transformer:translate_2D(-tx, -ty, x, y)
      --applying transformation
      x, y =self.transformer:rotate_2D(self.angle_convert:degrees_to_radians(self.angle), x, y)
      --moving back to original position
      self.slash_verts[x_ind], self.slash_verts[y_ind] = self.transformer:translate_2D(tx, ty, x, y)


    
    end
end



function Player:fire_bullets(dt)
  --updates angle
  
    
  local angle = lume.angle(
                        self.position.x + (self.dimension.x/2),
                        self.position.y + (self.dimension.y/2), 
                        self.mouse_vector.x, 
                        self.mouse_vector.y
                      )

  self.angle = self.angle_convert:radians_to_degrees(angle)


  self.sin = math.sin(angle)
  self.cos = math.cos(angle)

  self.fire_rate = self.fire_rate - dt
  self.refill_rate = 0.1 + dt
  if self.fire_rate <= 0 and self.current_ammo > 0 then
    
    self.current_ammo = self.current_ammo - 1
    
    --adding randoness to the bullet launch
    --angle = self.angle_convert:degrees_to_radians(self.angle + love.math.random(-15, 15))
    local a_sin = math.sin(angle)
    local a_cos = math.cos(angle)


    --print("yep")
    local dist = math.max(WORLD_LEVEL_HEIGHT, WORLD_LEVEL_WIDTH) * 5
    local x_target = self.position.x + self.dimension.x/2 + dist * a_cos
    local y_target = self.position.y + self.dimension.y/2 + dist * a_sin
    local target_position = Vector2(x_target, y_target)
    local position = {x = self.line.x2, y = self.line.y2}

    local dimesions = {w = 5, h = 5}
    local t = Bullet(
      position,
      dimesions,
      10,
      self.bullet_img_path,
      0 * TILESIZE,
      3 * TILESIZE,
      false,
      Projectiles
    )
    --bullet owner ship
    t.owner = "player"
    --adding velocity so bullets have a constant speed as the player moves
    --t.move_speed = self.move_speed + t.move_speed
    t.target_position = target_position
    

    

    --meant to help the hitbox keep up with the sudden velocity change
    local last_pos_x = self.position.x
    local last_pos_y = self.position.y

    --knockback, works when friction is less than 1
    --self.velocity.x = lume.lerp(self.velocity.x, self.velocity.x + -t.move_speed * a_cos, self.acceleration/2)
    --self.velocity.y = lume.lerp(self.velocity.y, self.velocity.y + -t.move_speed * a_sin, self.acceleration/2)

    self.fire_rate = 0.20 --+ love.math.random(0.05, 0.08) 
    
    local pos_x_change = self.position.x - last_pos_x
    local pos_y_change = self.position.y - last_pos_y
    
    --[[
    for i = 1, #self.hitbox, 2  do
      local x_ind = i
      local y_ind = i + 1
      --keeping the hitbox aligned with the position
      self.hitbox[x_ind] = self.hitbox[x_ind] + pos_x_change
      self.hitbox[y_ind] = self.hitbox[y_ind] + pos_y_change
    end
    ]]--
    
  end
  
end

function Player:reset(array_2d, floor_tile)
  local viable_tiles = {}
  self.hp = self.og_hp
  self.state = "idle"
  for y = 1,#array_2d do
    for x = 1,#array_2d[y] do
      if array_2d[y][x] == floor_tile  then
        table.insert(viable_tiles, Vector2(x * TILESIZE, y * TILESIZE))
      end
    end
  end
  
  self.position = viable_tiles[math.floor(#viable_tiles * love.math.random())] 
  --print(#viable_tiles, tostring(viable_tiles[1]), self.position)
  self.is_dead = false
  self.is_dying = false
  self.fade_time = 0
  self.fade_duration = 1
  self.fade_shader:send("time", self.fade_time)
  self.fade_shader:send("duration", self.fade_duration)
  love.graphics.setShader(self.fade_shader)
  love.graphics.setShader()
end

function Player:update(dt)
    --hump camera
    local mx,my = CAM:worldCoords(love.mouse.getPosition())
    
    --kikito's gamera
    --local mx, my = GAM:toWorld(love.mouse.getPosition())
    --gam:setPosition(self.x + self.w/2,self.y + self.h/2)
    CAM:lookAt(self.position.x + self.dimension.x/2,self.position.y + self.dimension.y/2)
    self.mx = mx 
    self.my = my 
    self.mouse_vector.x = self.mx 
    self.mouse_vector.y = self.my
    

    self.delta_time = dt
    local lmb = love.mouse.isDown(1)
    local rmb = love.mouse.isDown(2)
    --self:update_line_angle(dt)


    --current movement options
    
    --self:tank_movement(dt)
    --self:topdown_2d_movement(dt)
  
    --self:platformer_2d_movement(dt)
    --self:tile_button_movement(dt,self.walkable_tile,self.unreachable_tile)
    --self:follow_target_tile(dt,self.walkable_tile, self.target_position)
    


    --left mouse button
    if  not self.is_defending 
    and not self.is_slashing 
    and not self.is_hurting 
    and not self.is_dead 
    and not self.is_dying 
    then
      
      if lmb and not rmb then
        --updates angle and position
        self.target_position = self.mouse_vector
        --self.state = "walk"
        self:follow_target(self.target_position,dt)
      end


      if lmb then
        self.state = "walk"
      else
        self.state = "idle"
      end
      --firing bullets
      --right mouse button
      if rmb  then
        --updates line angle
        self:update_line_angle()
        --uses line angle 
        self:fire_bullets(dt)
        --if self.velocity.x < 1 and self.velocity.x > -1 then

        self.state = "shoot"

          
        --end

      end
      
      if self.position.x + self.dimension.x/2 < self.mouse_vector.x then
        self.fx = -1
        
        
      else
        self.fx = 1
        
      end


      self:update_other_hitbox()
      self:update_hitbox_position()

      --refilling
      if self.current_ammo ~= self.total_ammo then
        self.refill_rate = self.refill_rate - dt
        if self.refill_rate < 0 then
          self.current_ammo = self.current_ammo + 1
          self.refill_rate = 0.23
        end
      end

    end
    
    
    if self.is_slashing then
      self.slash_mode = 'fill'
      self.slash_timer = self.slash_timer - dt
      

      if self.slash_timer <= 0 then
        self.slash_timer = self.hit_anim.ot * self.hit_anim.f
        self.is_slashing = false
        self.state = "idle"
        self.slash_mode = 'line'
      end
    elseif self.is_defending then
        
        self.defend_timer = self.defend_timer - dt
        
  
        if self.defend_timer <= 0 then
          self.defend_timer = 0.5
          self.is_defending = false
          self.state = "idle"
        end
    elseif self.is_hurting then
      
      self.hurt_timer = self.hurt_timer - dt
      

      if self.hurt_timer <= 0 then
        self.hurt_timer = 0.3
        self.is_hurting = false
        self.state = "idle"
        if self.hp <= 0 then
          self.is_dead = true
          self.state = "dead"
        end
      end
    
    
    elseif self.is_dying then
      
      self.dead_timer = self.dead_timer - dt
      self:animate(dt, self.dead_anim, self.quad)

      if self.dead_timer <= 0 then
        self.dead_timer = self.dead_anim.ot * self.dead_anim.f
        self.is_dying = false
        
        
        self.is_dead = true
        
        self.state = "dead"
        
      end

    else
      if not self.is_dead then
        if love.keyboard.isDown('z') then
          self.state = "attack"
          self.slash_mode = 'line'
          self.is_slashing = true
        elseif love.keyboard.isDown('x') then
          self.state = "defend"
          self.is_defending = true
        elseif love.keyboard.isDown('c') then
          --for testing
          self.state = "hurt"
          self.is_hurting = true
          self.hp = lume.clamp(self.hp - 1, 0, self.og_hp)
          if self.hp <= 0 then
            --self.current_anim = self.dead_anim
            self.is_dying = true
            self.state = "dead"
          end
          
        --elseif love.keyboard.isDown('r') then
          --restart
          --self:reset(map_tiles)
          
        end
      else
        if self.fade_time < self.fade_duration then
          self.fade_time = self.fade_time + dt
          self.fade_shader:send("time", self.fade_time)
          self.fade_shader:send("duration",self.fade_duration)
        else
          self.fade_shader:send("time", self.fade_duration)
        end
        
        
        if love.keyboard.isDown('r') then
          --restart
          self:reset(map_tiles)
          
        end
      end
    end

    
  
    
  
  if not self.is_dying then
    if self.state == "attack" then
      self.current_anim = self.hit_anim

    elseif self.state == "defend" then
      self.current_anim = self.dfnd_anim

    elseif self.state == "walk" then
      self.current_anim = self.walk_anim

    elseif self.state == "hurt" then
      self.current_anim = self.hurt_anim

    elseif self.state == "idle" then
      self.current_anim = self.idle_anim
    
    elseif self.state == "dead" then
      self.current_anim = self.dead_anim
    elseif self.state == "shoot" then
      self.current_anim = self.cast_anim
    end
    self:animate(dt, self.current_anim, self.quad)
  end
  self.ammo_value:set_value(self.current_ammo, false, true, false)
  self.hp_value:set_value(self.hp, false, true, false)
  self.ammo_value_w:set_value(self.current_ammo, false, false, true)
  
end



function Player:draw()
  if not self.is_dead then
    self.hp_bar:display_bar('line', self.position.x - self.dimension.x/2, self.position.y - self.dimension.y/2)
    self.hp_value:display_bar('fill', self.position.x - self.dimension.x/2, self.position.y - self.dimension.y/2)

    self.ammo_bar:display_bar('line', self.position.x - self.dimension.x/2, self.position.y - self.dimension.y)
    self.ammo_value:display_bar('fill', self.position.x - self.dimension.x/2, self.position.y - self.dimension.y)

    self.ammo_value_w:display_wheel('fill', self.position.x + self.dimension.x/2, self.position.y - self.dimension.y * (3/2))
    self.ammo_wheel:display_wheel('line', self.position.x + self.dimension.x/2, self.position.y - self.dimension.y * (3/2))
  end

  --self:draw_line()

  --if self.single_tile_input or self.mouse_tile_input then
  local boxx, boxy = self:world_to_array2d(self.mx, self.my) 
  boxx, boxy = self:array2d_to_world(boxx, boxy)
  
  
  love.graphics.rectangle("line",
    boxx,
    boxy,
    TILESIZE,
    TILESIZE)

  --self.slash_mode
  --love.graphics.polygon(self.slash_mode, self.slash_verts)
  if self.is_slashing then
    --print("slashing")
    love.graphics.draw(self.slash_img,
                        self.slash_quad,
                        self.position.x,
                        self.position.y + self.dimension.y/3,
                        0,
                        self.fx,
                        1, 
                      -(self.frame_size * (self.fx - 1))/2,
                      0)
  end

  if self.hurt_timer > 0.15  and self.hurt_timer < 0.25 then
    love.graphics.setShader(self.flash_shader)
    if self.quad ~= nil then
      love.graphics.draw(self.img,
                      self.quad,
                      self.position.x,
                      self.position.y,
                      0, 
                      self.fx, 
                      1, 
                      -(self.frame_size * (self.fx - 1))/2,
                      0)
    end
    love.graphics.setShader()
    
  elseif self.is_dead == true and self.is_dying == false then
    
    love.graphics.setShader(self.fade_shader)
    love.graphics.draw(self.img,
                      self.quad,
                      self.position.x,
                      self.position.y,
                      0, 
                      self.fx, 
                      1, 
                      -(self.frame_size * (self.fx - 1))/2,
                      0)
    love.graphics.setShader()
  else
    love.graphics.draw(self.img,
                      self.quad,
                      self.position.x,
                      self.position.y,
                      0, 
                      self.fx, 
                      1, 
                      -(self.frame_size * (self.fx - 1))/2,
                      0)
  end

  --love.graphics.polygon("line", self.hitbox)
  
  --self:display('line')
  
  
end





