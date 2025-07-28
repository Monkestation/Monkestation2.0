/obj/machinery/dna_infuser
	var/static/list/chromosome_ckey_list = null

/obj/machinery/dna_infuser/infuse_organ(mob/living/carbon/human/target)
	. = ..()
	if(!. || isnull(target) || isnull(target.ckey))
		return

	if(isnull(chromosome_ckey_list))
		chromosome_ckey_list = list()

	if(!chromosome_ckey_list[target.ckey])
		chromosome_ckey_list[target.ckey] = TRUE
		for(var/i in 1 to 2)
			var/chromosome_path = generate_chromosome()
			new chromosome_path(get_turf(src))

		say("New DNA detected, extraction of 2 chromosomes successfull.")
