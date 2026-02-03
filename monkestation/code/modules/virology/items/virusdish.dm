///////////////VIRUS DISH///////////////
GLOBAL_LIST_INIT(virusdishes, list())
/obj/item/weapon/virusdish
	name = "growth dish"
	desc = "A petri dish fit to contain viral, bacteriologic, parasitic, or any other kind of pathogenic culture."
	icon = 'monkestation/code/modules/virology/icons/virology.dmi'
	icon_state = "virusdish"
	w_class = WEIGHT_CLASS_SMALL
	//sterility = 100//the outside of the dish is sterile.
	var/growth = 0
	var/info = ""
	var/analysed = FALSE
	var/datum/disease/acute/contained_virus
	/// Boolean, TRUE if the lid is opened
	var/open = FALSE
	var/cloud_delay = 8 SECONDS//similar to a mob's breathing
	var/mob/last_openner
	COOLDOWN_DECLARE(cloud_cooldown)

/obj/item/weapon/virusdish/New(loc)
	..()
	reagents = new(10)
	reagents.my_atom = src
	GLOB.virusdishes.Add(src)

	var/list/reagent_change_signals = list(
			COMSIG_REAGENTS_ADD_REAGENT,
			COMSIG_REAGENTS_NEW_REAGENT,
			COMSIG_REAGENTS_REM_REAGENT,
			COMSIG_REAGENTS_DEL_REAGENT,
			COMSIG_REAGENTS_CLEAR_REAGENTS,
			COMSIG_REAGENTS_REACTED,
	)
	RegisterSignals(src.reagents, reagent_change_signals, PROC_REF(on_reagent_change))

/obj/item/weapon/virusdish/Destroy()
	STOP_PROCESSING(SSobj, src)
	contained_virus = null
	GLOB.virusdishes.Remove(src)
	. = ..()

/*
/obj/item/weapon/virusdish/clean_blood()
	..()
	if(open)
		contained_virus = null
		growth = 0
		update_icon()
*/

/obj/item/weapon/virusdish/update_icon()
	. = ..()
	overlays.len = 0
	if(!contained_virus)
		if(open)
			icon_state = "virusdish1"
		else
			icon_state = "virusdish"
		return
	icon_state = "virusdish-outline"
	var/image/I1 = image(icon,src,"virusdish-bottom")
	I1.color = contained_virus.color
	var/image/I2 = image(icon,src,"pattern-[contained_virus.pattern]")
	I2.color = contained_virus.pattern_color
	var/image/I3 = image(icon,src,"virusdish-[open?"open":"closed"]")
	I3.color = contained_virus.color
	overlays += I1
	if(open)
		overlays += I3
		I2.alpha = growth*255/200+127
		overlays += I2
	else
		overlays += I2
		overlays += I3
		I2.alpha = (growth*255/200+127)*60/100
		overlays += I2
		var/image/I4 = image(icon,src,"virusdish-reflection")
		overlays += I4
	if(analysed)
		overlays += "virusdish-label"
	else if(info != "" && copytext(info, 1, 9) == "OUTDATED")
		overlays += "virusdish-outdated"

/obj/item/weapon/virusdish/attack_hand(mob/living/user, list/modifiers)
	..()
	infection_attempt(user)

/obj/item/weapon/virusdish/attack_self(mob/living/user, list/modifiers)
	open = !open
	update_appearance()
	to_chat(user,span_notice("You [open?"open":"close"] dish's lid."))
	if(open)
		last_openner = user
		if(contained_virus)
			contained_virus.log += "<br />[ROUND_TIME()] Containment Dish opened by [key_name(user)]."
			START_PROCESSING(SSobj, src)
	else
		if(contained_virus)
			contained_virus.log += "<br />[ROUND_TIME()] Containment Dish closed by [key_name(user)]."
		STOP_PROCESSING(SSobj, src)
	infection_attempt(user)

/obj/item/weapon/virusdish/is_open_container()
	return open

/obj/item/weapon/virusdish/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	if((user.istate & ISTATE_HARM) && tool.force)
		visible_message(span_danger("The virus dish is smashed to bits!"))
		shatter(user)
		return ITEM_INTERACT_SUCCESS

	if(istype(tool, /obj/item/reagent_containers/syringe))
		if(growth < 50)
			to_chat(user, span_warning("There isn't enough growth in the [src]."))
			return ITEM_INTERACT_BLOCKING
		growth = growth - 50
		var/obj/item/reagent_containers/syringe/syringe_tool = tool
		var/list/data = list("viruses"=null,"blood_DNA"=null,"blood_type"="O-","resistances"=null,"trace_chem"=null,"viruses"=list(),"immunity"=list())
		data["viruses"] |= list(contained_virus)
		syringe_tool.reagents.add_reagent(/datum/reagent/blood, syringe_tool.volume, data)
		to_chat(user, span_notice("You take some blood from the [src]."))
		return ITEM_INTERACT_SUCCESS

	if(istype(tool, /obj/item/reagent_containers))
		if(!open)
			user.balloon_alert(user, "lid closed")
			return ITEM_INTERACT_BLOCKING

		if(!tool.is_open_container())
			to_chat(user, span_notice("[tool] is not an open container"))
			return ITEM_INTERACT_BLOCKING

		var/transfered_amount = 0
		transfered_amount = tool.reagents.trans_to(src, 10, transfered_by = user)
		if(transfered_amount > 0)
			to_chat(user, span_notice("You transfer [transfered_amount] units of the solution to \the [src]."))
		return ITEM_INTERACT_SUCCESS

