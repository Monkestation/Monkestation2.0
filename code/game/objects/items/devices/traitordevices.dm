/*

Miscellaneous traitor devices

BATTERER

RADIOACTIVE MICROLASER

*/

/*

The Batterer, like a flashbang but 50% chance to knock people over. Can be either very
effective or pretty fucking useless.

*/

/obj/item/batterer
	name = "mind batterer"
	desc = "A strange device with twin antennas."
	icon = 'icons/obj/device.dmi'
	icon_state = "batterer"
	throwforce = 5
	w_class = WEIGHT_CLASS_TINY
	throw_speed = 3
	throw_range = 7
	flags_1 = CONDUCT_1
	inhand_icon_state = "electronic"
	lefthand_file = 'icons/mob/inhands/items/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items/devices_righthand.dmi'

	var/times_used = 0 //Number of times it's been used.
	var/max_uses = 2


/obj/item/batterer/attack_self(mob/living/carbon/user, flag = 0, emp = 0)
	if(!user) return

	if(times_used >= max_uses)
		to_chat(user, span_danger("The mind batterer has been burnt out!"))
		return

	log_combat(user, null, "knocked down people in the area", src)

	for(var/mob/living/carbon/human/M in urange(10, user, 1))
		if(prob(50))

			M.Paralyze(rand(200,400))
			to_chat(M, span_userdanger("You feel a tremendous, paralyzing wave flood your mind."))

		else
			to_chat(M, span_userdanger("You feel a sudden, electric jolt travel through your head."))

	playsound(src.loc, 'sound/misc/interference.ogg', 50, TRUE)
	to_chat(user, span_notice("You trigger [src]."))
	times_used += 1
	if(times_used >= max_uses)
		icon_state = "battererburnt"

/*
		The radioactive microlaser, a device disguised as a health analyzer used to irradiate people.

		The strength of the radiation is determined by the 'intensity' setting, while the delay between
	the scan and the irradiation kicking in is determined by the wavelength.

		Each scan will cause the microlaser to have a brief cooldown period. Higher intensity will increase
	the cooldown, while higher wavelength will decrease it.

		Wavelength is also slightly increased by the intensity as well.
*/

/obj/item/healthanalyzer/rad_laser
	var/irradiate = TRUE
	var/stealth = FALSE
	var/used = FALSE // is it cooling down?
	var/intensity = 10 // how much damage the radiation does
	var/wavelength = 10 // time it takes for the radiation to kick in, in seconds

/obj/item/healthanalyzer/rad_laser/attack(mob/living/M, mob/living/user)
	if(!stealth || !irradiate)
		..()

	if(!irradiate)
		return

	var/mob/living/carbon/human/human_target = M
	if(istype(human_target) && !used && SSradiation.wearing_rad_protected_clothing(human_target)) //intentionally not checking for TRAIT_RADIMMUNE here so that tatortot can still fuck up and waste their cooldown.
		to_chat(user, span_warning("[M]'s clothing is fully protecting [M.p_them()] from irradiation!"))
		return

	if(!used)
		log_combat(user, M, "irradiated", src)
		var/cooldown = get_cooldown()
		used = TRUE
		icon_state = "health1"
		addtimer(VARSET_CALLBACK(src, used, FALSE), cooldown)
		addtimer(VARSET_CALLBACK(src, icon_state, "health"), cooldown)
		to_chat(user, span_warning("Successfully irradiated [M]."))
		addtimer(CALLBACK(src, PROC_REF(radiation_aftereffect), M, intensity), (wavelength+(intensity*4))*5)
		return

	to_chat(user, span_warning("The radioactive microlaser is still recharging."))

