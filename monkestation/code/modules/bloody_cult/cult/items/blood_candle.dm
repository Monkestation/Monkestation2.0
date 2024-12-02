/obj/item/candle/blood
	name = "blood candle"
	desc = "A candle made out of blood moth wax, burns much longer than regular candles. Used for moody lighting and occult rituals."
	icon = 'monkestation/code/modules/bloody_cult/icons/candle.dmi'
	icon_state = "bloodcandle"
	food_candle = "foodbloodcandle"
	color = null

	wax = 3600 // 60 minutes
	trashtype = /obj/item/trash/blood_candle

/obj/item/candle/blood/get_cult_power()
	return 1

/obj/item/candle/blood/update_icon()
	. = ..()
	overlays.len = 0
	if (wax == initial(wax))
		icon_state = "bloodcandle"
	else
		var/i
		if(wax > 2400)
			i = 1
		else if(wax > 1200)
			i = 2
		else i = 3
		icon_state = "bloodcandle[i]"
	if (lit)
		var/image/I = image(icon, src, "[icon_state]_lit")
		I.blend_mode = BLEND_ADD
		if (isturf(loc))
			I.plane = ABOVE_LIGHTING_PLANE
		else
			I.plane = ABOVE_HUD_PLANE // inventory
		overlays += I

/obj/item/trash/blood_candle
	name = "blood candle"
	desc = "A candle made out of blood moth wax, burns much longer than regular candles. Used for moody lighting and occult rituals."
	icon = 'monkestation/code/modules/bloody_cult/icons/candle.dmi'
	icon_state = "bloodcandle4"
