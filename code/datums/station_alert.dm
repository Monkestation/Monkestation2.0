/datum/station_alert
	/// Holder of the datum
	var/holder
	/// List of all alarm types we are listening to
	var/list/alarm_types
	/// Listens for alarms, provides the alarms list for our UI
	var/datum/alarm_listener/listener
	/// Title of our UI
	var/title
	/// If UI will also show and allow jumping to cameras connected to each alert area
	var/camera_view

/datum/station_alert/ui_host(mob/user)
	return holder

/datum/station_alert/New(holder, list/alarm_types, list/listener_z_level, list/listener_areas, title = "Station Alerts", camera_view = FALSE)
	src.holder = holder
	src.alarm_types = alarm_types
	src.title = title
	src.camera_view = camera_view
	listener = new(alarm_types, listener_z_level, listener_areas)

/datum/station_alert/Destroy()
	QDEL_NULL(listener)
	return ..()

/datum/station_alert/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "StationAlertConsole", title)
		ui.open()

/datum/station_alert/ui_data(mob/user)
	var/list/data = list()
	data["cameraView"] = camera_view
	data["alarms"] = list()
	var/list/nominal_types = alarm_types.Copy()
	var/list/alarms = listener.alarms
	for(var/alarm_type in alarms)
		var/list/alarm_category = list(
			"name" = alarm_type,
			"alerts" = list(),
		)
		var/list/alerts = alarms[alarm_type]
		for(var/alert in alerts)
			var/list/alert_details = alerts[alert]
			alarm_category["alerts"] += list(list(
				"name" = get_area_name(alert_details[1], TRUE),
				"cameras" = camera_view ? length(alert_details[2]) : null,
				"sources" = camera_view ? length(alert_details[3]) : null,
				"ref" = camera_view ? REF(alert) : null,
			))
		data["alarms"] += list(alarm_category)
		nominal_types -= alarm_type
	if(length(nominal_types))
		for(var/nominal_type in nominal_types)
			var/list/nominal_category = list(
				"name" = nominal_type,
				"alerts" = list(),
			)
			data["alarms"] += list(nominal_category)
	return data