/obj/item/healthanalyzer/rad_laser/proc/radiation_aftereffect(mob/living/M, passed_intensity)
/* MONKESTATION EDIT START
	if(QDELETED(M) || !ishuman(M) || HAS_TRAIT(M, TRAIT_RADIMMUNE))
		return
*/
	if(QDELETED(M) || !ishuman(M))
		return

	if(HAS_TRAIT(M, TRAIT_RADHEALING))
		M.adjustBruteLoss(-round(passed_intensity/0.075))
		M.adjustFireLoss(-round(passed_intensity/0.075))

	if(HAS_TRAIT(M, TRAIT_RADIMMUNE))
		return

// MONKESTATION EDIT END

	if(passed_intensity >= 5)
		M.apply_effect(round(passed_intensity/0.075), EFFECT_UNCONSCIOUS) //to save you some math, this is a round(intensity * (4/3)) second long knockout

/obj/item/healthanalyzer/rad_laser/proc/get_cooldown()
	return round(max(10, (stealth*30 + intensity*5 - wavelength/4)))

/obj/item/healthanalyzer/rad_laser/attack_self(mob/user)
	interact(user)

/obj/item/healthanalyzer/rad_laser/interact(mob/user)
	ui_interact(user)

/obj/item/healthanalyzer/rad_laser/ui_state(mob/user)
	return GLOB.hands_state

/obj/item/healthanalyzer/rad_laser/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "RadioactiveMicrolaser")
		ui.open()

/obj/item/healthanalyzer/rad_laser/ui_data(mob/user)
	var/list/data = list()
	data["irradiate"] = irradiate
	data["stealth"] = stealth
	data["scanmode"] = scanmode
	data["intensity"] = intensity
	data["wavelength"] = wavelength
	data["on_cooldown"] = used
	data["cooldown"] = DisplayTimeText(get_cooldown())
	return data

/obj/item/healthanalyzer/rad_laser/ui_act(action, params)
	. = ..()
	if(.)
		return

	switch(action)
		if("irradiate")
			irradiate = !irradiate
			. = TRUE

		if("stealth")
			stealth = !stealth
			. = TRUE

		if("scanmode")
			scanmode = !scanmode
			. = TRUE

		if("radintensity")
			var/target = params["target"]
			var/adjust = text2num(params["adjust"])
			if(target == "min")
				target = 1
				. = TRUE

			else if(target == "max")
				target = 20
				. = TRUE

			else if(adjust)
				target = intensity + adjust
				. = TRUE

			else if(text2num(target) != null)
				target = text2num(target)
				. = TRUE

			if(.)
				target = round(target)
				intensity = clamp(target, 1, 20)

		if("radwavelength")
			var/target = params["target"]
			var/adjust = text2num(params["adjust"])
			if(target == "min")
				target = 0
				. = TRUE

			else if(target == "max")
				target = 120
				. = TRUE

			else if(adjust)
				target = wavelength + adjust
				. = TRUE

			else if(text2num(target) != null)
				target = text2num(target)
				. = TRUE

			if(.)
				target = round(target)
				wavelength = clamp(target, 0, 120)

/obj/item/storage/belt/military/assault/cloak
	name = "cloaker belt"
	desc = "Makes you invisible for short periods of time. Recharges in darkness while active."
	icon = 'icons/obj/clothing/belts.dmi'
	icon_state = "cloak"
	inhand_icon_state = "security"
	lefthand_file = 'icons/mob/inhands/equipment/belt_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/belt_righthand.dmi'
	worn_icon_state = "assault"
	slot_flags = ITEM_SLOT_BELT

	COOLDOWN_DECLARE(stealth_cooldown)
	var/mob/living/carbon/human/user = null
	var/charge = 300
	var/max_charge = 300
	var/on = FALSE
	actions_types = list(/datum/action/item_action/toggle)

/obj/item/storage/belt/military/assault/cloak/update_overlays()
	. = ..()
	. +=  mutable_appearance(icon, "cloak_meter", alpha = (charge / max_charge) * 255)

/obj/item/storage/belt/military/assault/cloak/Initialize(mapload)
	. = ..()
	update_appearance(UPDATE_OVERLAYS)
	atom_storage.max_slots = 4

