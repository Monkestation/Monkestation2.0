/mob/living/proc/grant_mimicry()
	if(!src.GetComponent(/datum/component/perfect_mimicry))
		src.AddComponent(/datum/component/perfect_mimicry)
/mob/living/proc/remove_mimicry()
	var/datum/component/perfect_mimicry/mimic_component = GetComponent(/datum/component/perfect_mimicry)
	if(mimic_component)
		qdel(mimic_component)

#define INTEGRITY_PER_WCLASS 10
#define MIMIC_SPOOF_RESIST_MASK ( \
	LAVA_PROOF | \
	FIRE_PROOF | \
	FREEZE_PROOF | \
	SHUTTLE_CRUSH_PROOF | \
	FLAMMABLE | \
	UNACIDABLE | \
	ACID_PROOF | \
	INDESTRUCTIBLE \
) // Filter for specific item flags so disguises cannot be invincible while still maintaining the appearence that they are.

/datum/component/perfect_mimicry
	dupe_mode = COMPONENT_DUPE_UNIQUE

	COOLDOWN_DECLARE(move_cooldown)
	var/obj/mimicked_object
	var/obj/fake_storage
	var/datum/action/cooldown/mimic_object/mimic_ability
	var/spoofed_flags = 0

	// What is allowed to be mimicked. Allowing everything is extremely dangerous.
	var/static/list/allowed_objects = typecacheof(list(
		/obj/item/storage/backpack,
		/obj/item/trash
	))
	// What is blocked. Used when using the whitelist allows a problematic subtype
	var/static/list/blocked_objects = typecacheof(list(
		/obj/item/trash/bee
	))
	// Traits applied to mob during disguise.
	var/list/applied_mob_traits = list(
		TRAIT_HANDS_BLOCKED,
		TRAIT_UI_BLOCKED,
		TRAIT_PULL_BLOCKED,
		TRAIT_NOBREATH,
		TRAIT_RESISTHIGHPRESSURE,
		TRAIT_RESISTLOWPRESSURE
		)

/datum/component/perfect_mimicry/Initialize()
	. = ..()
	if(!isliving(parent))
		return COMPONENT_INCOMPATIBLE
	mimic_ability = new(src)

/datum/component/perfect_mimicry/Destroy(force)
	QDEL_NULL(mimic_ability)
	stop_mimicry()
	return ..()

/datum/component/perfect_mimicry/RegisterWithParent()
	mimic_ability.Grant(parent)

/// Called when the current disguise is deleted externally.
/datum/component/perfect_mimicry/proc/on_object_qdel(datum/source, force)
	SIGNAL_HANDLER
	if(source != mimicked_object)
		return
	if(!stop_mimicry())
		return
	if(QDELETED(mimic_ability))
		return
	mimic_ability.update_mimic_mode(FALSE)
	mimic_ability.StartCooldown(mimic_ability.cooldown_after_use)

/datum/component/perfect_mimicry/proc/on_dropped(obj/item/source, mob/dropper)
	SIGNAL_HANDLER
	if(source != mimicked_object)
		return

	var/mob/living/mimic = parent
	mimic.reset_perspective()

/datum/component/perfect_mimicry/proc/override_examine_flags(datum/source, mob/user)
	SIGNAL_HANDLER
	return spoofed_flags | EXAMINE_RESISTANCE_OVERRIDE

/// Mimic can move their disguise slowly.
/datum/component/perfect_mimicry/proc/on_user_move(obj/moved_source, mob/user_moving, direction)
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
	COOLDOWN_START(src, move_cooldown, ((last_move_diagonal ? 1 : 0.5)) SECONDS)

	if(QDELETED(src))
		return COMSIG_BLOCK_RELAYMOVE
	return TRUE

/// Can attack mimic disguises when in harm state
/datum/component/perfect_mimicry/proc/on_item_interaction(obj/attacked_source, mob/living/user, obj/item/tool, list/modifiers)
	SIGNAL_HANDLER

	if(user?.istate & (ISTATE_HARM))
		return ITEM_INTERACT_SKIP_TO_ATTACK
	return NONE

/datum/component/perfect_mimicry/proc/transder_damage(datum/source, damage_amount, damage_type, damage_flag, sound_effect, attack_dir, armour_penetration)
	SIGNAL_HANDLER
	if(!damage_amount)
		return
	if(isliving(parent))
		var/mob/living/living_owner = parent
		living_owner.apply_damage(damage_amount, damage_type, null, 0, FALSE, TRUE, 0, 0, NONE, attack_dir)

/datum/component/perfect_mimicry/proc/handle_speech(datum/source, list/speech_args)
	SIGNAL_HANDLER

	if(QDELETED(mimicked_object)) // Return early and prevent speech. Object cleanup should be happening.
		speech_args[SPEECH_MESSAGE] = ""
		return

	mimicked_object.say(speech_args[SPEECH_MESSAGE], speech_args[SPEECH_BUBBLE_TYPE], \
	speech_args[SPEECH_SPANS], speech_args[SPEECH_SANITIZE], speech_args[SPEECH_LANGUAGE], \
	speech_args[SPEECH_IGNORE_SPAM], speech_args[SPEECH_FORCED], speech_args[SPEECH_FILTERPROOF], \
	speech_args[SPEECH_RANGE], speech_args[SPEECH_SAYMODE])

	speech_args[SPEECH_MESSAGE] = ""

