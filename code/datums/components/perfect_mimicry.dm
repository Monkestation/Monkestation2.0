#define INTEGRITY_PER_WCLASS 10

/mob/living/proc/grant_mimicry()
	var/datum/action/cooldown/mimic_ability/mimic_object/action = new(src)
	action.Grant(src)

/mob/living/proc/remove_mimicry()
	for(var/datum/action/cooldown/mimic_ability/mimic_object/action in src.actions)
		action.Remove(src)

/*
 * Mimicry actions
 */
/datum/action/cooldown/mimic_ability
	name = "Base Mimic Ability"
	desc = "You should not be seeing this. This is an error alert developers."
	check_flags = AB_CHECK_CONSCIOUS|AB_CHECK_INCAPACITATED

	var/cooldown_after_use = 3 SECONDS // Cooldown after mimicry ends

/datum/action/cooldown/mimic_ability/mimic_object
	name = "Mimic Object"
	desc = "Take on the appearance and behavior of a nearby object. Use again to reveal yourself."

	click_to_activate = TRUE
	cooldown_time = 1 SECOND
	ranged_mousepointer = 'icons/effects/mouse_pointers/supplypod_target.dmi'

	var/static/list/allowed_objects = list() // typecache of allowed objects to mimic
	var/static/list/banned_objects = list(/obj/item/folder/biscuit, /obj/item/modular_computer, /obj/item/card, \
		/obj/item/holochip, /obj/item/stack
		) // typecache of banned objects that should absolutely not be mimicked
	var/list/applied_mob_traits = list(TRAIT_HANDS_BLOCKED, TRAIT_UI_BLOCKED, TRAIT_PULL_BLOCKED, TRAIT_NOBREATH)

	COOLDOWN_DECLARE(move_cooldown)
	var/obj/mimicked_object
	var/obj/fake_storage

/datum/action/cooldown/mimic_ability/mimic_object/proc/block_abilities()
	SIGNAL_HANDLER

// Item adjustments for specific cases.
/datum/action/cooldown/mimic_ability/mimic_object/proc/handle_mimic_target(obj/item/target_item)
	if(!isitem(target_item))
		return
	var/obj/item/new_item
	if(istype(target_item, /obj/item/disk/nuclear)) // Can mimic disk but it is fake and can be destroyed.
		var/obj/item/disk/nuclear/fake/nuclear = new(owner.drop_location())
		var/datum/component/stationloving/stationcomp = nuclear.GetComponent(/datum/component/stationloving)
		if(stationcomp)
			stationcomp.allow_item_destruction = TRUE
		new_item = nuclear
	if(!istype(new_item))
		new_item = duplicate_object(target_item, owner.drop_location())
	if(!new_item.loc?.atom_storage)
		new_item.item_flags &= ~(IN_INVENTORY | IN_STORAGE) // Prevent hover outline when mimicking inventory items.
		new_item.remove_filter(HOVER_OUTLINE_FILTER)
	new_item.AddComponent(/datum/component/mimic_disguise)
	if(new_item.uses_integrity) // Mimicked items can break easier
		var/weight_multiplier = max(1, new_item.w_class)
		var/adjusted_integrity = 5 + (weight_multiplier * INTEGRITY_PER_WCLASS)
		new_item.modify_max_integrity(clamp(adjusted_integrity, 10, 60))

	return new_item

/datum/action/cooldown/mimic_ability/mimic_object/proc/reflect_damage(datum/source, damage_amount, damage_type, damage_flag, sound_effect, attack_dir, armour_penetration)
	SIGNAL_HANDLER
	if(!damage_amount)
		return
	if(isliving(owner))
		var/mob/living/living_owner = owner
		living_owner.apply_damage(damage_amount, damage_type, null, 0, FALSE, TRUE, 0, 0, NONE, attack_dir)

/datum/action/cooldown/mimic_ability/mimic_object/proc/handle_speech(datum/source, list/speech_args)
	SIGNAL_HANDLER

	if(QDELETED(mimicked_object)) // Return early and prevent speech. Object cleanup should be happening.
		speech_args[SPEECH_MESSAGE] = ""
		return

	mimicked_object.say(speech_args[SPEECH_MESSAGE], speech_args[SPEECH_BUBBLE_TYPE], \
	speech_args[SPEECH_SPANS], speech_args[SPEECH_SANITIZE], speech_args[SPEECH_LANGUAGE], \
	speech_args[SPEECH_IGNORE_SPAM], speech_args[SPEECH_FORCED], speech_args[SPEECH_FILTERPROOF], \
	speech_args[SPEECH_RANGE], speech_args[SPEECH_SAYMODE])

	speech_args[SPEECH_MESSAGE] = ""