/obj/item/storage/belt/military/assault/cloak/ui_action_click(mob/user)
	if(user.get_item_by_slot(ITEM_SLOT_BELT) == src)
		if(!on)
			Activate(usr)

		else
			Deactivate()

	return

/obj/item/storage/belt/military/assault/cloak/item_action_slot_check(slot, mob/user)
	if(slot & ITEM_SLOT_BELT)
		return 1

/obj/item/storage/belt/military/assault/cloak/proc/Activate(mob/living/carbon/human/user)
	if(!user)
		return
	if(!COOLDOWN_FINISHED(src, stealth_cooldown))
		balloon_alert(user, "on cooldown!")
		return
	to_chat(user, span_notice("You activate [src]."))
	RegisterSignal(user, COMSIG_LIVING_MOB_BUMP, PROC_REF(unstealth))
	RegisterSignal(user, COMSIG_HUMAN_MELEE_UNARMED_ATTACK, PROC_REF(on_unarmed_attack))
	RegisterSignal(user, COMSIG_ATOM_BULLET_ACT, PROC_REF(on_bullet_act))
	RegisterSignals(user, list(COMSIG_MOB_ITEM_ATTACK, COMSIG_ATOM_ATTACKBY, COMSIG_ATOM_ATTACK_HAND, COMSIG_ATOM_HITBY, COMSIG_ATOM_HULK_ATTACK, COMSIG_ATOM_ATTACK_PAW, COMSIG_CARBON_CUFF_ATTEMPTED), PROC_REF(unstealth))
	src.user = user
	animate(user,alpha = 25,time = 1.5 SECONDS)
	START_PROCESSING(SSobj, src)
	playsound(src, 'sound/magic/charge.ogg', 50, TRUE)
	on = TRUE

/obj/item/storage/belt/military/assault/cloak/proc/Deactivate(display_message)
	STOP_PROCESSING(SSobj, src)
	if(user)
		animate(user, alpha =  initial(user.alpha), time = 1.5 SECONDS)
		if(display_message)
			to_chat(user, span_notice("You deactivate [src]."))
	UnregisterSignal(user, COMSIG_LIVING_MOB_BUMP)
	UnregisterSignal(user, list(COMSIG_HUMAN_MELEE_UNARMED_ATTACK, COMSIG_MOB_ITEM_ATTACK, COMSIG_ATOM_ATTACKBY, COMSIG_ATOM_ATTACK_HAND, COMSIG_ATOM_BULLET_ACT, COMSIG_ATOM_HITBY, COMSIG_ATOM_HULK_ATTACK, COMSIG_ATOM_ATTACK_PAW, COMSIG_CARBON_CUFF_ATTEMPTED))
	on = FALSE
	user = null

/obj/item/storage/belt/military/assault/cloak/proc/unstealth(datum/source)
	SIGNAL_HANDLER

	COOLDOWN_START(src, stealth_cooldown, 30 SECONDS)
	to_chat(user, span_warning("[src] gets discharged from contact!"))
	do_sparks(2, TRUE, src)
	Deactivate(display_message = FALSE)

/obj/item/storage/belt/military/assault/cloak/proc/on_unarmed_attack(datum/source, atom/target)
	SIGNAL_HANDLER

	if(!isliving(target))
		return
	unstealth(source)

/obj/item/storage/belt/military/assault/cloak/proc/on_bullet_act(datum/source, obj/projectile/projectile)
	SIGNAL_HANDLER

	if(!projectile.is_hostile_projectile())
		return
	unstealth(source)

/obj/item/storage/belt/military/assault/cloak/dropped(mob/user)
	..()
	if(user && user.get_item_by_slot(ITEM_SLOT_BELT) != src)
		Deactivate()

