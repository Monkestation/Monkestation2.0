/mob/living/silicon/ai/Login()
	. = ..()
	if(!. || !client)
		return FALSE
	if(stat != DEAD)
		if(lacks_power() && apc_override) //Placing this in Login() in case the AI doesn't have this link for whatever reason.
			to_chat(usr, "[span_warning("Main power is unavailable, backup power in use. Diagnostics scan complete.")] <A href='byond://?src=[REF(src)];emergencyAPC=[TRUE]'>Local APC ready for connection.</A>")
	set_eyeobj_visible(TRUE)
	if(multicam_on)
		end_multicam()
	view_core()
	if(!login_warned_temp)
		to_chat(src, span_userdanger("WARNING. THE WAY AI IS PLAYED HAS CHANGED. PLEASE REFER TO THE NEWLY MERGED OR TESTMERGED AI PR. ALSO SHOUT AT ICE TYPE FOR NOT UPDATING THIS WITH A LINK"))
		login_warned_temp = TRUE
	INVOKE_ASYNC(src, PROC_REF(preload_vox_voices))
	show_laws(FALSE)

/// Preloads the `vox_voices.json` asset
/mob/living/silicon/ai/proc/preload_vox_voices()
	set waitfor = FALSE
	get_asset_datum(/datum/asset/json/vox_voices).send(src)
