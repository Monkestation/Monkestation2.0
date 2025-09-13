#define NANITE_CHAMBER_BREAKOUT_TIME (2 MINUTES)

/obj/machinery/nanite_chamber
	name = "nanite chamber"
	desc = "A device that can scan, reprogram, and inject nanites."
	circuit = /obj/item/circuitboard/machine/nanite_chamber
	icon = 'monkestation/icons/obj/machines/nanites/nanite_machines.dmi'
	icon_state = "nanite_chamber"
	base_icon_state = "nanite_chamber"
	layer = ABOVE_WINDOW_LAYER
	use_power = IDLE_POWER_USE
	anchored = TRUE
	density = TRUE
	idle_power_usage = 50
	active_power_usage = 300

	///The icon file used post-initialize, the default icon is used solely so it shows up in the R&D console.
	var/chamber_icon = 'monkestation/icons/obj/machines/nanites/nanite_chamber.dmi'
	///The nanite chamber control machine we're synced to.
	var/obj/machinery/computer/nanite_chamber_control/linked_console
	///The level of the scanning module installed in the nanite chamber.
	var/scan_level
	///Boolean on whether we're currently locked, preventing the machine from being opened/closed.
	var/locked = FALSE
	///Boolean on whether the machine is currently busy.
	var/busy = FALSE
	///An icon state we're gonna set ourselves to, given to us by set_busy.
	var/busy_icon_state
	///The message that will be displayed to the nanite controller, given by set_busy.
	var/busy_message
	///The cooldown between messages telling a resisting player that they can't leave.
	COOLDOWN_DECLARE(message_cooldown)

/obj/machinery/nanite_chamber/Initialize(mapload)
	occupant_typecache = GLOB.typecache_living
	return ..()

/obj/machinery/nanite_chamber/RefreshParts()
	. = ..()
	scan_level = 0
	for(var/obj/item/stock_parts/scanning_module/scanning_mod in component_parts)
		scan_level = scanning_mod.rating

/obj/machinery/nanite_chamber/examine(mob/user)
	. = ..()
	if(in_range(user, src) || isobserver(user))
		. += span_notice("The status display reads: Scanning module has been upgraded to level <b>[scan_level]</b>.")

/obj/machinery/nanite_chamber/proc/set_busy(status, message, working_icon)
	busy = status
	busy_message = message
	busy_icon_state = working_icon
	update_appearance(UPDATE_ICON)

/obj/machinery/nanite_chamber/proc/set_safety(threshold)
	if(!occupant)
		return
	SEND_SIGNAL(occupant, COMSIG_NANITE_SET_SAFETY, threshold)

/obj/machinery/nanite_chamber/proc/set_cloud(cloud_id)
	if(!occupant)
		return
	SEND_SIGNAL(occupant, COMSIG_NANITE_SET_CLOUD, cloud_id)

/obj/machinery/nanite_chamber/proc/inject_nanites()
	if(machine_stat & (NOPOWER|BROKEN))
		return
	if((machine_stat & MAINT) || panel_open)
		return
	if(!occupant || busy)
		return

	var/locked_state = locked
	locked = TRUE

	playsound(src, 'monkestation/sound/nanites/nanite_install.wav', 50)
	set_busy(TRUE, "Initializing injection protocol...", "[initial(icon_state)]_raising")
	addtimer(CALLBACK(src, PROC_REF(set_busy), TRUE, "Analyzing host bio-structure...", "[initial(icon_state)]_active"), 2 SECONDS)
	addtimer(CALLBACK(src, PROC_REF(set_busy), TRUE, "Priming nanites...", "[initial(icon_state)]_active"), 4 SECONDS)
	addtimer(CALLBACK(src, PROC_REF(set_busy), TRUE, "Injecting...", "[initial(icon_state)]_active"), 7 SECONDS)
	addtimer(CALLBACK(src, PROC_REF(set_busy), TRUE, "Activating nanites...", "[initial(icon_state)]_falling"), 9 SECONDS)
	addtimer(CALLBACK(src, PROC_REF(complete_injection), locked_state), 11 SECONDS)

/obj/machinery/nanite_chamber/proc/complete_injection(locked_state)
	//TODO MACHINE DING
	locked = locked_state
	set_busy(FALSE)
	if(!occupant || !linked_console.linked_techweb)
		return
	occupant.AddComponent(/datum/component/nanites, linked_console.linked_techweb)

