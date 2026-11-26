/mob/living/basic/chicken/rev_raptor
	icon_suffix = "rev_raptor"
	worn_slot_flags = null

	breed_name = "Revolutionary Raptor"
	breed_name_male = "Revolutionary Tiercel"
	egg_type = /obj/item/food/egg/raptor

	ai_controller = /datum/ai_controller/chicken/hostile
	health = 150
	maxHealth = 100
	melee_damage_upper = 6
	melee_damage_lower = 2
	obj_damage = 10

	targeted_ability = /datum/action/cooldown/mob_cooldown/chicken/rev_convert

	book_desc = "This is what happens when we let the raptors learn from the stations crew."

/// Spreads the revolution to the chickens around us
/mob/living/basic/chicken/rev_raptor/pick_ability_target(datum/ai_controller/controller)
	var/list/viable_conversions = list()
	for(var/mob/living/basic/chicken/found_chicken in view(4, loc))
		if(!istype(found_chicken, /mob/living/basic/chicken/rev_raptor) && !istype(found_chicken, /mob/living/basic/chicken/raptor))
			viable_conversions |= found_chicken
	return length(viable_conversions) ? pick(viable_conversions) : null

/obj/item/food/egg/rev_raptor
	name = "Revolutionary Egg"
	icon_state = "rev_raptor"

	layer_hen_type = /mob/living/basic/chicken/rev_raptor


/datum/action/cooldown/mob_cooldown/chicken/rev_convert
	name = "Revolt"
	desc = "Bring more chickens into your cause."
	button_icon = 'icons/mob/actions/actions_ecult.dmi'
	button_icon_state = "eye"
	background_icon_state = "bg_demon"
	overlay_icon_state = "bg_demon_border"

	cooldown_time = 20 SECONDS
	check_flags = AB_CHECK_CONSCIOUS | AB_CHECK_INCAPACITATED
	click_to_activate = TRUE
	shared_cooldown = NONE
	ai_range = 1

/datum/action/cooldown/mob_cooldown/chicken/rev_convert/PreActivate(atom/target)
	if(target == owner || !istype(target, /mob/living/basic/chicken))
		return FALSE
	return ..()

/datum/action/cooldown/mob_cooldown/chicken/rev_convert/Activate(mob/living/target)
	if(!istype(target, /mob/living/basic/chicken))
		CRASH("Revolutionary raptor somehow tried to convert non-chicken")
	owner.say("VIVA, BAWK!")
	var/mob/living/basic/chicken/raptor/converted_raptor = new(target.loc)
	target.mind?.transfer_to(converted_raptor)
	qdel(target)
	StartCooldown()
	return TRUE

