/obj/item/reagent_containers/cup/maunamug
	name = "mauna mug"
	desc = "A drink served in a classy mug. Now with built-in heating!"
	icon = 'icons/obj/mauna_mug.dmi'
	icon_state = "maunamug"
	base_icon_state = "maunamug"
	spillable = TRUE
	reagent_flags = OPENCONTAINER
	fill_icon_state = "maunafilling"
	fill_icon_thresholds = list(25)
	var/obj/item/stock_parts/power_store/cell/cell
	var/open = FALSE
	var/on = FALSE

/obj/item/reagent_containers/cup/maunamug/Initialize(mapload, vol)
	. = ..()
	cell = new /obj/item/stock_parts/power_store/cell(src)

/obj/item/reagent_containers/cup/maunamug/get_cell()
	return cell

/obj/item/reagent_containers/cup/maunamug/examine(mob/user)
	. = ..()
	. += span_notice("The status display reads: Current temperature: <b>[reagents.chem_temp]K</b> Current Charge:[cell ? "[cell.charge / cell.maxcharge * 100]%" : "No cell found"].")
	if(open)
		. += span_notice("The battery case is open.")
	if(cell && cell.charge > 0)
		. += span_notice("<b>Ctrl+Click</b> to toggle the power.")

/obj/item/reagent_containers/cup/maunamug/process(seconds_per_tick)
	..()
	if(on && (!cell || cell.charge <= 0)) //Check if we ran out of power
		change_power_status(FALSE)
		return FALSE
	cell.use(5 * seconds_per_tick) //Basic cell goes for like 200 seconds, bluespace for 8000
	if(!reagents.total_volume)
		return FALSE
	var/max_temp = min(500 + (500 * (0.2 * cell.rating)), 1000) // 373 to 1000
	reagents.adjust_thermal_energy(0.4 * cell.maxcharge * reagents.total_volume * seconds_per_tick, max_temp = max_temp) // 4 kelvin every tick on a basic cell. 160k on bluespace
	reagents.handle_reactions()
	update_appearance()
	if(reagents.chem_temp >= max_temp)
		change_power_status(FALSE)
		audible_message(span_notice("The Mauna Mug lets out a happy beep and turns off!"))
		playsound(src, 'sound/machines/chime.ogg', 50)

/obj/item/reagent_containers/cup/maunamug/Destroy()
	if(cell)
		QDEL_NULL(cell)
	STOP_PROCESSING(SSobj, src)
	. = ..()

/obj/item/reagent_containers/cup/maunamug/item_ctrl_click(mob/user)
	if(on)
		change_power_status(FALSE)
	else
		if(!cell || cell.charge <= 0)
			return FALSE //No power, so don't turn on
		change_power_status(TRUE)
	return CLICK_ACTION_SUCCESS

/obj/item/reagent_containers/cup/maunamug/proc/change_power_status(status)
	on = status
	if(on)
		START_PROCESSING(SSobj, src)
	else
		STOP_PROCESSING(SSobj, src)
	update_appearance()

/obj/item/reagent_containers/cup/maunamug/screwdriver_act(mob/living/user, obj/item/I)
	. = ..()
	open = !open
	to_chat(user, span_notice("You screw the battery case on [src] [open ? "open" : "closed"] ."))
	update_appearance()

/obj/item/reagent_containers/cup/maunamug/attackby(obj/item/attacking_item, mob/user, list/modifiers, list/attack_modifiers)
	add_fingerprint(user)
	if(!istype(attacking_item, /obj/item/stock_parts/power_store/cell))
		return ..()
	if(!open)
		to_chat(user, span_warning("The battery case must be open to insert a power cell!"))
		return FALSE
	if(cell)
		to_chat(user, span_warning("There is already a power cell inside!"))
		return FALSE
	else if(!user.transferItemToLoc(attacking_item, src))
		return
	cell = attacking_item
	user.visible_message(span_notice("[user] inserts a power cell into [src]."), span_notice("You insert the power cell into [src]."))
	update_appearance()

/obj/item/reagent_containers/cup/maunamug/attack_hand(mob/living/user, list/modifiers)
	if(cell && open)
		cell.update_appearance()
		user.put_in_hands(cell)
		cell = null
		to_chat(user, span_notice("You remove the power cell from [src]."))
		on = FALSE
		update_appearance()
		return TRUE
	return ..()

/obj/item/reagent_containers/cup/maunamug/update_icon_state()
	if(open)
		icon_state = "[base_icon_state][cell ? null : "_no"]_bat"
		return ..()
	icon_state = "[base_icon_state][on ? "_on" : null]"
	return ..()

