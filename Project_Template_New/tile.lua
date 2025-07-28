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
  
end






