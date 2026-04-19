/obj/item/ammo_box/magazine/paint_container
	name = "Paint Canister"
	desc = "A container for paint, dont know what else you would expect."
	icon_state = "9x19p"
	base_icon_state = "9x19p"
	ammo_type = /obj/item/ammo_casing/c10mm
	max_ammo = 1 //we contain a dummy casing that gets refilled by the gun
	multiple_sprites = AMMO_BOX_FULL_EMPTY
	multiple_sprite_use_base = TRUE
	///The color of paint stored within us
	var/stored_paint_color
	///How much paint is stored within us
	var/paint = 0
	///The maximum amount of paint we can have stored
	var/max_paint = 25

/obj/item/ammo_box/magazine/paint_container/Initialize(mapload, paint_color)
	stored_ammo += new /obj/item/ammo_casing/paint_dummy_casing(src)
	stored_paint_color = paint_color
	return ..()

/obj/item/ammo_box/magazine/paint_container/try_load(mob/living/user, obj/item/tool, silent, replace_spent)
	return

/obj/item/ammo_box/magazine/paint_container/top_off(load_type, starting, color)
	if(!color && !stored_paint_color)
		stored_paint_color = COLOR_WHITE
	paint = max_paint

/obj/item/ammo_box/magazine/paint_container/ammo_count(countempties)
	return paint

/obj/item/ammo_box/magazine/paint_container/empty_magazine()
	if(paint <= 0)
		return

	var/paint_left = paint - 1
	paint = 0
	var/turf/our_turf = get_turf(src)
	if(isspaceturf(our_turf))
		return

	our_turf.add_atom_colour(stored_paint_color, WASHABLE_COLOUR_PRIORITY)
	if(paint_left <= 0)
		return
	//if we have paint left then "spill" onto adjacent tiles
	for(var/cardinal_dir in GLOB.cardinals)
		var/turf/step_turf = get_step(src, cardinal_dir)
		if(isspaceturf(step_turf))
			continue

		paint_left--
		step_turf.add_atom_colour(stored_paint_color, WASHABLE_COLOUR_PRIORITY)
		if(paint_left <= 0)
			return

/obj/item/ammo_casing/paint_dummy_casing
	name = "paint casing"
	desc = "oops"
	slot_flags = null
	projectile_type = /obj/projectile/magic
	firing_effect_type = /obj/effect/temp_visual/dir_setting/firing_effect/magic
	heavy_metal = FALSE