/obj/item/reagent_containers/cup/maunamug/update_overlays()
	. = ..()
	if(!reagents.total_volume || reagents.chem_temp < 400)
		return

	var/intensity = (reagents.chem_temp - 400) * 1 / 600 //Get the opacity of the incandescent overlay. Ranging from 400 to 1000
	var/mutable_appearance/mug_glow = mutable_appearance(icon, "maunamug_incand")
	mug_glow.alpha = 255 * intensity
	. += mug_glow

/obj/item/reagent_containers/cup/rag
	name = "damp rag"
	desc = "For cleaning up messes, you suppose."
	w_class = WEIGHT_CLASS_TINY
	icon = 'icons/obj/toys/toy.dmi'
	icon_state = "rag"
	item_flags = NOBLUDGEON
	reagent_flags = OPENCONTAINER
	amount_per_transfer_from_this = 5
	possible_transfer_amounts = list()
	volume = 5
	spillable = FALSE

/obj/item/reagent_containers/cup/rag/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/cleaner, 3 SECONDS, pre_clean_callback=CALLBACK(src, PROC_REF(should_clean)))

/obj/item/reagent_containers/cup/rag/suicide_act(mob/living/user)
	user.visible_message(span_suicide("[user] is smothering [user.p_them()]self with [src]! It looks like [user.p_theyre()] trying to commit suicide!"))
	return OXYLOSS

/obj/item/reagent_containers/cup/rag/interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	if(!iscarbon(interacting_with) || !reagents?.total_volume)
		return ..()
	var/mob/living/carbon/carbon_target = interacting_with
	var/reagentlist = pretty_string_from_reagent_list(reagents.reagent_list)
	var/log_object = "containing [reagentlist]"
	if((user.istate & ISTATE_HARM) && !carbon_target.is_mouth_covered())
		reagents.trans_to(carbon_target, reagents.total_volume, transfered_by = user, methods = INGEST)
		carbon_target.visible_message(span_danger("[user] smothers \the [carbon_target] with \the [src]!"), span_userdanger("[user] smothers you with \the [src]!"), span_hear("You hear some struggling and muffled cries of surprise."))
		log_combat(user, carbon_target, "smothered", src, log_object)
	else
		reagents.expose(carbon_target, TOUCH)
		reagents.clear_reagents()
		carbon_target.visible_message(span_notice("[user] touches \the [carbon_target] with \the [src]."))
		log_combat(user, carbon_target, "touched", src, log_object)
	return ITEM_INTERACT_SUCCESS

///Checks whether or not we should clean.
/obj/item/reagent_containers/cup/rag/proc/should_clean(datum/cleaning_source, atom/atom_to_clean, mob/living/cleaner)
	if((cleaner.istate & ISTATE_HARM) && ismob(atom_to_clean))
		return CLEAN_BLOCKED|CLEAN_DONT_BLOCK_INTERACTION
	if(loc == cleaner)
		return CLEAN_ALLOWED
	return CLEAN_ALLOWED|CLEAN_NO_XP

/obj/item/reagent_containers/cup/fuelcanister
	name = "fuel canister"
	desc = "A canister full of industrial welding fuel. Do not puncture."
	icon = 'icons/obj/atmospherics/tank.dmi'
	lefthand_file = 'icons/mob/inhands/equipment/tanks_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/tanks_righthand.dmi'
	desc_controls = "Alt-Click to close or open the fuel nozzle cap."
	icon_state = "canister"
	base_icon_state = "canister"
	volume = 250
	spillable = FALSE
	reagent_flags = SEALED_CONTAINER
	possible_transfer_amounts = list(5,10,15,20,25,30,50)
	flags_1 = CONDUCT_1
	hitsound = 'sound/weapons/smash.ogg'
	pressure_resistance = ONE_ATMOSPHERE * 5
	resistance_flags = FIRE_PROOF
	force = 5
	throwforce = 10
	throw_speed = 1
	throw_range = 4
	demolition_mod = 1.25
	w_class = WEIGHT_CLASS_NORMAL
	var/cap_on = TRUE
	var/cap_lost = FALSE

/obj/item/reagent_containers/cup/fuelcanister/Initialize(mapload, vol)
	. = ..()
	register_context()

/obj/item/reagent_containers/cup/fuelcanister/examine(mob/user)
	. = ..()
	. += span_notice("It's [cap_on ? "capped" : "uncapped"].")
	if(src.loc == user)
		. += span_notice("It feels [get_volume_description()].")