/obj/item/weapon/virusdish/interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	if(istype(interacting_with, /obj/machinery/smartfridge/chemistry))
		return ITEM_INTERACT_SKIP_TO_ATTACK

	if(!open)
		user.balloon_alert(user, "lid closed")
		return ITEM_INTERACT_BLOCKING

	if(is_reagent_container(interacting_with))
		var/amount_transfered = reagents.trans_to(interacting_with, 10, transfered_by = user)
		if(amount_transfered > 0)
			to_chat(user, span_notice("You transfer [amount_transfered] units of the solution to \the [interacting_with]."))
			return ITEM_INTERACT_SUCCESS
		return ITEM_INTERACT_BLOCKING

	if(istype(interacting_with, /obj/structure/reagent_dispensers))
		var/obj/structure/reagent_dispensers/dispenser = interacting_with
		var/amount_transfered = dispenser.reagents.trans_to(src, 10, transfered_by = user)
		if(amount_transfered > 0)
			to_chat(user, span_notice("You transfer [amount_transfered] units of the solution to \the [src]."))
			return ITEM_INTERACT_SUCCESS
		return ITEM_INTERACT_BLOCKING

	if(istype(interacting_with, /obj/structure/urinal) || istype(interacting_with, /obj/structure/sink))
		empty(user, interacting_with)
		return ITEM_INTERACT_SUCCESS

	if(istype(interacting_with, /obj/structure/toilet))
		var/obj/structure/toilet/convenient_disposal = interacting_with
		if(!convenient_disposal.open)
			return NONE
		empty(user, interacting_with)
		return ITEM_INTERACT_SUCCESS

/// Empties out the virus dish
/obj/item/weapon/virusdish/proc/empty(mob/user, atom/target)
	if(user && target)
		to_chat(user,span_notice("You empty \the [src]'s reagents into \the [target]."))
	reagents.clear_reagents()

/obj/item/weapon/virusdish/process()
	if(!contained_virus || !open)
		return PROCESS_KILL
	if(isliving(loc))
		var/mob/living/holder = loc
		if(holder.is_holding(src))
			infection_attempt(holder, contained_virus)
	else if(isopenturf(loc))
		for(var/mob/living/potential_victim in loc.contents)
			infection_attempt(potential_victim, contained_virus)
	if(contained_virus.spread_flags & DISEASE_SPREAD_AIRBORNE)
		if(COOLDOWN_FINISHED(src, cloud_cooldown))
			COOLDOWN_START(src, cloud_cooldown, cloud_delay)
			var/list/L = list(contained_virus)
			new /obj/effect/pathogen_cloud/core(get_turf(src), last_openner, virus_copylist(L), FALSE)

/obj/item/weapon/virusdish/random
	name = "growth dish"

/obj/item/weapon/virusdish/random/New(loc)
	..(loc)
	if(loc)//because fuck you /datum/subsystem/supply_shuttle/Initialize()
		var/virus_choice = pick(WILD_ACUTE_DISEASES)
		contained_virus = new virus_choice
		var/list/anti = list(
			ANTIGEN_BLOOD	= 2,
			ANTIGEN_COMMON	= 2,
			ANTIGEN_RARE	= 1,
			ANTIGEN_ALIEN	= 0,
			)
		var/list/bad = list(
			EFFECT_DANGER_HELPFUL	= 1,
			EFFECT_DANGER_FLAVOR	= 2,
			EFFECT_DANGER_ANNOYING	= 2,
			EFFECT_DANGER_HINDRANCE	= 2,
			EFFECT_DANGER_HARMFUL	= 2,
			EFFECT_DANGER_DEADLY	= 0,
			)
		contained_virus.makerandom(list(50,90),list(10,100),anti,bad,src)
		contained_virus.Refresh_Acute()
		growth = rand(5, 50)
		name = "growth dish (Unknown [contained_virus.form])"
		update_appearance()
		contained_virus.origin = "Random Dish"
	else
		GLOB.virusdishes.Remove(src)

/obj/item/weapon/virusdish/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	..()
	if(isturf(hit_atom))
		visible_message(span_danger("The virus dish shatters on impact!"))
		shatter(throwingdatum.thrower)

