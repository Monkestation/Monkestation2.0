/datum/action/cooldown/vampire/veil
	name = "Veil of Many Faces"
	desc = "Disguise yourself in the illusion of another identity."
	button_icon_state = "power_veil"
	power_explanation = "Activating Veil of Many Faces will shroud you in smoke and forge you a new identity.\n\
		Your name and appearance will be completely randomized, deactivating the ability will restore you to your former self."
	vampire_power_flags = BP_AM_TOGGLE
	vampire_check_flags = BP_CANT_USE_IN_FRENZY | BP_CANT_USE_WHILE_STAKED | BP_ALLOW_WHILE_SILVER_CUFFED
	vitaecost = 100
	constant_vitaecost = 4
	cooldown_time = 10 SECONDS

	var/datum/dna/original_dna
	var/prev_disfigured
	var/original_name
	var/alist/original_clothing_prefs

/datum/action/cooldown/vampire/veil/activate_power()
	. = ..()
	cast_effect() // POOF
	veil_user()
	owner.balloon_alert(owner, "veil turned on.")

/datum/action/cooldown/vampire/veil/proc/veil_user()
	if(!ishuman(owner))
		return
	var/mob/living/carbon/human/user = owner
	to_chat(owner, span_warning("You mystify the air around your person. Your identity is now altered."))
	original_dna = new user.dna.type
	original_name = user.real_name
	original_clothing_prefs = user.backup_clothing_prefs()
	user.dna.copy_dna(original_dna)
	randomize_human(user)
	prev_disfigured = HAS_TRAIT(user, TRAIT_DISFIGURED) // I was disfigured! //prev_disabilities = user.disabilities
	if(prev_disfigured)
		REMOVE_TRAIT(user, TRAIT_DISFIGURED, null)

	to_chat(owner, span_warning("You mystify the air around your person. Your identity is now altered."))

/datum/action/cooldown/vampire/veil/deactivate_power()
	. = ..()
	if(!ishuman(owner))
		return
	var/mob/living/carbon/human/user = owner
	to_chat(user, span_notice("You return to your old form."))
	original_dna.copy_dna(user.dna, COPY_DNA_SE|COPY_DNA_SPECIES|COPY_DNA_MUTATIONS)
	user.real_name = original_name
	user.restore_clothing_prefs(original_clothing_prefs)
	user.updateappearance(mutcolor_update = TRUE)
	//user.disabilities = prev_disabilities // Restore HUSK, CLUMSY, etc.
	if(prev_disfigured)
		//We are ASSUMING husk. // user.status_flags |= DISFIGURED // Restore "Unknown" disfigurement
		ADD_TRAIT(user, TRAIT_DISFIGURED, TRAIT_HUSK)

	original_dna = null

	cast_effect() // POOF
	owner.balloon_alert(owner, "veil turned off.")

// CAST EFFECT // General effect (poof, splat, etc) when you cast. Doesn't happen automatically!
/datum/action/cooldown/vampire/veil/proc/cast_effect()
	// Effect
	playsound(get_turf(owner), 'sound/magic/smoke.ogg', 20, 1)
	var/datum/effect_system/steam_spread/vampire/puff = new /datum/effect_system/steam_spread/()
	puff.set_up(3, 0, get_turf(owner))
	puff.attach(owner) //OPTIONAL
	puff.start()
	owner.spin(0.8 SECONDS, 1) //Spin around like a loon.
	check_witnesses()

/obj/effect/particle_effect/fluid/smoke/vampsmoke
	opacity = FALSE
	lifetime = 0

/obj/effect/particle_effect/fluid/smoke/vampsmoke/fade_out(frames = 0.8 SECONDS)
	..(frames)
