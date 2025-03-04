/obj/structure/bloodsucker
	///Who owns this structure?
	var/mob/living/owner
	/*
	 *	We use vars to add descriptions to items.
	 *	This way we don't have to make a new /examine for each structure
	 *	And it's easier to edit.
	 */
	var/ghost_desc
	var/vamp_desc
	var/vassal_desc
	var/hunter_desc

/obj/structure/bloodsucker/Destroy()
	owner = null
	return ..()

/obj/structure/bloodsucker/examine(mob/user)
	. = ..()
	if(!user.mind && ghost_desc != "")
		. += span_cult(ghost_desc)
	if(IS_BLOODSUCKER(user) && vamp_desc)
		if(!owner)
			. += span_cult("It is unsecured. Click on [src] while in your lair to secure it in place to get its full potential.")
			return
		. += span_cult(vamp_desc)
	if(IS_VASSAL(user) && vassal_desc != "")
		. += span_cult(vassal_desc)
	if(IS_MONSTERHUNTER(user) && hunter_desc != "")
		. += span_cult(hunter_desc)

/// This handles bolting down the structure.
/obj/structure/bloodsucker/proc/bolt(mob/user)
	to_chat(user, span_danger("You have secured [src] in place."))
	to_chat(user, span_announce("* Bloodsucker Tip: Examine [src] to understand how it functions!"))
	owner = user

/// This handles unbolting of the structure.
/obj/structure/bloodsucker/proc/unbolt(mob/user)
	to_chat(user, span_danger("You have unsecured [src]."))
	owner = null

/obj/structure/bloodsucker/attackby(obj/item/item, mob/living/user, params)
	if(IS_BLOODSUCKER(user) && item.tool_behaviour == TOOL_WRENCH && !anchored)
		user.playsound_local(null, 'sound/machines/buzz-sigh.ogg', 40, FALSE, pressure_affected = FALSE)
		to_chat(user, span_announce("* Bloodsucker Tip: Examine Bloodsucker structures to understand how they function!"))
		return TRUE
	return ..()

/obj/structure/bloodsucker/attack_hand(mob/user, list/modifiers)
//	. = ..() // Don't call parent, else they will handle unbuckling.
	var/datum/antagonist/bloodsucker/bloodsuckerdatum = user.mind.has_antag_datum(/datum/antagonist/bloodsucker)
	/// Claiming the Rack instead of using it?
	if(istype(bloodsuckerdatum) && !owner)
		if(!bloodsuckerdatum.bloodsucker_lair_area)
			to_chat(user, span_danger("You don't have a lair. Claim a coffin to make that location your lair."))
			return FALSE
		if(bloodsuckerdatum.bloodsucker_lair_area != get_area(src))
			to_chat(user, span_danger("You may only activate this structure in your lair: [bloodsuckerdatum.bloodsucker_lair_area]."))
			return FALSE

		/// Radial menu for securing your Persuasion rack in place.
		to_chat(user, span_notice("Do you wish to secure [src] here?"))
		var/static/list/secure_options = list(
			"Yes" = image(icon = 'icons/hud/radial.dmi', icon_state = "radial_yes"),
			"No" = image(icon = 'icons/hud/radial.dmi', icon_state = "radial_no"))
		var/secure_response = show_radial_menu(user, src, secure_options, radius = 36, require_near = TRUE)
		if(!secure_response)
			return FALSE
		switch(secure_response)
			if("Yes")
				user.playsound_local(null, 'sound/items/ratchet.ogg', 70, FALSE, pressure_affected = FALSE)
				bolt(user)
				return FALSE
		return FALSE
	return TRUE

/obj/structure/bloodsucker/AltClick(mob/user)
	. = ..()
	if(user == owner && user.Adjacent(src))
		balloon_alert(user, "unbolt [src]?")
		var/static/list/unclaim_options = list(
			"Yes" = image(icon = 'icons/hud/radial.dmi', icon_state = "radial_yes"),
			"No" = image(icon = 'icons/hud/radial.dmi', icon_state = "radial_no"),
		)
		var/unclaim_response = show_radial_menu(user, src, unclaim_options, radius = 36, require_near = TRUE)
		switch(unclaim_response)
			if("Yes")
				unbolt(user)
/*
/obj/structure/bloodsucker/bloodaltar
	name = "bloody altar"
	desc = "It is made of marble, lined with basalt, and radiates an unnerving chill that puts your skin on edge."
/obj/structure/bloodsucker/bloodstatue
	name = "bloody countenance"
	desc = "It looks upsettingly familiar..."
/obj/structure/bloodsucker/bloodportrait
	name = "oil portrait"
	desc = "A disturbingly familiar face stares back at you. Those reds don't seem to be painted in oil..."
/obj/structure/bloodsucker/bloodbrazier
	name = "lit brazier"
	desc = "It burns slowly, but doesn't radiate any heat."
/obj/structure/bloodsucker/bloodmirror
	name = "faded mirror"
	desc = "You get the sense that the foggy reflection looking back at you has an alien intelligence to it."
/obj/item/restraints/legcuffs/beartrap/bloodsucker
*/

/obj/structure/bloodsucker/vassalrack
	name = "persuasion rack"
	desc = "If this wasn't meant for torture, then someone has some fairly horrifying hobbies."
	icon = 'monkestation/icons/bloodsuckers/vamp_obj.dmi'
	icon_state = "vassalrack"
	anchored = FALSE
	density = TRUE
	can_buckle = TRUE
	buckle_lying = 180
	ghost_desc = "This is a Vassal rack, which allows Bloodsuckers to thrall crewmembers into loyal minions."
	vamp_desc = "This is the Vassal rack, which allows you to thrall crewmembers into loyal minions in your service.\n\
		Simply click and hold on a victim, and then drag their sprite on the vassal rack. Right-click on the vassal rack to unbuckle them.\n\
		To convert into a Vassal, repeatedly click on the persuasion rack. The time required scales with the tool in your off hand. This costs Blood to do.\n\
		Vassals can be turned into special ones by continuing to torture them once converted."
	vassal_desc = "This is the vassal rack, which allows your master to thrall crewmembers into their minions.\n\
		Aid your master in bringing their victims here and keeping them secure.\n\
		You can secure victims to the vassal rack by click dragging the victim onto the rack while it is secured."
	hunter_desc = "This is the vassal rack, which monsters use to brainwash crewmembers into their loyal slaves.\n\
		They usually ensure that victims are handcuffed, to prevent them from running away.\n\
		Their rituals take time, allowing us to disrupt it."

	/// Resets on each new character to be added to the chair. Some effects should lower it...
	var/convert_progress = 3
	/// Mindshielded and Antagonists willingly have to accept you as their Master.
	var/disloyalty_confirm = FALSE
	/// Prevents popup spam.
	var/disloyalty_offered = FALSE
	// Prevent spamming torture via spam click. Otherwise they're able to lose a lot of blood quickly
	var/blood_draining = FALSE

