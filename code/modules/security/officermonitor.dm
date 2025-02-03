/obj/item/sensor_device/brigdoc
	name = "brig physician's handheld monitor"
	desc = "A specialised model of handheld crew monitor, configured to only security."
	icon = 'icons/obj/device.dmi'
	icon_state = "scanner"
	inhand_icon_state = "electronic"
	worn_icon_state = "electronic"
	lefthand_file = 'icons/mob/inhands/items/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items/devices_righthand.dmi'
	w_class = WEIGHT_CLASS_SMALL
	slot_flags = ITEM_SLOT_BELT

/obj/item/sensor_device/brigdoc/attack_self(mob/user)
	GLOB.security_crewmonitor.show(user,src)

///Modified and referenced from crew.dm and blueshield's crew_monitor.dm
#define SENSORS_UPDATE_PERIOD (10 SECONDS)

GLOBAL_DATUM_INIT(security_crewmonitor, /datum/crewmonitor/security, new)

//list of all sec jobs + prisoners
/datum/crewmonitor/security
	var/list/jobs_security = list(
		JOB_HEAD_OF_SECURITY = 10,
		JOB_WARDEN = 11,
		JOB_SECURITY_OFFICER = 12,
		JOB_SECURITY_OFFICER_MEDICAL = 13,
		JOB_SECURITY_OFFICER_ENGINEERING = 14,
		JOB_SECURITY_OFFICER_SCIENCE = 15,
		JOB_SECURITY_OFFICER_SUPPLY = 16,
		JOB_DETECTIVE = 17,
		JOB_SECURITY_ASSISTANT = 18,
		JOB_BRIG_PHYSICIAN = 19,
		JOB_PRISONER = 998,
	)
/datum/crewmonitor/security/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if (!ui)
		ui = new(user, src, "CrewConsoleNova")///Hopefully the same ui as regular monitors
		ui.open()
/datum/crewmonitor/security/update_data(z)
	if(data_by_z["[z]"] && last_update["[z]"] && world.time <= last_update["[z]"] + SENSORS_UPDATE_PERIOD)
		return data_by_z["[z]"]
	var/nt_net = GLOB.crewmonitor.get_ntnet_wireless_status(z)

	var/list/results = list()
	for(var/tracked_mob in GLOB.suit_sensors_list | GLOB.nanite_sensors_list)
		var/sensor_mode = GLOB.crewmonitor.get_tracking_level(tracked_mob, z, nt_net)
		if (sensor_mode == SENSOR_OFF)
			continue
		var/mob/living/tracked_living_mob = tracked_mob
		var/list/entry = list()

		var/obj/item/card/id/id_card = tracked_living_mob.get_idcard(hand_first = FALSE)
		if (id_card)
			entry["name"] = id_card.registered_name
			entry["assignment"] = id_card.assignment
			var/trim_assignment = id_card.get_trim_assignment()
			//check if they're security
			if (jobs_security[trim_assignment] != null)
				entry["ijob"] = jobs_security[trim_assignment]
			else
				continue

			if (isipc(tracked_living_mob))
				entry["is_robot"] = TRUE
			if (sensor_mode >= SENSOR_LIVING)
				entry["life_status"] = (tracked_living_mob.stat != DEAD)
			if (sensor_mode >= SENSOR_VITALS)
				entry += list(
					"oxydam" = round(tracked_living_mob.getOxyLoss(), 1),
					"toxdam" = round(tracked_living_mob.getToxLoss(), 1),
					"burndam" = round(tracked_living_mob.getFireLoss(), 1),
					"brutedam" = round(tracked_living_mob.getBruteLoss(), 1),
					"health" = round(tracked_living_mob.health, 1),
				)
			if (sensor_mode >= SENSOR_COORDS)
				entry["area"] = get_area_name(tracked_living_mob, format_text = TRUE)

			entry["can_track"] = tracked_living_mob.can_track()
		else
			continue
		results[++results.len] = entry
	data_by_z["[z]"] = results
	last_update["[z]"] = world.time
	return results
#undef SENSORS_UPDATE_PERIOD
