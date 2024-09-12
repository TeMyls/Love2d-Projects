require "entity"

Player = Entity:extend()
local tiny = 0.1



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

  
  
end









--[[
function Player:collide(dt)
  --the actually collision code for the library used for the world
  local x,y,vx,vy= self.x,self.y,self.vx,self.vy
  local futureX =  x + vx * dt
  local futureY =  y + vy * dt
  local nextX,nextY,cols,len = world:move(self,futureX,futureY)
  for i = 1 , len do
    local col = cols[i]
    local kind = col.other.class
     if col.normal.y == -1  then

      self.vy = tiny
    
    
    end
    
    if col.normal.y == 1  then
      self.vy = tiny
    
      
    
    end
  end
  
  self.x = nextX
  self.y = nextY
end
]]--
function Player:update(dt)
  --hump camera
  local mx,my = cam:worldCoords(love.mouse.getPosition())
  
  --kikito's gamera
  --local mx, my = gam:toWorld(love.mouse.getPosition())
  --gam:setPosition(self.x + self.w/2,self.y + self.h/2)
  cam:lookAt(self.position.x + self.dimension.x/2,self.position.y + self.dimension.y/2)
  self.mx = mx 
  self.my = my 
  local mouse_vector = Vector2(self.mx, self.my)

  self.delta_time = dt
  self:update_line_angle(dt)
  --self:tank_movement(dt)
  --self:topdown_2d_movement(dt)
  
  --self:follow_target(mouse_vector,dt)
  --self:platformer_2d_movement(dt)
  --self:apply_gravity(dt)
  local walkable_tile = 0
  local unreachable_tile = 1
  self:continuous_tile_mouse_movement(dt,walkable_tile)
  --self:continuous_tile_button_movement(dt,walkable_tile,unreachable_tile)
  
  
  
  
end






function Player:draw()

  self:draw_line()
  --[[
  if love.mouse.isDown(1) then
    love.graphics.line(self.x + self.w/2,
      self.y + self.h/2,
      self.mx,
      self.my)
  end]]--
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
--end
  
  self:display('line')

  

end





