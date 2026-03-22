/obj/machinery/cassette_postbox
	name = "Space Board of Music Postbox"
	desc = "Has a slit specifically to fit cassettes into it."

	icon = 'icons/obj/cassettes/radio_station.dmi'
	icon_state = "postbox"

	max_integrity = 100000 //lol
	resistance_flags = INDESTRUCTIBLE
	anchored = TRUE
	density = TRUE

/obj/machinery/cassette_postbox/Initialize(mapload)
	. = ..()
	REGISTER_REQUIRED_MAP_ITEM(1, INFINITY)

/obj/machinery/cassette_postbox/item_interaction(mob/living/user, obj/item/cassette_tape/tape, list/modifiers)
	if(!istype(tape, /obj/item/cassette_tape) || !user.client)
		return NONE

	if(tape.cassette_data.status == CASSETTE_STATUS_APPROVED)
		to_chat(user, span_notice("This tape is already approved!"))
		return ITEM_INTERACT_BLOCKING

	if(!length(tape.cassette_data?.front?.songs) && !length(tape.cassette_data?.back?.songs))
		to_chat(user, span_notice("This tape is blank!"))
		return

	var/list/admin_count = get_admin_counts(R_FUN)
	if(!length(admin_count["present"]))
		to_chat(user, span_notice("The postbox refuses your cassette, it seems the Space Board is out for lunch."))
		return ITEM_INTERACT_BLOCKING

	if(!tape.cassette_data.name)
		to_chat(user, span_notice("Please name your tape before submitting it, you can't change this later!"))
		return ITEM_INTERACT_BLOCKING

	if(!tape.cassette_data.desc)
		to_chat(user, span_notice("Please add a description to your tape before submitting it, you can't change this later!"))
		return ITEM_INTERACT_BLOCKING

	var/choice = tgui_alert(user, "Are you sure? This costs 5k Monkecoins", "Mailbox", list("Yes", "No"))
	if(choice != "Yes")
		return ITEM_INTERACT_BLOCKING

	var/secondchoice = tgui_alert(user, "Please make sure to Adminhelp and check for any available admins that can review your cassette before submitting, you will not be refunded if it is denied. If an admin does not review your cassette, and you are connected at the end of the round, you may be refunded.", "Mailbox", list("Acknowledge", "Cancel"))
	if(secondchoice != "Acknowledge")
		return ITEM_INTERACT_BLOCKING

#ifndef TESTING
	///these two parts here should be commented out for local testing without a db
	if(user.client.prefs?.metacoins < 5000)
		to_chat(user, span_notice("Sorry, you don't have enough Monkecoins to submit a cassette for review."))
		return ITEM_INTERACT_BLOCKING

	if(!user.client.prefs?.adjust_metacoins(user.client.ckey, -5000, "Submitted a mixtape", donator_multiplier = FALSE))
		return ITEM_INTERACT_BLOCKING
#endif

	submit_cassette_for_review(user, tape)
	return ITEM_INTERACT_SUCCESS
