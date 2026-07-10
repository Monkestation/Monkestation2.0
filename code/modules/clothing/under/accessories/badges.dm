// Badges, pins, and other very small items that slot onto a shirt.
/obj/item/clothing/accessory/clown_enjoyer_pin
	name = "\improper Clown Pin"
	desc = "A pin to show off your appreciation for clowns and clowning!"
	icon_state = "clown_enjoyer_pin"

/obj/item/clothing/accessory/clown_enjoyer_pin/can_attach_accessory(obj/item/clothing/under/attach_to, mob/living/user)
	. = ..()
	if(!.)
		return
	if(locate(/obj/item/clothing/accessory/mime_fan_pin) in attach_to.attached_accessories)
		if(user)
			attach_to.balloon_alert(user, "can't pick both sides!")
		return FALSE
	return TRUE

/obj/item/clothing/accessory/clown_enjoyer_pin/accessory_equipped(obj/item/clothing/under/clothes, mob/living/user)
	if(HAS_TRAIT(user, TRAIT_CLOWN_ENJOYER))
		user.add_mood_event("clown_enjoyer_pin", /datum/mood_event/clown_enjoyer_pin)
	if(ishuman(user))
		var/mob/living/carbon/human/human_equipper = user
		human_equipper.fan_hud_set_fandom()

/obj/item/clothing/accessory/clown_enjoyer_pin/accessory_dropped(obj/item/clothing/under/clothes, mob/living/user)
	user.clear_mood_event("clown_enjoyer_pin")
	if(ishuman(user))
		var/mob/living/carbon/human/human_equipper = user
		human_equipper.fan_hud_set_fandom()

/obj/item/clothing/accessory/mime_fan_pin
	name = "\improper Mime Pin"
	desc = "A pin to show off your appreciation for mimes and miming!"
	icon_state = "mime_fan_pin"

/obj/item/clothing/accessory/mime_fan_pin/can_attach_accessory(obj/item/clothing/under/attach_to, mob/living/user)
	. = ..()
	if(!.)
		return
	if(locate(/obj/item/clothing/accessory/clown_enjoyer_pin) in attach_to.attached_accessories)
		if(user)
			attach_to.balloon_alert(user, "can't pick both sides!")
		return FALSE
	return TRUE

/obj/item/clothing/accessory/mime_fan_pin/accessory_equipped(obj/item/clothing/under/clothes, mob/living/user)
	if(HAS_TRAIT(user, TRAIT_MIME_FAN))
		user.add_mood_event("mime_fan_pin", /datum/mood_event/mime_fan_pin)
	if(ishuman(user))
		var/mob/living/carbon/human/human_equipper = user
		human_equipper.fan_hud_set_fandom()

/obj/item/clothing/accessory/mime_fan_pin/accessory_dropped(obj/item/clothing/under/clothes, mob/living/user)
	user.clear_mood_event("mime_fan_pin")
	if(ishuman(user))
		var/mob/living/carbon/human/human_equipper = user
		human_equipper.fan_hud_set_fandom()

/obj/item/clothing/accessory/pocketprotector
	name = "pocket protector"
	desc = "Can protect your clothing from ink stains, but you'll look like a nerd if you're using one."
	icon_state = "pocketprotector"

/obj/item/clothing/accessory/pocketprotector/Initialize(mapload)
	. = ..()
	create_storage(storage_type = /datum/storage/pockets/pocketprotector)

/obj/item/clothing/accessory/pocketprotector/can_attach_accessory(obj/item/clothing/under/attach_to, mob/living/user)
	. = ..()
	if(!.)
		return

	if(!isnull(attach_to.atom_storage))
		if(user)
			attach_to.balloon_alert(user, "not compatible!")
		return FALSE
	return TRUE

/obj/item/clothing/accessory/pocketprotector/full

/obj/item/clothing/accessory/pocketprotector/full/Initialize(mapload)
	. = ..()
	new /obj/item/pen/red(src)
	new /obj/item/pen(src)
	new /obj/item/pen/blue(src)

/obj/item/clothing/accessory/pocketprotector/cosmetology

/obj/item/clothing/accessory/pocketprotector/cosmetology/Initialize(mapload)
	. = ..()
	for(var/i in 1 to 3)
		new /obj/item/lipstick/random(src)

/obj/item/clothing/accessory/dogtag
	name = "Dogtag"
	desc = "Can't wear a collar, but this is fine?"
	icon_state = "allergy"
	attachment_slot = NONE // actually NECK but that doesn't make sense
	/// What message is displayed when our dogtags / its clothes / its wearer is examined
	var/display = "Nothing!"

/obj/item/clothing/accessory/dogtag/examine(mob/user)
	. = ..()
	. += display

