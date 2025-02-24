/**
 * Base for all bouldertech industry machines.
 */
/obj/machinery/bouldertech
	name = "bouldertech brand refining machine"
	desc = "You shouldn't be seeing this! And bouldertech isn't even a real company!"
	icon = 'monkestation/code/modules/factory_type_beat/icons/mining_machines.dmi'
	icon_state = "ore_redemption"
	anchored = TRUE
	density = TRUE

/obj/machinery/bouldertech/Initialize(mapload)
	. = ..()

/obj/machinery/bouldertech/LateInitialize()
	. = ..()

/obj/machinery/bouldertech/add_context(atom/source, list/context, obj/item/held_item, mob/user)

/obj/machinery/bouldertech/Destroy()
	return ..()

/obj/machinery/bouldertech/update_icon_state()
	. = ..()

/obj/machinery/bouldertech/wrench_act(mob/living/user, obj/item/tool)
	. = ..()

/obj/machinery/bouldertech/screwdriver_act(mob/living/user, obj/item/tool)
	. = ..()

/obj/machinery/bouldertech/crowbar_act(mob/living/user, obj/item/tool)
	. = ..()

/obj/machinery/bouldertech/attackby(obj/item/attacking_item, mob/user, params)
	return ..()

/obj/machinery/bouldertech/attack_hand_secondary(mob/user, list/modifiers)
	. = ..()

/obj/machinery/bouldertech/CanAllowThrough(atom/movable/mover, border_dir)
	return ..()

/obj/machinery/bouldertech/examine(mob/user)
	. = ..()

/**
 * Accepts a boulder into the machinery, then converts it into minerals.
 * If the boulder can be fully processed by this machine, we take the materials, insert it into the silo, and destroy the boulder.
 * If the boulder has materials left, we make a copy of the boulder to hold the processable materials, take the processable parts, and eject the original boulder.
 * @param chosen_boulder The boulder to being breaking down into minerals.
 */
/obj/machinery/bouldertech/proc/breakdown_boulder(obj/item/boulder/chosen_boulder)
	return FALSE

/**
 * Accepts a boulder into the machine. Used when a boulder is first placed into the machine.
 * @param new_boulder The boulder to be accepted.
 */
/obj/machinery/bouldertech/proc/accept_boulder(obj/item/boulder/new_boulder)
	return FALSE

/**
 * Checks if it can process other exotic items besides boulders.
 * @param item The item to be checked. Returns true if it can be accepted.
 */
/obj/machinery/bouldertech/proc/check_extras(obj/item/item)
	return FALSE

/**
 * Ejects a boulder from the machine. Used when a boulder is finished processing, or when a boulder can't be processed.
 * @param drop_turf The location to eject the boulder to. If null, it will eject to the machine's drop_location().
 * @param specific_boulder The boulder to be ejected.
 */
/obj/machinery/bouldertech/proc/remove_boulder(obj/item/boulder/specific_boulder, turf/drop_turf = null)
	return FALSE

/**
 * Getter proc to determine how many boulders are contained in the machine.
 * Also adds their reference to the boulders_contained list.
 */
/obj/machinery/bouldertech/proc/update_boulder_count()
	return FALSE

/**
 * Override Getter proc to determine what exotic items are contained in the machine.
 * Ovveride this proc for your machines purposes.
 */
/obj/machinery/bouldertech/proc/return_extras()
	return list()

/obj/machinery/bouldertech/proc/on_entered(datum/source, atom/movable/atom_movable)
	SIGNAL_HANDLER

/**
 * Checks if a custom_material is in a list of processable materials in the machine.
 * @param list/custom_material A list of materials, presumably taken from a boulder. If a material that this machine can process is in this list, it will return true, inclusively.
 */
/obj/machinery/bouldertech/proc/check_for_processable_materials(list/boulder_mats)
	return FALSE
