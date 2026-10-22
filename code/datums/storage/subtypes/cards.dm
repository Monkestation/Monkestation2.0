/**
 *A storage component to be used on card piles, for use as hands/decks/discard piles. Don't use on something that's not a card pile!
 */
/datum/storage/tcg
	max_specific_storage = WEIGHT_CLASS_TINY
	max_slots = 30
	max_total_storage = WEIGHT_CLASS_TINY * 30

/datum/storage/tcg/New()
	. = ..()
	set_holdable(list(/obj/item/tcgcard))

/datum/storage/tcg/attempt_remove(obj/item/thing, atom/newLoc, silent = FALSE, visual_updates = TRUE)
	. = ..()
	handle_empty_deck()

/datum/storage/tcg/show_contents(mob/to_show)
	. = ..()
	to_show.visible_message(span_notice("[to_show] starts to look through the contents of \the [real_location]!"), \
					span_notice("You begin looking into the contents of \the [real_location]!"))

/datum/storage/tcg/hide_contents()
	. = ..()
	real_location.visible_message(span_notice("\the [parent] is shuffled after looking through it."))
	real_location.contents = shuffle(real_location.contents)

/datum/storage/tcg/dump_content_at(atom/dest_object, mob/user)
	. = ..()

	if(!real_location.contents.len)
		qdel(real_location)

/datum/storage/tcg/proc/handle_empty_deck()
	//You can't have a deck of one card!
	if(real_location.contents.len == 1)
		var/obj/item/tcgcard_deck/deck = real_location
		var/obj/item/tcgcard/card = real_location.contents[1]
		attempt_remove(card, card.drop_location())
		card.flipped = deck.flipped
		card.update_icon_state()
		qdel(parent)
