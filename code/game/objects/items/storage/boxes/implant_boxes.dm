/obj/item/storage/box/trackimp
	name = "boxed tracking implant kit"
	desc = "Box full of scum-bag tracking utensils."
	icon_state = "secbox"
	illustration = "implant"

/obj/item/storage/box/trackimp/PopulateContents()
	var/list/items_inside = list(
		/obj/item/implantcase/tracking = 4,
		/obj/item/implanter = 1,
		/obj/item/implantpad = 1,
		/obj/item/locator = 1,
	)
	generate_items_inside(items_inside, src)

/obj/item/storage/box/minertracker
	name = "boxed miner tracking implant kit"
	desc = "For finding those who have died on the accursed lavaworld."
	illustration = "implant"

/obj/item/storage/box/minertracker/PopulateContents()
	var/list/items_inside = list(
		/obj/item/implantcase/tracking/miner = 3,
		/obj/item/implanter = 1,
		/obj/item/implantpad = 1,
		/obj/item/locator = 1,
	)
	generate_items_inside(items_inside, src)

/obj/item/storage/box/chemimp
	name = "boxed chemical implant kit"
	desc = "Box of stuff used to implant chemicals."
	illustration = "implant"

/obj/item/storage/box/chemimp/PopulateContents()
	var/list/items_inside = list(
		/obj/item/implantcase/chem = 5,
		/obj/item/implanter = 1,
		/obj/item/implantpad = 1,
	)
	generate_items_inside(items_inside, src)

/obj/item/storage/box/exileimp
	name = "boxed exile implant kit"
	desc = "Box of exile implants. It has a picture of a clown being booted through the Gateway."
	illustration = "implant"

/obj/item/storage/box/exileimp/PopulateContents()
	var/list/items_inside = list(
		/obj/item/implantcase/exile = 5,
		/obj/item/implanter = 1,
		/obj/item/implantpad = 1,
	)
	generate_items_inside(items_inside, src)

/obj/item/storage/box/teleport_blocker
	name = "boxed bluespace grounding implant kit"
	desc = "Box of bluespace grounding implants. There's a drawing on the side -- A figure wearing some intimidating robes, frowning and shedding a single tear."
	illustration = "implant"

/obj/item/storage/box/teleport_blocker/PopulateContents()
	var/list/items_inside = list(
		/obj/item/implantcase/teleport_blocker = 4,
		/obj/item/implanter = 1,
		/obj/item/implantpad = 1,
	)
	generate_items_inside(items_inside, src)
