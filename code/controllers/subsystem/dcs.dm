PROCESSING_SUBSYSTEM_DEF(dcs)
	name = "Datum Component System"
	flags = SS_NO_INIT | SS_HIBERNATE
	wait = 1 SECONDS

	var/list/elements_by_type = list()

/datum/controller/subsystem/processing/dcs/Recover()
	_listen_lookup = SSdcs._listen_lookup

/datum/controller/subsystem/processing/dcs/proc/GetElement(list/arguments)
	var/datum/element/eletype = arguments[1]
	var/element_id = eletype

	if(!ispath(eletype, /datum/element))
		CRASH("Attempted to instantiate [eletype] as a /datum/element")

	if(initial(eletype.element_flags) & ELEMENT_BESPOKE)
		element_id = GetIdFromArguments(arguments)

	. = elements_by_type[element_id]
	if(.)
		return
	. = elements_by_type[element_id] = new eletype

/****
	* Generates an id for bespoke elements when given the argument list
	* Generating the id here is a bit complex because we need to support named arguments
	* Named arguments can appear in any order and we need them to appear after ordered arguments
	* We assume that no one will pass in a named argument with a value of null
	**/
/datum/controller/subsystem/processing/dcs/proc/GetIdFromArguments(list/arguments)
	var/datum/element/eletype = arguments[1]
	var/list/fullid = list("[eletype]")
	var/list/named_arguments = list()

	for(var/i in initial(eletype.argument_hash_start_idx) to length(arguments))
		var/key = arguments[i]

		if(istext(key))
			var/value = arguments[key]
			if (isnull(value))
				fullid += key
			else
				if (!istext(value) && !isnum(value))
					value = REF(value)
				named_arguments[key] = value

			continue

		if (isnum(key))
			fullid += "[key]"
		else
			fullid += REF(key)

	if(named_arguments)
		sortTim(named_arguments, GLOBAL_PROC_REF(cmp_text_asc))
		fullid += named_arguments

	return list2params(fullid)

/datum/controller/subsystem/processing/dcs/proc/_Has_Element(atom/checker, datum/element/element_id)
	var/datum/element/eletype = elements_by_type[element_id]
	if(!eletype)
		return FALSE //not yet created simply return FALSE

	if(!(checker in eletype?._signal_procs)) //shitcode beware
		return FALSE
	return TRUE
