//These macros are used to define all verbs that mentor datums get. Macros defined here ARE NOT shared with ADMIN_VERB macros so if you
//need similar functionality for admins make it using the ADMIN_VERB macro.
//The verb_name must be different from any other verbs with a similar name otherwise only one will show up.
//Admin Verb macros defines in [code\__DEFINES\admin_verb.dm]
#define _MENTOR_VERB(verb_path_name, verb_permissions, exact_permissions, verb_name, verb_desc, verb_category, show_in_context_menu, verb_args...) \
/datum/mentor_verb/##verb_path_name \
{ \
	name = ##verb_name; \
	description = ##verb_desc; \
	category = ##verb_category; \
	permissions = ##verb_permissions; \
	match_exact_permissions = ##exact_permissions; \
	verb_path = /client/proc/__avd_##verb_path_name; \
}; \
/client/proc/__avd_##verb_path_name(##verb_args) \
{ \
	set name = ##verb_name; \
	set desc = ##verb_desc; \
	set hidden = FALSE; /* this is explicitly needed as the proc begins with an underscore */ \
	set popup_menu = ##show_in_context_menu; \
	set category = ##verb_category; \
	var/list/_verb_args = list(usr, /datum/mentor_verb/##verb_path_name); \
	_verb_args += args; \
	SSadmin_verbs.dynamic_invoke_mentor_verb(arglist(_verb_args)); \
}; \
/datum/mentor_verb/##verb_path_name/__avd_do_verb(client/user, ##verb_args)


#define MENTOR_VERB(verb_path_name, verb_permissions, exact_permissions, verb_name, verb_desc, verb_category, verb_args...) \
_MENTOR_VERB(verb_path_name, verb_permissions, exact_permissions, verb_name, verb_desc, verb_category, FALSE, ##verb_args)

#define MENTOR_VERB_ONLY_CONTEXT_MENU(verb_path_name, exact_permissions, verb_permissions, verb_name, verb_args...) \
_MENTOR_VERB(verb_path_name, verb_permissions, exact_permissions, verb_name, ADMIN_VERB_NO_DESCRIPTION, ADMIN_CATEGORY_HIDDEN, TRUE, ##verb_args)

#define MENTOR_VERB_AND_CONTEXT_MENU(verb_path_name, exact_permissions, verb_permissions, verb_name, verb_desc, verb_category, verb_args...) \
_MENTOR_VERB(verb_path_name, verb_permissions, exact_permissions, verb_name, verb_desc, verb_category, TRUE, ##verb_args)

/// Used to define a special check to determine if the mentor verb should exist at all. Useful for verbs such as play sound which require configuration.
#define MENTOR_VERB_CUSTOM_EXIST_CHECK(verb_path_name) \
/datum/mentor_verb/##verb_path_name/__avd_check_should_exist()

/// Used to define the visibility flag of the verb. If the mentor does not have this flag enabled they will not see the verb.
#define MENTOR_VERB_VISIBILITY(verb_path_name, verb_visibility) /datum/mentor_verb/##verb_path_name/visibility_flag = ##verb_visibility

// These are put here to prevent the "procedure override precedes definition" error.
/datum/mentor_verb/proc/__avd_get_verb_path() //I have yet to figure out what this is used for.
	CRASH("__avd_get_verb_path not defined. use the macro")
/datum/mentor_verb/proc/__avd_do_verb(...)
	CRASH("__avd_do_verb not defined. use the macro")
/datum/mentor_verb/proc/__avd_check_should_exist()
	return TRUE

// Mentor verb categories
#define MENTOR_CATEGORY_MAIN "Mentor"
