/datum/round_event_control/bureaucratic_error
	name = "Bureaucratic Error"
	typepath = /datum/round_event/bureaucratic_error
	max_occurrences = 1
	weight = 5
	category = EVENT_CATEGORY_BUREAUCRATIC
	description = "Randomly opens and closes job slots, along with changing the overflow role."
	track = EVENT_TRACK_MAJOR // if you've ever dealt with 10 mimes you understand why.
	tags = list(TAG_COMMUNAL)
	event_group = /datum/event_group/error

/datum/round_event/bureaucratic_error
	announce_when = 1

/datum/round_event/bureaucratic_error/announce(fake)
	priority_announce("A recent bureaucratic error in the Organic Resources Department may result in personnel shortages in some departments and redundant staffing in others.", "Paperwork Mishap Alert")

/datum/round_event/bureaucratic_error/start()
	var/list/jobs = SSjob.get_valid_overflow_jobs()
	var/list/overflowable_jobs = list()
	for(var/datum/job/possible_overflow as anything in jobs)
		if(possible_overflow.allow_overflow)
			overflowable_jobs += possible_overflow
	if(length(overflowable_jobs) && prob(33)) // Only allows latejoining as a single role.
		var/datum/job/overflow = pick(overflowable_jobs)
		jobs -= overflow
		overflow.spawn_positions = -1
		overflow.total_positions = -1 // Ensures infinite slots as this role. Assistant will still be open for those that cant play it.
		for(var/job in jobs)
			var/datum/job/current = job
			var/ran = rand(-2,4) //MONKESTATION CHANGE: REMOVE(current.total_positions = 0) ADD: var/ran = rand(-2,4)
			current.total_positions = max(current.total_positions + ran, 1) //MONKESTATION ADDITION
	else // Adds/removes a random amount of job slots from all jobs.
		for(var/datum/job/current as anything in jobs)
			var/ran = rand(-2,4)
			current.total_positions = max(current.total_positions + ran, 1) //MONKESTATION CHANGE: ran, 0) ==> ran, 1)
