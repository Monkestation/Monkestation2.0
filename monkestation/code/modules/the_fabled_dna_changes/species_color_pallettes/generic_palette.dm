/datum/color_palette/generic_colors
	var/hair_color
	var/mutant_color
	var/mutant_color_secondary
	///Color of Monkey and Simian's fur, defaulted to Monkey-Brown.
	var/fur_color = COLOR_MONKEY_BROWN
	var/ethereal_color
	var/pod_color = COLOR_VERY_DARK_LIME_GREEN

/datum/color_palette/generic_colors/apply_prefs(datum/preferences/incoming)
	hair_color = incoming.read_preference(/datum/preference/color/hair_color)
	mutant_color = incoming.read_preference(/datum/preference/color/mutant_color)
	mutant_color_secondary = incoming.read_preference(/datum/preference/color/mutant_color_secondary)
	fur_color = incoming.read_preference(/datum/preference/color/fur_color)
	ethereal_color =  GLOB.color_list_ethereal[incoming.read_preference(/datum/preference/choiced/ethereal_color)]
	pod_color = incoming.read_preference(/datum/preference/color/pod_color)

