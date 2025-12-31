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
	///The REAL name of the person who imprinted their details onto the badge.
	var/stored_name
	///The job title the badge holds.
	var/badge_string

/obj/item/clothing/accessory/badge/add_context(atom/source, list/context, obj/item/held_item, mob/user)
	. = ..()
	if(isnull(held_item))
		return .
	if(held_item == src)
		context[SCREENTIP_CONTEXT_LMB] = "Show off"
		return CONTEXTUAL_SCREENTIP_SET
	if(held_item.GetID())
		context[SCREENTIP_CONTEXT_LMB] = "Imprint Job"
		return CONTEXTUAL_SCREENTIP_SET
	if(IS_WRITING_UTENSIL(held_item))
		context[SCREENTIP_CONTEXT_LMB] = "Edit Job Title"
		return CONTEXTUAL_SCREENTIP_SET
	return .

/obj/item/clothing/accessory/badge/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	. = ..()
	if(.)
		return .

	if(tool.GetID())
		if(!allowed(user))
			user.balloon_alert(user, "no access!")
			return ITEM_INTERACT_BLOCKING
		user.balloon_alert(user, "details imprinted")
		set_identity(user)
		return ITEM_INTERACT_SUCCESS

	if(IS_WRITING_UTENSIL(tool))
		if(!allowed(user))
			user.balloon_alert(user, "no access!")
			return ITEM_INTERACT_BLOCKING
		var/new_badge_string = tgui_input_text(user, "Enter badge job title", "New job", max_length = MAX_LABEL_LEN)
		if(isnull(new_badge_string) || !istext(new_badge_string))
			return ITEM_INTERACT_BLOCKING
		badge_string = new_badge_string
		return ITEM_INTERACT_SUCCESS

	return NONE

/obj/item/clothing/accessory/badge/interact(mob/user)
	. = ..()
	user.point_at(src)
	user.balloon_alert_to_viewers("[stored_name]: [badge_string]")

/obj/item/clothing/accessory/badge/allowed(mob/accessor)
	if(isnull(stored_name) || obj_flags & EMAGGED)
		return TRUE
	return ..()

/obj/item/clothing/accessory/badge/emag_act(mob/user, obj/item/card/emag/emag_card)
	if(obj_flags & EMAGGED)
		return FALSE
	obj_flags |= EMAGGED
	balloon_alert(user, "access restriction disabled")
	return TRUE

/obj/item/clothing/accessory/badge/attack(mob/living/target, mob/living/user, params)
	if(!isliving(target))
		return
	user.visible_message(span_danger("[user] invades [target]'s personal space, thrusting [src] into their face insistently."),
		span_danger("You invade [target]'s personal space, thrusting [src] into their face insistently."))
	user.do_attack_animation(target)

///Sets the badge's identity to the name and description given to us.
/obj/item/clothing/accessory/badge/proc/set_identity(mob/living/named_mob)
	if(!ismob(named_mob))
		var/found_name = findname(named_mob)
		if(found_name)
			named_mob = found_name

	//now is this a real mob we have, or just a random name we inserted?
	if(ismob(named_mob))
		stored_name = named_mob.last_name()
	else
		stored_name = named_mob

	name = "[initial(name)] ([stored_name])"

/**
 * SUBTYPES
 * Used by:
 * - Detective
 * - Cargo
 * - Lawyer
 */
/obj/item/clothing/accessory/badge/detective
	name = "detective's badge"
	desc = "An immaculately polished silver security badge on leather."
	icon_state = "detective-silver"
	access_required = ACCESS_DETECTIVE
	badge_string = JOB_DETECTIVE

/obj/item/clothing/accessory/badge/detective/set_identity(mob/living/named_mob)
	. = ..()
	desc = initial(desc) + " Labeled '[badge_string]'."

/obj/item/clothing/accessory/badge/detective/gold
	name = "detective's badge"
	desc = "An immaculately polished gold security badge on leather."
	icon_state = "detective-gold"

/obj/item/clothing/accessory/badge/cargo
	name = "union badge"
	desc = "A badge designating the user as part of the 'Cargo Workers Union', employee level."
	icon_state = "cargo-silver"
	badge_string = "Union Employee"
	var/list/access = list(
		ACCESS_UNION,
	)