/obj/structure/bloodsucker/vassalrack/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/elevation, pixel_shift = 14)

/obj/structure/bloodsucker/vassalrack/deconstruct(disassembled = TRUE)
	new /obj/item/stack/sheet/iron(drop_location(), 4)
	new /obj/item/stack/rods(drop_location(), 4)
	return ..()

/obj/structure/bloodsucker/vassalrack/examine(mob/user)
	. = ..()
	var/datum/antagonist/bloodsucker/bloodsuckerdatum = IS_BLOODSUCKER(user)
	if(bloodsuckerdatum)
		var/remaining_vassals = bloodsuckerdatum.return_current_max_vassals() - length(bloodsuckerdatum.vassals)
		if(remaining_vassals > 0)
			. += span_info("You are currently capable of creating <b>[remaining_vassals]</b> more vassal\s.")
		else
			. += span_warning("You cannot create any more vassals at the moment!")

/obj/structure/bloodsucker/vassalrack/attackby(obj/item/item, mob/living/user, params)
	if(IS_BLOODSUCKER(user) && has_buckled_mobs() && !(user.istate & ISTATE_HARM))
		return torture_interact(user, item)
	return ..()

/obj/structure/bloodsucker/vassalrack/bolt()
	. = ..()
	set_density(FALSE)
	set_anchored(TRUE)

/obj/structure/bloodsucker/vassalrack/unbolt()
	. = ..()
	unbuckle_all_mobs()
	set_density(TRUE)
	set_anchored(FALSE)

/obj/structure/bloodsucker/vassalrack/MouseDrop_T(atom/movable/movable_atom, mob/user)
	if(DOING_INTERACTION(user, DOAFTER_SOURCE_PERSUASION_RACK))
		return
	var/mob/living/living_target = movable_atom
	if(!anchored && IS_BLOODSUCKER(user))
		to_chat(user, span_danger("Until this rack is secured in place, it cannot serve its purpose."))
		to_chat(user, span_announce("* Bloodsucker Tip: Examine the Persuasion Rack to understand how it functions!"))
		return
	// Default checks
	if(!isliving(movable_atom) || !living_target.Adjacent(src) || living_target == user || !isliving(user) || has_buckled_mobs() || user.incapacitated() || living_target.buckled)
		return
	// Don't buckle Silicon to it please.
	if(issilicon(living_target))
		to_chat(user, span_danger("You realize that this machine cannot be vassalized, therefore it is useless to buckle them."))
		return
	if(do_after(user, 5 SECONDS, living_target, interaction_key = DOAFTER_SOURCE_PERSUASION_RACK))
		attach_victim(living_target, user)

/// Attempt Release (Owner vs Non Owner)
/obj/structure/bloodsucker/vassalrack/attack_hand_secondary(mob/user, modifiers)
	. = ..()
	if(. == SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN)
		return
	if(DOING_INTERACTION(user, DOAFTER_SOURCE_PERSUASION_RACK))
		return
	if(!user.can_perform_action(src))
		return
	if(!has_buckled_mobs() || !isliving(user))
		return
	var/mob/living/carbon/buckled_carbons = pick(buckled_mobs)
	if(buckled_carbons)
		if(user == owner)
			unbuckle_mob(buckled_carbons)
		else
			user_unbuckle_mob(buckled_carbons, user)

/**
 * Attempts to buckle target into the vassalrack
 */
/obj/structure/bloodsucker/vassalrack/proc/attach_victim(mob/living/target, mob/living/user)
	if(!buckle_mob(target))
		return
	user.visible_message(
		span_notice("[user] straps [target] into the rack, immobilizing them."),
		span_boldnotice("You secure [target] tightly in place. They won't escape you now."),
	)

	playsound(loc, 'sound/effects/pop_expl.ogg', vol = 25, vary = TRUE)
	update_appearance(UPDATE_ICON)
	set_density(TRUE)

	// Set up Torture stuff now
	reset_progress()

/// Attempt Unbuckle
/obj/structure/bloodsucker/vassalrack/user_unbuckle_mob(mob/living/buckled_mob, mob/user)
	if(DOING_INTERACTION(user, DOAFTER_SOURCE_PERSUASION_RACK))
		return
	if(IS_BLOODSUCKER(user) || IS_VASSAL(user))
		return ..()

	if(buckled_mob == user)
		buckled_mob.visible_message(
			span_danger("[user] tries to release themself from the rack!"),
			span_danger("You attempt to release yourself from the rack!"),
			span_hear("You hear a squishy wet noise.")
		)
		if(!do_after(user, 20 SECONDS, buckled_mob, interaction_key = DOAFTER_SOURCE_PERSUASION_RACK))
			return
	else
		buckled_mob.visible_message(
			span_danger("[user] tries to pull [buckled_mob] from the rack!"),
			span_danger("[user] tries to pull [buckled_mob] from the rack!"),
			span_hear("You hear a squishy wet noise.")
		)
		if(!do_after(user, 10 SECONDS, buckled_mob, interaction_key = DOAFTER_SOURCE_PERSUASION_RACK))
			return

	return ..()

