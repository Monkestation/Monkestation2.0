/datum/quirk/prosthetic_limb
	name = "Prosthetic Limb"
	desc = "An accident caused you to lose one of your limbs. Because of this, you now have a surplus prosthetic!"
	icon = "tg-prosthetic-leg"
	value = QUIRK_COST_PROSTHETIC_LIMB
	hardcore_value = QUIRK_HARDCORE_PROSTHETIC_LIMB
	quirk_flags = QUIRK_HUMAN_ONLY | QUIRK_CHANGES_APPEARANCE | QUIRK_DONT_CLONE
	mail_goodies = list(/obj/item/weldingtool/mini, /obj/item/stack/cable_coil/five)
	/// The slot to replace, in string form
	var/slot_string = "limb"
	/// The slot to replace, in GLOB.limb_zones (both arms and both legs)
	var/limb_zone
	species_blacklist = list(SPECIES_OOZELING)

/datum/quirk/prosthetic_limb/add_unique(client/client_source)
	limb_zone = GLOB.limb_choice[client_source?.prefs?.read_preference(/datum/preference/choiced/limb/prosthetic)]
	if (isnull(limb_zone))  //Client gone or they chose a random limb
		limb_zone = GLOB.limb_choice[pick(GLOB.limb_choice)]
	slot_string = body_zone_as_plaintext(limb_zone)

	var/obj/item/bodypart/surplus
	switch (limb_zone)
		if (BODY_ZONE_L_ARM)
			surplus = new /obj/item/bodypart/arm/left/robot/surplus()
		if (BODY_ZONE_R_ARM)
			surplus = new /obj/item/bodypart/arm/right/robot/surplus()
		if (BODY_ZONE_L_LEG)
			surplus = new /obj/item/bodypart/leg/left/robot/surplus()
		if (BODY_ZONE_R_LEG)
			surplus = new /obj/item/bodypart/leg/right/robot/surplus()
	medical_record_text = "Patient uses a low-budget prosthetic on the [slot_string]."
	var/mob/living/carbon/human/human_holder = quirk_holder
	human_holder.del_and_replace_bodypart(surplus, special = TRUE)

/datum/quirk/prosthetic_limb/post_add()
	to_chat(quirk_holder, span_bolddanger("Your [slot_string] has been replaced with a surplus prosthetic. It has almost no muscle force, and makes you unhealthier by just having it. Additionally, \
	you need to use a welding tool and cables to repair it, instead of sutures and regenerative meshes."))

/datum/quirk/prosthetic_limb/remove()
	if(QDELETED(quirk_holder))
		return
	var/mob/living/carbon/human/human_holder = quirk_holder
	human_holder.reset_to_original_bodypart(limb_zone)
