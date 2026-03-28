/obj/item/heartstring_extractor
	name = "heart-string extractor"
	desc = "This specially treated pair of scissors has been saturated with the energy of the quintessential cotton, helping to preserve Heart-strings and Shape-strings when used to excise them."
	icon = 'monkestation/code/modules/blueshift/icons/items.dmi'
	icon_state = "scissors"
	w_class = WEIGHT_CLASS_SMALL
	sharpness = SHARP_EDGED
	force = 1

/obj/item/heartstring
	name = "\improper Heart-strings"
	desc = "A bundle of woven cotton fibres. The vivifying crux of a plush, along with both its Soul-string and any adjoining Shape-strings. Without its Heart-string, a plushie's spirit is lost."
	icon = 'icons/obj/toys/plushes.dmi'
	icon_state = "heartstring"
	var/datum/weakref/our_plush
	var/list/datum/plush_trait/shape_strings = list()
	w_class = WEIGHT_CLASS_SMALL
	resistance_flags = INDESTRUCTIBLE //love is indestructable except for when it's not

/obj/item/heartstring/attackby(obj/item/attacking_item, mob/user, list/modifiers, list/attack_modifiers)
	if(istype(attacking_item, /obj/item/heartstring_extractor))
		if(!shape_strings)
			to_chat(user, span_warning("The Soul-string is bereft of Shape-strings."))
			return
		var/list/shape_string_names = list()
		for(var/datum/plush_trait/possible_string in shape_strings)
			if(possible_string.removable)
				shape_string_names[possible_string.name] = possible_string
		if(!shape_string_names.len)
			to_chat(user, span_warning("The only Shape-strings here are woven irreversably into the Soul-string."))
			return
		to_chat(user, span_notice("Select a Shape-string to cut from the Heart-string."))
		var/datum/plush_trait/shape_string_choice = shape_string_names[tgui_input_list(user, "Choose a string", "Plushtomization", shape_string_names)]
		var/obj/item/shapestring/extracted = new(get_turf(src))
		extracted.stored_trait = shape_string_choice
		if(shape_string_choice.shapestring_icon_state != "")
			extracted.icon_state = shape_string_choice.shapestring_icon_state
		extracted.name = "\improper [shape_string_choice.name] Shape-string"
		extracted.desc = "A thick cotton fibre. The sculpting energies of a plush. It moulds the quintessential Cotton into something more substantial, fueling the Cloth. This particular one [shape_string_choice.desc]"
		shape_strings.Remove(shape_string_choice)
	if(istype(attacking_item, /obj/item/shapestring))
		var/obj/item/shapestring/newstring = attacking_item
		for(var/datum/plush_trait/trait_to_check in shape_strings)
			if(is_type_in_list(newstring.stored_trait, trait_to_check::incompatible_traits) || is_type_in_list(trait_to_check, newstring.stored_trait::incompatible_traits))
				to_chat(user, span_warning("[newstring.stored_trait::name] is incompatible with [trait_to_check::name]!"))
				return
			if(is_type_in_list(newstring.stored_trait, shape_strings))
				to_chat(user, span_warning("[src] already contain a [newstring.stored_trait::name] Shape-string. No stacking."))
				return
		shape_strings += newstring.stored_trait
		user.visible_message(span_notice("[user] weaves [newstring] into [src]."), span_notice("You integrate [newstring] into [src]' Soul-string."))
		newstring.stored_trait = null
		qdel(newstring)

/obj/item/shapestring
	name = "\improper Shape-string"
	desc = "A thick cotton fibre. The sculpting and binding energies of a plush. It moulds the quintessential Cotton into something more substantial, fueling the Cloth."
	icon = 'icons/obj/toys/plushes.dmi'
	icon_state = "shapestring"
	w_class = WEIGHT_CLASS_TINY
	var/datum/plush_trait/stored_trait
	resistance_flags = INDESTRUCTIBLE // The soul is also indestructable, maybe. I'm not sure. I think Buddhism answers that. Someone go check.
