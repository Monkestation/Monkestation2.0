/mob/living/basic/isaac //default color is red, others are defined below
	name = "isaac"
	desc = "What are you doing here?"
	icon = 'monkestation/code/modules/biodome/icons/isaac.dmi'
	icon_state = "isaac"
	icon_living = "isaac"
	icon_dead = "isaac_dead"
	speed = 1
	response_help_continuous = "bumps"
	response_help_simple = "bump"
	response_disarm_continuous = "pushes aside"
	response_disarm_simple = "push aside"
	response_harm_continuous = "attacks"
	response_harm_simple = "attack"
	speak_emote = list("communicates")
	maxHealth = 25
	health = 25
	friendly_verb_continuous = "nudges"
	friendly_verb_simple = "nudge"
	mob_biotypes = MOB_ORGANIC
	gold_core_spawnable = FRIENDLY_SPAWN
	verb_say = "communicates"
	verb_ask = "communicates"
	verb_exclaim = "communicates"
	verb_yell = "communicates"
	gender = NEUTER
	held_items = list(null, null)
	greyscale_colors = "#ffffff"
	ai_controller = /datum/ai_controller/basic_controller/amoung
	// They're wearing space suits
	unsuitable_atmos_damage = 0
	unsuitable_cold_damage = 0
	unsuitable_heat_damage = 0
	/// List of possible amongus colours.

/obj/item/structure/fluff/item_altar
	name = "item altar"
	desc = "How do I use these?"

	icon = 'monkestation/code/modules/biodome/icons/isaac.dmi'
	icon_state = "item_altar"
	anchored = TRUE

	var/picked_icon_state = "0,1"
	var/obj/effect/abstract/item_holder/item

/obj/item/structure/fluff/item_altar/Initialize(mapload)
	. = ..()
	pick_random_item()


/obj/item/structure/fluff/item_altar/proc/pick_random_item()
	picked_icon_state = "[rand(0,19)],[rand(1,27)]"
	if(!item)
		item = new
		item.pixel_y += 12
		src.vis_contents += item
		item.add_animation_step_list(list("pixel_y" = item.pixel_y + 4, "loop" = -1, "time" = 0.3 SECONDS))
		item.add_animation_step_list(list("pixel_y" = item.pixel_y - 4, "time" = 0.3 SECONDS))

	item.icon_state = picked_icon_state

/obj/effect/abstract/item_holder
	name = ""
	icon = 'monkestation/code/modules/biodome/icons/isaac.dmi'
	anchored = TRUE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