// Examining the clothes will display the examine message of the dogtag
/obj/item/clothing/accessory/dogtag/attach(obj/item/clothing/under/attach_to, mob/living/attacher)
	. = ..()
	if(!.)
		return
	RegisterSignal(attach_to, COMSIG_ATOM_EXAMINE, PROC_REF(on_examine))

/obj/item/clothing/accessory/dogtag/detach(obj/item/clothing/under/detach_from)
	. = ..()
	UnregisterSignal(detach_from, COMSIG_ATOM_EXAMINE)

// Double examining the person wearing the clothes will display the examine message of the dogtag
/obj/item/clothing/accessory/dogtag/accessory_equipped(obj/item/clothing/under/clothes, mob/living/user)
	RegisterSignal(user, COMSIG_ATOM_EXAMINE_MORE, PROC_REF(on_examine))

/obj/item/clothing/accessory/dogtag/accessory_dropped(obj/item/clothing/under/clothes, mob/living/user)
	UnregisterSignal(user, COMSIG_ATOM_EXAMINE_MORE)

/// Adds the examine message to the clothes and mob.
/obj/item/clothing/accessory/dogtag/proc/on_examine(datum/source, mob/user, list/examine_list)
	SIGNAL_HANDLER

	// Only show the examine message if we're close (2 tiles)
	if(!IN_GIVEN_RANGE(get_turf(user), get_turf(src), 2))
		return

	if(ismob(source))
		// Examining a mob wearing the clothes, wearing the dogtag will also show the message
		examine_list += "A dogtag is hanging around [source.p_their()] neck: [display]"
	else
		examine_list += "A dogtag is attached to [source]: [display]"

/obj/item/clothing/accessory/dogtag/allergy
	name = "Allergy dogtag"
	desc = "A dogtag with a listing of allergies."

/obj/item/clothing/accessory/dogtag/allergy/Initialize(mapload, allergy_string)
	. = ..()
	if(allergy_string)
		display = span_notice("The dogtag has a listing of allergies: [allergy_string]")
	else
		display = span_notice("The dogtag is all scratched up.")

/obj/item/clothing/accessory/dogtag/borg_ready
	name = "Pre-Approved Cyborg Cantidate dogtag"
	display = "This employee has been screened for negative mental traits to an acceptable level of accuracy, and is approved for the NT Cyborg program as an alternative to medical resuscitation."

/// Reskins for the pride pin accessory, mapped by display name to icon state
GLOBAL_LIST_INIT(pride_pin_reskins, list(
	"Rainbow Pride" = "pride",
	"Bisexual Pride" = "pride_bi",
	"Pansexual Pride" = "pride_pan",
	"Asexual Pride" = "pride_ace",
	"Non-binary Pride" = "pride_enby",
	"Transgender Pride" = "pride_trans",
	"Intersex Pride" = "pride_intersex",
	"Lesbian Pride" = "pride_lesbian",
	"Gay Pride" = "pride_mlm",
	"Genderfluid Pride" = "pride_genderfluid",
	"Genderqueer Pride" = "pride_genderqueer",
	"Aromantic Pride" = "pride_aromantic",
))

/obj/item/clothing/accessory/pride
	name = "pride pin"
	desc = "A Nanotrasen Diversity & Inclusion Center-sponsored holographic pin to show off your pride, reminding the crew of their unwavering commitment to equity, diversity, and inclusion!"
	icon_state = "pride"
	item_flags = UNIQUE_RENAME | INFINITE_RESKIN

/obj/item/clothing/accessory/pride/Initialize(mapload)
	unique_reskin = GLOB.pride_pin_reskins
	. = ..()

/obj/item/clothing/accessory/pride/setup_reskinning()
	if(!check_setup_reskinning())
		return

	// We already register context regardless in Initialize.
	RegisterSignal(src, COMSIG_CLICK_ALT, PROC_REF(on_click_alt_reskin))

/obj/item/clothing/accessory/pride/post_reskin()
	for(var/pride_name in GLOB.pride_pin_reskins)
		if(GLOB.pride_pin_reskins[pride_name] == icon_state)
			name = "[LOWER_TEXT(pride_name)] pin"
			return

	name = initial(name) // If we somehow fail to find our pride in the global list, just make us generic

///Awarded for being dutiful and extinguishing the debt from the "Indebted" quirk.
/obj/item/clothing/accessory/debt_payer_pin
	name = "debt payer pin"
	desc = "I've paid my debt and all I've got was this pin."
	icon_state = "debt_payer_pin"

/obj/item/clothing/accessory/deaf_pin
	name = "deaf personnel pin"
	desc = "Indicates that the wearer is deaf."
	icon_state = "deaf_pin"

