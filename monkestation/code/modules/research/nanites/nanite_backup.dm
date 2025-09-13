/datum/nanite_cloud_backup
	///The ID the backup is set to that is shown in the cloud host.
	var/cloud_id = 0
	///The nanite component that the backup has, which handles listing programs and such.
	var/datum/component/nanites/nanites
	///The host of our nanites in the cloud.
	var/obj/machinery/computer/nanite_cloud_controller/cloud_host

/datum/nanite_cloud_backup/New(obj/machinery/computer/nanite_cloud_controller/cloud_host_machine, cloud_host_id)
	. = ..()
	src.cloud_id = cloud_host_id
	src.cloud_host = cloud_host_machine
	cloud_host.cloud_backups += src
	SSnanites.cloud_backups += src

/datum/nanite_cloud_backup/proc/set_nanites(datum/component/nanites/cloud_copy)
	src.nanites = cloud_copy

/datum/nanite_cloud_backup/Destroy()
	cloud_host.cloud_backups -= src
	SSnanites.cloud_backups -= src
	return ..()
