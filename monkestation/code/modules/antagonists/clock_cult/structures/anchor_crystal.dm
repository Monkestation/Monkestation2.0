#define CRYSTAL_SHIELD_DELAY 50 SECONDS //how long until shields start to recharge
#define CRYSTAL_CHARGING 0 //crystal is currently charging
#define CRYSTAL_LOCATION_ANNOUNCED 1 //the location of the crystal has been anouced to the crew
#define FULLY_CHARGED 2 //the crystal is fully charged
#define SHIELD_ACTIVE "active" //the shield is currently active
#define SHIELD_DEFLECT "deflect" //the shield is currently in its deflecting animation
#define SHIELD_BREAK "break" //the shield is currently in its breaking animation
#define SHIELD_BROKEN "broken" //the shield is currently broken
#define EXTRA_MARKED_AREAS 4 //how many extra adjacent areas do we mark
/obj/structure/destructible/clockwork/anchoring_crystal
	name = "Anchoring Crystal"
	desc = "A strange crystal that you cant quite seem to focus on."
	icon = 'monkestation/icons/obj/clock_cult/clockwork_objects.dmi'
	icon_state = "obelisk"
	break_message = span_warning("As the Anchoring Crystal shatters you swear you hear a faint scream.")
	break_sound = 'monkestation/sound/machines/clockcult/ark_damage.ogg'
	immune_to_servant_attacks = TRUE
	clockwork_desc = "This will help anchor reebe to this realm, allowing for greater power."
	can_rotate = FALSE
	resistance_flags = FIRE_PROOF | ACID_PROOF | LAVA_PROOF
	armor_type = /datum/armor/anchoring_crystal
	max_integrity = 250 //pretty hard to break
	///how many hits this can take before taking structure damage, not using the component as its only for items/mobs
	var/shields = 3
	///what charge state is this crystal
	var/charge_state = CRYSTAL_CHARGING
	///what area is this in
	var/area/crystal_area
	///timer var for charging
	var/charging_for = 0
	///due to the way overlays are handled we have to handle everything for them within a single SIGNAL_HANDLER proc, this var is used for keeping track of what to set our overlay state to next
	var/overlay_state = SHIELD_ACTIVE
	///the list of our charge effect datums
	var/static/list/charge_datums
	///the charge effect datum we are currently using
	var/datum/anchoring_crystal_charge_effect/charge_effect_datum
	///cooldown for when we were last hit
	COOLDOWN_DECLARE(recently_hit_cd)

/datum/armor/anchoring_crystal
	bio = 100
	bomb = 100 //we dont want bombing to be good
	energy = 100
	fire = 100
	acid = 100
	melee = -15 //weak to melee, subject to change
	laser = 60 //resistant to lasers
	bullet = 30

/obj/structure/destructible/clockwork/anchoring_crystal/Initialize(mapload)
	. = ..()
	if(!SSthe_ark.initialized)
		SSthe_ark.Initialize()

	crystal_area = get_area(src)
	SSthe_ark.anchoring_crystals[src] = 0

	SEND_SIGNAL(SSthe_ark, COMSIG_ANCHORING_CRYSTAL_CREATED, src)
	var/conversion_timer = SSthe_ark.convert_area_turfs(crystal_area)
	var/list/adjacent_areas = get_area_edge_turfs(crystal_area, TRUE)[src.z]
	var/extra_marks = 0
	while(length(adjacent_areas) && extra_marks < EXTRA_MARKED_AREAS)
		var/area/marked_area = pick_n_take(adjacent_areas)
		if(marked_area.outdoors || SSthe_ark.marked_areas[marked_area])
			continue

		extra_marks++
		SSthe_ark.marked_areas[marked_area] = TRUE
		SSthe_ark.convert_area_turfs(marked_area, 50, conversion_timer)

	priority_announce("Reality warping object aboard the station, emergency shuttle uplink connection lost.", "Higher Dimensional Affairs", ANNOUNCER_SPANOMALIES, has_important_message = TRUE)
	send_clock_message(null, span_bigbrass(span_bold("An Anchoring Crystal has been created at [crystal_area], defend it!")))
	START_PROCESSING(SSprocessing, src)
	RegisterSignal(src, COMSIG_ATOM_UPDATE_OVERLAYS, PROC_REF(on_update_overlays))
	update_icon()
	START_PROCESSING(SSmachines, src)

	SSthe_ark.marked_areas[crystal_area] = TRUE
	SSthe_ark.block_shuttle(src)
	if(SSthe_ark.valid_crystal_areas)
		SSthe_ark.valid_crystal_areas -= crystal_area

/obj/structure/destructible/clockwork/anchoring_crystal/Destroy()
	SSthe_ark.clear_shuttle_interference(src)
	return ..()

/obj/structure/destructible/clockwork/anchoring_crystal/take_damage(damage_amount, damage_type, damage_flag, sound_effect, attack_dir, armour_penetration)
	COOLDOWN_START(src, recently_hit_cd, CRYSTAL_SHIELD_DELAY)
	if(shields >= 1)
		shields--
		src.visible_message("The attack is deflected by the shield of [src].")
		if(shields > 0)
			overlay_state = SHIELD_DEFLECT
		else
			overlay_state = SHIELD_BREAK
		do_sparks(2, TRUE, src)
		update_icon()
		damage_amount = 0 //dont take damage if we have shields
	return ..()

