local gauge = {}
gauge.__index = gauge
--where things that go up and down come from
--divides is how many units the guage bar is divided into
function gauge:new(bar_x,bar_y,bar_w,bar_h,divides,img)
  local this = {}
  this.bar_x = bar_x
  this.bar_y = bar_y
  this.bar_w = bar_w
  this.bar_h = bar_h


  --'og' means original
  this.og_width = bar_w
  this.og_height = bar_h
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
  if this.img ~= nil then
    this.img = love.graphics.newImage(img)
    this.quad = love.graphics.newQuad(this.qx, this.qy, this.dimension.bar_x, this.dimension.bar_y, this.img)
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

function gauge:set_value(value, vertical, horizontal)

  self.current_value = value
  if vertical and not horizontal then
    self:set_height()
  elseif not vertical and horizontal then
    self:set_width()
  end

end

--current 
function gauge:set_width()
  
  self.bar_w = self.og_width * (self.current_value/self.divides)

end

function gauge:set_height()
  self.bar_h = self.og_height * (self.current_value/self.divides)

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
  love.graphics.draw(self.img,self.quad,self.bar_x,self.bar_y)
end

function gauge:display(mode,bar_x,bar_y)
  --mode used to take the place of argument 1
  love.graphics.rectangle(mode,bar_x,bar_y,self.bar_w,self.bar_h)
end

return gauge



