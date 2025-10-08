///Legacy name - now refers to the time between free levels for vampires.
#define TIME_BLOODSUCKER_NIGHT 600

SUBSYSTEM_DEF(sol)
	name = "Sol"
	can_fire = FALSE
	wait = 20 // ticks, not seconds (so this runs every second, actually)
	flags = SS_NO_INIT | SS_BACKGROUND | SS_TICKER | SS_KEEP_TIMING

	///The time between the next cycle.
	var/time_til_cycle = TIME_BLOODSUCKER_NIGHT
	///If Bloodsucker levels for the night has been given out yet.
	var/issued_XP = FALSE

/datum/controller/subsystem/sol/Recover()
	can_fire = SSsol.can_fire
	time_til_cycle = SSsol.time_til_cycle
	issued_XP = SSsol.issued_XP

/datum/controller/subsystem/sol/fire(resumed = FALSE)
	time_til_cycle--

	if (time_til_cycle > 0 && time_til_cycle <= 15)
		if (!issued_XP)
			issued_XP = TRUE
			SEND_SIGNAL(src, COMSIG_SOL_RANKUP_BLOODSUCKERS)

	if (time_til_cycle < 1)
		issued_XP = FALSE
		time_til_cycle = TIME_BLOODSUCKER_NIGHT

#undef TIME_BLOODSUCKER_NIGHT
