require "entity"

Player = Entity:extend()
local tiny = 0.1



function Player:new(x,y,w,h,hp,image_path,quad_x,quad_y,group_table)
  Player.super.new(self,
    x,
    y,
    w,
    h,
    nil,
    image_path,
    quad_x,
    quad_y,
    true,
    group_table)
  
  --size of single frame in spritesheer
  
  --self.frame_size = 24
  self.max_speed = 200
  self.rotation_speed = 200
  self.single_tile_input = false
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
  local mx,my = cam:worldCoords(love.mouse.getPosition())
  --local mx, my = gam:toWorld(love.mouse.getPosition())
  cam:lookAt(self.x + self.w/2,self.y + self.h/2)
  --gam:setPosition(self.x + self.w/2,self.y + self.h/2)
  self.mx = mx 
  
  self.my = my 
  self.delta_time = dt
  --self:update_line_angle(dt)
  --self:tank_movement(dt)
  --self:topdown_2d_movement(dt)
  
  --self:follow_mouse_click_movement(self.mx,self.my,dt)
  --self:platformer_2d_movement(dt)
  --self:apply_gravity(dt)
  local walkable_tile = 2
  local unreachable_tile = 0
  self:continuous_tile_mouse_movement(dt,walkable_tile)
  self:continuous_tile_button_movement(dt,walkable_tile,unreachable_tile)
  
  
  
  
  
end






function Player:draw()

  --self:draw_line()
  --[[
  if love.mouse.isDown(1) then
    love.graphics.line(self.x + self.w/2,
      self.y + self.h/2,
      self.mx,
      self.my)
  end]]--
--if self.single_tile_input or self.mouse_tile_input then
  local boxx = math.floor((self.mx/(level_width * TILESIZE)) * (level_width)) * TILESIZE
  local boxy = math.floor((self.my/(level_height * TILESIZE)) * (level_height)) * TILESIZE
  love.graphics.rectangle("line",
    boxx,
    boxy,
    TILESIZE,
    TILESIZE)
--end
  
  self:display('fill')

  

end





