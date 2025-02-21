require "entity"

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
    --self:continuous_tile_button_movement(dt,self.walkable_tile,self.unreachable_tile)
    --self:continuous_tile_mouse_movement(dt,self.walkable_tile)
    if love.mouse.isDown(1) then
      self:follow_target(mouse_vector,dt)
    end
    self:update_hitbox_position()
    
end






function Player:draw()
  
  --self:draw_line()

  --if self.single_tile_input or self.mouse_tile_input then
  local boxx, boxy = self:world_to_array2d(self.mx, self.my) 
  local boxx, boxy = self:array2d_to_world(boxx, boxy)
  --local boxx = math.floor((self.mx/(level_width * TILESIZE)) * (level_width)) * TILESIZE
  --local boxy = math.floor((self.my/(level_height * TILESIZE)) * (level_height)) * TILESIZE
  
  love.graphics.rectangle("line",
    boxx,
    boxy,
    TILESIZE,
    TILESIZE)

  
  self:display('line')

  

end





