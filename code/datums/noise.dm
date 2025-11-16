/datum/noise_generator
	var/seed = 0
	var/octaves = 7
	var/gain = 0.5
	var/offset = 0
	var/frequency = 1
	var/lacunarity = 1.89783

	var/list/grad2_lut
	var/list/grad3_lut
	var/list/perm_lut
	var/list/perm_mod12_lut

/datum/noise_generator/New(_seed = 0)
	..()
	seed = _seed
	if(seed == 0)
		seed = rand(-65535, 65535)

	//! Really don't fuck with these
	grad2_lut = list(1, 1, -1, 1, 1, -1, -1, -1, 1, 0, -1, 0, 1, 0, -1, 0, 0, 1, 0, -1, 0, 1, 0, -1)
	grad3_lut = list(1, 1, 0, -1, 1, 0, 1, -1, 0, -1, -1, 0, 1, 0, 1, -1, 0, 1, 1, 0, -1, -1, 0, -1, 0, 1, 1, 0, -1, 1, 0, 1, -1, 0, -1, -1)

	perm_lut = list(
		151, 160, 137, 91, 90, 15, 131, 13, 201, 95, 96, 53, 194, 233, 7, 225, 140, 36, 103, 30, 69, 142,
		8, 99, 37, 240, 21, 10, 23, 190, 6, 148, 247, 120, 234, 75, 0, 26, 197, 62, 94, 252, 219, 203, 117,
		35, 11, 32, 57, 177, 33, 88, 237, 149, 56, 87, 174, 20, 125, 136, 171, 168, 68, 175, 74, 165, 71,
		134, 139, 48, 27, 166, 77, 146, 158, 231, 83, 111, 229, 122, 60, 211, 133, 230, 220, 105, 92, 41,
		55, 46, 245, 40, 244, 102, 143, 54, 65, 25, 63, 161, 1, 216, 80, 73, 209, 76, 132, 187, 208, 89,
		18, 169, 200, 196, 135, 130, 116, 188, 159, 86, 164, 100, 109, 198, 173, 186, 3, 64, 52, 217, 226,
		250, 124, 123, 5, 202, 38, 147, 118, 126, 255, 82, 85, 212, 207, 206, 59, 227, 47, 16, 58, 17, 182,
		189, 28, 42, 223, 183, 170, 213, 119, 248, 152, 2, 44, 154, 163, 70, 221, 153, 101, 155, 167, 43,
		172, 9, 129, 22, 39, 253, 19, 98, 108, 110, 79, 113, 224, 232, 178, 185, 112, 104, 218, 246, 97,
		228, 251, 34, 242, 193, 238, 210, 144, 12, 191, 179, 162, 241, 81, 51, 145, 235, 249, 14, 239,
		107, 49, 192, 214, 31, 181, 199, 106, 157, 184, 84, 204, 176, 115, 121, 50, 45, 127, 4, 150, 254,
		138, 236, 205, 93, 222, 114, 67, 29, 24, 72, 243, 141, 128, 195, 78, 66, 215, 61, 156, 180,
		151, 160, 137, 91, 90, 15, 131, 13, 201, 95, 96, 53, 194, 233, 7, 225, 140, 36, 103, 30, 69, 142,
		8, 99, 37, 240, 21, 10, 23, 190, 6, 148, 247, 120, 234, 75, 0, 26, 197, 62, 94, 252, 219, 203, 117,
		35, 11, 32, 57, 177, 33, 88, 237, 149, 56, 87, 174, 20, 125, 136, 171, 168, 68, 175, 74, 165, 71,
		134, 139, 48, 27, 166, 77, 146, 158, 231, 83, 111, 229, 122, 60, 211, 133, 230, 220, 105, 92, 41,
		55, 46, 245, 40, 244, 102, 143, 54, 65, 25, 63, 161, 1, 216, 80, 73, 209, 76, 132, 187, 208, 89,
		18, 169, 200, 196, 135, 130, 116, 188, 159, 86, 164, 100, 109, 198, 173, 186, 3, 64, 52, 217, 226,
		250, 124, 123, 5, 202, 38, 147, 118, 126, 255, 82, 85, 212, 207, 206, 59, 227, 47, 16, 58, 17, 182,
		189, 28, 42, 223, 183, 170, 213, 119, 248, 152, 2, 44, 154, 163, 70, 221, 153, 101, 155, 167, 43,
		172, 9, 129, 22, 39, 253, 19, 98, 108, 110, 79, 113, 224, 232, 178, 185, 112, 104, 218, 246, 97,
		228, 251, 34, 242, 193, 238, 210, 144, 12, 191, 179, 162, 241, 81, 51, 145, 235, 249, 14, 239,
		107, 49, 192, 214, 31, 181, 199, 106, 157, 184, 84, 204, 176, 115, 121, 50, 45, 127, 4, 150, 254,
		138, 236, 205, 93, 222, 114, 67, 29, 24, 72, 243, 141, 128, 195, 78, 66, 215, 61, 156, 180)

	perm_mod12_lut = list(
		7, 4, 5, 7, 6, 3, 11, 1, 9, 11, 0, 5, 2, 5, 7, 9, 8, 0, 7, 6, 9,
		10, 8, 3, 1, 0, 9, 10, 11, 10, 6, 4, 7, 0, 6, 3, 0, 2, 5, 2, 10,
		0, 3, 11, 9, 11, 11, 8, 9, 9, 9, 4, 9, 5, 8, 3, 6, 8, 5, 4, 3,
		0, 8, 7, 2, 9, 11, 2, 7, 0, 3, 10, 5, 2, 2, 3, 11, 3, 1, 2, 0,
		7, 1, 2, 4, 9, 8, 5, 7, 10, 5, 4, 4, 6, 11, 6, 5, 1, 3, 5, 1,
		0, 8, 1, 5, 4, 0, 7, 4, 5, 6, 1, 8, 4, 3, 10, 8, 8, 3, 2, 8, 4,
		1, 6, 5, 6, 3, 4, 4, 1, 10, 10, 4, 3, 5, 10, 2, 3, 10, 6, 3,
		10, 1, 8, 3, 2, 11, 11, 11, 4, 10, 5, 2, 9, 4, 6, 7, 3, 2, 9,
		11, 8, 8, 2, 8, 10, 7, 10, 5, 9, 5, 11, 11, 7, 4, 9, 9, 10, 3,
		1, 7, 2, 0, 2, 7, 5, 8, 4, 10, 5, 4, 8, 2, 6, 1, 0, 11, 10, 2,
		1, 10, 6, 0, 0, 11, 11, 6, 1, 9, 3, 1, 7, 9, 2, 11, 11, 1, 0,
		10, 7, 1, 7, 10, 1, 4, 0, 0, 8, 7, 1, 2, 9, 7, 4, 6, 2, 6, 8,
		1, 9, 6, 6, 7, 5, 0, 0, 3, 9, 8, 3, 6, 6, 11, 1, 0, 0, 7, 4, 5,
		7, 6, 3, 11, 1, 9, 11, 0, 5, 2, 5, 7, 9, 8, 0, 7, 6, 9, 10, 8,
		3, 1, 0, 9, 10, 11, 10, 6, 4, 7, 0, 6, 3, 0, 2, 5, 2, 10, 0, 3,
		11, 9, 11, 11, 8, 9, 9, 9, 4, 9, 5, 8, 3, 6, 8, 5, 4, 3, 0, 8,
		7, 2, 9, 11, 2, 7, 0, 3, 10, 5, 2, 2, 3, 11, 3, 1, 2, 0, 7, 1,
		2, 4, 9, 8, 5, 7, 10, 5, 4, 4, 6, 11, 6, 5, 1, 3, 5, 1, 0, 8,
		1, 5, 4, 0, 7, 4, 5, 6, 1, 8, 4, 3, 10, 8, 8, 3, 2, 8, 4, 1, 6,
		5, 6, 3, 4, 4, 1, 10, 10, 4, 3, 5, 10, 2, 3, 10, 6, 3, 10, 1,
		8, 3, 2, 11, 11, 11, 4, 10, 5, 2, 9, 4, 6, 7, 3, 2, 9, 11, 8,
		8, 2, 8, 10, 7, 10, 5, 9, 5, 11, 11, 7, 4, 9, 9, 10, 3, 1, 7, 2,
		0, 2, 7, 5, 8, 4, 10, 5, 4, 8, 2, 6, 1, 0, 11, 10, 2, 1, 10, 6,
		0, 0, 11, 11, 6, 1, 9, 3, 1, 7, 9, 2, 11, 11, 1, 0, 10, 7, 1,
		7, 10, 1, 4, 0, 0, 8, 7, 1, 2, 9, 7, 4, 6, 2, 6, 8, 1, 9, 6, 6,
		7, 5, 0, 0, 3, 9, 8, 3, 6, 6, 11, 1, 0, 0)

