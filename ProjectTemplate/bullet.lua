require "entity"


Bullet = Entity:extend()

function Bullet:new(position_table,dimension_table,hp,image_path,quad_x,quad_y,in_world,group_table)
    Bullet.super.new(self,
    position_table,
    dimension_table,
    hp,
    image_path,
    quad_x,
    quad_y,
    in_world,
    group_table)
    self.target_position = self.position
    self.lifetime = 2
    self.collided = false
    self.move_speed = 180
    self.owner = ""
    self.r = math.max(dimension_table.w, dimension_table.h)


    
end

function Bullet:update(dt)
    self.lifetime = self.lifetime - dt
    if self.lifetime <= 0 then
        for i, v in ipairs(Projectiles) do   
            if v == self then
                self:remove_from_group(Projectiles, i)
            end
        end
    end
    if self.target_position then
        self:follow_target(self.target_position, dt)
    end

    for _, v in ipairs(Enemies) do
        if self.owner == "player" then
            if v.name == 'tris' then
                if v.state ~= "hurt" and v.state ~= "dying" then
                    if self.collider:polygon_circle(v.hitbox, 
                                                    self.position.x, 
                                                    self.position.y, 
                                                    self.r) then
                        v.state = "hurt"
                        v.state_timer = 0.0
                        v.hp = v.hp - 1
                        self.lifetime = 0
                    end
                end
            elseif v.name == 'doppel' then
                if v.state ~= "hurt" then
                    if self.collider:polygon_circle(v.hitbox, 
                                                    self.position.x, 
                                                    self.position.y, 
                                                    self.r) then
                        v.state = "hurt"
                        v.hp = v.hp - 1
                        self.lifetime = 0
                    end
                end
            end
        end
    end
    
end

function Bullet:arena_destroy()
  
    if not self.collider:circle_circle(self.position.x, self.position.y, self.r, CIRCLE_ARENA.x, CIRCLE_ARENA.y, CIRCLE_ARENA.r) then
      --CIRCLE_ARENA.fill = "fill"
      self.lifetime = 0
    else
      --CIRCLE_ARENA.fill = "line"
    end
    
    
end
  

function Bullet:follow_target(a_vector, dt)

  
    
  --distance between the two objects
    

    --local angle = math.atan2(mouse_y - (self.y+self.h/2),mouse_x - (self.x+self.w/2))
    --local angle = mouse_vector:angleTo(self.position + (self.dimension * 0.5))
    --self.position.x + (self.dimension.x/2)
    local angle = lume.angle(self.position.x + (self.dimension.x/2),self.position.y + (self.dimension.y/2), a_vector.x, a_vector.y)
    self.angle = self.angle_convert:radians_to_degrees(angle)
    

    
  if not self.collider:point_circle(self.position.x + (self.dimension.x/2), self.position.y + (self.dimension.y/2), a_vector.x, a_vector.y, 10) then

    self.sin = math.sin(angle)
    self.cos = math.cos(angle)
    self.velocity.x = lume.lerp(self.velocity.x, 
                                self.cos *  self.move_speed, 
                                self.acceleration)
    self.velocity.y = lume.lerp(self.velocity.y, 
                                self.sin *  self.move_speed, 
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

function Bullet:collide(dt)
    
    --the actually collision code for the library used for the world
    self.last_y = self.position.y
    local x,y,vx,vy= self.position.x,self.position.y,self.velocity.x,self.velocity.y
  
    local futureX =  x + vx * dt
    local futureY =  y + vy * dt
    
    self.position.x = futureX
    self.position.y = futureY
end

function Bullet:draw()
    local mode = ""
    if self.owner == "player" then
        mode = "line"
    else
        mode = "fill"
    end
    love.graphics.circle(mode, self.position.x, self.position.y, self.r, 5)
end