local angle_convert = {}
angle_convert.__index = angle_convert

function angle_convert:new()
  return setmetatable( {} , self)
end

function angle_convert:degrees_to_radians(degree)
  return (degree * math.pi) / 180
end

function angle_convert:radians_to_degrees(radian)
  return radian * ( 180 / math.pi )
end

return angle_convert











