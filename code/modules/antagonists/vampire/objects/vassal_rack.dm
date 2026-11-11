#define RACK_TEACH_COST 150

/obj/structure/vampire/vassalrack
	name = "vassalization rack"
	desc = "If this wasn't meant for brainwashing, then someone has some fairly horrifying hobbies."
	icon = 'icons/obj/antags/vampire/vamp_obj.dmi'
	icon_state = "vassalrack"
	anchored = FALSE
	density = TRUE
	can_buckle = TRUE
	buckle_lying = 180
	ghost_desc = "This is a vassalization rack. Vampires strap victims to it to hold them still, and teach their vassals some of their power here."
	vampire_desc = "This is the vassalization rack. Strap someone to it and they're held still enough for you to Share Blood with them.\n\
		Simply click and hold on a victim, and then drag their sprite onto the vassalization rack. Right-click on the vassalization rack to unbuckle them.\n\
		Strap one of your own vassals in and click the rack to teach them a lesser version of one of your disciplines. This costs blood to do."
	vassal_desc = "This is the vassalization rack, which your master uses to hold victims still while sharing blood with them.\n\
		Aid your master in bringing their victims here and keeping them secure.\n\
		Your master can also strap you in here to teach you some of their power."
	curator_desc = "This is the vassalization rack, which monsters use to hold crew members still while feeding them their blood.\n\
		They usually ensure that victims are handcuffed to prevent them from running away.\n\
		Their rituals take time, allowing us to disrupt them."

	custom_materials = list(/datum/material/iron = SHEET_MATERIAL_AMOUNT * 8)

/obj/structure/vampire/vassalrack/examine(mob/user)
	. = ..()
	var/datum/antagonist/vampire/vampiredatum = IS_VAMPIRE(user)
	if(vampiredatum)
		var/remaining_vassals = max_vampire_vassals() - vampiredatum.count_vassals()
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
	update_appearance(UPDATE_ICON)

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

	var/datum/antagonist/vassal/vassaldatum = IS_VASSAL(buckled_person)
	if(vassaldatum?.master != vampiredatum)
		balloon_alert(user, "share your blood with them!")
		return TRUE

	pick_discipline(user, vampiredatum, buckled_person)
	return TRUE

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

/obj/structure/vampire/vassalrack/proc/pick_discipline(mob/living/user, datum/antagonist/vampire/vampiredatum, mob/living/carbon/target)
	var/list/radial_display = list()
	for(var/datum/discipline/discipline as anything in vampiredatum.owned_disciplines)
		if(!discipline.vassal_power || discipline.level < 2)
			continue
		var/datum/radial_menu_choice/option = new
		option.image = image(icon = 'icons/mob/actions/actions_vampire_disciplines.dmi', icon_state = discipline.icon_state)
		option.info = "[span_boldnotice(discipline.name)]\n[span_cult(initial(discipline.vassal_power.desc))]"
		radial_display[discipline.name] = option

	if(!length(radial_display))
		balloon_alert(user, "nothing you can teach!")
		return

	var/choice = show_radial_menu(user, src, radial_display, require_near = TRUE)
	if(!choice)
		return
	for(var/datum/discipline/discipline as anything in vampiredatum.owned_disciplines)
		if(discipline.name == choice)
			teach_discipline(user, target, discipline)
			return

/// Everything after the radial pick, so it all still works with no client around.
/obj/structure/vampire/vassalrack/proc/teach_discipline(mob/living/user, mob/living/carbon/target, datum/discipline/discipline)
	var/datum/antagonist/vampire/vampiredatum = IS_VAMPIRE(user)
	var/datum/antagonist/vassal/vassaldatum = IS_VASSAL(target)
	if(!vampiredatum || vassaldatum?.master != vampiredatum || !discipline.vassal_power)
		return FALSE
	if(discipline.level < 2)
		balloon_alert(user, "you don't know [discipline.name]!")
		return FALSE
	if(vampiredatum.current_vitae < RACK_TEACH_COST)
		balloon_alert(user, "not enough blood!")
		return FALSE

	user.balloon_alert_to_viewers("smears blood...", "teaching [discipline.name]...")
	if(!do_after(user, 5 SECONDS, target, interaction_key = DOAFTER_SOURCE_PERSUASION_RACK))
		balloon_alert(user, "interrupted!")
		return FALSE
	if(!(target in buckled_mobs) || vampiredatum.current_vitae < RACK_TEACH_COST)
		return FALSE

	vampiredatum.adjust_blood_volume(-RACK_TEACH_COST)
	vassaldatum.teach_power(discipline.vassal_power)
	to_chat(target, span_cult("[user] carves the secrets of [discipline.name] into your flesh. You can now use [initial(discipline.vassal_power.name)]."))
	to_chat(user, span_notice("You teach [target] [initial(discipline.vassal_power.name)]."))
	return TRUE

#undef RACK_TEACH_COST
