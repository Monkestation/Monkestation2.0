/datum/uplink_item/role_restricted/minibible
	name = "Miniature Bible"
	desc = "We understand it can be difficult to carry out some of our missions. Here is some spiritual counsel in a small package."
	progression_minimum = 5 MINUTES
	cost = 1
	item = /obj/item/book/bible/mini
	restricted_roles = list(JOB_CHAPLAIN, JOB_CLOWN)

/datum/uplink_item/role_restricted/reverse_bear_trap
	surplus = 60

/datum/uplink_item/role_restricted/modified_syringe_gun
	surplus = 50

/datum/uplink_item/role_restricted/clonekit
	name = "Clone Army Kit"
	desc = "Everything you need for a clone army, armaments not included."
	progression_minimum = 5 MINUTES
	cost = 20
	item = /obj/item/storage/box/clonearmy
	restricted_roles = list(JOB_GENETICIST, JOB_RESEARCH_DIRECTOR, JOB_MEDICAL_DOCTOR, JOB_CHIEF_MEDICAL_OFFICER, JOB_CARGO_TECHNICIAN, JOB_QUARTERMASTER) // Experimental cloners were traditionally bought by cargo.

///I know this probably isn't the right place to put it, but I don't know where I should put it, and I can move it later.
/obj/item/disk/clonearmy
	name = "DNA data disk" //Cunning disguise.
	var/objective = ""
	icon_state = "datadisk0"

/obj/item/disk/clonearmy/Initialize(mapload)
	. = ..()
	icon_state = "datadisk[rand(0,7)]"
	add_overlay("datadisk_gene")

/obj/item/disk/clonearmy/attack_self(mob/user)
	var/targName = tgui_input_text(user, "Enter a directive for the evil clones.", "Clone Directive Entry", objective, CONFIG_GET(number/max_law_len), TRUE)
	if(!targName)
		return
	if(is_ic_filtered(targName))
		to_chat(user, span_warning("Error: Directive contains invalid text."))
		return
	var/list/soft_filter_result = is_soft_ooc_filtered(targName)
	if(soft_filter_result)
		if(tgui_alert(user,"Your directive contains \"[soft_filter_result[CHAT_FILTER_INDEX_WORD]]\". \"[soft_filter_result[CHAT_FILTER_INDEX_REASON]]\", Are you sure you want to use it?", "Soft Blocked Word", list("Yes", "No")) != "Yes")
			return
		message_admins("[ADMIN_LOOKUPFLW(user)] has passed the soft filter for \"[soft_filter_result[CHAT_FILTER_INDEX_WORD]]\" they may be using a disallowed term for a clone directive. Directive: \"[html_encode(targName)]\"")
		log_admin_private("[key_name(user)] has passed the soft filter for \"[soft_filter_result[CHAT_FILTER_INDEX_WORD]]\" they may be using a disallowed term for a clone directive. Directive: \"[targName]\"")
	objective = targName
	..()

/obj/item/disk/clonearmy/attack()
	return

/obj/item/disk/clonearmy/afterattack(atom/target, mob/user, proximity)
	. = ..()
	var/atom/A = target
	if(!proximity)
		return
	. |= AFTERATTACK_PROCESSED_ITEM
	if(!istype(A, /obj/machinery/clonepod/experimental))
		return
	to_chat(user, "You upload the directive to the experimental cloner.")
	var/obj/machinery/clonepod/experimental/pod = target
	pod.custom_objective = objective
	pod.RefreshParts()
	pod.locked = TRUE // The pod shouldn't be eligible for cloner event.

/datum/uplink_item/role_restricted/syndicate_plant_gene
	name = "Catalytic Inhibitor Serum Plant Data Disk"
	desc = "This plant data disk contains the genetic blueprint for the Catalytic Inhibitor Serum gene.\
			enabling plants to produce a serum that halts all internal chemical reactions"
	item = /obj/item/disk/plantgene/syndicate
	cost = 17
	restricted_roles = list(JOB_BOTANIST)

/datum/uplink_item/role_restricted/power_gloves
	name = "Power Gloves"
	desc = "Are the Engineers on your station creating too much power? Use this to set them in their place. T-ray scanner not included"
	cost = 8
	item = /obj/item/clothing/gloves/color/yellow/power_gloves
	restricted_roles = list(JOB_STATION_ENGINEER, JOB_CHIEF_ENGINEER, JOB_ATMOSPHERIC_TECHNICIAN)

/datum/uplink_item/role_restricted/tunnel_khans
	name = "Tunnel Khans Care Package"
	desc = "A... questionably packed box written on with gray crayon. It's really hard to read. We hope that your assistant mind can comprehend it better than us."
	cost = 13
	item = /obj/item/storage/box/syndie_kit/khan_package
	restricted_roles = list(JOB_ASSISTANT)

