#define SECONDARY_CRATE_BUDGET 30

/datum/uplink_item/dangerous/uzi
	name = "Type U3 Uzi"
	desc = "A lightweight, burst-fire submachine gun, for when you really want someone dead. Uses 9mm rounds."
	item = /obj/item/gun/ballistic/automatic/mini_uzi
	cost = 16
	purchasable_from = UPLINK_GANGS

/datum/uplink_item/ammo/uzi_mag
	name = "U3 Uzi Magazine"
	desc = "A single 32 round magazine for the U3 Uzi SMG."
	item = /obj/item/ammo_box/magazine/uzim9mm
	cost = 5
	purchasable_from = UPLINK_GANGS

/datum/uplink_item/ammo/bulk_9mm_box
	name = "Bulk 9mm Ammo Box"
	desc = "A box containing 120 rounds of 9mm ammunition."
	item = /obj/item/ammo_box/c9mm/bulk
	cost = 10
	purchasable_from = UPLINK_GANGS

/datum/uplink_item/ammo/ap_9mm_box
	name = "Bulk 9mm Ammo Box"
	desc = "A box containing 30 rounds of AP 9mm ammunition."
	item = /obj/item/ammo_box/c9mm/ap
	cost = 4
	purchasable_from = UPLINK_GANGS

/datum/uplink_item/ammo/ap_9mm_box
	name = "Bulk 9mm Ammo Box"
	desc = "A box containing 30 rounds of hollowpoint 9mm ammunition."
	item = /obj/item/ammo_box/c9mm/hp
	cost = 4
	purchasable_from = UPLINK_GANGS

/datum/uplink_item/ammo/ap_9mm_box
	name = "Bulk 9mm Ammo Box"
	desc = "A box containing 30 rounds of incendiary 9mm ammunition."
	item = /obj/item/ammo_box/c9mm/fire
	cost = 4
	purchasable_from = UPLINK_GANGS

/datum/uplink_item/dangerous/gang_turret
	name = "Disposable Sentry Gun"
	desc = "A disposable gang aligned sentry gun deployment system cleverly disguised as a toolbox, apply wrench for functionality."
	item = /obj/item/storage/toolbox/emergency/turret/gang
	cost = 12
	purchasable_from = UPLINK_GANGS

/datum/uplink_item/dangerous/tommygun
	name = "Thomson SMG"
	desc = "A classic design nicknamed the \"Tommy Gun\" carrying an impressive 50 round drum magazine chambered in .45,\
			sure to mow down your enemies. Comes with 2 magazines, a spiffy outfit, and a stylish case to carry it in."
	item = /obj/item/storage/box/syndicate/tommygun_kit
	cost = 25
	purchasable_from = UPLINK_GANGS

/obj/item/storage/briefcase/tommygun
	w_class = WEIGHT_CLASS_BULKY
	desc = "A case specially designed to carry an unloaded Thomson SMG and its magazines, doesnt look like much else would fit inside."

/obj/item/storage/briefcase/tommygun/Initialize(mapload)
	. = ..()
	atom_storage.max_specific_storage = WEIGHT_CLASS_BULKY
	atom_storage.set_holdable(list(/obj/item/gun/ballistic/automatic/tommygun, /obj/item/ammo_box/magazine/tommygunm45))

/obj/item/storage/briefcase/tommygun/PopulateContents()
	new /obj/item/gun/ballistic/automatic/tommygun/gang(src)
	new /obj/item/ammo_box/magazine/tommygunm45(src)
	new /obj/item/ammo_box/magazine/tommygunm45(src)

/obj/item/storage/box/syndicate/tommygun_kit
	name = "Tommygun Kit"

/obj/item/storage/box/syndicate/tommygun_kit/PopulateContents()
	new /obj/item/storage/briefcase/tommygun(src)
	new /obj/item/clothing/head/fedora(src)
	new /obj/item/clothing/under/suit/checkered(src)
	new /obj/item/clothing/gloves/color/black(src)
	new /obj/item/clothing/shoes/laceup(src)

/datum/uplink_item/device_tools/gang_communicator
	name = "Uplink Communicator Upgrade"
	desc = "An upgrade for your implant that when applied will grant you the ability to communicate to other members of your gang via your implant's inbuilt communication network."
	item = /obj/item/gang_device/communicator_upgrade
	cost = 4
	purchasable_from = UPLINK_GANGS

/datum/uplink_item/device_tools/gang_spraycan
	name = "Gang Spraycan"
	desc = "A modified spraycan that can be used to claim areas for your gang."
	item = /obj/item/toy/crayon/spraycan/gang
	cost = 1
	purchasable_from = UPLINK_GANGS

