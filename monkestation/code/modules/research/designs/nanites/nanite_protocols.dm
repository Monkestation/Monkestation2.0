/datum/design/nanites/kickstart
	name = "Kickstart Protocol"
	desc = "Replication Protocol: the nanites focus on early growth, boosting replication rate by 3.5 for 2 minutes after the initial implantation, \
			resulting in an additional 420 nanite volume being produced during the first two minutes."
	id = "kickstart_nanites"
	category = list(NANITES_CATEGORY_PROTOCOLS)
	program_type = /datum/nanite_program/protocol/kickstart

/datum/design/nanites/factory
	name = "Factory Protocol"
	desc = "Replication Protocol: the nanites build a factory matrix within the host, increasing replication speed by 0.002 each second, \
		granting a maximum of 2 additional nanite production after roughly 17 minutes. \
		The factory decays at a rate of -0.01 replication rate per second if the protocol is not active, or if the nanites are disrupted by shocks or EMPs."
	id = "factory_nanites"
	category = list(NANITES_CATEGORY_PROTOCOLS)
	program_type = /datum/nanite_program/protocol/factory

/datum/design/nanites/tinker
	name = "Tinker Protocol"
	desc = "Replication Protocol: the nanites learn to use metallic material in the host's bloodstream to speed up the replication process."
	id = "tinker_nanites"
	category = list(NANITES_CATEGORY_PROTOCOLS)
	program_type = /datum/nanite_program/protocol/tinker

/datum/design/nanites/offline
	name = "Offline Production Protocol"
	desc = "Replication Protocol: while the host is asleep or otherwise unconcious, the nanites exploit the reduced interference to increase replication rate by 3."
	id = "offline_nanites"
	category = list(NANITES_CATEGORY_PROTOCOLS)
	program_type = /datum/nanite_program/protocol/offline

/datum/design/nanites/hive
	name = "Hive Protocol"
	desc = "Storage Protocol: the nanites use a more efficient grid arrangment for volume storage, increasing maximum volume in a host."
	id = "hive_nanites"
	category = list(NANITES_CATEGORY_PROTOCOLS)
	program_type = /datum/nanite_program/protocol/hive

/datum/design/nanites/zip
	name = "Zip Protocol"
	desc = "Storage Protocol: the nanites are disassembled and compacted when unused, increasing the maximum volume to 1000. However, the process reduces their replication rate by 0.2."
	id = "zip_nanites"
	category = list(NANITES_CATEGORY_PROTOCOLS)
	program_type = /datum/nanite_program/protocol/zip

/datum/design/nanites/free_range
	name = "Free-range Protocol"
	desc = "Storage Protocol: the nanites discard their default storage protocols in favour of a cheaper and more organic approach. Reduces maximum volume, but increases the replication rate."
	id = "free_range_nanites"
	category = list(NANITES_CATEGORY_PROTOCOLS)
	program_type = /datum/nanite_program/protocol/free_range

/datum/design/nanites/unsafe_storage
	name = "S.L.O. Protocol"
	desc = "Storage Protocol: 'S.L.O.P.', or Storage Level Override Protocol, completely disables the safety measures normally present in nanites,\
		allowing them to reach much higher saturation levels, but at the risk of causing internal damage to the host."
	id = "unsafe_storage_nanites"
	category = list(NANITES_CATEGORY_PROTOCOLS)
	program_type = /datum/nanite_program/protocol/unsafe_storage
