/obj/structure/holosign/barrier/atmos/leaf
	name = "leaf atmos barrier"
	max_integrity = 150
	icon = 'monkestation/code/modules/biodome/icons/holo_leaves.dmi'
	icon_state = "holo_leaves"

/obj/structure/plaque/static_plaque/golden/commission/biodome
	desc = "Spinward Sector Station SS-13\n'Biodome' Class Outpost \nCommissioned 18/02/2563\n'Walk In The Park'"

/obj/structure/fake_eggs
	name = "egg cluster"
	desc = "These imitation eggs put the pen inhabitants at ease."
	icon = 'icons/effects/effects.dmi'
	icon_state = "eggs"
	anchored = TRUE
	density = FALSE

/obj/item/sign/set_sign_type(obj/structure/sign/fake_type)
	. = ..()
	icon = initial(fake_type.icon)

/obj/structure/sign/flag/pride
	name = "flag of Gay Pride"
	desc = "The flag of Gay Pride. Hang that rainbow up with pride!"
	icon = 'monkestation/code/modules/biodome/icons/pride_flags.dmi'
	icon_state = "flag_pride"
	sign_change_name = "Pride Flag - Rainbow"

/obj/structure/sign/flag/pride/ace
	name = "flag of Asexual Pride"
	desc = "The flag of Asexual Pride."
	icon_state = "flag_ace"
	sign_change_name = "Pride Flag - Asexual"

/obj/structure/sign/flag/pride/bi
	name = "flag of Bisexual Pride"
	desc = "The flag of Bisexual Pride."
	icon_state = "flag_bi"
	sign_change_name = "Pride Flag - Bisexual"

/obj/structure/sign/flag/pride/lesbian
	name = "flag of Lesbian Pride"
	desc = "The flag of Lesbian Pride."
	icon_state = "flag_lesbian"
	sign_change_name = "Pride Flag - Lesbian"

/obj/structure/sign/flag/pride/pan
	name = "flag of Pansexual Pride"
	desc = "The flag of Pansexual Pride."
	icon_state = "flag_pan"
	sign_change_name = "Pride Flag - Pansexual"

/obj/structure/sign/flag/pride/trans
	name = "flag of Transgender Pride"
	desc = "The flag of Transgender Pride."
	icon_state = "flag_trans"
	sign_change_name = "Pride Flag - Transgender"

/obj/item/kirbyplants/random/dead
	icon = 'icons/obj/flora/plants.dmi'
	icon_state = "plant-25"

/obj/structure/broken_flooring
	name = "broken tiling"
	desc = "A segment of broken flooring."
	icon = 'icons/obj/fluff/brokentiling.dmi'
	icon_state = "corner"
	anchored = TRUE
	density = FALSE
	opacity = FALSE
	plane = FLOOR_PLANE
	layer = CATWALK_LAYER
	/// do we always have FLOOR_PLANE even if we arent on plating?
	var/always_floorplane = FALSE

/obj/structure/broken_flooring/Initialize(mapload)
	. = ..()
	return INITIALIZE_HINT_LATELOAD

/obj/structure/broken_flooring/LateInitialize()
	. = ..()
	var/turf/turf = get_turf(src)
	if(!isplatingturf(turf) && !always_floorplane) // Render as trash if not on plating
		plane = GAME_PLANE
		layer = LOW_OBJ_LAYER
		return
	for(var/obj/object in turf)
		if(object.flags_1 & INITIALIZED_1)
			SEND_SIGNAL(object, COMSIG_OBJ_HIDE, UNDERFLOOR_VISIBLE)
			CHECK_TICK

/obj/structure/broken_flooring/crowbar_act(mob/living/user, obj/item/I)
	I.play_tool_sound(src, 80)
	balloon_alert(user, "tile reclaimed")
	new /obj/item/stack/tile/iron(get_turf(src))
	qdel(src)
	return TRUE

/obj/structure/broken_flooring/singular
	icon_state = "singular"

/obj/structure/broken_flooring/singular/always_floorplane
	always_floorplane = TRUE

/obj/structure/broken_flooring/pile
	icon_state = "pile"

/obj/structure/broken_flooring/pile/always_floorplane
	always_floorplane = TRUE

/obj/structure/broken_flooring/side
	icon_state = "side"

/obj/structure/broken_flooring/side/always_floorplane
	always_floorplane = TRUE

/obj/structure/broken_flooring/corner
	icon_state = "corner"

/obj/structure/broken_flooring/corner/always_floorplane
	always_floorplane = TRUE

/obj/structure/broken_flooring/plating
	icon_state = "plating"

/obj/structure/broken_flooring/plating/always_floorplane
	always_floorplane = TRUE

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/broken_flooring/singular, 0)
MAPPING_DIRECTIONAL_HELPERS(/obj/structure/broken_flooring/pile, 0)
MAPPING_DIRECTIONAL_HELPERS(/obj/structure/broken_flooring/side, 0)
MAPPING_DIRECTIONAL_HELPERS(/obj/structure/broken_flooring/corner, 0)
MAPPING_DIRECTIONAL_HELPERS(/obj/structure/broken_flooring/plating, 0)
MAPPING_DIRECTIONAL_HELPERS(/obj/structure/broken_flooring/singular/always_floorplane, 0)
MAPPING_DIRECTIONAL_HELPERS(/obj/structure/broken_flooring/pile/always_floorplane, 0)
MAPPING_DIRECTIONAL_HELPERS(/obj/structure/broken_flooring/side/always_floorplane, 0)
MAPPING_DIRECTIONAL_HELPERS(/obj/structure/broken_flooring/corner/always_floorplane, 0)
MAPPING_DIRECTIONAL_HELPERS(/obj/structure/broken_flooring/plating/always_floorplane, 0)