/obj/structure/bloodsucker/vassalrack/unbuckle_mob(mob/living/buckled_mob, force = FALSE, can_fall = TRUE)
	. = ..()
	if(!.)
		return FALSE
	visible_message(span_danger("[buckled_mob][buckled_mob.stat == DEAD ? "'s corpse" : ""] slides off of the rack."))
	set_density(FALSE)
	buckled_mob.Paralyze(2 SECONDS)
	update_appearance(UPDATE_ICON)
	reset_progress()
	return TRUE

/obj/structure/bloodsucker/vassalrack/attack_hand(mob/user, list/modifiers)
	. = ..()
	if(.)
		return torture_interact(user)

/obj/structure/bloodsucker/vassalrack/proc/torture_interact(mob/user, tool = null)
	if(DOING_INTERACTION(user, DOAFTER_SOURCE_PERSUASION_RACK))
		return FALSE
	// Is there anyone on the rack & If so, are they being tortured?
	if(!has_buckled_mobs())
		balloon_alert(user, "nobody buckled!")
		return FALSE

	var/datum/antagonist/bloodsucker/bloodsuckerdatum = user.mind.has_antag_datum(/datum/antagonist/bloodsucker)
	var/mob/living/carbon/buckled_carbons = pick(buckled_mobs)
	// If I'm not a Bloodsucker, try to unbuckle them.
	if(!istype(bloodsuckerdatum))
		user_unbuckle_mob(buckled_carbons, user)
		return
	if(!bloodsuckerdatum.my_clan)
		to_chat(user, span_warning("You can't vassalize people until you enter a Clan (Through your Antagonist UI button)"))
		user.balloon_alert(user, "join a clan first!")
		return

	var/datum/antagonist/vassal/vassaldatum = IS_VASSAL(buckled_carbons)
	// Are they our Vassal?
	if(vassaldatum?.master == bloodsuckerdatum)
		SEND_SIGNAL(bloodsuckerdatum, BLOODSUCKER_INTERACT_WITH_VASSAL, vassaldatum)
		return

	// Not our Vassal, but Alive & We're a Bloodsucker, good to torture!
	torture_victim(user, buckled_carbons)

/**
 * Torture steps:
 *
 * * Tick Down Conversion from 3 to 0
 * * Break mindshielding/antag (on approve)
 * * Vassalize target
 */
/obj/structure/bloodsucker/vassalrack/proc/torture_victim(mob/living/user, mob/living/target, tool = null)
	var/datum/antagonist/bloodsucker/bloodsuckerdatum = user.mind.has_antag_datum(/datum/antagonist/bloodsucker)
	if(target.stat > UNCONSCIOUS)
		balloon_alert(user, "too badly injured!")
		return FALSE

	if(IS_VASSAL(target))
		var/datum/antagonist/vassal/vassaldatum = target.mind.has_antag_datum(/datum/antagonist/vassal)
		if(!vassaldatum.master.broke_masquerade)
			balloon_alert(user, "someone else's vassal!")
			return FALSE

	if(!iscarbon(target))
		balloon_alert(user, "you can't torture an animal or basic mob!")
		return FALSE
	if(disloyalty_offered)
		balloon_alert(user, "wait a moment!")
		return FALSE
	var/disloyalty_requires = RequireDisloyalty(user, target)

	if(disloyalty_requires == VASSALIZATION_BANNED)
		balloon_alert(user, "can't be vassalized!")
		return FALSE

	// Conversion Process
	if(convert_progress)
		//Are we currently torturing this person? If so, do not spill blood more.
		if(blood_draining)
			balloon_alert(user, "already spilling blood!")
			return
		//We're torturing. Do not start another torture on this rack.
		blood_draining = TRUE
		balloon_alert(user, "spilling blood...")
		bloodsuckerdatum.AddBloodVolume(-TORTURE_BLOOD_HALF_COST)
		if(!do_torture(user, target, tool = tool))
			return FALSE
		bloodsuckerdatum.AddBloodVolume(-TORTURE_BLOOD_HALF_COST)
		// Prevent them from unbuckling themselves as long as we're torturing.
		target.Paralyze(1 SECONDS)
		convert_progress--

		// We're done? Let's see if they can be Vassal.
		if(convert_progress)
			balloon_alert(user, "needs more persuasion...")
			return

		if(disloyalty_requires)
			balloon_alert(user, "has external loyalties! more persuasion required!")
		else
			balloon_alert(user, "ready for communion!")
			return

		if(!disloyalty_confirm && disloyalty_requires)
			if(!do_disloyalty(user, target))
				return
			if(!disloyalty_confirm)
				balloon_alert(user, "refused persuasion!")
				convert_progress++
			else
				balloon_alert(user, "ready for communion!")
			return
	//If they don't need any more torture, start converting them into a vassal!
	else
		user.balloon_alert_to_viewers("smears blood...", "painting bloody marks...")
		if(!do_after(user, 5 SECONDS, target, interaction_key = DOAFTER_SOURCE_PERSUASION_RACK))
			balloon_alert(user, "interrupted!")
			return
		// Convert to Vassal!
		bloodsuckerdatum.AddBloodVolume(-TORTURE_CONVERSION_COST)
		if(bloodsuckerdatum.make_vassal(target))
			remove_loyalties(target)
			SEND_SIGNAL(bloodsuckerdatum, BLOODSUCKER_MADE_VASSAL, user, target)

/obj/structure/bloodsucker/vassalrack/proc/do_torture(mob/living/user, mob/living/carbon/target, mult = 1, tool = null)
	// Fifteen seconds if you aren't using anything. Shorter with weapons and such.
	var/torture_time = 15
	var/torture_dmg_brute = 2
	var/torture_dmg_burn = 0
	var/obj/item/bodypart/selected_bodypart = pick(target.bodyparts)
	// Get Weapon
	var/obj/item/held_item = tool || user.get_inactive_held_item()
	/// Weapon Bonus
	if(held_item)
		torture_time -= held_item.force / 4
		if(!held_item.use_tool(src, user, 0, volume = 5))
			return
		switch(held_item.damtype)
			if(BRUTE)
				torture_dmg_brute = held_item.force / 4
				torture_dmg_burn = 0
			if(BURN)
				torture_dmg_brute = 0
				torture_dmg_burn = held_item.force / 4
		switch(held_item.sharpness)
			if(SHARP_EDGED)
				torture_time -= 2
			if(SHARP_POINTY)
				torture_time -= 3

	// Minimum 5 seconds.
	torture_time = max(5 SECONDS, torture_time SECONDS)
	// Now run process.
	if(!do_after(user, (torture_time * mult), target, interaction_key = DOAFTER_SOURCE_PERSUASION_RACK))
		//Torture failed. You can start again.
		blood_draining = FALSE
		return FALSE

	held_item?.play_tool_sound(target)
	target.visible_message(
		span_danger("[user] performs a ritual, spilling some of [target]'s blood from [user.p_their()] [selected_bodypart.name] and shaking them up!"),
		span_userdanger("[user] performs a ritual, spilling some blood from your [selected_bodypart.name], shaking you up!")
	)

	INVOKE_ASYNC(target, TYPE_PROC_REF(/mob, emote), "scream")
	target.set_timed_status_effect(5 SECONDS, /datum/status_effect/jitter, only_if_higher = TRUE)
	target.apply_damages(brute = torture_dmg_brute, burn = torture_dmg_burn, def_zone = selected_bodypart.body_zone)
	//Torture succeeded. You may torture again.
	blood_draining = FALSE
	return TRUE

/// Offer them the oppertunity to join now.
/obj/structure/bloodsucker/vassalrack/proc/do_disloyalty(mob/living/user, mob/living/target)
	if(disloyalty_offered)
		return FALSE

	disloyalty_offered = TRUE
	to_chat(user, span_notice("[target] has been given the opportunity for servitude. You await their decision..."))
	var/alert_response = tgui_alert(
		user = target, \
		message = "You are being tortured! Do you want to give in and pledge your undying loyalty to [user]? \n\
			You will not lose your current objectives, but they come second to the will of your new master!", \
		title = "THE HORRIBLE PAIN! WHEN WILL IT END?!",
		buttons = list("Accept", "Refuse"),
		timeout = 10 SECONDS, \
		autofocus = TRUE, \
	)
	switch(alert_response)
		if("Accept")
			disloyalty_confirm = TRUE
		else
			target.balloon_alert_to_viewers("stares defiantly", "refused vassalization!")
	disloyalty_offered = FALSE
	return TRUE

/obj/structure/bloodsucker/vassalrack/proc/RequireDisloyalty(mob/living/user, mob/living/target)
#ifdef BLOODSUCKER_TESTING
	if(!target?.mind)
#else
	if(!target?.client)
#endif
		balloon_alert(user, "target has no mind!")
		return VASSALIZATION_BANNED

	var/datum/antagonist/bloodsucker/bloodsuckerdatum = IS_BLOODSUCKER(user)
	return bloodsuckerdatum.AmValidAntag(target)

/obj/structure/bloodsucker/vassalrack/proc/remove_loyalties(mob/living/target)
	// Find Mind Implant & Destroy
	for(var/obj/item/implant/implant as anything in target.implants)
		if(istype(implant, /obj/item/implant/mindshield) && implant.removed(target, silent = TRUE))
			qdel(implant)

/obj/structure/bloodsucker/vassalrack/proc/reset_progress()
	convert_progress = initial(convert_progress)
	disloyalty_offered = initial(disloyalty_offered)
	disloyalty_confirm = initial(disloyalty_confirm)
	blood_draining = initial(blood_draining)

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

/obj/structure/bloodsucker/candelabrum
	name = "candelabrum"
	desc = "It burns slowly, but doesn't radiate any heat."
	icon = 'monkestation/icons/bloodsuckers/vamp_obj.dmi'
	icon_state = "candelabrum"
	base_icon_state = "candelabrum"
	light_color = "#66FFFF"
	light_power = 3
	light_outer_range = 2
	light_on = FALSE
	density = FALSE
	can_buckle = TRUE
	anchored = FALSE
	ghost_desc = "This is a magical candle which drains at the sanity of non Bloodsuckers and Vassals.\n\
		Vassals can turn the candle on manually, while Bloodsuckers can do it from a distance."
	vamp_desc = "This is a magical candle which drains at the sanity of mortals who are not under your command while it is active.\n\
		You can right-click on it from any range to turn it on remotely, or simply be next to it and click on it to turn it on and off normally."
	vassal_desc = "This is a magical candle which drains at the sanity of the fools who havent yet accepted your master, as long as it is active.\n\
		You can turn it on and off by clicking on it while you are next to it.\n\
		If your Master is part of the Ventrue Clan, they utilize this to upgrade their Favorite Vassal."
	hunter_desc = "This is a blue Candelabrum, which causes insanity to those near it while active."
	var/lit = FALSE

/obj/structure/bloodsucker/candelabrum/Initialize(mapload)
	. = ..()
	RegisterSignal(src, COMSIG_CLICK, PROC_REF(distance_toggle))

/obj/structure/bloodsucker/candelabrum/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/structure/bloodsucker/candelabrum/bolt()
	. = ..()
	set_anchored(TRUE)
	set_density(TRUE)

/obj/structure/bloodsucker/candelabrum/unbolt()
	. = ..()
	set_anchored(FALSE)
	set_density(FALSE)
	set_lit(FALSE)

/obj/structure/bloodsucker/candelabrum/update_icon_state()
	icon_state = "[base_icon_state][lit ? "_lit" : ""]"
	return ..()

/obj/structure/bloodsucker/candelabrum/update_desc(updates)
	if(lit)
		desc = initial(desc)
	else
		desc = "Despite not being lit, it makes your skin crawl."
	return ..()

/obj/structure/bloodsucker/candelabrum/update_overlays()
	. = ..()
	if(lit)
		. += emissive_appearance(icon, "[base_icon_state]_lit_emissive", src)

/obj/structure/bloodsucker/candelabrum/proc/distance_toggle(datum/source, atom/location, control, params, mob/user)
	SIGNAL_HANDLER
	if(anchored && !user.incapacitated() && IS_BLOODSUCKER(user) && !user.Adjacent(src))
		set_lit(!lit)

/obj/structure/bloodsucker/candelabrum/attack_hand(mob/living/user, list/modifiers)
	. = ..()
	if(!.)
		return
	if(anchored && (IS_VASSAL(user) || IS_BLOODSUCKER(user)))
		set_lit(!lit)

/obj/structure/bloodsucker/candelabrum/proc/set_lit(value)
	lit = value
	if(lit)
		set_light_on(TRUE)
		START_PROCESSING(SSobj, src)
	else
		set_light_on(FALSE)
		STOP_PROCESSING(SSobj, src)
	update_appearance(UPDATE_ICON | UPDATE_DESC)

/obj/structure/bloodsucker/candelabrum/process()
	if(!lit)
		set_lit(FALSE)
		return PROCESS_KILL
	for(var/mob/living/carbon/nearly_people in viewers(7, src))
		/// We dont want Bloodsuckers or Vassals affected by this
		if(IS_VASSAL(nearly_people) || IS_BLOODSUCKER(nearly_people) || IS_MONSTERHUNTER(nearly_people))
			continue
		nearly_people.set_hallucinations_if_lower(5 SECONDS)
		nearly_people.add_mood_event("vampcandle", /datum/mood_event/vampcandle)

/// Blood Throne - Allows Bloodsuckers to remotely speak with their Vassals. - Code (Mostly) stolen from comfy chairs (armrests) and chairs (layers)
/obj/structure/bloodsucker/bloodthrone
	name = "wicked throne"
	desc = "Twisted metal shards jut from the arm rests. Very uncomfortable looking. It would take a masochistic sort to sit on this jagged piece of furniture."
	icon = 'monkestation/icons/bloodsuckers/vamp_obj_64.dmi'
	icon_state = "throne"
	buckle_lying = 0
	anchored = FALSE
	density = TRUE
	can_buckle = TRUE
	ghost_desc = "This is a Bloodsucker throne, any Bloodsucker sitting on it can remotely speak to their Vassals by attempting to speak aloud."
	vamp_desc = "This is a blood throne, sitting on it will allow you to telepathically speak to your vassals by simply speaking."
	vassal_desc = "This is a blood throne, it allows your Master to telepathically speak to you and others like you."
	hunter_desc = "This is a chair that hurts those that try to buckle themselves onto it, though the Undead have no problem latching on.\n\
		While buckled, Monsters can use this to telepathically communicate with eachother."
	var/mutable_appearance/armrest

// Add rotating and armrest
/obj/structure/bloodsucker/bloodthrone/Initialize()
	AddComponent(/datum/component/simple_rotation)
	armrest = GetArmrest()
	armrest.layer = ABOVE_MOB_LAYER
	return ..()

/obj/structure/bloodsucker/bloodthrone/Destroy()
	QDEL_NULL(armrest)
	return ..()

/obj/structure/bloodsucker/bloodthrone/bolt()
	. = ..()
	set_anchored(TRUE)

/obj/structure/bloodsucker/bloodthrone/unbolt()
	. = ..()
	set_anchored(FALSE)

// Armrests
/obj/structure/bloodsucker/bloodthrone/proc/GetArmrest()
	return mutable_appearance('monkestation/icons/bloodsuckers/vamp_obj_64.dmi', "thronearm")

/obj/structure/bloodsucker/bloodthrone/proc/update_armrest()
	if(has_buckled_mobs())
		add_overlay(armrest)
	else
		cut_overlay(armrest)

// Rotating
/obj/structure/bloodsucker/bloodthrone/setDir(newdir)
	. = ..()
	if(has_buckled_mobs())
		for(var/m in buckled_mobs)
			var/mob/living/buckled_mob = m
			buckled_mob.setDir(newdir)

	if(has_buckled_mobs() && dir == NORTH)
		layer = ABOVE_MOB_LAYER
	else
		layer = OBJ_LAYER

// Buckling
/obj/structure/bloodsucker/bloodthrone/buckle_mob(mob/living/user, force = FALSE, check_loc = TRUE)
	if(!anchored)
		to_chat(user, span_announce("[src] is not bolted to the ground!"))
		return
	. = ..()
	user.visible_message(
		span_notice("[user] sits down on \the [src]."),
		span_boldnotice("You sit down onto [src]."),
	)
	if(IS_BLOODSUCKER(user))
		RegisterSignal(user, COMSIG_MOB_SAY, PROC_REF(handle_speech))
	else
		unbuckle_mob(user)
		user.Paralyze(10 SECONDS)
		to_chat(user, span_cult("The power of the blood throne overwhelms you!"))

/obj/structure/bloodsucker/bloodthrone/post_buckle_mob(mob/living/target)
	. = ..()
	update_armrest()
	target.pixel_y += 2

// Unbuckling
/obj/structure/bloodsucker/bloodthrone/unbuckle_mob(mob/living/user, force = FALSE, can_fall = TRUE)
	visible_message(span_danger("[user] unbuckles [user.p_them()]self from \the [src]."))
	if(IS_BLOODSUCKER(user))
		UnregisterSignal(user, COMSIG_MOB_SAY)
	. = ..()

/obj/structure/bloodsucker/bloodthrone/post_unbuckle_mob(mob/living/target)
	target.pixel_y -= 2

// The speech itself
/obj/structure/bloodsucker/bloodthrone/proc/handle_speech(datum/source, list/speech_args)
	SIGNAL_HANDLER

	// ignore forced speech
	if(speech_args[SPEECH_FORCED])
		return
	var/message = speech_args[SPEECH_MESSAGE]
	var/mob/living/carbon/human/user = source
	var/rendered = span_cultlarge("<b>[user.real_name]:</b> [message]")
	user.log_talk(message, LOG_SAY, tag=ROLE_BLOODSUCKER)
	var/datum/antagonist/bloodsucker/bloodsuckerdatum = user.mind.has_antag_datum(/datum/antagonist/bloodsucker)
	for(var/datum/antagonist/vassal/receiver as anything in bloodsuckerdatum.vassals)
		var/mob/receiver_mob = receiver?.owner?.current
		if(QDELETED(receiver_mob))
			continue
		to_chat(receiver_mob, rendered, type = MESSAGE_TYPE_RADIO)
	to_chat(user, rendered, type = MESSAGE_TYPE_RADIO, avoid_highlighting = TRUE) // tell yourself, too.

	for(var/mob/dead_mob in GLOB.dead_mob_list)
		var/link = FOLLOW_LINK(dead_mob, user)
		to_chat(dead_mob, "[link] [rendered]", type = MESSAGE_TYPE_RADIO)

	speech_args[SPEECH_MESSAGE] = ""

/// Blood mirror wallframe item.
/obj/item/wallframe/blood_mirror
	name = "scarlet mirror"
	desc = "A pool of stilled blood kept secure between unanchored glass and silver. Attach it to a wall to use."
	icon = 'monkestation/icons/bloodsuckers/vamp_obj.dmi'
	icon_state = "blood_mirror"
	custom_materials = list(
		/datum/material/glass = SHEET_MATERIAL_AMOUNT,
		/datum/material/silver = SHEET_MATERIAL_AMOUNT,
	)
	result_path = /obj/structure/bloodsucker/mirror
	pixel_shift = 28

//Copied over from 'wall_mounted.dm' with necessary alterations
/obj/item/wallframe/blood_mirror/attach(turf/on_wall, mob/user)
	if(!IS_BLOODSUCKER(user))
		balloon_alert(user, "you don't understand its mounting mechanism!")
		return
	var/datum/antagonist/bloodsucker/bloodsuckerdatum = user.mind.has_antag_datum(/datum/antagonist/bloodsucker)
	if(get_area(user) == bloodsuckerdatum.bloodsucker_lair_area)
		playsound(src.loc, 'sound/machines/click.ogg', 75, TRUE)
		user.visible_message(span_notice("[user.name] attaches [src] to the wall."),
			span_notice("You attach [src] to the wall."),
			span_hear("You hear clicking."))
		var/floor_to_wall = get_dir(user, on_wall)

		var/obj/structure/bloodsucker/mirror/hanging_object = new result_path(get_turf(user), floor_to_wall, TRUE)
		hanging_object.setDir(floor_to_wall)
		if(pixel_shift)
			switch(floor_to_wall)
				if(NORTH)
					hanging_object.pixel_y = pixel_shift
				if(SOUTH)
					hanging_object.pixel_y = -pixel_shift
				if(EAST)
					hanging_object.pixel_x = pixel_shift
				if(WEST)
					hanging_object.pixel_x = -pixel_shift
		transfer_fingerprints_to(hanging_object)
		hanging_object.bolt(user)
		qdel(src)
	else
		balloon_alert(user, "you can only mount it while in your lair!")

/// Blood mirror, allows bloodsuckers to remotely observe their vassals. Vassals being observed gain red eyes.
/// Lots of code from regular mirrors has been copied over here for obvious reasons.
/obj/structure/bloodsucker/mirror
	name = "scarlet mirror"
	desc = "It bleeds with visions of a world rendered in red."
	icon = 'monkestation/icons/bloodsuckers/vamp_obj.dmi'
	base_icon_state = "blood_mirror"
	icon_state = "blood_mirror"
	movement_type = FLOATING
	density = FALSE
	anchored = TRUE
	integrity_failure = 0.5
	max_integrity = 200
	vamp_desc = "This is a blood mirror, it will allow you to see through the eyes of your vassals remotely (though it will cause said eyes to redden as a side effect.) \n\
		It is warded against usage by unvassalized mortals with teleportation magic that can rend psyches asunder at the cost of its own integrity."
	vassal_desc = "This is a magical blood mirror that Bloodsuckers may use to watch over their devotees.\n\
		Those unworthy of the mirror who haven't been sworn to the service of a Bloodsucker may anger it if they attempt to use it."
	hunter_desc = "This is a mirror cursed with blood, it allows vampires to spy upon their thralls. \n\
		 An incredibly shy mirror spirit has also been bound to it, so try not to look into it directly lest you wish to face a phantasmal panic response."
	light_system = OVERLAY_LIGHT //It glows a bit when in use.
	light_outer_range = 2
	light_power = 1.5
	light_color = LIGHT_COLOR_BLOOD_MAGIC
	light_on = FALSE

	/// Boolean indicating whether or not the mirror is actively being used to observe someone.
	var/in_use = FALSE
	/// The mob currently using the mirror to observe someone (if any.)
	var/mob/living/carbon/human/current_user = null
	/// The mob currently being observed by someone using the mirror (if any.)
	var/mob/living/carbon/human/current_observed = null
	/// The typepath of the action used to stop observing someone with the mirror.
	var/datum/action/innate/mirror_observe_stop/stop_observe = /datum/action/innate/mirror_observe_stop
	/// The original left eye color of the mob being observed.
	var/original_eye_color_left
	/// The original right eye color of the mob being observed.
	var/original_eye_color_right
	/// Boolean indicating whether or not the mirror is angry (see 'proc/katabasis' for more info.)
	var/mirror_will_not_forget_this = FALSE

/obj/structure/bloodsucker/mirror/Initialize(mapload)
	. = ..()
	var/static/list/reflection_filter = alpha_mask_filter(icon = icon('monkestation/icons/bloodsuckers/vamp_obj.dmi', "blood_mirror_mask"))
	var/static/matrix/reflection_matrix = matrix(0.75, 0, 0, 0, 0.75, 0)
	var/datum/callback/can_reflect = CALLBACK(src, PROC_REF(can_reflect))
	var/list/update_signals = list(COMSIG_ATOM_BREAK)

	AddComponent(/datum/component/reflection, reflection_filter = reflection_filter, reflection_matrix = reflection_matrix, can_reflect = can_reflect, update_signals = update_signals)
	stop_observe = new stop_observe(src)

/obj/structure/bloodsucker/mirror/Destroy(force)
	STOP_PROCESSING(SSobj, src)
	if(in_use)
		stop_observing(current_user, current_observed)
	QDEL_NULL(stop_observe)
	return ..()

/obj/structure/bloodsucker/mirror/examine(mob/user)
	. = ..()
	if(in_use)
		. += span_cultbold("It's glowing ominously as [current_user] stares into it!")

/// Default 'click_alt()' interaction overriden since mirrors are a unique case.
/obj/structure/bloodsucker/mirror/click_alt(mob/user)
	if(user == owner && user.Adjacent(src))
		if(broken)
			balloon_alert(user, "clear up [src]?")
		else
			balloon_alert(user, "unsecure [src]?")
		var/static/list/unclaim_options = list(
			"Yes" = image(icon = 'icons/hud/radial.dmi', icon_state = "radial_yes"),
			"No" = image(icon = 'icons/hud/radial.dmi', icon_state = "radial_no"),
		)
		var/unclaim_response = show_radial_menu(user, src, unclaim_options, radius = 36, require_near = TRUE)
		switch(unclaim_response)
			if("Yes")
				if(broken) //Clear up broken mirrors by "gibbing" them.
					new /obj/effect/gibspawner/generic(src.loc)
					qdel(src)
				else
					new /obj/item/wallframe/blood_mirror(src.loc)
					playsound(src.loc, 'sound/machines/click.ogg', 75, TRUE)
					user.visible_message(span_notice("[user.name] removes [src] from the wall."),
					span_notice("You remove [src] from the wall."),
					span_hear("You hear clicking."))
					qdel(src)

/obj/structure/bloodsucker/mirror/update_desc(updates)
	if(broken)
		desc = "It's a suspended pool of darkened fragments resembling a scab."
	else
		desc = src::desc
	return ..()

/obj/structure/bloodsucker/mirror/update_icon_state()
	if(broken)
		icon_state = "[base_icon_state]_broken"
	else if(in_use)
		icon_state = "[base_icon_state]_active"
	else
		icon_state = base_icon_state
	return ..()

/// Copied from 'mirror/proc/can_reflect()'
/obj/structure/bloodsucker/mirror/proc/can_reflect(atom/movable/target)
	if(atom_integrity <= integrity_failure * max_integrity)
		return FALSE
	if(broken || !isliving(target) || HAS_TRAIT(target, TRAIT_NO_MIRROR_REFLECTION))
		return FALSE
	return TRUE

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/bloodsucker/mirror, 28)

/obj/structure/bloodsucker/mirror/Initialize(mapload)
	. = ..()
	find_and_hang_on_wall()
	bolt()

/obj/structure/bloodsucker/mirror/broken
	icon_state = "blood_mirror_broken"

/obj/structure/bloodsucker/mirror/broken/Initialize(mapload)
	. = ..()
	atom_break(null, mapload)

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/bloodsucker/mirror/broken, 28)

