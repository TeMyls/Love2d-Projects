require "entity"

local gauge = require "gauge"
--really a boid
Enemy = Entity:extend()

function Enemy:new(position_table,dimension_table,hp,image_path,quad_x,quad_y,in_world,group_table)
    Enemy.super.new(self,
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
    self.rotation_speed = 600
    self.button_tile_input = true
    self.mouse_tile_input = false
    --mouse offeset
    self.mx = 0
    self.my = 0
    self.vy = 0
    self.friction = 0.1
    self.walkable_tile = 0
    self.unreachable_tile = 1
    self.fire_rate = 0.15
    self.line.length = 10
    self.mouse_vector = Vector2(self.mx, self.my)
    self.angle = love.math.random() * 360

    self.flash_timer = 0.1
    self.hurt_timer = 0.4
    self.state_timer = 0
    self.death_timer = 0.5

    self.alert_circle = {r = 130, x = 0, y = 0}
    self.push_circle = {r = self.dimension.x , x = 0, y = 0}
    self.mode = "fill"
    self.move_speed = 170
    --shape center
    local cx, cy = self.position.x + self.dimension.y/2, self.position.y + self.dimension.y/2

    local a1 = self.angle_convert:degrees_to_radians(90)
    local a2 = self.angle_convert:degrees_to_radians(180)
    local a3 = self.angle_convert:degrees_to_radians(270)
    --triangle coodinates
    local x1, y1 = cx + math.cos(a1) * (self.dimension.x/2), cy + math.sin(a1) * (self.dimension.y/2)
    local x2, y2 = cx + math.cos(a2) * (self.dimension.x/2), cy + math.sin(a2) * (self.dimension.y/2)
    local x3, y3 = cx + math.cos(a3) * (self.dimension.x/2), cy + math.sin(a3) * (self.dimension.y/2)

    self.hitbox = {
        x1, y1, 
        x2, y2,
        x3, y3,
    }
    local angle = self.angle_convert:degrees_to_radians(self.angle)
    self.target_position = self.position
    --self.target_position.x = 500 * math.cos(angle)
    --self.target_position.y = 500 * math.sin(angle)

    self.name = 'bad'

    self.states = {
        "idle",
        "pursuit",
        "wander",
        "hurt",
        "dying"
    }
    self.state = "idle"


    self.state = "wander"
    
    self.hp_bar = gauge:new(self.position.x - self.dimension.x/2, self.position.y - self.dimension.y/ 2, self.dimension.x * 2, 6, hp, nil)
    self.hp_value = gauge:new(self.position.x - self.dimension.x/2, self.position.y - self.dimension.y/ 2, self.dimension.x * 2, 6, hp, nil)
end
  
  
function Enemy:update(dt)
    if self.death_timer <= 0 then
        for i, v in ipairs(Enemies) do   
            if v == self then
                --print("ded")
                self:remove_from_group(Enemies, i)
            
            end
        end
    end

    if self.hp <= 0 then
        self.state = "dying"
    end


    if self.state ~= "dying" then

        
        if self.state == "hurt" then
            self.hurt_timer = self.hurt_timer - dt
            self.flash_timer = self.flash_timer - dt
            if self.hurt_timer <= 0 then
                self.hurt_timer = 0.7
                self.state = "wander"
                self.flash_timer = 0.1
                self.mode = 'fill'
            end
            if self.flash_timer <= 0 then
                self.flash_timer = 0.1
                if self.mode == 'fill' then
                    self.mode = 'line'
                else
                    self.mode = 'fill'
                end
            end
        end

        self.state_timer = self.state_timer - dt
        if self.state_timer <= 0 then
            if self.state == "wander" then
                self.mode = "fill"
                self.angle = love.math.random(0, 360)
                local angle = self.angle_convert:degrees_to_radians(self.angle)
                local dist = 500
                local a_sin = math.sin(angle)
                local a_cos = math.cos(angle)
                local x_target = self.position.x + self.dimension.x/2 + dist * a_cos
                local y_target = self.position.y + self.dimension.y/2 + dist * a_sin
                self.target_position.x = x_target
                self.target_position.y = y_target
                self.state_timer = 1 + love.math.random() * 2
                
            elseif self.state == "hurt" then
                if self.mode == "fill" then
                    self.mode = "line"
                else
                    self.mode = "fill"
                end
                self.state_timer = 0.1
            end
        end

        if #Protag > 0 then
            if self.collider:point_circle(
                Protag[1].position.x + Protag[1].dimension.x/2,
                Protag[1].position.y + Protag[1].dimension.y/2,
                self.position.x + self.dimension.x/2, 
                self.position.y + self.dimension.y/2,
                self.alert_circle.r
            ) then
                self.target_position = Protag[1].position + (Protag[1].dimension/2)
                self.state = "pursuit"
            else
                self.state = "wander"
            end
        end

        self:arena_wrap()
        --self:update_hitbox_position()
    
        self:follow_target(self.target_position, dt)
    end

    if self.state == "dying" then
        self.death_timer = self.death_timer - dt
        --self:spinout(dt)
    end

    self.alert_circle.x = self.position.x + self.dimension.x/2 
    self.alert_circle.y = self.position.y + self.dimension.y/2

    self.push_circle.x = self.position.x + self.dimension.x/2 
    self.push_circle.y = self.position.y + self.dimension.y/2


    --self.hp_bar = Gauge:new(self.position.x, self.position.y - self.dimension.y/ 2, self.dimension.x, 4, nil)
    --self.hp_value = Gauge:new(self.position.x, self.position.y - self.dimension.y/ 2, self.dimension.x, 4, hp, nil)


    self.hp_value:set_value(self.hp, false, true, false)

    

end



function Enemy:follow_target(a_vector,dt)
    
    local angle = lume.angle(self.position.x + (self.dimension.x/2), self.position.y + (self.dimension.y/2), a_vector.x, a_vector.y)
    self.angle = self.angle_convert:radians_to_degrees(angle)

    
    if not self.collider:point_circle(self.position.x + (self.dimension.x/2), self.position.y + (self.dimension.y/2), a_vector.x, a_vector.y, 10) then
        local a_sin = math.sin(angle)
        local a_cos = math.cos(angle)

    
    
        
        self.velocity.x = lume.lerp(self.velocity.x, 
                                    a_cos *  self.move_speed, 
                                    self.acceleration)
        self.velocity.y = lume.lerp(self.velocity.y, 
                                    a_sin *  self.move_speed, 
                                    self.acceleration)

                                
    end
    
    self:collide(dt)
end

function Enemy:collide(dt)
    --the actually collision code for the library used for the world
    self.last_y = self.position.y
    local x,y,vx,vy= self.position.x,self.position.y,self.velocity.x,self.velocity.y
 


    --[[
    if #Enemies > 1 then
        --keeps enemies from stacking on top of each other
        for i, v in ipairs(Enemies) do
            if v ~= self then
                if v.name == '' then
                    if self.collider:circle_circle(self.push_circle.x , self.push_circle.y, self.push_circle.r, 
                    v.push_circle.x, v.push_circle.y, v.push_circle.r) 
                    then
                        --the opposite direction of wherever its moving it
                        local angle = -lume.angle(self.position.x + (self.dimension.x/2), self.position.y + (self.dimension.y/2), v.position.x, v.position.y)
                        
                        local a_sin = math.sin(angle)
                        local a_cos = math.cos(angle)

                        vx = vx + a_cos *  1.2 * self.move_speed
                        vy = vy + a_sin *  1.2 * self.move_speed
                                    
                        
                        
                        
                    end
                end
            end
        end
    end]]--
    local futureX =  x + vx * dt
    local futureY =  y + vy * dt
    
  
    self.position.x = futureX
    self.position.y = futureY
    
end


--[[
function Enemy:arena_wrap()
    if not self.collider:polygon_circle(self.hitbox, CIRCLE_ARENA.x, CIRCLE_ARENA.y, CIRCLE_ARENA.r) then
      --CIRCLE_ARENA.fill = "fill"
      local angle = lume.angle(CIRCLE_ARENA.x, CIRCLE_ARENA.y, self.position.x, self.position.y) + math.pi --PI is half a rotation in radians
      local a_sin = math.sin(angle)
      local a_cos = math.cos(angle)
      self.position.x = CIRCLE_ARENA.x + CIRCLE_ARENA.r * a_cos
      self.position.y = CIRCLE_ARENA.y + CIRCLE_ARENA.r * a_sin
    else
      --CIRCLE_ARENA.fill = "line"
    end
    
  end
]]--
function Enemy:draw(dt)
    --self.hp_bar = gauge:new(self.position.x - self.dimension.x/2, self.position.y - self.dimension.y/ 2, self.dimension.x * 2, 6, hp, nil)
    --self.hp_value = gauge:new(self.position.x - self.dimension.x/2, self.position.y - self.dimension.y/ 2, self.dimension.x * 2, 6, hp, nil)

    self.hp_bar:display('line', self.position.x - self.dimension.x/2, self.position.y - self.dimension.y)
    self.hp_value:display('fill', self.position.x - self.dimension.x/2, self.position.y - self.dimension.y)
    
    love.graphics.polygon(self.mode,self.hitbox)
    love.graphics.circle("line", self.alert_circle.x, self.alert_circle.y, self.alert_circle.r)
    love.graphics.circle("line", self.push_circle.x, self.push_circle.y, self.push_circle.r)
end