/obj/item/weapon/virusdish/proc/incubate(mutatechance=5, growthrate=3, effect_focus = 0)
	if(contained_virus)
		if(reagents.remove_reagent(/datum/reagent/consumable/virus_food, 0.2))
			growth = min(growth + growthrate, 100)
		if(reagents.remove_reagent(/datum/reagent/water, 0.2))
			growth = max(growth - growthrate, 0)
		contained_virus.incubate(src,mutatechance,effect_focus)

/obj/item/weapon/virusdish/proc/on_reagent_change(datum/reagents/reagents)
	SIGNAL_HANDLER

	if(contained_virus)
		var/datum/reagent/blood/blood = locate() in reagents.reagent_list
		if(blood)
			var/list/L = list()
			L |= contained_virus
			LAZYOR(blood.data["diseases"], filter_disease_by_spread(L, required = DISEASE_SPREAD_BLOOD))

/obj/item/weapon/virusdish/proc/shatter(mob/user)
	var/obj/effect/decal/cleanable/virusdish/dish = new(get_turf(src))
	dish.pixel_x = pixel_x
	dish.pixel_y = pixel_y
	if(contained_virus)
		dish.contained_virus = contained_virus.Copy()
	dish.last_openner = key_name(user)
	src.transfer_fingerprints_to(dish)
	playsound(get_turf(src), "shatter", 70, 1)
	var/image/I1
	var/image/I2
	if(contained_virus)
		I1 = image(icon,src,"brokendish-color")
		I1.color = contained_virus.color
		I2 = image(icon,src,"pattern-[contained_virus.pattern]b")
		I2.color = contained_virus.pattern_color
	else
		I1 = image(icon,src,"brokendish")
	dish.overlays += I1
	if(contained_virus)
		dish.overlays += I2
		contained_virus.log += "<br />[ROUND_TIME()] Containment Dish shattered by [key_name(user)]."
		if(contained_virus.spread_flags & DISEASE_SPREAD_AIRBORNE)
			var/strength = contained_virus.infectionchance
			var/list/L = list()
			L += contained_virus
			while (strength > 0)
				new /obj/effect/pathogen_cloud/core(get_turf(src), last_openner, virus_copylist(L), FALSE)
				strength -= 40
	qdel(src)

/obj/item/weapon/virusdish/update_desc(updates)
	. = ..()
	desc = initial(desc)
	if(open)
		desc += "\nIts lid is open!"
	else
		desc += "\nIts lid is closed!"
	if(info)
		desc += "\nThere is a sticker with some printed information on it. <a href='byond://?src=\ref[src];examine=1'>(Read it)</a>"


/obj/item/weapon/virusdish/Topic(href, href_list)
	if(..())
		return TRUE
	if(href_list["examine"])
		var/datum/browser/popup = new(usr, "\ref[src]", name, 600, 300, src)
		popup.set_content(info)
		popup.open()

/obj/item/weapon/virusdish/infection_attempt(mob/living/perp, datum/disease/D)
	if(open)//If the dish is open, we may get infected by the disease inside on top of those that might be stuck on it.
		var/block = 0
		var/bleeding = 0
		if(src in perp.held_items)
			block = perp.check_contact_sterility(BODY_ZONE_ARMS)
			bleeding = perp.check_bodypart_bleeding(BODY_ZONE_ARMS)
			if(!block && (contained_virus.spread_flags & DISEASE_SPREAD_CONTACT_SKIN))
				perp.infect_disease(contained_virus, notes="(Contact, from picking up \a [src])")
			else if(bleeding && (contained_virus.spread_flags & DISEASE_SPREAD_BLOOD))
				perp.infect_disease(contained_virus, notes="(Blood, from picking up \a [src])")
		else if(isturf(loc) && loc == perp.loc)//is our perp standing over the open dish?
			if(perp.body_position & LYING_DOWN)
				block = perp.check_contact_sterility(BODY_ZONE_EVERYTHING)
				bleeding = perp.check_bodypart_bleeding(BODY_ZONE_EVERYTHING)
			else
				block = perp.check_contact_sterility(BODY_ZONE_LEGS)
				bleeding = perp.check_bodypart_bleeding(BODY_ZONE_LEGS)
			if(!block && (contained_virus.spread_flags & DISEASE_SPREAD_CONTACT_SKIN))
				perp.infect_disease(contained_virus, notes="(Contact, from [(perp.body_position & LYING_DOWN)?"lying":"standing"] over a virus dish[last_openner ? " opened by [key_name(last_openner)]" : ""])")
			else if(bleeding && (contained_virus.spread_flags & DISEASE_SPREAD_BLOOD))
				perp.infect_disease(contained_virus, notes="(Blood, from [(perp.body_position & LYING_DOWN)?"lying":"standing"] over a virus dish[last_openner ? " opened by [key_name(last_openner)]" : ""])")
	..(perp,D)
