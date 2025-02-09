/obj/item/traitor_machine_trapper/door_charge
	name = "Door Charge"
	desc = "A small explosive charge that can be rigged onto a door."
	deploy_time = 2 SECONDS
	target_machine_path = /obj/machinery/door
	explosion_range = 5
	component_datum = /datum/component/interaction_booby_trap/door

/datum/component/interaction_booby_trap/door
	explosion_heavy_range = 2

//Had to do it this way since its parent item hard codes its additional_triggers
/datum/component/interaction_booby_trap/door/Initialize(
	explosion_light_range,
	explosion_heavy_range,
	triggered_sound,
	trigger_delay,
	sound_loop_type,
	defuse_tool,
	additional_triggers,
	datum/callback/on_triggered_callback,
	datum/callback/on_defused_callback,
)
	. = ..()
	RegisterSignal(parent, COMSIG_ATOM_BUMPED, PROC_REF(bump_explosive))

/datum/component/interaction_booby_trap/door/Destroy(force)
	UnregisterSignal(parent, COMSIG_ATOM_BUMPED)
	return ..()

/datum/component/interaction_booby_trap/door/proc/bump_explosive(atom/source, atom/bumper)
	if(iscarbon(bumper))
		trigger_explosive(bumper)
