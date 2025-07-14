// All the code below makes it so you can shock someone if they're pulling you whilst you're cuffed
/datum/action/cooldown/spell/touch/shock/IsAvailable(feedback = FALSE)
	if(!owner || owner.stat != CONSCIOUS || !owner.pulledby || (next_use_time > world.time))
		return ..()

	var/mob/living/carbon/human = owner
	if(istype(human) && !isnull(human.handcuffed))
		return TRUE

	return ..()

/datum/action/cooldown/spell/touch/shock/cast(mob/living/carbon/cast_on)
	if(isnull(cast_on.handcuffed) || !cast_on.pulledby)
		return ..()

	do_hand_hit(null, cast_on.pulledby, cast_on)
	return TRUE
// Previous comment ends here

/datum/mutation/human/shock/far
	name = "Extended Shock Touch"
	desc = "The affected can channel excess electricity through their hands without shocking themselves, allowing them to shock others at range."
	text_gain_indication = span_notice("You feel unlimited power flow through your hands.")
	power_path = /datum/action/cooldown/spell/touch/shock/far
	instability = 50

/datum/action/cooldown/spell/touch/shock/far
	name = "Extended Shock Touch"
	hand_path = /obj/item/melee/touch_attack/shock/far

/datum/action/cooldown/spell/touch/shock/far/cast_on_hand_hit(obj/item/melee/touch_attack/hand, atom/victim, mob/living/carbon/caster)
	. = ..()
	caster.Beam(victim, icon_state = "red_lightning", time = 1.5 SECONDS)

/obj/item/melee/touch_attack/shock/far

/obj/item/melee/touch_attack/shock/far/afterattack(atom/target, mob/living/carbon/user, proximity, click_parameters)
	if(!can_see(user, target, 5) || get_dist(target, user) > 5)
		user.visible_message(span_notice("[user]'s hand reaches out but nothing happens."))
		return
	return ..(target, user, TRUE, click_parameters) //call the parent, forcing proximity = TRUE so even distant things are considered nearby

/datum/mutation/human/lay_on_hands
	conflicts = list(/datum/mutation/human/lay_on_hands/syndicate)

/datum/mutation/human/lay_on_hands/syndicate
	name = "Corrupted Mending Touch"
	desc = "A genetic sequence thats highly corrupted sharing some nucleotides with mending touch, use is not advised."
	quality = POSITIVE
	locked = TRUE
	text_gain_indication = span_notice("Your hand feels strange.")
	text_lose_indication = span_notice("Your hand feels secular once more.")
	power_path = /datum/action/cooldown/spell/touch/lay_on_hands/syndicate
	conflicts = list(/datum/mutation/human/lay_on_hands)
	instability = 50

/datum/action/cooldown/spell/touch/lay_on_hands/syndicate
	name = "Corrupted Mending Touch"
	desc = "You can now lay your hands on other people to transfer a small amount of their physical injuries to yourself. \
		This version of the mutation allows you smite anyone as long as you mean to cause HARM to them."
	button_icon = 'monkestation/icons/mob/actions/actions_genetic.dmi'
	button_icon_state = "corrupted_mending_touch"
	always_evil_smite = TRUE

/datum/action/cooldown/spell/touch/lay_on_hands/syndicate/determine_if_this_hurts_instead(mob/living/carbon/mendicant, mob/living/hurtguy)
	if(HAS_TRAIT(mendicant, TRAIT_PACIFISM))
		return FALSE //always return false if we're pacifist

	. = ..()
	if(!. && mendicant.istate & ISTATE_HARM)
		return TRUE