/obj/machinery/nanite_chamber/proc/remove_nanites()
	if(machine_stat & (NOPOWER|BROKEN))
		return
	if((machine_stat & MAINT) || panel_open)
		return
	if(!occupant || busy)
		return

	var/locked_state = locked
	locked = TRUE

	playsound(src, 'monkestation/sound/nanites/nanite_install_short.mp3', 50)
	set_busy(TRUE, "Initializing cleanup protocol...", "[initial(icon_state)]_raising")
	addtimer(CALLBACK(src, PROC_REF(set_busy), TRUE, "Analyzing host bio-structure...", "[initial(icon_state)]_active"), 2 SECONDS)
	addtimer(CALLBACK(src, PROC_REF(set_busy), TRUE, "Pinging nanites...", "[initial(icon_state)]_active"), 3 SECONDS)
	addtimer(CALLBACK(src, PROC_REF(set_busy), TRUE, "Initiating graceful self-destruct sequence...", "[initial(icon_state)]_active"), 5 SECONDS)
	addtimer(CALLBACK(src, PROC_REF(set_busy), TRUE, "Removing debris...", "[initial(icon_state)]_falling"), 7 SECONDS)
	addtimer(CALLBACK(src, PROC_REF(complete_removal), locked_state), 9 SECONDS)

/obj/machinery/nanite_chamber/proc/complete_removal(locked_state)
	//TODO MACHINE DING
	locked = locked_state
	set_busy(FALSE)
	if(!occupant)
		return
	SEND_SIGNAL(occupant, COMSIG_NANITE_DELETE)

/obj/machinery/nanite_chamber/update_icon(updates=ALL)
	icon = chamber_icon
	return ..()

/obj/machinery/nanite_chamber/update_icon_state()
	. = ..()
	if(!occupant)
		icon_state = "[base_icon_state][state_open ? "_open" : ""]"
		return
	if(busy)
		icon_state = busy_icon_state
	else
		icon_state = "[base_icon_state]_occupied"

/obj/machinery/nanite_chamber/update_overlays()
	. = ..()
	if((machine_stat & MAINT) || panel_open)
		. += "maint"
		return .
	if(machine_stat & (NOPOWER|BROKEN))
		return .
	if(!busy && !locked)
		. += "green"
		return .
	. += "red"
	if(locked)
		. += "bolted"

/obj/machinery/nanite_chamber/proc/toggle_open(mob/user)
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

/obj/machinery/nanite_chamber/container_resist_act(mob/living/user)
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

/obj/machinery/nanite_chamber/close_machine(atom/movable/target, density_to_set = TRUE)
	if(!state_open)
		return FALSE
	playsound(src, 'monkestation/sound/nanites/nanite_chamber.wav', 40)
	return ..()

/obj/machinery/nanite_chamber/open_machine(drop = TRUE, density_to_set = FALSE)
	if(state_open)
		return FALSE
	playsound(src, 'monkestation/sound/nanites/nanite_chamber.wav', 40)
	return ..()

/obj/machinery/nanite_chamber/relaymove(mob/living/user, direction)
	if((user.stat < HARD_CRIT) && !locked)
		open_machine()
		return
	if(COOLDOWN_FINISHED(src, message_cooldown))
		COOLDOWN_START(src, message_cooldown, 5 SECONDS)
		balloon_alert(user, "door won't budge!")

/obj/machinery/nanite_chamber/crowbar_act(mob/living/user, obj/item/tool)
	if(default_pry_open(tool) || default_deconstruction_crowbar(tool))
		return ITEM_INTERACT_SUCCESS
	return ..()

/obj/machinery/nanite_chamber/screwdriver_act(mob/living/user, obj/item/tool)
	if(!occupant && default_deconstruction_screwdriver(user, icon_state, icon_state, tool))
		update_appearance()
		return ITEM_INTERACT_SUCCESS
	return ..()

/obj/machinery/nanite_chamber/interact(mob/user)
	toggle_open(user)

/obj/machinery/nanite_chamber/mouse_drop_receive(atom/target, mob/user, params)
	if(!user.can_perform_action(src, FORBID_TELEKINESIS_REACH) || !Adjacent(target) || !user.Adjacent(target) || !(can_be_occupant(target)))
		return
	if(close_machine(target))
		log_combat(user, target, "inserted", null, "into [src].")
	add_fingerprint(user)
