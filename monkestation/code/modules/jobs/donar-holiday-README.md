## Guide to Setting Up Donator/Holiday Jobs and Holidays

Setting up pre-made jobs for holidays and donator ranks is relatively simple. However, setting up new jobs and holidays is more complex. This guide will walk you through the process.

Valid as of 2/28/2025 on Monkestation. If this is pulled into another codebase, it is your responsibility to keep it up to date—proceed at your own risk.
Base Setup

The first step is to set up your job. This method should work for any job except those required to keep the game running, such as basic crew roles. In theory, you could make jobs like Captain only appear in April, but I have no idea what that would break.

Once your job is set up to your needs, you'll need to edit the following settings based on your requirements. These settings can be used together. If any checks fail, the job will be unselectable for donator ranks and will not appear without the corresponding event.

```DM
/// Override these settings in your new job datum.
//From [code\modules\jobs\job_types\_job.dm]
/datum/job

	/// Holidays this job should only appear on. Leave null for it to always show. Supports multiple holidays.
	//base defines in [code\__DEFINES\time.dm]
	var/list/job_holiday_flags


	/// Donar rank required for this job. Leave null for no requirement.
	//defines found in [code\__DEFINES\~monkestation\_patreon.dm]
	var/job_req_donar = null //MONKESTATION EDIT
```

Finally one last checking proc is called in [code\controllers\subsystem\job.dm] that can be used to disable the job. This can be overriden for your specific purposes. Make sure to watch the parent procs.

```DM
/// Override these settings in your new job datum.
//From [code\modules\jobs\job_types\_job.dm]
/datum/job

//Used to check if the config or special setting for this job is enabled.
//Override where appropriate. Be aware of parent procs. Defaults to false.
/datum/job/proc/special_config_check()
	return FALSE



/datum/job/godzilla

/// Example override used from one of the halloween jobs.
//monkestation\code\modules\jobs\job_types\godzilla.dm
//Checks SPOOKTOBER_ENABLED from the game_options.txt
/datum/job/godzilla/special_config_check()
	return CONFIG_GET(flag/spooktober_enabled)

```

## Config settings

Config settings seem more difficult and I am a bit wary on touching them. For adding an entry at least seems straightward enough. Be warned messing with these can cause issues please refere to code\controllers\configuration\configuration.dm and in the case of game_options entries code\controllers\configuration\entries\game_options.dm

In game_options for spooktober SPOOKTOBER_ENABLED

```DM
/// Datum line was added to check for spooktober_enabled in the config.
//From [code\controllers\configuration\entries\game_options.dm]

/datum/config_entry/flag/spooktober_enabled

```

## Holidays

Holidays themselves are more straight forward. Defined using the Events and Holidays subsystem it has a guide to show how to add your own event.

In code\controllers\subsystem\events.dm for the basic proceedure 
/*
 * It's easy to add stuff. Just add a holiday datum in code/modules/holiday/holidays.dm
 * You can then check if it's a special day in any code in the game by calling check_holidays("Groundhog Day")
*/

code\modules\holiday\holidays.dm
 
 ```DM
/datum/holiday/xmas
	name = CHRISTMAS
	begin_day = 8 // monkestation edit
	begin_month = DECEMBER
	end_day = 27
	holiday_hat = /obj/item/clothing/head/costume/santa
	mail_holiday = TRUE
	holiday_colors = list(
		COLOR_CHRISTMAS_GREEN,
		COLOR_CHRISTMAS_RED,
	)
 ```
In this case, set up your custom holiday, and for the name, make it a define. The CHRISTMAS and other main holiday defines are located in code\__DEFINES\time.dm.

Create your own define for the custom holiday and store it where applicable. Finally, you can link the holiday to an event by setting the holidayID to your new define, similar to CHRISTMAS or VALENTINES, as seen in the Valentine's Day event located in monkestation\code\modules\events\holiday\vday.dm

monkestation\code\modules\events\holiday\vday.dm
 ```DM
/datum/round_event_control/valentines
	name = "Valentines!"
	holidayID = VALENTINES
	typepath = /datum/round_event/valentines
	weight = -1 //forces it to be called, regardless of weight
	max_occurrences = 1
	earliest_start = 0 MINUTES
	category = EVENT_CATEGORY_HOLIDAY
 ```

Should be all you need to get things up and running. 
