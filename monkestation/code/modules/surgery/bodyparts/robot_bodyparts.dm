/obj/item/bodypart/leg/left/robot/digitigrade
	name = "digitigrade prosthetic left leg"
	icon_static = 'monkestation/icons/mob/species/cetanoid/bodyparts.dmi'
	icon = 'monkestation/icons/mob/species/cetanoid/bodyparts.dmi'
	digitigrade_id = "digitigrade"
	can_be_digitigrade = TRUE

	biological_state = (BIO_ROBOTIC)

/obj/item/bodypart/leg/left/robot/digitigrade/Initialize(mapload)
	. = ..()
	set_digitigrade(TRUE)

/obj/item/bodypart/leg/right/robot/digitigrade
	name = "digitigrade prosthetic right leg"
	icon_static = 'monkestation/icons/mob/species/cetanoid/bodyparts.dmi'
	icon = 'monkestation/icons/mob/species/cetanoid/bodyparts.dmi'
	digitigrade_id = "digitigrade"
	can_be_digitigrade = TRUE

	biological_state = (BIO_ROBOTIC)

/obj/item/bodypart/leg/right/robot/digitigrade/Initialize(mapload)
	. = ..()
	set_digitigrade(TRUE)
