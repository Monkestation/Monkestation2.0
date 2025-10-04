/obj/machinery/public_nanite_chamber
	name = "public nanite chamber"
	desc = "A device that can rapidly implant cloud-synced nanites without an external operator."
	circuit = /obj/item/circuitboard/machine/public_nanite_chamber
	icon = 'monkestation/icons/obj/machines/nanites/nanite_machines.dmi'
	icon_state = "nanite_chamber"
	base_icon_state = "nanite_chamber"
	layer = ABOVE_WINDOW_LAYER
	use_power = IDLE_POWER_USE
	anchored = TRUE
	density = TRUE
	idle_power_usage = BASE_MACHINE_IDLE_CONSUMPTION * 0.5
	active_power_usage = BASE_MACHINE_IDLE_CONSUMPTION * 3
	obj_flags = BLOCKS_CONSTRUCTION // Becomes undense when the door is open

	///Unique to the Public nanite chamber, this is the Cloud ID that the occupant will get after the injection animation.
	var/cloud_id = 1

	///The icon file used post-initialize, the default icon is used solely so it shows up in the R&D console.
	///This is because this icon, which we actually use in game, is not 32x32.
	var/chamber_icon = 'monkestation/icons/obj/machines/nanites/nanite_chamber.dmi'
	///Boolean on whether the chamber is locked, which is nearly the same as busy but they both add different overlays.
	var/locked = FALSE
	///Boolean on whether the chamber is busy, preventing the occupant from leaving and being used in icon updating and such.
	var/busy = FALSE
	///The icon state set by `set_busy` which update_appearance will use to swap icon states while busy.
	var/busy_icon_state
	///The cooldown between messages telling a resisting player that they can't leave.
	COOLDOWN_DECLARE(message_cooldown)

/obj/machinery/public_nanite_chamber/Initialize(mapload)
	occupant_typecache = GLOB.typecache_living
	return ..()

/obj/machinery/public_nanite_chamber/RefreshParts()
	. = ..()
	var/obj/item/circuitboard/machine/public_nanite_chamber/board = circuit
	if(board)
		cloud_id = board.cloud_id

/obj/machinery/public_nanite_chamber/update_icon(updates=ALL)
	icon = chamber_icon
	return ..()

/obj/machinery/public_nanite_chamber/update_icon_state()
	. = ..()
	if(!occupant)
		icon_state = "[base_icon_state][state_open ? "_open" : ""]"
		return
	if(busy)
		icon_state = busy_icon_state
	else
		icon_state = "[base_icon_state]_occupied"

/obj/machinery/public_nanite_chamber/update_overlays()
	. = ..()
	if((machine_stat & MAINT) || panel_open)
		. += "maint"
		return .
	if(machine_stat & (NOPOWER|BROKEN))
		return .
	if(!busy && !locked)
		. += "green"
		return .
	if(locked)
		. += "bolted"
		return .
	. += "red"

/obj/machinery/public_nanite_chamber/container_resist_act(mob/living/user)
	if(!locked)
		open_machine()
		return
	if(busy)
		return
	user.changeNext_move(CLICK_CD_BREAKOUT)
	user.last_special = world.time + CLICK_CD_BREAKOUT
	user.visible_message(
		span_notice("You see [user] kicking against the door of [src]!"),
		span_notice("You lean on the back of [src] and start pushing the door open... (this will take about [DisplayTimeText(NANITE_CHAMBER_BREAKOUT_TIME)].)"),
		span_hear("You hear a metallic creaking from [src]."),
	)
	if(!do_after(user, NANITE_CHAMBER_BREAKOUT_TIME, target = src))
		return
	if(!user || user.stat != CONSCIOUS || user.loc != src || state_open || !locked || busy)
		return
	locked = FALSE
	user.visible_message(
		span_warning("[user] successfully broke out of [src]!"),
		span_notice("You successfully break out of [src]!"))
	open_machine()

/obj/machinery/public_nanite_chamber/close_machine(atom/movable/target, density_to_set = TRUE)
	if(!state_open)
		return FALSE
	playsound(src, 'monkestation/sound/nanites/nanite_chamber.wav', 40)
	//If someone is shoved in give them a chance to get out before the injection starts
	addtimer(CALLBACK(src, PROC_REF(try_inject_nanites)), 3 SECONDS)
	return ..()

/obj/machinery/public_nanite_chamber/open_machine(drop = TRUE, density_to_set = FALSE)
	if(state_open)
		return FALSE
	playsound(src, 'monkestation/sound/nanites/nanite_chamber.wav', 40)
	return ..()

/obj/machinery/public_nanite_chamber/relaymove(mob/living/user, direction)
	if((user.stat < HARD_CRIT) && !locked)
		open_machine()
		return
	if(COOLDOWN_FINISHED(src, message_cooldown))
		COOLDOWN_START(src, message_cooldown, 5 SECONDS)
		balloon_alert(user, "door won't budge!")

