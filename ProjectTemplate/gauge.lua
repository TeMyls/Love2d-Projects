local gauge = {}
gauge.__index = gauge
--where things that go up and down come from
--divides is how many units the guage bar is divided into
function gauge:new(bar_x,bar_y,bar_w,bar_h,divides,img)
  self.bar_x, self.bar_y, self.bar_w, self.bar_h =  bar_x,bar_y,bar_w,bar_h


  --'og' means original
  self.og_width = bar_w
  self.og_height = bar_h
  self.divides = divides
  self.flipx = 1
  self.flipy = 1


  --quad positions
  self.qx = 0
  self.qy = 0
  self.img = img 
  self.quad = nil
  if self.img ~= nil then
    self.img = love.graphics.newImage(img)
    self.quad = love.graphics.newQuad(self.qx,self.qy,self.dimension.bar_x,self.dimension.bar_y,self.img)
  end
  


  self.t = 1
  self.cd = 1/self.t
  
  
  self.__index = self
  return setmetatable( {} , self)
end

function gauge:animate(dt,anim_array, quad, dir)
  dir = dir or 1
  
  
  if anim_array.f ~= 1 then
    anim_array.t = anim_array.t - dt
  end
    
  if anim_array.t <= 0  then
        
        
        
      anim_array.qx = anim_array.qx + 1 * dir
      anim_array.t = anim_array.ot
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


--current 
function gauge:slimWidth(cur)
  
  self.bar_w = self.og_width * (cur/self.divides)
end

function gauge:slimHeight(cur)
  self.bar_h = self.og_height * (cur/self.divides)
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



