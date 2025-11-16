/obj/item/gun/ballistic/revolver/hunter_revolver
	name = "\improper Hunter's Revolver"
	desc = "While doing minimal physical damage, the bullets will force a monster to carry the weight of their impure sins for a short while, greatly slowing them down."
	icon_state = "revolver"
	icon = 'monkestation/icons/obj/guns/guns.dmi'
	accepted_magazine_type = /obj/item/ammo_box/magazine/internal/cylinder/bloodsilver
	initial_caliber = CALIBER_BLOODSILVER

/datum/movespeed_modifier/silver_bullet
	multiplicative_slowdown = 4
	flags = IGNORE_NOSLOW

/obj/item/ammo_box/magazine/internal/cylinder/bloodsilver
	name = "detective revolver cylinder"
	ammo_type = /obj/item/ammo_casing/silver
	caliber = CALIBER_BLOODSILVER
	max_ammo = 2

/obj/item/ammo_casing/silver
	name = "Bloodsilver casing"
	desc = "A Bloodsilver bullet casing."
	icon_state = "bloodsilver"
	icon = 'monkestation/icons/obj/guns/ammo.dmi'
	projectile_type = /obj/projectile/bullet/bloodsilver
	caliber = CALIBER_BLOODSILVER

/obj/projectile/bullet/bloodsilver
	name = "bloodsilver bullet"
	damage = 3
	ricochets_max = 4

/obj/projectile/bullet/bloodsilver/on_hit(mob/living/target, blocked = 0, pierce_hit)
	. = ..()
	if(is_monster_hunter_prey(target))
		target.apply_status_effect(/datum/status_effect/silver_bullet)

/datum/status_effect/silver_bullet
	id = "silver_bullet"
	duration = 8 SECONDS
	tick_interval = STATUS_EFFECT_NO_TICK
	status_type = STATUS_EFFECT_REFRESH
	alert_type = /atom/movable/screen/alert/status_effect/silver_bullet
	/// Traits given to the victim.
	var/static/list/traits_to_give = list(
		TRAIT_EASILY_WOUNDED,
		TRAIT_NO_SPRINT,
	)

/datum/status_effect/silver_bullet/on_apply()
	owner.add_traits(traits_to_give, TRAIT_STATUS_EFFECT(id))
	owner.set_pain_mod(id, 1.5)
	owner.add_movespeed_modifier(/datum/movespeed_modifier/silver_bullet)
	to_chat(owner, span_userdanger("Your body suddenly feels impossibly heavy, you can barely move!"), type = MESSAGE_TYPE_COMBAT)
	return TRUE

/datum/status_effect/silver_bullet/on_remove()
	owner.remove_traits(traits_to_give, TRAIT_STATUS_EFFECT(id))
	owner.unset_pain_mod(id)
	owner.remove_movespeed_modifier(/datum/movespeed_modifier/silver_bullet)
	to_chat(owner, span_notice("The impossible weight fades away, allowing you to move normally once more."), type = MESSAGE_TYPE_COMBAT)

// Either adds 4 seconds to the existing duration, or resets it to 8 seconds, whichever would be longer.
/datum/status_effect/silver_bullet/refresh(effect, ...)
	var/original_duration = initial(duration)
	duration = max(world.time + original_duration, duration + (original_duration / 2))

/atom/movable/screen/alert/status_effect/silver_bullet
	name = "Bloodsilver Curse"
	desc = "You can feel your sins crawling on your back, weighing you down immensely."
	icon_state = "silver_bullet"
