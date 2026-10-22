/datum/quirk/lisp
	name = "Lisp"
	desc = "You have a hard time pronoucing thome letterth."
	value = -2
	icon = FA_ICON_GRIN_TONGUE

/datum/quirk/lisp/add()
	RegisterSignal(quirk_holder, COMSIG_MOB_SAY, PROC_REF(handle_speech))

/datum/quirk/lisp/remove()
	UnregisterSignal(quirk_holder, COMSIG_MOB_SAY)

/datum/quirk/lisp/proc/handle_speech(datum/source, list/speech_args)
	SIGNAL_HANDLER
	if(HAS_TRAIT(source, TRAIT_SIGN_LANG))
		return
	var/message = speech_args[SPEECH_MESSAGE]
	if(message)
		message = replacetext(message,"s","th")
		speech_args[SPEECH_MESSAGE] = message
