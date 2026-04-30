/datum/round_event_control/wizard/summon_gifts
	name = "Gifts For Everyone!"
	weight = 3
	max_occurrences = 5
	earliest_start = 0 MINUTES
	typepath = /datum/round_event/wizard/summon_gifts
	description = "Gives every sentient carbon mob an xmas gift."
	min_wizard_trigger_potency = 0
	max_wizard_trigger_potency = 100

/datum/round_event/wizard/summon_gifts/start()
	for(var/mob/living/carbon/gifted_mob in GLOB.alive_player_list) //sentient monkeys get gifts too!
		gifted_mob.put_in_hands(new /obj/item/a_gift/anything/wiz_name(gifted_mob.drop_location()))
		playsound(gifted_mob, 'sound/magic/summon_guns.ogg', 50, TRUE)
		to_chat(gifted_mob, span_notice("A magical gift appears before you!"))

/obj/item/a_gift/anything/wiz_name
	name = "Mysterious Gift" //these are not chrimstmas gifts and should not be named as such
