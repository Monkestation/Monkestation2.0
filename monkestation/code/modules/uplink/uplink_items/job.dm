/datum/uplink_item/role_restricted/minibible
	name = "Miniature Bible"
	desc = "We understand it can be difficult to carry out some of our missions. Here is some spiritual counsel in a small package."
	progression_minimum = 5 MINUTES
	cost = 1
	item = /obj/item/storage/book/bible/mini
	restricted_roles = list(JOB_CHAPLAIN, JOB_CLOWN)

/datum/uplink_item/role_restricted/reverse_bear_trap
	surplus = 60

/datum/uplink_item/role_restricted/modified_syringe_gun
	surplus = 50

/datum/uplink_item/role_restricted/syndicate_plant_gene
	name = "Catalytic Inhibitor Serum Plant Data Disk"
	desc = "This plant data disk contains the genetic blueprint for the Catalytic Inhibitor Serum gene.\
			enabling plants to produce a serum that halts all internal chemical reactions"
	item = /obj/item/disk/plantgene/syndicate
	cost = 20
	restricted_roles = list(JOB_BOTANIST)