/obj/item/clothing/accessory/press_badge
	name = "press badge"
	desc = "A blue press badge that clearly identifies the wearer as a member of the media. While it signifies press affiliation, it does not grant any special privileges or rights no matter how much the wearer yells about it."
	desc_controls = "Click person with it to show them it"
	icon_state = "press_badge"
	attachment_slot = NONE // actually NECK but that doesn't make sense
	/// The name of the person in the badge
	var/journalist_name
	/// The name of the press person is working for
	var/press_name

/obj/item/clothing/accessory/press_badge/examine(mob/user)
	. = ..()
	if(!journalist_name || !press_name)
		. += span_notice("Use it in hand to input information")
		return

	. += span_notice("It belongs to <b>[journalist_name]</b>, <b>[press_name]</b>")

/obj/item/clothing/accessory/press_badge/attack_self(mob/user, modifiers)
	. = ..()
	if(!journalist_name)
		journalist_name = tgui_input_text(user, "What is your name?", "Journalist Name", "[user.name]", MAX_NAME_LEN)
	if(!press_name)
		press_name = tgui_input_text(user, "For what organization you work?", "Press Name", "Nanotrasen", MAX_CHARTER_LEN)

/obj/item/clothing/accessory/press_badge/interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	if(!isliving(interacting_with))
		return NONE

	var/mob/living/interacting_living = interacting_with
	if(user.istate & ISTATE_HARM)
		playsound(interacting_living, 'sound/weapons/throw.ogg', 30)
		examine(interacting_living)
		to_chat(interacting_living, span_userdanger("[user] shoves [src] up your face!"))
		user.visible_message(span_warning("[user] have shoved [src] into [interacting_living] face."))
	else
		playsound(interacting_living, 'sound/weapons/throwsoft.ogg', 20)
		examine(interacting_living)
		to_chat(interacting_living, span_boldwarning("[user] shows [src] to you."))
		user.visible_message(span_notice("[user] shows [src] to [interacting_living]."))
	return ITEM_INTERACT_SUCCESS

/obj/item/clothing/accessory/scryer_accessory
	name = "\improper MODlink scryer accessory"
	desc = "A MODlink Scryer that someone modified to attach to their clothes."
	icon = 'icons/obj/clothing/neck.dmi'
	worn_icon = 'icons/mob/clothing/neck.dmi'
	icon_state = "modlink"
	inhand_icon_state = "" //self deletes if removed from clothing
	attachment_slot = CHEST

	var/obj/item/clothing/neck/link_scryer/scryer // The scryer that this accessory is imitating.

/obj/item/clothing/accessory/scryer_accessory/Initialize(mapload, obj/item/clothing/neck/link_scryer/attaching)
	. = ..()
	if(!isliving(src.loc) || QDELETED(attaching))
		return INITIALIZE_HINT_QDEL
	var/mob/living/scryer_mob = src.loc
	if(!scryer_mob.transferItemToLoc(attaching, src))
		scryer_mob.put_in_hands(attaching)
		return INITIALIZE_HINT_QDEL
	scryer = attaching
	if(!scryer_mob.put_in_hands(src))
		scryer_mob.put_in_hands(attaching)
		return INITIALIZE_HINT_QDEL
	scryer.slot_flags = ITEM_SLOT_ICLOTHING
	scryer.mod_link.get_user_callback = CALLBACK(scryer, TYPE_PROC_REF(/obj/item/clothing/neck/link_scryer, get_accessory_user))
	scryer.mod_link.can_call_callback = CALLBACK(scryer, TYPE_PROC_REF(/obj/item/clothing/neck/link_scryer, can_accessory_call))

/obj/item/clothing/accessory/scryer_accessory/detach(obj/item/clothing/under/detach_from, popped)
	. = ..()
	if(QDELETED(src))
		return .
	if(QDELETED(scryer))
		qdel(src)
		return .
	if(popped && isliving(detach_from.loc))
		var/mob/living/remover = detach_from.loc
		remover.put_in_hands(scryer)
	else
		scryer.forceMove(detach_from.drop_location())
	scryer.slot_flags = ITEM_SLOT_NECK
	scryer.mod_link.get_user_callback = CALLBACK(scryer, TYPE_PROC_REF(/obj/item/clothing/neck/link_scryer, get_user))
	scryer.mod_link.can_call_callback = CALLBACK(scryer, TYPE_PROC_REF(/obj/item/clothing/neck/link_scryer, can_call))
	scryer =  null
	qdel(src)

/obj/item/clothing/accessory/scryer_accessory/Destroy()
	if(istype(scryer))	// For some reason this was deleted before scryer removed, Assume it was destroyed.
		QDEL_NULL(scryer)
	return ..()

