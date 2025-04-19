/datum/mind_ui/tamogatchi
	uniqueID = "Tamogatchi"
	element_types_to_spawn = list(
		/obj/abstract/mind_ui_element/tamogatchi_background,
		/obj/abstract/mind_ui_element/tamogatchi_screen,
		/obj/abstract/mind_ui_element/tamogatchi,
		/obj/abstract/mind_ui_element/hoverable/tamogatchi_paw,
		/obj/abstract/mind_ui_element/hoverable/tamogatchi_right,
		/obj/abstract/mind_ui_element/hoverable/tamogatchi_left,
		/obj/abstract/mind_ui_element/hoverable/tamogatchi_ok,
		/obj/abstract/mind_ui_element/hoverable/tamogatchi_close,
		/obj/abstract/mind_ui_element/hoverable/movable/tamogatchi_move,
		)
	display_with_parent = TRUE
	y = "BOTTOM"
	x = "LEFT"
//------------------------------------------------------------
/obj/abstract/mind_ui_element/tamogatchi_background
	icon = 'monkestation/code/modules/bloody_cult/icons/tamogatchi/320x320.dmi'
	icon_state = "bg"
	layer = MIND_UI_BACK

/obj/abstract/mind_ui_element/tamogatchi_screen
	icon = 'monkestation/code/modules/bloody_cult/icons/tamogatchi/320x320.dmi'
	icon_state = "screen"
	layer = MIND_UI_FRONT

/obj/abstract/mind_ui_element/tamogatchi
	icon = 'monkestation/code/modules/bloody_cult/icons/tamogatchi/320x320.dmi'
	icon_state = "pet"
	layer = MIND_UI_FRONT + 1
	var/angry = FALSE

/obj/abstract/mind_ui_element/tamogatchi/New(turf/loc, datum/mind_ui/P)
	. = ..()
	animate(src, pixel_y = 2 , time = 10, loop = -1, easing = SINE_EASING)
	animate(pixel_y = -2, time = 10, loop = -1, easing = SINE_EASING)


/obj/abstract/mind_ui_element/hoverable/tamogatchi_paw
	icon = 'monkestation/code/modules/bloody_cult/icons/tamogatchi/320x320.dmi'
	icon_state = "paw_button"
	layer = MIND_UI_BUTTON

/obj/abstract/mind_ui_element/hoverable/tamogatchi_paw/Click(location, control, params)
	var/obj/abstract/mind_ui_element/tamogatchi/pet = locate() in parent.elements
	pet?.angry = !pet?.angry

	pet?.icon_state = "[pet?.angry ? "pet-angry" : "pet"]"

/obj/abstract/mind_ui_element/hoverable/tamogatchi_right
	icon = 'monkestation/code/modules/bloody_cult/icons/tamogatchi/320x320.dmi'
	icon_state = "right_button"
	layer = MIND_UI_BUTTON

/obj/abstract/mind_ui_element/hoverable/tamogatchi_left
	icon = 'monkestation/code/modules/bloody_cult/icons/tamogatchi/320x320.dmi'
	icon_state = "left_button"
	layer = MIND_UI_BUTTON

/obj/abstract/mind_ui_element/hoverable/tamogatchi_ok
	icon = 'monkestation/code/modules/bloody_cult/icons/tamogatchi/320x320.dmi'
	icon_state = "okay_button"
	layer = MIND_UI_BUTTON

/obj/abstract/mind_ui_element/hoverable/tamogatchi_close
	name = "Close"
	icon = 'monkestation/code/modules/bloody_cult/icons/tamogatchi/320x320.dmi'
	icon_state = "close"
	layer = MIND_UI_BUTTON + 6

/obj/abstract/mind_ui_element/hoverable/tamogatchi_close/Click()
	parent.Hide()

/obj/abstract/mind_ui_element/hoverable/movable/tamogatchi_move
	name = "Move"
	icon = 'monkestation/code/modules/bloody_cult/icons/tamogatchi/320x320.dmi'
	icon_state = "move"
	layer = MIND_UI_BUTTON + 6
	move_whole_ui = TRUE

	const_offset_y =  -100
	const_offset_x = -100
