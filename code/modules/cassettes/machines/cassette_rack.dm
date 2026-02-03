#define MAX_STORED_CASSETTES 		28
#define DEFAULT_CASSETTES_TO_SPAWN 	5
#define DEFAULT_BLANKS_TO_SPAWN 	10

/obj/structure/cassette_rack
	name = "cassette pouch"
	desc = "Safely holds cassettes for storage."
	icon = 'icons/obj/cassettes/radio_station.dmi'
	icon_state = "cassette_pouch"
	anchored = FALSE
	density = FALSE

/obj/structure/cassette_rack/Initialize(mapload)
	. = ..()
	create_storage(storage_type = /datum/storage/cassette_rack)
	if(mapload)
		set_anchored(TRUE)

/obj/structure/cassette_rack/update_overlays()
	. = ..()
	var/number = length(contents) ? min(length(contents), 7) : 0
	. += mutable_appearance(icon, "[icon_state]_[number]")

/datum/storage/cassette_rack
	max_slots = MAX_STORED_CASSETTES
	max_specific_storage = WEIGHT_CLASS_SMALL
	max_total_storage = WEIGHT_CLASS_SMALL * MAX_STORED_CASSETTES
	numerical_stacking = TRUE

/datum/storage/cassette_rack/New()
	. = ..()
	set_holdable(/obj/item/cassette_tape)
	RegisterSignal(src, COMSIG_STORAGE_DUMP_POST_TRANSFER, PROC_REF(post_dump))
	RegisterSignal(src, COMSIG_STORAGE_DUMP_ONTO_POST_TRANSFER, PROC_REF(post_dumpall))

// Allow opening on a normal left click
/datum/storage/cassette_rack/on_attack(datum/source, mob/user)
	if(QDELETED(user) || !user.Adjacent(parent) || user.incapacitated() || !user.canUseStorage())
		return ..()
	INVOKE_ASYNC(src, PROC_REF(open_storage), user)
	return COMPONENT_CANCEL_ATTACK_CHAIN

/datum/storage/cassette_rack/item_insertion_feedback(mob/user, obj/item/thing, override = FALSE, sound = SFX_RUSTLE, sound_vary = TRUE)
	. = ..(user, thing, override, SFX_CASSETTE_PUT_IN, FALSE)

/datum/storage/cassette_rack/attempt_remove(obj/item/thing, atom/newLoc, silent = FALSE, visual_updates = TRUE, sound = SFX_RUSTLE, sound_vary = TRUE)
	. = ..(thing, newLoc, FALSE, visual_updates, SFX_CASSETTE_TAKE_OUT, FALSE)

// /datum/storage/cassette_rack/dump_content_at(atom/dest_object, mob/user, sound = SFX_RUSTLE, sound_vary = TRUE)
// 	. = ..(dest_object, user, SFX_CASSETTE_DUMP, FALSE)

/datum/storage/cassette_rack/proc/post_dump(datum/storage/source, atom/dest_object, mob/user)
	SIGNAL_HANDLER
	playsound(parent, SFX_CASSETTE_DUMP, 50, FALSE, -4)

/datum/storage/cassette_rack/proc/post_dumpall(datum/storage/source, atom/dest_object, mob/user)
	SIGNAL_HANDLER
	playsound(parent, SFX_CASSETTE_DUMP, 50, FALSE, -4)

/obj/structure/cassette_rack/prefilled
	var/spawn_random = DEFAULT_CASSETTES_TO_SPAWN
	var/spawn_blanks = DEFAULT_BLANKS_TO_SPAWN

/obj/structure/cassette_rack/prefilled/Initialize(mapload)
	. = ..()
	REGISTER_REQUIRED_MAP_ITEM(1, INFINITY)
	RegisterSignal(SSdcs, COMSIG_GLOB_CREWMEMBER_JOINED, PROC_REF(spawn_curator_tapes))
	for(var/i in 1 to spawn_blanks)
		new /obj/item/cassette_tape/blank(src)
	for(var/id in unique_random_tapes(spawn_random))
		new /obj/item/cassette_tape(src, id)
	update_appearance()

/obj/structure/cassette_rack/prefilled/Destroy()
	UnregisterSignal(SSdcs, COMSIG_GLOB_CREWMEMBER_JOINED)
	return ..()

/obj/structure/cassette_rack/prefilled/proc/spawn_curator_tapes(datum/source, mob/living/new_crewmember, rank)
	SIGNAL_HANDLER
	if(QDELETED(new_crewmember) || new_crewmember.stat == DEAD || !new_crewmember.ckey)
		return
	if(!istype(new_crewmember.mind?.assigned_role, /datum/job/curator))
		return
	add_user_tapes(new_crewmember.ckey)

/obj/structure/cassette_rack/prefilled/proc/add_user_tapes(user_ckey, max_amt = 3, expand_max_size = TRUE)
	var/list/existing_cassettes = list()
	for(var/obj/item/cassette_tape/tape in src)
		if(tape.cassette_data.id)
			existing_cassettes |= tape.cassette_data.id
	var/amount_spawned = 0
	for(var/datum/cassette/cassette as anything in SScassettes.unique_random_cassettes(max_amt, CASSETTE_STATUS_APPROVED, user_ckey, existing_cassettes))
		new /obj/item/cassette_tape(src, cassette)
		amount_spawned++
	if(expand_max_size && !QDELETED(atom_storage) && amount_spawned > 0)
		atom_storage.max_slots += amount_spawned
		atom_storage.max_total_storage += amount_spawned * WEIGHT_CLASS_SMALL
	return TRUE

#undef DEFAULT_BLANKS_TO_SPAWN
#undef DEFAULT_CASSETTES_TO_SPAWN
#undef MAX_STORED_CASSETTES
