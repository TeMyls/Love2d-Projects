--Affine Transformations
--with and without the use of tables
local transformer = {}
transformer.__index = transformer
local  _cos, _sin  = math.cos, math.sin

------------------------------------------------------------------------------------------------
--creating tables



function transformer:new()
    return setmetatable( {} , self)
end

function transformer:display(arr2d)
    for i, row in ipairs(arr2d) do
        print(table.concat(row, ", "))
    end
end

function transformer:set_matrix2D(x, y)
    return {
        {x}, 
        {y}, 
        {1}
    }
end

function transformer:set_matrix3D(x, y, z)
    return {
            {x}, 
            {y}, 
            {z}, 
            {1}
        }
end

function transformer:get_2D_vertices(matrix2D)
    local x = matrix2D[1][1]
    local y = matrix2D[2][1]
    return x, y
end

function transformer:get_3D_vertices(matrix3D)
    local x = matrix3D[1][1]
    local y = matrix3D[2][1]
    local z = matrix3D[3][1]
    return x, y, z
end

function transformer:blank_matrix2D()
    return {
            {1, 0, 0}, 
            {0, 1, 0}, 
            {0, 0, 1}
        }
end

function transformer:translation_matrix2D(tx, ty)
    return {
            {1, 0, tx}, 
            {0, 1, ty}, 
            {0, 0, 1}
        }
end

function transformer:rotation_matrix2D(radians)
    local c = _cos(radians)
    local s = _sin(radians)
    return {
            {c, -s, 0}, 
            {s, c, 0}, 
            {0, 0, 1}
        }
end

function transformer:shear_matrix2D(sx, sy)
    return {
            {1, sx, 0}, 
            {sy, 1, 0}, 
            {0, 0, 1}
        }
end

function transformer:scale_matrix2D(sx, sy)
    return {
            {sx, 0, 0}, 
            {0, sy, 0}, 
            {0, 0, 1}
        }
end

function transformer:reflect_matrix2D(rx, ry)
    return {
            {rx, 0, 0}, 
            {0, ry, 0}, 
            {0, 0, 1}
        }
end

function transformer:blank_matrix3D()
    return {
            {1, 0, 0, 0}, 
            {0, 1, 0, 0}, 
            {0, 0, 1, 0}, 
            {0, 0, 0, 1}
        }
end

function transformer:reflection_matrix3D(rx, ry, rz)
    return {
            {rx, 0, 0, 0}, 
            {0, ry, 0, 0}, 
            {0, 0, rz, 0}, 
            {0, 0, 0, 1}
        }
end

function transformer:scale_matrix3D(sx, sy, sz)
    return {
            {sx, 0, 0, 0}, 
            {0, sy, 0, 0}, 
            {0, 0, sz, 0}, 
            {0, 0, 0, 1}
        }
end

function transformer:translation_matrix3D(tx, ty, tz)
    return {
            {1, 0, 0, tx}, 
            {0, 1, 0, ty}, 
            {0, 0, 1, tz}, 
            {0, 0, 0, 1}
        }
end

function transformer:shear_matrix3D(sxy, sxz, syz, syx, szx, szy)
    return {
            {1, sxy, sxz, 0}, 
            {syx, 1, syz, 0},
            {szx, szy, 1, 0}, 
            {0, 0, 0, 1}}
end

function transformer:x_rotation_matrix3D(radians)
    local c = _cos(radians)
    local s = _sin(radians)
    return {
            {1, 0, 0, 0}, 
            {0, c, -s, 0}, 
            {0, s, c, 0}, 
            {0, 0, 0, 1}
        }
end

function transformer:y_rotation_matrix3D(radians)
    local c = _cos(radians)
    local s = _sin(radians)
    return {
            {c, 0, s, 0}, 
            {0, 1, 0, 0}, 
            {-s, 0, c, 0}, 
            {0, 0, 0, 1}
        }
end

function transformer:z_rotation_matrix3D(radians)
    local c = _cos(radians)
    local s = _sin(radians)
    return {
            {c, -s, 0, 0}, 
            {s, c, 0, 0}, 
            {0, 0, 1, 0}, 
            {0, 0, 0, 1}
        }
end

function transformer:new_matrix(rows, cols)
    local result = {}
    for i = 1, rows do
        local row = {}
        for j = 1, cols do
            row[j] = 0
        end
        result[i] = row
    end
    return result
end

