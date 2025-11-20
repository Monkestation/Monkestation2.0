/obj/item/clothing/accessory/pride/accessory_equipped(obj/item/clothing/under/clothes, mob/living/user)
	if(HAS_TRAIT(user, TRAIT_PRIDE_PIN))
		user.add_mood_event("pride_pin", /datum/mood_event/pride_pin)

/obj/item/clothing/accessory/pride/accessory_dropped(obj/item/clothing/under/clothes, mob/living/user)
	user.clear_mood_event("pride_pin")

///Actual "Badge" badges.
/obj/item/clothing/accessory/badge
	name = "badge"
	desc = "A worn badge, how cool of you."
	icon = 'monkestation/icons/obj/clothing/accessories.dmi'
	worn_icon = 'monkestation/icons/mob/clothing/accessories.dmi'
	icon_state = "badge"
	slot_flags = ITEM_SLOT_NECK
	attachment_slot = CHEST

	///The access needed to change the stored name, not needed if no name is given.
	var/access_required = ACCESS_CARGO
	///Boolean on whether the badge string can be edited.
	var/edit_jobs = FALSE
	///The REAL name of the person who imprinted their details onto the badge.
	var/stored_name
	///The job title the badge holds.
	var/badge_string

/obj/item/clothing/accessory/badge/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	if(!istype(tool, /obj/item/card/id))
		return NONE

	var/obj/item/card/id/id_card = tool
	if(isnull(stored_name) || (access_required && (access_required in id_card.access)) || (obj_flags & EMAGGED))
		user.balloon_alert(user, "details imprinted")
		set_identity(user.last_name(), id_card.assignment)
		return ITEM_INTERACT_SUCCESS

	user.balloon_alert(user, "no access!")
	return ITEM_INTERACT_BLOCKING

/obj/item/clothing/accessory/badge/interact(mob/user)
	. = ..()
	user.point_at(src)
	user.balloon_alert_to_viewers("[stored_name]: [badge_string]")

/obj/item/clothing/accessory/badge/attack(mob/living/target, mob/living/user, params)
	if(!isliving(target))
		return
	user.visible_message(span_danger("[user] invades [target]'s personal space, thrusting [src] into their face insistently."),
		span_danger("You invade [target]'s personal space, thrusting [src] into their face insistently."))
	user.do_attack_animation(target)

/obj/item/clothing/accessory/badge/emag_act(mob/user, obj/item/card/emag/emag_card)
	if(obj_flags & EMAGGED)
		return FALSE
	obj_flags |= EMAGGED
	balloon_alert(user, "access restriction disabled")
	return TRUE

///Sets the badge's identity to the name and description given to us.
/obj/item/clothing/accessory/badge/proc/set_identity(new_name, new_description)
	stored_name = new_name
	name = "[initial(name)] ([stored_name])"
	if(new_description && edit_jobs)
		badge_string = new_description

/**
 * SUBTYPES
 * Used by:
 * - Detective
 * - Lawyer
 * - Cargo
 */
/obj/item/clothing/accessory/badge/detective
	name = "detective's badge"
	desc = "An immaculately polished silver security badge on leather."
	icon_state = "detective-silver"
	access_required = ACCESS_DETECTIVE
	badge_string = JOB_DETECTIVE

/obj/item/clothing/accessory/badge/detective/set_identity(new_name, new_description)
	. = ..()
	desc = initial(desc) + " Labeled '[badge_string]'."

/obj/item/clothing/accessory/badge/detective/gold
	name = "detective's badge"
	desc = "An immaculately polished gold security badge on leather. Labeled 'Detective.'"
	icon_state = "detective-gold"

/obj/item/clothing/accessory/badge/cargo
	name = "union badge"
	desc = "A badge designating the user as part of the 'Cargo Workers Union', employee level."
	icon_state = "cargo-silver"
	badge_string = "Union Employee"

/obj/item/clothing/accessory/badge/quartermaster
	name = "union president badge"
	desc = "A badge designating the user as part of the 'Cargo Workers Union', presidential level."
	icon_state = "cargo-gold"
	badge_string = "Union President"

/obj/item/clothing/accessory/badge/lawyer
	name = "attorney's badge"
	desc = "Fills you with the conviction of JUSTICE. Lawyers tend to want to show it to everyone they meet."
	icon = 'icons/obj/clothing/accessories.dmi'
	worn_icon = 'icons/mob/clothing/accessories.dmi'
	icon_state = "lawyerbadge"
	access_required = ACCESS_LAWYER
	badge_string = "Attorney-At-Law"

/obj/item/clothing/accessory/badge/lawyer/interact(mob/user)
	. = ..()
	if(prob(1))
		user.say("The testimony contradicts the evidence!", forced = "[src]")

/obj/item/clothing/accessory/badge/lawyer/accessory_equipped(obj/item/clothing/under/clothes, mob/living/user)
	RegisterSignal(user, COMSIG_LIVING_SLAM_TABLE, PROC_REF(table_slam))
	user.bubble_icon = "lawyer"

/obj/item/clothing/accessory/badge/lawyer/accessory_dropped(obj/item/clothing/under/clothes, mob/living/user)
	UnregisterSignal(user, COMSIG_LIVING_SLAM_TABLE)
	user.bubble_icon = initial(user.bubble_icon)

/obj/item/clothing/accessory/badge/lawyer/proc/table_slam(mob/living/source, obj/structure/table/the_table)
	SIGNAL_HANDLER

	ASYNC
		source.say("Objection!!", spans = list(SPAN_YELL), forced = "[src]")
