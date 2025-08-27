#define TRAM_BOAT "tram_boat"
#define TRAM_BOAT_FORE "tram_boat_fore"
#define TRAM_BOAT_CENTRAL "tram_boat_central"
#define TRAM_BOAT_AFT "tram_boat_aft"

/obj/effect/landmark/lift_id/boat
	specific_lift_id = TRAM_BOAT

/obj/machinery/computer/tram_controls/boat
	specific_lift_id = TRAM_BOAT

/obj/effect/landmark/tram/boat/fore
	name = "Fore Boat Dock"
	specific_lift_id = TRAM_BOAT
	platform_code = TRAM_BOAT_FORE
	tgui_icons = list("Departures" = "plane-departure", "Science" = "flask")

/obj/effect/landmark/tram/boat/middle
	name = "Central Boat Dock"
	specific_lift_id = TRAM_BOAT
	platform_code = TRAM_BOAT_CENTRAL
	tgui_icons = list("Cargo" = "box")

/obj/effect/landmark/tram/boat/aft
	name = "Aft Boat Dock"
	specific_lift_id = TRAM_BOAT
	platform_code = TRAM_BOAT_AFT
	tgui_icons = list("Command" = "bullhorn")

/obj/structure/sign/collision_counter/boat
	name = "boating incident counter"
	desc = "A display that indicates how many boat related incidents have occured today."
	sign_change_name = "Indicator board- Boating incidents"

/obj/machinery/button/tram/boat/fore
	id = TRAM_BOAT_FORE
	lift_id = TRAM_BOAT

/obj/machinery/button/tram/boat/middle
	id = TRAM_BOAT_CENTRAL
	lift_id = TRAM_BOAT

/obj/machinery/button/tram/boat/aft
	id = TRAM_BOAT_AFT
	lift_id = TRAM_BOAT

#undef TRAM_BOAT
#undef TRAM_BOAT_AFT
#undef TRAM_BOAT_CENTRAL
#undef TRAM_BOAT_FORE
