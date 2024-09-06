/datum/map_template/asteroid
	name = "Base Asteroid Template"
	///This is just a reminder, set the path will you? cant load what we cant find.
	//path =

	///X wise, where are we on the Cartesian Plane?
	var/x
	///Y wise, where are we on the Cartesian Plane?
	var/y
	///Have we found this astroid, but not yet summoned it?
	var/found
	///Have we already summoned this boi to the station?
	var/summoned
	///Radius, how big this boi? 7 is max, so 15x15 total!
	var/size = 7
	///How likely is this to generate? We'll assume a base weight of 100 if not defined.
	var/asteroid_weight
