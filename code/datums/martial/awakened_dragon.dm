/datum/martial_art/the_sleeping_carp/awakened_dragon
	name = "The Awakened Dragon"
	id = MARTIALART_AWAKENEDDRAGON
	help_verb = /mob/living/proc/awakened_dragon_help
	deflect_cooldown = 0
	deflect_stamcost = 5
	deflect_miss_probability = 0
	log_name = "Awakened Dragon"
	var/title = null //YOUR TITLE BELOW THE HEAVENS! This is the prefix you use :]
	var/list/character_prefixes
	scarp_traits = list(TRAIT_NOGUNS, TRAIT_HARDLY_WOUNDED, TRAIT_NODISMEMBER, TRAIT_LIGHT_SLEEPER, TRAIT_THROW_GUNS)

/datum/martial_art/the_sleeping_carp/awakened_dragon/prefixes/New()
	character_prefixes = list(
		"Heavenly Demon",
		"Cheonma",
		"Heavenly Dragon",
		"Greatest Before the Heavens",
		"Dragon Fist",
		"Awakened Dragon's Disciple",
	)

/datum/martial_art/the_sleeping_carp/awakened_dragon/teach(mob/living/carbon/human/target, make_temporary)
	. = ..()
	var/titled_name //name you get after you're titled
	var/real_name = target.real_name
	title = pick(character_prefixes)
	titled_name = "[title] [target.get_face_name(real_name)]"
	target.fully_replace_character_name(real_name, titled_name)

/datum/martial_art/the_sleeping_carp/awakened_dragon/strongPunch(mob/living/attacker, mob/living/defender)
	. = ..()
	damage = 30
	wounding = 15
	attacker.say("Crushing Maw!!", spans = list("yell"), ignore_spam = TRUE)


/datum/martial_art/the_sleeping_carp/awakened_dragon/launchKick(mob/living/attacker, mob/living/defender)
	. = ..()
	damage = 25
	kick_speed = 5
	wounding = 5
	zone = BODY_ZONE_HEAD
	zone_message = "head"
	attacker.say("Tsunami Kick of the Heavenly Serpent!!", spans = list("yell"), ignore_spam = TRUE)

/datum/martial_art/the_sleeping_carp/awakened_dragon/dropKick(mob/living/attacker, mob/living/defender)
	. = ..()
	stamina_damage = 50
	defender.apply_damage(30, attacker.get_attack_type(), defender.zone_selected, wound_bonus = 10, bare_wound_bonus = 5)
	attacker.say("Heavenly Dragon Kick!!", spans = list("yell"), ignore_spam = TRUE)


/mob/living/proc/awakened_dragon_help()
	set name = "Recall Teachings"
	set desc = "Remember the martial techniques of the Awakened Dragon."
	set category = "Awakened Dragon"

	to_chat(usr, "<b><i>You retreat inward and recall the teachings of the venerable Awakened Dragon...</i></b>\n\
	[span_notice("Crushing Maw")]: Punch Punch. Deal additional damage every second (consecutive) punch! Extremely good chance to wound!\n\
	[span_notice("Heavenly Serpent Tsunami Kick")]: Punch Shove. Launch your opponent away from you with incredible force! Extremely good chance to wound!\n\
	[span_notice("Heavenly Dragon Kick")]: Shove Shove. Kick an opponent to the floor, knocking them down, discombobulating them and dealing substantial stamina damage and damage. If they're already prone, disarm them as well.\n\
	[span_notice("Grabs and Shoves")]: While in combat mode, your typical grab and shove do decent stamina damage. If you grab someone who has substantial amounts of stamina damage, you knock them out!\n\
	<span class='notice'>While in combat mode (and not stunned, not a hulk, and not in a mech), you can reflect all projectiles that come your way, sending them back at the people who fired them! \n\
	Also, you are more resilient against suffering wounds in combat, and your limbs cannot be dismembered. This grants you extra staying power during extended combat, especially against slashing and other bleeding weapons. \n\
	You are not invincible, however- while you may not suffer debilitating wounds often, you must still watch your health and should have appropriate medical supplies for use during downtime. \n\
	In addition, your training has imbued you with a loathing of guns, and you can no longer use them.</span>")
