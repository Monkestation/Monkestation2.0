/datum/component/bane_inducing
	dupe_mode = COMPONENT_DUPE_UNIQUE_PASSARGS
	/// i hate i have to do this i hate i hate i hate please someone make electroplating etc. sane but whatever fuck it sure
	var/list/datum/material/mats_we_pretend_to_be

/datum/component/bane_inducing/Initialize(datum/target, mats_we_pretend_to_be=/datum/material/silver)
	. = ..()
	if(!islist(mats_we_pretend_to_be))
		var/list/datum/material/dem_mats = list(mats_we_pretend_to_be)
		src.mats_we_pretend_to_be = dem_mats
	else
		src.mats_we_pretend_to_be = mats_we_pretend_to_be

/datum/component/bane_inducing/InheritComponent(datum/component/bane_inducing/new_comp, original, mats_we_pretend_to_be)
	if(!original)
		return
	if(mats_we_pretend_to_be)
		if(!islist(mats_we_pretend_to_be))
			var/list/datum/material/dem_mats = list(mats_we_pretend_to_be)
			src.mats_we_pretend_to_be += dem_mats
		else
			src.mats_we_pretend_to_be += mats_we_pretend_to_be