/datum/noise_generator/proc/scale(c, x, y)
	return (y - x) * (c + 1) / 2 + x

/datum/noise_generator/proc/noise2(x, y)
	x += seed
	y += seed

	var/n0, n1, n2
	var/s = (x + y) * 0.36602540378
	var/i = round(x + s)
	var/j = round(y + s)

	var/t = (i + j) * 0.2113248654
	var/x0 = x - (i - t)
	var/y0 = y - (j - t)

	var/i1, j1
	if(x0 > y0)
		i1 = 1
		j1 = 0
	else
		i1 = 0
		j1 = 1

	var/x1 = x0 - i1 + 0.2113248654
	var/y1 = y0 - j1 + 0.2113248654
	var/x2 = x0 - 1.0 + 2.0 * 0.2113248654
	var/y2 = y0 - 1.0 + 2.0 * 0.2113248654

	var/ii = i & 255
	var/jj = j & 255

	var/g1 = perm_mod12_lut[perm_lut[ii + perm_lut[jj + 1] + 1] + 1] * 2
	var/g2 = perm_mod12_lut[perm_lut[ii + i1 + perm_lut[jj + j1 + 1] + 1] + 1] * 2
	var/g3 = perm_mod12_lut[perm_lut[ii + 1 + perm_lut[jj + 2] + 1] + 1] * 2

	var/t0 = 0.5 - x0 * x0 - y0 * y0
	var/t1 = 0.5 - x1 * x1 - y1 * y1
	var/t2 = 0.5 - x2 * x2 - y2 * y2

	if(t0 < 0)
		n0 = 0.0
	else
		t0 *= t0
		n0 = t0 * t0 * (grad2_lut[g1 + 1] * x0 + grad2_lut[g1 + 2] * y0)

	if(t1 < 0)
		n1 = 0.0
	else
		t1 *= t1
		n1 = t1 * t1 * (grad2_lut[g2 + 1] * x1 + grad2_lut[g2 + 2] * y1)

	if(t2 < 0)
		n2 = 0.0
	else
		t2 *= t2
		n2 = t2 * t2 * (grad2_lut[g3 + 1] * x2 + grad2_lut[g3 + 2] * y2)

	return 70.0 * (n0 + n1 + n2)

