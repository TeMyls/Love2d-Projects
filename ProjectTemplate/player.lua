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

  --size of cell in the spritesheet
  self.frame_size = 24


  
  --slash hitbox stuff
  self.slash_timer = 0.2
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
  
  

  

  self.ammo_value = gauge:new(self.position.x - self.dimension.x/2, self.position.y - self.dimension.y, self.dimension.x  * 2, 6, self.total_ammo, nil)
  self.ammo_bar = gauge:new(self.position.x - self.dimension.x/2, self.position.y - self.dimension.y, self.dimension.x * 2, 6, self.total_ammo, nil)
  
  self.hp_bar = gauge:new(self.position.x - self.dimension.x/2, self.position.y - self.dimension.y/ 2, self.dimension.x * 2, 6, self.hp, nil)
  self.hp_value = gauge:new(self.position.x - self.dimension.x/2, self.position.y - self.dimension.y/ 2, self.dimension.x * 2, 6, self.hp, nil)

  
  self.last_x = 0
  self.last_y = 0
  
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
      nil,
      0,
      0,
      false,
      Projectiles
    )
    --bullet owner ship
    t.owner = "player"
    --adding velocity so bullets have a constant speed as the player moves
    t.move_speed = self.move_speed + t.move_speed
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
    --self:update_line_angle(dt)


    --current movement options
    
    --self:tank_movement(dt)
    --self:topdown_2d_movement(dt)
  
    --self:platformer_2d_movement(dt)
    --self:tile_button_movement(dt,self.walkable_tile,self.unreachable_tile)
    --self:follow_target_tile(dt,self.walkable_tile, self.mouse_vector)
    
    --left mouse button
    if love.mouse.isDown(1) then
      --updates angle and position
      self:follow_target(self.mouse_vector,dt)
    end
    
    
    self:update_other_hitbox()
    self:update_hitbox_position()


    if self.current_ammo ~= self.total_ammo then
      self.refill_rate = self.refill_rate - dt
      if self.refill_rate < 0 then
        self.current_ammo = self.current_ammo + 1
        self.refill_rate = 0.23
      end
    end



    


    --right mouse button
    if love.mouse.isDown(2) then
      --updates line angle
      self:update_line_angle()
      --uses line angle 
      self:fire_bullets(dt)
    end
    
    

    if self.is_slashing then
      self.slash_mode = 'fill'
      self.slash_timer = self.slash_timer - dt
      if self.slash_timer <= 0 then
        self.slash_timer = 0.2
        self.is_slashing = false
      end
    else
      self.slash_mode = 'line'
      if love.keyboard.isDown('z') then
        self.is_slashing = true
      end
    end
  
  self.ammo_value:set_value(self.current_ammo, false, true)
  self.hp_value:set_value(self.hp, false, true)
  
end

function Player:draw()
  self.hp_bar:display('line', self.position.x - self.dimension.x/2, self.position.y - self.dimension.y/2)
  self.hp_value:display('fill', self.position.x - self.dimension.x/2, self.position.y - self.dimension.y/2)

  self.ammo_bar:display('line', self.position.x - self.dimension.x/2, self.position.y - self.dimension.y)
  self.ammo_value:display('fill', self.position.x - self.dimension.x/2, self.position.y - self.dimension.y)
  self:draw_line()

  --if self.single_tile_input or self.mouse_tile_input then
  local boxx, boxy = self:world_to_array2d(self.mx, self.my) 
  local boxx, boxy = self:array2d_to_world(boxx, boxy)
  
  
  love.graphics.rectangle("line",
    boxx,
    boxy,
    TILESIZE,
    TILESIZE)

  love.graphics.polygon(self.slash_mode, self.slash_verts)
  love.graphics.polygon("line", self.hitbox)
  --self:display('line')

  

end





