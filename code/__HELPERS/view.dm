/proc/getviewsize(view)
	if(!view) // Just to avoid any runtimes that could otherwise cause constant disconnect loops.
		stack_trace("Missing value for 'view' in getviewsize(), defaulting to world.view!")
		view = world.view

	if(isnum(view))
		var/totalviewrange = (view < 0 ? -1 : 1) + 2 * view
		return list(totalviewrange, totalviewrange)
	else if(isnull(view)) // assume world.view if view is null
		var/static/list/cached_world_view
		if(!cached_world_view)
			cached_world_view = getviewsize(world.view)
		return cached_world_view
	else
		var/list/viewrangelist = splittext(view, "x")
		return list(text2num(viewrangelist[1]), text2num(viewrangelist[2]))


/// Takes a string or num view, and converts it to pixel width/height in a list(pixel_width, pixel_height)
/proc/view_to_pixels(view)
	if(!view)
		return list(0, 0)
	var/list/view_info = getviewsize(view)
	view_info[1] *= world.icon_size
	view_info[2] *= world.icon_size
	return view_info

/**
* Frustrated with bugs in can_see(), this instead uses viewers for a much more effective approach.
* ### Things to note:
* - Src/source must be a mob. `viewers()` returns mobs.
* - Adjacent objects are always considered visible.
*/

/// The default tile-distance between two atoms for one to consider the other as visible.
#define DEFAULT_SIGHT_DISTANCE 7

/// Basic check to see if the src object can see the target object.
#define CAN_I_SEE(target) ((src in viewers(DEFAULT_SIGHT_DISTANCE, target)) || in_range(target, src))


/// Checks the visibility between two other objects.
#define CAN_THEY_SEE(target, source) ((source in viewers(DEFAULT_SIGHT_DISTANCE, target)) || in_range(target, source))


/// Further checks distance between source and target.
#define CAN_SEE_RANGED(target, source, dist) ((source in viewers(dist, target)) || in_range(target, source))

//Returns an in proportion scaled out view, with zoom_amt extra tiles on the y axis.
/proc/get_zoomed_view(view, zoom_amt)
	var/view_x
	var/view_y
	if(IS_SAFE_NUM(view))
		return view + zoom_amt
	else
		var/list/viewrangelist = splittext(view, "x")
		view_x = text2num(viewrangelist[1])
		view_y = text2num(viewrangelist[2])
		var/proportion = view_x / view_x
		view_x += zoom_amt * proportion
		view_y += zoom_amt
	//God, I hate that we have to round this.
	return "[round(view_x, 1)]x[round(view_y, 1)]"
