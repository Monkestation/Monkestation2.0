/*
CONTAINS:
RSF

*/
///Extracts the related object from an associated list of objects and values, or lists and objects.
#define OBJECT_OR_LIST_ELEMENT(from, input) (islist(input) ? from[input] : input)
/obj/item/rsf
	name = "\improper Rapid-Service-Fabricator"
	desc = "A device used to rapidly deploy service items."
	icon = 'icons/obj/tools.dmi'
	icon_state = "rsf"
	inhand_icon_state = "rsf"
	base_icon_state = "rsf"
	///The icon state to revert to when the tool is empty
	var/spent_icon_state = "rsf_empty"
	lefthand_file = 'icons/mob/inhands/equipment/tools_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/tools_righthand.dmi'
	opacity = FALSE
	density = FALSE
	anchored = FALSE
	item_flags = NOBLUDGEON
	armor_type = /datum/armor/none
	///The current matter count
	var/matter = 0
	///The max amount of matter in the device
	var/max_matter = 30
	///The type of the object we are going to dispense
	var/to_dispense
	///The cost of the object we are going to dispense
	var/dispense_cost = 0
	w_class = WEIGHT_CLASS_NORMAL
	///An associated list of atoms and charge costs. This can contain a separate list, as long as it's associated item is an object
	//MONKESTATION REMOVAL
	/*
	var/list/cost_by_item = list(/obj/item/reagent_containers/cup/glass/drinkingglass = 20,
								/obj/item/paper = 10,
								/obj/item/storage/dice = 200,
								/obj/item/pen = 50,
								/obj/item/clothing/mask/cigarette = 10,
								)
	*/
	//MONKESTATION REMOVAL END
	//MONKESTATION ADDITION
	///The RSF item list below shows in the player facing ui in this order, this is why it isn't in alphabetical order, but instead sorted by category
	var/list/cost_by_item = list(
		/obj/item/reagent_containers/cup/glass/drinkingglass = 20,
		/obj/item/reagent_containers/cup/glass/sillycup = 10,
		/obj/item/plate = 70,
		/obj/item/reagent_containers/cup/bowl = 70,
		/obj/item/kitchen/fork/plastic = 30,
		/obj/item/knife/plastic = 30,
		/obj/item/kitchen/spoon/plastic = 30,
		/obj/item/food/seaweedsheet = 30,
		/obj/item/storage/dice = 200,
		/obj/item/toy/cards/deck = 200,
		/obj/item/paper = 10,
		/obj/item/pen = 50,
		/obj/item/clothing/mask/cigarette = 10,
	)
	//MONKESTATION ADDITION END
	///An associated list of fuel and it's value
	var/list/matter_by_item = list(/obj/item/rcd_ammo = 10,)
	///A list of surfaces that we are allowed to place things on.
	var/list/allowed_surfaces = list(/turf/open/floor, /obj/structure/table)
	///The unit of mesure of the matter, for use in text
	var/discriptor = "fabrication-units"
	///The verb that describes what we're doing, for use in text
	var/action_type = "Dispensing"
	///Holds a copy of world.time from the last time the synth was used.
	var/cooldown = 0
	///How long should the minimum period between this RSF's item dispensings be?
	var/cooldowndelay = 0 SECONDS

/obj/item/rsf/Initialize(mapload)
	. = ..()
	to_dispense = cost_by_item[1]
	dispense_cost = cost_by_item[to_dispense]

/obj/item/rsf/examine(mob/user)
	. = ..()
	. += span_notice("It currently holds [matter]/[max_matter] [discriptor].")

/obj/item/rsf/cyborg
	matter = 30

/obj/item/rsf/attackby(obj/item/attacking_item, mob/user, list/modifiers, list/attack_modifiers)
	if(is_type_in_list(attacking_item,matter_by_item))//If the thing we got hit by is in our matter list
		var/tempMatter = matter_by_item[attacking_item.type] + matter
		if(tempMatter > max_matter)
			to_chat(user, span_warning("\The [src] can't hold any more [discriptor]!"))
			return
		if(isstack(attacking_item))
			var/obj/item/stack/stack = attacking_item
			stack.use(1)
		else
			qdel(attacking_item)
		matter = tempMatter //We add its value
		playsound(src.loc, 'sound/machines/click.ogg', 10, TRUE)
		to_chat(user, span_notice("\The [src] now holds [matter]/[max_matter] [discriptor]."))
		icon_state = base_icon_state//and set the icon state to the base state
	else
		return ..()

