/// Dynamic value for source-based multipliers and increments.
/// Should be performant enough for 90% of applications.
/datum/modifier
	VAR_PROTECTED/base_value

	/// Lazylist of multiplicatives.
	VAR_PROTECTED/list/multiplicative
	/// Lazylist of additives.
	VAR_PROTECTED/list/additive

	VAR_PROTECTED/cached_multiplier
	VAR_PROTECTED/cached_increment
	VAR_PROTECTED/cached_value

/datum/modifier/New(base_value = 1)
	src.base_value = base_value
	cached_value = base_value

/// Sets the base value.
/datum/modifier/proc/set_base_value(value)
	if(base_value == value)
		return
	base_value = value
	if(isnull(cached_multiplier) || cached_multiplier != 0) // anything multiplied by 0 is 0
		decache_value()

/// Gets the base value.
/datum/modifier/proc/get_base_value()
	return base_value

/// Sets the value of a multiplicative.
/datum/modifier/proc/set_multiplicative(source, value)
	if(isnull(value) || value == 1)
		clear_multiplicative(source)
		return
	if(get_multiplicative(source) == value)
		return
	LAZYSET(multiplicative, source, value)
	decache_multiplier()

/// Gets the value of a multiplicative. Defaults to 1.
/datum/modifier/proc/get_multiplicative(source)
	var/value = LAZYACCESS(multiplicative, source)
	return isnull(value) ? 1 : value

/// Clears the value of a multiplicative.
/datum/modifier/proc/clear_multiplicative(source)
	if(!LAZYACCESS(multiplicative, source))
		return
	LAZYREMOVE(multiplicative, source)
	decache_multiplier()

/// Sets the value of an additive.
/datum/modifier/proc/set_additive(source, value)
	if(isnull(value) || value == 0)
		clear_additive(source)
		return
	if(get_additive(source) == value)
		return
	LAZYSET(additive, source, value)
	decache_increment()

/// Gets the value of an additive. Defaults to 0.
/datum/modifier/proc/get_additive(source)
	var/value = LAZYACCESS(additive, source)
	return isnull(value) ? 0 : value

/// Clears the value of an additive.
/datum/modifier/proc/clear_additive(source)
	if(!LAZYACCESS(additive, source))
		return
	LAZYREMOVE(additive, source)
	decache_increment()

/// Returns the final multiplier.
/datum/modifier/proc/get_multiplier()
	if(isnull(cached_multiplier))
		update_multiplier()
	return cached_multiplier

/// Updates the cached multiplier. Done automatically.
/datum/modifier/proc/update_multiplier()
	PROTECTED_PROC(TRUE)

	var/value = 1
	for(var/source as anything in multiplicative)
		value *= multiplicative[source]
	cached_multiplier = value

/// Invalidates the cached multiplier.
/datum/modifier/proc/decache_multiplier()
	cached_multiplier = null
	if (isnull(cached_increment) || cached_increment != -base_value) // anything multiplied by 0 is 0
		decache_value()

/// Returns the final increment.
/datum/modifier/proc/get_increment()
	if(isnull(cached_increment))
		update_increment()
	return cached_increment

/// Updates the cached increment.
/datum/modifier/proc/update_increment()
	PROTECTED_PROC(TRUE)

	var/value = 0
	for(var/source as anything in additive)
		value += additive[source]
	cached_increment = value

/// Invalidates the cached increment.
/datum/modifier/proc/decache_increment()
	cached_increment = null
	if (isnull(cached_multiplier) || cached_multiplier != 0) // anything multiplied by 0 is 0
		decache_value()

/// Returns the final value.
/datum/modifier/proc/get_value()
	if(isnull(cached_value))
		update_value()
	return cached_value

/// Updates the cached value.
/datum/modifier/proc/update_value()
	PROTECTED_PROC(TRUE)

	var/value = base_value
	value += get_increment()
	value *= get_multiplier()
	cached_value = value

/// Invalidates the cached value.
/datum/modifier/proc/decache_value()
	PROTECTED_PROC(TRUE)

	var/old_value = cached_value
	cached_value = null

	SEND_SIGNAL(src, COMSIG_MODIFIER_VALUE_CHANGED, old_value)