function transformer:multiply_matrix(a_matrix, b_matrix)
    --print(f"A rows: {rows_a} A cols: {cols_a}")
    --print("A MATRIX")
	--display(a_matrix)
	--print(f"B rows: {rows_b} B cols: {cols_b}")
    --print("B MATRIX")
	--display(b_matrix)

	local rows_a = #a_matrix
	local cols_a = #a_matrix[1]
	local rows_b = #b_matrix
	local cols_b = #b_matrix[1]
	

	if cols_a ~= rows_b and rows_a ~= cols_b then
		print("Matrix \"A\"s columns must be equal to Matrix \"B\"s rows")
		return 
    elseif rows_a == 0 or rows_b == 0 or cols_a == 0 or cols_a == 0 then
		print("Empty Matrix")
		return 
	end
	
	local result = {}
	if rows_a == cols_b then
		result = self:new_matrix(rows_b,cols_a)
		for ax = 1, cols_a do
			
			for by = 1, rows_b  do
				local prod = 0
				for bx = 1,cols_b do
					--print(a_matrix[bx][ax]," times ", b_matrix[by][bx])
					prod = prod + a_matrix[bx][ax] * b_matrix[by][bx]
                end
				result[by][ax] = prod
            end
				
		end
    elseif cols_a == rows_b then
		result = self:new_matrix(rows_a,cols_b)
		for bx = 1 , cols_b do 
			for ay = 1 ,rows_a  do
				local prod = 0
				for ax = 1 ,cols_a do 
					--print(b_matrix[ax][bx]," times ", a_matrix[ay][ax])
					prod = prod +  b_matrix[ax][bx] * a_matrix[ay][ax]
                end
				result[ay][bx] = prod
            end
        end
    end
	return result		
end

function transformer:matrix_multiply(a_matrix, b_matrix)
    local rows_a = #a_matrix
    local cols_a = #a_matrix[1]
    local rows_b = #b_matrix
    local cols_b = #b_matrix[1]

    if cols_a ~= rows_b and rows_a ~= cols_b then
        print("Matrix 'A's columns must equal Matrix 'B's rows")
        return nil
    end
    
    local result = {}
    local a = a_matrix
    local b = b_matrix

    if rows_a == cols_b and cols_a == rows_a then
        if rows_a + cols_b < cols_a + rows_b then
				a = b_matrix
				b = a_matrix
        else
            a = a_matrix
            b = b_matrix 
        end
    elseif rows_a == cols_b then
        a = a_matrix
        b = b_matrix

    elseif cols_a == rows_b then
        a = b_matrix
        b = a_matrix
    end

    for by = 1, #b do
        local new_row = {}
        for ax = 1, #a[1] do
            local product = 0
            for bx = 1, #b[1] do
                product = product + a[bx][ax] * b[by][bx]
            end
            table.insert(new_row, product)
        end
        table.insert(result, new_row)
    end
    return result
end

------------------------------------------------------------------------------------------------
--without creating tables

function transformer:translate_2D(tx, ty , x, y)

    --all transfornations outside the origin must be relocated to it vis this matrix first
	--and then back
    local _x = x + tx
    local _y = y + ty
    return _x, _y
end


function transformer:rotate_2D(radians, x, y)
    local c = _cos(radians)
    local s = _sin(radians)
    local _x = (x * c) - (y * s)
    local _y = (x * s) + (y * c)
    return _x, _y
end


function transformer:shear_2D(sx, sy, x, y)
    local _x = x + (y * sx)
    local _y = (x * sy) + y
    return _x, _y
end


function transformer:scale_2D(sx, sy, x, y)
    local _x = x * sx
    local _y = y * sy
    return _x, _y
end


function transformer:reflect_2D(rx, ry, x, y)
    local _x = x * rx
    local _y = y * ry
    return _x, _y
end

function transformer:scale_3D(sx, sy, sz, x, y, z)
    local _x = x * sx
    local _y = y * sy
    local _z = z * sz
    return _x, _y, _z
end

function transformer:reflect_3D(rx, ry, rz, x, y, z)
    local _x = x * rx
    local _y = y * ry
    local _z = z * rz
    return _x, _y, _z
end

function transformer:translate_3D(tx, ty, tz, x, y, z)
    local _x = x + tx
    local _y = y + ty
    local _z = z + tz
    return _x, _y, _z
end


function transformer:shear_3D(sxy, sxz, syz, syx, szx, szy, x, y, z)
    local _x = x + (y * sxy) + (z * sxz)
    local _y = (x * syx) + y + (z * syz)
    local _z = (x * szx) + (y * szy) + z
    return _x, _y, _z
end


function transformer:x_rotate3D(radians, x, y, z)
    local c = _cos(radians)
    local s = _sin(radians)
    local _x = x
    local _y = (y * c) - (z * s)
    local _z = (y * s) + (z * c)
    return _x, _y, _z
end


function transformer:y_rotate3D(radians, x, y, z)
    local c = _cos(radians)
    local s = _sin(radians)
    local _x = (x * c) +  (z * s) 
    local _y = y
    local _z = (-1 * x * s) + (z * c)
    return _x, _y, _z
end


function transformer:z_rotate3D(radians, x, y, z)
    local c = _cos(radians)
    local s = _sin(radians)
    local _x = (x * c) - (y * s) 
    local _y = (x * s) + (y * c)
    local _z = z
    return _x, _y, _z
end

return transformer