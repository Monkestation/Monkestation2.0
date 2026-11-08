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

	var/obj/mimicked_object
	var/datum/action/cooldown/mimic_object/mimic_ability
	var/spoofed_flags = 0

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

/datum/component/perfect_mimicry/proc/is_allowed_object(atom/mimic_target)
	if(!isitem(mimic_target))
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

		if(istype(new_item, /obj/item/storage)) // For storage specific items like clearing out preloading iventories.
			var/obj/item/storage/box_item = new_item
			if(box_item.preload && box_item.storage_type)
				var/list/contents = box_item.storage_type.return_inv()
				box_item.storage_type.remove_all(update_storage = FALSE)
				for(var/obj/item/contained_item in contents)
					qdel(contained_item, TRUE)
				box_item.storage_type.refresh_views()

		if(new_item.uses_integrity) // Mimicked items can break easier.
			var/weight_multiplier = max(1, new_item.w_class)
			var/adjusted_integrity = 5 + (weight_multiplier * INTEGRITY_PER_WCLASS)
			new_item.modify_max_integrity(clamp(adjusted_integrity, 10, 60))

	// Store the original resistance flags before adjusting the disguise.
	spoofed_flags = new_object.resistance_flags
	new_object.resistance_flags &= ~MIMIC_SPOOF_RESIST_MASK
	new_object.obj_flags |= CAN_BE_HIT

	return new_object

/datum/component/perfect_mimicry/proc/start_mimicry(obj/mimic_target)
	if(!QDELETED(mimicked_object))
		return FALSE
	var/obj/new_object = handle_mimic_target(mimic_target)
	if(QDELETED(new_object))
		return FALSE
	mimicked_object = new_object
	var/mob/living/mimic = parent
	mimic.forceMove(mimicked_object)
	return TRUE

/datum/component/perfect_mimicry/proc/stop_mimicry()
	if(QDELETED(mimicked_object))
		mimicked_object = null
		spoofed_flags = 0
		return FALSE

	var/mob/living/mimic = parent
	mimic.forceMove(mimicked_object.drop_location())

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
