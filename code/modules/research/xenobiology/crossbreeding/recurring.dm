/*
Recurring extracts:
	Generates a new charge every few seconds.
	If depleted of its' last charge, stops working.
*/
/obj/item/slimecross/recurring
	name = "recurring extract"
	desc = "A tiny, glowing core, wrapped in several layers of goo."
	effect = "recurring"
	icon_state = "recurring"
	var/extract_type
	var/obj/item/slime_extract/extract
	var/cooldown = 0
	var/max_cooldown = 10 // In seconds

/obj/item/slimecross/recurring/Initialize(mapload)
	. = ..()
	extract = new extract_type(src.loc)
	visible_message(span_notice("[src] wraps a layer of goo around itself!"))
	extract.name = name
	extract.desc = desc
	extract.icon = icon
	extract.icon_state = icon_state
	extract.color = color
	extract.recurring = TRUE
	src.forceMove(extract)
	START_PROCESSING(SSobj,src)

/obj/item/slimecross/recurring/process(seconds_per_tick)
	if(cooldown > 0)
		cooldown -= seconds_per_tick
	else if(extract.Uses < 10 && extract.Uses > 0)
		extract.Uses++
		cooldown = max_cooldown
	else if(extract.Uses <= 0)
		extract.visible_message(span_warning("The light inside [extract] flickers and dies out."))
		extract.desc = "A tiny, inert core, bleeding dark, cerulean-colored goo."
		extract.icon_state = "prismatic"
		qdel(src)

/obj/item/slimecross/recurring/Destroy()
	. = ..()
	STOP_PROCESSING(SSobj,src)

/obj/item/slimecross/recurring/grey
	extract_type = /obj/item/slime_extract/grey
	slime_type = /datum/slime_type/grey

/obj/item/slimecross/recurring/orange
	extract_type = /obj/item/slime_extract/orange
	slime_type = /datum/slime_type/orange

/obj/item/slimecross/recurring/purple
	extract_type = /obj/item/slime_extract/purple
	slime_type = /datum/slime_type/purple

/obj/item/slimecross/recurring/blue
	extract_type = /obj/item/slime_extract/blue
	slime_type = /datum/slime_type/blue

/obj/item/slimecross/recurring/metal
	extract_type = /obj/item/slime_extract/metal
	slime_type = /datum/slime_type/metal
	max_cooldown = 20

/obj/item/slimecross/recurring/yellow
	extract_type = /obj/item/slime_extract/yellow
	slime_type = /datum/slime_type/yellow
	max_cooldown = 20

/obj/item/slimecross/recurring/darkpurple
	extract_type = /obj/item/slime_extract/darkpurple
	slime_type = /datum/slime_type/darkpurple
	max_cooldown = 20

/obj/item/slimecross/recurring/darkblue
	extract_type = /obj/item/slime_extract/darkblue
	slime_type = /datum/slime_type/darkblue

/obj/item/slimecross/recurring/silver
	extract_type = /obj/item/slime_extract/silver
	slime_type = /datum/slime_type/silver

/obj/item/slimecross/recurring/bluespace
	extract_type = /obj/item/slime_extract/bluespace
	slime_type = /datum/slime_type/bluespace

/obj/item/slimecross/recurring/sepia
	extract_type = /obj/item/slime_extract/sepia
	slime_type = /datum/slime_type/sepia
	max_cooldown = 36 //No infinite timestop for you!

/obj/item/slimecross/recurring/cerulean
	extract_type = /obj/item/slime_extract/cerulean
	slime_type = /datum/slime_type/cerulean

/obj/item/slimecross/recurring/pyrite
	extract_type = /obj/item/slime_extract/pyrite
	slime_type = /datum/slime_type/pyrite

/obj/item/slimecross/recurring/red
	extract_type = /obj/item/slime_extract/red
	slime_type = /datum/slime_type/red

/obj/item/slimecross/recurring/green
	extract_type = /obj/item/slime_extract/green
	slime_type = /datum/slime_type/green

/obj/item/slimecross/recurring/pink
	extract_type = /obj/item/slime_extract/pink
	slime_type = /datum/slime_type/pink

/obj/item/slimecross/recurring/gold
	extract_type = /obj/item/slime_extract/gold
	slime_type = /datum/slime_type/gold
	max_cooldown = 30

/obj/item/slimecross/recurring/oil
	extract_type = /obj/item/slime_extract/oil
	slime_type = /datum/slime_type/oil //Why would you want this?

/obj/item/slimecross/recurring/black
	extract_type = /obj/item/slime_extract/black
	slime_type = /datum/slime_type/black

/obj/item/slimecross/recurring/lightpink
	extract_type = /obj/item/slime_extract/lightpink
	slime_type = /datum/slime_type/lightpink

/obj/item/slimecross/recurring/adamantine
	extract_type = /obj/item/slime_extract/adamantine
	slime_type = /datum/slime_type/adamantine
	max_cooldown = 20

/obj/item/slimecross/recurring/rainbow
	extract_type = /obj/item/slime_extract/rainbow
	slime_type = /datum/slime_type/rainbow
	max_cooldown = 40 //It's pretty powerful.
