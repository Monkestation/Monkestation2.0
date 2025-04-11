/atom/movable/screen/parallax_layer/rifts
	icon = 'monkestation/code/modules/bloody_cult/icons/riftbox.dmi'
	icon_state = "rift"
	layer = 2
	speed = 0.5

/atom/movable/screen/parallax_layer/rifts/Initialize(mapload, mob/owner)
	. = ..()
	src.add_atom_colour(COLOR_CARP_RIFT_RED, ADMIN_COLOUR_PRIORITY)


SUBSYSTEM_DEF(hell_universe)
	name = "Hell Universe Processing"
	flags = SS_NO_INIT | SS_TICKER
	wait = LIGHTING_INTERVAL

	var/hell_time = FALSE
	var/old_starlight_color
	//var/list/turfs_to_process = list()
	var/list/lights_to_break = list()

/datum/controller/subsystem/hell_universe/proc/start_hell()
	hell_time = TRUE
	old_starlight_color = GLOB.starlight_color

	for(var/mob/dead/observer/observer in GLOB.player_list)
		observer.narsie_act()

	for(var/client/client in GLOB.clients)
		var/view = client.view || world.view
		client.parallax_layers_cached += new /atom/movable/screen/parallax_layer/rifts(null, client.mob)

		for(var/atom/movable/screen/parallax_layer/layer as anything in client.parallax_layers_cached)
			if(!istype(layer, /atom/movable/screen/parallax_layer/layer_1))
				continue
			layer.remove_atom_colour(ADMIN_COLOUR_PRIORITY, GLOB.starlight_color)
			layer.icon_state = "narsie"
			layer.update_o(view)
		client.mob.hud_used?.update_parallax_pref()

	GLOB.starlight_color = COLOR_BLOOD

	for(var/z in SSmapping.levels_by_trait(ZTRAIT_STATION))
		var/list/turfs = get_area_turfs(/area/space, z)
		for(var/turf/open/space/space in turfs)
			space.update_starlight()
			//turfs_to_process |= space

	for(var/datum/time_of_day/time in SSoutdoor_effects.time_cycle_steps)
		time.color = COLOR_BLOOD
	GLOB.GLOBAL_LIGHT_RANGE = 20

	for (var/atom/movable/screen/fullscreen/lighting_backdrop/sunlight/SP in SSoutdoor_effects.sunlighting_planes)
		SSoutdoor_effects.transition_sunlight_color(SP)

	for(var/obj/machinery/light/light_to_break in GLOB.machines)
		lights_to_break |= light_to_break

	SSoutdoor_effects.InitializeTurfs()

/datum/controller/subsystem/hell_universe/fire(resumed)
	if(!hell_time)
		return
	/*
	for(var/turf/open/space/space as anything in turfs_to_process)
		CHECK_TICK

		space.add_particles(PS_SPACE_RUNES)//visible for everyone
		space.adjust_particles(PVAR_SPAWNING, rand(5, 20)/1000 ,PS_SPACE_RUNES)
		turfs_to_process -= space
	*/

	for(var/obj/machinery/light/light_to_break in lights_to_break)
		if(QDELETED(light_to_break))
			lights_to_break -= light_to_break
			continue

		CHECK_TICK

		light_to_break.break_light_tube()
		lights_to_break -= light_to_break

	if(!length(lights_to_break))
		hell_time = FALSE