// Examining the person wearing the clothes will display the examine message to strip.
/obj/item/clothing/accessory/scryer_accessory/accessory_equipped(obj/item/clothing/under/clothes, mob/living/user)
	. = ..()
	if(istype(scryer))
		RegisterSignal(user, COMSIG_ATOM_EXAMINE, PROC_REF(on_examine))
		scryer.equipped(user, user.get_slot_by_item(clothes))

/obj/item/clothing/accessory/scryer_accessory/accessory_dropped(obj/item/clothing/under/clothes, mob/living/user)
	. = ..()
	if(istype(scryer))
		UnregisterSignal(user, COMSIG_ATOM_EXAMINE)
		scryer.dropped(user)

/obj/item/clothing/accessory/scryer_accessory/proc/on_examine(datum/source, mob/user, list/examine_list)
	SIGNAL_HANDLER

	if(istype(source, /mob/living/carbon/human) && istype(src.loc, /obj/item/clothing/under))
		var/mob/living/carbon/human/holder = source
		var/obj/item/clothing/under/uniform = src.loc
		if(holder.w_uniform == uniform && user != holder && user.CanReach(holder, view_only = TRUE))
			examine_list += "[get_examine_icon(user)] <a href='byond://?src=[REF(src)];strip_scryer=1;clothing=[REF(uniform)];holder=[REF(source)]'>[src.get_examine_name(user)] (Click to strip)</a>"

/obj/item/clothing/accessory/scryer_accessory/Topic(href, list/href_list)
	. = ..()
	if(href_list["strip_scryer"])
		if(!iscarbon(usr) || !usr.can_perform_action(locate(href_list["holder"]), NEED_DEXTERITY | NEED_HANDS | FORBID_TELEKINESIS_REACH | ALLOW_RESTING))
			return
		INVOKE_ASYNC(src, PROC_REF(remove_scryer), usr, locate(href_list["holder"]), locate(href_list["clothing"]))

/obj/item/clothing/accessory/scryer_accessory/proc/remove_scryer(mob/living/carbon/remover, mob/living/carbon/human/wearer, obj/item/clothing/under/uniform)
	if(QDELETED(src) || QDELETED(remover) || QDELETED(wearer) || QDELETED(uniform))
		return
	if(DOING_INTERACTION_WITH_TARGET(remover, wearer) || (wearer.w_uniform != uniform) || src.loc != uniform)
		return
	if(!remover.can_perform_action(wearer, NEED_DEXTERITY | NEED_HANDS | FORBID_TELEKINESIS_REACH | ALLOW_RESTING))
		return
	if(!remover.CanReach(wearer))
		return
	remover.visible_message(
		span_warning("[remover] begins removing [src] from [wearer]."),
		span_notice("You start removing [src] from [wearer]."))
	if(!do_after(remover, uniform.strip_delay, wearer) || (wearer.w_uniform != uniform) || src.loc != uniform)
		return
	uniform.remove_accessory(src)

///Actual "Badge" badges.
/obj/item/clothing/accessory/badge
	name = "badge"
	desc = "A worn badge, how cool of you."
	icon = 'icons/obj/clothing/accessories.dmi'
	worn_icon = 'icons/mob/clothing/accessories.dmi'
	icon_state = "badge"
	slot_flags = ITEM_SLOT_NECK
	attachment_slot = NONE //can be worn while rolled down

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
		RegisterSignal(user, COMSIG_MOB_RETRIEVE_ACCESS, PROC_REF(retrieve_access))

/obj/item/clothing/accessory/badge/cargo/dropped(mob/living/user)
	UnregisterSignal(user, COMSIG_MOB_RETRIEVE_ACCESS)
	return ..()

/obj/item/clothing/accessory/badge/cargo/proc/retrieve_access(datum/source, list/player_access)
	SIGNAL_HANDLER
	player_access += access

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
	var/datum/weakref/to_copy_ref

/obj/item/clothing/accessory/badge/lawyer/Initialize(mapload)
	. = ..()
	var/mob/living/person_wearing_us = recursive_loc_check(src, /mob/living)
	if(person_wearing_us)
		to_copy_ref = WEAKREF(person_wearing_us)

/obj/item/clothing/accessory/badge/lawyer/Destroy(force)
	to_copy_ref = null
	return ..()

/obj/item/clothing/accessory/badge/lawyer/examine(mob/user)
	if(isnull(to_copy_ref))
		return ..()
	var/mob/living/badge_owner = to_copy_ref?.resolve()
	if(badge_owner)
		set_identity(badge_owner)
	to_copy_ref = null
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
