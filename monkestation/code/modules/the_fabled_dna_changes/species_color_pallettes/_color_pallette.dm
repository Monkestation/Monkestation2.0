/datum/color_palette
	var/default_color = "#FFFFFF"

///override this if you need to check if the color can be applied
/datum/color_palette/proc/is_viable_color(color)
	return TRUE

///this is where we apply colors to our palette from our prefs
/datum/color_palette/proc/apply_prefs(datum/preferences/incoming)
	CRASH("Please Override apply_prefs on your color palette")

///this takes 2 inputs varname and mainvar. mainvar is optional but if varname is null trys to return maincolor
/datum/color_palette/proc/return_color(varname, mainvar)
	if(!varname && !mainvar)
		return default_color

	var/retrieved_var = vars[varname]
	if(!retrieved_var)
		if(mainvar)
			retrieved_var = vars[mainvar]
			if(retrieved_var)
				return retrieved_var
		return default_color

	return retrieved_var

/// Creates a new copy of this color palette, with the same type and the same values.
/datum/color_palette/proc/make_copy() as /datum/color_palette
	var/static/list/vars_to_ignore
	if(isnull(vars_to_ignore))
		var/datum/base = new
		vars_to_ignore = assoc_to_keys(base.vars)
	var/datum/color_palette/new_palette = new type
	for(var/name, value in vars)
		if(name in vars_to_ignore)
			continue
		new_palette.vars[name] = value
	return new_palette
