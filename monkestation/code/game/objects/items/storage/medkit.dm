/obj/item/storage/medkit/surgery/cmo/PopulateContents()
	if(empty)
		return
	var/static/items_inside = list(
		/obj/item/healthanalyzer/advanced = 1,
		/obj/item/stack/medical/gauze/twelve = 1,
		/obj/item/stack/medical/suture = 2,
		/obj/item/stack/medical/mesh = 2,
		/obj/item/reagent_containers/hypospray/medipen = 1,
		/obj/item/surgical_processor/cmo = 1,
		/obj/item/scalpel/advanced = 1,
		/obj/item/retractor/advanced = 1,
		/obj/item/cautery/advanced = 1,
		/obj/item/bonesetter = 1,
		/obj/item/blood_filter = 1,
	)
	generate_items_inside(items_inside,src)