/obj/item/storage/belt/military/assault/cloak/process(seconds_per_tick)
	if(user.get_item_by_slot(ITEM_SLOT_BELT) != src)
		do_sparks(2, TRUE, src)
		Deactivate(display_message = FALSE)
		return

	var/turf/T = get_turf(src)
	if(on)
		var/lumcount = T.get_lumcount()

		if(lumcount > 0.3)
			charge = clamp(charge - 10, 0, max_charge)//Quick decrease in light

		else
			charge = clamp(charge + 20, 0, max_charge)//Charge in the dark
	if(charge == 0)
		balloon_alert(user, "out of charge!")
		do_sparks(2, TRUE, src)
		Deactivate(display_message = FALSE)
	update_appearance(UPDATE_OVERLAYS)

/// Checks if a given atom is in range of a radio jammer, returns TRUE if it is.
/proc/is_within_radio_jammer_range(atom/source)
	for(var/obj/item/jammer/jammer as anything in GLOB.active_jammers)
		if(IN_GIVEN_RANGE(source, jammer, jammer.range))
			return TRUE
	return FALSE

/obj/item/jammer
	name = "radio jammer"
	desc = "Device used to disrupt nearby radio communication. Alternate function creates a powerful distruptor wave which disables all nearby listening devices."
	icon = 'icons/obj/device.dmi'
	icon_state = "jammer"
	var/active = FALSE
	/// The range of devices to disable while active
	var/range = 12

	/// The range of the disruptor wave, disabling radios
	var/disruptor_range = 7

	/// The delay between using the disruptor wave
	var/jam_cooldown_duration = 15 SECONDS
	COOLDOWN_DECLARE(jam_cooldown)

/obj/item/jammer/Initialize(mapload)
	. = ..()
	register_context()

/obj/item/jammer/add_context(atom/source, list/context, obj/item/held_item, mob/user)
	context[SCREENTIP_CONTEXT_LMB] = "Release distruptor wave"
	context[SCREENTIP_CONTEXT_RMB] = "Toggle"
	return CONTEXTUAL_SCREENTIP_SET

/obj/item/jammer/attack_self(mob/user, modifiers)
	. = ..()
	if (!COOLDOWN_FINISHED(src, jam_cooldown))
		user.balloon_alert(user, "on cooldown!")
		return ..()

	user.balloon_alert(user, "distruptor wave released!")
	to_chat(user, span_notice("You release a distruptor wave, disabling all nearby radio devices."))
	for (var/atom/potential_owner in view(disruptor_range, user))
		disable_radios_on(potential_owner, ignore_syndie = TRUE)
	COOLDOWN_START(src, jam_cooldown, jam_cooldown_duration)

/obj/item/jammer/attack_self_secondary(mob/user, modifiers)
	. = ..()
	to_chat(user, span_notice("You [active ? "deactivate" : "activate"] [src]."))
	user.balloon_alert(user, "[active ? "deactivated" : "activated"] the jammer")
	active = !active
	if(active)
		GLOB.active_jammers |= src
	else
		GLOB.active_jammers -= src
	update_appearance()

/obj/item/jammer/Destroy()
	GLOB.active_jammers -= src
	return ..()

/obj/item/jammer/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	. = ..()
	if(.)
		return

	if (!(target in view(disruptor_range, user)))
		user.balloon_alert(user, "out of reach!")
		return

	target.balloon_alert(user, "radio distrupted!")
	to_chat(user, span_notice("You release a directed distruptor wave, disabling all radio devices on [target]."))
	disable_radios_on(target)

/obj/item/jammer/proc/disable_radios_on(atom/target, ignore_syndie = FALSE)
	var/list/target_contents = target.get_all_contents() + target
	for (var/obj/item/radio/radio in target_contents)
		if(ignore_syndie && radio.syndie)
			continue
		radio.set_broadcasting(FALSE)
	for (var/obj/item/bodycam_upgrade/bodycamera in target_contents)
		bodycamera.turn_off()

