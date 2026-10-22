/*
* Only put an area here if it wouldn't fit sorting criteria
* If more areas are created of an area in this file, please
* make a new file for it!
*/

/*
* This is the ROOT for all station areas
* It keeps the work tree in SDMM nice and pretty :)
*/
/area/station
	name = "Station Areas"
	icon = 'icons/area/areas_station.dmi'
	icon_state = "station"

/*
* Tramstation unique areas
*/

/area/station/escapepodbay
	name = "\improper Pod Bay"
	icon_state = "podbay"

/area/station/asteroid
	name = "\improper Station Asteroid"
	icon_state = "station_asteroid"
	always_unpowered = TRUE
	power_environ = FALSE
	power_equip = FALSE
	power_light = FALSE
	requires_power = TRUE
	ambience_index = AMBIENCE_MINING
	outdoors = TRUE

/area/station/asteroid/tram/pet
	name = "\improper Pet Sanctuary"

/area/station/asteroid/tram/cargo
	name = "\improper Cargo Meadow"

/area/station/asteroid/tram/security
	name = "\improper Security Meadow"

/area/station/asteroid/tram/dorms
	name = "\improper Dorm Meadow"

/area/station/asteroid/tram/science
	name = "\improper Science Meadow"

/area/station/asteroid/tram/junction/east
	name = "\improper Eastern Tram Junction"

/area/station/asteroid/tram/junction/west
	name = "\improper Western Tram Junction"
