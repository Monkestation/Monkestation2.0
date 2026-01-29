/obj/structure/vampire/vassalrack
	name = "vassalization rack"
	desc = "If this wasn't meant for torture, then someone has some fairly horrifying hobbies."
	icon = 'icons/vampires/vamp_obj.dmi'
	icon_state = "vassalrack"
	anchored = FALSE
	density = TRUE
	can_buckle = TRUE
	buckle_lying = 180
	ghost_desc = "This is a vassalization rack, which allows vampires to turn crew members into loyal vassals."
	vampire_desc = "This is the vassalization rack, which allows you to turn crew members into loyal vassals in your service. This costs blood to do.\n\
		Simply click and hold on a victim, and then drag their sprite onto the vassalization rack. Right-click on the vassalization rack to unbuckle them.\n\
		To convert into a vassal, repeatedly click on the vassalization rack. The time required scales with the tool in your hand."
	vassal_desc = "This is the vassalization rack, which allows your master to turn crew members into loyal vassals.\n\
		Aid your master in bringing their victims here and keeping them secure.\n\
		You can secure victims to the vassalization rack by click-dragging the victim onto the rack while it is secured."
	curator_desc = "This is the vassalization rack, which monsters use to blood-slave crew members into vassals.\n\
		They usually ensure that victims are handcuffed to prevent them from running away.\n\
		Their rituals take time, allowing us to disrupt them."

	/// How many times a buckled person has to be tortured to be converted.
	var/convert_progress = 3
	/// Mindshielded individuals and antagonists must willingly accept you as their master.
	var/wants_vassalization = FALSE
	/// Prevents popup spam.
	var/vassalization_offered = FALSE
	/// No spamming torture
	var/is_torturing = FALSE

/obj/structure/vampire/vassalrack/examine(mob/user)
	. = ..()
	var/datum/antagonist/vampire/vampiredatum = IS_VAMPIRE(user)
	if(vampiredatum)
		var/remaining_vassals = vampiredatum.get_max_vassals() - vampiredatum.count_vassals()
		if(remaining_vassals > 0)
			. += span_info("You are currently capable of creating <b>[remaining_vassals]</b> more vassal[remaining_vassals == 1 ? "" : "s"].")
		else
			. += span_warning("You cannot create any more vassals at the moment!")

/obj/structure/vampire/vassalrack/deconstruct(disassembled = TRUE)
	. = ..()
	new /obj/item/stack/sheet/iron(src.loc, 4)
	new /obj/item/stack/rods(loc, 4)
	qdel(src)

/obj/structure/vampire/vassalrack/mouse_drop_receive(atom/dropped, mob/user, params)
	if(DOING_INTERACTION(user, DOAFTER_SOURCE_PERSUASION_RACK))
		return
	var/mob/living/living_target = dropped
	if(!anchored && IS_VAMPIRE(user))
		to_chat(user, span_danger("Until this rack is secured in place, it cannot serve its purpose."))
		to_chat(user, span_announce("* Vampire Tip: Examine the vassal rack to understand how it functions!"))
		return
	// Default checks
	if(!isliving(living_target) || !living_target.Adjacent(src) || living_target == user || !isliving(user) || has_buckled_mobs() || user.incapacitated() || living_target.buckled)
		return
	// Don't buckle Silicon to it please.
	if(issilicon(living_target))
		to_chat(user, span_danger("You realize that this machine cannot be vassalized, therefore it is useless to buckle [living_target.p_them()]."))
		return
	if(do_after(user, 5 SECONDS, living_target, interaction_key = DOAFTER_SOURCE_PERSUASION_RACK))
		set_density(FALSE)
		attach_victim(living_target, user)
		set_density(TRUE)

/**
 * Attempts to buckle target into the Vassalization Rack
 */
/obj/structure/vampire/vassalrack/proc/attach_victim(mob/living/target, mob/living/user)
	if(!buckle_mob(target))
		return
	user.visible_message(
		span_notice("[user] straps [target] into the rack, immobilizing [target.p_them()]."),
		span_boldnotice("You secure [target] tightly in place. [target.p_They()] won't escape you now."))

	playsound(loc, 'sound/effects/pop_expl.ogg', vol = 25, vary = TRUE)
	update_appearance(UPDATE_ICON)

	// Set up Torture stuff now
	reset_progress()

