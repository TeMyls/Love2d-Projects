Bullet = Entity:extend()
local tiny = 0.1



function Bullet:new(x,y,w,h,hp,image_path,quad_x,quad_y,group_table,move_speed)
  Bullet.super.new(self,
    x,
    y,
    w,
    h,
    nil,
    nil,
    quad_x,
    quad_y,
    true,
    group_table)
  self.move_speed = move_speed
  self.max_speed = 300
end

function Bullet:follow_target(target_x,target_y,dt)
  --mouse movement
  


    
  --distance between the two objects
    
    --local HorDiz = target_x - self.x + (self.w/2)
    --local VertDiz = target_y - self.y + (self.h/2)
  local angle = math.atan2(target_y - (self.y+self.h/2),target_x - (self.x+self.w/2))
    --love.graphics.print(tostring(angle),self.x -10,self.y)
    --local a = HorDiz ^ 2
    --local b = VertDiz ^ 2
    
    --local c = a + b
    
    --if c > 5 then
 

      
      
  local mouse_siny = math.sin(angle)
  local mouse_cosx = math.cos(angle)
  self.vx = self.move_speed * mouse_cosx
  self.vy = self.move_speed * mouse_siny
   
end