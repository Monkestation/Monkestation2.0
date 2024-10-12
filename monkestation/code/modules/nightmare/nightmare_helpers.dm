#define PASSIVE_SNUFF_LIMIT 0.5

/// Handles checking for nearby weak lights to auto-snuff as a nightmare. Start turf arg is optional and can be any atom, it'll just have get_turf called on it.
/proc/check_passive_nightmare_snuff(mob/living/carbon/nightmare, turf/start)
	if(!istype(nightmare))
		return

	if(!istype(start))
		start = get_turf(start || nightmare)

	if(!istype(start)) // Really? How did you even... whatever, just ignore it.
		return

	var/lumcount = start.get_lumcount()
	if(lumcount < SHADOW_SPECIES_LIGHT_THRESHOLD || lumcount > PASSIVE_SNUFF_LIMIT)
		return

	var/obj/item/organ/internal/heart/nightmare/heart = nightmare.get_organ_slot(ORGAN_SLOT_HEART)

	if(!istype(heart) || !heart.blade)
		return

	var/snuffed_something = FALSE

	for(var/atom/nearby as anything in view(2, start))
		if(!nearby.light)
			continue

		if(istype(nearby, /obj/machinery/light))
			var/obj/machinery/light/light_fixture = nearby
			if(!light_fixture.low_power_mode) // prevents an issue where nightmares could just turn on a fire alarm to obliterate lights
				continue

		var/hsl = rgb2num(nearby.light_color, COLORSPACE_HSL)
		if(nearby.light_power * (hsl[3] / 100) > 0.8) // power * lightness is a pretty good measure of "how bright is this thing"
			return

		SEND_SIGNAL(heart.blade, COMSIG_LIGHT_EATER_EAT, nearby, heart.blade, TRUE)
		snuffed_something = TRUE

	if(!snuffed_something)
		return

	nightmare.visible_message(
		message = span_danger("Something dark in [heart.blade] lashes out at nearby lights!"),
		self_message = span_notice("Your [heart.blade.name] lashes out at nearby lights!"),
		blind_message = span_danger("You feel a gnawing pulse eat at your sight.")
	)

#undef PASSIVE_SNUFF_LIMIT
