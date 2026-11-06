/atom/movable/screen/darkspawn_psi
	name = "psi"
	icon = 'icons/hud/screen_gen.dmi'
	icon_state = "psi_counter"
	screen_loc = ui_lingchemdisplay
	invisibility = INVISIBILITY_ABSTRACT

/datum/hud
	var/atom/movable/screen/darkspawn_psi/psi_counter

/datum/hud/New(mob/owner, ui_style = 'icons/hud/screen_midnight.dmi')
	. = ..()
	psi_counter = new /atom/movable/screen/darkspawn_psi(src)

/datum/hud/human/New(mob/living/carbon/human/owner, ui_style = 'icons/hud/screen_midnight.dmi')
	. = ..()
	psi_counter = new /atom/movable/screen/darkspawn_psi(src)
	infodisplay += psi_counter

/datum/hud/Destroy()
	. = ..()
	psi_counter = null

/datum/atom_hud/alternate_appearance/basic/has_antagonist/darkspawn
	antag_datum_type = /datum/antagonist/darkspawn

