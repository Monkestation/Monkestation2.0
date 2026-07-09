/datum/action/cooldown/bloodling/bolster
	name = "Bolster"
	desc = "Draw biomass from the ground."
	cooldown_time = 5 SECONDS
	shared_cooldown = NONE
	background_icon = 'icons/mob/actions/backgrounds.dmi'
	background_icon_state = "bg_bloodling"
	button_icon = 'monkestation/code/modules/antagonists/bloodling/sprites/bloodling_abilities.dmi'
	button_icon_state = "ascend"
	click_to_activate = FALSE

/datum/action/cooldown/bloodling/bolster/PreActivate(atom/target)
	if(!istype(owner.loc, /turf/open/misc/bloodling))
		owner.balloon_alert(owner, "the ground has no biomass!")
		return FALSE
	return ..()

/datum/action/cooldown/bloodling/bolster/Activate(atom/target)
	. = ..()
	var/mob/living/basic/bloodling/our_mob = owner
	our_mob.add_biomass(150)
	our_mob.Stun(10, ignore_canstun = TRUE)
	playsound(get_turf(owner), 'sound/items/drink.ogg', 30)
	owner.balloon_alert(owner, "your biomass is restored!")
	return TRUE
