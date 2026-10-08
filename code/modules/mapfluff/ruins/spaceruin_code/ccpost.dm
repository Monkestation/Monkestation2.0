///Stuff used in Central Command Liaison Outpost Ruin.

/obj/item/paper/fluff/ruins/ccpost/transmission
	default_raw_text = "Nothing of interest"

// Central Command Assignment for Liaison, also explains what's expected of them in more detail

/obj/item/paper/fluff/ruins/ccpost/transmission/assignment
	name = "liaison outpost assignment"
	default_raw_text = {"<center><table border="0" cellspacing="0" cellpadding="4" bgcolor="#0a1e2b" style="border: 4px solid white; border-radius: 10px; font-family: Bahnschrift, sans-serif;"><tr><td><font color="#f0f0f0" size="6"><b>&#9701;</b></font></td><td><font color="#f0f0f0" size="7"><b>N</b></font></td><td><font color="#f0f0f0" size="6"><b>&#9699;</b></font></td></tr></table></center>
	<br><center><small><i>This paper has been transmitted by Central Command</i></small></center><hr><hr><small>
	<br>
	<br>Name: Nina C. Trayson
	<br>Rank: CentCom Official
	<br>Position: Liaison Manager
	<br>
	<br>Posting: Central Command Liaison Outpost
	<br>Assigned Personnel: CentCom Liaisons
	<br>Priority: High
	<br>Status: Active
	<br>
	<br>Subject: OFFICIAL DUTY ASSIGNMENT
	<br>
	<br>You have been assigned to this installation on behalf of Central Command for the purpose of monitoring nearby Nanotrasen operations and maintaining an accurate record of station activity.
	<br>
	<br>Your primary responsibility is to act as Central Command's local eyes and ears within the sector.
	<br>
	<br>During your assignment, you are expected to:
	<br>
	<br>- Monitor station operations through available camera, telemetry, and communications systems.
	<br>- Maintain professional contact with the station's Command staff.
	<br>- Investigate significant irregularities, infrastructure failures, and other matters worthy of Central Command attention.
	<br>- Request clarification or departmental reports when available information is incomplete or contradictory.
	<br>- Record noteworthy events and preserve relevant communications for later review.
	<br>- Maintain the outpost, its communications equipment, records, and monitoring systems in operational condition.
	<br>- Submit accurate reports to Central Command when requested, or when circumstances warrant escalation.
	<br>
	<br>You are reminded that this posting grants you oversight authority, not operational command of the station.
	<br>
	<br>The Captain remains responsible for station operations. You may provide recommendations, request information, and relay legitimate Central Command directives, but you are not authorized to assume command of station departments or interfere unnecessarily with routine operations.
	<br>
	<br>Remain professional. Remain objective. Verify information before reporting it as fact.
	<br>
	<br>Under ordinary circumstances, personnel assigned to this outpost are expected to remain aboard the installation. Direct intervention in station affairs is outside the scope of this assignment unless specifically authorized by Central Command.
	<br>
	<br>Information obtained through Central Command systems is to be treated as privileged corporate material and handled accordingly.
	<br>
	<br>At the conclusion of the operational period, personnel should be prepared to provide an assessment of the station's condition, significant incidents, Command response, and any matters requiring further Central review.
	<br>
	<br>Failure to maintain adequate oversight may result in reassignment to a position involving substantially fewer windows.
	<br>
	<br></small><hr><hr><small><i>Signed, Nina C. Trayson</i></small>
	<br>CENTRAL COMMAND
	<br>SECTOR OVERSIGHT DEPARTMENT
	"}

/obj/structure/closet/secure_closet/centcom_liaison
	name = "CentCom Liaison's locker"
	req_access = list(ACCESS_NT_REPRESENTATVE)
	icon_state = "cc"

/obj/structure/closet/secure_closet/centcom_liaison/PopulateContents()
	..()
	new /obj/item/clothing/suit/armor/vest/nanotrasen_representative/bathrobe(src)
	new /obj/item/clothing/suit/armor/centcom_formal(src)
	new /obj/item/clothing/suit/toggle/centcom_jacket(src)
	new /obj/item/clothing/under/rank/centcom/official(src)
	new /obj/item/clothing/under/rank/centcom/official/skirt(src)
	new /obj/item/clothing/shoes/laceup(src)
	new /obj/item/binoculars(src)
	new /obj/item/implantcase/mindshield(src)