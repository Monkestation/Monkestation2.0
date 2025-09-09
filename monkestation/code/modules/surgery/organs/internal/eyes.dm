/obj/item/organ/internal/eyes/robotic/clockwork
	name = "biometallic receptors"
	desc = "A fragile set of small, mechanical cameras."
	icon = 'monkestation/icons/obj/medical/organs/organs.dmi'
	icon_state = "clockwork_eyeballs"

/obj/item/organ/internal/eyes/night_vision/arachnid
	name = "arachnid eyes"
	desc = "So many eyes!"
	icon = 'monkestation/icons/obj/medical/organs/organs.dmi'
	eye_icon_state = "arachnideyes"
	icon_state = "arachnid_eyeballs"
	overlay_ignore_lighting = TRUE
	no_glasses = TRUE
	low_light_cutoff = list(20, 15, 0)
	medium_light_cutoff = list(35, 30, 0)
	high_light_cutoff = list(50, 40, 0)

/obj/item/organ/internal/eyes/night_vision/arachnid/on_insert(mob/living/carbon/tongue_owner)
	. = ..()
	if(!ishuman(tongue_owner))
		return
	var/mob/living/carbon/human/human_receiver = tongue_owner
	if(!human_receiver.can_mutate())
		return
	var/datum/species/rec_species = human_receiver.dna.species
	rec_species.update_no_equip_flags(tongue_owner, rec_species.no_equip_flags | ITEM_SLOT_EYES)

/obj/item/organ/internal/eyes/night_vision/arachnid/on_remove(mob/living/carbon/tongue_owner)
	. = ..()
	if(!ishuman(tongue_owner))
		return
	var/mob/living/carbon/human/human_receiver = tongue_owner
	if(!human_receiver.can_mutate())
		return
	var/datum/species/rec_species = human_receiver.dna.species
	rec_species.update_no_equip_flags(tongue_owner, initial(rec_species.no_equip_flags))

/obj/item/organ/internal/eyes/floran
	name = "phytoid eyes"
	desc = "They look like big berries..."
	icon = 'monkestation/icons/obj/medical/organs/organs.dmi'
	eye_icon_state = "floraneyes"
	icon_state = "floran_eyeballs"

/obj/item/organ/internal/eyes/ethereal
	name = "crystal eyes"
	icon = 'monkestation/icons/obj/medical/organs/organs.dmi'
	icon_state = "crystalline_eyeballs"
	eye_icon_state = "etherealeyes"

/obj/item/organ/internal/eyes/moth/tundra
	name = "tundra moth eyes"
	eye_icon_state = "tundramotheyes"
	icon_state = "eyeballs-tundramoth"

/obj/item/organ/internal/eyes/jelly
	name = "photosensitive eyespots"
	zone = BODY_ZONE_CHEST

/obj/item/organ/internal/eyes/roundstartslime
	name = "photosensitive eyespots"
	zone = BODY_ZONE_CHEST
	organ_flags = ORGAN_UNREMOVABLE

/obj/item/organ/internal/eyes/synth
	name = "optical sensors"
	icon_state = "cybernetic_eyeballs"
	desc = "A very sensitive set of optical sensors, with functionality to toggle a protective film against lights."
	maxHealth = 1 * STANDARD_ORGAN_THRESHOLD
	flash_protect = FLASH_PROTECTION_HYPER_SENSITIVE
	organ_flags = ORGAN_ROBOTIC | ORGAN_SYNTHETIC_FROM_SPECIES
	actions_types = list(/datum/action/item_action/organ_action/toggle)
	var/shielding = FALSE

/obj/item/organ/internal/eyes/synth/ui_action_click(mob/user, action)
	if(istype(action, /datum/action/item_action/organ_action/toggle))
		toggle_active()

/**
 * Toggles the welding/tint of the eyes
 */
/obj/item/organ/internal/eyes/synth/proc/toggle_active()
	if(shielding)
		deactivate()
	else
		activate()
	owner.update_tint()

/**
 *
 * Turns the shielding on but gives tint.
 */
/obj/item/organ/internal/eyes/synth/proc/activate(mob/living/carbon/eye_owner = owner)
	shielding = TRUE
	flash_protect = FLASH_PROTECTION_WELDER
	tint = 2
	to_chat(eye_owner, "A protective film covers your optical sensors, shielding you from lights.")

/**
 *
 * Turns the shielding off but removes tint.
 */
/obj/item/organ/internal/eyes/synth/proc/deactivate(mob/living/carbon/eye_owner = owner)
	shielding = FALSE
	flash_protect = FLASH_PROTECTION_HYPER_SENSITIVE
	tint = 0
	to_chat(eye_owner, "The protective film over your opticalsensors recedes.")


/obj/item/organ/internal/eyes/synth/emp_act(severity)
	. = ..()

	if((. & EMP_PROTECT_SELF) || !owner)
		return

	switch(severity)
		if(EMP_HEAVY)
			to_chat(owner, span_warning("Alert:Severe electromagnetic interference clouds your optics with static. Error Code: I-CS6"))
			apply_organ_damage(SYNTH_ORGAN_HEAVY_EMP_DAMAGE, maximum = maxHealth, required_organ_flag = ORGAN_ROBOTIC)
		if(EMP_LIGHT)
			to_chat(owner, span_warning("Alert: Mild interference clouds your optics with static. Error Code: I-CS0"))
			apply_organ_damage(SYNTH_ORGAN_LIGHT_EMP_DAMAGE, maximum =maxHealth, required_organ_flag = ORGAN_ROBOTIC)

/datum/design/synth_eyes
	name = "Optical Sensors"
	desc = "A very basic set of optical sensors with no extra vision modes or functions."
	id = "synth_eyes"
	build_type = PROTOLATHE | AWAY_LATHE | MECHFAB
	construction_time = 4 SECONDS
	materials = list(
		/datum/material/iron = HALF_SHEET_MATERIAL_AMOUNT,
		/datum/material/glass = HALF_SHEET_MATERIAL_AMOUNT,
	)
	build_path = /obj/item/organ/internal/eyes/synth
	category = list(
		RND_CATEGORY_CYBERNETICS + RND_SUBCATEGORY_CYBERNETICS_SYNTHETIC_ORGANS
	)
	departmental_flags = DEPARTMENT_BITFLAG_MEDICAL | DEPARTMENT_BITFLAG_SCIENCE


/obj/item/organ/internal/eyes/robotic/meson
	name = "meson eyes"
	desc = "These cybernetic eye implants allow you to see the structural layout of your surroundings."
	eye_color_left = "0c4"
	eye_color_right = "0c4"
	color_cutoffs = list(5, 15, 5)
	sight_flags = SEE_TURFS
	lighting_cutoff = LIGHTING_CUTOFF_MEDIUM
