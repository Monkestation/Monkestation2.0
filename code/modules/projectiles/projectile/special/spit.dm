/obj/projectile/ink_spit
	name = "ink spit"
	icon_state = "ink_spit"
	damage = 5
	damage_type = STAMINA
	armor_flag = BIO
	impact_effect_type = /obj/effect/temp_visual/impact_effect/ink_spit
	armour_penetration = 50
	hitsound = SFX_DESECRATION
	hitsound_wall = SFX_DESECRATION

/obj/projectile/ink_spit/Initialize(mapload)
	. = ..()
	if(isliving(firer))
		var/mob/living/living = firer
		var/datum/status_effect/organ_set_bonus/fish/bonus = living?.has_status_effect(/datum/status_effect/organ_set_bonus/fish)
		if(bonus?.bonus_active)
			damage = 12
			armour_penetration = 65


/obj/projectile/ink_spit/on_hit(atom/target, blocked = 0, pierce_hit)
	. = ..()
	if(!isliving(target))
		return
	var/mob/living/victim = target
	blind_em(victim, !iscarbon(victim) || victim.get_bodypart(BODY_ZONE_HEAD))

///Blinds and confuses the victim, stronger (and knocks down) if the firer has the fish organ set bonus active
/obj/projectile/ink_spit/proc/blind_em(mob/living/victim, can_splat_on)
	if(!can_splat_on)
		return
	var/powered_up = FALSE
	if(isliving(firer))
		var/mob/living/living = firer
		var/datum/status_effect/organ_set_bonus/fish/bonus = living?.has_status_effect(/datum/status_effect/organ_set_bonus/fish)
		powered_up = bonus?.bonus_active
	victim.adjust_temp_blindness_up_to((powered_up ? 6.5 : 4.5) SECONDS, 10 SECONDS)
	victim.adjust_confusion_up_to((powered_up ? 3 : 1.5) SECONDS, 6 SECONDS)
	if(powered_up)
		victim.Knockdown(2 SECONDS) //splat!
