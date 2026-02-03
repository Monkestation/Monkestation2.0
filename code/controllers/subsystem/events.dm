SUBSYSTEM_DEF(events)
	name = "Events"
	init_order = INIT_ORDER_EVENTS
	runlevels = RUNLEVEL_GAME

	var/list/control = list() //list of all datum/round_event_control. Used for selecting events based on weight and occurrences.
	var/list/running = list() //list of all existing /datum/round_event
	var/list/currentrun = list()

	var/scheduled = 0 //The next world.time that a naturally occuring random event can be selected.
	var/frequency_lower = 1800 //3 minutes lower bound.
	var/frequency_upper = 6000 //10 minutes upper bound. Basically an event will happen every 3 to 10 minutes.

/datum/controller/subsystem/events/Initialize()
	for(var/datum/round_event_control/event_type as anything in typesof(/datum/round_event_control))
		if(!event_type::typepath || !event_type::name)
			continue
		var/datum/round_event_control/event = new event_type
		if(!event.valid_for_map())
			qdel(event) //highly iffy on this as it does cause issues for admins sometimes
			continue
		control += event //add it to the list of all events (controls)
	// Instantiate our holidays list if it hasn't been already
	if(isnull(GLOB.holidays))
		fill_holidays()
	return SS_INIT_SUCCESS

/datum/controller/subsystem/events/fire(resumed = FALSE)
	if(!resumed)
		src.currentrun = running.Copy()

	//cache for sanic speed (lists are references anyways)
	var/list/currentrun = src.currentrun

	while(length(currentrun))
		var/datum/thing = currentrun[length(currentrun)]
		currentrun.len--
		if(thing)
			thing.process(wait * 0.1)
		else
			running.Remove(thing)
		if (MC_TICK_CHECK)
			return

/datum/controller/subsystem/events/proc/resetFrequency()
	frequency_lower = initial(frequency_lower)
	frequency_upper = initial(frequency_upper)

/**
 * HOLIDAYS
 *
 * Uncommenting ALLOW_HOLIDAYS in config.txt will enable holidays
 *
 * It's easy to add stuff. Just add a holiday datum in code/modules/holiday/holidays.dm
 * You can then check if it's a special day in any code in the game by calling check_holidays("Groundhog Day")
 *
 * You can also make holiday random events easily thanks to Pete/Gia's system.
 * simply make a random event normally, then assign it a holidayID string which matches the holiday's name.
 * Anything with a holidayID, which isn't in the holidays list, will never occur.
 *
 * Please, Don't spam stuff up with stupid stuff (key example being april-fools Pooh/etc),
 * and don't forget: CHECK YOUR CODE!!!! We don't want any zero-day bugs which happen only on holidays and never get found/fixed!
 */
GLOBAL_LIST(holidays)

/**
 * Checks that the passed holiday is located in the global holidays list.
 *
 * Returns a holiday datum, or null if it's not that holiday.
 */
/proc/check_holidays(holiday_to_find)
	if(!CONFIG_GET(flag/allow_holidays))
		return // Holiday stuff was not enabled in the config!

	if(isnull(GLOB.holidays) && !fill_holidays())
		return // Failed to generate holidays, for some reason

	// We should allow one datum to have multiple holidays if it is applicable. Could be a community related thing.
	if(islist(holiday_to_find)) //MONKESTATION EDIT

		var/list/valid_holidays = list()
		for(var/holiday in holiday_to_find)
			if(GLOB.holidays[holiday])
				valid_holidays += GLOB.holidays[holiday]

			if(length(valid_holidays))
				return pick(valid_holidays) // Return a random valid holiday if multiple are found. Until all used checks can handle a list return.
			return

	return GLOB.holidays[holiday_to_find]

/**
 * Fills the holidays list if applicable, or leaves it an empty list.
 */
/proc/fill_holidays()
	if(!CONFIG_GET(flag/allow_holidays))
		return FALSE // Holiday stuff was not enabled in the config!

	GLOB.holidays = list()
	for(var/holiday_type in subtypesof(/datum/holiday))
		var/datum/holiday/holiday = new holiday_type()
		var/delete_holiday = TRUE
		for(var/timezone in holiday.timezones)
			var/time_in_timezone = world.realtime + timezone HOURS

			var/YYYY = text2num(time2text(time_in_timezone, "YYYY")) // get the current year
			var/MM = text2num(time2text(time_in_timezone, "MM")) // get the current month
			var/DD = text2num(time2text(time_in_timezone, "DD")) // get the current day
			var/DDD = time2text(time_in_timezone, "DDD") // get the current weekday

			if(holiday.shouldCelebrate(DD, MM, YYYY, DDD))
				holiday.celebrate()
				GLOB.holidays[holiday.name] = holiday
				delete_holiday = FALSE
				break
		if(delete_holiday)
			qdel(holiday)

	if(GLOB.holidays.len)
		shuffle_inplace(GLOB.holidays)
		// regenerate station name because holiday prefixes.
		set_station_name(new_station_name())
		world.update_status()

	return TRUE
