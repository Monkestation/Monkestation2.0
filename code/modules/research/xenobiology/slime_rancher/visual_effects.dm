/// Overlay that only shows up where its owner's sprite is
/obj/effect/abstract/visual_effect
	name = ""
	alpha = 210
	anchored = TRUE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	icon = 'icons/obj/xenobiology/slime_rancher/visual_effects.dmi'
	vis_flags = VIS_INHERIT_PLANE | VIS_INHERIT_LAYER
	blend_mode = BLEND_INSET_OVERLAY

/obj/effect/abstract/visual_effect/rainbow
	icon_state = "rainbow"
	alpha = 150

/obj/effect/abstract/visual_effect/bluespace
	icon_state = "bluespace"

/obj/effect/abstract/visual_effect/gold
	icon_state = "gold"

/obj/effect/abstract/visual_effect/oil
	icon_state = "oil"

/obj/effect/abstract/visual_effect/black
	icon_state = "black"

/obj/effect/abstract/visual_effect/spacey
	icon_state = "spacey"
	alpha = 255

/// Sticks a visual effect in our vis_contents
/atom/movable/proc/add_visual_effect(effect_type)
	if(!ispath(effect_type, /obj/effect/abstract/visual_effect))
		CRASH("tried to pass invalid type ([effect_type]) to add_visual_effect!")
	appearance_flags &= ~KEEP_APART
	appearance_flags |= KEEP_TOGETHER
	vis_contents += new effect_type
