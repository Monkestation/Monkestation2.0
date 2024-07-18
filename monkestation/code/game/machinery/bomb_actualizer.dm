/obj/machinery/bomb_actualizer
	name = "Bomb Actualizer	"
	desc = "An advanced EVIL? machine capable of releasing the normally bluespace-inhibited destructive potential of a bomb assembly"
	circuit = /obj/item/circuitboard/machine/bomb_actualizer
	icon = 'icons/obj/machines/research.dmi'
	base_icon_state = "explosive_compressor"
	icon_state = "explosive_compressor"
	density = TRUE

	/// The TTV inserted in the machine.
	var/obj/item/transfer_valve/inserted_bomb
	//combined gasmix to determine the simulation to reality
	var/datum/gas_mixture/combined_gasmix
	//Timer till detonation in seconds
	var/timer = 420
	//Countdown active
	var/countdown = FALSE
	//i dont really get what this is for, see anomaly refinery
	var/obj/item/tank/tank_to_target

	/obj/machinery/research/anomaly_refinery/Initialize(mapload)
		. = ..()
		RegisterSignal(src, COMSIG_ATOM_INTERNAL_EXPLOSION, PROC_REF(modify_explosion))

	//Stolen from anomaly_refinery
/obj/machinery/bomb_actualizer/attackby(obj/item/tool, mob/living/user, params)
	if(active)
		to_chat(user, span_warning("You can't insert [tool] into [src] while [p_theyre()] currently active."))
		return
	if(istype(tool, /obj/item/transfer_valve))
		if(inserted_bomb)
			to_chat(user, span_warning("There is already a bomb in [src]."))
			return
		var/obj/item/transfer_valve/valve = tool
		if(!valve.ready())
			to_chat(user, span_warning("[valve] is incomplete."))
			return
		if(!user.transferItemToLoc(tool, src))
			to_chat(user, span_warning("[tool] is stuck to your hand."))
			return
		inserted_bomb = tool
		tank_to_target = inserted_bomb.tank_two
		to_chat(user, span_notice("You insert [tool] into [src]"))
		return
	update_appearance()
	return ..()

/obj/machinery/bomb_actualizer/wrench_act(mob/living/user, obj/item/tool)
	. = ..()
	default_unfasten_wrench(user, tool)
	return TOOL_ACT_TOOLTYPE_SUCCESS

/obj/machinery/bomb_actualizer/screwdriver_act(mob/living/user, obj/item/tool)
	if(!default_deconstruction_screwdriver(user, "[base_icon_state]-off", "[base_icon_state]", tool))
		return FALSE
	update_appearance()
	return TRUE

/obj/machinery/bomb_actualizer/crowbar_act(mob/living/user, obj/item/tool)
	if(!default_deconstruction_crowbar(tool))
		return FALSE
	return TRUE

/**
 * Starts the Detonation Sequence
 */
/obj/machinery/bomb_actualizer/proc/start_detonation()
	if (active)
		say("ERROR: The countdown has aready begun!!!")
		return

	if(!istype(inserted_bomb))
		say("ERROR: Incorrect Bomb Specifications")
		return

	say("Begining detonation sequence. Countdown starting.")
	//TODO TIMER

	inserted_bomb.toggle_valve(tank_to_target)



//when crew inevitably bashes the thing to pieces
/obj/machiner/bomb_actualizer/Destroy()


//catches the parameter of the TTV's explosions as it happens internally, cancels the explosion and then re-triggers it to happen with modified perameters (such as maxcap = false)
/obj/machinery/bomb_actualizer/proc/modify_explosion(atom/source, list/arguments)
	SIGNAL_HANDLER
	var/heavy = arguments[EXARG_KEY_DEV_RANGE]
	var/medium = arguments[EXARG_KEY_HEAVY_RANGE]
	var/light = arguments[EXARG_KEY_LIGHT_RANGE]
	var/flame = 0
	var/flash = 0
	var/turf/location = get_turf(src)
	var/actualizer_multiplier = 0.25

	if(heavy > 3)
		var/capped_heavy = (GLOB.MAX_EX_DEVESTATION_RANGE + (heavy * actualizer_multiplier))

	if(medium > 7)
		var/capped_medium = (GLOB.MAX_EX_HEAVY_RANGE * (medium * actualizer_multiplier))

	if(light > 14)
		var/capped_light = (GLOB.MAX_EX_LIGHT_RANGE * (light * actualizer_multiplier))

	COMSIG_CANCEL_EXPLOSION

	SSexplosions.explode(location, capped_heavy, capped_medium, capped_light, flame, flash, TRUE, TRUE, FALSE, FALSE)
