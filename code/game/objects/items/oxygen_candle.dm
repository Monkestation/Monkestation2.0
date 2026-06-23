#define OXY_CANDLE_RELEASE_TEMP (T20C + 20) // 40 celsius, it's hot. Will be even hotter with hotspot expose

/obj/item/oxygen_candle
	name = "oxygen candle"
	desc = "A steel tube with the words 'OXYGEN - PULL CORD TO IGNITE' stamped on the side.\nA small label reads <span class='warning'>'WARNING: NOT FOR LIGHTING USE. WILL IGNITE FLAMMABLE GASSES'</span>"
	icon = 'icons/obj/atmospherics/oxygen_candle.dmi'
	icon_state = "oxycandle"
	base_icon_state = "oxycandle"
	grind_results = list(/datum/reagent/sodium = 5, /datum/reagent/chlorine = 5, /datum/reagent/iron = 10, /datum/reagent/oxygen = 30)
	w_class = WEIGHT_CLASS_SMALL
	light_on = FALSE
	light_color = LIGHT_COLOR_LAVA // Very warm chemical burn
	light_system = OVERLAY_LIGHT
	light_outer_range = 2
	heat = 1000
	var/pulled = FALSE
	/// how long does this burn for?
	var/fuel = 1 MINUTE
	var/oxygen_amount = 10
	var/on_damage = 6
	pressure_resistance = 10
	/// If the cord is pulled and we are active
	var/pulled = FALSE
	/// how long does this burn for?
	var/fuel = 1 MINUTE
	/// Amount of oxygen per second
	var/oxygen_amount = 10
	/// Damage after ignition, note damtype is BURN
	var/on_damage = 6


/obj/item/oxygen_candle/attack(mob/living/carbon/victim, mob/living/carbon/user)
	if(!isliving(victim))
		return ..()

	if(pulled && victim.ignite_mob())
		message_admins("[ADMIN_LOOKUPFLW(user)] set [key_name_admin(victim)] on fire with [src] at [AREACOORD(user)]")
		user.log_message("set [key_name(victim)] on fire with [src]", LOG_ATTACK)

	return ..()

/obj/item/oxygen_candle/attack_self(mob/user)
	. = ..()
	if(pulled)
		return
	playsound(src, 'sound/effects/fuse.ogg', 75, 1)
	balloon_alert(user, "cord pulled")
	icon_state = "[base_icon_state]_burning"
	pulled = TRUE
	START_PROCESSING(SSobj, src)
	set_light_on(TRUE)
	name = "lit [initial(name)]"
	attack_verb_continuous = string_list(list("burns", "singes"))
	attack_verb_simple = string_list(list("burn", "singe"))
	hitsound = 'sound/items/welder.ogg'
	force = on_damage
	damtype = BURN

/obj/item/oxygen_candle/process(seconds_per_tick)
	var/turf/my_turf = get_turf(src)
	if(!my_turf)
		return
	my_turf.hotspot_expose(500, 100)
	my_turf.atmos_spawn_air("o2=[oxygen_amount];TEMP=[OXY_CANDLE_RELEASE_TEMP]")
	fuel = fuel - seconds_per_tick * (1 SECONDS)
	if(fuel > 0)
		return
	set_light_on(FALSE)
	name = "burnt [initial(name)]"
	icon_state = "[base_icon_state]_burnt"
	desc += "\nThis tube has exhausted its chemicals."
	playsound(src, 'sound/effects/space_wind.ogg', 70, TRUE)
	attack_verb_continuous = initial(attack_verb_continuous)
	attack_verb_simple = initial(attack_verb_simple)
	hitsound = initial(hitsound)
	force = initial(force)
	damtype = initial(damtype)
	STOP_PROCESSING(SSobj, src)

/obj/item/oxygen_candle/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/item/oxygen_candle/large
	name = "large oxygen candle"
	icon_state = "oxycandle_large"
	base_icon_state = "oxycandle_large"
	grind_results = list(/datum/reagent/sodium = 10, /datum/reagent/chlorine = 10, /datum/reagent/iron = 20, /datum/reagent/oxygen = 60)
	light_color = LIGHT_COLOR_BABY_BLUE
	fuel = 5 MINUTES
	oxygen_amount = 30
	on_damage = 12

#undef OXY_CANDLE_RELEASE_TEMP