/obj/item/jammer/makeshift
	name = "makeshift radio jammer"
	desc = "A jury-rigged device that disrupts nearby radio communication. Its crude construction provides a significantly smaller area of effect compared to its Syndicate counterpart."
	range = 5
	disruptor_range = 3

/obj/item/storage/toolbox/emergency/turret
	desc = "You feel a strange urge to hit this with a wrench."
	//type of turret we spawn
	var/turret_type = /obj/machinery/porta_turret/syndicate/toolbox

/obj/item/storage/toolbox/emergency/turret/PopulateContents()
	new /obj/item/screwdriver(src)
	new /obj/item/wrench/combat(src)
	new /obj/item/weldingtool(src)
	new /obj/item/crowbar(src)
	new /obj/item/analyzer(src)
	new /obj/item/wirecutters(src)

/obj/item/storage/toolbox/emergency/turret/attackby(obj/item/attacking_item, mob/living/user, params)
	if(!istype(attacking_item, /obj/item/wrench/combat))
		return ..()

	if(!(user.istate & ISTATE_HARM))
		return

	if(!attacking_item.toolspeed)
		return

	balloon_alert(user, "constructing...")
	if(!attacking_item.use_tool(src, user, 2 SECONDS, volume = 20))
		return

	balloon_alert(user, "constructed!")
	user.visible_message(span_danger("[user] bashes [src] with [attacking_item]!"), \
		span_danger("You bash [src] with [attacking_item]!"), null, COMBAT_MESSAGE_RANGE)

	playsound(src, "sound/items/drill_use.ogg", 80, TRUE, -1)
	var/obj/machinery/porta_turret/syndicate/toolbox/turret = new turret_type(get_turf(loc))
	set_faction(turret, user)
	turret.toolbox = src
	forceMove(turret)

/obj/item/storage/toolbox/emergency/turret/proc/set_faction(obj/machinery/porta_turret/turret, mob/user)
	turret.faction = list("[REF(user)]")

/obj/item/storage/toolbox/emergency/turret/nukie
	turret_type = /obj/machinery/porta_turret/syndicate/toolbox/nukie

/obj/item/storage/toolbox/emergency/turret/nukie/set_faction(obj/machinery/porta_turret/turret, mob/user)
	turret.faction = list(ROLE_SYNDICATE)

/obj/item/storage/toolbox/emergency/turret/nukie/explosives/PopulateContents()
	for(var/i in 1 to 7)
		new /obj/item/grenade/c4/x4(src)

/obj/machinery/porta_turret/syndicate/toolbox
	icon_state = "toolbox_off"
	base_icon_state = "toolbox"
	integrity_failure = 0
	//render the frame underneath?
	var/frame = TRUE
	max_integrity = 100
	shot_delay = 0.5 SECONDS
	stun_projectile = /obj/projectile/bullet/toolbox_turret
	lethal_projectile = /obj/projectile/bullet/toolbox_turret
	subsystem_type = /datum/controller/subsystem/processing/projectiles
	ignore_faction = TRUE
	/// The toolbox we store.
	var/obj/item/toolbox

/obj/machinery/porta_turret/syndicate/toolbox/Initialize(mapload)
	. = ..()
	if(frame)
		underlays += image(icon = icon, icon_state = "[base_icon_state]_frame")

/obj/machinery/porta_turret/syndicate/toolbox/examine(mob/user)
	. = ..()
	if(faction_check(faction, user.faction))
		. += span_notice("You can repair it by <b>left-clicking</b> with a combat wrench.")
		. += span_notice("You can fold it by <b>right-clicking</b> with a combat wrench.")

/obj/machinery/porta_turret/syndicate/toolbox/target(atom/movable/target)
	if(!target)
		return

	if(shootAt(target))
		setDir(get_dir(base, target))

	return TRUE

