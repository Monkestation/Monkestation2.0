/datum/component/bane_inducing
	dupe_mode = COMPONENT_DUPE_UNIQUE_PASSARGS
	/// i hate i have to do this i hate i hate i hate please someone make electroplating etc. sane but whatever fuck it sure
	var/list/datum/material/mats_we_pretend_to_be

/datum/component/bane_inducing/Initialize(datum/target, mats_we_pretend_to_be=/datum/material/silver)
	. = ..()
	src.mats_we_pretend_to_be += islist(mats_we_pretend_to_be) ?  mats_we_pretend_to_be : list(mats_we_pretend_to_be)

/datum/component/bane_inducing/InheritComponent(datum/component/bane_inducing/new_comp, original, mats_we_pretend_to_be)
	if(!original)
		return
	if(mats_we_pretend_to_be)
		src.mats_we_pretend_to_be += islist( mats_we_pretend_to_be) ?  mats_we_pretend_to_be : list(mats_we_pretend_to_be)
