/obj/item/paper/fluff/ruins/oldstation/ice/survivor_note
	name = "To those who find this"
	default_raw_text = "You can barely make out a faded message... <br><br>I come back to the outpost after a simple mining mission, and nobody is here. Well, they COULD have gone to cryo... I didn't really check. Doesn't matter, I have bigger issues now. There is something out there. \
	I have no fucking idea what they are, all I know is that they don't like me. On occasion I hear them hissing and clawing on the airlock... good idea I barricaded the way in. Bad news: the transit tube is still broken, the damn engineers never fixed it. \
	So basically, I'm stuck here until someone comes to rescue us. And I have no food or water. <br>If you're reading this, I'm probably dead. These things have taken over most of Delta station. \
	Whatever you do, DON'T OPEN THE FIRELOCKS unless you have something to kill them. Look in security, maybe there might be some gear left in there. <br><br>So hungry... I don't want to go out like this..."

/obj/item/paper/fluff/ruins/oldstation/ice/biolab_note_emergency
	name = "Diary note - Emergency"
	default_raw_text = "OH GOD, the outpost is still creaking from a heavy impact in the port direction. The power is down, coms not responding, the air supply pipe depressurized and I can feel the artificial gravity weakening. \
	The whole department is running around in panic. I'll just pray that engineers get the TEG up and running.<br><br> ...And the alien spawn have broken out of the containment area due to the impact and slipped into the vent.<br><br> \
	I have a bad feeling about this, but I doubt that now is the right time to make guys hunt for what they call my `pet cockroach`... And RD is scary..."

/obj/item/paper/fluff/ruins/oldstation/ice
	name = "Cryo Awakening Alert"
	default_raw_text = "<B>**WARNING**</B><BR><BR>Catastrophic damage sustained to outpost. Powernet exhausted to reawaken crew.<BR><BR>Immediate Objectives<br><br>1: Activate emergency power generator<br>2: Lift station lockdown on the bridge<br><br>Please locate the 'Damage Report' on the bridge for a detailed situation report."

/obj/item/paper/fluff/ruins/oldstation/ice/damagereport
	name = "Damage Report"
	default_raw_text = "<b>*Damage Report*</b><br><br><b>Alpha Station</b> - Destroyed<br><br><b>Beta Station</b> - Catastrophic Damage. Medical, destroyed. Atmospherics, partially destroyed.<br><br><b>Charlie Station</b> - Multiple asteroid impacts, no loss in air pressure.<br><br><b>Delta Station</b> - Intact. <b>WARNING</b>: Unknown force occupying Delta Station. Intent unknown. Species unknown. Numbers unknown.<br><br>Recommendation - Reestablish station powernet via thermoelectric generator. Reestablish station atmospherics system to restore air."

/obj/item/paper/fluff/ruins/oldstation/ice/report
	name = "Crew Reawakening Report"
	default_raw_text = "Artificial Program's report to surviving crewmembers.<br><br>Crew were placed into cryostasis on March 10th, 2445.<br><br>Crew were awoken from cryostasis around June, 2557.<br><br> \
	<b>SIGNIFICANT EVENTS OF NOTE</b><br>1: The primary radiation detectors were taken offline after 112 years due to power failure, secondary radiation detectors showed no residual \
	radiation on the outpost. Deduction, primarily detector was malfunctioning and was producing a radiation signal when there was none.<br><br>2: A data burst from a nearby Nanotrasen Space \
	Station was received, this data burst contained research data that has been uploaded to our RnD labs.<br><br>3: An unknown force has occupied Delta station. Additionally, a pack of wolves have \
	taken refuge in the space surrounding all remaining stations, primarily Beta station."

/datum/outfit/oldcargo
	name = "Alpha Station Cargo Technician"

	backpack_contents = list(
		/obj/item/boxcutter = 1,
		/obj/item/universal_scanner = 1,
	)

	id = /obj/item/card/id/away/old/cargo
	id_trim = /datum/id_trim/job/away/old/cargo
	uniform = /obj/item/clothing/under/rank/cargo/tech
	ears = /obj/item/radio/headset/headset_old
	back = /obj/item/storage/backpack
	shoes = /obj/item/clothing/shoes/sneakers/black
	box = /obj/item/storage/box/survival

/datum/outfit/oldcargo/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	if(visualsOnly)
		return

	var/obj/item/radio/headset/R = H.ears
	R.set_frequency(FREQ_UNCOMMON)
	R.freqlock = RADIO_FREQENCY_LOCKED
	R.independent = TRUE
	var/obj/item/card/id/W = H.wear_id
	if(W)
		W.registered_name = H.real_name
		W.update_label()
		W.update_icon()
	..()

/obj/effect/mob_spawn/corpse/human/oldstation/cargo
	name = "Alpha Station Cargo Technician"
	outfit = /datum/outfit/oldcargo