/obj/machinery/porta_turret/syndicate/toolbox/attackby(obj/item/attacking_item, mob/living/user, params)
	if(!istype(attacking_item, /obj/item/wrench/combat))
		return ..()

	if(!attacking_item.toolspeed)
		return

	if(!attacking_item.toolspeed)
		return

	if((user.istate & ISTATE_HARM))
		balloon_alert(user, "deconstructing...")
		if(!attacking_item.use_tool(src, user, 5 SECONDS, volume = 20, extra_checks = CALLBACK(attacking_item, TYPE_PROC_REF(/obj/item/wrench/combat, is_active))))
			return

		deconstruct(TRUE)
		attacking_item.play_tool_sound(src, 50)
		balloon_alert(user, "deconstructed!")

	else
		if(atom_integrity == max_integrity)
			balloon_alert(user, "already repaired!")
			return

		balloon_alert(user, "repairing...")
		while(atom_integrity != max_integrity)
			if(!attacking_item.use_tool(src, user, 2 SECONDS, volume = 20, extra_checks = CALLBACK(attacking_item, TYPE_PROC_REF(/obj/item/wrench/combat, is_active))))
				return

			repair_damage(10)

		balloon_alert(user, "repaired!")

/obj/machinery/porta_turret/syndicate/toolbox/deconstruct(disassembled)
	if(disassembled)
		var/atom/movable/old_toolbox = toolbox
		toolbox = null
		old_toolbox.forceMove(drop_location())

	else
		new /obj/effect/gibspawner/robot(drop_location())

	return ..()

/obj/machinery/porta_turret/syndicate/toolbox/Destroy()
	toolbox = null
	return ..()

/obj/machinery/porta_turret/syndicate/toolbox/Exited(atom/movable/gone, direction)
	. = ..()
	if(gone == toolbox)
		toolbox = null
		qdel(src)

/obj/machinery/porta_turret/syndicate/toolbox/ui_status(mob/user)
	if(faction_check(user.faction, faction))
		return ..()

	return UI_CLOSE

/obj/projectile/bullet/toolbox_turret
	damage = 10
	speed = 0.6

/obj/machinery/porta_turret/syndicate/toolbox/nukie
	name = "9mm turret"
	icon_state = "syndie_off"
	base_icon_state = "syndie"
	//render the frame underneath?
	frame = FALSE
	max_integrity = 100
	shot_delay = 1.5 SECONDS
	stun_projectile = /obj/projectile/bullet/c9mm/nukie_turret
	stun_projectile_sound = 'monkestation/code/modules/blueshift/sounds/pistol_heavy.ogg'
	lethal_projectile = /obj/projectile/bullet/c9mm/nukie_turret
	lethal_projectile_sound = 'monkestation/code/modules/blueshift/sounds/pistol_heavy.ogg'
	var/activating
	COOLDOWN_DECLARE(acquire_target_cooldown)

/obj/projectile/bullet/c9mm/nukie_turret
	name = "9mm bullet"
	projectile_phasing = PASSMACHINE

/obj/machinery/porta_turret/syndicate/toolbox/nukie/tryToShootAt(list/atom/movable/targets)
	if(targets.len > 0)
		var/atom/movable/M = pick(targets)
		targets -= M
		if(COOLDOWN_FINISHED(src, acquire_target_cooldown))
			activating = TRUE
			COOLDOWN_START(src, acquire_target_cooldown, 10 SECONDS)
			playsound(src, 'sound/machines/beep.ogg', 75, FALSE)
			sleep(0.25 SECONDS)
			playsound(src, 'sound/machines/beep.ogg', 75, TRUE)
			sleep(1.25 SECONDS)
			target(M) //warning shot?
			activating = FALSE
			return
		if(!activating)
			COOLDOWN_START(src, acquire_target_cooldown, 10 SECONDS)
			target(M)
			return

