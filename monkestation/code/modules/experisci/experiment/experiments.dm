/datum/experiment/scanning/random/serverlink
	name = "Serverlink Salvage Experiment"
	description = "The analysis methods of advanced serverlinks have caught our researchers eyes. Provide any serverlink better than the standard model for reverse engineering in the experimental destructive analyzer."
	exp_tag = "Salvage Scan"
	total_requirement = 1
	possible_types = list(/obj/item/organ/internal/cyberimp/brain/linked_surgery/perfect)
	traits = EXPERIMENT_TRAIT_DESTRUCTIVE

/datum/experiment/scanning/random/casing
	name = "Grenade Casing Salavage Experiment"
	description = "We belive we can learn from applied use of chemical grenades. Deconstruct any large grenade casings from external parties in the experimental destructive analyzer."
	exp_tag = "Salvage Scan"
	total_requirement = 1
	possible_types = list(/obj/item/grenade/chem_grenade/large/bioterrorfoam, /obj/item/grenade/chem_grenade/large/tuberculosis,) //Any special grenade casings.
	traits = EXPERIMENT_TRAIT_DESTRUCTIVE

/datum/experiment/scanning/random/shell_scan
	name = "Artifical Shell Analysis"
	description = "Our AI's B.O.R.I.S. shells have been suffering from ionic interference. Scan an AI shell for data, and we'll share some of our findings with your station."
	total_requirement = 1
	possible_types = list(/mob/living/silicon/robot/shell)

/datum/experiment/scanning/random/bot_scan
	name = "Bot Scan Analysis"
	description = "Central is curious at the potential of replacing the workforce with robots. Create a few and begin the replacement of your coworkers."
	total_requirement = 2
	possible_types = list(/mob/living/simple_animal/bot/vibebot, /mob/living/basic/bot/hygienebot, /mob/living/basic/bot/cleanbot/medbay/jr, /mob/living/simple_animal/bot/firebot,)

/datum/experiment/scanning/random/money
	name = "Computing Software Funding Salvage"
	description = "Funding this quarter has been under, 'find' a bounty cube for us skip the middle man. The destructive analyzer can decrypt the cube, don't expect to see it back however."
	exp_tag = "Computing Scan"
	total_requirement = 1
	possible_types = list(/obj/item/bounty_cube) // I imagine people will get in fights from stealing bounty cubes. And frankly? Good.
	traits = EXPERIMENT_TRAIT_DESTRUCTIVE

/datum/experiment/scanning/points/modsuit
	name = "Modular Suit Analysis"
	description = "We're interested in promoting modular suit efforts in the sector. Run stresstests on the creations and we'll provide a research grant."
	required_points = 6
	required_atoms = list(
		/obj/item/mod/control/pre_equipped/cosmohonk = 2, //One's that can be created but also show roundstart are worth less.
		/obj/item/mod/control/pre_equipped/standard = 2,
		/obj/item/mod/control/pre_equipped/security = 1,
		/obj/item/mod/control/pre_equipped/engineering = 1,
		/obj/item/mod/control/pre_equipped/atmospheric = 1,
		/obj/item/mod/control/pre_equipped/medical = 1,
		)
