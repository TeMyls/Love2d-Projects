function display(array2d)
    local s = ""
    for y = 1, #array2d do
        s = s.."["
        for x = 1, #array2d[y] do
            s = "\n"..s.." "..tostring(array2d[y][x])
        end
        s = s.."]".."\n"
    end
    print(s)
end

function translate_origin_2d(x, y)
    local origin_t ={
        {1 , 0, -x},
        {0, 1, -y},
        {0, 0, 1}

    }
    return origin_t
end 

function new_matrix(rows,cols)
    local matrix = {}
    local c = 0
    for y = 1,rows do
        table.insert(matrix,{})
        for x = 1,cols do
            matrix[y][x] = c
            c = c + 1
        end
      end
	return matrix
end

-- Clockwise 2D rotation
function xy_rotate2d_cw(radians)
    local rotation_xy = {
        {math.cos(radians), -math.sin(radians)},
        {math.sin(radians), math.cos(radians)}
    }
    return rotation_xy
end

-- Counterclockwise 2D rotation
function xy_rotate2d_cc(radians)
    local rotation_xy = {
        {math.cos(radians), math.sin(radians)},
        {-math.sin(radians), math.cos(radians)}
    }
    return rotation_xy
end

-- 3D rotation around X-axis
function x_rotate3d(radians)
    local rotation_x = {
        {1.0, 0.0, 0.0},
        {0.0, math.cos(radians), -math.sin(radians)},
        {0.0, math.sin(radians), math.cos(radians)}
    }
    return rotation_x
end

-- 3D rotation around Y-axis
function y_rotate3d(radians)
    local rotation_y = {
        {math.cos(radians), 0.0, math.sin(radians)},
        {0.0, 1.0, 0.0},
        {-math.sin(radians), 0.0, math.cos(radians)}
    }
    return rotation_y
end

-- 3D rotation around Z-axis
function z_rotate3d(radians)
    local rotation_z = {
        {math.cos(radians), -math.sin(radians), 0.0},
        {math.sin(radians), math.cos(radians), 0.0},
        {0.0, 0.0, 1.0}
    }
    return rotation_z
end

function scalar_multiply(a_matrix, scalar)
    local rows_a = #a_matrix
    local cols_a = #a_matrix[1]


    local result = new_matrix(rows_a, cols_a)
    
    for y = 1, rows_a do
        for x = 1, cols_a do
            result[y][x] = a_matrix[y][x] * scalar
        end
    end
    
   
    return result
end

function scalar_divide(a_matrix, scalar)
    local rows_a = #a_matrix
    local cols_a = #a_matrix[1]


    local result = new_matrix(rows_a, cols_a)
    
    for y = 1, rows_a do
        for x = 1, cols_a do
            result[y][x] = a_matrix[y][x] / scalar
        end
    end
    
   
    return result
end

-- Matrix addition
function matrix_addition(a_matrix, b_matrix)
    local rows_a = #a_matrix
    local cols_a = #a_matrix[1]
    local rows_b = #b_matrix
    local cols_b = #b_matrix[1]
    
    if rows_a ~= rows_b or cols_a ~= cols_b then
        print("Both matrices must be the same dimensions")
        return
    elseif rows_a == 0 or cols_a == 0 then
        print("Empty")
        return
    end
    
    local result = new_matrix(rows_a, cols_a)
    
    for y = 1, rows_a do
        for x = 1, cols_a do
            result[y][x] = a_matrix[y][x] + b_matrix[y][x]
        end
    end
    
   
    return result
end

-- Matrix subtraction
function matrix_subtraction(a_matrix, b_matrix)
    local rows_a = #a_matrix
    local cols_a = #a_matrix[1]
    local rows_b = #b_matrix
    local cols_b = #b_matrix[1]
    
    if rows_a ~= rows_b or cols_a ~= cols_b then
        print("Both matrices must be the same dimensions")
        return
    elseif rows_a == 0 or cols_a == 0 then
        print("Empty")
        return
    end
    
    local result = new_matrix(rows_a, cols_a)
    
    for y = 1, rows_a do
        for x = 1, cols_a do
            result[y][x] = a_matrix[y][x] - b_matrix[y][x]
        end
    end
    
    
    return result
end


function matrix_multiply(a_matrix, b_matrix)
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

	--#display(a_matrix)
	--#display(b_matrix)
	
	--#result = new_matrix(min(rows_b,rows_a),min(cols_a,cols_b))
   
	
	local result = {}
	if rows_a == cols_b then
		result = new_matrix(rows_b,cols_a)
		for ax = 1, cols_a do
			
			for by = 1, rows_b  do
				local prod = 0
				for bx = 1,cols_b do
					--print(a_matrix[bx][ax]," times ", b_matrix[by][bx])
					prod = prod + a_matrix[bx][ax] * b_matrix[by][bx]
				--#result[ax].append(product)
                end
				result[by][ax] = prod
            end
				
		end
    elseif cols_a == rows_b then
		result = new_matrix(rows_a,cols_b)
		for bx = 1 , cols_b do 
			for ay = 1 ,rows_a  do
			--#for by in range(rows_b):
				local prod = 0
				for ax = 1 ,cols_a do 
				--#for bx in range(cols_b):
					--print(b_matrix[ax][bx]," times ", a_matrix[ay][ax])
					prod = prod +  b_matrix[ax][bx] * a_matrix[ay][ax]
                end
				
				result[ay][bx] = prod
            end
        end
				
			--#print()
    end
			
		
			
	--#display(result)
	return result		
end