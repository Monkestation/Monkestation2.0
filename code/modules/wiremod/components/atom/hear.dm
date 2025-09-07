/**
 * # Hear Component
 *
 * Listens for messages. Requires a shell.
 */
/obj/item/circuit_component/hear
	display_name = "Voice Activator"
	desc = "A component that listens for messages. Requires a shell."
	category = "Entity"

	/// The message heard
	var/datum/port/output/message_port
	/// The language heard
	var/datum/port/output/language_port
	/// The speaker name port, usually the name of the person who spoke.
	var/datum/port/output/speaker_name
	/// The speaker entity that is currently speaking. Not necessarily the person who is speaking.
	var/datum/port/output/speaker_port
	/// The trigger sent when this event occurs
	var/datum/port/output/trigger_port

/obj/item/circuit_component/hear/populate_ports()
	message_port = add_output_port("Message", PORT_TYPE_STRING)
	language_port = add_output_port("Language", PORT_TYPE_STRING)
	speaker_port = add_output_port("Speaker", PORT_TYPE_ATOM)
	speaker_name = add_output_port("Speaker Name", PORT_TYPE_STRING)
	trigger_port = add_output_port("Triggered", PORT_TYPE_SIGNAL)
	become_hearing_sensitive(ROUNDSTART_TRAIT)

/obj/item/circuit_component/hear/register_shell(atom/movable/shell)
	if(parent.loc != shell)
		shell.become_hearing_sensitive(CIRCUIT_HEAR_TRAIT)
		RegisterSignal(shell, COMSIG_MOVABLE_HEAR, PROC_REF(on_shell_hear))

/obj/item/circuit_component/hear/unregister_shell(atom/movable/shell)
	REMOVE_TRAIT(shell, TRAIT_HEARING_SENSITIVE, CIRCUIT_HEAR_TRAIT)

/obj/item/circuit_component/hear/proc/on_shell_hear(datum/source, list/arguments)
	SIGNAL_HANDLER
	return Hear(arglist(arguments))

/obj/item/circuit_component/hear/Hear(message, atom/movable/speaker, datum/language/message_language, raw_message, radio_freq, list/spans, list/message_mods, message_range)
	if(speaker == parent?.shell)
		return

	var/output_message = html_decode(raw_message)
	if(message_language)
		var/language_output = message_language::name
		if(!(message_language in GLOB.roundstart_languages))
			var/datum/language/dialect = GLOB.language_datum_instances[message_language]
			output_message = dialect.scramble(output_message)
			if(dialect.flags & LANGUAGE_HIDE_ICON_IF_NOT_UNDERSTOOD)
				language_output = "Unknown Language"
		language_port.set_output(language_output)
	message_port.set_output(output_message)
	speaker_port.set_output(speaker)
	speaker_name.set_output(speaker.GetVoice())
	trigger_port.set_output(COMPONENT_SIGNAL)
