/mob/living/basic/bot/mulebot/proc/set_cell_hud()
	var/image/holder = hud_list[DIAG_BATT_HUD]
	holder.pixel_z = get_cached_height() - world.icon_size
	if(!has_power())
		holder.icon_state = "hudnobatt"
		return

	var/datum/hud/living/mulebot/mule_hud = hud_used
	mule_hud?.charge_hud?.calculate_charge()
	holder.icon_state = "hudbatt[RoundDiagBar(cell.charge/cell.maxcharge)]"

/atom/movable/screen/mob_charge
	icon = 'icons/obj/power.dmi'
	icon_state = "ccharger"
	screen_loc = ui_stamina
	///used to find the overlay for charger icon
	var/current_charge_level = 4
	///dynamic, based on what cell our nulebot's using
	var/image/battery_overlay
	///maptext that displays charge in numbers
	var/image/charge_overlay
	///is there a mouse on us
	var/hovering = FALSE

/atom/movable/screen/mob_charge/proc/update_battery_overlay(atom/target_battery)
	var/obj/item/stock_parts/power_store/cell/my_cell = target_battery || (locate() in get_mob())
	if(isnull(my_cell))
		battery_overlay = null
	else
		battery_overlay = image(icon = my_cell.icon, icon_state = my_cell.icon_state, loc = src, layer = src.layer + 0.1)
	update_appearance(UPDATE_ICON)

/atom/movable/screen/mob_charge/proc/calculate_charge()
	var/obj/item/stock_parts/power_store/cell/my_battery = locate() in get_mob()
	var/charge_value = isnull(my_battery) ? 0 : round(my_battery.charge/my_battery.maxcharge * 100 , 1)
	current_charge_level = round(charge_value * 4 / 100)
	charge_overlay.maptext = MAPTEXT("<div align='center' valign='middle' style='position:relative'>[charge_value]%</div>")
	update_appearance(UPDATE_ICON)

/atom/movable/screen/mob_charge/New(loc, ...)
	. = ..()
	charge_overlay = image(loc = src, layer = src.layer+0.2, pixel_y = -5)
	update_battery_overlay()

/atom/movable/screen/mob_charge/Destroy()
	charge_overlay = null
	battery_overlay = null
	return ..()

/atom/movable/screen/mob_charge/update_overlays()
	. = ..()
	. += mutable_appearance(icon, "ccharger-o[current_charge_level]")
	if(battery_overlay)
		. |= battery_overlay
	if(hovering)
		. |= charge_overlay

/atom/movable/screen/mob_charge/MouseEntered(location,control,params)
	if(usr != get_mob())
		return
	. = ..()
	hovering = TRUE
	calculate_charge()

/atom/movable/screen/mob_charge/MouseExited(location, control, params)
	if(usr != get_mob())
		return
	. = ..()
	hovering = FALSE
	update_appearance(UPDATE_ICON)

/datum/hud/living/mulebot
	///the charge display of our mulebot
	var/atom/movable/screen/mob_charge/charge_hud

/datum/hud/living/mulebot/New(mob/living/owner)
	. = ..()
	charge_hud = new(null, src)
	infodisplay += charge_hud

/datum/hud/living/mulebot/Destroy()
	charge_hud = null
	return ..()
