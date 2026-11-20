/datum/smite/asspic
	name = "Ass Pic"

/datum/smite/asspic/effect(client/user, mob/living/ass)
	. = ..()
	var/icon/temp_img
	if(ishuman(ass))
		var/mob/living/carbon/human/H = ass
		var/obj/item/bodypart/chest/chest = H.get_bodypart(BODY_ZONE_CHEST)
		if(chest.ass_image)
			temp_img = icon(chest.ass_image)
		else
			temp_img = icon(ass.gender == FEMALE ? 'icons/ass/assfemale.png' : 'icons/ass/assmale.png')
	else if(isalienadult(ass)) //Xenos have their own asses, thanks to Pybro.
		temp_img = icon('icons/ass/assalien.png')
	else if(issilicon(ass))
		temp_img = icon('icons/ass/assmachine.png')
	else if(isdrone(ass)) //Drones are hot
		temp_img = icon('icons/ass/assdrone.png')

	var/obj/item/photo/copied_ass = new /obj/item/photo(get_turf(ass))
	var/datum/picture/toEmbed = new(name = "[ass]'s Ass", desc = "You see [ass]'s ass on the photo.", image = temp_img)
	toEmbed.psize_x = 128
	toEmbed.psize_y = 128
	copied_ass.set_picture(toEmbed, TRUE, TRUE)
	copied_ass.assphoto = TRUE
	if(ishuman(ass))
		var/mob/living/carbon/human/hole = ass
		hole.put_in_hands(copied_ass,FALSE,FALSE,FALSE,TRUE)
