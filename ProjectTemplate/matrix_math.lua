-- Importing math library for Lua
--same as matrixmath lua, but doesn't constantly create tables
--just returns points altered
--slightly less intuitive than matrix multiplication
local math = require("math")

function display(arr2d)
    for i, row in ipairs(arr2d) do
        print(table.concat(row, ", "))
    end
end


function translate_2D(tx, ty , x, y)

    --all transfornations outside the origin must be relocated to it vis this matrix first
	--and then back

    x = x + tx
    y = y + ty
    return x, y
end


function rotate_2D(radians, x, y)
    x = (x * math.cos(radians)) - (y * math.sin(radians))
    y = (x * math.sin(radians)) + (y * math.cos(radians))
    return x, y
end


function shear_2D(sx, sy, x, y)
    x = x + (y * sx)
    y = (x * sy) + y
    return x, y
end


function scale_2D(sx, sy, x, y)
    x = x * sx
    y = y * sy
    return x, y 
end


function reflect_2D(rx, ry, x, y)
    x = x * rx
    y = y * ry
    return x, y 
end

function scale_3D(sx, sy, sz, x, y, z)
    x = x * sx
    y = y * sy
    z = z * sz
    return x, y, z
end

function reflect_3D(rx, ry, rz, x, y, z)
    x = x * rx
    y = y * ry
    z = z * rz
    return x, y, z
end

function translate_3D(tx, ty, tz, x, y, z)
    x = x + tx
    y = y + ty
    z = z + tz
    return x, y, z
end


function shear_3D(sxy, sxz, syz, syx, szx, szy, x, y, z)
    x = x + (y * sxy) + (z * sxz)
    y = (x * syx) + y + (z * syz)
    z = (x * szx) + (y * szy) + z
    return x, y, z
end


function x_rotate3D(radians, x, y, z)
    x = x
    y = (y * math.cos(radians)) - (z * math.sin(radians))
    z = (y * math.sin(radians)) + (z * math.cos(radians))
    return x, y, z
end


function y_rotate3D(radians, x, y, z)
    x = (x * math.cos(radians)) +  (z * math.sin(radians)) 
    y = y
    z = (-1 * x * math.sin(radians)) + (z * math.cos(radians))
    return x, y, z
end


function z_rotate3D(radians, x, y, z)
    x = (x * math.cos(radians)) - (y * math.sin(radians)) 
    y = (x * math.sin(radians)) + (y * math.cos(radians))
    z = z
    return x, y, z
end