/obj/item/rsf/proc/select_item(mob/user, target)
	var/cost = 0
	//Warning, prepare for bodgecode
	while(islist(target))//While target is a list we continue the loop
		var/picked = show_radial_menu(user, src, formRadial(target), custom_check = CALLBACK(src, PROC_REF(check_menu), user), require_near = TRUE)
		if(!check_menu(user) || picked == null)
			return
		for(var/emem in target)//Back through target agian
			var/atom/test = OBJECT_OR_LIST_ELEMENT(target, emem)
			if(picked == initial(test.type))//We try and find the entry that matches the radial selection
				cost = target[emem]//We cash the cost
				target = emem
				break
		//If we found a list we start it all again, this time looking through its contents.
		//This allows for sublists
	to_dispense = target
	dispense_cost = cost
	// Change mode

/obj/item/rsf/attack_self(mob/user)
	playsound(src.loc, 'sound/effects/pop.ogg', 50, FALSE)
	select_item(user, cost_by_item)

///Forms a radial menu based off an object in a list, or a list's associated object
/obj/item/rsf/proc/formRadial(from)
	var/list/radial_list = list()
	for(var/meme in from)//We iterate through all of targets entrys
		var/atom/temp = OBJECT_OR_LIST_ELEMENT(from, meme)
		//We then add their data into the radial menu
		var/datum/radial_menu_choice/option = new
		option.name = initial(temp.name)
		option.image = image(icon = initial(temp.icon), icon_state = initial(temp.icon_state))
		radial_list[initial(temp.type)] = option
	return radial_list

/obj/item/rsf/proc/check_menu(mob/user)
	if(user.incapacitated() || !user.Adjacent(src))
		return FALSE
	return TRUE

/obj/item/rsf/interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	if(cooldown > world.time)
		return NONE
	if (!is_allowed(interacting_with))
		return NONE
	if(use_matter(dispense_cost, user))//If we can charge that amount of charge, we do so and return true
		playsound(src, 'sound/machines/click.ogg', 10, TRUE)
		var/atom/meme = new to_dispense(get_turf(interacting_with))
		to_chat(user, span_notice("[action_type] [meme.name]..."))
		cooldown = world.time + cooldowndelay
		return ITEM_INTERACT_SUCCESS
	return ITEM_INTERACT_BLOCKING

///A helper proc. checks to see if we can afford the amount of charge that is passed, and if we can docs the charge from our base, and returns TRUE. If we can't we return FALSE
/obj/item/rsf/proc/use_matter(charge, mob/user)
	if(iscyborg(user))
		var/mob/living/silicon/robot/R = user
		var/end_charge = R.cell.charge - charge
		if(end_charge < 0)
			to_chat(user, span_warning("You do not have enough power to use [src]."))
			icon_state = spent_icon_state
			return FALSE
		R.cell.charge = end_charge
		return TRUE
	else
		if(matter - 1 < 0)
			to_chat(user, span_warning("\The [src] doesn't have enough [discriptor] left."))
			icon_state = spent_icon_state
			return FALSE
		matter--
		to_chat(user, span_notice("\The [src] now holds [matter]/[max_matter] [discriptor]."))
		return TRUE

///Helper proc that iterates through all the things we are allowed to spawn on, and sees if the passed atom is one of them
/obj/item/rsf/proc/is_allowed(atom/to_check)
	return is_type_in_list(to_check, allowed_surfaces)

/obj/item/rsf/cookiesynth
	name = "Cookie Synthesizer"
	desc = "A self-recharging device used to rapidly deploy cookies."
	icon_state = "rcd"
	base_icon_state = "rcd"
	spent_icon_state = "rcd"
	max_matter = 10
	cost_by_item = list(/obj/item/food/cookie = 100)
	dispense_cost = 100
	discriptor = "cookie-units"
	action_type = "Fabricates"
	cooldowndelay = 10 SECONDS
	///Tracks whether or not the cookiesynth is about to print a poisoned cookie
	var/toxin = FALSE //This might be better suited to some initialize fuckery, but I don't have a good "poisoned" sprite

