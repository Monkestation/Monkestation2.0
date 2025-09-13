PROCESSING_SUBSYSTEM_DEF(nanites)
	name = "Nanites"
	flags = SS_BACKGROUND|SS_POST_FIRE_TIMING|SS_NO_INIT
	wait = 1 SECONDS

	///List of all Nanite backups in the game.
	var/list/datum/nanite_cloud_backup/cloud_backups = list()
	///List of all nanite relays in the game.
	var/list/datum/nanite_program/relay/nanite_relays = list()

/datum/controller/subsystem/processing/nanites/proc/check_hardware(datum/nanite_cloud_backup/backup)
	if(QDELETED(backup.cloud_host) || (backup.cloud_host.machine_stat & (NOPOWER|BROKEN)))
		return FALSE
	return TRUE

///Using a given cloud_id, will try to sync to the proper nanite cloud backup.
/datum/controller/subsystem/processing/nanites/proc/get_cloud_backup(cloud_id, force = FALSE)
	for(var/datum/nanite_cloud_backup/backup as anything in cloud_backups)
		if(!force && !check_hardware(backup))
			return
		if(backup.cloud_id == cloud_id)
			return backup
