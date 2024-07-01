/// called on implants, before an implant has been removed: (mob/living/source, silent, special)
#define COMSIG_PRE_IMPLANT_REMOVED "pre_implant_removed"
	/// Stops the call of removed() on the implant
	#define COMPONENT_STOP_IMPLANT_REMOVAL (1<<0)