/obj/item/rsf/cookiesynth/emag_act(mob/user, obj/item/card/emag/emag_card)
	obj_flags ^= EMAGGED
	if(obj_flags & EMAGGED)
		balloon_alert(user, "reagent safety checker shorted out")
	else
		balloon_alert(user, "reagent safety checker reset")
	return TRUE

/obj/item/rsf/cookiesynth/attack_self(mob/user)
	var/mob/living/silicon/robot/P = null
	if(iscyborg(user))
		P = user
	if(((obj_flags & EMAGGED) || (P?.emagged)) && !toxin)
		toxin = TRUE
		to_dispense = /obj/item/food/cookie/sleepy
		to_chat(user, span_alert("Cookie Synthesizer hacked."))
	else
		toxin = FALSE
		to_dispense = /obj/item/food/cookie
		to_chat(user, span_notice("Cookie Synthesizer reset."))

//RSF but with more stuff, split into categories
/obj/item/rsf/deluxe
	name = "\improper Deluxe Rapid-Service-Fabricator"
	icon_state = "drsf"
	inhand_icon_state = "drsf"
	base_icon_state = "drsf"
	var/options = list(
		bureaucracy = list(
			name = "Bureaucracy",
			icon = 'icons/obj/service/bureaucracy.dmi',
			icon_state = "pen-fountain",
		),
		bartending = list(
			name = "Bartending",
			icon = 'icons/obj/drinks/bottles.dmi',
			icon_state = "beer",
		),
		comforts = list(
			name = "Comforts",
			icon = 'icons/obj/clothing/masks.dmi',
			icon_state = "cigar2off",
		),
		cooking = list(
			name = "Kitchenware",
			icon = 'icons/obj/kitchen.dmi',
			icon_state = "knife",
		),
	)
	cost_by_item = list(
		bureaucracy = list(
			/obj/item/clipboard = 50,
			/obj/item/folder = 20,
			/obj/item/folder/blue = 20,
			/obj/item/folder/red = 20,
			/obj/item/folder/yellow = 20,
			/obj/item/folder/white = 20,
			/obj/item/paper = 10,
			/obj/item/paper/carbon = 20,
			/obj/item/pen = 50,
			/obj/item/pen/fountain = 60,
			/obj/item/stamp/granted = 30,
			/obj/item/stamp/denied = 30,
		),
		cooking = list(
			/obj/item/plate/small = 30,
			/obj/item/plate = 70,
			/obj/item/plate/large = 100,
			/obj/item/reagent_containers/cup/bowl = 70,
			/obj/item/kitchen/fork/plastic = 30,
			/obj/item/knife/plastic = 30,
			/obj/item/kitchen/spoon/plastic = 30,
			/obj/item/food/seaweedsheet = 30,
		),
		comforts = list(
			/obj/item/storage/dice = 200,
			/obj/item/toy/cards/deck = 200,
			/obj/item/clothing/mask/cigarette = 10,
			/obj/item/clothing/mask/cigarette/cigar/cohiba = 30,
			/obj/item/clothing/mask/cigarette/cigar/havana = 60,
			/obj/item/lighter = 50,
		),
		bartending = list(
			/obj/item/reagent_containers/cup/glass/bottle = 40,
			/obj/item/reagent_containers/cup/glass/drinkingglass = 20,
			/obj/item/reagent_containers/cup/glass/mug = 20,
			/obj/item/reagent_containers/cup/glass/mug/britcup = 20,
			/obj/item/reagent_containers/cup/glass/mug/nanotrasen = 20,
			/obj/item/reagent_containers/cup/glass/sillycup = 10,
		),
	)

/obj/item/rsf/deluxe/attack_self(mob/user)
	playsound(src.loc, 'sound/effects/pop.ogg', 50, FALSE)
	var/list/radial_list = list()
	for(var/key in options)
		var/datum/radial_menu_choice/option = new
		option.name = options[key]["name"]
		option.image = image(icon = options[key]["icon"], icon_state = options[key]["icon_state"])
		radial_list[key] = option
	var/picked = show_radial_menu(user, src, radial_list, custom_check = CALLBACK(src, PROC_REF(check_menu), user), require_near = TRUE)
	if(!check_menu(user) || picked == null)
		return
	if(cost_by_item[picked])
		select_item(user, cost_by_item[picked])

/obj/item/rsf/deluxe/cyborg
	matter = 30

#undef OBJECT_OR_LIST_ELEMENT