/obj/item/clothing/accessory/badge/cargo/equipped(mob/living/user, slot)
	. = ..()
	if(slot & (ITEM_SLOT_ICLOTHING|ITEM_SLOT_HANDS)) //ITEM_SLOT_NECK inv doesn't call dropped so we don't need to re-register.
		RegisterSignal(user, COMSIG_MOB_TRIED_ACCESS, PROC_REF(on_tried_access))

/obj/item/clothing/accessory/badge/cargo/dropped(mob/living/user)
	UnregisterSignal(user, COMSIG_MOB_TRIED_ACCESS)
	return ..()

/obj/item/clothing/accessory/badge/cargo/proc/on_tried_access(datum/source, obj/locked_thing)
	SIGNAL_HANDLER
	return locked_thing?.check_access(src) ? ACCESS_ALLOWED : NONE

/obj/item/clothing/accessory/badge/cargo/GetAccess()
	return access

/obj/item/clothing/accessory/badge/cargo/quartermaster
	name = "union president badge"
	desc = "A badge designating the user as part of the 'Cargo Workers Union', presidential level."
	icon_state = "cargo-gold"
	badge_string = "Union President"
	access = list(
		ACCESS_UNION,
		ACCESS_UNION_LEADER,
	)

/obj/item/clothing/accessory/badge/lawyer
	name = "attorney's badge"
	desc = "Fills you with the conviction of JUSTICE. Lawyers tend to want to show it to everyone they meet."
	icon = 'icons/obj/clothing/accessories.dmi'
	worn_icon = 'icons/mob/clothing/accessories.dmi'
	icon_state = "lawyerbadge"
	access_required = ACCESS_LAWYER
	badge_string = "Attorney-At-Law"

	///The mob we're gonna copy over when we get first examined. This is like the `virgin` var of filingcabinets,
	///this is necessary beacuse we don't know quirks/holy role/traits on initialize.
	var/mob/living/to_copy

/obj/item/clothing/accessory/badge/lawyer/Initialize(mapload)
	. = ..()
	to_copy = recursive_loc_check(src, /mob/living)

/obj/item/clothing/accessory/badge/lawyer/Destroy(force)
	to_copy = null
	return ..()

/obj/item/clothing/accessory/badge/lawyer/examine(mob/user)
	if(isnull(to_copy))
		return ..()
	if(!QDELETED(to_copy))
		set_identity(to_copy)
	to_copy = null
	return ..()

/obj/item/clothing/accessory/badge/lawyer/set_identity(mob/living/named_mob)
	. = ..()
	desc = initial(desc)
	if(named_mob.mind?.holy_role)
		desc  += " It is backed by the Apostolic Penitentiary."
	else if(isipc(named_mob))
		desc  += " It is not backed by any bar, but endorsed by an [span_red("LLM-based megacorporation")]."
	else if(named_mob.has_quirk(/datum/quirk/fluffy_tongue))
		desc  += " It is backed by the [span_red("Committee for Prosecutorial Excellence")]."
	else if(HAS_TRAIT(named_mob, TRAIT_CLOWN_ENJOYER) || HAS_TRAIT(named_mob, TRAIT_CLUMSY))
		desc  += " It is backed by the [span_red("Clown College of Law")]."
	else if(HAS_TRAIT(named_mob, TRAIT_MIME_FAN) || HAS_TRAIT(named_mob, TRAIT_MIMING))
		desc  += " It is backed by the [span_red("Barreau de l'espace du Québec")]."
	else if(HAS_TRAIT(named_mob, TRAIT_EVIL))
		desc  += " It is not backed by [span_red("any Bar Association")]."
	else if(HAS_TRAIT(named_mob, TRAIT_HEAVY_DRINKER))
		desc  += " It is backed by the [span_red("Bar")]."
	else
		desc  += " It is backed by the [span_red("Nanotrasen Bar Association")]."

	if(astype(named_mob, /mob/living/carbon/human)?.age < AGE_MINOR)
		desc  += " It is labelled as 'Unpaid Intern'."

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
