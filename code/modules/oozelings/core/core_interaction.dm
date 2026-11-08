/obj/item/organ/internal/brain/slime/examine()
	. = ..()
	if(gps_active)
		. += span_notice("A dim light lowly pulsates from the center of the core, indicating an outgoing signal from a tracking microchip.")
		. += span_red("You could probably use the core in-hand to snuff out the tracking signal and retrieve the items within it.")
	else
		. += span_red("You could probably use the core in-hand to retrieve the items within it.")
	if(mind?.dnr || (locate(/datum/quirk/dnr) in stored_quirks))
		. += span_warning("It looks dull and faded, as if the soul within the core had moved on...")
	else if((brainmob && (brainmob.client || brainmob.get_ghost())) || (mind?.current && (mind.current.client || mind.current.get_ghost())) || decoy_override)
		if(isnull(stored_dna))
			. += span_hypnophrase("Something looks wrong with this core, you don't think plasma will fix this one, maybe there's another way?")
		else
			. += span_hypnophrase("You remember that <i>slowly</i> pouring a big beaker of ground plasma on it by hand, if it's non-embodied, would make it regrow one.")
	. += span_notice("<i>You can take a closer look to see what may be inside...</i>")

/obj/item/organ/internal/brain/slime/examine_more(mob/user)
	. = ..()
	. += span_notice("You look closer through the core's hazy interior and see...")
	if(length(stored_items))
		for(var/atom/movable/item as anything in stored_items)
			. += " [item.get_examine_icon(user)] <a href='byond://?src=[REF(src)];core_item=[REF(item)]'>[item.get_examine_name(user)]</a>"
		. += span_notice("floating inside...")
	else
		. += span_notice("...nothing of interest.")

/obj/item/organ/internal/brain/slime/attack_self(mob/living/user) // Allows a player (presumably an antag) to deactivate the GPS signal on a slime core
	if(DOING_INTERACTION_WITH_TARGET(user, src))
		return
	user.visible_message(
		span_warning("[user] begins jamming [user.p_their()] hand into [src]! Slime goes everywhere!"),
		gps_active ? span_notice("You jam your hand into [src], feeling for the densest point! Slime covers your arm.") : span_notice("You jam your hand into [src], feeling for any dense objects. Slime covers your arm."),
		span_notice("You hear an obscene squelching sound.")
	)
	playsound(user, 'sound/items/handling/surgery/organ1.ogg', 80, TRUE)

	if(!do_after(user, 30 SECONDS, src))
		user.visible_message(
			span_warning("[user]'s hand slips out of [src] before [user.p_they()] can cause any harm!"),
			gps_active ? span_notice("Your hand slips out of the goopy core before you can find it's densest point.") : span_notice("Your hand slips out of the goopy core before you can find any dense points."),
			span_notice("You hear a resounding plop.")
		)
		return

	if(gps_active)
		user.visible_message(
			span_warning("[user] crunches something deep in [src]! It gradually stops glowing."),
			span_notice("You find the densest point, crushing it in your palm. The blinking light in the core slowly dissipates and items start to come out."),
			span_notice("You hear a wet crunching sound."),
		)
		gps_active = FALSE
		qdel(GetComponent(/datum/component/gps/no_bsa))//Actually remove the gps signal
	else
		user.visible_message(
			span_warning("[user] crunches something deep in [src]! It gradually stops glowing."),
			span_notice("You find several dense objects, forcing them out of the core, items start to spill."),
			span_notice("You hear a wet squelching sounds.")
		)
	playsound(user, 'sound/effects/wounds/crackandbleed.ogg', 80, TRUE)
	drop_items_to_ground(user.drop_location())

/obj/item/organ/internal/brain/slime/item_interaction(mob/living/user, obj/item/stake/stake, list/modifiers)
	if(!istype(stake))
		return NONE
	if(DOING_INTERACTION_WITH_TARGET(user, src))
		return ITEM_INTERACT_BLOCKING
	playsound(user, 'sound/effects/magic/demon_consume.ogg', vol = 50, vary = TRUE)
	user.balloon_alert_to_viewers("staking core...")
	if(!do_after(user, stake.staketime, src) || QDELETED(src) || QDELETED(stake))
		return ITEM_INTERACT_BLOCKING
	user.balloon_alert_to_viewers("staked core!")
	var/datum/antagonist/bloodsucker/bloodsucker_datum = IS_BLOODSUCKER(src)
	if(bloodsucker_datum)
		playsound(get_turf(src), 'sound/effects/tendril_destroyed.ogg', vol = 40, vary = TRUE)
		user.visible_message(
			span_danger("[user] drives \the [stake] into [src], causing it to rapidly dissolve. A hollow cry wails from the rapidly melting core."),
			span_danger("You drive \the [stake] into [src], causing it to rapidly dissolve. A hollow cry wails from the rapidly melting core."),
			span_hear("You hear a wet, crackling sound."),
		)
		to_chat(brainmob, span_userdanger("Your soul escapes your melting core as the abyss welcomes you to your Final Death."))
		drop_items_to_ground(drop_location())
		bloodsucker_datum.final_death(skip_destruction = TRUE)
		qdel(src)
	else
		playsound(get_turf(src), 'sound/effects/wounds/crackandbleed.ogg', vol = 80, vary = TRUE)
		user.visible_message(
			span_danger("[user] drives \the [stake] into [src], making a loud crunching sound!"),
			span_danger("You drive \the [stake] into [src], making a loud crunching sound!"),
			span_hear("You hear a loud crunching sound."),
		)
		set_organ_damage(maxHealth) // you're stabbing it with a stake.
	return ITEM_INTERACT_SUCCESS

/obj/item/organ/internal/brain/slime/proc/colorize()
	if(!isoozeling(owner))
		return
	var/datum/color_palette/generic_colors/located = owner.dna.color_palettes[/datum/color_palette/generic_colors]
	var/new_core_color = located.return_color(MUTANT_COLOR)
	if(new_core_color)
		core_color = new_core_color
		add_atom_colour(core_color, FIXED_COLOUR_PRIORITY)

/obj/item/organ/internal/brain/slime/Topic(href, list/href_list)
	. = ..()
	if(href_list["core_item"])
		if(!core_ejected || !iscarbon(usr) || !usr.can_perform_action(src, NEED_DEXTERITY | NEED_HANDS | FORBID_TELEKINESIS_REACH | ALLOW_RESTING))
			return
		var/obj/item/core_item = locate(href_list["core_item"]) in stored_items
		if(core_item)
			drop_items(usr, list(core_item))
