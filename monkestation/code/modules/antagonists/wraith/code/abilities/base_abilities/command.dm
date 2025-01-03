/datum/action/cooldown/spell/pointed/wraith/command
	name = "Command"
	desc = "Hurl any nearby objects at your target."
	button_icon_state = "command"

	essence_cost = 50
	cooldown_time = 20 SECONDS

/datum/action/cooldown/spell/pointed/wraith/command/before_cast(atom/cast_on)
	. = ..()
	if(!isturf(cast_on) && !ismob(cast_on) && !isitem(cast_on))
		. |= SPELL_CANCEL_CAST

/datum/action/cooldown/spell/pointed/wraith/command/cast(turf/cast_on)
	. = ..()
	if(!istype(cast_on))
		cast_on = get_turf(cast_on)

	for(var/obj/item/item in orange(5, cast_on)) // Its not anything complex
		if(item.anchored)
			continue

		INVOKE_ASYNC(src, PROC_REF(throw_item), cast_on, item)
		if(prob(30))
			break

/datum/action/cooldown/spell/pointed/wraith/command/proc/throw_item(turf/location, obj/item/item)
	var/item_color = item.color
	animate(item, pixel_y = item.pixel_y + 8, time = 0.5 SECONDS, color = COLOR_DARK_PURPLE)
	sleep(0.5 SECONDS)
	item.throw_at(location, 5, 1)
	item.pixel_y -= 8
	item.color = item_color
