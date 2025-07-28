local gauge = {}
gauge.__index = gauge
--where things that go up and down come from
--divides is how many units the guage bar is divided into
function gauge:new(gx,gy,bar_w,bar_h,wheel_a, wheel_r, divides,img)
  local this = {}
  this.gx = gx
  this.gy = gy
  this.bar_w = bar_w
  this.bar_h = bar_h
  this.wheel_a = wheel_a
  this.wheel_r = wheel_r


  --'og' means original
  this.og_width = bar_w
  this.og_height = bar_h
  this.og_area= 2 * math.pi
  this.divides = divides
  this.flipx = 1
  this.flipy = 1
  print(this.og_height)
  print(this.og_width)
  print(divides)

  --quad positions
  this.qx = 0
  this.qy = 0
  this.img = img 
  this.quad = nil
  this.dimension = Vector2.zero
  if this.img ~= nil then
    this.img = love.graphics.newImage(img)
    this.quad = love.graphics.newQuad(this.qx, this.qy, this.dimension.x, this.dimension.y, this.img)
  end
  
  this.current_value = 0

  this.this = 1
  this.cd = 1/this.this
  
  
  
  setmetatable( this ,self)
  return this
end

function gauge:animate(dt,anim_array, quad, dir)
  dir = dir or 1
  
  
  if anim_array.f ~= 1 then
    anim_array.this = anim_array.this - dt
  end
    
  if anim_array.this <= 0  then
        
        
        
      anim_array.qx = anim_array.qx + 1 * dir
      anim_array.this = anim_array.ot
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




--methods which act on the actor regardless

function gauge:set_value(value, vertical, horizontal, circular)

  self.current_value = value
  if not circular then
    if vertical and not horizontal then
      self:set_height()
    elseif not vertical and horizontal then
      self:set_width()
    end
  else
    self:set_area()
  end

end

--current 
function gauge:set_width()
  
  self.bar_w = self.og_width * (self.current_value/self.divides)

end

function gauge:set_height()
  self.bar_h = self.og_height * (self.current_value/self.divides)

end

function gauge:set_area()
  self.wheel_a = self.og_area * (1 - (self.current_value/self.divides))
end

--automatic refill
function gauge:auto(dt)
  if self.bar_w < self.og_width then
    self.bar_w = self.bar_w + self.og_width * (1/self.divides)
  end
  if self.bar_h < self.og_height then
    self.bar_h = self.bar_h + self.og_height * (1/self.divides)
  end
end


--one actually draws the other draws a box
function gauge:draw()
  love.graphics.draw(self.img,self.quad,self.gx,self.gy)
end

function gauge:display_bar(mode, x, y)
  --mode used to take the place of argument 1
  
  love.graphics.rectangle(mode, x, y,self.bar_w,self.bar_h)
end

function gauge:display_wheel(mode, x,  y)
  --mode used to take the place of argument 1
  --noteL wheel_a and og_area are angles in radians
  --love.graphics.circle("line", x, y, self.wheel_r)
  love.graphics.arc(mode, x, y, self.wheel_r,  self.wheel_a, self.og_area)
end

return gauge