/obj/structure/bloodsucker/mirror/atom_break(damage_flag, mapload)
	. = ..()
	if(broken)
		return
	src.visible_message(span_warning("Blood spews out of the mirror as it breaks!"))
	if(!owner && !mapload) //If we don't have an owner then just clear ourself up completely.
		new /obj/effect/gibspawner/generic(loc)
		qdel(src)
		return //This return might not be necessary since we've already qdel'd the mirror... idk
	if(!mapload)
		playsound(src, SFX_SHATTER, 70, TRUE)
		playsound(src, 'sound/effects/blob/blobattack.ogg', 60, TRUE)
	new /obj/effect/decal/cleanable/blood/splatter(loc)
	broken = TRUE
	update_appearance()

/**
 * Proc used by blood mirrors to allow a user to see from the perspective of a target.
 *
 * Made using 'dullahan.dm', '_machinery.dm', 'camera_advanced.dm', 'drug_effects.dm', and a lot of
 * other files as references.
 */
/obj/structure/bloodsucker/mirror/proc/begin_observing(mob/living/carbon/human/user, mob/living/carbon/human/observed)
	if(!observed)
		balloon_alert(user, "chosen vassal doesn't exist!")
		return
	var/obj/item/organ/internal/eyes/observed_eyes = observed.get_organ_slot(ORGAN_SLOT_EYES)
	var/datum/antagonist/bloodsucker/bloodsuckerdatum = user.mind.has_antag_datum(/datum/antagonist/bloodsucker)

	stop_observe.Grant(user)
	START_PROCESSING(SSobj, src)
	user.add_client_colour(/datum/client_colour/glass_colour/red)
	set_light_on(TRUE)

	if(observed_eyes)
		user.reset_perspective(observed, TRUE)
		original_eye_color_left = observed.eye_color_left
		original_eye_color_right = observed.eye_color_right
		observed.eye_color_left = BLOODCULT_EYE
		observed.eye_color_right = BLOODCULT_EYE
		observed.update_body()
	else
		balloon_alert(user, "targeted vassal has no eyes!")
		return

	in_use = TRUE
	update_appearance()
	playsound(src, 'sound/effects/portal/portal_travel.ogg', 25, frequency = 0.75, use_reverb = TRUE)
	current_user = user
	current_observed = observed
	bloodsuckerdatum.blood_structure_in_use = src

