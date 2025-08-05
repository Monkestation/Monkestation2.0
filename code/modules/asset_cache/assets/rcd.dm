/datum/asset/spritesheet_batched/rcd
	name = "rcd-tgui"

/datum/asset/spritesheet_batched/rcd/create_spritesheets()
	//We load airlock icons seperatly from other icons cause they need overlays

	//load all category essential icon_states. format is icon_file = list of icon states we need from that file
	var/list/essentials = list(
		'icons/obj/chairs.dmi' = list("bar"),
		'icons/obj/firealarm.dmi' = list("fire_bitem"),
		'icons/obj/lighting.dmi' = list("floodlight_c1"),
		'icons/obj/monitors.dmi' = list("alarm_bitem"),
		'icons/obj/wallframe.dmi' = list("apc"),
		'icons/obj/stock_parts.dmi' = list("box_1"),
		'icons/obj/objects.dmi' = list("bed"),
		'icons/obj/smooth_structures/catwalk.dmi' = list("catwalk-0"),
		'icons/hud/radial.dmi' = list("cnorth", "csouth", "ceast", "cwest", "chair", "secure_windoor", "stool", "wallfloor", "windowsize", "windowtype", "windoor"),
		'icons/obj/structures.dmi' = list("glass_table", "rack", "reflector_base", "table", "girder"),
		'monkestation/icons/obj/structures/window/window.dmi' = list("window-0"),
		'monkestation/icons/obj/structures/window/reinforced_window.dmi' = list("reinforced_window-0"),
		'monkestation/icons/obj/structures/window/window_sill.dmi' = list("window_sill-0"),
	)

	var/datum/universal_icon/icon
	for(var/icon_file as anything in essentials)
		for(var/icon_state as anything in essentials[icon_file])
			icon = uni_icon(icon_file, icon_state)
			if(icon_state == "window-0" || icon_state == "reinforced_window-0")
				icon.blend_color("#305a6d", ICON_MULTIPLY)
				icon.blend_icon(uni_icon('monkestation/icons/obj/structures/window/grille.dmi', "grille-0"), ICON_UNDERLAY)
			insert_icon(sanitize_css_class_name(icon_state), icon)

	//for each airlock type we create its overlayed version with the suffix Glass in the sprite name
	var/list/airlocks = list(
		"Standard" = 'icons/obj/doors/airlocks/station/public.dmi',
		"Public" = 'icons/obj/doors/airlocks/station2/glass.dmi',
		"Engineering" = 'icons/obj/doors/airlocks/station/engineering.dmi',
		"Atmospherics" = 'icons/obj/doors/airlocks/station/atmos.dmi',
		"Security" = 'icons/obj/doors/airlocks/station/security.dmi',
		"Command" = 'icons/obj/doors/airlocks/station/command.dmi',
		"Medical" = 'icons/obj/doors/airlocks/station/medical.dmi',
		"Research" = 'icons/obj/doors/airlocks/station/research.dmi',
		"Freezer" = 'icons/obj/doors/airlocks/station/freezer.dmi',
		"Pathology" = 'icons/obj/doors/airlocks/station/virology.dmi',
		"Mining" = 'icons/obj/doors/airlocks/station/mining.dmi',
		"Maintenance" = 'icons/obj/doors/airlocks/station/maintenance.dmi',
		"External" = 'icons/obj/doors/airlocks/external/external.dmi',
		"External Maintenance" = 'icons/obj/doors/airlocks/station/maintenanceexternal.dmi',
		"Airtight Hatch" = 'icons/obj/doors/airlocks/hatch/centcom.dmi',
		"Maintenance Hatch" = 'icons/obj/doors/airlocks/hatch/maintenance.dmi'
	)
	//these 3 types dont have glass doors
	var/list/exclusion = list("Freezer", "Airtight Hatch", "Maintenance Hatch")

	for(var/airlock_name in airlocks)
		//solid door with overlay
		icon = uni_icon(airlocks[airlock_name], "closed", SOUTH)
		if(icon_exists(airlocks[airlock_name], "fill_closed"))
			icon.blend_icon(uni_icon(airlocks[airlock_name], "fill_closed", SOUTH), ICON_OVERLAY)
		insert_icon(sanitize_css_class_name(airlock_name), icon)

		//exclude these glass types
		if(airlock_name in exclusion)
			continue

		//glass door no overlay
		icon = uni_icon(airlocks[airlock_name], "closed", SOUTH)
		insert_icon(sanitize_css_class_name("[airlock_name]Glass"), icon)