/datum/uplink_item/role_restricted/acid_spit
	name = "Refined Matter Eater Mutator"
	desc = "A mutator containing the recently refined \"Matter Eater\" mutation from clowns. \
		The strain was refined to only cause 20 genetic instability instead of 40 in an undisclosed amount of time. \
		Be cautious as it can be detected using genetic scanners and is curable with mutadone."
	cost = 6
	item = /obj/item/dnainjector/syndicate_matter_eater
	restricted_roles = list(JOB_GENETICIST)

/datum/uplink_item/role_restricted/acid_spit
	name = "Acid Spit Mutator"
	desc = "A mutator containing the recently extracted \"acid spit\" mutation from xenomorphs. \
		The strain was refined over many months until the point of only causing 20 genetic instability instead of 70. \
		Be cautious as it can be detected using genetic scanners and is curable with mutadone."
	cost = 8
	item = /obj/item/dnainjector/acid_spit
	restricted_roles = list(JOB_GENETICIST)

/datum/uplink_item/role_restricted/xray
	name = "Refined X-Ray Vision Mutator Box"
	desc = "A mutator containing a refined X-ray mutation allowing you to see through walls at the cost of eye health. \
		The strain was refined over many weeks until the point of only causing 40 genetic instability instead of 60. \
		Be cautious as it can be detected using genetic scanners and is curable with mutadone. \
		This package also includes 3 oculine medipens to negate the negative effects of the mutation upon your body."
	cost = 8
	item = /obj/item/storage/box/syndie_kit/xray
	restricted_roles = list(JOB_GENETICIST)

/datum/uplink_item/role_restricted/laser_eyes
	name = "Stabilized Laser Eyes Mutator Box"
	desc = "A mutator containing the recently discovered \"laser eyes\" mutation. \
		The strain was refined over 2 minutes in elite syndicate laboratories until the point of only causing 40 genetic instability instead of 60. \
		Be cautious as it can be detected using genetic scanners and is curable with mutadone. \
		This package also includes 3 oculine medipens to negate the negative effects of the mutation upon your body."
	cost = 8
	item = /obj/item/storage/box/syndie_kit/laser_eyes
	restricted_roles = list(JOB_GENETICIST)

/datum/uplink_item/role_restricted/corrupted_mender
	name = "Corrupted Mending Touch Mutator"
	desc = "A mutator containing a \"Mending Touch\" mutation, we have used special methods in order to make it able to smite anyone. \
		However this mending touch mutation causes 50 instability instead of 35 due to high complexity. \
		Be cautious as it can be detected using genetic scanners and is curable with mutadone."
	cost = 12
	item = /obj/item/dnainjector/syndicate_mending_touch
	restricted_roles = list(JOB_GENETICIST)

/datum/uplink_item/role_restricted/stabilizer_chromosome
	name = "Stabilizer Chromosome"
	desc = "A chromosome that reduces mutation instability by 20%. Whilst able to be found in people it is rather rare at a 6% chance. \
		For this reason we are offering you this rare opportunity of a lifetime for a low cost."
	cost = 2
	surplus = 0
	item = /obj/item/chromosome/stabilizer
	restricted_roles = list(JOB_GENETICIST)

/datum/uplink_item/role_restricted/synchronizer_chromosome
	name = "Synchronizer Chromosome"
	desc = "A chromosome that reduces downsides of negative effects on mutations by 50% or hides visual effects of certain mutations. \
		Due to not being easily mass-producable we are offering this chromosome to you agent for increased damage to the station."
	cost = 1
	surplus = 0
	item = /obj/item/chromosome/synchronizer
	restricted_roles = list(JOB_GENETICIST)

/datum/uplink_item/role_restricted/power_chromosome
	name = "Power Chromosome"
	desc = "A chromosome that increases mutation power by 50% or unlocks more powerful effects for specific mutations. \
		Due to not being easily mass-producable we are offering this chromosome to you agent for increased damage to the station."
	cost = 1
	surplus = 0
	item = /obj/item/chromosome/power
	restricted_roles = list(JOB_GENETICIST)

/datum/uplink_item/role_restricted/energy_chromosome
	name = "Energetic Chromosome"
	desc = "A chromosome that reduces action mutation cooldowns by 50% or increases chances of random mutation effects. \
		Due to not being easily mass-producable we are offering this chromosome to you agent for increased damage to the station."
	cost = 1
	surplus = 0
	item = /obj/item/chromosome/energy
	restricted_roles = list(JOB_GENETICIST)
