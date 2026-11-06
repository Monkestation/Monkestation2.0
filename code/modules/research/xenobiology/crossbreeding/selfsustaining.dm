/*
Self-sustaining extracts:
	Produces 4 extracts that do not need reagents.
*/
/obj/item/slimecross/selfsustaining
	name = "self-sustaining extract"
	effect = "self-sustaining"
	icon_state = "selfsustaining"
	var/extract_type = /obj/item/slime_extract

/obj/item/autoslime
	name = "autoslime"
	desc = "It resembles a normal slime extract, but seems filled with a strange, multi-colored fluid."
	var/obj/item/slime_extract/extract
	var/effect_desc = "A self-sustaining slime extract. When used, lets you choose which reaction you want."

//Just divides into the actual item.
/obj/item/slimecross/selfsustaining/Initialize(mapload)
	..()
	visible_message(span_warning("The [src] shudders, and splits into four smaller extracts."))
	for(var/i in 1 to 4)
		var/obj/item/autoslime/A = new /obj/item/autoslime(src.loc)
		var/obj/item/slime_extract/X = new extract_type(A)
		A.extract = X
		A.icon = icon
		A.icon_state = icon_state
		A.color = color
		A.name = "self-sustaining [slime_type::color] extract"
	return INITIALIZE_HINT_QDEL

/obj/item/autoslime/Initialize(mapload)
	return ..()

/obj/item/autoslime/attack_self(mob/user)
	var/reagentselect = tgui_input_list(user, "Reagent the extract will produce.", "Self-sustaining Reaction", sort_list(extract.activate_reagents, GLOBAL_PROC_REF(cmp_typepaths_asc)))
	if(isnull(reagentselect))
		return
	var/amount = 5
	var/secondary

	if (user.get_active_held_item() != src || user.stat != CONSCIOUS || HAS_TRAIT(user, TRAIT_HANDS_BLOCKED))
		return
	if(!reagentselect)
		return
	if(reagentselect == "lesser plasma")
		amount = 4
		reagentselect = /datum/reagent/toxin/plasma
	if(reagentselect == "holy water and uranium")
		reagentselect = /datum/reagent/water/holywater
		secondary = /datum/reagent/uranium
	extract.forceMove(user.drop_location())
	qdel(src)
	user.put_in_active_hand(extract)
	extract.reagents.add_reagent(reagentselect,amount)
	if(secondary)
		extract.reagents.add_reagent(secondary,amount)

/obj/item/autoslime/examine(mob/user)
	. = ..()
	if(effect_desc)
		. += span_notice("[effect_desc]")

//Different types.

/obj/item/slimecross/selfsustaining/grey
	extract_type = /obj/item/slime_extract/grey
	slime_type = /datum/slime_type/grey

/obj/item/slimecross/selfsustaining/orange
	extract_type = /obj/item/slime_extract/orange
	slime_type = /datum/slime_type/orange

/obj/item/slimecross/selfsustaining/purple
	extract_type = /obj/item/slime_extract/purple
	slime_type = /datum/slime_type/purple

/obj/item/slimecross/selfsustaining/blue
	extract_type = /obj/item/slime_extract/blue
	slime_type = /datum/slime_type/blue

/obj/item/slimecross/selfsustaining/metal
	extract_type = /obj/item/slime_extract/metal
	slime_type = /datum/slime_type/metal

/obj/item/slimecross/selfsustaining/yellow
	extract_type = /obj/item/slime_extract/yellow
	slime_type = /datum/slime_type/yellow

/obj/item/slimecross/selfsustaining/darkpurple
	extract_type = /obj/item/slime_extract/darkpurple
	slime_type = /datum/slime_type/darkpurple

/obj/item/slimecross/selfsustaining/darkblue
	extract_type = /obj/item/slime_extract/darkblue
	slime_type = /datum/slime_type/darkblue

/obj/item/slimecross/selfsustaining/silver
	extract_type = /obj/item/slime_extract/silver
	slime_type = /datum/slime_type/silver

/obj/item/slimecross/selfsustaining/bluespace
	extract_type = /obj/item/slime_extract/bluespace
	slime_type = /datum/slime_type/bluespace

/obj/item/slimecross/selfsustaining/sepia
	extract_type = /obj/item/slime_extract/sepia
	slime_type = /datum/slime_type/sepia

/obj/item/slimecross/selfsustaining/cerulean
	extract_type = /obj/item/slime_extract/cerulean
	slime_type = /datum/slime_type/cerulean

/obj/item/slimecross/selfsustaining/pyrite
	extract_type = /obj/item/slime_extract/pyrite
	slime_type = /datum/slime_type/pyrite

/obj/item/slimecross/selfsustaining/red
	extract_type = /obj/item/slime_extract/red
	slime_type = /datum/slime_type/red

/obj/item/slimecross/selfsustaining/green
	extract_type = /obj/item/slime_extract/green
	slime_type = /datum/slime_type/green

/obj/item/slimecross/selfsustaining/pink
	extract_type = /obj/item/slime_extract/pink
	slime_type = /datum/slime_type/pink

/obj/item/slimecross/selfsustaining/gold
	extract_type = /obj/item/slime_extract/gold
	slime_type = /datum/slime_type/gold

/obj/item/slimecross/selfsustaining/oil
	extract_type = /obj/item/slime_extract/oil
	slime_type = /datum/slime_type/oil

/obj/item/slimecross/selfsustaining/black
	extract_type = /obj/item/slime_extract/black
	slime_type = /datum/slime_type/black

/obj/item/slimecross/selfsustaining/lightpink
	extract_type = /obj/item/slime_extract/lightpink
	slime_type = /datum/slime_type/lightpink

/obj/item/slimecross/selfsustaining/adamantine
	extract_type = /obj/item/slime_extract/adamantine
	slime_type = /datum/slime_type/adamantine

/obj/item/slimecross/selfsustaining/rainbow
	extract_type = /obj/item/slime_extract/rainbow
	slime_type = /datum/slime_type/rainbow
