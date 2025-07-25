/datum/martial_art/the_sleeping_carp/awakened_dragon
	name = "The Awakened Dragon"
	id = MARTIALART_AWAKENEDDRAGON
	help_verb = /mob/living/proc/awakened_dragon_help
	//deflect_cooldown = 0
	deflect_stamcost = 0
	log_name = "Awakened Dragon"
	scarp_traits = list(TRAIT_NOGUNS, TRAIT_NEVER_WOUNDED, TRAIT_NODISMEMBER, TRAIT_LIGHT_SLEEPER, TRAIT_THROW_GUNS)
	counter = TRUE
	var/title = null //YOUR TITLE BELOW THE HEAVENS! This is the prefix you use :]
	var/static/list/character_prefixes = list(
		"Heavenly Demon",
		"Cheonma", //Roughly means Heavenly Demon
		"Heavenly Dragon",
		"Greatest Before the Heavens",
		"Dragon Fist",
		"Awakened Dragon's Disciple",
		"Sunaikinti's Blessed", //rogue lineage reference, don't ask
		"Shura", //Sekiro reference
	)
	var/datum/weakref/original_body = null
	var/original_name
	var/titled_name
	var/list/datum/weakref/all_bodies = list()
	instant_grab = TRUE
	snap_grab_state = GRAB_NECK //you can kill people a little faster
	damage_sharpness = TRUE

/datum/martial_art/the_sleeping_carp/awakened_dragon/can_deflect(mob/living/carp_user, check_intent = TRUE)
	//if(!COOLDOWN_FINISHED(src, block_cooldown)) //monke edit
	//	return FALSE
	if(!can_use(carp_user))
		return FALSE
	if(check_intent && !(carp_user.istate & ISTATE_HARM)) // monke edit: istates/intents
		return FALSE
	if(carp_user.incapacitated(IGNORE_GRAB)) //NO STUN
		return FALSE
	if(!(carp_user.mobility_flags & MOBILITY_USE)) //NO UNABLE TO USE
		return FALSE
	var/datum/dna/dna = carp_user.has_dna()
	if(dna?.check_mutation(/datum/mutation/hulk)) //NO HULK
		return FALSE
	if(!isturf(carp_user.loc)) //NO MOTHERFLIPPIN MECHS!
		return FALSE
	return TRUE

/datum/martial_art/the_sleeping_carp/awakened_dragon/teach(mob/living/carbon/human/target, make_temporary)
	. = ..()
	target.physiology.stamina_mod *= 0.7
	original_name = target.real_name
	if(original_body == null)
		original_body = target
	if(title == null)
		title = pick(character_prefixes)
	all_bodies += target
	titled_name = "[title] [original_name]"
	target.fully_replace_character_name(original_name, titled_name)

/datum/martial_art/the_sleeping_carp/awakened_dragon/remove(mob/living/carbon/human/target)
	. = ..()
	target.physiology.stamina_mod /= 0.7
	target.fully_replace_character_name(titled_name, original_name)

/datum/martial_art/the_sleeping_carp/awakened_dragon/strongPunch(mob/living/attacker, mob/living/defender, set_damage)
	damage = 55
	. = ..(attacker, defender)
	attacker.say("Crushing Maw!!", forced = /datum/martial_art/the_sleeping_carp/awakened_dragon, ignore_spam = TRUE)

/datum/martial_art/the_sleeping_carp/awakened_dragon/launchKick(mob/living/attacker, mob/living/defender, set_damage)
	damage = 40
	kick_speed = 5
	zone = BODY_ZONE_HEAD
	zone_message = "head"
	. = ..(attacker, defender, set_damage = FALSE)
	attacker.say("Tsunami Kick of the Heavenly Serpent!!", forced = /datum/martial_art/the_sleeping_carp/awakened_dragon, ignore_spam = TRUE)

/datum/martial_art/the_sleeping_carp/awakened_dragon/dropKick(mob/living/attacker, mob/living/defender, set_damage)
	stamina_damage = -100
	. = ..(attacker, defender, set_damage = FALSE)
	var/def_check = defender.getarmor(defender.zone_selected, MELEE)
	defender.apply_damage(30, attacker.get_attack_type(), defender.zone_selected, wound_bonus = 10, bare_wound_bonus = 5, blocked = def_check)
	attacker.say("Heavenly Dragon Kick!!", forced = /datum/martial_art/the_sleeping_carp/awakened_dragon, ignore_spam = TRUE)

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
