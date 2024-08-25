/obj/item/donator/wumpa
	name = "wumpa"
	desc = span_bold("What in the god-dam?...")
	icon = 'monkestation/code/modules/donator/icons/obj/misc.dmi'
	icon_state = "wumpa"
	var/datum/looping_sound/wumpa/sounds
	var/shutup = FALSE
	pickup_sound = 'monkestation/code/modules/donator/sounds/woah.ogg'
	drop_sound = 'monkestation/code/modules/donator/sounds/woah.ogg'
/obj/item/donator/wumpa/Initialize(mapload)
	. = ..()
	sounds = new /datum/looping_sound/wumpa(src,TRUE)

/obj/item/donator/wumpa/attack_self(mob/user, modifiers)
	. = ..()
	if(shutup)
		user.visible_message("The [src] continues its jolly melody.")
		sounds.stop()
	else
		user.visible_message("The [src] shuts up.")
		sounds.start(src)
	shutup= !shutup

/datum/looping_sound/wumpa
	mid_sounds = list('monkestation/code/modules/donator/sounds/wumpa.ogg' = 1)
	mid_length = 32
	volume = 1
	extra_range = 3
	falloff_exponent = 100
	falloff_distance = 3