/// Proc used by blood mirrors to stop observing. Arguments default to 'current_user' and 'current_observed'
/obj/structure/bloodsucker/mirror/proc/stop_observing(mob/living/carbon/human/user = current_user, mob/living/carbon/human/observed = current_observed)
	var/datum/antagonist/bloodsucker/bloodsuckerdatum = user.mind.has_antag_datum(/datum/antagonist/bloodsucker)

	user.reset_perspective()
	stop_observe.Remove(user)
	STOP_PROCESSING(SSobj, src)
	user.remove_client_colour(/datum/client_colour/glass_colour/red)
	set_light_on(FALSE)

	observed.eye_color_left = original_eye_color_left
	observed.eye_color_right = original_eye_color_right
	observed.update_body()

	in_use = FALSE
	update_appearance()
	playsound(user, 'sound/effects/portal/portal_travel.ogg', 25, frequency = -0.75, use_reverb = TRUE)
	current_user = null
	current_observed = null
	bloodsuckerdatum.blood_structure_in_use = null

/obj/structure/bloodsucker/mirror/process(seconds_per_tick)
	if(isdead(current_user))
		balloon_alert(current_user, "you are dead!")
		stop_observing()
		return

	if(isdead(current_observed))
		balloon_alert(current_user, "[current_observed] is dead!")
		stop_observing()
		return

	if(!current_observed.get_organ_slot(ORGAN_SLOT_EYES))
		balloon_alert(current_user, "[current_observed] has lost [current_observed.p_their()] eyes!")
		stop_observing()
		return

	if(broken)
		balloon_alert(current_user, "[src] has broken!")
		stop_observing()
		return

	if(!in_range(src, current_user))
		current_user.balloon_alert(current_user, "you have moved too far from [src]!")
		stop_observing()
		return

	if(!current_user.mind.has_antag_datum(/datum/antagonist/bloodsucker)) //Unlikely, but still...
		balloon_alert(current_user, "you aren't a bloodsucker anymore!")
		stop_observing()
		return

