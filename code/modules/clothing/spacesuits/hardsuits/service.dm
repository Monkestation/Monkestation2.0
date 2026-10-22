//----------------------------------------
// HOP Hardsuit, for when you need to do paperwork in space
//----------------------------------------

/obj/item/clothing/suit/space/hardsuit/hop
	name = "hardsuit"
	desc = "A special suit that protects against hazardous, low pressure environments. Has radiation shielding."
	icon_state = "hardsuit-hop"
	max_integrity = 300
	armor_type = /datum/armor/hardsuit/hop
	hardsuit_helmet = /obj/item/clothing/head/helmet/space/hardsuit/hop

/obj/item/clothing/head/helmet/space/hardsuit/hop
	name = "hardsuit helmet"
	desc = "A special helmet designed for work in a hazardous, low-pressure environment. Has radiation shielding."
	icon_state = "hardsuit0-hop"
	max_integrity = 300
	armor_type = /datum/armor/hardsuit/hop
	hardsuit_type = "hop"

//----------------------------------------
// Clown Hardsuit  PRAISE THE HONKMOTHER!
//----------------------------------------
/obj/item/clothing/suit/space/hardsuit/clown
	name = "cosmohonk hardsuit"
	desc = "A special suit made by Honk! Co. that protects against hazardous, low-humor environments. Only a true clown can wear it."
	icon_state = "hardsuit-clown"
	armor_type = /datum/armor/hardsuit/clown
	hardsuit_helmet = /obj/item/clothing/head/helmet/space/hardsuit/clown
	allowed = list(
		/obj/item/flashlight,
		/obj/item/tank/internals,
		/obj/item/tank/jetpack,
		/obj/item/bikehorn,//essential for deep space clown survival
		)

/obj/item/clothing/head/helmet/space/hardsuit/clown
	name = "cosmohonk hardsuit helmet"
	desc = "A special helmet designed for work in a hazardous, low-humor environment."
	icon_state = "hardsuit0-clown"
	armor_type = /datum/armor/hardsuit/clown
	hardsuit_type = "clown"

/obj/item/clothing/suit/space/hardsuit/clown/mob_can_equip(mob/M, slot, disable_warning = FALSE, bypass_equip_delay_self = FALSE, ignore_equipped = FALSE)
	if(!..() || !ishuman(M))
		return FALSE
	var/mob/living/carbon/human/H = M
	if(is_clown_job(H.mind?.assigned_role))
		return TRUE
	else
		to_chat(M, span_clown("ERROR: CLOWN COLLEGE DIPLOMA NOT FOUND")) //better enroll in clown college bucko
		return FALSE
