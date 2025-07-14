/// Interaction key for the do_after for forcing the ears onto some poor sap.
#define DOAFTER_SOURCE_FORCE_KITTY_EARS "doafter_source_force_kitty_ears"
/// How much health super kitties have by default.
#define SUPER_KITTY_HEALTH 50
/// How much health syndicate super kitties have by default.
#define SYNDIE_SUPER_KITTY_HEALTH 80

/obj/item/organ/internal/ears/cat/super
	name = "Super Kitty Ears"
	desc = "A pair of kitty ears that harvest the true energy of cats. Mrow!"
	icon_state = "superkitty"
	item_flags = parent_type::item_flags | NOBLUDGEON
	decay_factor = 0 // Space ruin item
	damage_multiplier = 0.5 // SUPER
	organ_flags = ORGAN_HIDDEN
	organ_traits = list(TRAIT_CAT)
	/// The instance of kitty form spell given to the user.
	/// The spell will be initialized using the initial typepath.
	var/datum/action/cooldown/spell/shapeshift/kitty/kitty_spell = /datum/action/cooldown/spell/shapeshift/kitty

/obj/item/organ/internal/ears/cat/super/Initialize(mapload)
	if(ispath(kitty_spell))
		kitty_spell = new kitty_spell(src)
	else
		stack_trace("kitty_spell is invalid typepath ([kitty_spell || "null"])")
	return ..()

/obj/item/organ/internal/ears/cat/super/Destroy()
	QDEL_NULL(kitty_spell)
	return ..()

/obj/item/organ/internal/ears/cat/super/examine(mob/user)
	. = ..()
	. += span_info("They can be forced onto someone's head after 8 seconds uninterrupted.")

/obj/item/organ/internal/ears/cat/super/attack(mob/target_mob, mob/living/carbon/user, obj/target)
	if(DOING_INTERACTION(user, DOAFTER_SOURCE_FORCE_KITTY_EARS))
		return
	. = ..()
	if(.)
		return TRUE
	if(!iscarbon(target_mob))
		to_chat(user, span_warning("\The [src] cannot be implanted into [target_mob]!"))
		return
	if(target_mob == user)
		implant_on_use(user)
	else
		force_implant(user, target_mob)

/obj/item/organ/internal/ears/cat/super/attack_self(mob/user, modifiers)
	if(DOING_INTERACTION(user, DOAFTER_SOURCE_FORCE_KITTY_EARS))
		return
	implant_on_use(user)
	return ..()

/obj/item/organ/internal/ears/cat/super/on_insert(mob/living/carbon/ear_owner)
	. = ..()
	kitty_spell.Grant(ear_owner)

/obj/item/organ/internal/ears/cat/super/on_remove(mob/living/carbon/ear_owner, special = FALSE)
	. = ..()
	kitty_spell.Remove(ear_owner)

// Stole this from demon heart hard, but hey it works
/obj/item/organ/internal/ears/cat/super/proc/implant_on_use(mob/living/carbon/user)
	if(!iscarbon(user) || !isnull(owner) || !user.is_holding(src))
		return FALSE
	user.visible_message(
		span_warning("[user] raises \the [src] to [user.p_their()] head and it melts into [user.p_their()] head!"),
		span_danger("A strange [span_kbity("feline")] comes over you as you place \the [src] on your head!"),
	)
	to_chat(user, span_kbity(span_slightly_larger("Everything is so much louder!")))
	playsound(get_turf(user), 'sound/effects/meow1.ogg', vol = 50, vary = TRUE)

	user.temporarilyRemoveItemFromInventory(src, force = TRUE)
	Insert(user)
	return TRUE