/obj/structure/bloodsucker/mirror/attack_hand(mob/living/carbon/human/user)
	. = ..()
	if(broken)
		balloon_alert(user, "it's broken and unusable!")
		return

	if(IS_BLOODSUCKER(user))
		var/datum/antagonist/bloodsucker/user_bloodsucker_datum = user.mind.has_antag_datum(/datum/antagonist/bloodsucker, FALSE)

		if(!length(user_bloodsucker_datum.vassals))
			balloon_alert(user, "you have no vassals to observe!")
			return
		if(in_use)
			balloon_alert(user, "mirror already in use!")
			return
		if(user_bloodsucker_datum.blood_structure_in_use)
			balloon_alert(user, "can't use two mirrors at the same time!")
			return


		var/vassal_name_list[0]
		for(var/datum/antagonist/vassal/vassal_datum as anything in user_bloodsucker_datum.vassals)
			vassal_name_list[vassal_datum.owner.name] = vassal_datum
		var/chosen = tgui_input_list(user, "Select a vassal to watch over...", "Vassal Observation List", vassal_name_list)

		if(chosen)
			var/datum/antagonist/vassal/chosen_datum = vassal_name_list[chosen]
			var/mob/chosen_datum_current = chosen_datum.owner.current
			if(isdead(chosen_datum_current))
				balloon_alert(user, "[chosen_datum_current.name] is dead!")
				return

			begin_observing(user, chosen_datum_current)
			return
		else
			balloon_alert(user, "no vassal selected!")
			return

	if(IS_VASSAL(user))
		balloon_alert(user, "you don't know how to use it!")
		return

	if(IS_MONSTERHUNTER(user))
		// They might be able to escape it by going to Wonderland...
		to_chat(user, span_userdanger("MOVE— MAYBE WONDERLAND— NOW!"))
		user.balloon_alert(user, "MOVE— MAYBE WONDERLAND— NOW!")

	if(mirror_will_not_forget_this)
		katabasis(user, TRUE)
		return

	to_chat(user, span_warning("You peer deeply into [src], but the reflection you see is not your own. You are stunned as <b>it begins reaching towards you...</b>"))

	var/mob/living/carbon/human/victim = user //(Just for code readability purposes.)
	var/original_victim_loc = victim.loc
	victim.Stun(6 SECONDS, TRUE)
	victim.playsound_local(get_turf(victim), 'sound/music/antag/bloodcult/ghost_whisper.ogg', 20, frequency = 5)
	flash_color(victim, flash_time = 8 SECONDS) //Defaults to cult stun flash, which fits here.
	sleep(5 SECONDS)//Wait five seconds and then...

	if(broken)		//...return if the mirror is broken...
		return
	if(QDELETED(src))		//...return if the mirror has been completely destroyed...
		return
	if(victim.loc != original_victim_loc) //...return and become angry if the victim has been moved...
		visible_message(span_warning("A dark red silhouette appears in [src], but as it bangs against the glass in vain."))
		mirror_will_not_forget_this = TRUE
		playsound(src, 'sound/effects/glass/glasshit.ogg')
		return

	katabasis(victim) //...make the victim undergo katabasis otherwise.

