/datum/action/cooldown/bloodsucker/veil
	name = "Veil of Many Faces"
	desc = "Disguise yourself in the illusion of another identity."
	button_icon_state = "power_veil"
	power_explanation = "Veil of Many Faces: \n\
		Activating Veil of Many Faces will shroud you in smoke and forge you a new identity.\n\
		Your name and appearance will be completely randomized, and turning the ability off again will undo it all."
	power_flags = BP_AM_TOGGLE
	check_flags = BP_CANT_USE_IN_FRENZY | BP_CANT_USE_DURING_SOL
	purchase_flags = BLOODSUCKER_DEFAULT_POWER | VASSAL_CAN_BUY
	bloodcost = 15
	constant_bloodcost = 0.1
	cooldown_time = 10 SECONDS
	var/datum/dna/originalDNA
	var/originalname
	var/prev_disfigured

/datum/action/cooldown/bloodsucker/veil/ActivatePower(trigger_flags)
	. = ..()
	cast_effect() // POOF
//	if(blahblahblah)
//		Disguise_Outfit()
	veil_user()
	owner.balloon_alert(owner, "veil turned on.")

/* // Meant to disguise your character's clothing into fake ones.
/datum/action/cooldown/bloodsucker/veil/proc/Disguise_Outfit()
	return
	// Step One: Back up original items
*/

/datum/action/cooldown/bloodsucker/veil/proc/veil_user()
	if(!ishuman(owner))
		return
	var/mob/living/carbon/human/user = owner
	to_chat(owner, span_warning("You mystify the air around your person. Your identity is now altered."))
	originalDNA = new user.dna.type
	originalname = user.real_name
	user.dna.copy_dna(originalDNA)
	randomize_human(user)
	prev_disfigured = HAS_TRAIT(user, TRAIT_DISFIGURED) // I was disfigured! //prev_disabilities = user.disabilities
	if(prev_disfigured)
		REMOVE_TRAIT(user, TRAIT_DISFIGURED, null)

/datum/action/cooldown/bloodsucker/veil/DeactivatePower()
	. = ..()
	if(!ishuman(owner))
		return
	var/mob/living/carbon/human/user = owner
	to_chat(user, span_notice("You return to your old form."))
	originalDNA.transfer_identity(user)
	user.real_name = originalname
	user.update_name_tag(originalname) // monkestation edit: name tags
	user.updateappearance(mutcolor_update=1)
	//user.disabilities = prev_disabilities // Restore HUSK, CLUMSY, etc.
	if(prev_disfigured)
		//We are ASSUMING husk. // user.status_flags |= DISFIGURED // Restore "Unknown" disfigurement
		ADD_TRAIT(user, TRAIT_DISFIGURED, TRAIT_HUSK)
	cast_effect() // POOF
	user.balloon_alert(owner, "veil turned off.")


// CAST EFFECT // General effect (poof, splat, etc) when you cast. Doesn't happen automatically!
/datum/action/cooldown/bloodsucker/veil/proc/cast_effect()
	// Effect
	playsound(get_turf(owner), 'sound/magic/smoke.ogg', 20, 1)
	var/datum/effect_system/steam_spread/bloodsucker/puff = new /datum/effect_system/steam_spread/()
	puff.set_up(3, 0, get_turf(owner))
	puff.attach(owner) //OPTIONAL
	puff.start()
	owner.spin(8, 1) //Spin around like a loon.

/obj/effect/particle_effect/fluid/smoke/vampsmoke
	opacity = FALSE
	lifetime = 0

/obj/effect/particle_effect/fluid/smoke/vampsmoke/fade_out(frames = 0.8 SECONDS)
	..(frames)
