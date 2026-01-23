/**
 *	# Archives of the Kindred:
 *
 *	A book that can only be used by Curators and Monster Hnters.
 *	When used on a player, after a short timer, will reveal if the player is a Vampire, including their real name and Clan.
 *	This book should not work on Vampires using the Masquerade ability.
 *	If it reveals a Vampire, the Curator will then be able to tell they are a Vampire on examine (Like a vassal).
 *	Reading it normally will allow Curators to read what each Clan does, with some extra flavor text ones.
 *
 *	Regular Vampires won't have any negative effects from the book, while everyone else will get burns/eye damage.
 */
/obj/item/book/kindred
	name = "\improper Archive of the Kindred"
	desc = "Cryptic documents explaining hidden truths behind Undead beings. It is said only Curators can decipher what they really mean."
	icon = 'icons/vampires/vamp_obj.dmi'
	lefthand_file = 'icons/vampires/bs_leftinhand.dmi'
	righthand_file = 'icons/vampires/bs_rightinhand.dmi'
	icon_state = "kindred_book"
	starting_title = "the Archive of the Kindred"
	starting_author = "dozens of generations of Curators"
	unique = TRUE
	cannot_carve = TRUE
	throw_speed = 1
	throw_range = 10
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | ACID_PROOF

/obj/item/book/kindred/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/stationloving)

///Attacking someone with the book.
/obj/item/book/kindred/interact_with_atom(mob/target, mob/living/user, list/modifiers)
	if(!ismob(target) || user == target || !user.can_read(src))
		return NONE
	if(DOING_INTERACTION(user, DOAFTER_SOURCE_ARCHIVE_OF_THE_KINDRED))
		return ITEM_INTERACT_BLOCKING
	if(!IS_VAMPIRE_HUNTER(user))
		if(!IS_VAMPIRE(user))
			to_chat(user, span_warning("[src] burns your hands as you try to use it!"))
			user.apply_damage(3, BURN, pick(BODY_ZONE_L_ARM, BODY_ZONE_R_ARM))
		else
			to_chat(user, span_notice("[src] seems to be too complicated for you. It would be best to leave this for someone else to take."))
		return ITEM_INTERACT_BLOCKING

	to_chat(user, span_notice("You begin carefully examining [target] while consulting [src]..."))
	user.visible_message(span_notice("[user] looks at [target] while reading [src]."), ignored_mobs = list(user))
	if(!do_after(user, 3 SECONDS, target, interaction_key = DOAFTER_SOURCE_ARCHIVE_OF_THE_KINDRED))
		to_chat(user, span_notice("You quickly close [src]."))
		return ITEM_INTERACT_SUCCESS

	var/datum/antagonist/vampire/vampiredatum = IS_VAMPIRE(target)
	// Are we a Vampire | Are we on Masquerade. If one is true, they will fail.
	if(vampiredatum && !HAS_TRAIT(target, TRAIT_MASQUERADE))
		if(vampiredatum.broke_masquerade)
			to_chat(user, span_warning("[target], also known as '[vampiredatum.return_full_name()]', is indeed a Vampire, but you already knew this."))
			return ITEM_INTERACT_SUCCESS
		to_chat(user, span_warning("[target], also known as '[vampiredatum.return_full_name()]', [vampiredatum.my_clan ? "is part of the [vampiredatum.my_clan]!" : "is not part of a clan."] You quickly note this information down, memorizing it."))
		vampiredatum.break_masquerade()
	else
		to_chat(user, span_notice("You fail to draw any conclusions to [target] being a Vampire."))
	return ITEM_INTERACT_SUCCESS

/obj/item/book/kindred/ranged_interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	return interact_with_atom(interacting_with, user, modifiers)

/obj/item/book/kindred/attack_self(mob/living/user)
	if(!IS_VAMPIRE_HUNTER(user))
		if(IS_VAMPIRE(user))
			to_chat(user, span_notice("[src] seems to be too complicated for you. It would be best to leave this for someone else to take."))
		else
			to_chat(user, span_warning("You feel your eyes unable to read the boring texts..."))
		return
	ui_interact(user)

/obj/item/book/kindred/ui_interact(mob/living/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "KindredBook", name)
		ui.set_autoupdate(FALSE)
		ui.open()

/obj/item/book/kindred/ui_static_data(mob/user)
	var/data = list()

	for(var/datum/vampire_clan/clan as anything in subtypesof(/datum/vampire_clan))
		data["clans"] += list(list(
			"clan_name" = clan::name,
			"clan_desc" = clan::description,
		))

	return data
