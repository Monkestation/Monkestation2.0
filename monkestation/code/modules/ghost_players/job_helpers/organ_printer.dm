/obj/structure/organ_creator
	name = "all in one organic medical fabricator"
	desc = "Capable of making all organs and bodyparts needed for practitioners to fix up bodies."
	resistance_flags = INDESTRUCTIBLE
	anchored = TRUE
	icon = 'icons/obj/money_machine.dmi'
	icon_state = "bogdanoff"
	/// Associative list of categories to a list of valid organs for that category.
	var/static/list/organ_choices

/obj/structure/organ_creator/Initialize(mapload)
	. = ..()
	if(isnull(organ_choices))
		organ_choices = list(
			"External Organs" = generate_organ_choices(/obj/item/organ/external),
			"Internal Organs" = generate_organ_choices(
				/obj/item/organ/internal,
				typecacheof(list(
					/obj/item/organ/internal/zombie_infection,
					/obj/item/organ/internal/alien,
					/obj/item/organ/internal/body_egg,
					/obj/item/organ/internal/heart/gland,
					/obj/item/organ/internal/butt/atomic,
					/obj/item/organ/internal/borer_body,
					/obj/item/organ/internal/empowered_borer_egg,
					/obj/item/organ/internal/legion_tumour,
					/obj/item/organ/internal/ears/cat/super,
				),
			)),
			"Bodyparts" = generate_organ_choices(/obj/item/bodypart),
		)


/obj/structure/organ_creator/attack_hand(mob/living/user, list/modifiers)
	. = ..()
	var/choice = tgui_input_list(user, "What do you wish to fabricate?", "[name]", assoc_to_keys(organ_choices))
	if(!choice)
		return
	var/list/choice_list = organ_choices[choice]
	if(!choice_list)
		return

	var/atom/second_choice = tgui_input_list(user, "Choose what to fabricate", "[choice]", choice_list)
	if(!second_choice || !ispath(second_choice, /obj/item))
		return

	new second_choice(drop_location())
	say("Organic Matter Fabricated")
	playsound(src, 'sound/machines/ding.ogg', vol = 50, vary = TRUE)


/obj/structure/organ_creator/attackby(obj/item/attacking_item, mob/user, params)
	. = ..()
	if(!istype(attacking_item, /obj/item/organ) || !istype(attacking_item, /obj/item/bodypart))
		return
	if(istype(attacking_item, /obj/item/organ/internal/brain))
		return
	qdel(attacking_item)
	say("Organic Matter Reclaimed")
	playsound(src, 'sound/machines/ding.ogg', vol = 50, vary = TRUE)

/obj/structure/organ_creator/proc/generate_organ_choices(obj/item/organ/base_type, list/blacklist)
	. = list()
	var/is_organ = ispath(base_type, /obj/item/organ) // stupid thing so we can also iterate thru /obj/item/bodypart
	for(var/obj/item/organ/organ as anything in subtypesof(base_type))
		if(is_type_in_typecache(organ, blacklist))
			continue
		if(is_organ && isnull(organ::slot))
			continue
		if(organ::name == base_type::name)
			continue
		. += organ
