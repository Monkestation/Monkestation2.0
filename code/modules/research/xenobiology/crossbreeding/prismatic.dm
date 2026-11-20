/*
Prismatic extracts:
	Becomes an infinite-use paintbrush.
*/
/obj/item/slimecross/prismatic
	name = "prismatic extract"
	desc = "It's constantly wet with a semi-transparent, colored goo."
	effect = "prismatic"
	effect_desc = "When used it paints whatever it hits."
	icon_state = "prismatic"
	var/paintcolor = "#FFFFFF"

/obj/item/slimecross/prismatic/interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	if(!isturf(interacting_with) || isspaceturf(interacting_with))
		return NONE
	user.do_attack_animation(interacting_with)
	interacting_with.add_atom_colour(color_transition_filter(paintcolor, SATURATION_OVERRIDE), WASHABLE_COLOUR_PRIORITY)
	playsound(interacting_with, 'sound/effects/slosh.ogg', 20, TRUE)
	return ITEM_INTERACT_SUCCESS

/obj/item/slimecross/prismatic/grey
	slime_type = /datum/slime_type/grey
	desc = "It's constantly wet with a pungent-smelling, clear chemical."

/obj/item/slimecross/prismatic/grey/interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	if(isturf(interacting_with) && interacting_with.color != initial(interacting_with.color))
		user.do_attack_animation(interacting_with)
		interacting_with.remove_atom_colour(WASHABLE_COLOUR_PRIORITY)
		playsound(interacting_with, 'sound/effects/slosh.ogg', 20, TRUE)
		return ITEM_INTERACT_SUCCESS
	return ..()

/obj/item/slimecross/prismatic/orange
	paintcolor = "#FFA500"
	slime_type = /datum/slime_type/orange

/obj/item/slimecross/prismatic/purple
	paintcolor = "#B19CD9"
	slime_type = /datum/slime_type/purple

/obj/item/slimecross/prismatic/blue
	paintcolor = "#ADD8E6"
	slime_type = /datum/slime_type/blue

/obj/item/slimecross/prismatic/metal
	paintcolor = "#7E7E7E"
	slime_type = /datum/slime_type/metal

/obj/item/slimecross/prismatic/yellow
	paintcolor = "#FFFF00"
	slime_type = /datum/slime_type/yellow

/obj/item/slimecross/prismatic/darkpurple
	paintcolor = "#551A8B"
	slime_type = /datum/slime_type/darkpurple

/obj/item/slimecross/prismatic/darkblue
	paintcolor = "#0000FF"
	slime_type = /datum/slime_type/darkblue

/obj/item/slimecross/prismatic/silver
	paintcolor = "#D3D3D3"
	slime_type = /datum/slime_type/silver

/obj/item/slimecross/prismatic/bluespace
	paintcolor = "#32CD32"
	slime_type = /datum/slime_type/bluespace

/obj/item/slimecross/prismatic/sepia
	paintcolor = "#704214"
	slime_type = /datum/slime_type/sepia

/obj/item/slimecross/prismatic/cerulean
	paintcolor = "#2956B2"
	slime_type = /datum/slime_type/cerulean

/obj/item/slimecross/prismatic/pyrite
	paintcolor = "#FAFAD2"
	slime_type = /datum/slime_type/pyrite

/obj/item/slimecross/prismatic/red
	paintcolor = "#FF0000"
	slime_type = /datum/slime_type/red

/obj/item/slimecross/prismatic/green
	paintcolor = "#00FF00"
	slime_type = /datum/slime_type/green

/obj/item/slimecross/prismatic/pink
	paintcolor = "#FF69B4"
	slime_type = /datum/slime_type/pink

/obj/item/slimecross/prismatic/gold
	paintcolor = "#FFD700"
	slime_type = /datum/slime_type/gold

/obj/item/slimecross/prismatic/oil
	paintcolor = "#505050"
	slime_type = /datum/slime_type/oil

/obj/item/slimecross/prismatic/black
	paintcolor = "#000000"
	slime_type = /datum/slime_type/black

/obj/item/slimecross/prismatic/lightpink
	paintcolor = "#FFB6C1"
	slime_type = /datum/slime_type/lightpink

/obj/item/slimecross/prismatic/adamantine
	paintcolor = "#008B8B"
	slime_type = /datum/slime_type/adamantine

/obj/item/slimecross/prismatic/rainbow
	paintcolor = "#FFFFFF"
	slime_type = /datum/slime_type/rainbow

/obj/item/slimecross/prismatic/rainbow/attack_self(mob/user)
	var/newcolor = tgui_color_picker(user, "Choose the slime color:", "Color change", paintcolor)
	if(user.get_active_held_item() != src || user.stat != CONSCIOUS || HAS_TRAIT(user, TRAIT_HANDS_BLOCKED))
		return
	if(!newcolor)
		return
	paintcolor = newcolor
	return
