/mob/living/basic/clown
	name = "Clown"
	desc = "A denizen of clown planet."
	icon = 'icons/mob/simple/clown_mobs.dmi'
	icon_state = "clown"
	icon_living = "clown"
	icon_dead = "clown_dead"
	icon_gib = "clown_gib"
	health_doll_icon = "clown" //if >32x32, it will use this generic. for all the huge clown mobs that subtype from this
	mob_biotypes = MOB_ORGANIC|MOB_HUMANOID
	response_disarm_continuous = "gently pushes aside"
	response_disarm_simple = "gently push aside"
	response_harm_continuous = "robusts"
	response_harm_simple = "robust"
	istate = ISTATE_HARM
	maxHealth = 75
	health = 75
	melee_damage_lower = 10
	melee_damage_upper = 10
	attack_sound = 'sound/items/bikehorn.ogg'
	attacked_sound = 'sound/items/bikehorn.ogg'
	environment_smash = ENVIRONMENT_SMASH_NONE
	basic_mob_flags = DEL_ON_DEATH
	initial_language_holder = /datum/language_holder/clown
	habitable_atmos = list("min_oxy" = 5, "max_oxy" = 0, "min_plas" = 0, "max_plas" = 1, "min_co2" = 0, "max_co2" = 5, "min_n2" = 0, "max_n2" = 0)
	minimum_survivable_temperature = T0C
	maximum_survivable_temperature = (T0C + 100)
	unsuitable_atmos_damage = 10
	unsuitable_heat_damage = 15
	faction = list(FACTION_CLOWN)
	ai_controller = /datum/ai_controller/basic_controller/clown
	speed = 1.4 //roughly close to simpleanimal clowns
	///list of stuff we drop on death
	var/list/loot = list(/obj/effect/mob_spawn/corpse/human/clown)
	///blackboard emote list
	var/list/emotes = list(
		BB_EMOTE_SAY = list("HONK", "Honk!", "Welcome to clown planet!"),
		BB_EMOTE_HEAR = list("honks", "squeaks"),
		BB_EMOTE_SOUND = list('sound/items/bikehorn.ogg'), //WE LOVE TO PARTY
		BB_SPEAK_CHANCE = 5,
	)
	///do we waddle (honk)
	var/waddles = TRUE

/mob/living/basic/clown/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/footstep, footstep_type = FOOTSTEP_MOB_SHOE)
	AddComponent(/datum/component/ai_retaliate_advanced, CALLBACK(src, PROC_REF(retaliate_callback)))
	ai_controller.set_blackboard_key(BB_BASIC_MOB_SPEAK_LINES, emotes)
	//im not putting dynamic humans or whatever its called here because this is the base path of nonhuman clownstrosities
	if(waddles)
		AddElement(/datum/element/waddling)
	if(length(loot))
		loot = string_list(loot)
		AddElement(/datum/element/death_drops, loot)

/mob/living/basic/clown/proc/retaliate_callback(mob/living/attacker)
	if (!istype(attacker))
		return
	for (var/mob/living/basic/clown/harbringer in oview(src, 7))
		harbringer.ai_controller.insert_blackboard_key_lazylist(BB_BASIC_MOB_RETALIATE_LIST, attacker)

/mob/living/basic/clown/melee_attack(atom/target, list/modifiers, ignore_cooldown = FALSE)
	if(!istype(target, /obj/item/food/grown/banana/bunch))
		return ..()
	var/obj/item/food/grown/banana/bunch/unripe_bunch = target
	unripe_bunch.start_ripening()
	log_combat(src, target, "explosively ripened")
