/// Movables with this component will automatically return to their original turf if moved outside a valid area
/datum/component/multi_area_bound
	///List of valid area instances/types, formatted as a typecache
	var/list/valid_areas
	///Do we use instances instead of types
	var/use_instances
	///Do we do a key value search instead of an (x in list) seach
	var/check_as_typecache
	///The turf we send our parent back to if they move out of allowed areas
	var/turf/reset_turf
	///Our area tracker datum
	var/datum/movement_detector/move_tracker
	var/moving = FALSE //Used to prevent infinite recursion if your reset turf places you somewhere on enter or something

/datum/component/multi_area_bound/Initialize(_valid_areas = list(), _use_instances = FALSE, _check_as_typecache = TRUE)
	if(!ismovable(parent))
		return COMPONENT_INCOMPATIBLE

	if(!length(_valid_areas)) //I guess if you have something that you want to behave this way then you can add a flag to ignore this check
		stack_trace("[src.type] initializing with an empty valid_areas.")
		return COMPONENT_INCOMPATIBLE

	valid_areas = _valid_areas
	use_instances = _use_instances
	check_as_typecache = _check_as_typecache
	reset_turf = get_turf(parent)
	move_tracker = new(parent, CALLBACK(src, PROC_REF(check_bounds)))
	check_bounds()

/datum/component/multi_area_bound/Destroy(force)
	QDEL_NULL(move_tracker)
	valid_areas = null
	return ..()

/datum/component/multi_area_bound/proc/check_bounds(atom/movable/source, atom/movable/mover, atom/oldloc, direction)
	SIGNAL_HANDLER //not technically a sig handler but it pretty much is
	var/area/current = get_area(source)
	if(!current)
		return

	if(!(check_as_typecache ? valid_areas[use_instances ? current : current.type] : ((use_instances ? current : current.type) in valid_areas))) //fun
		if(moving)
			stack_trace("Moved during a reset move, giving up to prevent infinite recursion. \
						[reset_turf ? "Turf: [reset_turf.type] at [reset_turf.x], [reset_turf.y], [reset_turf.z]" : "No reset_turf"]")
			return
		if(!reset_turf) //if unset then just move them to their last turf
			moving = TRUE
			source.forceMove(oldloc)
			moving = FALSE
			stack_trace("multi_area_bound without set reset_turf") //qdel(src)
			return

		moving = TRUE
		source.forceMove(reset_turf)
		moving = FALSE
	reset_turf = get_turf(source)
