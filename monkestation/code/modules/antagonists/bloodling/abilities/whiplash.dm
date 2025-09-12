/datum/action/cooldown/spell/aoe/repulse/bloodling
	name = "Whiplash"
	desc = "Grow whiplike appendages and throw back nearby attackers. Costs 25 biomass."
	background_icon = 'monkestation/code/modules/antagonists/bloodling/sprites/bloodling_abilities.dmi'
	background_icon_state = "button_bg"
	button_icon = 'monkestation/code/modules/antagonists/bloodling/sprites/bloodling_abilities.dmi'
	button_icon_state = "whiplash"
	sound = 'sound/magic/tail_swing.ogg'
	shared_cooldown = MOB_SHARED_COOLDOWN_1

	spell_requirements = NONE

	check_flags = AB_CHECK_CONSCIOUS | AB_CHECK_INCAPACITATED
	invocation_type = INVOCATION_NONE
	antimagic_flags = NONE
	aoe_radius = 2

	sparkle_path = /obj/effect/temp_visual/bloodling_tentacle

	/// Since this isn't a bloodling subtype ability we need to recode the cost here
	var/biomass_cost = 25

/obj/effect/temp_visual/bloodling_tentacle
	icon = 'monkestation/code/modules/antagonists/bloodling/sprites/bloodling_sprites.dmi'
	icon_state = "tentacle_effect"
	duration = 7

/datum/action/cooldown/spell/aoe/repulse/bloodling/IsAvailable(feedback = FALSE)
	. = ..()
	if(!.)
		return FALSE
	// Basically we only want bloodlings to have this
	if(!istype(owner, /mob/living/basic/bloodling))
		return FALSE
	var/mob/living/basic/bloodling/our_mob = owner
	if(our_mob.biomass <= biomass_cost)
		return FALSE
	return TRUE

/datum/action/cooldown/spell/aoe/repulse/bloodling/PreActivate(atom/target)
	var/mob/living/basic/bloodling/our_mob = owner
	// Parent calls Activate(), so if parent returns TRUE,
	// it means the activation happened successfuly by this point
	. = ..()
	if(!.)
		return FALSE
	// Since bloodlings evolve it may result in them or their abilities going away
	// so we can just return true here
	if(QDELETED(src) || QDELETED(owner))
		return TRUE

	if(our_mob.movement_type & VENTCRAWLING)
		our_mob.balloon_alert(our_mob, "can't use abilities in pipes!")
		return FALSE

	our_mob.add_biomass(-biomass_cost)

	return TRUE
