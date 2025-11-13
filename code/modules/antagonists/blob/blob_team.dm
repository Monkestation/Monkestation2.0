/datum/team/blob
	show_roundend_report = FALSE //the blob antag datum handles this
	///What size should we announce this overmind at
	var/announcement_size = OVERMIND_ANNOUNCEMENT_MIN_SIZE // Announce the biohazard when this size is reached
	///When should we announce this blob
	var/announcement_time
	///Have we been announced yet
	var/has_announced = FALSE
	///The highest amount of tiles we got before round end
	var/highest_tile_count = 0
	///How many tiles we need to win
	var/blobwincount = OVERMIND_WIN_CONDITION_AMOUNT
	///Are we winning, son?
	var/victory_in_progress = FALSE
	/// Stores world.time to figure out when to next give resources
	var/resource_delay = 0

	///What strain do we have
	var/datum/blobstrain/reagent/blobstrain //might want to keep this on the blob mob, but dont think so due to minion component
	/// The amount of points gained on blobstrain.core_process()
	var/point_rate = BLOB_BASE_POINT_RATE
	/// The amount of health regenned on core_process
	var/base_core_regen = BLOB_CORE_HP_REGEN

	///List of our minion mobs
	var/list/blob_mobs = list()
	///A list of all blob structures
	var/list/all_blob_tiles = list()
	///Assoc list of all blob structures keyed to their type
	var/alist/all_blobs_by_type = alist()
	///Count of blob structures in valid areas
	var/blobs_legit = 0

	///Ref to our main overmind
	var/mob/eye/blob/main_overmind
	///List of all our overminds
	var/list/overminds = list()

/datum/team/blob/New(datum/starting_members)
	. = ..()
	set_team_strain(pick(GLOB.valid_blobstrains))
	if(istype(starting_members) && starting_members.type == /mob/eye/blob)
		main_overmind = starting_members
	START_PROCESSING(SSprocessing, src)

/datum/team/blob/Destroy(force)
	STOP_PROCESSING(SSprocessing, src)
	return ..()

/datum/team/blob/add_member(datum/mind/new_member)
	. = ..()
	if(istype(new_member.current, /mob/eye/blob))
		var/mob/eye/blob/added_blob = new_member.current
		overminds += added_blob
		added_blob.update_strain()

/datum/team/blob/remove_member(datum/mind/member)
	. = ..()
	if(istype(member.current, /mob/eye/blob)) //pure -= without the type check may be cheaper, idk
		overminds -= member.current

/datum/team/blob/proc/set_team_strain(datum/blobstrain/new_strain)
	if(!ispath(new_strain))
		return FALSE

	var/old_strain = FALSE
	if(blobstrain)
		old_strain = TRUE
		blobstrain.on_lose()
		qdel(blobstrain)

	blobstrain = new new_strain(src)
	blobstrain.on_gain()
	for(var/mob/eye/blob/overmind in overminds)
		overmind.update_strain(old_strain)

/datum/team/blob/process(seconds_per_tick)
	if(resource_delay <= world.time)
		resource_delay = world.time + 10 // 1 second
		for(var/mob/eye/blob/overmind in overminds)
			overmind.add_points(point_rate + blobstrain.point_rate_bonus)
	main_overmind?.blob_core?.repair_damage(base_core_regen + blobstrain.core_regen_bonus)