/datum/component/perfect_mimicry/proc/on_stat_change(mob/living/victim, new_stat)
	SIGNAL_HANDLER

	if(victim != parent)
		return
	if(new_stat < SOFT_CRIT)
		return
	if(!stop_mimicry())
		return
	if(QDELETED(mimic_ability))
		return
	mimic_ability.update_mimic_mode(FALSE)
	mimic_ability.StartCooldown(mimic_ability.cooldown_after_use)

/datum/component/perfect_mimicry/proc/is_allowed_object(atom/mimic_target)
	if(!isitem(mimic_target))
		return FALSE
	if(!mimic_target.uses_integrity)
		return FALSE
	if(mimic_target.flags_1 & HOLOGRAM_1)
		return FALSE
	var/obj/item/item_to_mimic = mimic_target
	if(item_to_mimic.item_flags & ABSTRACT)
		return FALSE
	if(is_type_in_list(item_to_mimic, blocked_objects))
		return FALSE
	if(!is_type_in_typecache(item_to_mimic, allowed_objects))
		return FALSE
	return TRUE

/datum/component/perfect_mimicry/proc/can_start_mimicry(atom/mimic_target)
	var/mob/living/mimic = parent

	if(!istype(mimic) || QDELETED(mimic))
		return FALSE
	if(mimic_target == mimic)
		to_chat(mimic, span_notice("You cannot mimic yourself."))
		return FALSE
	if(!isobj(mimic_target) || QDELETED(mimic_target))
		return FALSE
	if(get_dist(mimic, mimic_target) > 3)
		to_chat(mimic, span_notice("[mimic_target.name] is too far away."))
		return FALSE
	if(!is_allowed_object(mimic_target))
		to_chat(mimic, span_notice("[mimic_target.name] is too complex to mimic."))
		return FALSE
	if(mimic.movement_type & VENTCRAWLING)
		to_chat(mimic, span_notice("You cannot mimic objects while ventcrawling."))
		return FALSE
	return TRUE

/// Proc to duplicate setup and handle edge cases for the mimic's disguise.
/datum/component/perfect_mimicry/proc/handle_mimic_target(obj/mimic_target)
	RETURN_TYPE(/obj)

	var/mob/living/mimic = parent
	var/obj/new_object

	if(istype(mimic_target, /obj/item/disk/nuclear)) // Can mimic disk, but it is fake and can be destroyed.
		var/obj/item/disk/nuclear/fake/nuclear = new(mimic.drop_location())
		var/datum/component/stationloving/stationcomp = nuclear.GetComponent(/datum/component/stationloving)
		if(stationcomp)
			stationcomp.allow_item_destruction = TRUE
		new_object = nuclear
	else
		new_object = duplicate_object(mimic_target, mimic.drop_location())

	if(QDELETED(new_object))
		return null

	if(isitem(new_object)) // Handles specific flags and integrity for the new item
		var/obj/item/new_item = new_object
		new_object.remove_filter(HOVER_OUTLINE_FILTER)
		new_item.item_flags &= ~(IN_INVENTORY | IN_STORAGE) // Remove inherited inventory flags. Prevents selection borders from mimicking inventory items.

		// Set item plane to undo possible inventory fullbrightness in the world plane.
		new_item.layer = initial(new_item.layer)
		SET_PLANE_EXPLICIT(new_item, initial(new_item.plane), new_item.loc)
		new_item.appearance_flags &= ~NO_CLIENT_COLOR

		// Give the disguise a small random offset from its normal position.
		if(!(new_item.item_flags & NO_PIXEL_RANDOM_DROP))
			new_item.pixel_x = new_item.base_pixel_x + rand(-5, 5)
			new_item.pixel_y = new_item.base_pixel_y + rand(-5, 5)

		if(istype(new_item, /obj/item/storage)) // For storage specific items like clearing out preloading iventories.
			var/obj/item/storage/box_item = new_item
			if(box_item.atom_storage)
				var/list/contents = box_item.atom_storage.return_inv()
				box_item.atom_storage.remove_all(update_storage = FALSE)
				for(var/obj/item/contained_item in contents)
					qdel(contained_item, TRUE)
		if(new_item.atom_storage)
			fake_storage = new(src)
			fake_storage.clone_storage(new_item.atom_storage)
			new_item.atom_storage.set_real_location(fake_storage)
		if(new_item.uses_integrity) // Mimicked items can break easier.
			var/weight_multiplier = max(1, new_item.w_class)
			var/adjusted_integrity = 5 + (weight_multiplier * INTEGRITY_PER_WCLASS)
			new_item.modify_max_integrity(clamp(adjusted_integrity, 10, 60))

	// Store the original resistance flags before adjusting the disguise.
	spoofed_flags = new_object.resistance_flags
	new_object.resistance_flags &= ~MIMIC_SPOOF_RESIST_MASK
	new_object.obj_flags |= CAN_BE_HIT
	RegisterSignal(new_object, COMSIG_ATOM_EXAMINE_RESISTANCE_FLAGS, PROC_REF(override_examine_flags))
	RegisterSignal(new_object, COMSIG_ATOM_TAKE_DAMAGE, PROC_REF(transder_damage))
	RegisterSignal(new_object, COMSIG_ATOM_ITEM_INTERACTION, PROC_REF(on_item_interaction))
	RegisterSignal(new_object, COMSIG_ITEM_DROPPED, PROC_REF(on_dropped))

	return new_object