/obj/item/missile_targeter
	name = "missile targeter"
	desc = "A one time use targeter for calling a missile to bomb the designated target. Radius from epicenter: 12 meters."
	desc_controls = "Alt-Click the device to fire the missile."
	icon = 'icons/obj/device.dmi'
	icon_state = "missile_targeter_0"
	inhand_icon_state = "radio"
	lefthand_file = 'icons/mob/inhands/items/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items/devices_righthand.dmi'
	w_class = WEIGHT_CLASS_SMALL
	var/used = FALSE
	var/target_mode_on = FALSE
	var/targeting = FALSE //are we currently targetting
	var/missile_firing = FALSE
	var/obj/effect/abstract/targetting_laser/target_laser
	var/turf/designated_target


/obj/item/missile_targeter/proc/check_usability(mob/user)
	if(used)
		balloon_alert(user, "out of charge!")
		return FALSE
	return TRUE

/obj/item/missile_targeter/attack_self(mob/user)
	if(!(check_usability(user)))
		return
	toggle_targetting_mode(user)

/obj/item/missile_targeter/proc/toggle_targetting_mode(mob/user)
	target_mode_on = !target_mode_on
	balloon_alert(user, "targetting [target_mode_on ? "on" : "off"]")
	update_icon_state()

/obj/item/missile_targeter/afterattack(atom/target, mob/user, proximity_flag)
	. = ..()
	if(!(check_usability(user)))
		return
	if(!target_mode_on)
		balloon_alert(user, "targeting mode off!")
		return
	if(!check_allowed_items(target, not_inside = TRUE))
		return
	. |= AFTERATTACK_PROCESSED_ITEM
	var/turf/targeted_turf = get_turf(target)
	if(targeted_turf.density)
		balloon_alert(user, "target has to be in the open!")
		return
	if(targeted_turf == designated_target)
		balloon_alert(user, "already being targeted!")
		return
	if(targeting)
		balloon_alert(user, "already targetting!")
		return

	targeting = TRUE

	if(!do_after(user, 3 SECONDS, target = target))
		targeting = FALSE
		return
	designated_target = targeted_turf
	if(target_laser)
		qdel(target_laser)
	target_laser = new /obj/effect/abstract/targetting_laser(designated_target)
	playsound(src, 'sound/machines/chime.ogg', 30, TRUE)
	targeting = FALSE

/obj/item/missile_targeter/update_icon_state()
	. = ..()
	if(missile_firing)
		icon_state = "missile_targeter_2"
		return
	if(used)
		icon_state = "missile_targeter_3"
		return
	if(target_mode_on)
		icon_state = "missile_targeter_1"
		return
	icon_state = "missile_targeter_0"

/obj/item/missile_targeter/AltClick(mob/living/user)
	if(!(check_usability(user)))
		return
	if(!designated_target)
		balloon_alert(user, "no target designated!")
		return

	missile_firing = TRUE
	update_icon_state()
	if(target_laser)
		qdel(target_laser)
	var/obj/structure/closet/supplypod/syndicate_missile/new_missile = new()
	new /obj/effect/pod_landingzone(designated_target, new_missile)
	used = TRUE
	to_chat(user, span_userdanger("The [name] vibrates and lets out an ominous alarm."))
	playsound(src, 'sound/machines/warning-buzzer.ogg', 30, TRUE)
	var/area/our_area = get_area(designated_target)
	if(is_station_level(designated_target.z))
		minor_announce("MISSILE ON COLLISION COURSE. COLLISION POINT: [our_area.get_original_area_name()]. ETA: 10 SECONDS.", "Priority Alert", sound_override = 'sound/misc/missile_warn.ogg', should_play_sound = TRUE, color_override = "red")
	sleep(10 SECONDS)
	missile_firing = FALSE
	update_icon_state()

/obj/effect/abstract/targetting_laser
	icon_state = "impact_laser"
	light_outer_range = 2
	light_power = 1
	light_color = COLOR_SOFT_RED
