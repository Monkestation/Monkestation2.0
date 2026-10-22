/proc/init_smites()
	var/list/smites = list()
	for (var/_smite_path in subtypesof(/datum/smite))
		var/datum/smite/smite_path = _smite_path
		smites[initial(smite_path.name)] = smite_path
	return smites

GLOBAL_LIST_INIT_TYPED(smites, /datum/smite, init_smites())

GLOBAL_VAR_INIT(admin_notice, "") // Admin notice that all clients see when joining the server

// A list of all the special byond lists that need to be handled different by vv
GLOBAL_LIST_INIT(vv_special_lists, init_special_list_names())

/proc/init_special_list_names()
	var/list/output = list()
	var/obj/sacrifice = new
	for(var/varname in sacrifice.vars)
		var/value = sacrifice.vars[varname]
		if(!islist(value))
			if(!isdatum(value) && hascall(value, "Cut"))
				output += varname
			continue
		if(isnull(locate(REF(value))))
			output += varname
	return output