/datum/component/perfect_mimicry/proc/start_mimicry(obj/mimic_target)
	if(!QDELETED(mimicked_object))
		return FALSE
	var/obj/new_object = handle_mimic_target(mimic_target)
	if(QDELETED(new_object))
		return FALSE
	mimicked_object = new_object
	RegisterSignal(mimicked_object, COMSIG_QDELETING, PROC_REF(on_object_qdel))
	var/mob/living/mimic = parent
	mimic.forceMove(mimicked_object)
	if(length(applied_mob_traits))
		mimic.add_traits(applied_mob_traits, REF(src))
	RegisterSignal(mimic, COMSIG_MOB_SAY, PROC_REF(handle_speech))
	RegisterSignal(mimic, COMSIG_MOB_STATCHANGE, PROC_REF(on_stat_change))
	RegisterSignal(mimicked_object, COMSIG_ATOM_RELAYMOVE, PROC_REF(on_user_move))
	return TRUE

/datum/component/perfect_mimicry/proc/stop_mimicry()
	if(!mimicked_object)
		return FALSE
	UnregisterSignal(mimicked_object, list(
		COMSIG_QDELETING,
		COMSIG_ITEM_DROPPED,
		COMSIG_ATOM_EXAMINE_RESISTANCE_FLAGS,
		COMSIG_ATOM_RELAYMOVE,
		COMSIG_ATOM_ITEM_INTERACTION,
		COMSIG_ATOM_TAKE_DAMAGE
		))
	var/mob/living/mimic = parent
	mimic.forceMove(mimicked_object.drop_location())
	UnregisterSignal(mimic, list(COMSIG_MOB_SAY, COMSIG_MOB_STATCHANGE))
	if(length(applied_mob_traits))
		mimic.remove_traits(applied_mob_traits, REF(src))
	if(mimicked_object.atom_storage)
		mimicked_object.atom_storage.remove_all(mimicked_object.drop_location())
	if(fake_storage)
		QDEL_NULL(fake_storage)
	if(QDELETED(mimicked_object))
		mimicked_object = null
	else
		QDEL_NULL(mimicked_object)
	spoofed_flags = 0
	return TRUE

#undef INTEGRITY_PER_WCLASS
#undef MIMIC_SPOOF_RESIST_MASK

/*
 * Mimicry actions
 */
/datum/action/cooldown/mimic_object
	name = "Mimic Object"
	desc = "Take on the appearance and behavior of a nearby object."
	button_icon = 'icons/hud/mimicry.dmi'
	button_icon_state = "mimic"

	click_to_activate = TRUE
	cooldown_time = 1 SECONDS
	var/cooldown_after_use = 3 SECONDS
	ranged_mousepointer = 'icons/effects/mouse_pointers/supplypod_target.dmi'
	check_flags = AB_CHECK_CONSCIOUS|AB_CHECK_INCAPACITATED

/datum/action/cooldown/mimic_object/Destroy(force)
	if(!QDELETED(target))
		var/datum/component/perfect_mimicry/mimic_component = target
		mimic_component.stop_mimicry()
	return ..()

/datum/action/cooldown/mimic_object/PreActivate(atom/mimic_target)
	var/datum/component/perfect_mimicry/mimic_component = target

	if(!istype(mimic_component) || QDELETED(mimic_component))
		return FALSE
	if(mimic_component.mimicked_object)
		return ..()
	if(!mimic_component.can_start_mimicry(mimic_target))
		return FALSE

	return ..()

/datum/action/cooldown/mimic_object/Activate(atom/mimic_target)
	var/datum/component/perfect_mimicry/mimic_component = target

	if(!istype(mimic_component) || QDELETED(mimic_component))
		return FALSE
	if(mimic_component.mimicked_object)
		if(!mimic_component.stop_mimicry())
			return FALSE
	else
		if(!mimic_component.start_mimicry(mimic_target))
			return FALSE

	update_mimic_mode(mimic_component.mimicked_object)
	StartCooldown(mimic_component.mimicked_object ? cooldown_time : cooldown_after_use)
	return TRUE

/datum/action/cooldown/mimic_object/proc/update_mimic_mode(disguised)
	if(disguised)
		click_to_activate = FALSE
		button_icon_state = "unmimic"
	else
		click_to_activate = TRUE
		button_icon_state = "mimic"

	build_all_button_icons(UPDATE_BUTTON_ICON | UPDATE_BUTTON_STATUS)
