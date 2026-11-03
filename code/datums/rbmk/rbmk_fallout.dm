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
	weather_duration_lower = 5 MINUTES
	weather_duration_upper = 8 MINUTES
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
	/// Total deposits are bounded so the event cannot blanket every turf with emitters.
	var/deposits_created = 0
	var/max_deposits = 128
	COOLDOWN_DECLARE(deposition_cooldown)

/datum/weather/rbmk_fallout/start()
	. = ..()
	if(stage == MAIN_STAGE)
		START_PROCESSING(SSobj, src)

/datum/weather/rbmk_fallout/wind_down()
	STOP_PROCESSING(SSobj, src)
	return ..()

/datum/weather/rbmk_fallout/end()
	STOP_PROCESSING(SSobj, src)
	return ..()

/datum/weather/rbmk_fallout/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/** Settles radioactive debris around exposed rooms, including unoccupied ones. */
/datum/weather/rbmk_fallout/process(seconds_per_tick)
	if(stage != MAIN_STAGE || deposits_created >= max_deposits)
		return PROCESS_KILL
	if(!COOLDOWN_FINISHED(src, deposition_cooldown) || !length(impacted_areas) || !length(impacted_z_levels))
		return
	COOLDOWN_START(src, deposition_cooldown, 5 SECONDS)
	for(var/attempt in 1 to 4)
		if(deposits_created >= max_deposits)
			break
		var/area/exposed_area = pick(impacted_areas)
		var/list/area_turfs = exposed_area.get_turfs_by_zlevel(pick(impacted_z_levels))
		if(!length(area_turfs))
			continue
		deposit_fallout(pick(area_turfs))

/** Only exposed station floors may receive radioactive ash. */
/datum/weather/rbmk_fallout/proc/deposit_fallout(turf/target)
	if(deposits_created >= max_deposits || !istype(target, /turf/open/floor))
		return FALSE
	if(!(get_area(target) in impacted_areas) || !(target.z in impacted_z_levels))
		return FALSE
	if(locate(/obj/effect/decal/cleanable/rbmk_fallout) in target)
		return FALSE
	new /obj/effect/decal/cleanable/rbmk_fallout(target)
	deposits_created++
	return TRUE

/datum/weather/rbmk_fallout/weather_act(mob/living/affected_mob)
	SSradiation.irradiate(affected_mob)

/// Washable fallout remains radioactive after it settles, until cleaned or decayed.
/obj/effect/decal/cleanable/rbmk_fallout
	name = "radioactive ash"
	desc = "Fine radioactive debris from a breached reactor. It needs decontamination."
	icon = 'icons/obj/objects.dmi'
	icon_state = "ash"
	color = COLOR_PALE_GREEN_GRAY
	mergeable_decal = FALSE
	beauty = -50

/obj/effect/decal/cleanable/rbmk_fallout/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/radioactive_emitter, 10 SECONDS, 2, RAD_LIGHT_INSULATION, span_warning("Radioactive dust emits radiation into its surroundings."))
	QDEL_IN(src, 10 MINUTES)