/obj/item/organ/internal/ears/cat/super/proc/force_implant(mob/living/carbon/user, mob/living/carbon/victim)
	if(!iscarbon(user) || !isnull(owner) || !user.is_holding(src))
		return FALSE
	user.visible_message(
		span_warning("[user] begins to force \the [src] onto [victim]'s head!"),
		span_notice("You begin to force \the [src] onto [victim]'s head."),
		ignored_mobs = list(victim),
	)
	to_chat(victim, span_userdanger("[user] begins to force \the [src] onto your head, a strange <s>[span_kbity("feline")]</s> feeling creeping into you as it slowly begins to meld into you!"))

	user.log_message("is trying to forcefully implant [name] into [key_name(victim)].", LOG_ATTACK, color = "red")
	victim.log_message("is being forcefully implanted with [name] by [key_name(user)].", LOG_VICTIM, color = "orange", log_globally = FALSE)
	if(do_after(user, 8 SECONDS, victim, extra_checks = CALLBACK(src, PROC_REF(do_after_checks), user), interaction_key = DOAFTER_SOURCE_FORCE_KITTY_EARS))
		playsound(get_turf(victim), 'sound/effects/meow1.ogg', vol = 50, vary = TRUE)
		user.visible_message(
			span_warning("[user] forces \the [src] onto [victim]'s head, and they melt into place!"),
			span_notice("You force \the [src] onto [victim]'s head, and they melt into place!"),
			ignored_mobs = list(victim),
		)
		to_chat(victim, span_userdanger("A strange [span_kbity("feline")] comes over you as [user] forces \the [src] onto your head!"))
		to_chat(victim, span_kbity(span_slightly_larger("Everything is so much louder!")))
		user.temporarilyRemoveItemFromInventory(src, force = TRUE)
		Insert(victim)
		user.log_message("has forcefully implanted [name] into [key_name(victim)].", LOG_ATTACK, color = "red")
		victim.log_message("has been forcefully implanted with [name] by [key_name(user)].", LOG_VICTIM, color = "orange", log_globally = FALSE)
	return TRUE

/obj/item/organ/internal/ears/cat/super/proc/do_after_checks(mob/living/user, mob/living/target)
	return !QDELETED(src) && isnull(owner) && user.is_holding(src)

/datum/action/cooldown/spell/shapeshift/kitty
	name = "KITTY POWER!!"
	desc = "Take on the shape of a kitty cat! Gain their powers at a loss of vitality."

	cooldown_time = 20 SECONDS
	invocation = "MRR MRRRW!!"
	invocation_type = INVOCATION_SHOUT
	spell_requirements = SPELL_CASTABLE_WITHOUT_INVOCATION

	possible_shapes = list(
		/mob/living/simple_animal/pet/cat/super,
		/mob/living/simple_animal/pet/cat/breadcat/super,
		/mob/living/simple_animal/pet/cat/original/super,
	)
	keep_name = TRUE

/mob/living/simple_animal/pet/cat/super
	maxHealth = SUPER_KITTY_HEALTH
	health = SUPER_KITTY_HEALTH
	speed = 0
	gold_core_spawnable = NO_SPAWN

/mob/living/simple_animal/pet/cat/breadcat/super
	maxHealth = SUPER_KITTY_HEALTH
	health = SUPER_KITTY_HEALTH
	speed = 0
	gold_core_spawnable = NO_SPAWN

/mob/living/simple_animal/pet/cat/original/super
	maxHealth = SUPER_KITTY_HEALTH
	health = SUPER_KITTY_HEALTH
	speed = 0
	gold_core_spawnable = NO_SPAWN

/obj/item/organ/internal/ears/cat/super/syndie
	kitty_spell = /datum/action/cooldown/spell/shapeshift/kitty/syndie

/datum/action/cooldown/spell/shapeshift/kitty/syndie
	name = "SYNDICATE KITTY POWER!!"
	desc = "Take on the shape of an kitty cat, clad in blood-red armor! Gain their powers at a loss of vitality."
	check_flags = AB_CHECK_INCAPACITATED|AB_CHECK_HANDS_BLOCKED|AB_CHECK_IMMOBILE|AB_CHECK_CONSCIOUS
	possible_shapes = list(/mob/living/simple_animal/hostile/syndicat/super)

/mob/living/simple_animal/hostile/syndicat/super
	maxHealth = SYNDIE_SUPER_KITTY_HEALTH
	health = SYNDIE_SUPER_KITTY_HEALTH
	speed = 0
	// it's clad in blood-red armor
	damage_coeff = list(BRUTE = 0.8, BURN = 0.9, TOX = 0, CLONE = 0, STAMINA = 0, OXY = 0)
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_plas" = 0, "max_plas" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	bodytemp_cold_damage_limit = -1
	bodytemp_heat_damage_limit = INFINITY
	unsuitable_atmos_damage = 0

/mob/living/simple_animal/hostile/syndicat/super/Initialize(mapload)
	. = ..()
	// get rid of the microbomb normal syndie cats have
	for(var/obj/item/implant/explosive/implant_to_remove in implants)
		qdel(implant_to_remove)

#undef SYNDIE_SUPER_KITTY_HEALTH
#undef SUPER_KITTY_HEALTH
#undef DOAFTER_SOURCE_FORCE_KITTY_EARS
