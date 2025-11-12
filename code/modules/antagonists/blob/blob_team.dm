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
	///What strain do we have
	var/datum/blobstrain/reagent/blobstrain //might want to keep this on the blob mob, but dont think so due to minion component
	///List of our minion mobs
	var/list/blob_mobs = list()
	///A list of all blob structures
	var/list/all_blobs = list()
	///Assoc list of all blob structures keyed to their type
	var/alist/all_blobs_by_type = alist()
	///Count of blob structures in valid areas
	var/blobs_legit = 0
	///Ref to our main overmind
	var/mob/eye/blob/main_overmind
	/// The amount of points gained on blobstrain.core_process()
	var/point_rate = BLOB_BASE_POINT_RATE
	/// The amount of health regenned on core_process
	var/base_core_regen = BLOB_CORE_HP_REGEN

/datum/team/blob/New(datum/starting_members)
	. = ..()
	if(istype(starting_members) && starting_members.type == /mob/eye/blob)
		main_overmind = starting_membersz
