/// The minimum client BYOND build to disable screentip icons for.
#define MIN_BYOND_BUILD_DISABLE_SCREENTIP_ICONS 1657
/// The maximum client BYOND build to disable screentip icons for.
/// Update this whenever https://www.byond.com/forum/post/2967731 is fixed.
#define MAX_BYOND_BUILD_DISABLE_SCREENTIP_ICONS 1699

/// Checks if the given target is either a client or a mock client
#define IS_CLIENT_OR_MOCK(target) (istype(target, /client) || istype(target, /datum/client_interface))

/// Ensures that the client has been fully initialized via New(), and can't somehow execute actions before that. Security measure.
/// WILL RETURN OUT OF THE ENTIRE PROC COMPLETELY IF THE CLIENT IS NOT FULLY INITIALIZED. BE WARNED IF YOU WANT RETURN VALUES.
#define VALIDATE_CLIENT(target)\
	if (!target.fully_created) {\
		to_chat(target, span_warning("You are not fully initialized yet! Please wait a moment."));\
		log_access("Client [key_name(target)] attempted to execute a verb before being fully initialized.");\
		return\
	}
