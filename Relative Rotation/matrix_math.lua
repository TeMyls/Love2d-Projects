--Importing math library for Lua
--same as matrixmath lua, but doesn't constantly create tables
--just returns points altered
--slightly less intuitive than matrix multiplication
local math = require("math")


function translate_2D(tx, ty , x, y)

    --all transfornations outside the origin must be relocated to it vis this matrix first
	--and then back
    local _x = x + tx
    local _y = y + ty
    return _x, _y
end


function rotate_2D(radians, x, y)
    local c = math.cos(radians)
    local s = math.sin(radians)
    local _x = (x * c) - (y * s)
    local _y = (x * s) + (y * c)
    return _x, _y
end


function shear_2D(sx, sy, x, y)
    local _x = x + (y * sx)
    local _y = (x * sy) + y
    return _x, _y
end


function scale_2D(sx, sy, x, y)
    local _x = x * sx
    local _y = y * sy
    return _x, _y
end


function reflect_2D(rx, ry, x, y)
    local _x = x * rx
    local _y = y * ry
    return x, y 
end

function scale_3D(sx, sy, sz, x, y, z)
    local _x = x * sx
    local _y = y * sy
    local _z = z * sz
    return _x, _y, _z
end

function reflect_3D(rx, ry, rz, x, y, z)
    local _x = x * rx
    local _y = y * ry
    local _z = z * rz
    return _x, _y, _z
end

function translate_3D(tx, ty, tz, x, y, z)
    local _x = x + tx
    local _y = y + ty
    local _z = z + tz
    return _x, _y, _z
end


function shear_3D(sxy, sxz, syz, syx, szx, szy, x, y, z)
    local _x = x + (y * sxy) + (z * sxz)
    local _y = (x * syx) + y + (z * syz)
    local _z = (x * szx) + (y * szy) + z
    return _x, _y, _z
end


function x_rotate3D(radians, x, y, z)
    local c = math.cos(radians)
    local s = math.sin(radians)
    local _x = x
    local _y = (y * c) - (z * s)
    local _z = (y * s) + (z * c)
    return _x, _y, _z
end


function y_rotate3D(radians, x, y, z)
    local c = math.cos(radians)
    local s = math.sin(radians)
    local _x = (x * c) +  (z * s) 
    local _y = y
    local _z = (-1 * x * s) + (z * c)
    return _x, _y, _z
end


function z_rotate3D(radians, x, y, z)
    local c = math.cos(radians)
    local s = math.sin(radians)
    local _x = (x * c) - (y * s) 
    local _y = (x * s) + (y * c)
    local _z = z
    return _x, _y, _z
end
