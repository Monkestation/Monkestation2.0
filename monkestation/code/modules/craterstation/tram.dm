// Tram related code for craterstation

/obj/effect/landmark/tram/crater
	name = "craterstation tram landmark"

/obj/effect/landmark/tram/crater/arrivals
	specific_lift_id = "CRATER_ARRIVALS"

/obj/effect/landmark/tram/crater/arrivals/dock
	name = "Arrivals Dock"
	platform_code = "CRATER_ARRIVALS_DOCK"
	tgui_icons = list("Arrivals" = "plane-arrival")

/obj/effect/landmark/tram/crater/arrivals/main
	name = "Crater Outpost Station"
	platform_code = "CRATER_ARRIVALS_STATION"
	tgui_icons = list("Crater Outpost" = "wrench")

/obj/effect/landmark/tram/crater/ordnance
	specific_lift_id = "CRATER_ORDNANCE"

/obj/effect/landmark/tram/crater/ordnance/rnd
	name = "Crater Outpost Ordnance Research"
	platform_code = "CRATER_ORDNANCE_RND"
	tgui_icons = list("Research Facilities" = "flask")

/obj/effect/landmark/tram/crater/ordnance/testing_site
	name = "Ordnance Test Site"
	platform_code = "CRATER_ORDNANCE_TEST"
	tgui_icons = list("Bomb Test Site (WARNING)" = "bullseye")

/obj/structure/industrial_lift/tram/catwalk
	icon = 'icons/obj/smooth_structures/catwalk.dmi'
	icon_state = "catwalk-0"
	base_icon_state = "catwalk"

/obj/effect/landmark/tram/crater/evac
	specific_lift_id = "CRATER_DEPARTURES"

/obj/effect/landmark/tram/crater/evac/station
	name = "Crater Outpost Tunnel Network"
	platform_code = "CRATER_DEPARTURES_STATION"
	tgui_icons = list("Crater Outpost" = "wrench")

/obj/effect/landmark/tram/crater/evac/dock
	name = "Departures"
	platform_code = "CRATER_DEPARTURES_DOCK"
	tgui_icons = list("Departures" = "plane-departure", "Auxiliary Freight Spaceport" = "box")

/obj/effect/landmark/tram/crater/dumbwaiter
	specific_lift_id = "CRATER_DUMBWAITER"

/obj/effect/landmark/tram/crater/dumbwaiter/botany
	name = "Hothouse Loading Zone"
	platform_code = "CRATER_DUMBWAITER_BOTANY"

/obj/effect/landmark/tram/crater/dumbwaiter/kitchen
	name = "Kitchen"
	platform_code = "CRATER_DUMBWAITER_KITCHEN"