/obj/item/reagent_containers/cup/fuelcanister/add_context(atom/source, list/context, obj/item/held_item, mob/user)
	. = ..()

	var/screentip_change = FALSE

	if(!cap_lost)
		context[SCREENTIP_CONTEXT_ALT_LMB] = cap_on ? "Close" : "Open"
		screentip_change = TRUE

	if(istype(held_item, /obj/item/weldingtool) && reagents.total_volume)
		context[SCREENTIP_CONTEXT_LMB] = "Refuel"
		screentip_change = TRUE

	return screentip_change ? CONTEXTUAL_SCREENTIP_SET : NONE

/obj/item/reagent_containers/cup/fuelcanister/proc/get_volume_description()
	var/volume_percentage = (reagents.total_volume/reagents.maximum_volume) * 100
	switch(volume_percentage)
		if(0)
			return "empty"
		if(1 to 25)
			return "almost empty"
		if(25 to 40)
			return "less than half full"
		if(40 to 60)
			return "half full"
		if(60 to 75)
			return "more than half full"
		if(75 to 99)
			return "almost full"
		if(99 to 100)
			return "full"

/obj/item/reagent_containers/cup/fuelcanister/click_alt(mob/living/user)
	if(cap_lost)
		to_chat(user, span_warning("The cap seems to be missing! Where did it go?"))
		return CLICK_ACTION_BLOCKING

	if(HAS_TRAIT(user, TRAIT_CLUMSY) && prob(25))
		spill(user, rand(5,50), user)
		playsound(src, 'sound/effects/slosh.ogg', 25, TRUE)
		user.visible_message(span_warning("[user] accidently drenches themself with the contents of \the [src]! What a doofus."), span_danger("Your hands slip and the contents of \the [src] drench you!"))

	var/fumbled = HAS_TRAIT(user, TRAIT_CLUMSY) && prob(5)
	if(cap_on || fumbled)
		cap_on = FALSE
		icon_state = "[base_icon_state]_nocap"
		reagent_flags = OPENCONTAINER
		spillable = TRUE
		reagents.flags = reagent_flags
		if(fumbled)
			to_chat(user, span_warning("You fumble with [src]'s cap! The cap falls onto the ground and simply vanishes. Where the hell did it go?"))
			cap_lost = TRUE
		else
			to_chat(user, span_notice("You remove the cap from [src]."))
			playsound(src, 'sound/effects/can_open1.ogg', 50, TRUE)
	else
		cap_on = TRUE
		icon_state = "[base_icon_state]"
		reagent_flags = SEALED_CONTAINER
		spillable = FALSE
		reagents.flags = reagent_flags
		to_chat(user, span_notice("You put the cap on [src]."))
	update_appearance()
	return CLICK_ACTION_SUCCESS

/obj/item/reagent_containers/cup/fuelcanister/proc/boom()
	var/datum/reagent/fuel/volatiles = reagents.has_reagent(/datum/reagent/fuel)
	var/fuel_amt = 0
	if(volatiles.volume <= 25)
		return
	if(istype(volatiles))
		fuel_amt = volatiles.volume
		reagents.del_reagent(/datum/reagent/fuel) // not actually used for the explosion
	if(reagents.total_volume)
		if(!fuel_amt)
			visible_message(span_danger("\The [src] ruptures!"))
		// Leave it up to future terrorists to figure out the best way to mix reagents with fuel for a useful boom here
		chem_splash(loc, null, 2 + (reagents.total_volume + fuel_amt) / 1000, list(reagents), extra_heat=(fuel_amt / 50),adminlog=(fuel_amt<25))

	if(fuel_amt) // with that done, actually explode
		visible_message(span_danger("\The [src] explodes!"))
		// old code for reference:
		// standard fuel tank = 1000 units = heavy_impact_range = 1, light_impact_range = 5, flame_range = 5
		// big fuel tank =SHEET_MATERIAL_AMOUNT * 2.5 units = devastation_range = 1, heavy_impact_range = 2, light_impact_range = 7, flame_range = 12
		// It did not account for how much fuel was actually in the tank at all, just the size of the tank.
		// I encourage others to better scale these numbers in the future.
		// As it stands this is a minor nerf in exchange for an easy bombing technique working that has been broken for a while.
		switch(volatiles.volume)
			if(25 to 150)
				explosion(src, light_impact_range = 1, flame_range = 2)
			if(150 to 300)
				explosion(src, light_impact_range = 2, flame_range = 3)
			if(300 to 750)
				explosion(src, heavy_impact_range = 1, light_impact_range = 3, flame_range = 5)
			if(750 to 1500)
				explosion(src, heavy_impact_range = 1, light_impact_range = 4, flame_range = 6)
			if(1500 to INFINITY)
				explosion(src, devastation_range = 1, heavy_impact_range = 2, light_impact_range = 6, flame_range = 8)
	qdel(src)

