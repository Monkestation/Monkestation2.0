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

