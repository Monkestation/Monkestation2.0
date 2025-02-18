/obj/machinery/computer/cargo/express
	///If set then our default landing area will be set to here instead of cargo
	var/area/landingzone_override

/obj/machinery/computer/cargo/express/byos
	landingzone_override = /area/station/byos_start_area/cargo_landing_area

/obj/machinery/computer/cargo/express/byos_syndicate
	landingzone_override = /area/station/byos_start_area/syndicate_cargo_landing_area
