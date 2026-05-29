/obj/machinery/transformer
	name = "\improper Automatic Robotic Factory 5000"
	desc = "A large metallic machine with an entrance and an exit. A sign on \
		the side reads, 'human go in, robot come out'. The human must be \
		lying down and alive. Has a cooldown between each use. Can alternate \
		between making cyborgs and IPCs" // monkestation edit PR #5133
	icon = 'icons/obj/recycling.dmi'
	icon_state = "separator-AO1"
	layer = ABOVE_ALL_MOB_LAYER // Overhead
	plane = ABOVE_GAME_PLANE
	density = FALSE
	active_power_usage = BASE_MACHINE_ACTIVE_CONSUMPTION * 5
	/// Whether this machine transforms dead mobs into cyborgs/ipcs
	var/transform_dead = FALSE
	/// Whether this machine transforms standing mobs into cyborgs/ipcs
	var/transform_standing = FALSE
	/// How long we have to wait between processing mobs
	var/cooldown_duration = 60 SECONDS
	/// Whether we're on cooldown
	var/cooldown = FALSE
	/// How long until the next mob can be processed
	var/cooldown_timer
	/// The created cyborg's cell chage
	var/robot_cell_charge = 5000
	///Whether this machine transforms mobs to ipcs, else transforms them to cyborgs
	var/is_ipc_mode = FALSE // monkestation edit PR #5133
	/// The visual countdown effect
	var/obj/effect/countdown/transformer/countdown

/obj/machinery/transformer/Initialize(mapload)
	. = ..()
	new /obj/machinery/conveyor/auto(locate(x - 1, y, z), WEST)
	new /obj/machinery/conveyor/auto(loc, WEST)
	new /obj/machinery/conveyor/auto(locate(x + 1, y, z), WEST)
	countdown = new(src)
	countdown.start()

/obj/machinery/transformer/examine(mob/user)
	. = ..()
	// monkestation edit start PR #5133
	. += span_notice("It is currently set to producing: [is_ipc_mode ? "IPC's" : "Cyborgs"]")
	if(issilicon(user) || isobserver(user))
		if(cooldown)
			. += "It will be ready in [DisplayTimeText(cooldown_timer - world.time)]."
		. += span_notice("Right-click to change its production mode.")
	// monkestation edit end PR #5133

/obj/machinery/transformer/Destroy()
	QDEL_NULL(countdown)
	. = ..()

/obj/machinery/transformer/update_icon_state()
	if(machine_stat & (BROKEN|NOPOWER) || cooldown == 1)
		icon_state = "separator-AO0"
	else
		icon_state = initial(icon_state)
	return ..()

/obj/machinery/transformer/Bumped(atom/movable/entering_thing)
	if(cooldown)
		return

	// Crossed didn't like people lying down.
	if(ishuman(entering_thing))
		// Only humans can enter from the west side, while lying down.
		var/move_dir = get_dir(loc, entering_thing.loc)
		var/mob/living/carbon/human/victim = entering_thing
		if((transform_standing || victim.body_position == LYING_DOWN) && move_dir == EAST)
			entering_thing.forceMove(drop_location())
			do_transform(entering_thing)

/obj/machinery/transformer/CanAllowThrough(atom/movable/mover, border_dir)
	. = ..()
	// Allows items to go through to stop them from blocking the conveyor belt.
	if(!ishuman(mover))
		if(get_dir(src, mover) == EAST)
			return
	return FALSE

/obj/machinery/transformer/process()
	if(cooldown && (cooldown_timer <= world.time))
		cooldown = FALSE
		update_appearance()

/obj/machinery/transformer/proc/do_transform(mob/living/carbon/human/victim)
	if(machine_stat & (BROKEN|NOPOWER))
		return

	if(cooldown)
		return

	if(!transform_dead && victim.stat == DEAD)
		playsound(src.loc, 'sound/machines/buzz-sigh.ogg', 50, FALSE)
		return

	// Activate the cooldown
	cooldown = TRUE
	cooldown_timer = world.time + cooldown_duration
	update_appearance()

	playsound(src.loc, 'sound/items/welder.ogg', 50, TRUE)
	victim.emote("scream") // It is painful
	victim.adjustBruteLoss(max(0, 80 - victim.getBruteLoss())) // Hurt the human, don't try to kill them though.

	// Sleep for a couple of ticks to allow the human to see the pain
	sleep(0.5 SECONDS)

	use_energy(active_power_usage) // Use a lot of power.

	// monkestation edit start PR #5133
	if(is_ipc_mode || HAS_MIND_TRAIT(victim, TRAIT_UNBORGABLE))
		victim.set_species(/datum/species/ipc)
		victim.heal_damage_type(max(0, 80 - victim.getBruteLoss()), BRUTE)
	// monkestation edit end PR #5133