/// Attempt Unbuckle
/obj/structure/vampire/vassalrack/user_unbuckle_mob(mob/living/buckled_mob, mob/user)
	if(HAS_MIND_TRAIT(user, TRAIT_VAMPIRE_ALIGNED))
		return ..()

	if(buckled_mob == user)
		buckled_mob.visible_message(
			span_danger("[user] tries to release [user.p_them()]self from the rack!"),
			span_danger("You attempt to release yourself from the rack!"),
			span_hear("You hear a squishy wet noise."),
		)
		if(!do_after(user, 20 SECONDS, buckled_mob))
			return FALSE
	else
		buckled_mob.visible_message(
			span_danger("[user] tries to pull [buckled_mob] from the rack!"),
			span_danger("You attempt to release [buckled_mob] from the rack!"),
			span_hear("You hear a squishy wet noise."),
		)
		if(!do_after(user, 10 SECONDS, buckled_mob))
			return FALSE

	return ..()

/obj/structure/vampire/vassalrack/post_unbuckle_mob(mob/living/unbuckled_mob)
	visible_message(span_danger("[unbuckled_mob][unbuckled_mob.stat == DEAD ? "'s corpse" : ""] slides off of the rack."))
	unbuckled_mob.Paralyze(2 SECONDS)
	update_appearance(UPDATE_ICON)
	reset_progress()

/obj/structure/vampire/vassalrack/attack_hand(mob/user, list/modifiers)
	. = ..()
	if(!. || !has_buckled_mobs() || DOING_INTERACTION(user, DOAFTER_SOURCE_PERSUASION_RACK))
		return FALSE

	var/datum/antagonist/vampire/vampiredatum = IS_VAMPIRE(user)
	var/mob/living/carbon/buckled_person = pick(buckled_mobs)

	// oh no let me free this poor soul
	if(!vampiredatum)
		user_unbuckle_mob(buckled_person, user)
		return TRUE

	var/obj/item/held_item = user.get_inactive_held_item()
	try_to_torture(user, buckled_person, held_item)

/obj/structure/vampire/vassalrack/attack_hand_secondary(mob/user, list/modifiers)
	. = ..()
	if(. == SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN)
		return
	if(!has_buckled_mobs() || !isliving(user) || DOING_INTERACTION(user, DOAFTER_SOURCE_PERSUASION_RACK))
		return
	var/mob/living/carbon/buckled_carbons = pick(buckled_mobs)
	if(buckled_carbons)
		if(user == owner.current)
			unbuckle_mob(buckled_carbons)
		else
			user_unbuckle_mob(buckled_carbons, user)

/obj/structure/vampire/vassalrack/attackby(obj/item/attacking_item, mob/living/user, params)
	if(IS_VAMPIRE(user) && has_buckled_mobs() && !(user.istate & ISTATE_HARM))
		return try_to_torture(user, pick(buckled_mobs), attacking_item)
	return ..()

/**
 * Torture steps:
 *
 * * When convert_progress reaches 0, the victim is ready to be converted
 * * Using a better tool will reduce the time required to torture
 * * If the victim has a mindshield or is an antagonist, they must accept the conversion. If they don't accept, they aren't converted
 * * vassalize target
 */
/obj/structure/vampire/vassalrack/proc/try_to_torture(mob/living/living_vampire, mob/living/living_target, obj/item/held_item)
	if(DOING_INTERACTION(living_vampire, DOAFTER_SOURCE_PERSUASION_RACK))
		return

	if(vassalization_offered)
		balloon_alert(living_vampire, "wait a moment!")
		return

	var/datum/antagonist/vampire/vampiredatum = IS_VAMPIRE(living_vampire)

	if(!vampiredatum.can_make_vassal(living_target) || is_torturing)
		return

	// These if statements can be simplified but aren't for better code-readability.
	if(convert_progress > 0)
		balloon_alert(living_vampire, "spilling blood...")

		is_torturing = TRUE
		living_target.Paralyze(1 SECONDS)
		vampiredatum.adjust_blood_volume(-TORTURE_BLOOD_HALF_COST)

		if(!do_torture(living_vampire, living_target, held_item))
			is_torturing = FALSE
			return
		is_torturing = FALSE

		vampiredatum.adjust_blood_volume(-TORTURE_BLOOD_HALF_COST)
		convert_progress--

		if(convert_progress > 0)
			balloon_alert(living_vampire, "needs more persuasion...")
			return

		// If the victim is mindshielded or an antagonist, they choose to accept or refuse vassilization.
		if(!wants_vassalization && (HAS_TRAIT(living_target, TRAIT_MINDSHIELD) || length(living_target.mind.antag_datums)))
			balloon_alert(living_vampire, "has external loyalties! more persuasion required!")
			if(!ask_for_vassalization(living_vampire, living_target))
				balloon_alert(living_vampire, "refused persuasion!")
				convert_progress++
				return

		balloon_alert(living_vampire, "ready for communion!")
		return

	if(wants_vassalization || !(HAS_TRAIT(living_target, TRAIT_MINDSHIELD) || length(living_target.mind.antag_datums)))
		living_vampire.balloon_alert_to_viewers("smears blood...", "paints bloody marks...")
		if(!do_after(living_vampire, 5 SECONDS, living_target, interaction_key = DOAFTER_SOURCE_PERSUASION_RACK))
			balloon_alert(living_vampire, "interrupted!")
			return

		// Make our target into a vassal
		vampiredatum.adjust_blood_volume(-TORTURE_CONVERSION_COST)
		if(vampiredatum.make_vassal(living_target))
			// We've made a vassal the proper way, do clan stuff
			vampiredatum.my_clan?.on_vassal_made(living_vampire, living_target)
			remove_loyalties(living_target)

/obj/structure/vampire/vassalrack/proc/do_torture(mob/living/user, mob/living/carbon/target, obj/item/held_item)
	var/torture_time = 15
	torture_time -= held_item?.force / 4
	torture_time -= held_item?.sharpness + 1

	// Minimum 5 seconds
	torture_time = max(5 SECONDS, torture_time SECONDS)
	if(do_after(user, torture_time, target, interaction_key = DOAFTER_SOURCE_PERSUASION_RACK))
		held_item?.play_tool_sound(target)

		var/obj/item/bodypart/selected_bodypart = pick(target.bodyparts)
		target.visible_message(
			span_danger("[user] performs a ritual, spilling some of [target]'s blood from [target.p_their()] [selected_bodypart.name]!"),
			span_userdanger("[user] performs a ritual, spilling some blood from your [selected_bodypart.name]!"))

		INVOKE_ASYNC(target, TYPE_PROC_REF(/mob, emote), "scream")
		target.set_jitter_if_lower(10 SECONDS)
		target.apply_damage(held_item ? held_item.force / 4 : 2, held_item ? held_item.damtype : BRUTE, selected_bodypart)
		return TRUE
	else
		balloon_alert(user, "interrupted!")
		return FALSE

/// Offer them the oppertunity to join now.
/obj/structure/vampire/vassalrack/proc/ask_for_vassalization(mob/living/user, mob/living/target)
	if(vassalization_offered)
		balloon_alert(user, "wait a moment!")
		return FALSE
	vassalization_offered = TRUE

	to_chat(user, span_notice("[target] has been given the opportunity for servitude. You await [target.p_their()] decision..."))
	var/alert_response = tgui_alert(
		user = target, \
		message = "You are being tortured! Do you want to give in and pledge your undying loyalty to [user]? \n\
			You will not lose your current objectives, but they come second to the will of your new master!", \
		title = "THE HORRIBLE PAIN! WHEN WILL IT END?!",
		buttons = list("Accept", "Refuse"),
		timeout = 15 SECONDS, \
		autofocus = TRUE
	)
	if(alert_response == "Accept")
		wants_vassalization = TRUE
	else
		target.balloon_alert_to_viewers("refused vassalization!")

	vassalization_offered = FALSE

	return wants_vassalization

/obj/structure/vampire/vassalrack/proc/reset_progress()
	convert_progress = initial(convert_progress)
	wants_vassalization = initial(wants_vassalization)
	vassalization_offered = initial(vassalization_offered)
	is_torturing = initial(is_torturing)

/obj/structure/vampire/vassalrack/proc/remove_loyalties(mob/living/target)
	// Find Mind Implant & Destroy
	for(var/obj/item/implant/implant as anything in target.implants)
		if(istype(implant, /obj/item/implant/mindshield) && implant.removed(target, silent = TRUE))
			qdel(implant)
