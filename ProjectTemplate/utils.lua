function degrees_to_radians(degree)
  return (degree * math.pi) / 180
end

function radians_to_degrees(radian)
  return radian * ( 180 / math.pi )
end

function AABB_collision(a, b)
  return a.x < b.x + b.w --is the left of 'a' less than the right of 'b'
  and b.x < a.x + a.w  -- is the right of 'a' greater than the left of 'b'
  and a.y < b.y + b.h  -- is the top of 'a' less than the bottom of 'b'
  and b.y  < a.y + a.w -- is the bottom of 'a' greater than the top of 'b'   
end

function mouse_AABB_collision(mx, my, b)
  return mx < b.x + b.w --is the left of 'a' less than the right of 'b'
  and b.x < mx  -- is the right of 'a' greater than the left of 'b'
  and my < b.y + b.h  -- is the top of 'a' less than the bottom of 'b'
  and b.y  < a.y + a.w -- is the bottom of 'a' greater than the top of 'b'   
end

--https://www.jeffreythompson.org/collision-detection/table_of_contents.php
--collisions