/datum/noise_generator/proc/fbm2(x, y)
	var/total = 0.0
	var/ampl = 1

	x *= frequency
	y *= frequency

	for(var/i = 0, i < octaves, i++)
		total += (noise2(x, y) + offset) * ampl
		ampl *= gain

		x *= lacunarity
		y *= lacunarity

	return total

/datum/noise_generator/proc/poisson_disk_sampling(min_x, max_x, min_y, max_y, min_radius, max_attempts = 30)
	var/list/points = list()
	var/list/active = list()
	var/cell_size = min_radius / 1.414 // sqrt(2)
	var/grid_width = ceil((max_x - min_x) / cell_size) + 1
	var/grid_height = ceil((max_y - min_y) / cell_size) + 1
	var/list/grid = new /list(grid_width * grid_height)

	var/first_x = min_x + rand() * (max_x - min_x)
	var/first_y = min_y + rand() * (max_y - min_y)

	points += list(list(first_x, first_y))
	active += list(list(first_x, first_y))

	var/gx = floor((first_x - min_x) / cell_size)
	var/gy = floor((first_y - min_y) / cell_size)
	grid[gy * grid_width + gx + 1] = list(first_x, first_y)

	while(length(active) > 0)
		var/rand_idx = rand(1, length(active))
		var/list/point = active[rand_idx]
		var/found = FALSE

		for(var/attempt = 1 to max_attempts)
			var/angle = rand() * 360
			var/radius = min_radius * (1 + rand())
			var/new_x = point[1] + cos(angle) * radius
			var/new_y = point[2] + sin(angle) * radius

			if(new_x < min_x || new_x >= max_x || new_y < min_y || new_y >= max_y)
				continue

			var/new_gx = floor((new_x - min_x) / cell_size)
			var/new_gy = floor((new_y - min_y) / cell_size)

			var/valid = TRUE
			for(var/dx = -2 to 2)
				for(var/dy = -2 to 2)
					var/check_x = new_gx + dx
					var/check_y = new_gy + dy

					if(check_x < 0 || check_x >= grid_width || check_y < 0 || check_y >= grid_height)
						continue

					var/grid_idx = check_y * grid_width + check_x + 1
					var/list/neighbor = grid[grid_idx]
					if(!neighbor)
						continue

					var/dist_x = new_x - neighbor[1]
					var/dist_y = new_y - neighbor[2]
					var/dist = sqrt(dist_x * dist_x + dist_y * dist_y)

					if(dist < min_radius)
						valid = FALSE
						break

				if(!valid)
					break

			if(valid)
				var/list/new_point = list(new_x, new_y)
				points += list(new_point)
				active += list(new_point)
				grid[new_gy * grid_width + new_gx + 1] = new_point
				found = TRUE
				break

		if(!found)
			active.Cut(rand_idx, rand_idx + 1)

	return points

/datum/noise_generator/proc/generate_voronoi_cells(min_x, max_x, min_y, max_y, num_cells)
	var/list/cells = list()

	// Generate random seed points for Voronoi cells
	for(var/i = 1 to num_cells)
		var/seed_x = min_x + rand() * (max_x - min_x)
		var/seed_y = min_y + rand() * (max_y - min_y)
		cells += list(list("x" = seed_x, "y" = seed_y, "id" = i))

	return cells

/datum/noise_generator/proc/get_voronoi_cell(x, y, list/cells)
	var/closest_cell = null
	var/min_dist = INFINITY

	for(var/list/cell in cells)
		var/dx = x - cell["x"]
		var/dy = y - cell["y"]
		var/dist = sqrt(dx * dx + dy * dy)

		if(dist < min_dist)
			min_dist = dist
			closest_cell = cell

	return closest_cell
