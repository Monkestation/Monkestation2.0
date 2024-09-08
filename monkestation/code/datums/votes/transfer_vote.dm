#define CHOICE_TRANSFER	"Initiate Crew Transfer"
#define CHOICE_CONTINUE	"Continue Round"

/// If a map vote is called before the emergency shuttle leaves the station, the players can call another vote to re-run the vote on the shuttle leaving.
/datum/vote/crew_transfer
	name = "Crew Transfer"
	message = "Vote to call the shuttle to end the current round."
	default_choices = list(
		CHOICE_TRANSFER,
		CHOICE_CONTINUE,
	)
	player_startable = FALSE

/datum/vote/crew_transfer/reset()
	. = ..()
	SSgamemode.doing_transfer_vote = FALSE

/datum/vote/crew_transfer/can_be_initiated(mob/by_who, forced = FALSE)
	. = ..()
	if(!.)
		return FALSE
	if(!SSticker.IsRoundInProgress())
		return FALSE
	if(EMERGENCY_PAST_POINT_OF_NO_RETURN)
		return FALSE
	if(SSgamemode.doing_transfer_vote)
		return FALSE

/datum/vote/crew_transfer/initiate_vote(initiator, duration)
	. = ..()
	SSgamemode.doing_transfer_vote = TRUE

/datum/vote/crew_transfer/finalize_vote(winning_option)
	switch(winning_option)
		if(CHOICE_TRANSFER)
			SSgamemode.crew_transfer_passed()
		if(CHOICE_CONTINUE)
			SSgamemode.crew_transfer_continue()
		else
			CRASH("[type] wasn't passed a valid winning choice. (Got: [winning_option || "null"])")

#undef CHOICE_CONTINUE
#undef CHOICE_TRANSFER
