/obj/machinery/wish_granter
	name = "wish granter"
	desc = "You're not so sure about this, anymore..."
	icon = 'icons/obj/device.dmi'
	icon_state = "syndbeacon"

	use_power = NO_POWER_USE
	density = TRUE

	var/charges = 1
	var/insisting = 0

/obj/machinery/wish_granter/attack_hand(mob/living/carbon/user, list/modifiers)
	. = ..()
	if(.)
		return
	if(charges <= 0)
		to_chat(user, span_boldnotice("The Wish Granter lies silent."))
		return

	else if(!ishuman(user))
		to_chat(user, span_boldnotice("You feel a dark stirring inside of the Wish Granter, something you want nothing of. Your instincts are better than any man's."))
		return

	else if(is_special_character(user))
		to_chat(user, span_boldnotice("Even to a heart as dark as yours, you know nothing good will come of this. Something instinctual makes you pull away."))

	else if (!insisting)
		to_chat(user, span_boldnotice("Your first touch makes the Wish Granter stir, listening to you. Are you really sure you want to do this?"))
		insisting++

	else
		to_chat(user, span_boldnotice("You speak. [pick("I want the station to disappear","Humanity is corrupt, mankind must be destroyed","I want to be rich", "I want to rule the world","I want immortality.")]. The Wish Granter answers."))

		charges--
		insisting = 0

		user.mind.add_antag_datum(/datum/antagonist/wishgranter)
		message_admins("[ADMIN_LOOKUPFLW(user)] has become the Wishgranter Avatar!")
		deadchat_broadcast(span_bold(" has become the Wishgranter Avatar!"), span_name("[user.real_name]"), follow_target = user, message_type = DEADCHAT_ANNOUNCEMENT)

		to_chat(user, span_warning("You have a very bad feeling about this."))
		for(var/mob/player as anything in GLOB.player_list - user)
			if(QDELETED(player) || isnewplayer(player) || issilicon(player))
				continue
			to_chat(player, span_userdanger("An ominous wave of pressure fills the air around you, as if a chaotic malignant blaze had ignited elsewhere."))
			player.playsound_local(player, 'sound/ambience/antag/wishgranter_awaken.ogg', vol = 75, vary = FALSE, pressure_affected = FALSE)
			if(isliving(player))
				var/mob/living/living_player = player
				living_player.add_mood_event("wishgranter_awakening", /datum/mood_event/wishgranter_awakening)
