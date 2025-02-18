/datum/quirk/prosthetic_limb
	name = "Prosthetic Limb"
	desc = "An accident caused you to lose one of your limbs. Because of this, you now have a surplus prosthetic!"
	icon = "tg-prosthetic-leg"
	value = -3
	hardcore_value = 3
	quirk_flags = QUIRK_HUMAN_ONLY | QUIRK_CHANGES_APPEARANCE | QUIRK_DONT_CLONE // monkestation edit: QUIRK_DONT_CLONE
	mail_goodies = list(/obj/item/weldingtool/mini, /obj/item/stack/cable_coil/five)
	/// The slot to replace, in string form
	var/slot_string = "limb"
	/* MONKESTATION REMOVAL
	/// the original limb from before the prosthetic was applied
	var/obj/item/bodypart/old_limb
	*/

/datum/quirk/prosthetic_limb/add_unique(client/client_source)
	// MONKESTATION EDIT START
	var/body_zone = GLOB.limb_choice[client_source?.prefs?.read_preference(/datum/preference/choiced/limb/prosthetic)]
	if(isnull(body_zone))  //Client gone or they chose a random prosthetic
		body_zone = GLOB.limb_choice[pick(GLOB.limb_choice)]

	var/missing = client_source?.prefs?.read_preference(/datum/preference/toggle/limb_missing/prosthetic)

	var/mob/living/carbon/human/human_holder = quirk_holder
	slot_string = body_zone_as_plaintext(body_zone)
	if(missing)
		medical_record_text = "Patient is missing their [slot_string]."
		human_holder.remove_bodypart_painlessly(body_zone)
		return

	var/obj/item/bodypart/surplus
	switch (body_zone)
		if(BODY_ZONE_L_ARM)
			surplus = new /obj/item/bodypart/arm/left/robot/surplus()
		if(BODY_ZONE_R_ARM)
			surplus = new /obj/item/bodypart/arm/right/robot/surplus()
		if(BODY_ZONE_L_LEG)
			surplus = new /obj/item/bodypart/leg/left/robot/surplus()
		if(BODY_ZONE_R_LEG)
			surplus = new /obj/item/bodypart/leg/right/robot/surplus()
	medical_record_text = "Patient uses a low-budget prosthetic on the [slot_string]."
	human_holder.del_and_replace_bodypart(surplus, special = TRUE)
	/* original
	var/limb_type = GLOB.limb_choice[client_source?.prefs?.read_preference(/datum/preference/choiced/prosthetic)]
	if(isnull(limb_type))  //Client gone or they chose a random prosthetic
		limb_type = GLOB.limb_choice[pick(GLOB.limb_choice)]

	var/mob/living/carbon/human/human_holder = quirk_holder
	var/obj/item/bodypart/surplus = new limb_type()
	slot_string = "[surplus.plaintext_zone]"

	medical_record_text = "Patient uses a low-budget prosthetic on the [slot_string]."
	old_limb = human_holder.return_and_replace_bodypart(surplus, special = TRUE)
	*/
	// MONKESTATION EDIT END

/datum/quirk/prosthetic_limb/post_add()
	to_chat(quirk_holder, span_boldannounce("Your [slot_string] has been replaced with a surplus prosthetic. It is fragile and will easily come apart under duress. Additionally, \
	you need to use a welding tool and cables to repair it, instead of sutures and regenerative meshes."))

/* MONKESTATION REMOVAL
/datum/quirk/prosthetic_limb/remove()
	var/mob/living/carbon/human/human_holder = quirk_holder
	human_holder.del_and_replace_bodypart(old_limb, special = TRUE)
	old_limb = null
*/