/**
 * The mirror is trapped, and this proc represents the trap's effects.
 * In short, it will deal moderate damage to its victim, teleport them to a random location on the station,
 * give them a deep-rooted fear of blood, give them a severe negative moodlet, and then shatter itself.
 *
 * 'var/aggressive' increases mirror damage if true.
 */
/obj/structure/bloodsucker/mirror/proc/katabasis(mob/living/carbon/human/victim, var/aggressive = FALSE)
	//Damage
	if((victim.maxHealth - victim.get_total_damage()) >= victim.crit_threshold)
		var/refined_damage_amount = (victim.maxHealth - victim.get_total_damage()) * (aggressive ? 0.45 : 0.35)
		victim.adjustBruteLoss(refined_damage_amount)

	//Break mirror
	atom_break()

	//Flavor
	var/turf/victim_turf = get_turf(victim)
	playsound(victim_turf, 'sound/effects/hallucinations/veryfar_noise.ogg', 100, frequency = 1.25, use_reverb = TRUE)
	victim.visible_message(
		span_danger("A red hand erupts from [src], dragging [victim.name] away through broken glass!"),
		span_bolddanger(span_big("A crimson palm envelops your face, and with a horrible jolt it pulls you into [src]!")),
		span_warning("You briefly hear the sound of glass breaking accompanied by an eerie, almost fluid gust and a sudden thump!"),
	)

	//Find a reasonable/safe area and teleport the victim to it
	var/turf/target_turf = get_safe_random_station_turf(typesof(/area/station/commons)) || get_safe_random_station_turf(typesof(/area/station/hallway)) || get_safe_random_station_turf_equal_weight()
	do_teleport(victim, target_turf, no_effects = TRUE, channel = TELEPORT_CHANNEL_FREE)

	//Nightmare, trauma, and mood event
	victim.Sleeping(6 SECONDS)
	sleep(6 SECONDS)

	victim.Sleeping(5 SECONDS)
	to_chat(victim, span_warning("...you were dragged through an infinite expanse of carmine..."))
	sleep(5 SECONDS)

	victim.Sleeping(5 SECONDS)
	to_chat(victim, span_warning("...within it all things were stagnant— clotting to no end..."))
	sleep(5 SECONDS)

	victim.Sleeping(5 SECONDS)
	to_chat(victim, span_warning("...this place was where those of ages old once claimed their vitality..."))
	sleep(5 SECONDS)

	victim.Sleeping(5 SECONDS)
	to_chat(victim, span_boldwarning("...and soon, you're sure, those claims will be renewed."))
	victim.playsound_local(get_turf(victim), 'sound/effects/blob/blobattack.ogg', 60, frequency = -1)
	victim.gain_trauma(/datum/brain_trauma/mild/phobia/blood, TRAUMA_RESILIENCE_LOBOTOMY)
	victim.add_mood_event("blood_mirror", /datum/mood_event/bloodmirror)

/// The action button that allows players to stop using blood mirrors.
/datum/action/innate/mirror_observe_stop
	name = "Stop Overseeing"
	button_icon = 'icons/mob/actions/actions_spells.dmi'
	button_icon_state = "blind"

/datum/action/innate/mirror_observe_stop/Activate()
	var/datum/antagonist/bloodsucker/bloodsuckerdatum = owner.mind.has_antag_datum(/datum/antagonist/bloodsucker)
	var/obj/structure/bloodsucker/mirror/our_mirror = bloodsuckerdatum?.blood_structure_in_use
	if(istype(our_mirror))
		our_mirror.stop_observing(our_mirror.current_user, our_mirror.current_observed)
