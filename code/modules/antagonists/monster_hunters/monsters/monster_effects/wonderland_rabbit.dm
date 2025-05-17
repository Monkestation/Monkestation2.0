// not a subtype of /mob/living/basic/rabbit as those have several elements we don't want to inherit
/mob/living/basic/wonderland_rabbit
	name = /mob/living/basic/rabbit::name
	desc = /mob/living/basic/rabbit::desc
	icon = 'monkestation/icons/mob/rabbit.dmi'
	icon_state = "white_rabbit"
	icon_living = "white_rabbit"
	dir = EAST // so it's consistent with the animation
	density = FALSE
	health = 75
	maxHealth = 75
	gender = PLURAL
	mob_biotypes = MOB_ORGANIC | MOB_BEAST
	basic_mob_flags = DEL_ON_DEATH
	gold_core_spawnable = NONE
	faction = list(FACTION_RABBITS)
	sentience_type = SENTIENCE_BOSS
	unsuitable_atmos_damage = 0
	unsuitable_cold_damage = 0
	unsuitable_heat_damage = 0
	/// Innate traits paradox rabbits have.
	/// Remember, these are not normal rabbits by any means,
	/// they are fantastical entities that don't exactly follow the same laws of reality.
	var/static/list/innate_traits = list(
		TRAIT_ANTIMAGIC,
		TRAIT_NO_MINDSWAP,
		TRAIT_NO_RANDOM_SENTIENCE,
		TRAIT_SHOCKIMMUNE,
	)

/mob/living/basic/wonderland_rabbit/Initialize(mapload)
	add_traits(innate_traits, INNATE_TRAIT)
	return ..()

/mob/living/basic/wonderland_rabbit/death(gibbed)
	var/obj/effect/wonderland_rabbit_exit/exit = new(loc)
	exit.setDir(dir)
	return ..()

/mob/living/basic/wonderland_rabbit/examine(mob/user)
	. = ..()
	if(!isliving(user) || IS_MONSTERHUNTER(user) || (FACTION_RABBITS in user.faction))
		return
	//var/mob/living/living_user = user
	if(is_monster_hunter_prey(user) || IS_CULTIST(user) || IS_CLOCK(user) || IS_WIZARD(user))
		. += span_warning("You feel sick as you look into its eyes...")

/obj/effect/wonderland_rabbit_enter
	name = "rabbit?"
	icon = 'monkestation/icons/mob/rabbit.dmi'
	icon_state = "rabbit_enter"

/obj/effect/wonderland_rabbit_enter/Initialize(mapload)
	. = ..()
	addtimer(CALLBACK(src, PROC_REF(finish_animation)), 4 SECONDS)

/obj/effect/wonderland_rabbit_enter/proc/finish_animation()
	new /mob/living/basic/wonderland_rabbit(loc)
	qdel(src)

/obj/effect/wonderland_rabbit_exit
	name = "rabbit"
	icon = 'monkestation/icons/mob/rabbit.dmi'
	icon_state = "rabbit_hole"

/obj/effect/wonderland_rabbit_exit/Initialize(mapload)
	. = ..()
	QDEL_IN(src, 8 SECONDS)
