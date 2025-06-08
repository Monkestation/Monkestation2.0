
/datum/rune_spell/stream
	secret=TRUE
	name="Stream"
	desc="Start or stop streaming on Spess.TV."
	desc_talisman="Start or stop streaming on Spess.TV."
	invocation="L'k' c'mm'nt 'n' s'bscr'b! P'g ch'mp! Kappah!"
	word1=/datum/rune_word/other
	word2=/datum/rune_word/see
	word3=/datum/rune_word/self
	page="This rune lets you start (or stop) streaming on Spess.TV so that you can let your audience watch and cheer for you while you slay infidels in the name of Nar-sie. #Sponsored"

/datum/rune_spell/stream/cast()
	var/datum/antagonist/streamer/streamer=activator.mind?.has_antag_datum(/datum/antagonist/streamer)
	if(!streamer)
		streamer=new /datum/antagonist/streamer
		streamer.team="Cult"
		activator.mind.add_antag_datum(streamer)
	streamer.team="Cult"
	if(!streamer.camera)
		streamer.set_camera(new /obj/machinery/camera/spesstv(activator))
	streamer.toggle_streaming()
	qdel(src)