/obj/structure/destructible/clockwork/anchoring_crystal/process(seconds_per_tick)
	for(var/mob/living/affected_mob in crystal_area)
		if(IS_CLOCK(affected_mob))
			affected_mob.adjustToxLoss(-2.5 * seconds_per_tick) //slightly better tox healing as well as better stam healing around it for servants
			affected_mob.stamina.adjust(7.5 * seconds_per_tick, TRUE)
			continue
		affected_mob.adjust_silence_up_to(5 SECONDS * seconds_per_tick, 2 MINUTES)

	if(charge_state == FULLY_CHARGED) //if fully charged then add the power and return
		SSthe_ark.clock_power = min(SSthe_ark.clock_power + (10 * seconds_per_tick), SSthe_ark.max_clock_power)
		return

	charging_for = min(charging_for + seconds_per_tick, ANCHORING_CRYSTAL_CHARGE_DURATION)

	if(shields < initial(shields) && COOLDOWN_FINISHED(src, recently_hit_cd))
		playsound(src, 'sound/magic/charge.ogg', 50, TRUE)
		shields++
		overlay_state = SHIELD_ACTIVE
		update_icon()

	if(charging_for >= ANCHORING_CRYSTAL_CHARGE_DURATION)
		finish_charging()
		return

	if(charge_state < CRYSTAL_LOCATION_ANNOUNCED && charging_for >= 60) //announce after one minute
		charge_state = CRYSTAL_LOCATION_ANNOUNCED
		priority_announce("Reality warping object located in [crystal_area].", "Central Command Higher Dimensional Affairs", ANNOUNCER_SPANOMALIES, has_important_message = TRUE)

/obj/structure/destructible/clockwork/anchoring_crystal/Destroy()
	send_clock_message(null, span_bigbrass(span_bold("The Anchoring Crystal at [crystal_area] has been destroyed!")))
	SSthe_ark.anchoring_crystals -= src
	STOP_PROCESSING(SSprocessing, src)
	UnregisterSignal(src, COMSIG_ATOM_UPDATE_OVERLAYS)
	return ..()

/obj/structure/destructible/clockwork/anchoring_crystal/examine(mob/user) //needs to be here as it has updating information
	. = ..()
	if(IS_CLOCK(user) || isobserver(user))
		. += span_brass(\
		"[charge_state == FULLY_CHARGED ? "It is fully charged and is indestructable." : "It will be fully charged in [(ANCHORING_CRYSTAL_CHARGE_DURATION - charging_for)] seconds."]")

//do all the stuff for finishing charging
/obj/structure/destructible/clockwork/anchoring_crystal/proc/finish_charging()
	send_clock_message(null, span_bigbrass(span_bold("The Anchoring Crystal at [crystal_area] has fully charged! [anchoring_crystal_charge_message(TRUE)]")))
	charge_state = FULLY_CHARGED
	resistance_flags |= INDESTRUCTIBLE
	atom_integrity = INFINITY
	set_armor(/datum/armor/immune)
	desc += "Reality around it shimmers, making it effectively impervious to damage."
	priority_announce("Reality in [crystal_area] has been destabilized, all personnel are advised to avoid the area.", \
					  "Central Command Higher Dimensional Affairs", ANNOUNCER_SPANOMALIES, has_important_message = TRUE)
	SSthe_ark.max_clock_power += 1000
	SSthe_ark.on_crystal_charged(src)

//set the shield overlay
/obj/structure/destructible/clockwork/anchoring_crystal/proc/on_update_overlays(atom/crystal, list/overlays)
	SIGNAL_HANDLER

	var/mutable_appearance/shield_appearance = mutable_appearance('monkestation/icons/obj/clock_cult/clockwork_effects.dmi', \
																  overlay_state == SHIELD_BROKEN ? "broken" : "clock_shield", ABOVE_OBJ_LAYER)
	if(overlay_state == SHIELD_DEFLECT)
		shield_appearance.icon_state = "clock_shield_deflect"
		overlay_state = SHIELD_ACTIVE
		addtimer(CALLBACK(src, TYPE_PROC_REF(/atom, update_icon)), 3)
	else if(overlay_state == SHIELD_BREAK)
		shield_appearance.icon_state = "clock_shield_break"
		overlay_state = SHIELD_BROKEN
		addtimer(CALLBACK(src, TYPE_PROC_REF(/atom, update_icon)), 2)
	overlays += shield_appearance

///return a message based off of what this anchoring crystal did/will do for the cult
/proc/anchoring_crystal_charge_message(completed = FALSE)
	var/message = ""
	switch(SSthe_ark.charged_anchoring_crystals)
		if(0)
			message = "[completed ? "We can now" : "We will be able to"] support 2 more servants and gain faster build speed with replica fabricators on reebe."
		if(ANCHORING_CRYSTALS_TO_SUMMON - 1)
			message = "[completed ? "We can now" : "We will be able to"] open the ark."
		if(ANCHORING_CRYSTALS_TO_SUMMON)
			message = "The Steam Helios, a strong 2 pilot mech, [completed ? "has been" : "will be"] summoned to reebe."
		if(ANCHORING_CRYSTALS_TO_SUMMON + 1)
			message = "Humaniod servants [completed ? "may now" : "will be able to"] ascend their form to that of a clockwork golem, giving them innate armor, environmental immunity, \
					   and faster invoking for most scriptures."
	return message

#undef CRYSTAL_SHIELD_DELAY
#undef CRYSTAL_CHARGING
#undef CRYSTAL_LOCATION_ANNOUNCED
#undef FULLY_CHARGED
#undef SHIELD_ACTIVE
#undef SHIELD_DEFLECT
#undef SHIELD_BREAK
#undef SHIELD_BROKEN
#undef EXTRA_MARKED_AREAS
