#define XY_TO_INDEX(x, y, maxx) ((y - 1) * maxx + x)
#define INDEX_TO_X(idx, maxx) (((idx - 1) % maxx) + 1)
#define INDEX_TO_Y(idx, maxx) ((idx - 1) / maxx) + 1
#define INDEX_TO_XY(idx, x_name, y_name, maxx) \
	var/_i_1 = idx - 1; \
	var/x_name = (_i_1 % maxx) + 1; \
	var/y_name = (_i_1 / maxx) + 1;

#define MARK_TURF_CACHED(turf, mark_list, maxx, z) \
	mark_list[z][XY_TO_INDEX(turf.x, turf.y, maxx)] = TRUE;

#define MARK_SINGLE_TURF(turf) MARK_TURF_CACHED(turf, SSdemo.marked_turfs_by_z, world.maxx, turf.z)
