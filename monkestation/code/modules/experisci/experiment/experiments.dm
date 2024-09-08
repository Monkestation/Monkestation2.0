/datum/experiment/scanning/cyborg_scan
	name = "Positronic Brain Diagnostics"
	description = "Scientists on a neighboring station have possibly found the solution for replicating advanced silicon lifeforms! They are requesting analysis of a few active cyborgs to complete their research."
	scan_message = "Scan Cyborgs built with Positronic Brains."
	exp_tag = "Scan"
	required_atoms = list(/mob/living/silicon/robot = 4)

	//store scanned ckeys so roboticists dont disassemble and reassemble a borg over and over
	var/scanned_ckeys = list()

/datum/experiment/scanning/cyborg_scan/final_contributing_index_checks(target, typepath)
	var/mob/living/silicon/robot/cyborg = target
	if (cyborg.mind != null || !(cyborg.ckey in scanned_ckeys) || cyborg.mmi == /obj/item/mmi/posibrain)
		scanned_ckeys += cyborg.ckey
		return TRUE
	else
		return FALSE
