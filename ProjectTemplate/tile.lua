require "entity"

Tile = Entity:extend()

function Tile:new(position_table,dimension_table,hp,tile_image_path,quad_x,quad_y,in_world,group_table)
  Tile.super.new(self,
    position_table,
    dimension_table,
    hp,
    tile_image_path,
    quad_x,
    quad_y,
    in_world,
    group_table
  )
  self.breakable = true
  --self.img = love.graphics.newImage(tile_image_path)
  --self.quad = love.graphics.newQuad(quad_x,quad_y,tile_size_w,tile_size_h,self.img)

  
end

function Tile:take_damage()
  if self.hp <= 0 then
    
  end
  
end

function Tile:update(dt)
  
end




