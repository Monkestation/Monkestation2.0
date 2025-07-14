/datum/martial_art/slasher_grab //martial art that exists so slasher can aggro grab like a real evil dude
	name = "Slasher Grabbing"
	id = MARTIALART_SLASHER_GRAB
	COOLDOWN_DECLARE(grabby_cd)

/datum/martial_art/slasher_grab/grab_act(mob/living/attacker, mob/living/defender)
	return big_grab(attacker, defender, TRUE)

/datum/martial_art/slasher_grab/proc/big_grab(mob/living/attacker, mob/living/defender, grab_attack)
	if(COOLDOWN_FINISHED(src, grabby_cd))
		if(attacker.grab_state >= GRAB_AGGRESSIVE)
			defender.grabbedby(attacker, 1)
		else
			attacker.start_pulling(defender, supress_message = TRUE)
			if(attacker.pulling)
				attacker.balloon_alert(attacker, "You grab them aggressively by the neck!")
				defender.balloon_alert(defender, "You are grabbed aggressively by the neck!")
				defender.stop_pulling()
				COOLDOWN_START(src, grabby_cd, 15 SECONDS)
				if(grab_attack)
					log_combat(attacker, defender, "grabbed", addition="aggressively")
					defender.visible_message(span_warning("[attacker] violently grabs [defender]!"), \
									span_userdanger("You're violently grabbed by [attacker]!"), span_hear("You hear sounds of aggressive fondling!"), null, attacker)
					to_chat(attacker, span_danger("You violently grab [defender]!"))
					attacker.setGrabState(GRAB_AGGRESSIVE) //Instant aggressive grab
				else
					log_combat(attacker, defender, "grabbed", addition="passively")
					attacker.setGrabState(GRAB_PASSIVE)
