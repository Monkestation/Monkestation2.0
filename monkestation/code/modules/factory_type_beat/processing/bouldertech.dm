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

	register_context()

/obj/machinery/bouldertech/LateInitialize()
	. = ..()

/obj/machinery/bouldertech/Destroy()
	return ..()

/obj/machinery/bouldertech/on_deconstruction(disassembled)
	// put in code to empty its container

/obj/machinery/bouldertech/add_context(atom/source, list/context, obj/item/held_item, mob/user)
	// override for the specific machine

/obj/machinery/bouldertech/examine(mob/user)
	. = ..()

/obj/machinery/bouldertech/update_icon_state()
	. = ..()

/obj/machinery/bouldertech/wrench_act(mob/living/user, obj/item/tool)
	return

/obj/machinery/bouldertech/screwdriver_act(mob/living/user, obj/item/tool)
	return

/obj/machinery/bouldertech/crowbar_act(mob/living/user, obj/item/tool)
	if(default_deconstruction_crowbar(tool))
		return TOOL_ACT_TOOLTYPE_SUCCESS
	return

/obj/machinery/bouldertech/CanAllowThrough(atom/movable/mover, border_dir)
	if(!anchored)
		return FALSE
	return ..()

/obj/machinery/bouldertech/proc/on_entered(datum/source, atom/movable/atom_movable)
	SIGNAL_HANDLER

/**
 * Looks for a boost to the machine's efficiency, and applies it if found.
 * Applied more on the chemistry integration but can be used for other things if desired.
 */
/obj/machinery/bouldertech/proc/check_for_boosts()
	PROTECTED_PROC(TRUE)

/**
 * Checks if this machine can process this material
 * Arguments
 *
 * * datum/material/mat - the material to process
 */
/obj/machinery/bouldertech/proc/can_process_material(datum/material/mat)
	PROTECTED_PROC(TRUE)
	return FALSE

/obj/machinery/bouldertech/attackby(obj/item/attacking_item, mob/user, params)
	return ..()

/obj/machinery/bouldertech/attack_hand_secondary(mob/user, list/modifiers)
	. = ..()
	if(. == SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN || panel_open)
		return
	if(!anchored)
		balloon_alert(user, "anchor first!")
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN
	if(panel_open)
		balloon_alert(user, "close panel!")
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

/obj/machinery/bouldertech/process()
	if(!anchored || panel_open || !is_operational || (machine_stat & (BROKEN | NOPOWER)))
		return
