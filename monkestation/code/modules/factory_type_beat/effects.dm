/obj/effect/temp_visual/mining_overlay/vent
	icon = 'monkestation/code/modules/factory_type_beat/icons/vent_overlays.dmi'
	icon_state = "unknown"
	duration = 45
	pixel_x = 0
	pixel_y = 0
	easing_style = CIRCULAR_EASING|EASE_IN

/obj/effect/decal/cleanable/rubble
	name = "rubble"
	desc = "A pile of rubble."
	icon = 'monkestation/code/modules/factory_type_beat/icons/debris.dmi'
	icon_state = "rubble"
	mergeable_decal = FALSE
	beauty = -10

/obj/effect/decal/cleanable/rubble/Initialize(mapload)
	. = ..()
	flick("rubble_bounce", src)
	icon_state = "rubble"
	update_appearance(UPDATE_ICON_STATE)

/obj/effect/temp_visual/circle_wave
	icon = 'icons/effects/64x64.dmi'
	icon_state = "circle_wave"
	pixel_x = -16
	pixel_y = -16
	duration = 0.5 SECONDS
	color = COLOR_LIME
	var/max_alpha = 255
	///How far the effect would scale in size
	var/amount_to_scale = 2

/obj/effect/temp_visual/circle_wave/Initialize(mapload)
	transform = matrix().Scale(0.1)
	animate(src, transform = matrix().Scale(amount_to_scale), time = duration, flags = ANIMATION_PARALLEL)
	animate(src, alpha = 255, time = duration * 0.6, flags = ANIMATION_PARALLEL)
	animate(alpha = 0, time = duration * 0.4)
	apply_wibbly_filters(src)
	return ..()

/// Visual effect spawned when the bioscrambler scrambles your bio
/obj/effect/temp_visual/circle_wave/bioscrambler
	color = COLOR_LIME

/obj/effect/temp_visual/circle_wave/bioscrambler/light
	max_alpha = 128

//for void heretic
/obj/effect/temp_visual/circle_wave/void_conduit
	color = COLOR_FULL_TONER_BLACK
	duration = 12 SECONDS
	amount_to_scale = 12
