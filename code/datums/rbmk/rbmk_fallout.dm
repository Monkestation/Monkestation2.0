/**
 * Temporary radioactive fallout caused by an RBMK meltdown.
 *
 * Affects exposed mobs in station areas while leaving designated shelters safe.
 */
/datum/weather/rbmk_fallout
	name = "reactor fallout"
	desc = "Airborne radioactive debris contaminates exposed station areas after an RBMK reactor meltdown."
	telegraph_duration = 0 SECONDS
	telegraph_message = null
	weather_message = "<span class='userdanger'><i>Radioactive ash fills the air! Find shielded shelter!</i></span>"
	weather_overlay = "light_ash"
	weather_duration_lower = 1 MINUTES
	weather_duration_upper = 2.5 MINUTES
	weather_color = COLOR_GREEN
	weather_sound = 'sound/rbmk/falloutwind.ogg'
	end_duration = 10 SECONDS
	end_message = "<span class='notice'>The radioactive ash thins and settles, but the breached reactor remains dangerously radioactive.</span>"
	area_type = /area/station
	protected_areas = list(
		/area/station/ai_monitored/turret_protected/aisat/maint,
		/area/station/maintenance,
		/area/station/security/prison/safe,
		/area/station/security/prison/toilet,
	)
	immunity_type = TRAIT_RADSTORM_IMMUNE

/datum/weather/rbmk_fallout/weather_act(mob/living/affected_mob)
	SSradiation.irradiate(affected_mob)
