// Make sure that the code compiles with AI_VOX undefined
#ifdef AI_VOX

/mob/living/silicon/ai
	/// The currently selected VOX Announcer voice.
	var/vox_type = VOX_NORMAL
	/// The list of available VOX Announcer voices to choose from.
	var/list/vox_voices = list(VOX_HL, VOX_NORMAL, VOX_BMS, VOX_MIL) //MONKE CHANGE: non-malf AIs get VOX_MIL too. if theyre subverted or whatever may be thats NOT malf.
	/// The VOX word(s) that were previously inputed.
	var/vox_word_string

/// Returns a list of vox sounds based on the sound_type passed in
/mob/living/silicon/ai/proc/get_vox_sounds(vox_type)
	switch(vox_type)
		if(VOX_NORMAL)
			return GLOB.vox_sounds
		if(VOX_HL)
			return GLOB.vox_sounds_hl
		if(VOX_BMS)
			return GLOB.vox_sounds_bms
		if(VOX_MIL)
			return GLOB.vox_sounds_mil
	return GLOB.vox_sounds

/mob/living/silicon/ai/verb/switch_vox()
	set name = "Switch Vox Voice"
	set desc = "Switch your VOX announcement voice!"
	set category = "AI Commands"

	if(incapacitated())
		return
	var/selection = tgui_input_list(src, "Please select a new VOX voice:", "VOX VOICE", vox_voices)
	if(selection == null)
		return
	vox_type = selection

	to_chat(src, "Vox voice set to [vox_type]")


/mob/living/silicon/ai/verb/display_word_string()
	set name = "Display Word String"
	set desc = "Display the list of recently pressed vox lines."
	set category = "AI Commands"

	if(incapacitated())
		return

	to_chat(src, vox_word_string)

/mob/living/silicon/ai/verb/clear_word_string()
	set name = "Clear Word String"
	set desc = "Clear recent vox words."
	set category = "AI Commands"

	vox_word_string = ""

#endif
