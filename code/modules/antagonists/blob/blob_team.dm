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
	var/datum/blobstrain/blobstrain
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

/datum/team/blob/New(starting_members)
	. = ..()
	set_team_strain(pick(GLOB.valid_blobstrains))
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
		if(!main_overmind && added_blob.type == /mob/eye/blob)
			main_overmind = added_blob
			SSshuttle.registerHostileEnvironment(main_overmind)

/datum/team/blob/remove_member(datum/mind/member)
	. = ..()
	if(istype(member.current, /mob/eye/blob)) //pure -= without the type check may be cheaper, idk
		overminds -= member.current

/datum/team/blob/process(seconds_per_tick)
	if(!main_overmind?.blob_core)
		return

	if(resource_delay <= world.time)
		var/amount_to_give = round(blobstrain?.core_process(), 0.1) || 0 //make sure amount_to_give is always a num
		resource_delay = world.time + (1 SECOND)
		main_overmind?.add_points(amount_to_give)
		if(length(overminds) > 1)
			amount_to_give = ceil(amount_to_give / 2)
			for(var/mob/eye/blob/overmind in overminds - main_overmind)
				overmind.add_points(amount_to_give)
	main_overmind.blob_core.repair_damage(base_core_regen + blobstrain.core_regen_bonus)

///Set our strain and update all our overminds and tiles
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

///Called when our main overmind dies
/datum/team/blob/proc/main_overmind_death()
	QDEL_NULL(blobstrain)
	STOP_PROCESSING(SSprocessing, src)
	SSshuttle.clearHostileEnvironment(main_overmind)
	SSticker.news_report = BLOB_DESTROYED
	for(var/obj/structure/blob/blob_structure in all_blob_tiles)
		blob_structure.blob_team = null
		blob_structure.update_appearance()

	for(var/overmind in overminds)
		qdel(overmind)

	main_overmind = null

/// Create a blob spore and link it to us
/datum/team/blob/proc/create_spore(turf/spore_turf, spore_type = /mob/living/basic/blob_minion/spore/minion)
	var/mob/living/basic/blob_minion/spore/spore = new spore_type(spore_turf)
	make_minion(spore)
	return spore

/// Give our new minion the properties of a minion
/datum/team/blob/proc/make_minion(mob/living/minion)
	minion.AddComponent(/datum/component/blob_minion, src)

/// Add something to our list of mobs and wait for it to die
/datum/team/blob/proc/register_new_minion(mob/living/minion)
	blob_mobs |= minion
	if(!istype(minion, /mob/living/basic/blob_minion/blobbernaut))
		RegisterSignal(minion, COMSIG_LIVING_DEATH, PROC_REF(on_minion_death))

/// When a spore (or zombie) dies then we do this
/datum/team/blob/proc/on_minion_death(mob/living/spore)
	SIGNAL_HANDLER
	blobstrain.on_sporedeath(spore)