/obj/item/reagent_containers/cup/fuelcanister/blob_act(obj/structure/blob/B)
	boom()

/obj/item/reagent_containers/cup/fuelcanister/ex_act()
	boom()

/obj/item/reagent_containers/cup/fuelcanister/fire_act(exposed_temperature, exposed_volume)
	boom()

/obj/item/reagent_containers/cup/fuelcanister/zap_act(power, zap_flags)
	. = ..() //extend the zap
	if(ZAP_OBJ_DAMAGE & zap_flags)
		boom()

/obj/item/reagent_containers/cup/fuelcanister/bullet_act(obj/projectile/P)
	. = ..()
	if(QDELETED(src)) //wasn't deleted by the projectile's effects.
		return

	if(P.damage > 0 && ((P.damage_type == BURN) || (P.damage_type == BRUTE)))
		log_bomber(P.firer, "detonated a", src, "via projectile")
		boom()

/obj/item/reagent_containers/cup/fuelcanister/proc/spill(atom/target, spill_amount, mob/user)
	if(!spill_amount || !target)
		return FALSE
	if(!cap_on && reagents && reagents.total_volume)
		var/reagent_text
		for(var/datum/reagent/reagent as anything in reagents.reagent_list)
			reagent_text += "[reagent] ([num2text(reagent.volume)]),"
		log_combat(user, target, "splashed", reagent_text)
		reagents.expose(target, TOUCH, spill_amount / max(spill_amount, reagents.total_volume))
		reagents.remove_all(spill_amount)
		return TRUE
	return FALSE

/obj/item/reagent_containers/cup/fuelcanister/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	. = ..()
	if(tool.tool_behaviour != TOOL_WELDER)
		return
	if(!reagents.total_volume)
		to_chat(user, span_warning("\The [src] is out of fuel!"))
		return ITEM_INTERACT_BLOCKING
	var/obj/item/weldingtool/welder = tool
	if(istype(welder) && !welder.welding)
		if(!cap_on)
			to_chat(user, span_warning("\The [src] is uncapped!"))
			return
		if(welder.reagents.total_volume >= welder.reagents.maximum_volume)
			to_chat(user, span_warning("Your [welder.name] is already full!"))
			return ITEM_INTERACT_BLOCKING
		reagents.trans_to(welder, welder.max_fuel, transfered_by = user)
		user.visible_message(span_notice("[user] refills [user.p_their()] [welder.name]."), span_notice("You refill [welder]."))
		playsound(src, 'sound/effects/refill.ogg', 50, TRUE)
		welder.update_appearance()
	else
		user.visible_message(span_danger("[user] catastrophically fails at refilling [user.p_their()] [tool.name]!"), span_userdanger("That was stupid of you."))
		log_bomber(user, "detonated a", src, "via welding tool")
		boom()
	return ITEM_INTERACT_SUCCESS

/obj/item/reagent_containers/cup/fuelcanister/interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	. = ..()
	if(!(user.istate & ISTATE_HARM))
		return
	if(cap_on)
		to_chat(user, span_warning("\The [src] is capped!"))
		return
	if(!reagents.total_volume)
		to_chat(user, span_warning("\The [src] is empty!"))
		return ITEM_INTERACT_BLOCKING

	var/amount_to_spill = rand(10, 25)
	playsound(src, 'sound/effects/can_shake.ogg', 50, TRUE, 3)
	spill(interacting_with, amount_to_spill, user)
	user.visible_message(span_warning("[user] shakes the contents of \the [src] onto \the [interacting_with]!"), span_notice("You shake the contents of \the [src] onto \the [interacting_with]!"))
	if(ismob(interacting_with))
		var/mob/target_mob = interacting_with
		target_mob.show_message(
			span_userdanger("[user] splashs the contents of [src] onto you!"),
			MSG_VISUAL,
			span_userdanger("You feel drenched!"),
		)
	return ITEM_INTERACT_SUCCESS

/obj/item/reagent_containers/cup/fuelcanister/full
	list_reagents = list(/datum/reagent/fuel = 250)