/datum/action/cooldown/mimic_ability/mimic_object/PreActivate(atom/mimic_target)
	if(!isnull(mimicked_object))
		return ..()
	if(mimic_target == owner)
		to_chat(owner, span_notice("You cannot mimic yourself."))
		return FALSE
	if(get_dist(owner, mimic_target) > 3)
		to_chat(owner, span_notice("[mimic_target.name] is too far away."))
		return FALSE
	if(!is_allowed_object(mimic_target))
		to_chat(owner, span_notice("[mimic_target.name] is too complex to mimic."))
		return FALSE
	if(owner.movement_type & VENTCRAWLING)
		to_chat(owner, span_notice("You cannot mimic objects while ventcrawling."))
		return FALSE
	return ..()

/datum/action/cooldown/mimic_ability/mimic_object/proc/is_allowed_object(obj/item/target_item)
	if(!isitem(target_item))
		return FALSE
	if(!target_item.uses_integrity)
		return FALSE
	if(length(banned_objects) && is_type_in_list(target_item, banned_objects))
		return FALSE
	if(length(allowed_objects) && !is_type_in_list(target_item, allowed_objects))
		return FALSE
	return TRUE

/datum/action/cooldown/mimic_ability/mimic_object/Activate(atom/mimic_target)
	if(!isnull(mimicked_object))
		stop_mimicry()
		click_to_activate = TRUE
		StartCooldown(cooldown_after_use)
		return TRUE
	if(start_mimicry(mimic_target))
		click_to_activate = FALSE
		StartCooldown()
		return TRUE
	return FALSE

/datum/action/cooldown/mimic_ability/mimic_object/proc/start_mimicry(obj/mimic_item)
	mimicked_object = handle_mimic_target(mimic_item)
	if(isnull(mimicked_object))
		return
	RegisterSignal(mimicked_object, COMSIG_ATOM_RELAYMOVE, PROC_REF(on_user_move))
	RegisterSignal(mimicked_object, COMSIG_ATOM_TAKE_DAMAGE, PROC_REF(reflect_damage))
	RegisterSignal(mimicked_object, COMSIG_QDELETING, PROC_REF(on_object_qdel))
	RegisterSignal(owner, COMSIG_MOB_SAY, PROC_REF(handle_speech))
	owner.forceMove(mimicked_object)
	mimicked_object.buckle_mob(owner)
	if(length(applied_mob_traits))
		owner.add_traits(applied_mob_traits, REF(src))
	if(mimicked_object.atom_storage)
		fake_storage = new(src)
		fake_storage.clone_storage(mimicked_object.atom_storage)
		mimicked_object.atom_storage.set_real_location(fake_storage)
	return mimicked_object

/datum/action/cooldown/mimic_ability/mimic_object/proc/stop_mimicry()
	owner.forceMove(mimicked_object.drop_location())
	UnregisterSignal(owner, COMSIG_MOB_SAY)
	if(mimicked_object.atom_storage)
		mimicked_object.atom_storage.remove_all(mimicked_object.drop_location())
	if(length(applied_mob_traits))
		owner.remove_traits(applied_mob_traits, REF(src))
	if(fake_storage)
		QDEL_NULL(fake_storage)
	if(QDELETED(mimicked_object))
		mimicked_object = null
	else
		QDEL_NULL(mimicked_object)

///The user can move while inside of the item.
/datum/action/cooldown/mimic_ability/mimic_object/proc/on_user_move(obj/moved_source, mob/user_moving, direction)
	SIGNAL_HANDLER

	if(!COOLDOWN_FINISHED(src, move_cooldown))
		return COMSIG_BLOCK_RELAYMOVE
	var/turf/next = get_step(moved_source, direction)
	var/turf/current = get_turf(moved_source)
	if(!istype(next) || !istype(current))
		return COMSIG_BLOCK_RELAYMOVE
	if(next.density)
		return COMSIG_BLOCK_RELAYMOVE
	if(!isturf(moved_source.loc))
		return COMSIG_BLOCK_RELAYMOVE

	step(moved_source, direction)
	var/last_move_diagonal = ((direction & (direction - 1)) && (moved_source.loc == next))
	COOLDOWN_START(src, move_cooldown, ((last_move_diagonal ? 1 : 0.5)) SECOND)

	if(QDELETED(src))
		return COMSIG_BLOCK_RELAYMOVE
	return TRUE

///Called when the host of the mob is qdeleted.
/datum/action/cooldown/mimic_ability/mimic_object/proc/on_object_qdel(datum/source, force)
	SIGNAL_HANDLER
	stop_mimicry()
	if(QDELETED(owner))
		return
	for(var/datum/action/cooldown/mimic_ability/mimic_abilities in owner.actions)
		mimic_abilities.click_to_activate = TRUE
		mimic_abilities.StartCooldown(mimic_abilities.cooldown_after_use)

/datum/action/cooldown/mimic_ability/throw_self

#undef INTEGRITY_PER_WCLASS
