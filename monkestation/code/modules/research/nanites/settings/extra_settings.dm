/datum/nanite_extra_setting
	var/setting_type
	var/value

/datum/nanite_extra_setting/proc/get_value()
	return value

/datum/nanite_extra_setting/proc/set_value(value)
	src.value = value

/datum/nanite_extra_setting/proc/get_copy()
	return

//I made the choice to send the name as part of the parameter instead of storing it directly on
//this datum as a way of avoiding duplication of data between the containing assoc list
//and this datum.
//Also make sure to double wrap the list when implementing this as
//+= is interpreted as a combine on lists, so the outer list gets unwrapped
/datum/nanite_extra_setting/proc/get_frontend_list(name)
	return

/**
 * Boolean
 */
/datum/nanite_extra_setting/boolean
	setting_type = NESTYPE_BOOLEAN
	var/true_text
	var/false_text

/datum/nanite_extra_setting/boolean/New(initial, true_text, false_text)
	value = initial
	src.true_text = true_text
	src.false_text = false_text

/datum/nanite_extra_setting/boolean/set_value(value)
	if(isnull(value))
		src.value = !src.value
		return
	. = ..()

/datum/nanite_extra_setting/boolean/get_copy()
	return new /datum/nanite_extra_setting/boolean(value, true_text, false_text)

/datum/nanite_extra_setting/boolean/get_frontend_list(name)
	return list(list(
		"name" = name,
		"type" = setting_type,
		"value" = value,
		"true_text" = true_text,
		"false_text" = false_text,
	))

/**
 * Number
 */
/datum/nanite_extra_setting/number
	setting_type = NESTYPE_NUMBER
	var/min
	var/max
	var/unit = ""

/datum/nanite_extra_setting/number/New(initial, min, max, unit)
	value = initial
	src.min = min
	src.max = max
	if(unit)
		src.unit = unit

/datum/nanite_extra_setting/number/set_value(value)
	if(istext(value))
		value = text2num(value)
	if(!value || !isnum(value))
		return
	src.value = clamp(value, min, max)

/datum/nanite_extra_setting/number/get_copy()
	return new /datum/nanite_extra_setting/number(value, min, max, unit)

/datum/nanite_extra_setting/number/get_frontend_list(name)
	return list(list(
		"name" = name,
		"type" = setting_type,
		"value" = value,
		"min" = min,
		"max" = max,
		"unit" = unit,
	))
