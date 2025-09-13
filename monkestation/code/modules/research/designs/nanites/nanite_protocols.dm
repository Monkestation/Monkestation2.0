/datum/design/nanites/kickstart
	name = "Kickstart Protocol"
	desc = "Replication Protocol: the nanites focus on early growth, heavily boosting replication rate for a few minutes after the initial implantation."
	id = "kickstart_nanites"
	category = list(NANITES_CATEGORY_PROTOCOLS)
	program_type = /datum/nanite_program/protocol/kickstart

/datum/design/nanites/factory
	name = "Factory Protocol"
	desc = "Replication Protocol: the nanites build a factory matrix within the host, gradually increasing replication speed over time. The factory decays if the protocol is not active."
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
	desc = "Replication Protocol: while the host is asleep or otherwise unconcious, the nanites exploit the reduced interference to replicate more quickly."
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
	desc = "Storage Protocol: the nanites are disassembled and compacted when unused, greatly increasing the maximum volume while in a host. However, the process slows down the replication rate slightly."
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
