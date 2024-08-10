require "entity"

Tile = Entity:extend()

function Tile:new(x,y,tile_size_w,tile_size_h,hp,tile_image_path,quad_x,quad_y,x_table,breakable)
  Tile.super.new(self,
    x,
    y,
    tile_size_w,
    tile_size_h,
    hp,
    tile_image_path,
    quad_x,
    quad_y,
    false,
    x_table)
  self.breakable = breakable
  --self.img = love.graphics.newImage(tile_image_path)
  --self.quad = love.graphics.newQuad(quad_x,quad_y,tile_size_w,tile_size_h,self.img)
  --quad position
  self.qx = quad_x 
  self.qy = quad_y 
 
  local g = nil
  self.img = tile_image_path
  self.quad = nil
  if self.img ~= nil then
    self.img = love.graphics.newImage(tile_image_path)
    self.quad = love.graphics.newQuad(self.qx,self.qy,self.w,self.h,self.img)
    g = anim8.newGrid(tile_size_w,tile_size_h,self.img:getWidth(),self.img:getHeight(),0,0,0)
  end
  --column, row or image 
  self.quad = g(self.qx,self.qy)[1]
end



function Tile:take_damage()
  if self.hp <= 0 then
    
  end
  
end

function Tile:update(dt)
  
end




