///sent from borg recharge stations: (amount, repairs)
#define COMSIG_PROCESS_BORGCHARGER_OCCUPANT "living_charge"
///sent from borg mobs to itself, for tools to catch an upcoming destroy() due to safe decon (rather than detonation)
#define COMSIG_BORG_SAFE_DECONSTRUCT "borg_safe_decon"

/// Sent from [/obj/machinery/computer/robotics/proc/unlock_cyborg] when a robotics console tries to unlock the cyborg: (obj/machinery/computer/robotics/unlocking_console)
#define COMSIG_CYBORG_LOCKDOWN_CONSOLE_UNLOCK_ATTEMPT "cyborg_lockdown_console_attempt"
	// Stops further action for the robotic console's lockdown attempt.
	#define CYBORG_LOCKDOWN_CONSOLE_INTERCEPTED (1 << 0)

/// Sent from [/mob/living/silicon/robot/proc/try_lockdown] if the cyborg was successfully unlocked: ()
#define COMSIG_CYBORG_LOCKDOWN_UNLOCK "cyborg_lockdown_unlock"