/obj/machinery/public_nanite_chamber/crowbar_act(mob/living/user, obj/item/tool)
	if(default_pry_open(tool) || default_deconstruction_crowbar(tool))
		return ITEM_INTERACT_SUCCESS
	return ..()

/obj/machinery/public_nanite_chamber/screwdriver_act(mob/living/user, obj/item/tool)
	if(!occupant && default_deconstruction_screwdriver(user, icon_state, icon_state, tool))
		update_appearance()
		return ITEM_INTERACT_SUCCESS
	return ..()

/obj/machinery/public_nanite_chamber/interact(mob/user)
	toggle_open(user)

/obj/machinery/public_nanite_chamber/mouse_drop_receive(mob/living/dropped, mob/user, params)
	if(!user.can_perform_action(src, FORBID_TELEKINESIS_REACH) || !Adjacent(dropped) || !user.Adjacent(dropped) || !can_be_occupant(dropped))
		return
	if(close_machine(dropped))
		log_combat(user, dropped, "inserted", null, "into [src].")
	add_fingerprint(user)

///Called when interacted with, opens/closes the nanite chamber doors as necessary.
/obj/machinery/public_nanite_chamber/proc/toggle_open(mob/user)
	if(panel_open)
		balloon_alert(user, "panel open!")
		return
	if(state_open)
		close_machine()
		return
	if(locked)
		balloon_alert(user, "bolts locked down!")
		return
	open_machine()

///Called when the nanite chamber starts/stops working, this handles 'busy' vars and updating appearances.
/obj/machinery/public_nanite_chamber/proc/set_busy(status, working_icon)
	busy = status
	busy_icon_state = working_icon
	update_appearance(UPDATE_ICON)

///Called after a delay when someone enters the chamber, this sees what needs to be done with the occupant to edit/add nanites.
/obj/machinery/public_nanite_chamber/proc/try_inject_nanites()
	if(isnull(occupant))
		return
	var/datum/component/nanites/nanites = occupant.GetComponent(/datum/component/nanites)
	if(nanites)
		if(nanites && nanites.cloud_id != cloud_id)
			change_cloud(occupant)
		return
	var/mob/living/living_occupant = occupant
	if(living_occupant.mob_biotypes & NANITE_COMPATIBLE_BIOTYPES)
		inject_nanites(occupant)

///Called from try_inject_nanites, this is the startup process of the actual injection of nanites.
/obj/machinery/public_nanite_chamber/proc/inject_nanites()
	if(machine_stat & (NOPOWER|BROKEN))
		return
	if((machine_stat & MAINT) || panel_open)
		return
	if(!occupant || busy)
		return

	var/locked_state = locked
	locked = TRUE

	playsound(src, 'monkestation/sound/nanites/nanite_install_short.mp3', 50)
	set_busy(TRUE, "[initial(icon_state)]_raising")
	addtimer(CALLBACK(src, PROC_REF(set_busy), TRUE, "[initial(icon_state)]_active"), 2 SECONDS)
	addtimer(CALLBACK(src, PROC_REF(set_busy), TRUE, "[initial(icon_state)]_falling"), 6 SECONDS)
	addtimer(CALLBACK(src, PROC_REF(complete_injection), locked_state), 8 SECONDS)

///Called when the nanites are done injecting, this handles unlocking and logging.
/obj/machinery/public_nanite_chamber/proc/complete_injection(locked_state)
	//TODO MACHINE DING
	locked = locked_state
	set_busy(FALSE)
	if(!occupant)
		return
	occupant.investigate_log("was injected with nanites with cloud ID [cloud_id] using [src] at [AREACOORD(src)].", INVESTIGATE_NANITES)
	occupant.AddComponent(/datum/component/nanites, 75, cloud_id)

///Called when entering a public nanite chamber with already existing nanites, this updates your Cloud ID to what the chamber's is.
/obj/machinery/public_nanite_chamber/proc/change_cloud()
	if(machine_stat & (NOPOWER|BROKEN))
		return
	if((machine_stat & MAINT) || panel_open)
		return
	if(!occupant || busy)
		return

	var/locked_state = locked
	locked = TRUE

	set_busy(TRUE, "[initial(icon_state)]_raising")
	addtimer(CALLBACK(src, PROC_REF(set_busy), TRUE, "[initial(icon_state)]_active"), 2 SECONDS)
	addtimer(CALLBACK(src, PROC_REF(set_busy), TRUE, "[initial(icon_state)]_falling"), 4 SECONDS)
	addtimer(CALLBACK(src, PROC_REF(complete_cloud_change), locked_state), 6 SECONDS)

///Called at the end of the animation that changes your Cloud ID, this handles releasing and sending the signal that changes said ID.
/obj/machinery/public_nanite_chamber/proc/complete_cloud_change(locked_state)
	locked = locked_state
	set_busy(FALSE)
	if(!occupant)
		return
	occupant.investigate_log("had their nanite cloud ID changed into [cloud_id] using [src] at [AREACOORD(src)].", INVESTIGATE_NANITES)
	SEND_SIGNAL(occupant, COMSIG_NANITE_SET_CLOUD, cloud_id)
