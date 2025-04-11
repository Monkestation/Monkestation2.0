/obj/singularity
	var/chained = FALSE

/obj/singularity/proc/on_capture()
	chained = TRUE
	overlays = 0
	move_self = FALSE
	switch(current_size)
		if(1)
			overlays += image('icons/obj/engine/singularity.dmi', "chain_s1")
		if(3)
			overlays += image('icons/effects/96x96.dmi', "chain_s3")
		if(5)
			overlays += image('icons/effects/160x160.dmi', "chain_s5")
		if(7)
			overlays += image('icons/effects/224x224.dmi', "chain_s7")
		if(9)
			overlays += image('icons/effects/288x288.dmi', "chain_s9")

/obj/singularity/proc/on_release()
	chained = FALSE
	overlays = 0
	move_self = TRUE