/datum/uplink_item/device_tools/gang_spraycan_resistant
	name = "Improved Gang Spraycan"
	desc = "An improved version of the gang spraycan that comes with 5 charges of an extra chemical mix used to give it's painted tags a coating making them resistant to cleaning\
			and being sprayed over. This mix is also able to disolve the coating on other resistant tags."
	item = /obj/item/toy/crayon/spraycan/gang/resistant
	cost = 3
	purchasable_from = UPLINK_GANGS

/datum/uplink_item/device_tools/credit_converter_beacon
	name = "Credit Converter Beacon"
	desc = "A device used to call down a credit converter in a stylish drop pod."
	item = /obj/item/gang_device/object_beacon/gang_machine/credit_converter
	cost = 20
	purchasable_from = UPLINK_GANGS

/datum/uplink_item/device_tools/gang_fabricator_beacon
	name = "Gang Fabricator Beacon"
	desc = "A device used to call down a gang fabricator in a stylish drop pod."
	item = /obj/item/gang_device/object_beacon/gang_machine/fabricator
	cost = 15
	purchasable_from = UPLINK_GANGS

/datum/uplink_item/device_tools/gang_machine_converter
	name = "Machine Hacking Device"
	desc = "A small device that can be used to convert the ownership of a machine owned by another gang to that of your own."
	item = /obj/item/gang_device/machine_converter
	cost = 5
	purchasable_from = UPLINK_GANGS

//spawns a few pods the buying gang gets to know the location of, as well as items spread randomly around the station
/datum/uplink_item/bundles_tc/surplus/gang_pods
	name = "Bulk Crate Pods"
	desc = "A total of 180 TC worth of items will be delivered, however due to space limitations the items will be within multiple pods. \
			A pod containing 50 TC worth will be dropped to your current location, while 2 others eaching containing 30 TC worth will be \
			dropped to carefully selected areas around the station, we will inform you of where these are. The rest of the value will come in \
			single pods dropped randomly throughout the station."
	cost = 50
	purchasable_from = UPLINK_GANGS
	stock_key = UPLINK_SHARED_STOCK_SURPLUS
	crate_tc_value = 180

/datum/uplink_item/bundles_tc/surplus/gang_pods/pick_possible_item(list/possible_items, tc_budget)
	. = ..()
	if(!.)
		return

	var/datum/uplink_item/item = .
	if(item.item == ABSTRACT_UPLINK_ITEM)
		return null

/datum/uplink_item/bundles_tc/surplus/gang_pods/spawn_item(spawn_path, mob/user, datum/uplink_handler/gang/handler, atom/movable/source)
	var/obj/structure/closet/crate/surplus_crate = new crate_type()
	if(!istype(surplus_crate))
		CRASH("crate_type is not a crate")

	var/list/possible_items = generate_possible_items(user, handler)
	if(!possible_items || !length(possible_items))
		handler.telecrystals += cost
		to_chat(user, span_warning("You get the feeling something went wrong and that you should inform syndicate command"))
		qdel(surplus_crate)
		CRASH("surplus crate failed to generate possible items")

	var/total_budget = crate_tc_value - 50
	fill_crate(surplus_crate, possible_items, handler?.purchase_log, 50)
	podspawn(list(
		"target" = get_turf(user),
		"style" = STYLE_SYNDICATE,
		"spawn" = surplus_crate,
	))

	var/secondary_count = 0
	var/list/pod_areas = list()
	while(secondary_count < 2)
		secondary_count++
		surplus_crate = new crate_type()
		fill_crate(surplus_crate, possible_items, handler?.purchase_log, SECONDARY_CRATE_BUDGET)
		total_budget -= SECONDARY_CRATE_BUDGET
		var/turf/target_turf = get_safe_random_station_turf()
		pod_areas += target_turf.loc
		podspawn(list(
			"target" = target_turf,
			"style" = STYLE_SYNDICATE,
			"spawn" = surplus_crate,
			"delays" = list(POD_TRANSIT = 1, POD_FALLING = 30 SECONDS, POD_OPENING = 1 SECONDS),
		))

	if(istype(handler)) //make sure we were actually bought by a gang uplink
		send_gang_message(list(handler.owning_gang), "Additional supply pods at: [english_list(pod_areas)]", null, "<span class='alertsyndie'>")

	while(total_budget)
		var/next_cost = rand(1, min(20, total_budget))
		surplus_crate = new crate_type()
		fill_crate(surplus_crate, possible_items, handler?.purchase_log, next_cost)
		total_budget -= next_cost
		podspawn(list(
			"target" = get_safe_random_station_turf(),
			"style" = STYLE_SYNDICATE,
			"spawn" = surplus_crate,
		))

	return source

#undef SECONDARY_CRATE_BUDGET
