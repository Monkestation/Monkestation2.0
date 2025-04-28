/obj/machinery/computer/scan_consolenew
	var/static/list/chromosome_ckey_list = null

/obj/machinery/computer/scan_consolenew/attackby(obj/item/dnainjector/activator/activator, mob/user, params)
	if(!istype(activator))
		return ..()

	// Recycle non-activator used injectors
	// Turn activator used injectors (aka research injectors) to chromosomes
	if(!activator.used)
		//recycle unused activators
		qdel(activator)
		to_chat(user, span_notice("Recycled unused [activator]."))
		return

	if(isnull(chromosome_ckey_list))
		chromosome_ckey_list = list()

	if(activator.research && activator.filled)
		if(isnull(chromosome_ckey_list))
			chromosome_ckey_list = list()

		if(!chromosome_ckey_list[activator.filled])
			chromosome_ckey_list[activator.filled] = 0

		if(chromosome_ckey_list[activator.filled] < 3)
			chromosome_ckey_list[activator.filled]++
			var/chromosome_path = generate_chromosome()
			var/obj/item/chromosome/chromosome = new chromosome_path(src)
			stored_chromosomes += chromosome
			to_chat(user, span_notice("[capitalize(chromosome.name)] added to storage."))
		else
			to_chat(user, span_notice("All available genetic data already extracted from injected user"))

	if(activator.crispr_charge)
		crispr_charges++
		to_chat(user, span_notice("CRISPR charge added."))

	qdel(activator)
	to_chat(user, span_notice("Recycled [activator]."))
