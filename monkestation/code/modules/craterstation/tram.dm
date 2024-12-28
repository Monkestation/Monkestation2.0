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


/obj/effect/landmark/tram/crater/sec
	specific_lift_id = "CRATER_PRISON"
/obj/effect/landmark/tram/crater/sec/prison
	name = "Prison"
	platform_code = "CRATER_PRISON"
	tgui_icons = list("Prison" = "gavel")

/obj/effect/landmark/tram/crater/sec/processing
	name = "Processing Facility"
	platform_code = "CRATER_PROCESSING"
	tgui_icons = list("Processing Area" = "bullhorn")
