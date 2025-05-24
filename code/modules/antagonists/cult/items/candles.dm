/obj/item/candle
	name = "candle"
	desc = "A candle made out of wax, used for moody lighting and solar flares."
	icon = 'monkestation/code/modules/bloody_cult/icons/candle.dmi'
	icon_state = "candle"
	heat = 1000
	var/food_candle = "foodcandle"
	w_class = WEIGHT_CLASS_TINY
	light_color = LIGHT_COLOR_FIRE
	color = COLOR_OFF_WHITE

	var/wax = 1800 // 30 minutes
	var/lit = 0
	var/trashtype = /obj/item/trash/candle
	var/image/wick
	var/flickering = 0

/obj/item/candle/New(turf/loc)
	..()
	wick = image(icon, src, "candle-wick")
	wick.appearance_flags = RESET_COLOR
	update_icon()

/obj/item/candle/Initialize(mapload)
	. = ..()
	if (lit)//pre-mapped lit candles
		lit = 0
		light("", TRUE)

/obj/item/candle/extinguish()
	..()
	if(lit)
		lit = 0
		update_icon()
		set_light(0)
		remove_particles(PS_CANDLE)
		remove_particles(PS_CANDLE2)

/obj/item/candle/update_icon()
	. = ..()
	overlays.len = 0
	if (wax == initial(wax))
		icon_state = "candle"
	else
		var/i
		if(wax > 1200)
			i = 1
		else if(wax > 600)
			i = 2
		else i = 3
		icon_state = "candle[i]"
	wick.icon_state = "[icon_state]-wick"
	overlays += wick
	if (lit)
		var/image/I = image(icon, src, "[icon_state]_lit")
		I.appearance_flags = RESET_COLOR
		I.blend_mode = BLEND_ADD
		if (isturf(loc))
			I.plane = ABOVE_LIGHTING_PLANE
		else
			I.plane = ABOVE_HUD_PLANE // inventory
		overlays += I

/obj/item/candle/dropped()
	..()
	update_icon()

/obj/item/candle/attackby(obj/item/W, mob/user, params)
	..()
	if (lit && heat)
		if (istype(W, /obj/item/candle))
			var/obj/item/candle/C = W
			C.light(span_notice("[user] lights [C] with [src].") )
		else if (istype(W, /obj/item/clothing/mask/cigarette))
			var/obj/item/clothing/mask/cigarette/ciggy = W
			ciggy.light(span_notice("[user] lights \the [ciggy] using \the [src]'s flame.") )
	if(W.heat)
		light(span_notice("[user] lights [src] with [W].") )

/obj/item/candle/proc/light(flavor_text = span_notice("[usr] lights [src].") , quiet = 0)
	if(!lit)
		lit = 1
		if(!quiet)
			visible_message(flavor_text)
		set_light(0.7)
		add_particles(PS_CANDLE)
		add_particles(PS_CANDLE2)
		START_PROCESSING(SSobj, src)
		update_icon()

/obj/item/candle/proc/flicker(amount = rand(5, 15))
	if(flickering)
		return
	flickering = 1
	if(lit)
		for(var/i = 0; i < amount; i++)
			if(prob(95))
				if(prob(30))
					extinguish()
				else
					var/candleflick = pick(0.5, 0.7, 0.9, 1, 1.3, 1.5, 2)
					set_light(candleflick * 0.7)
			else
				set_light(5 * 0.7)
				if(heat == 0) //only holocandles don't have source temp, using this so I don't add a new var
					wax = 0.8 * wax //jury rigged so the wax reduction doesn't nuke the holocandles if flickered
				visible_message(span_warning("\The [src]'s flame starts roaring unnaturally!") )
			update_icon()
			sleep(rand(5, 8))
			set_light(1)
			lit = 1
			update_icon()
			flickering = 0

/obj/item/candle/attack_ghost(mob/user)
	add_hiddenprint(user)
	flicker(1)

/obj/item/candle/process()
	if(!lit)
		return
	wax--
	if(!wax)
		new trashtype(src.loc, src)
		if(istype(src.loc, /mob))
			src.dropped()
		qdel(src)
		return
	update_icon()

/obj/item/candle/attack_self(mob/user as mob)
	if(lit)
		extinguish()
		to_chat(user, span_warning("You pinch \the [src]'s wick.") )



/obj/item/candle/Entered(atom/movable/arrived, atom/old_loc, list/atom/old_locs)
	. = ..()
	if(istype(arrived, /obj/projectile/beam))
		var/obj/projectile/beam/P = arrived//could be a laser beam or an emitter beam, both feature the get_damage() proc, for now...
		if(P.damage >= 5)
			light("", 1)

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
