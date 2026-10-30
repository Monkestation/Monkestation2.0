/// Central Command Liaison Outpost sector simulation and communications systems.

#define CCPOST_INSTALLATION_ONLINE "ONLINE"
#define CCPOST_INSTALLATION_ROUTINE "ROUTINE OPERATIONS"
#define CCPOST_INSTALLATION_MAINTENANCE "MAINTENANCE"
#define CCPOST_INSTALLATION_UNDER_REVIEW "UNDER REVIEW"
#define CCPOST_INSTALLATION_COMMS_DEGRADED "COMMUNICATIONS DEGRADED"
#define CCPOST_INSTALLATION_NO_CONTACT "NO CONTACT"
#define CCPOST_INSTALLATION_OFFLINE "OFFLINE"
#define CCPOST_INSTALLATION_CRITICAL "CRITICAL"

#define CCPOST_PRIORITY_ROUTINE "Routine"
#define CCPOST_PRIORITY_ADVISORY "Advisory"
#define CCPOST_PRIORITY_IMPORTANT "Important"
#define CCPOST_PRIORITY_PRIORITY "Priority"

#define CCPOST_MESSAGE_UPDATE "UPDATE"
#define CCPOST_MESSAGE_REQUEST "REQUEST"

#define CCPOST_MESSAGE_PENDING "PENDING"
#define CCPOST_MESSAGE_ACKNOWLEDGED "ACKNOWLEDGED"
#define CCPOST_MESSAGE_AUTHORIZED "AUTHORIZED"
#define CCPOST_MESSAGE_DENIED "DENIED"
#define CCPOST_MESSAGE_EXPIRED "EXPIRED"

#define CCPOST_PAPERWORK_AWAITING_REVIEW "AWAITING LIAISON REVIEW"
#define CCPOST_PAPERWORK_AWAITING_RECEIPT "TRANSMITTED - AWAITING RECEIPT"

#define CCPOST_INSTALLATION_CODE_REL_A17 "NT-REL-A17"
#define CCPOST_INSTALLATION_CODE_OUT_K04 "NT-OUT-K04"
#define CCPOST_INSTALLATION_CODE_MIN_RC12 "NT-MIN-RC12"
#define CCPOST_INSTALLATION_CODE_LP_D03 "NT-LP-D03"
#define CCPOST_INSTALLATION_CODE_ADM_06 "NT-ADM-06"
#define CCPOST_INSTALLATION_CODE_LOG_H09 "NT-LOG-H09"
#define CCPOST_INSTALLATION_CODE_MED_M12 "NT-MED-M12"
#define CCPOST_INSTALLATION_CODE_SEC_S08 "NT-SEC-S08"

#define CCPOST_NOTICE_TEMPLATE_MEDICAL_BATCH_RECALL "medical_batch_recall"

// Sector notice template definitions

/datum/ccpost_sector_notice_template
	var/template_id
	var/category
	var/source
	var/priority = CCPOST_PRIORITY_ROUTINE
	var/title
	var/body
	var/logistics_effect_duration = 0
	var/logistics_authorization_delay = 0
	var/logistics_dispatch_delay = 0
	var/logistics_transit_multiplier = 1
	var/logistics_effect_summary
	var/blocks_medical_supplies = FALSE

/datum/ccpost_sector_notice_template/New(_template_id, _category, _source, _priority, _title, _body)
	. = ..()
	if(!isnull(_template_id))
		template_id = _template_id
	if(!isnull(_category))
		category = _category
	if(!isnull(_source))
		source = _source
	if(!isnull(_priority))
		priority = _priority
	if(!isnull(_title))
		title = _title
	if(!isnull(_body))
		body = _body

/datum/ccpost_sector_notice_template/relay_maintenance
	template_id = "relay_maintenance"
	category = "Communications"
	source = "Central Communications Directorate"
	priority = CCPOST_PRIORITY_ADVISORY
	title = "Scheduled Sector Relay Maintenance"
	body = "Routine calibration of long-range communications relays is scheduled within the sector. Brief transmission delays or duplicate routing acknowledgements may occur. No action is required unless communications are lost for an extended period."

/datum/ccpost_sector_notice_template/credential_audit
	template_id = "credential_audit"
	category = "Compliance"
	source = "Internal Compliance Division"
	title = "Quarterly Credential Review"
	body = "Sector installations are reminded to review locally issued access credentials and report unexplained discrepancies through the appropriate administrative channels. Do not submit duplicate reports for previously documented irregularities."

/datum/ccpost_sector_notice_template/freight_routing
	template_id = "freight_routing"
	category = "Logistics"
	source = "Sector Logistics Coordination"
	priority = CCPOST_PRIORITY_ADVISORY
	title = "Temporary Freight Routing Revision"
	body = "Commercial and Nanotrasen freight traffic is being rerouted around a congested transit corridor. Minor delivery delays are expected. Priority medical and emergency shipments remain unaffected."
	logistics_effect_duration = 12 MINUTES
	logistics_transit_multiplier = 1.4
	logistics_effect_summary = "Sector freight traffic is being rerouted around a congested transit corridor."

/datum/ccpost_sector_notice_template/document_retention
	template_id = "document_retention"
	category = "Administration"
	source = "Central Records Administration"
	title = "Document Retention Reminder"
	body = "Operational reports, incident summaries, disciplinary records, and formal correspondence are to be retained according to current Nanotrasen document retention policy. Unofficial notes written on food packaging do not qualify as archival copies."

/datum/ccpost_sector_notice_template/priority_channels
	template_id = "priority_channels"
	category = "Communications"
	source = "Central Communications Directorate"
	title = "Priority Channel Usage"
	body = "Personnel are reminded that priority communications channels are reserved for operationally relevant traffic. Personal disputes, recreational broadcasts, and requests regarding payroll processing should be directed elsewhere."

/datum/ccpost_sector_notice_template/debris_advisory
	template_id = "debris_advisory"
	category = "Navigation"
	source = "Sector Traffic Control"
	priority = CCPOST_PRIORITY_ADVISORY
	title = "Orbital Debris Advisory"
	body = "Automated tracking systems have identified an increased concentration of non-hazardous debris within the sector. Navigational systems have been updated accordingly. Fixed installations are not presently considered at risk."

/datum/ccpost_sector_notice_template/staffing_review
	template_id = "staffing_review"
	category = "Personnel"
	source = "Central Personnel Administration"
	title = "Remote Installation Staffing Review"
	body = "Central Command is conducting a routine review of staffing allocations across remote installations. Requests for additional personnel should include an operational justification, current staffing figures, and an explanation of why existing personnel cannot simply work harder."

/datum/ccpost_sector_notice_template/budget_controls
	template_id = "budget_controls"
	category = "Finance"
	source = "Central Budgetary Oversight"
	title = "Discretionary Expenditure Controls"
	body = "Sector installations are reminded that discretionary purchases remain subject to departmental budget controls. Describing an expenditure as 'mission critical' does not automatically make it mission critical."

/datum/ccpost_sector_notice_template/medical_batch_recall
	template_id = CCPOST_NOTICE_TEMPLATE_MEDICAL_BATCH_RECALL
	category = "Medical"
	source = "Central Medical Logistics"
	priority = CCPOST_PRIORITY_IMPORTANT
	title = "Medical Supply Batch Recall"
	body = "Central Medical Logistics has issued a precautionary recall covering selected field-medical supply batches distributed throughout the sector. Remote installations are instructed to quarantine affected stock and suspend routine medical resupply requests until the review window closes. Emergency care should continue from verified local inventory."
	logistics_effect_duration = 10 MINUTES
	logistics_effect_summary = "A Central Medical Logistics batch recall is temporarily suspending routine medical resupply requisitions."
	blocks_medical_supplies = TRUE

/datum/ccpost_sector_notice_template/software_revision
	template_id = "software_revision"
	category = "Systems"
	source = "Nanotrasen Systems Administration"
	title = "Administrative Software Revision"
	body = "A revised administrative software package is being distributed across sector infrastructure. Installations operating legacy systems may continue doing so until a scheduled maintenance period becomes available."

/datum/ccpost_sector_notice_template/incident_numbering
	template_id = "incident_numbering"
	category = "Administration"
	source = "Central Records Administration"
	title = "Incident Reference Number Standardization"
	body = "All newly submitted sector incident reports should include a valid local reference number. Reports titled 'the thing from earlier' or 'you know what happened' may experience processing delays."

/datum/ccpost_sector_notice_template/emergency_readiness
	template_id = "emergency_readiness"
	category = "Operations"
	source = "Central Emergency Management"
	priority = CCPOST_PRIORITY_ADVISORY
	title = "Emergency Readiness Review"
	body = "Remote installations are encouraged to confirm the availability of emergency communications, evacuation equipment, and current response documentation. This notice does not indicate the existence of a specific threat."

/datum/ccpost_sector_notice_template/network_latency
	template_id = "network_latency"
	category = "Systems"
	source = "Sector Network Operations"
	priority = CCPOST_PRIORITY_ADVISORY
	title = "Sector Network Latency"
	body = "Intermittent latency has been observed on several administrative network routes. Automated systems may take longer than usual to acknowledge submitted requests. Repeatedly submitting the same request will not improve processing speed."
	logistics_effect_duration = 10 MINUTES
	logistics_authorization_delay = 10 SECONDS
	logistics_effect_summary = "Administrative network latency is delaying requisition authorization."

/datum/ccpost_sector_notice_template/form_revision
	template_id = "form_revision"
	category = "Compliance"
	source = "Central Administrative Standards Office"
	title = "Administrative Form Revision"
	body = "Form CC-17B has been superseded by Form CC-17C. Existing copies of Form CC-17B may continue to be used until depleted, provided all references to Form CC-17B are amended to indicate that the form remains temporarily acceptable."

/datum/ccpost_sector_notice_template/patrol_adjustment
	template_id = "patrol_adjustment"
	category = "Security"
	source = "Sector Security Coordination"
	priority = CCPOST_PRIORITY_ADVISORY
	title = "Sector Patrol Scheduling Adjustment"
	body = "Routine Nanotrasen security patrol schedules have been adjusted in response to changing traffic patterns. This notice does not constitute a request for local security mobilization or increased alert status."

/datum/ccpost_sector_notice_template/freight_priority_window
	template_id = "freight_priority_window"
	category = "Logistics"
	source = "Sector Logistics Coordination"
	priority = CCPOST_PRIORITY_ADVISORY
	title = "Temporary Freight Capacity Surplus"
	body = "Sector Logistics is reporting temporary surplus freight capacity. Eligible Nanotrasen installations may experience reduced delivery times while additional routing capacity remains available."
	logistics_effect_duration = 10 MINUTES
	logistics_transit_multiplier = 0.75
	logistics_effect_summary = "Temporary surplus freight capacity is reducing transit times."

/datum/ccpost_sector_notice_template/personnel_records
	template_id = "personnel_records"
	category = "Personnel"
	source = "Central Personnel Administration"
	title = "Personnel Record Accuracy"
	body = "Supervisory personnel are reminded that staffing records should accurately reflect current assignments. Personnel who have been missing for several consecutive shifts should not continue to be recorded as 'temporarily unavailable' indefinitely."

/datum/ccpost_sector_notice_template/wizard_federation_activity
	template_id = "wizard_federation_activity"
	category = "Security"
	source = "Central Security Intelligence"
	priority = CCPOST_PRIORITY_IMPORTANT
	title = "Wizard Federation Activity Advisory"
	body = "Central Security Intelligence has received credible reports of Wizard Federation activity within neighboring transit routes. No hostile wizard presence has been confirmed at local Nanotrasen installations. Personnel are instructed to report unexplained teleportation, spontaneous transmutation, hostile spell effects, or individuals loudly declaring allegiance to the Federation."

/datum/ccpost_sector_notice_template/thaumaturgic_signal_interference
	template_id = "thaumaturgic_signal_interference"
	category = "Communications"
	source = "Central Communications Directorate"
	priority = CCPOST_PRIORITY_ADVISORY
	title = "Unexplained Thaumaturgic Signal Interference"
	body = "Several sector relays have logged short-duration transmission distortions inconsistent with conventional electromagnetic interference. Central Communications is coordinating with Security Intelligence regarding possible Wizard Federation involvement. Do not attempt to reproduce anomalous signal patterns on operational equipment."

/datum/ccpost_sector_notice_template/arcane_contraband_reminder
	template_id = "arcane_contraband_reminder"
	category = "Compliance"
	source = "Internal Compliance Division"
	title = "Arcane Contraband Handling Reminder"
	body = "Personnel are reminded that unregistered enchanted artifacts, spellbooks, magical staves, and equipment associated with the Wizard Federation are not approved workplace materials. Recovered items are to be secured and reported through Security channels. Under no circumstances should personnel activate an unfamiliar artifact to determine what it does."

/datum/ccpost_sector_notice_template/arcane_displacement_advisory
	template_id = "arcane_displacement_advisory"
	category = "Navigation"
	source = "Sector Traffic Control"
	priority = CCPOST_PRIORITY_ADVISORY
	title = "Localized Spatial Displacement Advisory"
	body = "Sector Traffic Control has received several reports of brief spatial displacement events affecting unmanned cargo and navigation beacons. Wizard Federation activity has not been ruled out. Installations should immediately report personnel, freight, or equipment appearing in locations they did not previously occupy."

/datum/ccpost_sector_notice_template/summoned_entity_guidance
	template_id = "summoned_entity_guidance"
	category = "Emergency Operations"
	source = "Central Emergency Management"
	priority = CCPOST_PRIORITY_ADVISORY
	title = "Summoned Entity Response Guidance"
	body = "In light of recent Wizard Federation activity, remote installations are reminded that unidentified creatures or objects appearing without a conventional arrival record are to be treated as potential hostile anomalies. Isolate the area where practical, avoid unnecessary physical contact, and request Security assessment before attempting containment or disposal."


// Sector installation template definitions

/datum/ccpost_sector_contact
	var/contact_name = "Unknown Personnel"
	var/contact_role = "Installation Duty Officer"

/// Installation-specific acknowledgement text for Liaison aid decisions.
/// Kept separate from message templates so every installation can maintain a
/// consistent voice without duplicating response strings across each request.
/datum/ccpost_installation_response_profile
	var/authorized_response = "Authorization received. The approved resources will be applied to the outstanding operational requirement."
	var/denied_response = "Denial received. Local personnel will continue with existing resources and record the outstanding requirement."
	var/critical_authorized_response = "Emergency authorization received. The approved resources are being committed to immediate stabilization efforts. The incident remains active."
	var/critical_denied_response = "Emergency support denied. Local personnel will continue containment with remaining on-site resources."

/datum/ccpost_installation_response_profile/rel_a17
	authorized_response = "Authorization received. A-17 will release the approved relay resources and begin the requested work immediately."
	denied_response = "Denial received. A-17 will remain on local spares and reduced redundancy. The outstanding requirement has been entered into the relay maintenance record."
	critical_authorized_response = "Emergency authorization received. A-17 is committing the approved resources to secure routing, emergency power, and relay stabilization. The incident remains active."
	critical_denied_response = "Emergency support denied. A-17 will preserve the remaining authenticated relay paths and shed nonessential systems as required."

/datum/ccpost_installation_response_profile/out_k04
	authorized_response = "Authorization received. Kappa-4 will restore the affected monitoring or continuity reserve and update the watch record."
	denied_response = "Denial received. Kappa-4 will redistribute local reserves and accept the resulting reduction in monitoring coverage."
	critical_authorized_response = "Emergency authorization received. Kappa-4 is reinforcing protected sections, life support, and essential monitoring. The incident remains active."
	critical_denied_response = "Emergency support denied. Kappa-4 is consolidating personnel and power around the protected section and will abandon nonessential monitoring as necessary."

/datum/ccpost_installation_response_profile/min_rc12
	authorized_response = "Authorization received. RC-12 will release the approved industrial support and return the affected systems to controlled service."
	denied_response = "Denial received. RC-12 will continue on local spares and reduced throughput. Deferred maintenance has been entered into the platform log."
	critical_authorized_response = "Emergency authorization received. RC-12 is committing the resources to atmosphere, structural isolation, and damage control. The incident remains active."
	critical_denied_response = "Emergency support denied. RC-12 is abandoning nonessential machinery and concentrating remaining resources on atmosphere, structure, and personnel survival."

/datum/ccpost_installation_response_profile/lp_d03
	authorized_response = "Authorization received. Delta-3 will bring the approved monitoring hardware or reserve capacity online and restore coverage."
	denied_response = "Denial received. Delta-3 will continue with reduced coverage and prioritize the highest-value monitoring channels."
	critical_authorized_response = "Emergency authorization received. Delta-3 is reinforcing protected power, secure communications, and the remaining monitoring array. The incident remains active."
	critical_denied_response = "Emergency support denied. Delta-3 will narrow the watch to essential channels and preserve local power for the remaining array."

/datum/ccpost_installation_response_profile/adm_06
	authorized_response = "Authorization received. Annex 6 will apply the approved resources to records continuity and close the associated deficiency once service is restored."
	denied_response = "Denial received. Annex 6 will continue manual processing and record the resulting backlog against the current review period."
	critical_authorized_response = "Emergency authorization received. Annex 6 is committing the resources to protected archives, secure storage, and continuity operations. The incident remains active."
	critical_denied_response = "Emergency support denied. Annex 6 will preserve priority records and abandon nonessential processing where necessary."

/datum/ccpost_installation_response_profile/log_h09
	authorized_response = "Authorization received. H-9 will allocate the approved freight resources and restore the affected routing capacity."
	denied_response = "Denial received. H-9 will maintain reduced freight throughput and reroute what traffic local capacity can still support."
	critical_authorized_response = "Emergency authorization received. H-9 is committing the resources to manual routing, protected power, and secured freight operations. The incident remains active."
	critical_denied_response = "Emergency support denied. H-9 will suspend nonessential freight movements and preserve local capacity for controlled emergency routing."

/datum/ccpost_installation_response_profile/med_m12
	authorized_response = "Authorization received. M-12 will apply the approved resources to validated storage and regional medical distribution."
	denied_response = "Denial received. M-12 will conserve verified stock and continue operations within local refrigeration and storage limits."
	critical_authorized_response = "Emergency authorization received. M-12 is committing the resources to refrigeration, protected stock, and essential treatment capacity. The incident remains active."
	critical_denied_response = "Emergency support denied. M-12 will consolidate viable stock and treatment into the remaining protected areas and abandon compromised storage."

/datum/ccpost_installation_response_profile/sec_s08
	authorized_response = "Authorization received. S-8 will deploy the approved resources to restore patrol readiness, secure storage, or security-system redundancy."
	denied_response = "Denial received. S-8 will redistribute local security reserves and accept the resulting reduction in regional coverage."
	critical_authorized_response = "Emergency authorization received. S-8 is committing the resources to verified access control, protected communications, casualty support, and command continuity. The incident remains active."
	critical_denied_response = "Emergency support denied. S-8 will consolidate verified personnel around secured sections and preserve only essential regional security functions."


/// Permanent sector consequence applied after an installation is confirmed lost.
/// Individual systems read only the fields relevant to them, keeping loss
/// behavior data-driven rather than scattering installation-code checks around.
/datum/ccpost_installation_loss_effect
	var/summary

	/// Freight effects. Empty logistics_categories means the effect applies to
	/// every requisition; otherwise it applies only to listed package categories.
	var/logistics_authorization_delay = 0
	var/logistics_dispatch_delay = 0
	var/logistics_transit_multiplier = 1
	var/list/logistics_categories = list()

	/// Sector-simulation effects. Interval multipliers above 1 slow generation.
	var/sector_message_interval_multiplier = 1
	var/sector_paperwork_interval_multiplier = 1
	var/critical_chance_modifier = 0

/datum/ccpost_installation_loss_effect/proc/has_logistics_effect()
	return logistics_authorization_delay || logistics_dispatch_delay || logistics_transit_multiplier != 1

/datum/ccpost_installation_loss_effect/rel_a17
	summary = "Long-range authorization traffic is being rerouted through alternate infrastructure, increasing freight authorization times."
	logistics_authorization_delay = 15 SECONDS

/datum/ccpost_installation_loss_effect/out_k04
	summary = "Regional monitoring and administrative coordination capacity has been reduced. Sector communications and routine paperwork will arrive less frequently."
	sector_message_interval_multiplier = 1.25
	sector_paperwork_interval_multiplier = 1.25

/datum/ccpost_installation_loss_effect/min_rc12
	summary = "Engineering and material requisitions must be sourced from more distant industrial suppliers, increasing their freight transit time."
	logistics_transit_multiplier = 1.35
	logistics_categories = list("Engineering", "Materials")

/datum/ccpost_installation_loss_effect/lp_d03
	summary = "Deep-space early-warning coverage has been reduced. Surviving installations face a slightly increased chance of Critical escalation."
	critical_chance_modifier = 3

/datum/ccpost_installation_loss_effect/adm_06
	summary = "Regional administrative processing has been rerouted, increasing freight requisition authorization times."
	logistics_authorization_delay = 15 SECONDS

/datum/ccpost_installation_loss_effect/log_h09
	summary = "Sector freight dispatch has been rerouted through distant infrastructure, significantly increasing dispatch and transit times."
	logistics_dispatch_delay = 20 SECONDS
	logistics_transit_multiplier = 1.75

/datum/ccpost_installation_loss_effect/med_m12
	summary = "Medical requisitions must be sourced from more distant distribution centers, increasing their freight transit time."
	logistics_transit_multiplier = 1.5
	logistics_categories = list("Medical")

/datum/ccpost_installation_loss_effect/sec_s08
	summary = "Regional Security coordination and response coverage has been degraded. Surviving installations face an increased chance of Critical escalation."
	critical_chance_modifier = 5


/datum/ccpost_sector_installation_template
	var/installation_code
	var/installation_name
	var/installation_function
	/// Player-facing description of the wider sector capability provided by this installation.
	var/regional_dependency = "No unique regional dependency has been recorded for this installation."
	var/initial_status = CCPOST_INSTALLATION_ONLINE
	var/list/contact_types = list()

	/// Typepaths for installation-specific configuration datums.
	var/response_profile_type = /datum/ccpost_installation_response_profile
	var/loss_effect_type = /datum/ccpost_installation_loss_effect

/datum/ccpost_sector_contact/rel_a17/contact_1
	contact_name = "Addust Johnson"
	contact_role = "Communications Supervisor"

/datum/ccpost_sector_contact/rel_a17/contact_2
	contact_name = "Chip Shafer"
	contact_role = "Senior Relay Technician"

/datum/ccpost_sector_contact/rel_a17/contact_3
	contact_name = "Talia Mercer"
	contact_role = "Relay Operations Officer"

/datum/ccpost_sector_contact/rel_a17/contact_4
	contact_name = "DAV-714"
	contact_role = "Relay Diagnostics Unit"

/datum/ccpost_sector_installation_template/rel_a17
	installation_code = CCPOST_INSTALLATION_CODE_REL_A17
	installation_name = "Relay Station A-17"
	installation_function = "Long-range communications relay"
	regional_dependency = "Provides long-range communications and authorization routing for the sector. Loss forces freight approvals through slower alternate communications infrastructure."
	response_profile_type = /datum/ccpost_installation_response_profile/rel_a17
	loss_effect_type = /datum/ccpost_installation_loss_effect/rel_a17
	contact_types = list(
		/datum/ccpost_sector_contact/rel_a17/contact_1,
		/datum/ccpost_sector_contact/rel_a17/contact_2,
		/datum/ccpost_sector_contact/rel_a17/contact_3,
		/datum/ccpost_sector_contact/rel_a17/contact_4
	)

/datum/ccpost_sector_contact/out_k04/contact_1
	contact_name = "Sasha Straljevic"
	contact_role = "Outpost Administrator"

/datum/ccpost_sector_contact/out_k04/contact_2
	contact_name = "Sian West"
	contact_role = "Operations Coordinator"

/datum/ccpost_sector_contact/out_k04/contact_3
	contact_name = "Renee Kessler"
	contact_role = "Command Duty Officer"

/datum/ccpost_sector_installation_template/out_k04
	installation_code = CCPOST_INSTALLATION_CODE_OUT_K04
	installation_name = "Outpost Kappa-4"
	installation_function = "Administrative monitoring outpost"
	regional_dependency = "Provides regional monitoring and administrative coordination. Loss reduces the frequency of routine sector communications and administrative paperwork."
	initial_status = CCPOST_INSTALLATION_ROUTINE
	response_profile_type = /datum/ccpost_installation_response_profile/out_k04
	loss_effect_type = /datum/ccpost_installation_loss_effect/out_k04
	contact_types = list(
		/datum/ccpost_sector_contact/out_k04/contact_1,
		/datum/ccpost_sector_contact/out_k04/contact_2,
		/datum/ccpost_sector_contact/out_k04/contact_3
	)

/datum/ccpost_sector_contact/min_rc12/contact_1
	contact_name = "Sally Braun"
	contact_role = "Platform Superintendent"

/datum/ccpost_sector_contact/min_rc12/contact_2
	contact_name = "Erebus Heretak"
	contact_role = "Senior Mining Foreman"

/datum/ccpost_sector_contact/min_rc12/contact_3
	contact_name = "Jeanna Lafortune"
	contact_role = "Platform Operations Chief"

/datum/ccpost_sector_installation_template/min_rc12
	installation_code = CCPOST_INSTALLATION_CODE_MIN_RC12
	installation_name = "Mining Platform RC-12"
	installation_function = "Mineral extraction and processing platform"
	regional_dependency = "Provides nearby industrial extraction and material sourcing. Loss increases Engineering and Materials freight transit times."
	initial_status = CCPOST_INSTALLATION_ROUTINE
	response_profile_type = /datum/ccpost_installation_response_profile/min_rc12
	loss_effect_type = /datum/ccpost_installation_loss_effect/min_rc12
	contact_types = list(
		/datum/ccpost_sector_contact/min_rc12/contact_1,
		/datum/ccpost_sector_contact/min_rc12/contact_2,
		/datum/ccpost_sector_contact/min_rc12/contact_3
	)

/datum/ccpost_sector_contact/lp_d03/contact_1
	contact_name = "Sera Vale"
	contact_role = "Watch Officer"

/datum/ccpost_sector_contact/lp_d03/contact_2
	contact_name = "Tomas Vek"
	contact_role = "Senior Signal Analyst"

/datum/ccpost_sector_contact/lp_d03/contact_3
	contact_name = "Mira Kessler"
	contact_role = "Monitoring Supervisor"

/datum/ccpost_sector_installation_template/lp_d03
	installation_code = CCPOST_INSTALLATION_CODE_LP_D03
	installation_name = "Listening Post Delta-3"
	installation_function = "Deep-space communications monitoring"
	regional_dependency = "Provides deep-space monitoring and early-warning coverage. Loss increases the chance that operational problems at surviving installations escalate into Critical incidents."
	response_profile_type = /datum/ccpost_installation_response_profile/lp_d03
	loss_effect_type = /datum/ccpost_installation_loss_effect/lp_d03
	contact_types = list(
		/datum/ccpost_sector_contact/lp_d03/contact_1,
		/datum/ccpost_sector_contact/lp_d03/contact_2,
		/datum/ccpost_sector_contact/lp_d03/contact_3
	)

/datum/ccpost_sector_contact/adm_06/contact_1
	contact_name = "Rinne Kudo"
	contact_role = "Senior Records Officer"

/datum/ccpost_sector_contact/adm_06/contact_2
	contact_name = "Adrian Vos"
	contact_role = "Compliance Coordinator"

/datum/ccpost_sector_contact/adm_06/contact_3
	contact_name = "Marianne Cole"
	contact_role = "Administrative Supervisor"

/datum/ccpost_sector_installation_template/adm_06
	installation_code = CCPOST_INSTALLATION_CODE_ADM_06
	installation_name = "Administrative Annex 6"
	installation_function = "Regional records and compliance office"
	regional_dependency = "Provides regional records, compliance, and requisition-processing support. Loss increases freight authorization times."
	initial_status = CCPOST_INSTALLATION_UNDER_REVIEW
	response_profile_type = /datum/ccpost_installation_response_profile/adm_06
	loss_effect_type = /datum/ccpost_installation_loss_effect/adm_06
	contact_types = list(
		/datum/ccpost_sector_contact/adm_06/contact_1,
		/datum/ccpost_sector_contact/adm_06/contact_2,
		/datum/ccpost_sector_contact/adm_06/contact_3
	)

/datum/ccpost_sector_contact/log_h09/contact_1
	contact_name = "Mara Venn"
	contact_role = "Senior Freight Controller"

/datum/ccpost_sector_contact/log_h09/contact_2
	contact_name = "Darius Cole"
	contact_role = "Routing Supervisor"

/datum/ccpost_sector_contact/log_h09/contact_3
	contact_name = "Victor Graham"
	contact_role = "Logistics Operations Officer"

/datum/ccpost_sector_contact/log_h09/contact_4
	contact_name = "Randolph P. Checkers Esq."
	contact_role = "Quartermaster"

/datum/ccpost_sector_installation_template/log_h09
	installation_code = CCPOST_INSTALLATION_CODE_LOG_H09
	installation_name = "Logistics Station H-9"
	installation_function = "Freight routing and supply coordination"
	regional_dependency = "Provides sector freight routing and supply coordination. Loss significantly increases freight dispatch and transit times."
	initial_status = CCPOST_INSTALLATION_ROUTINE
	response_profile_type = /datum/ccpost_installation_response_profile/log_h09
	loss_effect_type = /datum/ccpost_installation_loss_effect/log_h09
	contact_types = list(
		/datum/ccpost_sector_contact/log_h09/contact_1,
		/datum/ccpost_sector_contact/log_h09/contact_2,
		/datum/ccpost_sector_contact/log_h09/contact_3,
		/datum/ccpost_sector_contact/log_h09/contact_4
	)

/datum/ccpost_sector_contact/med_m12/contact_1
	contact_name = "Evelina Lee"
	contact_role = "Medical Logistics Supervisor"

/datum/ccpost_sector_contact/med_m12/contact_2
	contact_name = "Dr. Jack Anderson"
	contact_role = "Pharmaceutical Compliance Officer"

/datum/ccpost_sector_contact/med_m12/contact_3
	contact_name = "A.X.O."
	contact_role = "Cold-Chain Operations Coordinator Unit"

/datum/ccpost_sector_contact/med_m12/contact_4
	contact_name = "Frank DuFresne"
	contact_role = "Medical Officer Super Private First Class"

/datum/ccpost_sector_installation_template/med_m12
	installation_code = CCPOST_INSTALLATION_CODE_MED_M12
	installation_name = "Medical Distribution Center M-12"
	installation_function = "Regional medical supply and pharmaceutical distribution"
	regional_dependency = "Provides regional medical and pharmaceutical distribution. Loss increases Medical freight transit times."
	initial_status = CCPOST_INSTALLATION_ROUTINE
	response_profile_type = /datum/ccpost_installation_response_profile/med_m12
	loss_effect_type = /datum/ccpost_installation_loss_effect/med_m12
	contact_types = list(
		/datum/ccpost_sector_contact/med_m12/contact_1,
		/datum/ccpost_sector_contact/med_m12/contact_2,
		/datum/ccpost_sector_contact/med_m12/contact_3,
		/datum/ccpost_sector_contact/med_m12/contact_4
	)


/datum/ccpost_sector_contact/sec_s08/contact_1
	contact_name = "Jeff Gaiman"
	contact_role = "Sector Security Coordinator"

/datum/ccpost_sector_contact/sec_s08/contact_2
	contact_name = "Samantha Rosia"
	contact_role = "Security Intelligence Officer"

/datum/ccpost_sector_contact/sec_s08/contact_3
	contact_name = "Signy Mallory"
	contact_role = "Patrol Operations Supervisor"

/datum/ccpost_sector_contact/sec_s08/contact_4
	contact_name = "SENTRY-8"
	contact_role = "Security Analysis Unit"

/datum/ccpost_sector_installation_template/sec_s08
	installation_code = CCPOST_INSTALLATION_CODE_SEC_S08
	installation_name = "Sector Security Outpost S-8"
	installation_function = "Regional security coordination, patrol dispatch, and threat assessment"
	regional_dependency = "Provides regional security coordination, patrol dispatch, and threat assessment. Loss increases the chance that operational problems at surviving installations escalate into Critical incidents."
	initial_status = CCPOST_INSTALLATION_ROUTINE
	response_profile_type = /datum/ccpost_installation_response_profile/sec_s08
	loss_effect_type = /datum/ccpost_installation_loss_effect/sec_s08
	contact_types = list(
		/datum/ccpost_sector_contact/sec_s08/contact_1,
		/datum/ccpost_sector_contact/sec_s08/contact_2,
		/datum/ccpost_sector_contact/sec_s08/contact_3,
		/datum/ccpost_sector_contact/sec_s08/contact_4
	)


// Sector paperwork template definitions

/datum/ccpost_sector_paperwork_template
	var/template_id
	var/installation_code
	var/title
	var/body

/datum/ccpost_sector_paperwork_template/a17_relay_maintenance_certification
	template_id = "a17_relay_maintenance_certification"
	installation_code = CCPOST_INSTALLATION_CODE_REL_A17
	title = "Relay Maintenance Certification Review"
	body = "A-17 has completed a scheduled certification pass on one of the long-range relay segments. Local Engineering has signed off on the hardware inspection, but regional procedure requires Central Liaison acknowledgment before the certification can be closed and returned to the maintenance archive."

/datum/ccpost_sector_paperwork_template/a17_routing_exception
	template_id = "a17_routing_exception"
	installation_code = CCPOST_INSTALLATION_CODE_REL_A17
	title = "Communications Routing Exception"
	body = "A burst of civilian and corporate traffic was temporarily routed through a secondary trunk during scheduled synchronization work. No messages are reported lost. A-17 requests Liaison review of the routing exception before the record is closed."

/datum/ccpost_sector_paperwork_template/a17_signal_retention
	template_id = "a17_signal_retention"
	installation_code = CCPOST_INSTALLATION_CODE_REL_A17
	title = "Signal Retention Authorization"
	body = "A-17 has retained a routine diagnostic signal capture beyond the normal automated purge window because the recording may be useful for future alignment work. Central Liaison authorization is requested to retain the file in the regional technical archive."

/datum/ccpost_sector_paperwork_template/kappa4_monitoring_coverage
	template_id = "kappa4_monitoring_coverage"
	installation_code = CCPOST_INSTALLATION_CODE_OUT_K04
	title = "Monitoring Coverage Review"
	body = "Kappa-4 has adjusted several observation packages to remove overlapping coverage and improve monitoring of a previously low-priority approach corridor. The revised coverage map requires Central Liaison acknowledgment before the local watch schedule is finalized."

/datum/ccpost_sector_paperwork_template/kappa4_equipment_custody
	template_id = "kappa4_equipment_custody"
	installation_code = CCPOST_INSTALLATION_CODE_OUT_K04
	title = "Monitoring Equipment Custody Record"
	body = "A portable monitoring package has been transferred between secured equipment lockers following a local inventory reconciliation. No equipment is missing. Kappa-4 requests Liaison authorization to close the custody-transfer record."

/datum/ccpost_sector_paperwork_template/kappa4_watch_variance
	template_id = "kappa4_watch_variance"
	installation_code = CCPOST_INSTALLATION_CODE_OUT_K04
	title = "Observation Schedule Variance"
	body = "Kappa-4 temporarily consolidated two low-traffic observation periods after a routine staffing adjustment. Required monitoring coverage was maintained. Central Liaison acknowledgment is requested before the variance is entered into the permanent watch record."

/datum/ccpost_sector_paperwork_template/rc12_production_variance
	template_id = "rc12_production_variance"
	installation_code = CCPOST_INSTALLATION_CODE_MIN_RC12
	title = "Production Variance Certification"
	body = "RC-12 reports a minor production variance after one processing line operated below projected throughput for part of the shift. Recovered output remains within contract tolerance. Liaison review is requested before the variance is certified and closed."

/datum/ccpost_sector_paperwork_template/rc12_safety_acknowledgement
	template_id = "rc12_safety_acknowledgement"
	installation_code = CCPOST_INSTALLATION_CODE_MIN_RC12
	title = "Industrial Safety Acknowledgment"
	body = "A scheduled safety inspection identified a restricted-access industrial area requiring updated hazard markings and revised maintenance signage. Corrective work has been completed. Central Liaison acknowledgment is requested for the compliance record."

/datum/ccpost_sector_paperwork_template/rc12_shipment_discrepancy
	template_id = "rc12_shipment_discrepancy"
	installation_code = CCPOST_INSTALLATION_CODE_MIN_RC12
	title = "Mineral Shipment Discrepancy Review"
	body = "A routine shipment reconciliation found a small difference between automated ore-weight records and the final freight manifest. Local staff attribute the variance to processing residue and container calibration. Liaison review is requested before the manifest is finalized."

/datum/ccpost_sector_paperwork_template/delta3_intercept_retention
	template_id = "delta3_intercept_retention"
	installation_code = CCPOST_INSTALLATION_CODE_LP_D03
	title = "Classified Intercept Retention"
	body = "Delta-3 has flagged an otherwise low-priority encrypted intercept for extended retention because its transmission pattern may assist future signal comparison. No immediate threat is indicated. Central Liaison authorization is requested to retain the recording."

/datum/ccpost_sector_paperwork_template/delta3_sensor_anomaly
	template_id = "delta3_sensor_anomaly"
	installation_code = CCPOST_INSTALLATION_CODE_LP_D03
	title = "Sensor Anomaly Disposition"
	body = "A short-lived sensor contact could not be reproduced during follow-up sweeps and is presently assessed as instrumentation noise. Delta-3 requests Liaison review before the event is reclassified and removed from active monitoring."

/datum/ccpost_sector_paperwork_template/delta3_log_release
	template_id = "delta3_log_release"
	installation_code = CCPOST_INSTALLATION_CODE_LP_D03
	title = "Monitoring Log Release Authorization"
	body = "A completed monitoring log has reached the end of its restricted local review period. Delta-3 requests Central Liaison authorization to release the record into the standard classified archive and close the local handling entry."

/datum/ccpost_sector_paperwork_template/annex6_personnel_discrepancy
	template_id = "annex6_personnel_discrepancy"
	installation_code = CCPOST_INSTALLATION_CODE_ADM_06
	title = "Regional Personnel Record Discrepancy Review"
	body = "A discrepancy has been identified between archived personnel-transfer records and current regional assignment records. The affected entries have been isolated from automated processing. Central Liaison review is requested before the records are returned to active circulation."

/datum/ccpost_sector_paperwork_template/annex6_archive_release
	template_id = "annex6_archive_release"
	installation_code = CCPOST_INSTALLATION_CODE_ADM_06
	title = "Archive Release Authorization"
	body = "A closed regional operations file has completed its required retention hold and is eligible for transfer into the general corporate archive. Annex 6 requests Liaison authorization before the file is released from restricted archival status."

/datum/ccpost_sector_paperwork_template/annex6_compliance_closure
	template_id = "annex6_compliance_closure"
	installation_code = CCPOST_INSTALLATION_CODE_ADM_06
	title = "Compliance File Closure"
	body = "A routine regional compliance review has been completed with no outstanding corrective actions. Annex 6 requests Central Liaison acknowledgment before the review file is formally closed and removed from the active docket."

/datum/ccpost_sector_paperwork_template/h09_freight_exception
	template_id = "h09_freight_exception"
	installation_code = CCPOST_INSTALLATION_CODE_LOG_H09
	title = "Freight Routing Exception Authorization"
	body = "Three freight consignments were manually rerouted around a temporary automated scheduling conflict. All consignments reached their intended destinations. H-9 requests Liaison acknowledgment before the routing exception is closed."

/datum/ccpost_sector_paperwork_template/h09_cargo_loss_declaration
	template_id = "h09_cargo_loss_declaration"
	installation_code = CCPOST_INSTALLATION_CODE_LOG_H09
	title = "Minor Cargo Loss Declaration"
	body = "A freight container arrived with a small quantity of low-value packing material missing from the recorded load. No controlled or operationally significant cargo is affected. Central Liaison review is requested before the loss declaration is finalized."

/datum/ccpost_sector_paperwork_template/h09_dispatch_reconciliation
	template_id = "h09_dispatch_reconciliation"
	installation_code = CCPOST_INSTALLATION_CODE_LOG_H09
	title = "Dispatch Reconciliation Record"
	body = "H-9 has reconciled a set of manual dispatch entries created during routine controller maintenance. All referenced freight has been accounted for. Liaison authorization is requested to merge the manual record into the automated routing archive."

/datum/ccpost_sector_paperwork_template/med12_quarantine_release
	template_id = "med12_quarantine_release"
	installation_code = CCPOST_INSTALLATION_CODE_MED_M12
	title = "Medical Stock Quarantine Release"
	body = "A routine quality-control hold on a medical supply batch has concluded with no contamination or storage defects identified. M-12 requests Central Liaison authorization before the batch is released back into regional distribution inventory."

/datum/ccpost_sector_paperwork_template/med12_coldchain_variance
	template_id = "med12_coldchain_variance"
	installation_code = CCPOST_INSTALLATION_CODE_MED_M12
	title = "Cold-Chain Variance Review"
	body = "One monitored shipment briefly approached the upper limit of its approved storage range during transfer. Local validation indicates the stock remains usable. Liaison review is requested before the variance is closed and the shipment cleared."

/datum/ccpost_sector_paperwork_template/med12_inventory_certification
	template_id = "med12_inventory_certification"
	installation_code = CCPOST_INSTALLATION_CODE_MED_M12
	title = "Regional Medical Inventory Certification"
	body = "M-12 has completed a routine reconciliation of controlled regional medical stock. Physical counts and distribution records are within acceptable tolerance. Central Liaison acknowledgment is requested before the certification is entered into the permanent inventory record."


/datum/ccpost_sector_paperwork_template/sec8_patrol_after_action
	template_id = "sec8_patrol_after_action"
	installation_code = CCPOST_INSTALLATION_CODE_SEC_S08
	title = "Sector Patrol After-Action Review"
	body = "S-8 has completed the administrative review of a routine patrol interception involving an unregistered civilian vessel operating outside its declared route. No hostile activity was confirmed. Central Liaison acknowledgment is requested before the after-action file is closed and transferred to the regional security archive."

/datum/ccpost_sector_paperwork_template/sec8_evidence_transfer
	template_id = "sec8_evidence_transfer"
	installation_code = CCPOST_INSTALLATION_CODE_SEC_S08
	title = "Restricted Evidence Transfer Authorization"
	body = "A completed regional investigation has left several secured evidence containers eligible for transfer into long-term Central Security storage. Chain-of-custody records are complete. S-8 requests Liaison authorization before the evidence leaves local custody."

/datum/ccpost_sector_paperwork_template/sec8_armory_reconciliation
	template_id = "sec8_armory_reconciliation"
	installation_code = CCPOST_INSTALLATION_CODE_SEC_S08
	title = "Regional Armory Reconciliation"
	body = "S-8 has completed a scheduled reconciliation of controlled weapons, ammunition, and restricted security equipment. Physical inventory and authorization records are within acceptable tolerance. Central Liaison acknowledgment is requested before the certification is entered into the permanent security record."


// Sector message template definitions

/datum/ccpost_sector_message_template
	var/template_id
	var/installation_code
	var/message_type = CCPOST_MESSAGE_UPDATE
	var/priority = CCPOST_PRIORITY_ROUTINE
	var/title
	var/body
	var/list/required_statuses = list()
	var/allocation_cost = 0
	var/allocation_reward = 0
	var/success_status
	var/success_details
	var/reactive_aid = FALSE

/datum/ccpost_sector_message_template/New(_template_id, _installation_code, _message_type, _priority, _title, _body, list/_required_statuses)
	. = ..()
	if(!isnull(_template_id))
		template_id = _template_id
	if(!isnull(_installation_code))
		installation_code = _installation_code
	if(!isnull(_message_type))
		message_type = _message_type
	if(!isnull(_priority))
		priority = _priority
	if(!isnull(_title))
		title = _title
	if(!isnull(_body))
		body = _body
	if(_required_statuses)
		required_statuses = _required_statuses.Copy()

/datum/ccpost_sector_message_template/relay_nominal_update
	template_id = "relay_nominal_update"
	installation_code = CCPOST_INSTALLATION_CODE_REL_A17
	title = "Relay Operations Update"
	body = "Primary and secondary relay channels are holding synchronization. We completed the scheduled alignment pass without finding anything that requires intervention. Traffic remains steady and, for once, uneventful."
	required_statuses = list(CCPOST_INSTALLATION_ONLINE, CCPOST_INSTALLATION_ROUTINE)

/datum/ccpost_sector_message_template/a17_bandwidth_credit
	template_id = "a17_bandwidth_credit"
	installation_code = CCPOST_INSTALLATION_CODE_REL_A17
	title = "Unused Relay Capacity Reconciliation"
	body = "Commercial routing demand came in below forecast this cycle. The unused relay reservation has been released and Sector Communications has approved a small transfer back to Liaison-controlled operational funds."
	required_statuses = list(CCPOST_INSTALLATION_ONLINE, CCPOST_INSTALLATION_ROUTINE)
	allocation_reward = 2

/datum/ccpost_sector_message_template/a17_preventative_parts
	template_id = "a17_preventative_parts"
	installation_code = CCPOST_INSTALLATION_CODE_REL_A17
	message_type = CCPOST_MESSAGE_REQUEST
	title = "Preventative Transmitter Service"
	body = "Diagnostics are still green, but two transmitter couplings are approaching their recommended service limit. I'd rather replace them during a quiet window than explain why we waited until one failed. Requesting a small preventative maintenance allocation."
	required_statuses = list(CCPOST_INSTALLATION_ONLINE, CCPOST_INSTALLATION_ROUTINE)
	allocation_cost = 2
	success_details = "Preventative transmitter servicing has been completed ahead of the next maintenance threshold."

/datum/ccpost_sector_message_template/a17_capacitor_reserve
	template_id = "a17_capacitor_reserve"
	installation_code = CCPOST_INSTALLATION_CODE_REL_A17
	message_type = CCPOST_MESSAGE_REQUEST
	title = "Emergency Capacitor Reserve"
	body = "Our spare pulse-capacitor stock is below the recommended reserve after last cycle's replacements. Nothing is failing right now. I am requesting authorization to replenish the reserve before that sentence becomes less reassuring."
	required_statuses = list(CCPOST_INSTALLATION_ONLINE, CCPOST_INSTALLATION_ROUTINE)
	allocation_cost = 3
	success_details = "Emergency capacitor reserves have been replenished to recommended levels."

/datum/ccpost_sector_message_template/kappa4_quiet_shift
	template_id = "kappa4_quiet_shift"
	installation_code = CCPOST_INSTALLATION_CODE_OUT_K04
	title = "Monitoring Shift Summary"
	body = "The current watch has been quiet. No abnormal traffic, no unscheduled dockings, and no equipment alarms worth elevating. The night crew has asked me to formally note that this is not a complaint."
	required_statuses = list(CCPOST_INSTALLATION_ONLINE, CCPOST_INSTALLATION_ROUTINE)

/datum/ccpost_sector_message_template/kappa4_budget_return
	template_id = "kappa4_budget_return"
	installation_code = CCPOST_INSTALLATION_CODE_OUT_K04
	title = "Monitoring Budget Adjustment"
	body = "A scheduled sensor package replacement was completed below projected cost. The unused portion has been cleared for return to sector operational allocation rather than being consumed by the end-of-cycle spending requirement."
	required_statuses = list(CCPOST_INSTALLATION_ONLINE, CCPOST_INSTALLATION_ROUTINE)
	allocation_reward = 1

/datum/ccpost_sector_message_template/kappa4_sensor_refresh
	template_id = "kappa4_sensor_refresh"
	installation_code = CCPOST_INSTALLATION_CODE_OUT_K04
	message_type = CCPOST_MESSAGE_REQUEST
	title = "Remote Sensor Refresh"
	body = "Three external observation packages are still functional but have exceeded their preferred deployment hours. Replacing them now would avoid losing coverage one sensor at a time over the next few shifts. Requesting authorization for a refresh package."
	required_statuses = list(CCPOST_INSTALLATION_ONLINE, CCPOST_INSTALLATION_ROUTINE)
	allocation_cost = 3
	success_details = "A replacement set of remote monitoring packages has been deployed."

/datum/ccpost_sector_message_template/kappa4_backup_batteries
	template_id = "kappa4_backup_batteries"
	installation_code = CCPOST_INSTALLATION_CODE_OUT_K04
	message_type = CCPOST_MESSAGE_REQUEST
	title = "Backup Power Reserve"
	body = "Our emergency battery rack passed inspection, but reserve capacity is lower than I'd like after repeated charge cycling. The outpost can continue normally without replacement. I'd prefer not to discover how long 'normally' lasts during an actual outage."
	required_statuses = list(CCPOST_INSTALLATION_ONLINE, CCPOST_INSTALLATION_ROUTINE)
	allocation_cost = 2
	success_details = "Backup power reserves have been restored to full rated capacity."

/datum/ccpost_sector_message_template/rc12_production_update
	template_id = "rc12_production_update"
	installation_code = CCPOST_INSTALLATION_CODE_MIN_RC12
	title = "Production Shift Report"
	body = "Processing throughput is on target and the extraction crews are ahead of quota. The only unplanned downtime this shift involved a jammed ore gate and one supervisor insisting that kicking it counted as a repair procedure."
	required_statuses = list(CCPOST_INSTALLATION_ONLINE, CCPOST_INSTALLATION_ROUTINE)

/datum/ccpost_sector_message_template/rc12_export_credit
	template_id = "rc12_export_credit"
	installation_code = CCPOST_INSTALLATION_CODE_MIN_RC12
	title = "Production Surplus Reconciliation"
	body = "Processed-material output exceeded the contracted requirement this cycle. A portion of the resulting operational surplus has been approved for redistribution to sector administrative support."
	required_statuses = list(CCPOST_INSTALLATION_ONLINE, CCPOST_INSTALLATION_ROUTINE)
	allocation_reward = 2

/datum/ccpost_sector_message_template/rc12_drill_spares
	template_id = "rc12_drill_spares"
	installation_code = CCPOST_INSTALLATION_CODE_MIN_RC12
	message_type = CCPOST_MESSAGE_REQUEST
	title = "Extraction Head Spare Stock"
	body = "We've used the last two spare extraction heads from local stores. The active units are fine, but the next hard failure will stop a line until replacement freight arrives. Requesting funding to restore minimum spare stock."
	required_statuses = list(CCPOST_INSTALLATION_ONLINE, CCPOST_INSTALLATION_ROUTINE)
	allocation_cost = 4
	success_details = "Critical extraction-head spares have been restored to platform inventory."

/datum/ccpost_sector_message_template/rc12_dust_filters
	template_id = "rc12_dust_filters"
	installation_code = CCPOST_INSTALLATION_CODE_MIN_RC12
	message_type = CCPOST_MESSAGE_REQUEST
	title = "Industrial Filtration Resupply"
	body = "Ore dust loading is higher than forecast and we're consuming filtration cartridges faster than planned. There is no immediate atmospheric concern. I'd like to keep it that way. Requesting a replacement filter shipment."
	required_statuses = list(CCPOST_INSTALLATION_ONLINE, CCPOST_INSTALLATION_ROUTINE)
	allocation_cost = 3
	success_details = "Industrial filtration reserves have been replenished."

/datum/ccpost_sector_message_template/delta3_watch_update
	template_id = "delta3_watch_update"
	installation_code = CCPOST_INSTALLATION_CODE_LP_D03
	title = "Deep-Space Watch Update"
	body = "The current watch remains uneventful. No significant unidentified transmissions or anomalous traffic have been detected. We did isolate a repeating carrier burst, but it turned out to be a commercial beacon with a damaged timing circuit."
	required_statuses = list(CCPOST_INSTALLATION_ONLINE, CCPOST_INSTALLATION_ROUTINE)

/datum/ccpost_sector_message_template/delta3_analysis_credit
	template_id = "delta3_analysis_credit"
	installation_code = CCPOST_INSTALLATION_CODE_LP_D03
	title = "Signal Analysis Resource Release"
	body = "A scheduled high-load analysis block was cancelled after the target signal was identified by another sector asset. The reserved processing allocation has been released for reassignment."
	required_statuses = list(CCPOST_INSTALLATION_ONLINE, CCPOST_INSTALLATION_ROUTINE)
	allocation_reward = 1

/datum/ccpost_sector_message_template/delta3_receiver_service
	template_id = "delta3_receiver_service"
	installation_code = CCPOST_INSTALLATION_CODE_LP_D03
	message_type = CCPOST_MESSAGE_REQUEST
	title = "Receiver Cooling Service"
	body = "Receiver bank two is within tolerance, but coolant efficiency has been trending down for three shifts. We can keep watching the sector as-is. I'm requesting service parts now so we don't have to choose between thermal limits and signal coverage later."
	required_statuses = list(CCPOST_INSTALLATION_ONLINE, CCPOST_INSTALLATION_ROUTINE)
	allocation_cost = 2
	success_details = "Receiver-bank cooling efficiency has been restored to nominal levels."

/datum/ccpost_sector_message_template/delta3_storage_array
	template_id = "delta3_storage_array"
	installation_code = CCPOST_INSTALLATION_CODE_LP_D03
	message_type = CCPOST_MESSAGE_REQUEST
	title = "Telemetry Archive Expansion"
	body = "We're retaining more raw traffic captures than projected after the recent sector anomalies. I can start purging older low-priority recordings, or you can authorize another archive module and let us keep the full comparison set."
	required_statuses = list(CCPOST_INSTALLATION_ONLINE, CCPOST_INSTALLATION_ROUTINE)
	allocation_cost = 3
	success_details = "Additional telemetry archive capacity has been installed."

/datum/ccpost_sector_message_template/annex6_records_update
	template_id = "annex6_records_update"
	installation_code = CCPOST_INSTALLATION_CODE_ADM_06
	title = "Records Processing Update"
	body = "The current filing backlog is within acceptable limits and all priority submissions have been indexed. Sixteen duplicate requisition forms were also identified and returned to their originating offices with professionally restrained annotations."
	required_statuses = list(CCPOST_INSTALLATION_ONLINE, CCPOST_INSTALLATION_ROUTINE)

/datum/ccpost_sector_message_template/annex6_efficiency_credit
	template_id = "annex6_efficiency_credit"
	installation_code = CCPOST_INSTALLATION_CODE_ADM_06
	title = "Administrative Cost Reconciliation"
	body = "A records-storage contract was consolidated ahead of renewal and the resulting savings have been approved for partial return to sector operational allocation. Please do not interpret this as precedent for future procurement requests."
	required_statuses = list(CCPOST_INSTALLATION_ONLINE, CCPOST_INSTALLATION_ROUTINE)
	allocation_reward = 1

/datum/ccpost_sector_message_template/annex6_archive_media
	template_id = "annex6_archive_media"
	installation_code = CCPOST_INSTALLATION_CODE_ADM_06
	message_type = CCPOST_MESSAGE_REQUEST
	title = "Archival Media Replenishment"
	body = "Long-term archival media is below our preferred reserve after an unusually document-heavy cycle. We can continue by rotating older media early, but that creates exactly the kind of audit trail I would rather not explain later. Requesting replenishment."
	required_statuses = list(CCPOST_INSTALLATION_ONLINE, CCPOST_INSTALLATION_ROUTINE)
	allocation_cost = 2
	success_details = "Long-term archival media reserves have been restored."

/datum/ccpost_sector_message_template/annex6_scanner_service
	template_id = "annex6_scanner_service"
	installation_code = CCPOST_INSTALLATION_CODE_ADM_06
	message_type = CCPOST_MESSAGE_REQUEST
	title = "Bulk Scanner Service Contract"
	body = "Two high-volume document scanners are beginning to misfeed under sustained load. They are technically still operational, which is accounting language for 'someone else will suffer later.' Requesting approval for preventative servicing."
	required_statuses = list(CCPOST_INSTALLATION_ONLINE, CCPOST_INSTALLATION_ROUTINE)
	allocation_cost = 2
	success_details = "High-volume records scanners have completed preventative servicing."

/datum/ccpost_sector_message_template/h09_lane_update
	template_id = "h09_lane_update"
	installation_code = CCPOST_INSTALLATION_CODE_LOG_H09
	title = "Freight Lane Status"
	body = "All assigned freight lanes are processing within forecast tolerances. We cleared the morning queue early and have enough spare routing capacity to absorb normal fluctuations without touching contingency lanes."
	required_statuses = list(CCPOST_INSTALLATION_ONLINE, CCPOST_INSTALLATION_ROUTINE)

/datum/ccpost_sector_message_template/h09_capacity_credit
	template_id = "h09_capacity_credit"
	installation_code = CCPOST_INSTALLATION_CODE_LOG_H09
	title = "Freight Capacity Reconciliation"
	body = "Our latest routing reconciliation identified unused operational capacity allocated to this installation. Sector Logistics approved transfer of the surplus back to Liaison-controlled operational funds."
	required_statuses = list(CCPOST_INSTALLATION_ONLINE, CCPOST_INSTALLATION_ROUTINE)
	allocation_reward = 3

/datum/ccpost_sector_message_template/h09_preventative_actuators
	template_id = "h09_preventative_actuators"
	installation_code = CCPOST_INSTALLATION_CODE_LOG_H09
	message_type = CCPOST_MESSAGE_REQUEST
	title = "Dock Actuator Preventative Service"
	body = "Two freight-dock actuators are starting to lag under load. They still pass inspection, but not by enough that I want to bet next week's traffic on them. Requesting replacement assemblies while we can schedule the work instead of reacting to it."
	required_statuses = list(CCPOST_INSTALLATION_ONLINE, CCPOST_INSTALLATION_ROUTINE)
	allocation_cost = 3
	success_details = "Freight-dock actuators have completed preventative replacement."

/datum/ccpost_sector_message_template/h09_tracking_beacons
	template_id = "h09_tracking_beacons"
	installation_code = CCPOST_INSTALLATION_CODE_LOG_H09
	message_type = CCPOST_MESSAGE_REQUEST
	title = "Freight Beacon Replacement"
	body = "Our reserve pallet of short-range cargo beacons is nearly empty after a bad batch was pulled from service. We can operate without a refill, but manual tagging will slow every exception case. Requesting authorization for replacement stock."
	required_statuses = list(CCPOST_INSTALLATION_ONLINE, CCPOST_INSTALLATION_ROUTINE)
	allocation_cost = 2
	success_details = "Freight tracking beacon reserves have been replenished."

/datum/ccpost_sector_message_template/med12_inventory_update
	template_id = "med12_inventory_update"
	installation_code = CCPOST_INSTALLATION_CODE_MED_M12
	title = "Regional Medical Inventory Update"
	body = "Regional medical inventory is within target range. Cold storage is stable, controlled stock reconciled cleanly, and the outgoing queue is moving without exceptions. I am documenting that now before something decides to become interesting."
	required_statuses = list(CCPOST_INSTALLATION_ONLINE, CCPOST_INSTALLATION_ROUTINE)

/datum/ccpost_sector_message_template/med12_surplus_credit
	template_id = "med12_surplus_credit"
	installation_code = CCPOST_INSTALLATION_CODE_MED_M12
	title = "Medical Logistics Surplus Release"
	body = "A planned emergency restock was cancelled after local demand came in below forecast. Central Medical Logistics has approved release of the unused operational allocation back into the sector pool."
	required_statuses = list(CCPOST_INSTALLATION_ONLINE, CCPOST_INSTALLATION_ROUTINE)
	allocation_reward = 2

/datum/ccpost_sector_message_template/med12_cold_chain_service
	template_id = "med12_cold_chain_service"
	installation_code = CCPOST_INSTALLATION_CODE_MED_M12
	message_type = CCPOST_MESSAGE_REQUEST
	title = "Cold-Chain Preventative Service"
	body = "Two pharmaceutical cold-storage compressors are still within tolerance, but their duty cycle is climbing faster than expected. I would rather service them while the medicine is cold and the technicians are calm. Requesting preventative maintenance allocation."
	required_statuses = list(CCPOST_INSTALLATION_ONLINE, CCPOST_INSTALLATION_ROUTINE)
	allocation_cost = 3
	success_details = "Preventative service has restored the pharmaceutical cold-chain system to preferred operating margins."

/datum/ccpost_sector_message_template/med12_sterile_packaging
	template_id = "med12_sterile_packaging"
	installation_code = CCPOST_INSTALLATION_CODE_MED_M12
	message_type = CCPOST_MESSAGE_REQUEST
	title = "Sterile Packaging Reserve"
	body = "Our sterile packaging reserve has fallen below the regional target after a larger-than-expected emergency shipment. Current orders are unaffected. Requesting a small replenishment before the next priority dispatch turns that into a problem."
	required_statuses = list(CCPOST_INSTALLATION_ONLINE, CCPOST_INSTALLATION_ROUTINE)
	allocation_cost = 2
	success_details = "Sterile packaging reserves have been replenished to regional target levels."

/datum/ccpost_sector_message_template/a17_encrypted_uplink_anomaly
	template_id = "a17_encrypted_uplink_anomaly"
	installation_code = CCPOST_INSTALLATION_CODE_REL_A17
	priority = CCPOST_PRIORITY_PRIORITY
	title = "Encrypted Uplink Interference"
	body = "We are tracing short encrypted bursts riding the edge of our commercial bands. The traffic pattern resembles known Syndicate uplink activity, but I do not have enough to call it a confirmed traitor channel. We have isolated the affected repeater and are watching for another handshake."
	required_statuses = list(CCPOST_INSTALLATION_UNDER_REVIEW, CCPOST_INSTALLATION_COMMS_DEGRADED)

/datum/ccpost_sector_message_template/a17_alignment_fault
	template_id = "a17_alignment_fault"
	installation_code = CCPOST_INSTALLATION_CODE_REL_A17
	title = "Relay Alignment Drift"
	body = "Array three has drifted out of preferred alignment twice this watch. Local technicians are compensating manually while diagnostics work through the actuator chain. Traffic is still moving, just with less redundancy than I would like."
	required_statuses = list(CCPOST_INSTALLATION_MAINTENANCE, CCPOST_INSTALLATION_COMMS_DEGRADED)

/datum/ccpost_sector_message_template/kappa4_identity_discrepancy
	template_id = "kappa4_identity_discrepancy"
	installation_code = CCPOST_INSTALLATION_CODE_OUT_K04
	priority = CCPOST_PRIORITY_PRIORITY
	title = "Personnel Identity Discrepancy"
	body = "We have two contradictory biometric records for the same member of staff and neither one is obviously corrupted. Until Security finishes the comparison, I have ordered controlled access and paired movement. Yes, someone already said 'changeling.' No, that does not make it confirmed."
	required_statuses = list(CCPOST_INSTALLATION_UNDER_REVIEW, CCPOST_INSTALLATION_COMMS_DEGRADED)

/datum/ccpost_sector_message_template/kappa4_sensor_blindspot
	template_id = "kappa4_sensor_blindspot"
	installation_code = CCPOST_INSTALLATION_CODE_OUT_K04
	title = "External Sensor Blind Spot"
	body = "A cluster of remote observation packages has dropped from the network. We still have overlapping coverage, but one approach corridor is being watched by fewer eyes than policy prefers. Local repair drones are en route."
	required_statuses = list(CCPOST_INSTALLATION_MAINTENANCE, CCPOST_INSTALLATION_COMMS_DEGRADED)

/datum/ccpost_sector_message_template/rc12_cult_markings
	template_id = "rc12_cult_markings"
	installation_code = CCPOST_INSTALLATION_CODE_MIN_RC12
	priority = CCPOST_PRIORITY_PRIORITY
	title = "Unauthorized Ritual Activity"
	body = "Maintenance found fresh geometric markings, blood residue, and an improvised ritual site inside a disused extraction gallery. Security is treating it as possible cultist or heretic activity until proven otherwise. The gallery is sealed and nobody is volunteering to clean it."
	required_statuses = list(CCPOST_INSTALLATION_UNDER_REVIEW, CCPOST_INSTALLATION_MAINTENANCE)

/datum/ccpost_sector_message_template/rc12_labor_unrest
	template_id = "rc12_labor_unrest"
	installation_code = CCPOST_INSTALLATION_CODE_MIN_RC12
	priority = CCPOST_PRIORITY_PRIORITY
	title = "Organized Labor Disruption"
	body = "A group of workers attempted to seize a processing control room after distributing anti-corporate material across the lower decks. Security has contained the immediate disturbance. Central has asked us to treat the matter as possible revolutionary activity pending investigation."
	required_statuses = list(CCPOST_INSTALLATION_UNDER_REVIEW, CCPOST_INSTALLATION_COMMS_DEGRADED)

/datum/ccpost_sector_message_template/delta3_nukeop_chatter
	template_id = "delta3_nukeop_chatter"
	installation_code = CCPOST_INSTALLATION_CODE_LP_D03
	priority = CCPOST_PRIORITY_IMPORTANT
	title = "Hostile Burst-Traffic Intercept"
	body = "We intercepted a tightly compressed burst sequence using authentication behavior associated with hostile Syndicate field teams. It could be spoofed traffic. It could also be nuclear operative chatter. We are preserving the raw capture and narrowing the bearing now."
	required_statuses = list(CCPOST_INSTALLATION_UNDER_REVIEW, CCPOST_INSTALLATION_COMMS_DEGRADED)

/datum/ccpost_sector_message_template/delta3_receiver_noise
	template_id = "delta3_receiver_noise"
	installation_code = CCPOST_INSTALLATION_CODE_LP_D03
	title = "Receiver Noise Excursion"
	body = "Receiver bank four is showing a persistent noise floor above calibration limits. We have moved priority watch traffic onto the cleaner arrays while engineering checks shielding and local power conditioning."
	required_statuses = list(CCPOST_INSTALLATION_MAINTENANCE, CCPOST_INSTALLATION_COMMS_DEGRADED)

/datum/ccpost_sector_message_template/annex6_revolutionary_material
	template_id = "annex6_revolutionary_material"
	installation_code = CCPOST_INSTALLATION_CODE_ADM_06
	priority = CCPOST_PRIORITY_PRIORITY
	title = "Unauthorized Political Material Review"
	body = "Internal Compliance found coordinated anti-corporate material embedded in staff bulletins and payroll notices. The wording matches several known revolutionary recruitment patterns. Access to the publishing queue has been restricted while Personnel works out who approved any of it."
	required_statuses = list(CCPOST_INSTALLATION_UNDER_REVIEW)

/datum/ccpost_sector_message_template/annex6_archive_mismatch
	template_id = "annex6_archive_mismatch"
	installation_code = CCPOST_INSTALLATION_CODE_ADM_06
	title = "Archive Reconciliation Delay"
	body = "Three regional record sets disagree on personnel transfer dates and nobody has yet found the original source document. The records are not lost, but they are currently proving that having three copies does not guarantee having one correct copy."
	required_statuses = list(CCPOST_INSTALLATION_UNDER_REVIEW, CCPOST_INSTALLATION_MAINTENANCE)

/datum/ccpost_sector_message_template/h09_manifest_sabotage
	template_id = "h09_manifest_sabotage"
	installation_code = CCPOST_INSTALLATION_CODE_LOG_H09
	priority = CCPOST_PRIORITY_PRIORITY
	title = "Freight Manifest Sabotage Review"
	body = "Someone altered routing tags on six outbound containers and tried to bury the changes inside an automated reconciliation batch. Security is treating it as deliberate sabotage and possible traitor activity. The affected freight is isolated while we rebuild the manifests by hand."
	required_statuses = list(CCPOST_INSTALLATION_UNDER_REVIEW, CCPOST_INSTALLATION_MAINTENANCE, CCPOST_INSTALLATION_COMMS_DEGRADED)

/datum/ccpost_sector_message_template/h09_conveyor_fault
	template_id = "h09_conveyor_fault"
	installation_code = CCPOST_INSTALLATION_CODE_LOG_H09
	title = "Freight Conveyor Isolation"
	body = "One of the transfer conveyors has been isolated after repeated motor faults. We are routing around it with manual handling and the secondary lane. Throughput is down, but nothing is stranded yet."
	required_statuses = list(CCPOST_INSTALLATION_MAINTENANCE, CCPOST_INSTALLATION_COMMS_DEGRADED)

/datum/ccpost_sector_message_template/med12_recall_operations
	template_id = "med12_recall_operations"
	installation_code = CCPOST_INSTALLATION_CODE_MED_M12
	priority = CCPOST_PRIORITY_IMPORTANT
	title = "Medical Recall Operations"
	body = "We are working the active batch recall now. Affected lots are being quarantined, shipment records are being cross-checked, and verified emergency stock remains available locally. Do not restart routine medical resupply from our channel until Central Medical Logistics clears the notice."
	required_statuses = list(CCPOST_INSTALLATION_UNDER_REVIEW)

/datum/ccpost_sector_message_template/med12_bloodsucker_investigation
	template_id = "med12_bloodsucker_investigation"
	installation_code = CCPOST_INSTALLATION_CODE_MED_M12
	priority = CCPOST_PRIORITY_PRIORITY
	title = "Unexplained Blood-Loss Cluster"
	body = "Medical has admitted three staff with unexplained blood loss and matching puncture trauma. Security has restricted access to the residential wing while we rule out equipment injury, assault, or bloodsucker activity. I would prefer the boring explanation."
	required_statuses = list(CCPOST_INSTALLATION_UNDER_REVIEW, CCPOST_INSTALLATION_MAINTENANCE)

/datum/ccpost_sector_message_template/med12_changeling_quarantine
	template_id = "med12_changeling_quarantine"
	installation_code = CCPOST_INSTALLATION_CODE_MED_M12
	priority = CCPOST_PRIORITY_IMPORTANT
	title = "Biometric Quarantine Protocol"
	body = "We have conflicting tissue and identity records from a restricted treatment room. The wing is under quarantine while pathology repeats the tests. Changeling contamination is one of the scenarios on the checklist, not a confirmed diagnosis."
	required_statuses = list(CCPOST_INSTALLATION_UNDER_REVIEW, CCPOST_INSTALLATION_COMMS_DEGRADED)

/datum/ccpost_sector_message_template/med12_cold_storage_variance
	template_id = "med12_cold_storage_variance"
	installation_code = CCPOST_INSTALLATION_CODE_MED_M12
	title = "Cold Storage Temperature Variance"
	body = "One pharmaceutical vault is fluctuating outside preferred temperature margins. Nothing has crossed discard thresholds, but the affected stock is being held while engineering checks the cooling loop and calibration sensors."
	required_statuses = list(CCPOST_INSTALLATION_MAINTENANCE, CCPOST_INSTALLATION_COMMS_DEGRADED)

/datum/ccpost_sector_message_template/a17_credential_spoof
	template_id = "a17_credential_spoof"
	installation_code = CCPOST_INSTALLATION_CODE_REL_A17
	priority = CCPOST_PRIORITY_PRIORITY
	title = "Credential-Spoofed Relay Traffic"
	body = "We caught a maintenance authorization using a valid employee credential several hours after that employee was confirmed off-station. Security is treating it as possible traitor access or identity theft while we revoke the affected keys and rebuild the relay permissions."
	required_statuses = list(CCPOST_INSTALLATION_UNDER_REVIEW, CCPOST_INSTALLATION_COMMS_DEGRADED)

/datum/ccpost_sector_message_template/a17_identity_voice_mismatch
	template_id = "a17_identity_voice_mismatch"
	installation_code = CCPOST_INSTALLATION_CODE_REL_A17
	priority = CCPOST_PRIORITY_IMPORTANT
	title = "Authenticated Voiceprint Mismatch"
	body = "A priority call arrived with valid credentials but a voiceprint that does not match the registered operator. The sender disconnected when challenged. Changeling impersonation is on the threat checklist, though a stolen credential remains the simpler explanation."
	required_statuses = list(CCPOST_INSTALLATION_UNDER_REVIEW, CCPOST_INSTALLATION_COMMS_DEGRADED)

/datum/ccpost_sector_message_template/kappa4_revolutionary_meeting
	template_id = "kappa4_revolutionary_meeting"
	installation_code = CCPOST_INSTALLATION_CODE_OUT_K04
	priority = CCPOST_PRIORITY_PRIORITY
	title = "Unauthorized Staff Assembly"
	body = "Security broke up an unauthorized staff meeting after anti-corporate slogans and improvised recruitment sheets were found in the room. No command personnel were harmed. We are reviewing the attendees for possible revolutionary organization rather than assuming every angry employee is part of a cell."
	required_statuses = list(CCPOST_INSTALLATION_UNDER_REVIEW, CCPOST_INSTALLATION_COMMS_DEGRADED)

/datum/ccpost_sector_message_template/kappa4_ritual_material
	template_id = "kappa4_ritual_material"
	installation_code = CCPOST_INSTALLATION_CODE_OUT_K04
	priority = CCPOST_PRIORITY_PRIORITY
	title = "Restricted Occult Materials"
	body = "A routine locker inspection turned up blood-marked diagrams, a ceremonial blade, and several pages of material that Security cannot identify. Possible cultist or heretic involvement has been referred upward. The owner insists it is a hobby. Nobody has found that reassuring."
	required_statuses = list(CCPOST_INSTALLATION_UNDER_REVIEW, CCPOST_INSTALLATION_MAINTENANCE)

/datum/ccpost_sector_message_template/rc12_bloodless_casualty
	template_id = "rc12_bloodless_casualty"
	installation_code = CCPOST_INSTALLATION_CODE_MIN_RC12
	priority = CCPOST_PRIORITY_IMPORTANT
	title = "Unexplained Exsanguination Case"
	body = "A miner was recovered alive but severely blood-depleted from a locked auxiliary tunnel with no equipment failure sufficient to explain it. Medical is stabilizing them while Security checks the access logs. Bloodsucker activity is one possibility under review."
	required_statuses = list(CCPOST_INSTALLATION_UNDER_REVIEW, CCPOST_INSTALLATION_MAINTENANCE, CCPOST_INSTALLATION_COMMS_DEGRADED)

/datum/ccpost_sector_message_template/rc12_syndicate_explosive
	template_id = "rc12_syndicate_explosive"
	installation_code = CCPOST_INSTALLATION_CODE_MIN_RC12
	priority = CCPOST_PRIORITY_PRIORITY
	title = "Unauthorized Demolition Charge"
	body = "Engineering recovered an improvised charge from a conveyor junction before it detonated. Several components resemble Syndicate procurement patterns. Security is treating this as deliberate sabotage and possible traitor activity while the processing line remains isolated."
	required_statuses = list(CCPOST_INSTALLATION_UNDER_REVIEW, CCPOST_INSTALLATION_MAINTENANCE, CCPOST_INSTALLATION_COMMS_DEGRADED)

/datum/ccpost_sector_message_template/delta3_occult_signal
	template_id = "delta3_occult_signal"
	installation_code = CCPOST_INSTALLATION_CODE_LP_D03
	priority = CCPOST_PRIORITY_IMPORTANT
	title = "Nonstandard Ritual Broadcast"
	body = "One receiver bank captured a repeating transmission made up of spoken phrases, geometric image bursts, and a carrier pattern with no recognized commercial purpose. Analysts flagged similarities to archived cultist and heretic incidents. We have isolated the recording from the general network."
	required_statuses = list(CCPOST_INSTALLATION_UNDER_REVIEW, CCPOST_INSTALLATION_COMMS_DEGRADED)

/datum/ccpost_sector_message_template/delta3_syndicate_dead_drop
	template_id = "delta3_syndicate_dead_drop"
	installation_code = CCPOST_INSTALLATION_CODE_LP_D03
	priority = CCPOST_PRIORITY_PRIORITY
	title = "Suspected Syndicate Dead-Drop Traffic"
	body = "We identified a burst schedule consistent with one-way dead-drop traffic: very short transmissions, irregular timing, and no acknowledgement packets. It may be a traitor uplink or contractor channel. Direction finding is in progress."
	required_statuses = list(CCPOST_INSTALLATION_UNDER_REVIEW, CCPOST_INSTALLATION_COMMS_DEGRADED)

/datum/ccpost_sector_message_template/annex6_credential_forgery
	template_id = "annex6_credential_forgery"
	installation_code = CCPOST_INSTALLATION_CODE_ADM_06
	priority = CCPOST_PRIORITY_PRIORITY
	title = "Command Credential Forgery Review"
	body = "Records staff found a command-level approval attached to a transfer order that the listed signatory denies issuing. The signature chain is technically valid. Internal Compliance is treating the case as possible traitor credential compromise until the signing key is accounted for."
	required_statuses = list(CCPOST_INSTALLATION_UNDER_REVIEW, CCPOST_INSTALLATION_MAINTENANCE)

/datum/ccpost_sector_message_template/annex6_duplicate_employee
	template_id = "annex6_duplicate_employee"
	installation_code = CCPOST_INSTALLATION_CODE_ADM_06
	priority = CCPOST_PRIORITY_IMPORTANT
	title = "Duplicate Personnel Record Escalation"
	body = "Two active personnel files now contain the same biometric identifiers but different assignment histories. Neither file appears to be a simple duplicate. Compliance has locked both records while Security investigates possible changeling impersonation or deliberate database tampering."
	required_statuses = list(CCPOST_INSTALLATION_UNDER_REVIEW)

/datum/ccpost_sector_message_template/h09_revolutionary_slowdown
	template_id = "h09_revolutionary_slowdown"
	installation_code = CCPOST_INSTALLATION_CODE_LOG_H09
	priority = CCPOST_PRIORITY_PRIORITY
	title = "Coordinated Freight Work Stoppage"
	body = "Several freight teams abandoned assigned lanes simultaneously after receiving identical anti-corporate messages over local headsets. Supervisors are restoring minimum throughput while Security checks whether this is ordinary labor action or organized revolutionary activity."
	required_statuses = list(CCPOST_INSTALLATION_UNDER_REVIEW, CCPOST_INSTALLATION_COMMS_DEGRADED)

/datum/ccpost_sector_message_template/h09_syndicate_cache
	template_id = "h09_syndicate_cache"
	installation_code = CCPOST_INSTALLATION_CODE_LOG_H09
	priority = CCPOST_PRIORITY_IMPORTANT
	title = "Unregistered Tactical Cargo Cache"
	body = "A container entered our holding stack under a valid freight code but contained unregistered tactical equipment instead of the declared machine parts. The packing pattern resembles Syndicate field logistics. We are checking whether this was a traitor shipment or preparation for a larger hostile team."
	required_statuses = list(CCPOST_INSTALLATION_UNDER_REVIEW, CCPOST_INSTALLATION_MAINTENANCE, CCPOST_INSTALLATION_COMMS_DEGRADED)

/datum/ccpost_sector_message_template/med12_occult_trauma
	template_id = "med12_occult_trauma"
	installation_code = CCPOST_INSTALLATION_CODE_MED_M12
	priority = CCPOST_PRIORITY_IMPORTANT
	title = "Anomalous Trauma Review"
	body = "Medical received two patients with matching wounds that do not correspond to any tool or industrial process logged on-site. One patient keeps describing impossible geometric structures. Security has opened a possible heretic or cultist incident review while treatment continues."
	required_statuses = list(CCPOST_INSTALLATION_UNDER_REVIEW, CCPOST_INSTALLATION_MAINTENANCE)

/datum/ccpost_sector_message_template/med12_syndicate_toxin
	template_id = "med12_syndicate_toxin"
	installation_code = CCPOST_INSTALLATION_CODE_MED_M12
	priority = CCPOST_PRIORITY_PRIORITY
	title = "Unregistered Toxin Exposure"
	body = "Toxicology identified an exposure pattern inconsistent with anything stocked by the facility. The compound profile overlaps with substances recovered in previous Syndicate sabotage cases. Pharmacy access is frozen while Security checks for a traitor or compromised shipment."
	required_statuses = list(CCPOST_INSTALLATION_UNDER_REVIEW, CCPOST_INSTALLATION_MAINTENANCE, CCPOST_INSTALLATION_COMMS_DEGRADED)

/datum/ccpost_sector_message_template/sec8_watch_summary
	template_id = "sec8_watch_summary"
	installation_code = CCPOST_INSTALLATION_CODE_SEC_S08
	title = "Sector Security Watch Summary"
	body = "Regional security traffic is within normal parameters. Scheduled patrols have checked in, no priority warrants remain outstanding, and the current threat board contains nothing requiring wider action. I am documenting that now before somebody decides to improve the statistics."
	required_statuses = list(CCPOST_INSTALLATION_ONLINE, CCPOST_INSTALLATION_ROUTINE)

/datum/ccpost_sector_message_template/sec8_reserve_credit
	template_id = "sec8_reserve_credit"
	installation_code = CCPOST_INSTALLATION_CODE_SEC_S08
	title = "Security Reserve Reconciliation"
	body = "A scheduled patrol deployment was cancelled after the originating threat report was downgraded. Central Security has released part of the unused operational reserve back into the sector allocation pool."
	required_statuses = list(CCPOST_INSTALLATION_ONLINE, CCPOST_INSTALLATION_ROUTINE)
	allocation_reward = 2

/datum/ccpost_sector_message_template/sec8_patrol_equipment
	template_id = "sec8_patrol_equipment"
	installation_code = CCPOST_INSTALLATION_CODE_SEC_S08
	message_type = CCPOST_MESSAGE_REQUEST
	title = "Patrol Equipment Reserve"
	body = "Our patrol teams have drawn down the reserve supply of replacement armor components, portable barriers, and field communication equipment faster than forecast. Current coverage is unaffected. I would prefer to replenish the reserve before the next security incident makes that sentence inaccurate."
	required_statuses = list(CCPOST_INSTALLATION_ONLINE, CCPOST_INSTALLATION_ROUTINE)
	allocation_cost = 3
	success_details = "Regional patrol equipment reserves have been restored to recommended readiness levels."

/datum/ccpost_sector_message_template/sec8_evidence_capacity
	template_id = "sec8_evidence_capacity"
	installation_code = CCPOST_INSTALLATION_CODE_SEC_S08
	message_type = CCPOST_MESSAGE_REQUEST
	title = "Secure Evidence Storage Expansion"
	body = "Restricted evidence storage is approaching its approved capacity after several investigations closed at once. We can begin transferring older material early, but that creates additional handling and chain-of-custody work. Requesting a small secure-storage expansion instead."
	required_statuses = list(CCPOST_INSTALLATION_ONLINE, CCPOST_INSTALLATION_ROUTINE)
	allocation_cost = 2
	success_details = "Additional secured evidence-storage capacity has been brought online."

/datum/ccpost_sector_message_template/sec8_missing_patrol
	template_id = "sec8_missing_patrol"
	installation_code = CCPOST_INSTALLATION_CODE_SEC_S08
	priority = CCPOST_PRIORITY_IMPORTANT
	title = "Patrol Craft Contact Loss"
	body = "One regional patrol craft missed two scheduled check-ins and has not responded on its authenticated backup channel. We do not currently have evidence of hostile action. Search routing has been adjusted and nearby assets are checking the patrol's last confirmed corridor."
	required_statuses = list(CCPOST_INSTALLATION_UNDER_REVIEW, CCPOST_INSTALLATION_COMMS_DEGRADED)

/datum/ccpost_sector_message_template/sec8_armory_discrepancy
	template_id = "sec8_armory_discrepancy"
	installation_code = CCPOST_INSTALLATION_CODE_SEC_S08
	priority = CCPOST_PRIORITY_PRIORITY
	title = "Controlled Armory Inventory Discrepancy"
	body = "A restricted armory reconciliation has identified equipment movement without a matching authorization record. The affected storage section is locked down while Security reconstructs the access chain. Nothing is being declared stolen until the records and physical inventory agree."
	required_statuses = list(CCPOST_INSTALLATION_UNDER_REVIEW, CCPOST_INSTALLATION_MAINTENANCE)

/datum/ccpost_sector_message_template/sec8_credential_compromise
	template_id = "sec8_credential_compromise"
	installation_code = CCPOST_INSTALLATION_CODE_SEC_S08
	priority = CCPOST_PRIORITY_PRIORITY
	title = "Security Credential Compromise Review"
	body = "Multiple privileged security actions were authenticated through credentials whose assigned personnel deny performing them. Those credentials have been revoked and replacement keys are being issued from isolated systems. We are treating the event as deliberate compromise until proven otherwise."
	required_statuses = list(CCPOST_INSTALLATION_UNDER_REVIEW, CCPOST_INSTALLATION_COMMS_DEGRADED)

/datum/ccpost_sector_message_template/a17_backup_transmitter_calibration
	template_id = "a17_backup_transmitter_calibration"
	installation_code = CCPOST_INSTALLATION_CODE_REL_A17
	priority = CCPOST_PRIORITY_ADVISORY
	title = "Backup Transmitter Calibration"
	body = "A secondary transmitter has been taken out of rotation for calibration after its timing drifted beyond our preferred tolerance. Primary traffic is unaffected and redundancy remains available, but maintenance will keep the unit isolated until the synchronization pass is complete."
	required_statuses = list(CCPOST_INSTALLATION_MAINTENANCE)

/datum/ccpost_sector_message_template/kappa4_sensor_power_cycle
	template_id = "kappa4_sensor_power_cycle"
	installation_code = CCPOST_INSTALLATION_CODE_OUT_K04
	priority = CCPOST_PRIORITY_ADVISORY
	title = "Remote Sensor Power Cycling"
	body = "Several exterior monitoring nodes are being power-cycled after intermittent synchronization faults. Coverage has been redistributed across the remaining array while technicians work through the affected units. No intrusion indicators have been confirmed."
	required_statuses = list(CCPOST_INSTALLATION_MAINTENANCE, CCPOST_INSTALLATION_COMMS_DEGRADED)

/datum/ccpost_sector_message_template/delta3_passive_array_calibration
	template_id = "delta3_passive_array_calibration"
	installation_code = CCPOST_INSTALLATION_CODE_LP_D03
	priority = CCPOST_PRIORITY_ADVISORY
	title = "Passive Sensor Array Calibration"
	body = "One passive sensor bank is undergoing a full calibration pass after accumulating enough baseline drift to affect low-confidence contacts. The remaining arrays are carrying the watch while the affected bank is kept out of analysis rotation."
	required_statuses = list(CCPOST_INSTALLATION_MAINTENANCE)

/datum/ccpost_sector_message_template/annex6_records_sync_failure
	template_id = "annex6_records_sync_failure"
	installation_code = CCPOST_INSTALLATION_CODE_ADM_06
	priority = CCPOST_PRIORITY_ADVISORY
	title = "Records Synchronization Failure"
	body = "Remote archive synchronization is returning incomplete verification receipts. Annex 6 has moved nonessential record transfers into a local holding queue until the communications link can reliably confirm both sides of the transaction."
	required_statuses = list(CCPOST_INSTALLATION_COMMS_DEGRADED)

/datum/ccpost_sector_message_template/annex6_authorization_routing_delay
	template_id = "annex6_authorization_routing_delay"
	installation_code = CCPOST_INSTALLATION_CODE_ADM_06
	priority = CCPOST_PRIORITY_ADVISORY
	title = "Administrative Authentication Delays"
	body = "Intermittent authentication failures are delaying routine administrative correspondence. Priority records remain available through redundant channels, but Annex 6 is holding low-priority approvals locally rather than risk duplicate or partially acknowledged transactions."
	required_statuses = list(CCPOST_INSTALLATION_COMMS_DEGRADED)

/datum/ccpost_sector_message_template/sec8_patrol_craft_service
	template_id = "sec8_patrol_craft_service"
	installation_code = CCPOST_INSTALLATION_CODE_SEC_S08
	priority = CCPOST_PRIORITY_ADVISORY
	title = "Patrol Craft Maintenance Rotation"
	body = "One regional patrol craft has entered its scheduled maintenance rotation for propulsion checks, armor inspection, and secure-radio servicing. Coverage has been redistributed among the remaining patrols until the craft is cleared back into service."
	required_statuses = list(CCPOST_INSTALLATION_MAINTENANCE)

/datum/ccpost_sector_message_template/sec8_sensor_auth_delay
	template_id = "sec8_sensor_auth_delay"
	installation_code = CCPOST_INSTALLATION_CODE_SEC_S08
	priority = CCPOST_PRIORITY_ADVISORY
	title = "Regional Sensor Authentication Delay"
	body = "Several remote security sensors are reporting through delayed authentication handshakes. The feeds remain available, but S-8 is treating unverified updates as advisory until the communications path can complete credential checks normally."
	required_statuses = list(CCPOST_INSTALLATION_COMMS_DEGRADED)

/datum/ccpost_sector_message_template/sec8_detainee_transfer
	template_id = "sec8_detainee_transfer"
	installation_code = CCPOST_INSTALLATION_CODE_SEC_S08
	title = "Regional Detainee Transfer Coordination"
	body = "A low-risk detainee transfer between two regional facilities was completed without incident. Custody acknowledgements, transport logs, and destination intake records all match. S-8 has closed the movement from the active security board."
	required_statuses = list(CCPOST_INSTALLATION_ONLINE, CCPOST_INSTALLATION_ROUTINE)

/datum/ccpost_sector_message_template/a17_relay_repairs
	template_id = "a17_relay_repairs"
	installation_code = CCPOST_INSTALLATION_CODE_REL_A17
	message_type = CCPOST_MESSAGE_REQUEST
	priority = CCPOST_PRIORITY_PRIORITY
	title = "Relay Array Component Request"
	body = "We've lost redundancy across part of the long-range array. The remaining transmitters are carrying the traffic, but I am not comfortable leaving them there. I need replacement couplings and a clean transmitter module before one failure becomes several."
	required_statuses = list(CCPOST_INSTALLATION_MAINTENANCE, CCPOST_INSTALLATION_UNDER_REVIEW, CCPOST_INSTALLATION_COMMS_DEGRADED)
	allocation_cost = 5
	success_status = CCPOST_INSTALLATION_ONLINE
	success_details = "Replacement transmitter components have restored full long-range relay capability."
	reactive_aid = TRUE

/datum/ccpost_sector_message_template/a17_emergency_power
	template_id = "a17_emergency_power"
	installation_code = CCPOST_INSTALLATION_CODE_REL_A17
	message_type = CCPOST_MESSAGE_REQUEST
	priority = CCPOST_PRIORITY_PRIORITY
	title = "Emergency Relay Power Support"
	body = "This message was queued on the emergency burst channel before the primary link dropped. We are running the relay core from backup distribution and I cannot guarantee another restart. If you can release emergency power-control hardware, do it now."
	required_statuses = list(CCPOST_INSTALLATION_NO_CONTACT, CCPOST_INSTALLATION_OFFLINE)
	allocation_cost = 7
	success_status = CCPOST_INSTALLATION_MAINTENANCE
	success_details = "Emergency power-control hardware has restored limited relay operation while local repairs continue."
	reactive_aid = TRUE

/datum/ccpost_sector_message_template/a17_critical_stabilization
	template_id = "a17_critical_stabilization"
	installation_code = CCPOST_INSTALLATION_CODE_REL_A17
	message_type = CCPOST_MESSAGE_REQUEST
	priority = CCPOST_PRIORITY_IMPORTANT
	title = "Immediate Relay Stabilization Request"
	body = "Liaison, A-17 is in emergency operation. We are isolating damaged relay sections faster than we can bring backup systems online. I need authorization for emergency components and contractor routing before we lose the remaining trunk entirely."
	required_statuses = list(CCPOST_INSTALLATION_CRITICAL)
	allocation_cost = 10
	success_details = "Emergency relay resources have been committed to authenticated communications, emergency power, and isolation of damaged or compromised relay sections."
	reactive_aid = TRUE

/datum/ccpost_sector_message_template/kappa4_monitoring_repairs
	template_id = "kappa4_monitoring_repairs"
	installation_code = CCPOST_INSTALLATION_CODE_OUT_K04
	message_type = CCPOST_MESSAGE_REQUEST
	title = "Monitoring Equipment Replacement"
	body = "Our observation coverage is thinning out. Several packages are failing diagnostics and I am running the remaining units harder to compensate. We can continue like this, but every failed sensor leaves a larger blind spot. Requesting replacements."
	required_statuses = list(CCPOST_INSTALLATION_MAINTENANCE, CCPOST_INSTALLATION_UNDER_REVIEW, CCPOST_INSTALLATION_COMMS_DEGRADED)
	allocation_cost = 4
	success_status = CCPOST_INSTALLATION_ROUTINE
	success_details = "Replacement monitoring packages have restored normal observation capability."
	reactive_aid = TRUE

/datum/ccpost_sector_message_template/kappa4_life_support_backup
	template_id = "kappa4_life_support_backup"
	installation_code = CCPOST_INSTALLATION_CODE_OUT_K04
	message_type = CCPOST_MESSAGE_REQUEST
	priority = CCPOST_PRIORITY_PRIORITY
	title = "Outpost Continuity Support"
	body = "If this gets through, our main systems are already down or close to it. The outpost is operating from local emergency power and we have started shutting nonessential monitoring racks off to preserve life support. Requesting backup distribution and environmental-control parts."
	required_statuses = list(CCPOST_INSTALLATION_NO_CONTACT, CCPOST_INSTALLATION_OFFLINE)
	allocation_cost = 6
	success_status = CCPOST_INSTALLATION_MAINTENANCE
	success_details = "Emergency continuity supplies have restored basic outpost systems while repairs continue."
	reactive_aid = TRUE

/datum/ccpost_sector_message_template/kappa4_critical_continuity
	template_id = "kappa4_critical_continuity"
	installation_code = CCPOST_INSTALLATION_CODE_OUT_K04
	message_type = CCPOST_MESSAGE_REQUEST
	priority = CCPOST_PRIORITY_IMPORTANT
	title = "Critical Outpost Continuity Request"
	body = "We're past routine maintenance. I have staff consolidating into the protected section and stripping power from everything we can afford to lose. I need emergency continuity funding if Central still expects this outpost to remain occupied."
	required_statuses = list(CCPOST_INSTALLATION_CRITICAL)
	allocation_cost = 9
	success_details = "Emergency continuity resources have been committed to protected areas, life support, emergency power, and local command continuity."
	reactive_aid = TRUE

/datum/ccpost_sector_message_template/rc12_processing_repairs
	template_id = "rc12_processing_repairs"
	installation_code = CCPOST_INSTALLATION_CODE_MIN_RC12
	message_type = CCPOST_MESSAGE_REQUEST
	priority = CCPOST_PRIORITY_PRIORITY
	title = "Processing Equipment Assistance"
	body = "One primary processor is down and the secondary line is swallowing the entire shift's load. I can keep production moving, but not at this rate for long. Requesting replacement bearings, drive assemblies, and enough contractor time to fit them properly."
	required_statuses = list(CCPOST_INSTALLATION_MAINTENANCE, CCPOST_INSTALLATION_UNDER_REVIEW, CCPOST_INSTALLATION_COMMS_DEGRADED)
	allocation_cost = 7
	success_status = CCPOST_INSTALLATION_ROUTINE
	success_details = "Replacement processing assemblies have restored normal mineral-processing throughput."
	reactive_aid = TRUE

/datum/ccpost_sector_message_template/rc12_pressure_seals
	template_id = "rc12_pressure_seals"
	installation_code = CCPOST_INSTALLATION_CODE_MIN_RC12
	message_type = CCPOST_MESSAGE_REQUEST
	priority = CCPOST_PRIORITY_PRIORITY
	title = "Emergency Pressure-Seal Resupply"
	body = "This was sent through the platform's emergency queue. We have isolated two industrial sections after repeated seal failures and our local repair stock is almost gone. Send pressure hardware and patch material before I have to shut another processing deck."
	required_statuses = list(CCPOST_INSTALLATION_NO_CONTACT, CCPOST_INSTALLATION_OFFLINE)
	allocation_cost = 8
	success_status = CCPOST_INSTALLATION_MAINTENANCE
	success_details = "Emergency seal and patch supplies have restored limited platform operation."
	reactive_aid = TRUE

/datum/ccpost_sector_message_template/rc12_critical_stabilization
	template_id = "rc12_critical_stabilization"
	installation_code = CCPOST_INSTALLATION_CODE_MIN_RC12
	message_type = CCPOST_MESSAGE_REQUEST
	priority = CCPOST_PRIORITY_IMPORTANT
	title = "Critical Platform Stabilization"
	body = "RC-12 is in a full operational emergency. I have crews abandoning damaged machinery and focusing on atmosphere, structural isolation, and keeping people alive. Release emergency industrial support now and we may still have a platform to repair afterward."
	required_statuses = list(CCPOST_INSTALLATION_CRITICAL)
	allocation_cost = 11
	success_details = "Emergency industrial resources have been committed to life support, structural isolation, damage control, and essential platform systems."
	reactive_aid = TRUE

/datum/ccpost_sector_message_template/delta3_signal_repair
	template_id = "delta3_signal_repair"
	installation_code = CCPOST_INSTALLATION_CODE_LP_D03
	message_type = CCPOST_MESSAGE_REQUEST
	priority = CCPOST_PRIORITY_PRIORITY
	title = "Signal Monitoring Array Assistance"
	body = "Our secondary array keeps dropping synchronization. I can hold the primary watch, but every correction cycle narrows our usable coverage. Requesting a replacement processing rack before we become very good at listening to only one direction."
	required_statuses = list(CCPOST_INSTALLATION_MAINTENANCE, CCPOST_INSTALLATION_UNDER_REVIEW, CCPOST_INSTALLATION_COMMS_DEGRADED)
	allocation_cost = 4
	success_status = CCPOST_INSTALLATION_ONLINE
	success_details = "Replacement signal-processing hardware has restored full monitoring coverage."
	reactive_aid = TRUE

/datum/ccpost_sector_message_template/delta3_backup_power
	template_id = "delta3_backup_power"
	installation_code = CCPOST_INSTALLATION_CODE_LP_D03
	message_type = CCPOST_MESSAGE_REQUEST
	priority = CCPOST_PRIORITY_PRIORITY
	title = "Emergency Monitoring Power Request"
	body = "This is a buffered transmission from Delta-3. The primary monitoring bus has failed and the post is cycling receivers to stay within emergency power limits. We need power-conditioning hardware if you want continuous sector coverage restored."
	required_statuses = list(CCPOST_INSTALLATION_NO_CONTACT, CCPOST_INSTALLATION_OFFLINE)
	allocation_cost = 6
	success_status = CCPOST_INSTALLATION_MAINTENANCE
	success_details = "Emergency power-conditioning hardware has restored limited monitoring capability."
	reactive_aid = TRUE

/datum/ccpost_sector_message_template/delta3_critical_stabilization
	template_id = "delta3_critical_stabilization"
	installation_code = CCPOST_INSTALLATION_CODE_LP_D03
	message_type = CCPOST_MESSAGE_REQUEST
	priority = CCPOST_PRIORITY_IMPORTANT
	title = "Critical Listening Post Support"
	body = "We are losing systems faster than I can isolate them. Most of the array is dark and the remaining equipment is running from emergency feeds. I need immediate stabilization resources or Delta-3 is going to stop being a listening post and start being debris."
	required_statuses = list(CCPOST_INSTALLATION_CRITICAL)
	allocation_cost = 10
	success_details = "Emergency listening-post resources have been committed to protected systems, emergency power, secure communications, and local containment efforts."
	reactive_aid = TRUE

/datum/ccpost_sector_message_template/annex6_records_repair
	template_id = "annex6_records_repair"
	installation_code = CCPOST_INSTALLATION_CODE_ADM_06
	message_type = CCPOST_MESSAGE_REQUEST
	title = "Records Infrastructure Assistance"
	body = "The Annex is processing a growing backlog after another archival server failure. The records are intact, but the remaining systems are well beyond comfortable load. I need replacement storage hardware before the backlog becomes a compliance incident of its own."
	required_statuses = list(CCPOST_INSTALLATION_UNDER_REVIEW, CCPOST_INSTALLATION_MAINTENANCE, CCPOST_INSTALLATION_COMMS_DEGRADED)
	allocation_cost = 3
	success_status = CCPOST_INSTALLATION_ROUTINE
	success_details = "Supplemental archival hardware has restored normal regional records processing."
	reactive_aid = TRUE

/datum/ccpost_sector_message_template/annex6_cooling_support
	template_id = "annex6_cooling_support"
	installation_code = CCPOST_INSTALLATION_CODE_ADM_06
	message_type = CCPOST_MESSAGE_REQUEST
	priority = CCPOST_PRIORITY_PRIORITY
	title = "Emergency Archive Cooling Support"
	body = "This message is coming through the Annex emergency transmitter. Environmental control in the primary records room is offline and we are moving active media by hand into the secondary vault. Requesting portable cooling and power-control hardware immediately."
	required_statuses = list(CCPOST_INSTALLATION_NO_CONTACT, CCPOST_INSTALLATION_OFFLINE)
	allocation_cost = 5
	success_status = CCPOST_INSTALLATION_MAINTENANCE
	success_details = "Emergency environmental-control equipment has stabilized the Annex records environment."
	reactive_aid = TRUE

/datum/ccpost_sector_message_template/annex6_critical_preservation
	template_id = "annex6_critical_preservation"
	installation_code = CCPOST_INSTALLATION_CODE_ADM_06
	message_type = CCPOST_MESSAGE_REQUEST
	priority = CCPOST_PRIORITY_IMPORTANT
	title = "Critical Records Preservation Request"
	body = "I am authorizing manual continuity procedures. Staff are evacuating priority archives from damaged storage areas and we are running the secondary vault independently. If Central wants the regional record set preserved, I need emergency preservation resources now."
	required_statuses = list(CCPOST_INSTALLATION_CRITICAL)
	allocation_cost = 8
	success_details = "Emergency preservation resources have been committed to priority archives, personnel-control continuity, protected storage, and local containment efforts."
	reactive_aid = TRUE

/datum/ccpost_sector_message_template/h09_freight_repairs
	template_id = "h09_freight_repairs"
	installation_code = CCPOST_INSTALLATION_CODE_LOG_H09
	message_type = CCPOST_MESSAGE_REQUEST
	priority = CCPOST_PRIORITY_PRIORITY
	title = "Freight Routing Repair Assistance"
	body = "A routing controller has failed and the remaining unit is carrying the full automated handoff load. We are keeping traffic moving, but I am not going to pretend this is sustainable. Requesting replacement hardware before the surviving controller joins it."
	required_statuses = list(CCPOST_INSTALLATION_MAINTENANCE, CCPOST_INSTALLATION_UNDER_REVIEW, CCPOST_INSTALLATION_COMMS_DEGRADED)
	allocation_cost = 6
	success_status = CCPOST_INSTALLATION_ROUTINE
	success_details = "Supplemental Central Command resources have restored primary freight-routing capability."
	reactive_aid = TRUE

/datum/ccpost_sector_message_template/h09_emergency_routing
	template_id = "h09_emergency_routing"
	installation_code = CCPOST_INSTALLATION_CODE_LOG_H09
	message_type = CCPOST_MESSAGE_REQUEST
	priority = CCPOST_PRIORITY_PRIORITY
	title = "Emergency Freight Control Support"
	body = "If you are reading this, H-9's normal telemetry is already gone. We have dropped to local freight control and manual lane assignment. I need emergency routing hardware and power distribution before the queue becomes impossible to recover."
	required_statuses = list(CCPOST_INSTALLATION_NO_CONTACT, CCPOST_INSTALLATION_OFFLINE)
	allocation_cost = 8
	success_status = CCPOST_INSTALLATION_MAINTENANCE
	success_details = "Emergency freight-control hardware has restored limited routing capability."
	reactive_aid = TRUE

/datum/ccpost_sector_message_template/h09_critical_stabilization
	template_id = "h09_critical_stabilization"
	installation_code = CCPOST_INSTALLATION_CODE_LOG_H09
	message_type = CCPOST_MESSAGE_REQUEST
	priority = CCPOST_PRIORITY_IMPORTANT
	title = "Critical Logistics Stabilization"
	body = "We are in a sector logistics emergency. Automated routing is collapsing, local power is unstable, and I am assigning freight by hand where I still have a live console. Release emergency support now or H-9 is going to stop moving anything at all."
	required_statuses = list(CCPOST_INSTALLATION_CRITICAL)
	allocation_cost = 12
	success_details = "Emergency logistics resources have been committed to manual routing, emergency power, secured freight, and local damage-control operations."
	reactive_aid = TRUE

/datum/ccpost_sector_message_template/med12_storage_repair
	template_id = "med12_storage_repair"
	installation_code = CCPOST_INSTALLATION_CODE_MED_M12
	message_type = CCPOST_MESSAGE_REQUEST
	priority = CCPOST_PRIORITY_PRIORITY
	title = "Medical Storage Recovery Assistance"
	body = "We have isolated one distribution vault after repeated cooling and inventory-control faults. Verified stock is safe, but our redundancy is disappearing quickly. Requesting replacement refrigeration controls, validation sensors, and contractor time before another vault has to come offline."
	required_statuses = list(CCPOST_INSTALLATION_MAINTENANCE, CCPOST_INSTALLATION_UNDER_REVIEW, CCPOST_INSTALLATION_COMMS_DEGRADED)
	allocation_cost = 5
	success_status = CCPOST_INSTALLATION_ROUTINE
	success_details = "Replacement medical-storage controls have restored validated regional distribution capacity."
	reactive_aid = TRUE

/datum/ccpost_sector_message_template/med12_emergency_coldchain
	template_id = "med12_emergency_coldchain"
	installation_code = CCPOST_INSTALLATION_CODE_MED_M12
	message_type = CCPOST_MESSAGE_REQUEST
	priority = CCPOST_PRIORITY_PRIORITY
	title = "Emergency Cold-Chain Support"
	body = "This is an emergency distribution message from M-12. Primary cold storage is unavailable and staff are moving verified stock into portable units by hand. I need emergency refrigeration and power-conditioning support before we start losing supplies that cannot be replaced locally."
	required_statuses = list(CCPOST_INSTALLATION_NO_CONTACT, CCPOST_INSTALLATION_OFFLINE)
	allocation_cost = 7
	success_status = CCPOST_INSTALLATION_MAINTENANCE
	success_details = "Emergency cold-chain equipment has restored limited medical distribution capability."
	reactive_aid = TRUE

/datum/ccpost_sector_message_template/med12_critical_stabilization
	template_id = "med12_critical_stabilization"
	installation_code = CCPOST_INSTALLATION_CODE_MED_M12
	message_type = CCPOST_MESSAGE_REQUEST
	priority = CCPOST_PRIORITY_IMPORTANT
	title = "Critical Medical Distribution Stabilization"
	body = "M-12 is in a full operational emergency. We are consolidating viable stock, abandoning damaged storage areas, and running essential refrigeration from emergency feeds. Release stabilization resources now or this sector loses a major part of its medical supply chain."
	required_statuses = list(CCPOST_INSTALLATION_CRITICAL)
	allocation_cost = 10
	success_details = "Emergency medical-logistics resources have been committed to essential refrigeration, verified stock, protected treatment areas, and local containment efforts."
	reactive_aid = TRUE


/datum/ccpost_sector_message_template/sec8_security_system_repair
	template_id = "sec8_security_system_repair"
	installation_code = CCPOST_INSTALLATION_CODE_SEC_S08
	message_type = CCPOST_MESSAGE_REQUEST
	priority = CCPOST_PRIORITY_PRIORITY
	title = "Regional Security Systems Assistance"
	body = "Our access-control and patrol coordination systems are operating with reduced redundancy after multiple hardware failures. Local Security is maintaining coverage manually, but every additional fault increases the number of systems depending on the same remaining controllers. Requesting replacement security hardware and technical support."
	required_statuses = list(CCPOST_INSTALLATION_MAINTENANCE, CCPOST_INSTALLATION_UNDER_REVIEW, CCPOST_INSTALLATION_COMMS_DEGRADED)
	allocation_cost = 5
	success_status = CCPOST_INSTALLATION_ROUTINE
	success_details = "Replacement access-control and patrol coordination hardware has restored normal regional security operations."
	reactive_aid = TRUE

/datum/ccpost_sector_message_template/sec8_emergency_lockdown
	template_id = "sec8_emergency_lockdown"
	installation_code = CCPOST_INSTALLATION_CODE_SEC_S08
	message_type = CCPOST_MESSAGE_REQUEST
	priority = CCPOST_PRIORITY_PRIORITY
	title = "Emergency Security Continuity Request"
	body = "This transmission was queued before normal communications failed. S-8 is operating under local lockdown with patrol coordination and access control on emergency systems. We need protected communications, power-control hardware, and medical reserves if the outpost is expected to maintain regional security coverage."
	required_statuses = list(CCPOST_INSTALLATION_NO_CONTACT, CCPOST_INSTALLATION_OFFLINE)
	allocation_cost = 7
	success_status = CCPOST_INSTALLATION_MAINTENANCE
	success_details = "Emergency security-continuity equipment has restored limited access control, communications, and patrol coordination."
	reactive_aid = TRUE

/datum/ccpost_sector_message_template/sec8_critical_continuity
	template_id = "sec8_critical_continuity"
	installation_code = CCPOST_INSTALLATION_CODE_SEC_S08
	message_type = CCPOST_MESSAGE_REQUEST
	priority = CCPOST_PRIORITY_IMPORTANT
	title = "Critical Sector Security Support"
	body = "S-8 is in a full security emergency. Verified personnel are consolidating into secured sections while we isolate compromised systems and keep the regional threat network alive. I need immediate continuity, medical, communications, and access-control support if this outpost is going to remain operational."
	required_statuses = list(CCPOST_INSTALLATION_CRITICAL)
	allocation_cost = 10
	success_details = "Emergency security resources have been committed to protected communications, verified access control, casualty support, and regional command continuity."
	reactive_aid = TRUE

// Critical incident definitions

/datum/ccpost_critical_incident
	var/description
	var/installation_code
	var/recovery_status = CCPOST_INSTALLATION_UNDER_REVIEW
	var/recovery_details
	var/request_text
	var/aid_details

/datum/ccpost_critical_incident/primary_power_failure
	description = "a cascading primary power failure"
	recovery_status = CCPOST_INSTALLATION_MAINTENANCE
	recovery_details = "Emergency generation and distribution have restored essential power. Damaged primary systems remain isolated while engineering repairs continue."
	request_text = "Primary distribution is cascading out across the installation. We are shedding nonessential loads and moving occupied sections onto emergency feeds, but the remaining buses are failing faster than we can isolate them. We need emergency power-control hardware and replacement distribution components now."
	aid_details = "Emergency power-control hardware, replacement distribution components, and technical support have been committed to keep essential systems energized while local crews isolate the cascade."

/datum/ccpost_critical_incident/atmospheric_containment_failure
	description = "a major atmospheric containment failure"
	recovery_status = CCPOST_INSTALLATION_MAINTENANCE
	recovery_details = "Atmospheric containment has been restored around occupied sections. Damaged compartments remain sealed while environmental repairs continue."
	request_text = "We have lost atmospheric containment across multiple sections and are sealing compartments as fast as pressure allows. Personnel are being moved into the remaining safe areas, but our emergency seals and environmental reserves are running down. We need containment hardware and life-support support immediately."
	aid_details = "Emergency containment hardware, environmental-control equipment, and life-support resources have been committed to preserve occupied sections and reinforce failing atmospheric boundaries."

/datum/ccpost_critical_incident/structural_integrity_failure
	description = "multiple structural integrity failures"
	recovery_status = CCPOST_INSTALLATION_MAINTENANCE
	recovery_details = "Further structural collapse has been arrested and unsafe sections have been isolated. Engineering recovery operations remain underway."
	request_text = "Structural alarms are propagating through multiple sections and we have already abandoned areas we cannot safely brace. Crews are trying to stop a local failure from becoming a full collapse. We need emergency structural material, remote handling equipment, and engineering support now."
	aid_details = "Emergency structural materials, bracing equipment, and engineering support have been committed to arrest further collapse and preserve safe access routes."

/datum/ccpost_critical_incident/external_impact_damage
	description = "unidentified external impacts causing severe structural damage"
	recovery_status = CCPOST_INSTALLATION_MAINTENANCE
	recovery_details = "Damage-control teams have stabilized the affected structure. Impact-damaged sections remain restricted pending repair and investigation."
	request_text = "We have taken repeated external impacts and several sections are no longer structurally trustworthy. Damage-control teams are sealing breaches and evacuating exposed compartments, but we do not know whether the impacts are finished. We need emergency structural and casualty-support resources immediately."
	aid_details = "Emergency structural repair material, damage-control equipment, and casualty-support resources have been committed while personnel stabilize the impact-damaged sections."

/datum/ccpost_critical_incident/internal_systems_failure
	description = "a widespread internal systems failure"
	recovery_status = CCPOST_INSTALLATION_MAINTENANCE
	recovery_details = "Essential control systems have been restored at reduced capacity. Failed subsystems remain under repair."
	request_text = "Control systems are failing across unrelated departments and local resets are no longer holding. We are running essential functions manually where we still can, but every new failure is narrowing what the installation can keep alive. We need replacement control hardware and emergency technical support now."
	aid_details = "Replacement control hardware, emergency technical support, and continuity resources have been committed to keep essential services operating while failed subsystems are isolated."

/datum/ccpost_critical_incident/stationwide_security_emergency
	description = "an unresolved station-wide security emergency"
	recovery_status = CCPOST_INSTALLATION_UNDER_REVIEW
	recovery_details = "Local control has been restored and the immediate security emergency has been contained. Central Security review and personnel accounting remain underway."
	request_text = "We have an active security emergency across the installation and local control is breaking down in multiple areas. Personnel are consolidating behind secured access points while Security tries to regain control. We need emergency medical, communications, and continuity resources immediately."
	aid_details = "Emergency medical, communications, access-control, and continuity resources have been committed to support local containment and preserve secured operating areas."

/datum/ccpost_critical_incident/life_support_failure
	description = "a cascading life-support systems failure"
	recovery_status = CCPOST_INSTALLATION_MAINTENANCE
	recovery_details = "Essential life-support services have been restored. Damaged environmental systems remain under emergency operating restrictions."
	request_text = "Life-support failures are spreading faster than our technicians can stabilize them. We are shutting down nonessential sections and concentrating personnel where atmosphere and temperature are still controllable. We need emergency environmental-control and power resources before the remaining safe areas become untenable."
	aid_details = "Emergency environmental-control, power, and life-support resources have been committed to preserve the remaining habitable sections while damaged systems are isolated."

/datum/ccpost_critical_incident/syndicate_infrastructure_sabotage
	description = "coordinated Syndicate sabotage affecting primary installation infrastructure"
	recovery_status = CCPOST_INSTALLATION_UNDER_REVIEW
	recovery_details = "Sabotaged systems have been isolated and essential operations restored. A Central Security investigation into the hostile action remains active."
	request_text = "We have confirmed coordinated sabotage across primary infrastructure and cannot assume the remaining failures are accidental. Critical systems are being isolated while verified personnel work under restricted access. We need emergency repair, security, and continuity resources now before the sabotage takes the installation with it."
	aid_details = "Emergency repair, access-control, and continuity resources have been committed to isolate sabotaged systems and keep verified personnel in control of essential infrastructure."

/datum/ccpost_critical_incident/rel_a17_relay_array_failure
	description = "catastrophic failure across the long-range relay array"
	installation_code = CCPOST_INSTALLATION_CODE_REL_A17
	recovery_status = CCPOST_INSTALLATION_MAINTENANCE
	recovery_details = "Emergency relay repairs have restored limited long-range capability. Damaged array sections remain isolated pending full repair."
	request_text = "The long-range array is collapsing section by section. We have already isolated damaged emitters and the remaining trunk is carrying traffic without meaningful redundancy. I need emergency relay components and contractor routing now, before the last stable path fails with everything still on it."
	aid_details = "Emergency relay components, power-control hardware, and contractor support have been committed to preserve the remaining trunk and isolate failing array sections."

/datum/ccpost_critical_incident/rel_a17_syndicate_signal_intrusion
	description = "a hostile Syndicate signal intrusion overriding authenticated relay traffic"
	installation_code = CCPOST_INSTALLATION_CODE_REL_A17
	recovery_status = CCPOST_INSTALLATION_UNDER_REVIEW
	recovery_details = "Compromised relay channels have been isolated and authenticated traffic restored through secured routing. Security specialists continue tracing the hostile intrusion."
	request_text = "Our authenticated traffic is being overwritten by a hostile Syndicate signal and we can no longer trust every route leaving this station. We are cutting compromised channels and forcing verified traffic through isolated hardware, but the clean paths are disappearing. I need secure routing equipment and emergency processing support immediately."
	aid_details = "Secure routing hardware, authentication support, and replacement processing equipment have been committed to isolate compromised channels and preserve verified relay traffic."

/datum/ccpost_critical_incident/rel_a17_changeling_identity_conflict
	description = "suspected changeling infiltration following conflicting operator voiceprints and access records"
	installation_code = CCPOST_INSTALLATION_CODE_REL_A17
	recovery_status = CCPOST_INSTALLATION_UNDER_REVIEW
	recovery_details = "Conflicting operator identities have been isolated from privileged access and verified personnel have resumed essential relay operations. Identity review remains active."
	request_text = "We have conflicting operator voiceprints, contradictory access records, and personnel we cannot reliably identify. Privileged relay controls are being locked down to the few identities we can verify, but that is leaving critical systems understaffed. I need continuity resources, secure authentication support, and emergency staffing capacity now."
	aid_details = "Secure authentication, continuity, and emergency operating resources have been committed so verified personnel can maintain essential relay control while identity checks continue."

/datum/ccpost_critical_incident/rel_a17_hostile_boarding_blackout
	description = "a coordinated communications blackout preceding suspected hostile boarding activity"
	installation_code = CCPOST_INSTALLATION_CODE_REL_A17
	recovery_status = CCPOST_INSTALLATION_UNDER_REVIEW
	recovery_details = "Limited communications have been restored and the immediate boarding threat has been contained. Security sweeps and access review remain underway."
	request_text = "The blackout was not random. We lost external communications immediately before suspected hostile boarding activity and several internal routes are now contested or silent. We are holding the relay core and restoring one secure path at a time. I need emergency communications, access-control, and casualty-support resources now."
	aid_details = "Emergency communications, access-control, and casualty-support resources have been committed to preserve the relay core and support local containment of the suspected boarding action."

/datum/ccpost_critical_incident/rel_a17_thaumaturgic_interference
	description = "severe thaumaturgic interference consistent with Wizard Federation manipulation of the relay network"
	installation_code = CCPOST_INSTALLATION_CODE_REL_A17
	recovery_status = CCPOST_INSTALLATION_COMMS_DEGRADED
	recovery_details = "Affected relay segments have been isolated and stable traffic restored through alternate channels. Thaumaturgic interference persists at reduced intensity."
	request_text = "The relay network is being hit by interference that does not behave like any conventional fault. Channels are distorting, rerouting themselves, and dropping synchronization faster than we can isolate them. I need redundant processing, protected power, and replacement relay hardware before the interference takes the remaining stable paths."
	aid_details = "Redundant processing, protected power, and replacement relay hardware have been committed to isolate affected segments and preserve stable communications during the thaumaturgic interference."

/datum/ccpost_critical_incident/rel_a17_wizard_signal_anomaly
	description = "an unauthorized Wizard Federation transmission forcing repeated spatial and signal anomalies through the primary array"
	installation_code = CCPOST_INSTALLATION_CODE_REL_A17
	recovery_status = CCPOST_INSTALLATION_COMMS_DEGRADED
	recovery_details = "Primary anomalous signal paths have been isolated and normal traffic rerouted. Residual spatial and signal anomalies remain under observation."
	request_text = "An unauthorized Wizard transmission is driving spatial and signal anomalies through the primary array. Hardware is reporting from impossible locations and traffic is appearing on paths we physically disconnected. We are isolating the primary sections, but I need redundant relay equipment and emergency power support before the anomaly spreads through the remaining network."
	aid_details = "Redundant relay hardware, emergency power support, and isolated processing resources have been committed to preserve alternate traffic paths while anomalous primary-array sections are contained."

/datum/ccpost_critical_incident/out_k04_revolutionary_takeover
	description = "armed revolutionary activity resulting in loss of local administrative control"
	installation_code = CCPOST_INSTALLATION_CODE_OUT_K04
	recovery_status = CCPOST_INSTALLATION_UNDER_REVIEW
	recovery_details = "Verified Nanotrasen personnel have regained control of critical administrative and life-support areas. Remaining revolutionary activity is being contained and the outpost is under security review."
	request_text = "Armed revolutionaries have taken administrative spaces and we have lost local control of several access and monitoring systems. Verified personnel are consolidating in the protected section and shutting hostile users out wherever we still can. We need emergency continuity, medical, and secure-control resources now or we may lose the outpost entirely."
	aid_details = "Emergency continuity, medical, and secure-control resources have been committed to support verified personnel holding protected sections and restoring local administrative control."

/datum/ccpost_critical_incident/out_k04_changeling_command_infiltration
	description = "suspected changeling infiltration compromising the outpost command roster"
	installation_code = CCPOST_INSTALLATION_CODE_OUT_K04
	recovery_status = CCPOST_INSTALLATION_UNDER_REVIEW
	recovery_details = "Verified personnel have re-established local command access and suspected compromised staff have been isolated. Identity verification remains underway."
	request_text = "We cannot trust the command roster. Biometric records and personnel identities are conflicting, and at least one privileged account may belong to someone who is not who they claim to be. Verified staff are restricting access and operating from a reduced chain of command. We need secure authentication and continuity resources immediately."
	aid_details = "Secure authentication, access-control, and continuity resources have been committed so verified personnel can maintain the outpost while suspected compromised staff are isolated."

/datum/ccpost_critical_incident/out_k04_cultist_activity
	description = "violent cultist activity compromising monitoring and security spaces"
	installation_code = CCPOST_INSTALLATION_CODE_OUT_K04
	recovery_status = CCPOST_INSTALLATION_UNDER_REVIEW
	recovery_details = "Immediate cultist activity has been contained and compromised monitoring and security spaces have been secured. Central Security review continues."
	request_text = "Cultist activity has breached monitoring and Security spaces and we are losing reliable coverage of occupied sections. Surviving personnel are abandoning compromised rooms and trying to hold the protected administrative core. We need emergency medical, security, and continuity resources now."
	aid_details = "Emergency medical, access-control, and continuity resources have been committed to reinforce protected areas and support containment of the cultist activity."

/datum/ccpost_critical_incident/out_k04_heretic_anomaly
	description = "a heretic-related anomaly spreading through occupied administrative areas"
	installation_code = CCPOST_INSTALLATION_CODE_OUT_K04
	recovery_status = CCPOST_INSTALLATION_UNDER_REVIEW
	recovery_details = "The affected administrative areas have been isolated and the immediate anomalous threat contained. Specialist review remains in progress."
	request_text = "An anomalous event linked to suspected heretic activity is spreading through occupied administrative areas. We are evacuating personnel and sealing sections as soon as the anomaly reaches them, but we are running out of uncontaminated space and equipment. We need emergency isolation and continuity resources immediately."
	aid_details = "Emergency isolation, continuity, and protected-power resources have been committed to keep occupied sections functional while the anomalous areas are contained."

/datum/ccpost_critical_incident/out_k04_syndicate_infiltrator
	description = "a hostile infiltrator incident involving Syndicate equipment and multiple casualties"
	installation_code = CCPOST_INSTALLATION_CODE_OUT_K04
	recovery_status = CCPOST_INSTALLATION_UNDER_REVIEW
	recovery_details = "Local security has restored control of critical areas. Casualty treatment, evidence recovery, and hostile-infiltration review remain underway."
	request_text = "We have a hostile infiltrator using Syndicate equipment inside the outpost and multiple personnel are already down. Local Security is trying to hold the remaining controlled spaces while Medical works from improvised positions. We need emergency medical, access-control, and continuity resources now."
	aid_details = "Emergency medical, access-control, and continuity resources have been committed to support surviving personnel and reinforce local containment of the hostile infiltrator."

/datum/ccpost_critical_incident/out_k04_wizard_teleportation
	description = "an unauthorized Wizard Federation teleportation event depositing hostile arcane phenomena inside the outpost"
	installation_code = CCPOST_INSTALLATION_CODE_OUT_K04
	recovery_status = CCPOST_INSTALLATION_UNDER_REVIEW
	recovery_details = "Hostile arcane phenomena have been contained or isolated from occupied sections. Affected areas remain restricted pending specialist assessment."
	request_text = "A Wizard Federation teleportation event has deposited hostile arcane phenomena inside occupied sections. Personnel and equipment are being displaced and we cannot guarantee that a secured room will remain secured. We need emergency isolation, redundant systems, and protected power immediately."
	aid_details = "Emergency isolation equipment, redundant systems, and protected-power resources have been committed to preserve safe operating areas while hostile arcane phenomena are contained."

/datum/ccpost_critical_incident/min_rc12_industrial_accident
	description = "an uncontrolled industrial accident causing cascading processing-line failures"
	installation_code = CCPOST_INSTALLATION_CODE_MIN_RC12
	recovery_status = CCPOST_INSTALLATION_MAINTENANCE
	recovery_details = "Damaged processing lines have been isolated and essential platform services stabilized. Industrial repair operations remain underway."
	request_text = "The processing lines are failing in sequence and we have crews abandoning machinery just to stay ahead of the cascade. Atmosphere, power, and structural isolation are now taking priority over production. We need emergency industrial repair material and life-support support now or there may not be a platform left to restart."
	aid_details = "Emergency industrial repair material, structural support, and life-support resources have been committed to isolate failed processing lines and preserve occupied platform sections."

/datum/ccpost_critical_incident/min_rc12_syndicate_sabotage
	description = "coordinated Syndicate sabotage affecting excavation and ore-processing infrastructure"
	installation_code = CCPOST_INSTALLATION_CODE_MIN_RC12
	recovery_status = CCPOST_INSTALLATION_UNDER_REVIEW
	recovery_details = "Sabotaged excavation and processing systems have been isolated and local control restored. Repairs and a security investigation remain active."
	request_text = "We have confirmed coordinated Syndicate sabotage across excavation and processing infrastructure. Controls we thought were safe are failing under load, and verified crews are working around systems we can no longer trust. We need emergency repair, security, and isolation resources immediately."
	aid_details = "Emergency repair, access-control, and isolation resources have been committed to preserve verified industrial controls and contain sabotaged infrastructure."

/datum/ccpost_critical_incident/min_rc12_revolutionary_control_seizure
	description = "violent revolutionary activity resulting in seizure of primary industrial controls"
	installation_code = CCPOST_INSTALLATION_CODE_MIN_RC12
	recovery_status = CCPOST_INSTALLATION_UNDER_REVIEW
	recovery_details = "Primary industrial controls have been retaken or isolated from hostile personnel. Production remains restricted while security review continues."
	request_text = "Revolutionary personnel have seized primary industrial controls and several processing areas are no longer answering to verified supervisors. Loyal crews are isolating power and trying to prevent hostile control from reaching life-support and pressure systems. We need emergency continuity and secure-control resources now."
	aid_details = "Emergency continuity, secure-control, and industrial isolation resources have been committed to help verified crews deny hostile access to essential platform systems."

/datum/ccpost_critical_incident/min_rc12_cult_or_heretic_activity
	description = "cultist or heretic activity discovered within active excavation sectors"
	installation_code = CCPOST_INSTALLATION_CODE_MIN_RC12
	recovery_status = CCPOST_INSTALLATION_UNDER_REVIEW
	recovery_details = "Affected excavation sectors have been sealed and the immediate hostile activity contained. Specialist investigation remains underway."
	request_text = "Hostile cultist or heretic activity has been confirmed inside active excavation sectors. We are sealing shafts and pulling crews back, but some personnel are still unaccounted for and industrial systems remain exposed. We need emergency medical, isolation, and continuity resources immediately."
	aid_details = "Emergency medical, isolation, and continuity resources have been committed to support evacuated crews and secure affected excavation sectors."

/datum/ccpost_critical_incident/min_rc12_bloodsucker_attack
	description = "a suspected bloodsucker attack producing multiple exsanguinated casualties in maintenance tunnels"
	installation_code = CCPOST_INSTALLATION_CODE_MIN_RC12
	recovery_status = CCPOST_INSTALLATION_UNDER_REVIEW
	recovery_details = "Maintenance sectors have been secured and surviving personnel consolidated into controlled areas. Casualty and security review continue."
	request_text = "We have multiple exsanguinated casualties in the maintenance tunnels and a suspected bloodsucker is still unaccounted for. Crews are abandoning isolated passages and consolidating around lit, controlled areas. We need emergency medical, security, and portable power resources now."
	aid_details = "Emergency medical, portable-power, access-control, and security-support resources have been committed to reinforce controlled areas and treat surviving personnel."

/datum/ccpost_critical_incident/min_rc12_arcane_mineral_transmutation
	description = "large-scale arcane transmutation associated with suspected Wizard Federation activity destabilizing stored mineral stock"
	installation_code = CCPOST_INSTALLATION_CODE_MIN_RC12
	recovery_status = CCPOST_INSTALLATION_MAINTENANCE
	recovery_details = "Unstable mineral stock has been isolated and affected processing lines shut down. Controlled industrial recovery remains underway."
	request_text = "Stored mineral stock is undergoing large-scale transmutation and we cannot predict which material is stable enough to move. Processing lines are being shut down around affected storage, but the unstable stock is threatening nearby infrastructure. We need emergency containment, handling, and industrial support immediately."
	aid_details = "Emergency containment, remote-handling, and industrial support resources have been committed to isolate unstable mineral stock and protect nearby platform systems."

/datum/ccpost_critical_incident/lp_d03_nuclear_operatives
	description = "a confirmed nuclear operative incursion against the listening post"
	installation_code = CCPOST_INSTALLATION_CODE_LP_D03
	recovery_status = CCPOST_INSTALLATION_UNDER_REVIEW
	recovery_details = "The hostile nuclear operative incursion has been repelled or contained and surviving personnel have regained local control. Classified systems remain locked down during security sweeps and damage assessment."
	request_text = "Liaison, this is Delta-3. We have confirmed nuclear operatives inside the post. Several secure sections are already lost and surviving personnel are consolidating around the monitoring core while classified systems are locked down. We need emergency medical, secure-power, and communications support immediately. If we lose this position, there may not be another transmission."
	aid_details = "Emergency medical, secure-power, communications, and continuity resources have been committed to help surviving personnel hold the monitoring core and protect classified systems during the nuclear operative incursion."

/datum/ccpost_critical_incident/lp_d03_syndicate_boarding
	description = "a hostile Syndicate boarding action following interception of classified burst traffic"
	installation_code = CCPOST_INSTALLATION_CODE_LP_D03
	recovery_status = CCPOST_INSTALLATION_UNDER_REVIEW
	recovery_details = "The boarding action has been repelled or contained and classified systems remain secured. Security sweeps and intelligence review continue."
	request_text = "We intercepted classified hostile traffic and were boarded almost immediately afterward. Multiple access points are compromised and surviving personnel are falling back around the secure monitoring core. We need emergency medical, access-control, and protected communications support now."
	aid_details = "Emergency medical, access-control, and protected communications resources have been committed to reinforce the secure core and support containment of the Syndicate boarding action."

/datum/ccpost_critical_incident/lp_d03_monitoring_blackout
	description = "a total monitoring blackout coinciding with unidentified encrypted transmissions"
	installation_code = CCPOST_INSTALLATION_CODE_LP_D03
	recovery_status = CCPOST_INSTALLATION_COMMS_DEGRADED
	recovery_details = "Emergency monitoring has been restored through isolated systems. The origin of the encrypted traffic remains unresolved and full coverage is not yet available."
	request_text = "Our monitoring array went completely dark while unidentified encrypted transmissions appeared across emergency channels. We are bringing receivers back one isolated rack at a time, but we cannot tell what happened outside our remaining local sensors. We need emergency processing, power-conditioning, and secure communications support now."
	aid_details = "Emergency processing, power-conditioning, and secure communications resources have been committed to restore isolated monitoring coverage and investigate the encrypted traffic."

/datum/ccpost_critical_incident/lp_d03_heretic_signal_anomaly
	description = "a heretic-related signal anomaly producing persistent nonstandard sensor returns"
	installation_code = CCPOST_INSTALLATION_CODE_LP_D03
	recovery_status = CCPOST_INSTALLATION_COMMS_DEGRADED
	recovery_details = "The affected monitoring array has been isolated and limited coverage restored. Persistent anomalous sensor returns remain under investigation."
	request_text = "We have persistent sensor returns that do not match any physical contact and the anomaly is spreading across monitoring channels. Operators are isolating affected racks, but we are losing sector coverage with every system we disconnect. We need redundant processing and protected monitoring hardware immediately."
	aid_details = "Redundant processing, protected monitoring hardware, and isolated power resources have been committed to preserve usable coverage while anomalous sensor channels are contained."

/datum/ccpost_critical_incident/lp_d03_changeling_infiltration
	description = "suspected changeling infiltration following conflicting watch-officer biometric records"
	installation_code = CCPOST_INSTALLATION_CODE_LP_D03
	recovery_status = CCPOST_INSTALLATION_UNDER_REVIEW
	recovery_details = "Verified personnel have regained control of the listening post and biometric revalidation is underway. Classified access remains restricted."
	request_text = "Watch-officer biometrics are conflicting and we can no longer trust every person with access to classified monitoring systems. Verified personnel are locking down credentials and operating with a reduced watch team. We need secure authentication, medical, and continuity resources now."
	aid_details = "Secure authentication, medical, and continuity resources have been committed so verified personnel can maintain classified monitoring while suspected compromised staff are isolated."

/datum/ccpost_critical_incident/lp_d03_wizard_sensor_distortion
	description = "a Wizard Federation transmission event causing repeated impossible sensor contacts and localized spatial distortion"
	installation_code = CCPOST_INSTALLATION_CODE_LP_D03
	recovery_status = CCPOST_INSTALLATION_COMMS_DEGRADED
	recovery_details = "Affected monitoring systems have been isolated and partial coverage restored. Residual spatial and signal distortion remains under observation."
	request_text = "A Wizard Federation transmission is producing impossible sensor contacts and localized spatial distortion throughout the post. Equipment is reporting movement where nothing exists and some compartments are no longer spatially consistent. We need redundant monitoring, protected power, and emergency isolation resources immediately."
	aid_details = "Redundant monitoring hardware, protected power, and emergency isolation resources have been committed to preserve a stable watch capability while spatial and signal anomalies are contained."

/datum/ccpost_critical_incident/adm_06_revolutionary_records_seizure
	description = "armed revolutionary activity resulting in seizure of records and personnel-control systems"
	installation_code = CCPOST_INSTALLATION_CODE_ADM_06
	recovery_status = CCPOST_INSTALLATION_UNDER_REVIEW
	recovery_details = "Verified Nanotrasen personnel have regained access to priority archives and personnel-control systems. Remaining revolutionary activity is being contained and the Annex is under security review."
	request_text = "Liaison, armed personnel have seized part of the Annex and we have lost access to several records and personnel-control systems. Loyal staff are evacuating priority archives and sealing the sections we still hold. Authorize emergency continuity, medical, and secure-records resources now or we risk losing both the facility and the records inside it."
	aid_details = "Emergency continuity, medical, and secure-records resources have been committed to protect priority archives and support verified personnel holding the remaining controlled sections."

/datum/ccpost_critical_incident/adm_06_syndicate_records_infiltration
	description = "coordinated Syndicate infiltration compromising secure corporate records"
	installation_code = CCPOST_INSTALLATION_CODE_ADM_06
	recovery_status = CCPOST_INSTALLATION_UNDER_REVIEW
	recovery_details = "Compromised systems have been isolated and priority archives secured. The extent of hostile access and data exposure remains under investigation."
	request_text = "We have confirmed coordinated Syndicate access to secure corporate records and cannot yet determine how much data has been exposed. Priority archives are being isolated from the network while verified staff work from sealed systems. We need emergency secure-storage, authentication, and continuity resources immediately."
	aid_details = "Emergency secure-storage, authentication, and continuity resources have been committed to isolate compromised records systems and preserve priority corporate archives."

/datum/ccpost_critical_incident/adm_06_changeling_records_conflict
	description = "suspected changeling infiltration following extensive duplicate personnel records and biometric conflicts"
	installation_code = CCPOST_INSTALLATION_CODE_ADM_06
	recovery_status = CCPOST_INSTALLATION_UNDER_REVIEW
	recovery_details = "Personnel records have been frozen for reconciliation and verified staff have restored control of critical archive functions. Identity verification remains underway."
	request_text = "Personnel records are duplicating, biometrics are conflicting, and we no longer know which identities inside the Annex can be trusted. Verified staff are freezing personnel-control changes and moving priority records onto isolated systems. We need secure authentication and continuity resources now."
	aid_details = "Secure authentication, isolated records-processing, and continuity resources have been committed so verified personnel can protect priority archives while identity verification continues."

/datum/ccpost_critical_incident/adm_06_cultist_archive_activity
	description = "violent cultist activity inside restricted archival areas"
	installation_code = CCPOST_INSTALLATION_CODE_ADM_06
	recovery_status = CCPOST_INSTALLATION_UNDER_REVIEW
	recovery_details = "Restricted archival areas have been secured and compromised records or materials isolated. Central Security and specialist review continue."
	request_text = "Cultist activity has breached restricted archival areas and several secure collections are no longer under verified control. Staff are evacuating irreplaceable records and sealing contaminated sections wherever possible. We need emergency medical, secure-storage, and access-control resources immediately."
	aid_details = "Emergency medical, secure-storage, and access-control resources have been committed to preserve priority archives and reinforce containment of compromised archival areas."

/datum/ccpost_critical_incident/adm_06_heretic_records_anomaly
	description = "a heretic-related containment incident involving anomalous records, structures, and missing personnel"
	installation_code = CCPOST_INSTALLATION_CODE_ADM_06
	recovery_status = CCPOST_INSTALLATION_UNDER_REVIEW
	recovery_details = "The immediate anomalous activity has been contained and affected records and structures sealed. Missing-personnel and specialist investigations remain active."
	request_text = "We have anomalous records and structures inside secured archival space, and personnel are missing from areas that should be physically accounted for. Staff are withdrawing from affected sections and sealing every boundary that still behaves normally. We need emergency isolation and continuity resources now."
	aid_details = "Emergency isolation, secure-storage, and continuity resources have been committed to protect unaffected archives and support containment of anomalous sections."

/datum/ccpost_critical_incident/adm_06_wizard_archive_raid
	description = "a suspected Wizard Federation raid resulting in the disappearance and reappearance of secured archival material"
	installation_code = CCPOST_INSTALLATION_CODE_ADM_06
	recovery_status = CCPOST_INSTALLATION_UNDER_REVIEW
	recovery_details = "Displaced archival material has been quarantined and priority records secured. Provenance and integrity verification remain underway."
	request_text = "Secured archival material is disappearing and reappearing in locations it was never transferred to, and we have evidence of a Wizard Federation raid. We cannot certify the integrity of anything that has been displaced. We need emergency quarantine, secure-storage, and verification resources immediately."
	aid_details = "Emergency quarantine, secure-storage, and verification resources have been committed to protect unaffected archives and isolate displaced material pending integrity checks."

/datum/ccpost_critical_incident/log_h09_syndicate_routing_sabotage
	description = "coordinated Syndicate sabotage collapsing automated freight routing"
	installation_code = CCPOST_INSTALLATION_CODE_LOG_H09
	recovery_status = CCPOST_INSTALLATION_MAINTENANCE
	recovery_details = "Emergency manual routing has been established and damaged automation isolated. Freight operations remain reduced while repairs and security review continue."
	request_text = "Automated freight routing is collapsing under confirmed Syndicate sabotage. We are assigning lanes manually where consoles still answer, but compromised controllers are creating dangerous movements faster than staff can catch them. We need emergency routing hardware, protected power, and security support now."
	aid_details = "Emergency routing hardware, protected power, and security-support resources have been committed to establish controlled manual freight movement while sabotaged automation is isolated."

/datum/ccpost_critical_incident/log_h09_hostile_freight_raid
	description = "an armed hostile raid targeting secured freight and supply reserves"
	installation_code = CCPOST_INSTALLATION_CODE_LOG_H09
	recovery_status = CCPOST_INSTALLATION_UNDER_REVIEW
	recovery_details = "The hostile raid has been repelled or contained and secured reserves are being accounted for. Security sweeps and loss assessment remain underway."
	request_text = "Armed hostiles are inside the freight complex and targeting secured reserves. Several storage areas are contested and routing staff are falling back behind hardened access points. We need emergency medical, access-control, and continuity resources now before the remaining reserves and dispatch systems are lost."
	aid_details = "Emergency medical, access-control, and continuity resources have been committed to reinforce protected freight areas and support containment of the armed raid."

/datum/ccpost_critical_incident/log_h09_revolutionary_cargo_seizure
	description = "revolutionary activity resulting in seizure of cargo control and dispatch systems"
	installation_code = CCPOST_INSTALLATION_CODE_LOG_H09
	recovery_status = CCPOST_INSTALLATION_UNDER_REVIEW
	recovery_details = "Dispatch control has been restored to verified personnel and compromised cargo lanes locked down. Security review remains active."
	request_text = "Revolutionary personnel have seized cargo control and parts of dispatch. Verified routing staff are cutting compromised lanes and trying to keep hostile users away from hazardous and secured freight. We need emergency secure-control, continuity, and access resources immediately."
	aid_details = "Emergency secure-control, continuity, and access resources have been committed to help verified routing personnel isolate seized dispatch systems and protect secured freight."

/datum/ccpost_critical_incident/log_h09_changeling_routing_infiltration
	description = "suspected changeling infiltration among routing personnel during a major freight emergency"
	installation_code = CCPOST_INSTALLATION_CODE_LOG_H09
	recovery_status = CCPOST_INSTALLATION_UNDER_REVIEW
	recovery_details = "Verified routing personnel have resumed restricted operations while identity checks continue. Privileged freight-control access remains limited."
	request_text = "We have conflicting identities among routing staff during an active freight emergency and cannot trust every person with dispatch access. Verified personnel are restricting controls while trying to keep essential cargo moving. We need secure authentication, emergency staffing, and continuity resources now."
	aid_details = "Secure authentication, emergency staffing, and continuity resources have been committed so verified personnel can maintain restricted freight operations while identity checks continue."

/datum/ccpost_critical_incident/log_h09_hazardous_freight_reaction
	description = "a chain reaction involving misrouted hazardous freight and damaged loading infrastructure"
	installation_code = CCPOST_INSTALLATION_CODE_LOG_H09
	recovery_status = CCPOST_INSTALLATION_MAINTENANCE
	recovery_details = "Hazardous freight has been contained and damaged loading areas isolated. Controlled routing has resumed at reduced capacity."
	request_text = "Misrouted hazardous freight has triggered a chain reaction across damaged loading infrastructure. We are evacuating lanes, isolating cargo we can still identify, and fighting secondary failures around the docks. We need emergency containment, handling, and structural resources immediately."
	aid_details = "Emergency containment, remote-handling, and structural resources have been committed to isolate hazardous freight and stabilize damaged loading areas."

/datum/ccpost_critical_incident/log_h09_wizard_freight_displacement
	description = "Wizard Federation spatial interference repeatedly displacing freight containers and personnel between secured routing zones"
	installation_code = CCPOST_INSTALLATION_CODE_LOG_H09
	recovery_status = CCPOST_INSTALLATION_MAINTENANCE
	recovery_details = "Spatial events have subsided enough for controlled routing to resume. Affected lanes remain closed while displaced freight and personnel are accounted for."
	request_text = "Spatial interference is moving freight containers and personnel between secured routing zones without any valid transfer path. We have suspended automated routing, but cargo is still appearing where it should not exist. We need emergency isolation, tracking, and protected-power resources now."
	aid_details = "Emergency isolation, tracking, and protected-power resources have been committed to preserve controlled freight zones while spatial displacement events are contained."

/datum/ccpost_critical_incident/med_m12_cold_chain_failure
	description = "a cascading medical cold-chain and life-support infrastructure failure"
	installation_code = CCPOST_INSTALLATION_CODE_MED_M12
	recovery_status = CCPOST_INSTALLATION_MAINTENANCE
	recovery_details = "Essential refrigeration and environmental control have been restored. Some medical stock remains quarantined or unavailable while validation continues."
	request_text = "Cold storage and life-support failures are cascading through M-12. Staff are moving viable stock by hand and abandoning storage areas as environmental control drops out. We need emergency refrigeration, power-conditioning, and life-support resources now or the sector is going to lose critical medical inventory with this facility."
	aid_details = "Emergency refrigeration, power-conditioning, and life-support resources have been committed to preserve viable medical stock and occupied distribution areas."

/datum/ccpost_critical_incident/med_m12_changeling_infiltration
	description = "suspected changeling infiltration following severe tissue, identity, and casualty discrepancies"
	installation_code = CCPOST_INSTALLATION_CODE_MED_M12
	recovery_status = CCPOST_INSTALLATION_UNDER_REVIEW
	recovery_details = "Suspect personnel and biological material have been isolated. Identity verification, casualty review, and medical containment remain underway."
	request_text = "We have tissue, identity, and casualty records that no longer agree with each other, and suspected changeling infiltration inside a medical distribution center. Verified staff are isolating personnel and biological material while keeping critical stock secured. We need emergency quarantine, authentication, and continuity resources now."
	aid_details = "Emergency quarantine, secure authentication, and continuity resources have been committed to protect verified medical stock and support isolation of suspect personnel and biological material."

/datum/ccpost_critical_incident/med_m12_bloodsucker_casualties
	description = "a suspected bloodsucker attack producing multiple unexplained exsanguinated casualties"
	installation_code = CCPOST_INSTALLATION_CODE_MED_M12
	recovery_status = CCPOST_INSTALLATION_UNDER_REVIEW
	recovery_details = "Treatment and storage areas have been secured and surviving personnel consolidated. Casualty investigation and security review remain active."
	request_text = "We have multiple unexplained exsanguinated casualties and a suspected bloodsucker still active somewhere inside M-12. Personnel are consolidating treatment and storage into controlled areas while unsecured corridors are abandoned. We need emergency medical, security, and portable-power resources immediately."
	aid_details = "Emergency medical, access-control, security-support, and portable-power resources have been committed to reinforce controlled treatment and storage areas."

/datum/ccpost_critical_incident/med_m12_cult_or_heretic_activity
	description = "violent cultist or heretic activity compromising treatment and storage areas"
	installation_code = CCPOST_INSTALLATION_CODE_MED_M12
	recovery_status = CCPOST_INSTALLATION_UNDER_REVIEW
	recovery_details = "Compromised treatment and storage areas have been sealed and viable stock transferred to secured sections. Specialist review continues."
	request_text = "Cultist or heretic activity has compromised treatment and medical-storage areas. Staff are moving patients and verified stock into the remaining secured sections while hostile or anomalous areas are sealed off. We need emergency medical continuity, isolation, and protected-power resources now."
	aid_details = "Emergency medical continuity, isolation, and protected-power resources have been committed to preserve viable treatment capacity and secured medical stock."

/datum/ccpost_critical_incident/med_m12_syndicate_medical_sabotage
	description = "coordinated Syndicate sabotage involving contaminated or deliberately compromised medical stock"
	installation_code = CCPOST_INSTALLATION_CODE_MED_M12
	recovery_status = CCPOST_INSTALLATION_UNDER_REVIEW
	recovery_details = "Suspect medical stock has been quarantined and verified inventory moved into secured storage. Sabotage and contamination review remain active."
	request_text = "We have confirmed coordinated sabotage involving contaminated or deliberately compromised medical stock. Distribution is being halted batch by batch while verified inventory is moved behind controlled access. We need emergency quarantine, validation, and secure-storage resources immediately."
	aid_details = "Emergency quarantine, validation, and secure-storage resources have been committed to isolate compromised stock and protect verified medical inventory."

/datum/ccpost_critical_incident/med_m12_wizard_medical_transmutation
	description = "an apparent Wizard Federation transmutation event rendering multiple secured medical supply batches biologically unrecognizable"
	installation_code = CCPOST_INSTALLATION_CODE_MED_M12
	recovery_status = CCPOST_INSTALLATION_UNDER_REVIEW
	recovery_details = "Transmuted stock has been quarantined and unaffected supplies transferred into validated storage. Specialist analysis remains underway."
	request_text = "Multiple secured medical batches have been transmuted into material our systems cannot biologically identify. We are quarantining everything affected and transferring untouched stock away from the event, but validated storage is running out. We need emergency quarantine, analysis, and secure-storage resources now."
	aid_details = "Emergency quarantine, analysis, and secure-storage resources have been committed to isolate transmuted stock and preserve unaffected medical inventory."


/datum/ccpost_critical_incident/sec_s08_syndicate_assault
	description = "a coordinated Syndicate assault targeting Sector Security command and communications"
	installation_code = CCPOST_INSTALLATION_CODE_SEC_S08
	recovery_status = CCPOST_INSTALLATION_UNDER_REVIEW
	recovery_details = "The immediate hostile assault has been contained and verified Security personnel retain control of command areas. Central Security sweeps and casualty accounting remain underway."
	request_text = "We have a coordinated Syndicate assault inside the outpost. Hostiles are targeting command, communications, and secured equipment rather than fighting for territory. Verified Security personnel are consolidating around the remaining controlled sections. We need emergency medical, access-control, communications, and continuity resources now."
	aid_details = "Emergency medical, access-control, protected-communications, and continuity resources have been committed to reinforce verified Security personnel and preserve regional command capability."

/datum/ccpost_critical_incident/sec_s08_armory_seizure
	description = "hostile personnel seizing part of the regional armory and security-control network"
	installation_code = CCPOST_INSTALLATION_CODE_SEC_S08
	recovery_status = CCPOST_INSTALLATION_UNDER_REVIEW
	recovery_details = "Verified Security personnel have regained control of restricted armory systems and compromised equipment is being accounted for. Access review and weapons reconciliation remain active."
	request_text = "Hostile personnel have seized part of the armory and we cannot account for every restricted weapon or access credential. Verified staff are locking down the remaining stores and cutting compromised security controls from the network. We need emergency authentication, medical, and secure-control resources immediately."
	aid_details = "Emergency authentication, medical, and secure-control resources have been committed to protect remaining armory stores and restore verified access to security systems."

/datum/ccpost_critical_incident/sec_s08_revolutionary_mutiny
	description = "organized revolutionary activity causing an internal security mutiny"
	installation_code = CCPOST_INSTALLATION_CODE_SEC_S08
	recovery_status = CCPOST_INSTALLATION_UNDER_REVIEW
	recovery_details = "Verified Nanotrasen personnel have restored control of essential Security functions. Remaining revolutionary activity is being contained and personnel loyalty review remains active."
	request_text = "We have an organized mutiny inside a Security installation. Multiple personnel have turned weapons and access privileges against command staff, and we cannot assume every local team is still loyal. Verified officers are holding the remaining secured sections. We need emergency medical, authentication, and continuity resources now."
	aid_details = "Emergency medical, authentication, and continuity resources have been committed so verified Nanotrasen personnel can preserve controlled sections and restore essential Security functions."

/datum/ccpost_critical_incident/sec_s08_changeling_command_compromise
	description = "suspected changeling infiltration compromising Security command identities and privileged access"
	installation_code = CCPOST_INSTALLATION_CODE_SEC_S08
	recovery_status = CCPOST_INSTALLATION_UNDER_REVIEW
	recovery_details = "Privileged access has been restricted to verified personnel and suspect identities isolated. Security command verification and biological review remain underway."
	request_text = "Command identities no longer agree with our biometrics, voiceprints, or access history, and suspected changeling infiltration has reached privileged Security staff. We are stripping authority down to the few identities we can verify. We need secure authentication, medical isolation, and continuity resources immediately."
	aid_details = "Secure authentication, medical-isolation, and continuity resources have been committed so verified personnel can maintain regional Security functions while identity checks continue."

/datum/ccpost_critical_incident/sec_s08_wizard_breach
	description = "a Wizard Federation attack disrupting secured areas, access control, and regional threat monitoring"
	installation_code = CCPOST_INSTALLATION_CODE_SEC_S08
	recovery_status = CCPOST_INSTALLATION_MAINTENANCE
	recovery_details = "The immediate thaumaturgic attack has subsided and secured areas are being re-established. Damaged access-control and monitoring systems remain under specialist review."
	request_text = "We have active Wizard Federation interference inside secured areas. Doors, personnel, and equipment are moving without valid access events, and parts of the regional threat network are producing impossible telemetry. We need protected power, redundant communications, medical support, and emergency isolation resources now."
	aid_details = "Protected power, redundant communications, medical support, and emergency isolation resources have been committed to preserve verified Security operations while thaumaturgic effects are contained."

/datum/ccpost_critical_incident/sec_s08_security_network_compromise
	description = "a hostile intrusion compromising regional security credentials, patrol routing, and automated access control"
	installation_code = CCPOST_INSTALLATION_CODE_SEC_S08
	recovery_status = CCPOST_INSTALLATION_UNDER_REVIEW
	recovery_details = "Compromised Security systems have been isolated and essential patrol coordination restored through verified channels. Credential reconstruction and intrusion tracing remain active."
	request_text = "The regional Security network is compromised. Patrol orders, access permissions, and threat notices are being altered through credentials that should be valid, which means we cannot trust automated routing or every authenticated command. We are moving essential coordination onto isolated systems. We need secure processing, authentication, and continuity resources immediately."
	aid_details = "Secure processing, authentication, and continuity resources have been committed to establish isolated patrol coordination and rebuild trusted access-control channels."


// CENTRAL COMMAND REMOTE OVERSIGHT NETWORK

// Sector Notice

/datum/ccpost_sector_notice
	var/notice_code
	var/template_id
	var/category
	var/source
	var/priority
	var/title
	var/body
	var/issued_at

/// Optional logistics effects attached to this notice.
	var/logistics_effect_duration = 0
	var/logistics_effect_expires_at = 0

	var/logistics_authorization_delay = 0
	var/logistics_dispatch_delay = 0
	var/logistics_transit_multiplier = 1

	var/logistics_effect_summary

	/// When TRUE and the notice is active, the Liaison Logistics terminal must not offer routine medical resupply.
	var/blocks_medical_supplies = FALSE

/datum/ccpost_sector_notice/New(_notice_code, datum/ccpost_sector_notice_template/template)
	. = ..()

	notice_code = _notice_code
	template_id = template.template_id
	category = template.category
	source = template.source
	priority = template.priority
	title = template.title
	body = template.body
	issued_at = station_time_timestamp()

	logistics_effect_duration = template.logistics_effect_duration
	logistics_authorization_delay = template.logistics_authorization_delay
	logistics_dispatch_delay = template.logistics_dispatch_delay
	logistics_transit_multiplier = template.logistics_transit_multiplier
	logistics_effect_summary = template.logistics_effect_summary
	blocks_medical_supplies = template.blocks_medical_supplies

	if(logistics_effect_duration > 0)
		logistics_effect_expires_at = world.time + logistics_effect_duration

/datum/ccpost_sector_notice/proc/has_active_logistics_effect()
	if(!logistics_effect_expires_at)
		return FALSE

	if(world.time >= logistics_effect_expires_at)
		return FALSE

	return TRUE


/// TRUE when this notice carries a player-facing mechanical sector effect, even
/// after that effect has expired. This lets Remote Oversight distinguish
/// historical operational notices from purely informational traffic.
/datum/ccpost_sector_notice/proc/has_operational_effect()
	if(logistics_effect_duration <= 0)
		return FALSE

	if(logistics_authorization_delay)
		return TRUE

	if(logistics_dispatch_delay)
		return TRUE

	if(logistics_transit_multiplier != 1)
		return TRUE

	return blocks_medical_supplies


/datum/ccpost_sector_notice/proc/get_operational_effect_seconds_remaining()
	if(!has_operational_effect() || !logistics_effect_expires_at)
		return 0

	return max(0, round((logistics_effect_expires_at - world.time) / (1 SECONDS)))

// Sector Installation History

/// Compact administrative history entry retained on each remote installation.
/// This records operational changes and Liaison decisions without duplicating the
/// full Sector Communications archive.
/datum/ccpost_installation_history_entry
	var/timestamp
	var/category
	var/title
	var/details

/datum/ccpost_installation_history_entry/New(
	_category,
	_title,
	_details
)
	. = ..()

	timestamp = station_time_timestamp()
	category = _category
	title = _title
	details = _details


// Sector Installation

/datum/ccpost_sector_installation
	var/installation_code
	var/installation_name
	var/installation_function
	var/regional_dependency

	/// Most recent authenticated installation-originated communication or telemetry contact.
	var/last_authenticated_contact
	var/last_authenticated_contact_at = 0

	/// Broad operational status visible to Central Command.
	var/status

	/// Timestamp of the most recent status change.
	var/status_since

	/// Current physical or operational condition.
	var/condition = "OPERATIONAL"

	/// Current state of remote telemetry.
	var/telemetry = "ACTIVE"

	/// Additional information regarding the installation's condition.
	var/condition_details = "No structural concerns reported."

	/// Current or most recent major incident.
	var/incident_summary = "No active incident."

	/// Current Central Command response.
	var/response_status = "NONE"

	/// Whether an Emergency Response Team was dispatched.
	var/ert_dispatched = FALSE

	/// Static configuration for the current or most recently contained Critical incident.
	var/datum/ccpost_critical_incident/critical_incident

	/// Whether Liaison-controlled emergency Operational Allocation was authorized
	/// during the current Critical incident.
	var/critical_aid_authorized = FALSE

	/// Administrative record of the most recent Critical aid authorization.
	var/critical_aid_authorized_by
	var/critical_aid_authorized_at

	/// Whether Liaison-controlled emergency assistance was explicitly denied
	/// during the current Critical incident.
	var/critical_aid_denied = FALSE

	/// Administrative record of the most recent Critical aid denial.
	var/critical_aid_denied_by
	var/critical_aid_denied_at

	/// TRUE while an installation is recovering from a successfully contained
	/// Critical incident but has not yet returned to green operation.
	var/critical_aftermath_active = FALSE

	/// Primary installation representative selected for this shift.
	var/contact_name = "Unknown Personnel"

	/// Job title of the selected installation representative.
	var/contact_role = "Installation Duty Officer"

	/// Installation-specific configuration copied from the immutable template.
	var/datum/ccpost_installation_response_profile/response_profile
	var/datum/ccpost_installation_loss_effect/loss_effect

	/// Temporary percentage-point increase to this installation's escalation risk
	/// caused by denied Operational Allocation requests. This decays as the
	/// installation survives later status cycles and clears when assistance is
	/// authorized or the installation returns to green operation.
	var/aid_denial_risk = 0

	/// Number of Operational Allocation requests denied during this shift.
	var/aid_denial_count = 0

	/// Administrative record of the most recent denial.
	var/last_aid_denial_at
	var/last_aid_denial_by

	/// Liaison relationship score for this installation. Starts at a neutral 50
	/// and changes only after meaningful administrative or operational decisions.
	var/trust_score = 50

	/// Compact shift-local administrative history, newest entry first.
	var/list/history = list()

	/// At most one ordinary operational follow-up chain may be active for this
	/// installation at a time. The originating message code prevents stale timer
	/// callbacks from continuing an old chain after a newer one has replaced it.
	var/active_followup_origin_code
	var/active_followup_origin_title
	var/active_followup_start_status
	var/followup_chain_step = 0

	/// Destroyed installations are permanently removed from normal rotation.
	var/destroyed = FALSE

/datum/ccpost_sector_installation/New(datum/ccpost_sector_installation_template/template)
	. = ..()

	installation_code = template.installation_code
	installation_name = template.installation_name
	installation_function = template.installation_function
	regional_dependency = template.regional_dependency
	status = template.initial_status
	status_since = station_time_timestamp()
	last_authenticated_contact = station_time_timestamp()
	last_authenticated_contact_at = world.time

	if(template.response_profile_type)
		var/response_profile_type = template.response_profile_type
		response_profile = new response_profile_type

	if(template.loss_effect_type)
		var/loss_effect_type = template.loss_effect_type
		loss_effect = new loss_effect_type

	if(length(template.contact_types))
		var/contact_type = pick(template.contact_types)
		var/datum/ccpost_sector_contact/chosen_contact = new contact_type

		contact_name = chosen_contact.contact_name
		contact_role = chosen_contact.contact_role

		qdel(chosen_contact)

/datum/ccpost_sector_installation/Destroy()
	QDEL_NULL(response_profile)
	QDEL_NULL(loss_effect)
	QDEL_LIST(history)
	return ..()


// SECTOR INSTALLATION COMMUNICATIONS

/datum/ccpost_sector_message
	var/message_code
	var/template_id

	var/installation_code
	var/installation_name

	var/sender_name
	var/sender_role

	/// UPDATE or REQUEST.
	var/message_type = CCPOST_MESSAGE_UPDATE

	var/priority = CCPOST_PRIORITY_ROUTINE
	var/title
	var/body
	var/issued_at

	/// PENDING, ACKNOWLEDGED, AUTHORIZED, DENIED, or EXPIRED.
	var/resolution_status = CCPOST_MESSAGE_PENDING

	var/responded_by
	var/responded_at
	var/response

	/// CU requested from the Liaison Outpost.
	var/allocation_cost = 0

	/// CU offered to the Liaison Outpost.
	var/allocation_reward = 0

	/// Actual CU change after resolution.
	var/allocation_change = 0

	/// Installation statuses for which this request remains valid.
	var/list/valid_statuses = list()

	/// Optional new installation status applied when authorized.
	var/success_status

	/// Optional condition-details override after authorization.
	var/success_details


/datum/ccpost_sector_message/New(
	_message_code,
	datum/ccpost_sector_installation/installation,
	datum/ccpost_sector_message_template/template,
	body_override
)
	. = ..()

	message_code = _message_code
	template_id = template.template_id

	installation_code = installation.installation_code
	installation_name = installation.installation_name

	sender_name = installation.contact_name
	sender_role = installation.contact_role

	message_type = template.message_type
	priority = template.priority
	title = template.title
	body = isnull(body_override) ? template.body : body_override
	allocation_cost = template.allocation_cost
	allocation_reward = template.allocation_reward

	if(length(template.required_statuses))
		valid_statuses = template.required_statuses.Copy()

	success_status = template.success_status
	success_details = template.success_details
	issued_at = station_time_timestamp()


// SECTOR ADMINISTRATIVE PAPERWORK

/// One active administrative document sent from a remote installation to the
/// Liaison Outpost for physical review, CentCom stamping, and return.
/datum/ccpost_sector_paperwork_request
	var/paperwork_code
	var/template_id

	var/installation_code
	var/installation_name
	var/sender_name
	var/sender_role

	var/priority = CCPOST_PRIORITY_ROUTINE
	var/title
	var/body
	var/issued_at

	/// AWAITING LIAISON REVIEW or TRANSMITTED - AWAITING RECEIPT.
	var/status = CCPOST_PAPERWORK_AWAITING_REVIEW

	var/submitted_by
	var/submitted_at

	/// Successful processing normally returns two CU to the Liaison Outpost.
	var/allocation_reward = 2

	/// Physical authenticated copies printed for this request. Copies are retained
	/// as objects when the request closes, but are visibly marked VOID.
	var/list/issued_copies = list()

/datum/ccpost_sector_paperwork_request/New(
	_paperwork_code,
	datum/ccpost_sector_installation/installation,
	datum/ccpost_sector_paperwork_template/template
)
	. = ..()

	paperwork_code = _paperwork_code
	template_id = template.template_id

	installation_code = installation.installation_code
	installation_name = installation.installation_name
	sender_name = installation.contact_name
	sender_role = installation.contact_role

	title = template.title
	body = template.body
	issued_at = station_time_timestamp()


/datum/ccpost_sector_paperwork_request/proc/register_physical_copy(obj/item/paper/ccpost_sector_paperwork/paperwork)
	if(!paperwork)
		return

	issued_copies |= paperwork


/datum/ccpost_sector_paperwork_request/proc/invalidate_physical_copies(reason)
	for(var/obj/item/paper/ccpost_sector_paperwork/paperwork as anything in issued_copies)
		if(QDELETED(paperwork))
			continue

		paperwork.mark_void(reason)

	issued_copies = list()


/datum/ccpost_sector_paperwork_request/Destroy()
	invalidate_physical_copies("Administrative request closed.")
	issued_copies = null
	return ..()


/// Physical, machine-identifiable paperwork generated by Sector Communications.
/// The hidden paperwork code prevents renamed, rewritten, or photocopied generic
/// paper from satisfying an active administrative request.
/obj/item/paper/ccpost_sector_paperwork
	name = "sector administrative document"
	desc = "An authenticated administrative document transmitted from a remote Nanotrasen installation for Central Command Liaison review."

	var/paperwork_code
	var/voided = FALSE
	var/void_reason


/obj/item/paper/ccpost_sector_paperwork/proc/mark_void(reason = "The originating administrative request is no longer active.")
	if(voided)
		return

	voided = TRUE
	void_reason = reason
	name = "VOID - [name]"
	desc = "A voided sector administrative document. It is retained for reference only and cannot satisfy an active Liaison paperwork request."
	add_raw_text("<hr><center><b>VOID - DOCUMENT NO LONGER VALID</b></center><br><small>[reason]</small>")
	update_appearance()


/obj/item/paper/ccpost_sector_paperwork/examine(mob/user)
	. = ..()

	if(voided)
		. += span_warning("This administrative document is VOID: [void_reason]")


// Shared Sector Network

/datum/ccpost_sector_network
	/// Prevents several displays from independently starting network timers.
	var/started = FALSE

	/// Every Remote Status Display connected to this shared network.
	var/list/registered_displays = list()

	/// Timer for ordinary Central Command sector notices.
	var/sector_notice_timer

	/// Timer for fictional sector installation updates.
	var/sector_installation_timer

	/// Current notice archive.
	var/list/sector_notices = list()

	/// Installations tracked by this network.
	var/list/sector_installations = list()

	/// Prevent immediately repeating the same random notice.
	var/last_sector_notice_id

	/// Prevent repeatedly selecting the same installation.
	var/last_updated_installation_code

	/// Sequential notice reference number.
	var/next_sector_notice_number = 1

	/// Maximum amount of sector notices retained.
	var/max_sector_notices = 20

	/// Sector Communications Terminals connected to this network.
	var/list/registered_comms_terminals = list()

	/// Timer controlling installation-originated messages.
	var/sector_message_timer

	/// Current and archived installation communications.
	var/list/sector_messages = list()

	/// Sequential identifier for sector communications.
	var/next_sector_message_number = 1

	/// Maximum communications retained.
	var/max_sector_messages = 100

	/// Maximum compact administrative-history entries retained per installation.
	var/max_installation_history_entries = 12

	/// Tracks whether at least one Medical Supply Recall is currently active so
	/// M-12 receives one clean history entry when the final active recall clears.
	var/medical_supply_recall_was_active = FALSE

	/// Prevents the exact same transmission template repeating immediately.
	var/last_sector_message_template_id

	/// Prevents one installation dominating ordinary communications.
	var/last_sector_message_installation_code

	/// Short rolling histories keep both installations and individual templates varied.
	var/list/recent_sector_message_installation_codes = list()
	var/list/recent_sector_message_template_ids = list()

	/// Number of recently used installations/templates avoided when alternatives exist.
	var/max_recent_sector_message_installations = 5
	var/max_recent_sector_message_templates = 8


	/// Timer controlling installation-originated administrative paperwork.
	var/sector_paperwork_timer

	/// Only one sector paperwork request may exist at a time because the Sector
	/// Communications Terminal has one physical document slot.
	var/datum/ccpost_sector_paperwork_request/active_sector_paperwork

	/// Sequential identifier used for physical sector paperwork.
	var/next_sector_paperwork_number = 1

	/// Prevents the exact same administrative form repeating back-to-back.
	var/last_sector_paperwork_template_id

	// Ordinary Sector Notice Templates

	/// Instantiated immutable configuration templates.
	var/list/sector_notice_templates = list()

	// Sector Installations

	var/list/sector_installation_templates = list()

	// Installation-originated administrative paperwork.
	//
	// Paperwork is intentionally low-stakes, physical office work. It is only
	// issued by installations which are ONLINE, conducting ROUTINE OPERATIONS,
	// or undergoing MAINTENANCE. CRITICAL, degraded, disconnected, offline,
	// destroyed, or UNDER REVIEW installations do not generate paperwork.

	var/list/sector_paperwork_templates = list()

	// Installation-originated communications.
	//
	// Ordinary messages are handled by the recurring Sector Communications
	// timer. Templates marked reactive_aid are instead considered when an
	// installation actually drops below green operational status.

	var/list/sector_message_templates = list()

	// Possible Critical Incidents
	// Critical incidents are mostly installation-specific so failures better match each site's function.
	// Roughly 70% of CRITICAL escalations use the installation pool; the remainder use a common sector emergency.

	var/list/critical_incidents_common = list()

	var/list/critical_incidents_by_installation = list()

/datum/ccpost_sector_network/New()
	. = ..()
	build_template_catalogs()

/datum/ccpost_sector_network/proc/build_template_catalogs()
	for(var/notice_type as anything in subtypesof(/datum/ccpost_sector_notice_template))
		sector_notice_templates += new notice_type

	for(var/installation_type as anything in subtypesof(/datum/ccpost_sector_installation_template))
		sector_installation_templates += new installation_type

	for(var/paperwork_type as anything in subtypesof(/datum/ccpost_sector_paperwork_template))
		sector_paperwork_templates += new paperwork_type

	for(var/message_template_type as anything in subtypesof(/datum/ccpost_sector_message_template))
		sector_message_templates += new message_template_type

	for(var/incident_type as anything in subtypesof(/datum/ccpost_critical_incident))
		var/datum/ccpost_critical_incident/incident = new incident_type

		if(!incident.description)
			qdel(incident)
			continue

		if(!incident.installation_code)
			critical_incidents_common += incident
			continue

		var/list/installation_incidents = critical_incidents_by_installation[incident.installation_code]
		if(!installation_incidents)
			installation_incidents = list()
			critical_incidents_by_installation[incident.installation_code] = installation_incidents

		installation_incidents += incident


GLOBAL_DATUM_INIT(ccpost_sector_network, /datum/ccpost_sector_network, new)

// NETWORK REGISTRATION

/datum/ccpost_sector_network/proc/register_display(obj/machinery/status_display/ccpost_remote_status/display)
	if(!display)
		return

	registered_displays |= display

	ensure_started()


/datum/ccpost_sector_network/proc/unregister_display(obj/machinery/status_display/ccpost_remote_status/display)
	if(!display)
		return

	registered_displays -= display


/datum/ccpost_sector_network/proc/ensure_started()
	if(started)
		return

	started = TRUE

	initialize_sector_installations()

	// Give the system one existing archived notice when it first comes online.
	issue_sector_notice(TRUE)

	schedule_next_sector_installation_update()

	schedule_next_sector_message()

	schedule_next_sector_paperwork()


/// Records the most recent authenticated contact from a remote installation.
/datum/ccpost_sector_network/proc/record_installation_contact(datum/ccpost_sector_installation/installation)
	if(!installation || installation.destroyed)
		return

	installation.last_authenticated_contact = station_time_timestamp()
	installation.last_authenticated_contact_at = world.time


/datum/ccpost_sector_network/proc/get_pending_sector_message_count()
	var/pending_count = 0

	for(var/datum/ccpost_sector_message/message as anything in sector_messages)
		if(QDELETED(message))
			continue

		if(message.resolution_status == CCPOST_MESSAGE_PENDING)
			pending_count++

	return pending_count


/// Returns the cumulative communication-delay multiplier from permanently lost
/// sector installations. Multipliers are capped to keep the network active.
/datum/ccpost_sector_network/proc/get_sector_message_interval_multiplier()
	var/multiplier = 1

	for(var/datum/ccpost_sector_installation/installation as anything in sector_installations)
		if(QDELETED(installation) || !installation.destroyed || !installation.loss_effect)
			continue

		multiplier *= max(1, installation.loss_effect.sector_message_interval_multiplier)

	return clamp(multiplier, 1, 2)


/// Returns the cumulative paperwork-delay multiplier from permanently lost
/// sector installations.
/datum/ccpost_sector_network/proc/get_sector_paperwork_interval_multiplier()
	var/multiplier = 1

	for(var/datum/ccpost_sector_installation/installation as anything in sector_installations)
		if(QDELETED(installation) || !installation.destroyed || !installation.loss_effect)
			continue

		multiplier *= max(1, installation.loss_effect.sector_paperwork_interval_multiplier)

	return clamp(multiplier, 1, 2)


/// Permanent early-warning/security losses raise the chance that later
/// operational problems escalate into a Critical incident.
/datum/ccpost_sector_network/proc/get_sector_loss_critical_chance_modifier()
	var/modifier = 0

	for(var/datum/ccpost_sector_installation/installation as anything in sector_installations)
		if(QDELETED(installation) || !installation.destroyed || !installation.loss_effect)
			continue

		modifier += max(0, installation.loss_effect.critical_chance_modifier)

	return modifier


/// Refreshes systems whose timing or freight state changes immediately when an
/// installation is permanently lost.
/datum/ccpost_sector_network/proc/apply_installation_loss_effects(datum/ccpost_sector_installation/installation)
	if(!installation?.destroyed || !installation.loss_effect)
		return

	var/datum/ccpost_installation_loss_effect/effect = installation.loss_effect

	if(effect.has_logistics_effect() && GLOB.ccpost_logistics_network)
		GLOB.ccpost_logistics_network.refresh_logistics_outputs()

	if(effect.sector_message_interval_multiplier != 1)
		schedule_next_sector_message()

	if(effect.sector_paperwork_interval_multiplier != 1)
		schedule_next_sector_paperwork()


// SECTOR INSTALLATION MESSAGE GENERATION

/datum/ccpost_sector_network/proc/schedule_next_sector_message(
	minimum_delay = 3 MINUTES,
	maximum_delay = 6 MINUTES
)
	if(sector_message_timer)
		deltimer(sector_message_timer)

	var/delay = rand(minimum_delay, maximum_delay)
	delay = round(delay * get_sector_message_interval_multiplier(), 1 SECONDS)

	sector_message_timer = addtimer(CALLBACK(src, PROC_REF(issue_sector_message)), delay, TIMER_STOPPABLE)



// SECTOR ADMINISTRATIVE PAPERWORK GENERATION

/datum/ccpost_sector_network/proc/schedule_next_sector_paperwork(
	minimum_delay = 8 MINUTES,
	maximum_delay = 15 MINUTES
)
	if(sector_paperwork_timer)
		deltimer(sector_paperwork_timer)

	var/delay = rand(minimum_delay, maximum_delay)
	delay = round(delay * get_sector_paperwork_interval_multiplier(), 1 SECONDS)

	sector_paperwork_timer = addtimer(CALLBACK(src, PROC_REF(issue_sector_paperwork)), delay, TIMER_STOPPABLE)


/// Administrative paperwork is only generated while an installation is stable
/// enough to perform ordinary office work. Maintenance remains eligible.
/datum/ccpost_sector_network/proc/can_issue_sector_paperwork(datum/ccpost_sector_installation/installation)
	if(!installation || installation.destroyed)
		return FALSE

	return installation.status == CCPOST_INSTALLATION_ONLINE || installation.status == CCPOST_INSTALLATION_ROUTINE || installation.status == CCPOST_INSTALLATION_MAINTENANCE


/// Removes the active paperwork request if its source can no longer conduct
/// normal administrative business. Physical copies become invalid immediately.
/datum/ccpost_sector_network/proc/expire_active_sector_paperwork(reason = "Source installation is no longer available for routine administrative processing.", refresh_ui = TRUE)
	if(!active_sector_paperwork)
		return FALSE

	var/expired_code = active_sector_paperwork.paperwork_code
	active_sector_paperwork.invalidate_physical_copies(reason)

	for(var/obj/machinery/computer/ccpost_sector_comms/terminal as anything in registered_comms_terminals)
		if(QDELETED(terminal))
			continue

		if(terminal.submitted_paperwork?.paperwork_code == expired_code)
			terminal.eject_sector_paperwork()

	qdel(active_sector_paperwork)
	active_sector_paperwork = null

	// An invalidated document should not block later routine paperwork forever.
	schedule_next_sector_paperwork(4 MINUTES, 7 MINUTES)

	if(refresh_ui)
		refresh_comms_terminals()

	return TRUE


/datum/ccpost_sector_network/proc/expire_sector_paperwork_for_installation(
	datum/ccpost_sector_installation/installation,
	reason = "Source installation is no longer available for routine administrative processing."
)
	if(!installation || !active_sector_paperwork)
		return FALSE

	if(active_sector_paperwork.installation_code != installation.installation_code)
		return FALSE

	return expire_active_sector_paperwork(reason)


/// Confirms that the current paperwork still belongs to an eligible installation.
/// UI reads may suppress the extra refresh because the interface is already updating.
/datum/ccpost_sector_network/proc/validate_active_sector_paperwork(refresh_ui = TRUE)
	if(!active_sector_paperwork)
		return FALSE

	var/datum/ccpost_sector_installation/installation = get_installation_by_code(
		active_sector_paperwork.installation_code
	)

	if(!can_issue_sector_paperwork(installation))
		expire_active_sector_paperwork(
			"Source installation left routine administrative availability.",
			refresh_ui
		)
		return FALSE

	return TRUE


/datum/ccpost_sector_network/proc/issue_sector_paperwork()
	sector_paperwork_timer = null

	// One physical document slot means one active paperwork request at a time.
	if(active_sector_paperwork)
		if(validate_active_sector_paperwork())
			return

	var/list/eligible_templates = list()

	for(var/datum/ccpost_sector_paperwork_template/template as anything in sector_paperwork_templates)
		var/datum/ccpost_sector_installation/installation = get_installation_by_code(
			template.installation_code
		)

		if(!can_issue_sector_paperwork(installation))
			continue

		eligible_templates += list(template)

	if(!length(eligible_templates))
		schedule_next_sector_paperwork(4 MINUTES, 7 MINUTES)
		return

	// Avoid immediately repeating the same form when alternatives exist.
	if(length(eligible_templates) > 1 && last_sector_paperwork_template_id)
		var/list/non_repeating_templates = list()

		for(var/datum/ccpost_sector_paperwork_template/template as anything in eligible_templates)
			if(template.template_id == last_sector_paperwork_template_id)
				continue

			non_repeating_templates += list(template)

		if(length(non_repeating_templates))
			eligible_templates = non_repeating_templates

	var/datum/ccpost_sector_paperwork_template/chosen_template = pick(eligible_templates)
	var/datum/ccpost_sector_installation/source_installation = get_installation_by_code(
		chosen_template.installation_code
	)

	if(!can_issue_sector_paperwork(source_installation))
		schedule_next_sector_paperwork(4 MINUTES, 7 MINUTES)
		return

	var/paperwork_code = "[source_installation.installation_code]/PR-[next_sector_paperwork_number]"
	next_sector_paperwork_number++

	active_sector_paperwork = new /datum/ccpost_sector_paperwork_request(
		paperwork_code,
		source_installation,
		chosen_template
	)

	record_installation_contact(source_installation)
	last_sector_paperwork_template_id = chosen_template.template_id

	// The first available Sector Communications Terminal physically prints the
	// incoming form. Other terminals can still display or reprint the same request.
	for(var/obj/machinery/computer/ccpost_sector_comms/terminal as anything in registered_comms_terminals)
		if(QDELETED(terminal) || terminal.machine_stat & (NOPOWER | BROKEN))
			continue

		if(terminal.print_sector_paperwork(active_sector_paperwork))
			terminal.say("Incoming administrative document from [source_installation.installation_name]. Sender: [source_installation.contact_role] [source_installation.contact_name].")
			break

	// The request remains available in TGUI even if no terminal could print it.
	refresh_comms_terminals()


/datum/ccpost_sector_network/proc/get_paperwork_receipt_body(
	datum/ccpost_sector_installation/installation,
	datum/ccpost_sector_paperwork_request/paperwork,
	reward_text
)
	if(!installation || !paperwork)
		return "Document receipt confirmed. [reward_text]"

	var/relationship = get_installation_trust_label(installation)

	switch(relationship)
		if("TRUSTED")
			return "Received, thank you. Liaison review [paperwork.paperwork_code] has been entered into our local administrative record. [reward_text] I appreciate the quick turnaround."
		if("COOPERATIVE")
			return "Liaison review [paperwork.paperwork_code] has been received and entered into the local administrative record. [reward_text] Thank you for the prompt review."
		if("GUARDED")
			return "Receipt confirmed for Liaison review [paperwork.paperwork_code]. The document has been entered into the local administrative record. [reward_text]"
		if("STRAINED")
			return "For record: Liaison review [paperwork.paperwork_code] has been received and entered locally. [reward_text] No further action is required from the Liaison office."

	return "Liaison review [paperwork.paperwork_code] has been received and entered into the local administrative record. [reward_text] Thank you for the timely review."


/// Completes a transmitted form after a short simulated routing delay, credits
/// the Liaison Outpost, and creates an ordinary Sector Communications receipt.
/datum/ccpost_sector_network/proc/complete_sector_paperwork(paperwork_code)
	if(!active_sector_paperwork || active_sector_paperwork.paperwork_code != paperwork_code)
		return

	if(active_sector_paperwork.status != CCPOST_PAPERWORK_AWAITING_RECEIPT)
		return

	if(!validate_active_sector_paperwork())
		return

	var/datum/ccpost_sector_paperwork_request/completed_paperwork = active_sector_paperwork
	var/datum/ccpost_sector_installation/installation = get_installation_by_code(
		completed_paperwork.installation_code
	)

	if(!can_issue_sector_paperwork(installation))
		expire_active_sector_paperwork("Receiving installation became unavailable before document receipt.")
		return

	var/credited_amount = 0
	var/datum/ccpost_logistics_network/logistics_network = GLOB.ccpost_logistics_network

	if(logistics_network)
		credited_amount = logistics_network.credit_allocation(
			completed_paperwork.allocation_reward,
			"Completed sector paperwork [completed_paperwork.paperwork_code]: [completed_paperwork.title]",
			"CENTRAL COMMAND SECTOR ADMINISTRATION"
		)
		logistics_network.refresh_logistics_outputs()

	var/reward_text

	if(credited_amount >= completed_paperwork.allocation_reward)
		reward_text = "Administrative processing compensation of [credited_amount] CU has been credited to Liaison Operational Allocation."
	else if(credited_amount > 0)
		reward_text = "[credited_amount] CU of the [completed_paperwork.allocation_reward] CU administrative processing compensation was credited before local Operational Allocation reached capacity."
	else
		reward_text = "Administrative processing compensation was approved, but local Operational Allocation is already at maximum capacity."

	var/paperwork_processor = completed_paperwork.submitted_by ? completed_paperwork.submitted_by : "UNKNOWN LIAISON"

	adjust_installation_trust(
		installation,
		2,
		"ADMINISTRATION",
		"Paperwork processed: [completed_paperwork.title]",
		"[completed_paperwork.sender_role] [completed_paperwork.sender_name] confirmed receipt of [completed_paperwork.paperwork_code], processed by [paperwork_processor]."
	)

	var/datum/ccpost_sector_message/confirmation = create_dynamic_sector_message(
		installation,
		"paperwork_receipt_[completed_paperwork.paperwork_code]",
		CCPOST_MESSAGE_UPDATE,
		CCPOST_PRIORITY_ROUTINE,
		"Document Receipt Confirmation - [completed_paperwork.paperwork_code]",
		get_paperwork_receipt_body(installation, completed_paperwork, reward_text)
	)

	if(confirmation)
		// Preserve the original sender identity used on the paperwork itself.
		confirmation.sender_name = completed_paperwork.sender_name
		confirmation.sender_role = completed_paperwork.sender_role
		confirmation.allocation_change = credited_amount
		notify_comms_terminals(confirmation)

	completed_paperwork.invalidate_physical_copies("Administrative request completed and archived.")
	active_sector_paperwork = null
	qdel(completed_paperwork)

	schedule_next_sector_paperwork()
	refresh_comms_terminals()


/datum/ccpost_sector_network/proc/is_installation_green(datum/ccpost_sector_installation/installation)
	if(!installation || installation.destroyed)
		return FALSE

	return installation.status == CCPOST_INSTALLATION_ONLINE || installation.status == CCPOST_INSTALLATION_ROUTINE


/// Selects another surviving sector installation to receive CU which cannot fit
/// inside the Liaison Outpost's Operational Allocation.
/datum/ccpost_sector_network/proc/get_allocation_reroute_recipient(excluded_installation_code)
	var/list/candidates = list()

	for(var/datum/ccpost_sector_installation/installation as anything in sector_installations)
		if(QDELETED(installation) || installation.destroyed)
			continue

		if(installation.installation_code == excluded_installation_code)
			continue

		candidates += installation

	if(!length(candidates))
		return null

	return pick(candidates)


/datum/ccpost_sector_network/proc/has_pending_sector_message_template(template_id)
	if(!template_id)
		return FALSE

	for(var/datum/ccpost_sector_message/existing_message as anything in sector_messages)
		if(QDELETED(existing_message))
			continue

		if(existing_message.resolution_status != CCPOST_MESSAGE_PENDING)
			continue

		if(existing_message.template_id == template_id)
			return TRUE

	return FALSE


/datum/ccpost_sector_network/proc/has_pending_sector_request_for_installation(installation_code)
	if(!installation_code)
		return FALSE

	for(var/datum/ccpost_sector_message/existing_message as anything in sector_messages)
		if(QDELETED(existing_message))
			continue

		if(existing_message.resolution_status != CCPOST_MESSAGE_PENDING)
			continue

		if(existing_message.installation_code != installation_code)
			continue

		if(existing_message.message_type == CCPOST_MESSAGE_REQUEST)
			return TRUE

	return FALSE


/datum/ccpost_sector_network/proc/get_eligible_sector_message_templates()
	var/list/eligible_templates = list()

	for(var/datum/ccpost_sector_message_template/template as anything in sector_message_templates)
		// Reactive aid requests are rolled when an installation's status changes.
		// The ordinary communications timer should not generate them on its own.
		if(template.reactive_aid)
			continue

		var/template_id = template.template_id

		if(has_pending_sector_message_template(template_id))
			continue

		var/installation_code = template.installation_code
		var/datum/ccpost_sector_installation/installation = get_installation_by_code(installation_code)

		if(!installation || installation.destroyed)
			continue

		var/list/required_statuses = template.required_statuses

		if(length(required_statuses))
			if(!(installation.status in required_statuses))
				continue

		// Installations may only transfer CU while they are fully green.
		// This is intentionally enforced here even if a template's status list
		// is later edited incorrectly.
		if(template.allocation_reward > 0 && !is_installation_green(installation))
			continue

		eligible_templates += list(template)

	return eligible_templates


// INSTALLATION HISTORY / RELATIONSHIP / FOLLOW-UP CHAINS

/datum/ccpost_sector_network/proc/get_installation_trust_label(datum/ccpost_sector_installation/installation)
	if(!installation)
		return "UNKNOWN"

	if(installation.trust_score >= 80)
		return "TRUSTED"
	if(installation.trust_score >= 60)
		return "COOPERATIVE"
	if(installation.trust_score >= 40)
		return "PROFESSIONAL"
	if(installation.trust_score >= 20)
		return "GUARDED"

	return "STRAINED"


/datum/ccpost_sector_network/proc/add_installation_history(
	datum/ccpost_sector_installation/installation,
	category,
	title,
	details
)
	if(!installation || !title)
		return

	var/datum/ccpost_installation_history_entry/entry = new(
		category || "GENERAL",
		title,
		details || "No additional details recorded."
	)

	installation.history.Insert(1, entry)

	while(length(installation.history) > max_installation_history_entries)
		var/datum/ccpost_installation_history_entry/oldest = installation.history[length(installation.history)]
		installation.history.Cut(length(installation.history), length(installation.history) + 1)
		qdel(oldest)

	notify_registered_displays()


/// Clears only the retained administrative history for one installation. This
/// does not alter its hidden relationship score, operational state, or active
/// follow-up chain.
/datum/ccpost_sector_network/proc/clear_installation_history(datum/ccpost_sector_installation/installation)
	if(!installation)
		return FALSE

	QDEL_LIST(installation.history)
	installation.history = list()
	notify_registered_displays()

	return TRUE


/datum/ccpost_sector_network/proc/adjust_installation_trust(
	datum/ccpost_sector_installation/installation,
	amount,
	category,
	title,
	details
)
	if(!installation || !amount)
		return 0

	var/old_score = installation.trust_score
	installation.trust_score = min(100, max(0, installation.trust_score + amount))
	var/actual_change = installation.trust_score - old_score

	if(!actual_change)
		return 0

	add_installation_history(
		installation,
		category,
		title,
		details
	)

	refresh_comms_terminals()

	return actual_change


/datum/ccpost_sector_network/proc/get_installation_status_severity(status)
	switch(status)
		if(CCPOST_INSTALLATION_ONLINE, CCPOST_INSTALLATION_ROUTINE)
			return 0
		if(CCPOST_INSTALLATION_MAINTENANCE, CCPOST_INSTALLATION_UNDER_REVIEW)
			return 1
		if(CCPOST_INSTALLATION_COMMS_DEGRADED)
			return 2
		if(CCPOST_INSTALLATION_NO_CONTACT)
			return 3
		if(CCPOST_INSTALLATION_OFFLINE)
			return 4
		if(CCPOST_INSTALLATION_CRITICAL)
			return 5

	return 0


/// Relationship affects how willing an installation is to volunteer continuing
/// context after a non-green operational update. It intentionally changes
/// information flow rather than raw survival odds or status-change rolls.
/datum/ccpost_sector_network/proc/get_installation_followup_chance(datum/ccpost_sector_installation/installation)
	if(!installation)
		return 0

	var/chance = 45 + round((installation.trust_score - 50) / 2)
	return min(70, max(25, chance))


/datum/ccpost_sector_network/proc/get_installation_followup_body(
	datum/ccpost_sector_installation/installation,
	origin_title,
	outcome
)
	if(!installation)
		return "Central Command is advised that the previously reported matter remains under local review."

	var/relationship = get_installation_trust_label(installation)
	var/current_status = installation.status

	switch(outcome)
		if("RESOLVED")
			switch(relationship)
				if("TRUSTED")
					return "Wanted to keep you personally informed: the matter we reported as '[origin_title]' has stabilized. Local personnel have closed the immediate issue and normal operations have resumed. Your office has the update before we close the local file."
				if("COOPERATIVE")
					return "A quick follow-up for the Liaison office: the matter previously reported as '[origin_title]' has stabilized. Local personnel have closed the immediate issue and normal operations have resumed. Thank you for keeping the line open."
				if("GUARDED")
					return "As required, this office is advising Central Command that the matter previously reported as '[origin_title]' has stabilized. Local personnel have closed the immediate issue and normal operations have resumed."
				if("STRAINED")
					return "For mandatory record: local personnel have stabilized '[origin_title]' and normal operations have resumed. No further Liaison action is requested. The originating correspondence remains attached to our local file."
			return "For Central Command situational awareness, the matter previously reported as '[origin_title]' has stabilized. Local personnel have closed the immediate issue and normal operations have resumed."

		if("ESCALATED")
			switch(relationship)
				if("TRUSTED")
					return "I wanted you to have this before the next formal reporting cycle: conditions associated with '[origin_title]' have deteriorated and we are now at [current_status]. Local personnel are continuing containment. We will keep your office informed of any material change."
				if("COOPERATIVE")
					return "Please note that conditions associated with '[origin_title]' have deteriorated since our previous transmission. Current installation status is [current_status]. Local personnel are continuing containment and we will forward another update if the situation changes materially."
				if("GUARDED")
					return "Central Command is advised that conditions associated with '[origin_title]' have deteriorated. Current installation status is [current_status]. Local containment remains in progress; further reporting will follow if required."
				if("STRAINED")
					return "For mandatory record: conditions associated with '[origin_title]' have deteriorated to [current_status]. Local personnel are proceeding with containment. Further transmissions will be made only on material change."
			return "For Central Command situational awareness, conditions associated with '[origin_title]' have deteriorated since our previous transmission. Current installation status is [current_status]. Local personnel are continuing containment and will report any further material change."

		if("CONTINUING_FINAL")
			switch(relationship)
				if("TRUSTED")
					return "One last update for your desk: '[origin_title]' remains unresolved at [current_status], but local personnel have the matter under observation and there is no additional request for Central Command action right now. We'll reopen contact if that changes."
				if("COOPERATIVE")
					return "For continued Liaison awareness, '[origin_title]' remains unresolved and the installation remains at [current_status]. Local personnel are monitoring the issue. No additional Central Command action is requested at this time."
				if("GUARDED")
					return "As required, this office confirms that '[origin_title]' remains unresolved. Current installation status is [current_status]. No additional Central Command action is requested; local observation continues."
				if("STRAINED")
					return "For mandatory record: '[origin_title]' remains unresolved at [current_status]. Local personnel retain responsibility for observation. No further Liaison action is requested at this time."
			return "For Central Command situational awareness, the matter previously reported as '[origin_title]' remains unresolved. Current installation status is [current_status]. No additional Central Command action is requested at this time, but the issue remains under local observation."

		if("CONTINUING")
			switch(relationship)
				if("TRUSTED")
					return "Keeping you in the loop: '[origin_title]' is still active and we remain at [current_status]. Local teams are continuing investigation and containment. I'll forward the next useful update rather than make you wait on the routine cycle."
				if("COOPERATIVE")
					return "For continued Liaison awareness, '[origin_title]' remains active and the installation is still at [current_status]. Local personnel are continuing investigation and containment; another update will follow if the matter remains unresolved."
				if("GUARDED")
					return "Central Command is advised that '[origin_title]' remains active. Current installation status is [current_status]. Local investigation and containment continue; a further report will be transmitted if required."
				if("STRAINED")
					return "For mandatory record: '[origin_title]' remains active at [current_status]. Local personnel are continuing containment. Further correspondence will be limited to material developments."
			return "For Central Command situational awareness, the matter previously reported as '[origin_title]' remains active. Current installation status is [current_status]. Local personnel are continuing investigation and containment; a final status update will follow if the situation remains unresolved."

	return "Central Command is advised that '[origin_title]' remains under local review at [current_status]."


/// Ordinary non-green UPDATE messages can begin a short two-stage follow-up
/// chain. Aid requests and automatic denial follow-ups use their own systems and
/// are intentionally excluded.
/datum/ccpost_sector_network/proc/maybe_start_installation_followup(datum/ccpost_sector_message/message)
	if(!message || message.message_type != CCPOST_MESSAGE_UPDATE || message.allocation_reward > 0)
		return FALSE

	var/datum/ccpost_sector_installation/installation = get_installation_by_code(message.installation_code)

	if(!installation || installation.destroyed || installation.status == CCPOST_INSTALLATION_CRITICAL)
		return FALSE

	if(is_installation_green(installation))
		return FALSE

	if(installation.active_followup_origin_code)
		return FALSE

	if(!prob(get_installation_followup_chance(installation)))
		return FALSE

	installation.active_followup_origin_code = message.message_code
	installation.active_followup_origin_title = message.title
	installation.active_followup_start_status = installation.status
	installation.followup_chain_step = 0

	var/minimum_delay = 3 MINUTES
	var/maximum_delay = 5 MINUTES

	if(installation.trust_score >= 80)
		minimum_delay = 2 MINUTES
		maximum_delay = 4 MINUTES
	else if(installation.trust_score < 20)
		minimum_delay = 4 MINUTES
		maximum_delay = 7 MINUTES

	add_installation_history(
		installation,
		"COMMUNICATIONS",
		"Follow-up opened: [message.title]",
		"[message.sender_role] [message.sender_name] indicated that additional information may follow regarding [message.title]."
	)

	addtimer(CALLBACK(src, PROC_REF(issue_installation_followup), installation.installation_code, message.message_code, 1), rand(minimum_delay, maximum_delay), TIMER_STOPPABLE)

	return TRUE


/datum/ccpost_sector_network/proc/clear_installation_followup(datum/ccpost_sector_installation/installation)
	if(!installation)
		return

	installation.active_followup_origin_code = null
	installation.active_followup_origin_title = null
	installation.active_followup_start_status = null
	installation.followup_chain_step = 0


/// Human-readable follow-up state for Liaison-facing records. Internal chain
/// step numbers remain backend-only.
/datum/ccpost_sector_network/proc/get_installation_followup_status_text(datum/ccpost_sector_installation/installation)
	if(!installation || !installation.active_followup_origin_code)
		return "No active case."

	if(installation.followup_chain_step <= 0)
		return "Awaiting first follow-up."

	return "Latest update received - further follow-up pending."


/datum/ccpost_sector_network/proc/issue_installation_followup(
	installation_code,
	origin_message_code,
	step
)
	var/datum/ccpost_sector_installation/installation = get_installation_by_code(installation_code)

	if(!installation || installation.destroyed)
		return

	if(installation.active_followup_origin_code != origin_message_code)
		return

	if(installation.status == CCPOST_INSTALLATION_CRITICAL)
		add_installation_history(
			installation,
			"COMMUNICATIONS",
			"Follow-up superseded by Critical incident",
			"The continuing matter associated with [installation.active_followup_origin_title] was superseded when the installation entered CRITICAL status."
		)
		clear_installation_followup(installation)
		return

	installation.followup_chain_step = step

	var/origin_title = installation.active_followup_origin_title
	var/start_status = installation.active_followup_start_status
	var/current_severity = get_installation_status_severity(installation.status)
	var/start_severity = get_installation_status_severity(start_status)
	var/followup_title
	var/followup_body
	var/followup_priority = CCPOST_PRIORITY_ROUTINE
	var/chain_complete = FALSE

	if(is_installation_green(installation))
		followup_title = "Resolution Follow-Up - [origin_title]"
		followup_body = get_installation_followup_body(installation, origin_title, "RESOLVED")
		chain_complete = TRUE
	else if(current_severity > start_severity)
		followup_title = "Escalation Follow-Up - [origin_title]"
		followup_body = get_installation_followup_body(installation, origin_title, "ESCALATED")
		followup_priority = CCPOST_PRIORITY_PRIORITY
	else if(step >= 2)
		followup_title = "Continuing Follow-Up - [origin_title]"
		followup_body = get_installation_followup_body(installation, origin_title, "CONTINUING_FINAL")
		chain_complete = TRUE
	else
		followup_title = "Continuing Follow-Up - [origin_title]"
		followup_body = get_installation_followup_body(installation, origin_title, "CONTINUING")

	var/datum/ccpost_sector_message/followup_message = create_dynamic_sector_message(
		installation,
		"installation_followup_[installation.installation_code]_[step]",
		CCPOST_MESSAGE_UPDATE,
		followup_priority,
		followup_title,
		followup_body
	)

	if(followup_message)
		notify_comms_terminals(followup_message)

	add_installation_history(
		installation,
		"COMMUNICATIONS",
		followup_title,
		followup_body
	)

	if(chain_complete)
		clear_installation_followup(installation)
		return

	addtimer(CALLBACK(src, PROC_REF(issue_installation_followup), installation.installation_code, origin_message_code, 2), rand(3 MINUTES, 5 MINUTES), TIMER_STOPPABLE)


// AID DENIAL CONSEQUENCES

/// Returns the escalation-risk penalty created by denying an installation's
/// Operational Allocation request. Green requests carry only a small future
/// risk, while refusing support to an already failing installation is a much
/// more serious gamble.
/datum/ccpost_sector_network/proc/get_aid_denial_risk(datum/ccpost_sector_installation/installation)
	if(!installation || installation.destroyed)
		return 0

	// Denials now carry substantially more operational weight. The value is
	// both added to later CRITICAL escalation rolls and used to bias ordinary
	// status updates toward deterioration.
	switch(installation.status)
		if(CCPOST_INSTALLATION_ONLINE, CCPOST_INSTALLATION_ROUTINE)
			return 6
		if(CCPOST_INSTALLATION_MAINTENANCE, CCPOST_INSTALLATION_UNDER_REVIEW)
			return 10
		if(CCPOST_INSTALLATION_COMMS_DEGRADED)
			return 16
		if(CCPOST_INSTALLATION_NO_CONTACT)
			return 22
		if(CCPOST_INSTALLATION_OFFLINE)
			return 28
		if(CCPOST_INSTALLATION_CRITICAL)
			return 30

	return 0


/// Percentage chance that an unresolved denial penalty forces an ordinary
/// installation update to move in a worse direction instead of using the
/// normal mixed recovery/deterioration table.
/datum/ccpost_sector_network/proc/get_aid_denial_worsening_chance(datum/ccpost_sector_installation/installation)
	if(!installation || installation.destroyed || installation.aid_denial_risk <= 0)
		return 0

	return min(75, installation.aid_denial_risk * 2)


/// Picks an explicitly worse non-CRITICAL state. OFFLINE has no lower ordinary
/// state, so its denial pressure is represented by its increased CRITICAL roll.
/datum/ccpost_sector_network/proc/get_denial_worsened_status(datum/ccpost_sector_installation/installation)
	if(!installation || installation.destroyed)
		return null

	switch(installation.status)
		if(CCPOST_INSTALLATION_ONLINE, CCPOST_INSTALLATION_ROUTINE)
			return pick(CCPOST_INSTALLATION_MAINTENANCE, CCPOST_INSTALLATION_MAINTENANCE, CCPOST_INSTALLATION_UNDER_REVIEW, CCPOST_INSTALLATION_COMMS_DEGRADED)

		if(CCPOST_INSTALLATION_MAINTENANCE)
			return pick(CCPOST_INSTALLATION_COMMS_DEGRADED, CCPOST_INSTALLATION_COMMS_DEGRADED, CCPOST_INSTALLATION_NO_CONTACT)

		if(CCPOST_INSTALLATION_UNDER_REVIEW)
			return pick(CCPOST_INSTALLATION_MAINTENANCE, CCPOST_INSTALLATION_COMMS_DEGRADED, CCPOST_INSTALLATION_NO_CONTACT)

		if(CCPOST_INSTALLATION_COMMS_DEGRADED)
			return pick(CCPOST_INSTALLATION_NO_CONTACT, CCPOST_INSTALLATION_NO_CONTACT, CCPOST_INSTALLATION_OFFLINE)

		if(CCPOST_INSTALLATION_NO_CONTACT)
			return CCPOST_INSTALLATION_OFFLINE

	return null


/// Records the mechanical and narrative consequences of refusing an
/// installation's request for Operational Allocation. No immediate status
/// damage is inflicted; instead the denied installation becomes more likely to
/// deteriorate during later sector simulation cycles.
/datum/ccpost_sector_network/proc/register_aid_denial(
	datum/ccpost_sector_installation/installation,
	datum/ccpost_sector_message/message,
	mob/denying_user
)
	if(!installation || installation.destroyed || !message)
		return

	if(message.allocation_cost <= 0)
		return

	var/added_risk = get_aid_denial_risk(installation)

	installation.aid_denial_risk = min(45, installation.aid_denial_risk + added_risk)
	installation.aid_denial_count++
	installation.last_aid_denial_at = station_time_timestamp()
	installation.last_aid_denial_by = denying_user ? denying_user.name : "UNKNOWN"

	// Track an explicit denial made during the current Critical incident so
	// later recovery/loss reports can distinguish it from older denial risk.
	if(installation.status == CCPOST_INSTALLATION_CRITICAL && (CCPOST_INSTALLATION_CRITICAL in message.valid_statuses))
		installation.critical_aid_denied = TRUE
		installation.critical_aid_denied_by = denying_user ? denying_user.name : "UNKNOWN"
		installation.critical_aid_denied_at = station_time_timestamp()

	if(added_risk > 0)
		installation.condition_details += " A recent request for external operational support was denied; local recovery capacity is reduced."
		notify_registered_displays()

	schedule_denial_followup(installation, message)


/// Schedules a short acknowledgement from the same named installation contact.
/// The follow-up is informational only and does not create another spending
/// decision.
/datum/ccpost_sector_network/proc/schedule_denial_followup(
	datum/ccpost_sector_installation/installation,
	datum/ccpost_sector_message/message
)
	if(!installation || !message)
		return

	addtimer(CALLBACK(src, PROC_REF(issue_denial_followup), installation.installation_code, message.title, installation.status), rand(2 MINUTES, 4 MINUTES), TIMER_STOPPABLE)


/datum/ccpost_sector_network/proc/get_denial_followup_body(
	datum/ccpost_sector_installation/installation,
	request_title,
	denied_status
)
	if(!installation)
		return "Assistance denial received. Local personnel will continue without the requested support."

	var/base_body

	if(is_installation_green(installation))
		base_body = pick("We managed to stabilize the problem locally. The refusal and additional maintenance burden have been logged for the next shift.", "Local staff have brought the installation back within normal parameters. The deferred work has not disappeared.", "We recovered without the allocation this time. The original request remains attached to our maintenance record in case the same fault returns.")
	else if(denied_status == CCPOST_INSTALLATION_CRITICAL || installation.status == CCPOST_INSTALLATION_CRITICAL)
		base_body = pick("We are proceeding without the requested emergency allocation. Personnel are being moved onto survival priorities and anything we cannot keep running safely is being abandoned.", "Emergency support is not coming. We will use what remains on-site and concentrate on keeping the installation intact long enough for the next response window.", "No additional allocation has been authorized. Nonessential systems are being cut now and the duty staff are working with what remains.")
	else if(denied_status == CCPOST_INSTALLATION_NO_CONTACT || denied_status == CCPOST_INSTALLATION_OFFLINE || installation.status == CCPOST_INSTALLATION_NO_CONTACT || installation.status == CCPOST_INSTALLATION_OFFLINE)
		base_body = pick("We are staying on emergency procedures and local reserves. I cannot promise the next transmission will make it out if the remaining systems continue to degrade.", "The remaining staff are keeping essential systems alive manually; anything beyond that is being deferred.", "The team has been told to conserve spares and power until we either recover locally or lose the link again.")
	else if(denied_status == CCPOST_INSTALLATION_COMMS_DEGRADED || installation.status == CCPOST_INSTALLATION_COMMS_DEGRADED)
		base_body = pick("We will stretch the remaining hardware and continue local repairs. If telemetry drops further, the original request should explain why.", "The degraded systems will remain in service and we will attempt to keep the temporary fixes alive under load.", "We will work around the fault without outside support. The affected systems are now marked as operating without normal redundancy.")
	else
		base_body = pick("We will continue with local maintenance and existing reserves. External assistance was requested and declined.", "We will defer the requested work and keep the installation operating with what we have on hand.", "No additional allocation has been authorized. Local staff will continue the repair effort and adjust operations as necessary.")

	var/relationship = get_installation_trust_label(installation)

	switch(relationship)
		if("TRUSTED")
			return "I wanted to answer you directly rather than leave this to the automated record. The denial regarding '[request_title]' came through. [base_body] We'll keep your office informed if the situation materially changes."
		if("COOPERATIVE")
			return "Your response regarding '[request_title]' was received. [base_body] We will forward another update if circumstances change."
		if("GUARDED")
			return "Decision logged regarding '[request_title]'. [base_body] Further correspondence will be limited to operationally relevant changes."
		if("STRAINED")
			return "For mandatory record, Liaison denial of '[request_title]' has been logged. [base_body] Local personnel will proceed without assuming further discretionary support."

	return "Denial received regarding '[request_title]'. [base_body]"


/datum/ccpost_sector_network/proc/issue_denial_followup(installation_code, request_title, denied_status)
	var/datum/ccpost_sector_installation/installation = get_installation_by_code(installation_code)

	if(!installation || installation.destroyed)
		return

	var/followup_priority = CCPOST_PRIORITY_ROUTINE

	// Match the follow-up priority to the installation's condition when the
	// response is actually sent. A denial made during a lesser incident can
	// therefore become a Priority or Important transmission if conditions worsen.
	if(is_installation_green(installation))
		followup_priority = CCPOST_PRIORITY_ROUTINE

	else if(denied_status == CCPOST_INSTALLATION_CRITICAL || installation.status == CCPOST_INSTALLATION_CRITICAL)
		followup_priority = CCPOST_PRIORITY_IMPORTANT

	else if(denied_status == CCPOST_INSTALLATION_NO_CONTACT || denied_status == CCPOST_INSTALLATION_OFFLINE || denied_status == CCPOST_INSTALLATION_COMMS_DEGRADED || installation.status == CCPOST_INSTALLATION_NO_CONTACT || installation.status == CCPOST_INSTALLATION_OFFLINE || installation.status == CCPOST_INSTALLATION_COMMS_DEGRADED)
		followup_priority = CCPOST_PRIORITY_PRIORITY

	var/datum/ccpost_sector_message/followup_message = create_dynamic_sector_message(
		installation,
		"aid_denial_followup",
		CCPOST_MESSAGE_UPDATE,
		followup_priority,
		"Assistance Denial Acknowledged",
		get_denial_followup_body(installation, request_title, denied_status)
	)

	if(followup_message)
		notify_comms_terminals(followup_message)


/datum/ccpost_sector_network/proc/get_installation_aid_request_chance(datum/ccpost_sector_installation/installation)
	if(!installation || installation.destroyed)
		return 0

	switch(installation.status)
		if(CCPOST_INSTALLATION_MAINTENANCE)
			return 35

		if(CCPOST_INSTALLATION_UNDER_REVIEW)
			return 25

		if(CCPOST_INSTALLATION_COMMS_DEGRADED)
			return 55

		if(CCPOST_INSTALLATION_NO_CONTACT)
			// Represents a buffered or emergency-burst transmission that was
			// queued immediately before normal contact was lost.
			return 40

		if(CCPOST_INSTALLATION_OFFLINE)
			return 70

		if(CCPOST_INSTALLATION_CRITICAL)
			return 90

	return 0


/datum/ccpost_sector_network/proc/maybe_issue_installation_aid_request(datum/ccpost_sector_installation/installation)
	if(!installation || installation.destroyed)
		return FALSE

	if(is_installation_green(installation))
		return FALSE

	if(has_pending_sector_request_for_installation(installation.installation_code))
		return FALSE

	var/aid_chance = get_installation_aid_request_chance(installation)

	if(aid_chance <= 0 || !prob(aid_chance))
		return FALSE

	var/list/eligible_aid_templates = list()

	for(var/datum/ccpost_sector_message_template/template as anything in sector_message_templates)
		if(!template.reactive_aid)
			continue

		if(template.installation_code != installation.installation_code)
			continue

		if(has_pending_sector_message_template(template.template_id))
			continue

		var/list/required_statuses = template.required_statuses

		if(length(required_statuses))
			if(!(installation.status in required_statuses))
				continue

		eligible_aid_templates += list(template)

	if(!length(eligible_aid_templates))
		return FALSE

	var/datum/ccpost_sector_message_template/chosen_template = pick(eligible_aid_templates)
	var/datum/ccpost_sector_message/new_message = create_sector_message(installation, chosen_template)

	if(!new_message)
		return FALSE

	notify_comms_terminals(new_message)

	return TRUE


/datum/ccpost_sector_network/proc/create_sector_message(
	datum/ccpost_sector_installation/installation,
	datum/ccpost_sector_message_template/template
)
	if(!installation || !template)
		return null

	var/message_code = "CC-SC-[next_sector_message_number]"
	next_sector_message_number++

	var/body_override
	if(installation.status == CCPOST_INSTALLATION_CRITICAL && template.reactive_aid && (CCPOST_INSTALLATION_CRITICAL in template.required_statuses))
		body_override = get_critical_aid_request_body(installation)

	var/datum/ccpost_sector_message/new_message = new(
		message_code,
		installation,
		template,
		body_override
	)

	sector_messages.Insert(1, new_message)

	if(length(sector_messages) > max_sector_messages)
		var/removal_index = 0

		// Preserve unresolved transmissions. Remove the oldest resolved
		// message instead so an unanswered request is never silently lost.
		for(var/index in 1 to length(sector_messages))
			var/datum/ccpost_sector_message/archive_message = sector_messages[index]

			if(QDELETED(archive_message))
				continue

			if(archive_message.resolution_status != CCPOST_MESSAGE_PENDING)
				removal_index = index

		if(removal_index)
			var/datum/ccpost_sector_message/oldest_resolved_message = sector_messages[removal_index]
			sector_messages.Cut(removal_index, removal_index + 1)
			qdel(oldest_resolved_message)

	if(installation.status != CCPOST_INSTALLATION_NO_CONTACT && installation.status != CCPOST_INSTALLATION_OFFLINE)
		record_installation_contact(installation)

	return new_message


/datum/ccpost_sector_network/proc/create_dynamic_sector_message(
	datum/ccpost_sector_installation/installation,
	template_id,
	message_type,
	priority,
	title,
	body,
	list/required_statuses
)
	if(!installation)
		return null

	var/datum/ccpost_sector_message_template/template = new(
		template_id,
		installation.installation_code,
		message_type,
		priority,
		title,
		body,
		required_statuses
	)

	var/datum/ccpost_sector_message/message = create_sector_message(installation, template)
	qdel(template)
	return message


/datum/ccpost_sector_network/proc/issue_sector_message()
	sector_message_timer = null

	var/list/eligible_templates = get_eligible_sector_message_templates()

	if(!length(eligible_templates))
		schedule_next_sector_message()
		return

	// Select the installation first so installations with larger template pools
	// do not receive proportionally more airtime than their neighbors.
	var/list/installation_candidates = list()

	for(var/datum/ccpost_sector_message_template/template as anything in eligible_templates)
		var/datum/ccpost_sector_installation/installation = get_installation_by_code(
			template.installation_code
		)

		if(!installation || installation.destroyed)
			continue

		installation_candidates |= installation

	if(!length(installation_candidates))
		schedule_next_sector_message()
		return

	var/list/fresh_installations = list()

	for(var/datum/ccpost_sector_installation/installation as anything in installation_candidates)
		if(installation.installation_code in recent_sector_message_installation_codes)
			continue

		fresh_installations += installation

	if(length(fresh_installations))
		installation_candidates = fresh_installations
	else if(length(installation_candidates) > 1 && last_sector_message_installation_code)
		for(var/datum/ccpost_sector_installation/installation as anything in installation_candidates)
			if(installation.installation_code != last_sector_message_installation_code)
				continue

			installation_candidates.Remove(installation)
			break

	var/datum/ccpost_sector_installation/chosen_installation = pick(installation_candidates)
	var/list/template_candidates = list()

	for(var/datum/ccpost_sector_message_template/template as anything in eligible_templates)
		if(template.installation_code != chosen_installation.installation_code)
			continue

		template_candidates += list(template)

	if(!length(template_candidates))
		schedule_next_sector_message()
		return

	// Once an installation has been selected, prefer one of its templates which
	// has not appeared in the recent rolling template history.
	var/list/fresh_templates = list()

	for(var/datum/ccpost_sector_message_template/template as anything in template_candidates)
		if(template.template_id in recent_sector_message_template_ids)
			continue

		fresh_templates += list(template)

	if(length(fresh_templates))
		template_candidates = fresh_templates
	else if(length(template_candidates) > 1 && last_sector_message_template_id)
		for(var/datum/ccpost_sector_message_template/template as anything in template_candidates)
			if(template.template_id != last_sector_message_template_id)
				continue

			template_candidates.Remove(template)
			break

	var/datum/ccpost_sector_message_template/chosen_template = pick(template_candidates)
	var/chosen_template_id = chosen_template.template_id
	var/chosen_installation_code = chosen_installation.installation_code

	last_sector_message_template_id = chosen_template_id
	last_sector_message_installation_code = chosen_installation_code

	recent_sector_message_template_ids.Insert(1, chosen_template_id)
	recent_sector_message_installation_codes.Insert(1, chosen_installation_code)

	if(length(recent_sector_message_template_ids) > max_recent_sector_message_templates)
		recent_sector_message_template_ids.Cut(max_recent_sector_message_templates + 1)

	if(length(recent_sector_message_installation_codes) > max_recent_sector_message_installations)
		recent_sector_message_installation_codes.Cut(max_recent_sector_message_installations + 1)

	var/datum/ccpost_sector_message/new_message = create_sector_message(
		chosen_installation,
		chosen_template
	)

	notify_comms_terminals(new_message)
	maybe_start_installation_followup(new_message)

	schedule_next_sector_message()

/datum/ccpost_sector_network/proc/find_sector_message(message_code)
	if(!message_code)
		return null

	for(var/datum/ccpost_sector_message/message as anything in sector_messages)
		if(QDELETED(message))
			continue

		if(message.message_code == message_code)
			return message

	return null


/datum/ccpost_sector_network/proc/sector_message_still_valid(
	datum/ccpost_sector_message/message
)
	if(!message)
		return FALSE

	var/datum/ccpost_sector_installation/installation = get_installation_by_code(
		message.installation_code
	)

	if(!installation || installation.destroyed)
		return FALSE

	if(length(message.valid_statuses))
		if(!(installation.status in message.valid_statuses))
			return FALSE

	return TRUE


/// Returns the installation-specific acknowledgement recorded after a Liaison
/// authorizes or denies Operational Allocation.
/datum/ccpost_sector_network/proc/get_aid_decision_response(
	datum/ccpost_sector_installation/installation,
	authorized = TRUE,
	critical = FALSE
)
	var/datum/ccpost_installation_response_profile/profile = installation?.response_profile

	if(!profile)
		if(authorized)
			return critical ? "Emergency assistance authorized. Installation remains CRITICAL pending incident resolution." : "Requested operational assistance authorized."

		return critical ? "Emergency assistance denied. Local personnel remain responsible for containment." : "Requested operational assistance denied."

	if(authorized)
		if(critical && profile.critical_authorized_response)
			return profile.critical_authorized_response

		return profile.authorized_response

	if(critical && profile.critical_denied_response)
		return profile.critical_denied_response

	return profile.denied_response


/datum/ccpost_sector_network/proc/apply_authorized_sector_request(
	datum/ccpost_sector_message/message
)
	if(!message)
		return FALSE

	var/datum/ccpost_sector_installation/installation = get_installation_by_code(
		message.installation_code
	)

	if(!installation || installation.destroyed)
		return FALSE

	// Once assistance is actually authorized, the unresolved risk created by
	// previous refusals is considered addressed. Historical denial count remains.
	installation.aid_denial_risk = 0

	var/critical_aid = installation.status == CCPOST_INSTALLATION_CRITICAL && (CCPOST_INSTALLATION_CRITICAL in message.valid_statuses)
	message.response = get_aid_decision_response(installation, TRUE, critical_aid)

	// Critical assistance is support, not an instant resolution. The installation
	// remains CRITICAL and the original incident stays active until the later
	// Critical recovery roll determines whether the installation survives.
	if(critical_aid)
		installation.critical_aid_authorized = TRUE
		installation.critical_aid_authorized_by = message.responded_by
		installation.critical_aid_authorized_at = station_time_timestamp()
		installation.critical_aid_denied = FALSE
		installation.critical_aid_denied_by = null
		installation.critical_aid_denied_at = null

		if(installation.ert_dispatched)
			installation.response_status = "ERT + LIAISON AID"
		else
			installation.response_status = "LIAISON AID AUTHORIZED"

		var/critical_aid_details = get_critical_aid_authorization_details(installation)

		if(critical_aid_details)
			installation.condition_details = "[critical_aid_details] The wider critical incident remains unresolved."
		else if(message.success_details)
			installation.condition_details = "[message.success_details] The wider critical incident remains unresolved."
		else
			installation.condition_details = "Emergency Central Command resources have been authorized. The wider critical incident remains unresolved."

		if(installation.ert_dispatched)
			installation.condition_details += " Emergency Response Team operations are also active."
		else
			installation.condition_details += " Local personnel remain responsible for containing the incident."


		notify_registered_displays(
			null,
			FALSE,
			30,
			"chimes. Emergency Liaison assistance has been authorized for a critical sector installation."
		)

		return TRUE

	// Non-Critical assistance retains its existing immediate operational effect.
	if(message.success_status)
		installation.status = message.success_status
		installation.status_since = station_time_timestamp()

		apply_installation_status_metadata(installation)

	if(message.success_details)
		installation.condition_details = message.success_details

	validate_active_sector_paperwork()

	// A post-Critical incident remains on the record until the installation
	// actually returns to green operation, even if later routine aid is approved.
	if(installation.critical_aftermath_active)
		if(is_installation_green(installation))
			clear_critical_aftermath(installation)
	else
		installation.incident_summary = "No active incident."

	notify_registered_displays(
		null,
		FALSE,
		25,
		"chimes. Sector installation telemetry has been updated following Liaison authorization."
	)

	return TRUE

// SECTOR COMMUNICATIONS ARCHIVE MANAGEMENT

/// Removes resolved communications while preserving every unresolved inbox
/// transmission. Returns the number of archived records cleared.
/datum/ccpost_sector_network/proc/clear_resolved_sector_messages()
	var/cleared_count = 0
	var/index = length(sector_messages)

	while(index >= 1)
		var/datum/ccpost_sector_message/message = sector_messages[index]

		if(QDELETED(message))
			sector_messages.Cut(index, index + 1)
			index--
			continue

		if(message.resolution_status != CCPOST_MESSAGE_PENDING)
			sector_messages.Cut(index, index + 1)
			qdel(message)
			cleared_count++

		index--

	refresh_comms_terminals()

	return cleared_count


// CENTRAL COMMAND SECTOR COMMUNICATIONS TERMINAL CIRCUIT BOARD

/obj/item/circuitboard/computer/ccpost_sector_comms
	name = "Central Command Sector Communications Terminal"
	greyscale_colors = CIRCUIT_COLOR_COMMAND
	build_path = /obj/machinery/computer/ccpost_sector_comms


// CENTRAL COMMAND SECTOR COMMUNICATIONS TERMINAL

/obj/machinery/computer/ccpost_sector_comms
	name = "Central Command sector communications terminal"
	desc = "A secure Central Command terminal used to receive and respond to authenticated communications and administrative paperwork from remote Nanotrasen installations."

	icon_screen = "comm_logs"
	icon_keyboard = "tech_key"
	light_color = LIGHT_COLOR_GREEN

	circuit = /obj/item/circuitboard/computer/ccpost_sector_comms

	/// Single physical slot used for the one active administrative document.
	var/obj/item/paper/ccpost_sector_paperwork/submitted_paperwork

	COOLDOWN_DECLARE(paperwork_print_cooldown)


/obj/machinery/computer/ccpost_sector_comms/Initialize(mapload)
	. = ..()

	GLOB.ccpost_sector_network.register_comms_terminal(src)


/obj/machinery/computer/ccpost_sector_comms/Destroy()
	if(submitted_paperwork)
		eject_sector_paperwork()

	GLOB.ccpost_sector_network.unregister_comms_terminal(src)

	return ..()



// ADMINISTRATIVE PAPERWORK SLOT

/obj/machinery/computer/ccpost_sector_comms/examine(mob/user)
	. = ..()

	var/datum/ccpost_sector_network/network = GLOB.ccpost_sector_network

	if(!network)
		return

	network.ensure_started()

	var/pending_messages = network.get_pending_sector_message_count()
	var/paperwork_pending = network.validate_active_sector_paperwork(FALSE) ? 1 : 0
	var/unresolved_work = pending_messages + paperwork_pending
	var/communication_label = pending_messages == 1 ? "communication" : "communications"
	var/paperwork_label = paperwork_pending ? "one active administrative document" : "no active administrative paperwork"

	if(unresolved_work)
		. += span_notice("Unresolved sector work: [pending_messages] pending [communication_label] and [paperwork_label].")
	else
		. += span_notice("No unresolved Sector Communications work is currently recorded.")


/obj/machinery/computer/ccpost_sector_comms/item_interaction(
	mob/living/user,
	obj/item/tool,
	list/modifiers
)
	if(!istype(tool, /obj/item/paper/ccpost_sector_paperwork))
		return NONE

	var/obj/item/paper/ccpost_sector_paperwork/paperwork = tool

	if(paperwork.voided)
		balloon_alert(user, "document is void")
		return ITEM_INTERACT_BLOCKING

	if(!GLOB.ccpost_sector_network.validate_active_sector_paperwork())
		balloon_alert(user, "no active paperwork request")
		return ITEM_INTERACT_BLOCKING

	var/datum/ccpost_sector_paperwork_request/request = GLOB.ccpost_sector_network.active_sector_paperwork

	if(!request || request.status != CCPOST_PAPERWORK_AWAITING_REVIEW)
		balloon_alert(user, "document no longer accepted")
		return ITEM_INTERACT_BLOCKING

	if(paperwork.paperwork_code != request.paperwork_code)
		balloon_alert(user, "document does not match active request")
		return ITEM_INTERACT_BLOCKING

	if(submitted_paperwork)
		balloon_alert(user, "document slot occupied")
		return ITEM_INTERACT_BLOCKING

	if(!user.transferItemToLoc(paperwork, src))
		balloon_alert(user, "unable to insert document")
		return ITEM_INTERACT_BLOCKING

	submitted_paperwork = paperwork

	playsound(src, 'sound/machines/terminal_alert.ogg', vol = 20, vary = TRUE)
	balloon_alert(user, "document inserted")
	SStgui.update_uis(src)

	return ITEM_INTERACT_SUCCESS


/obj/machinery/computer/ccpost_sector_comms/proc/eject_sector_paperwork(mob/living/user)
	if(!submitted_paperwork)
		return FALSE

	var/obj/item/paper/ccpost_sector_paperwork/ejected_paperwork = submitted_paperwork
	submitted_paperwork = null

	ejected_paperwork.forceMove(drop_location())

	if(user)
		user.put_in_hands(ejected_paperwork)

	SStgui.update_uis(src)
	return TRUE


/obj/machinery/computer/ccpost_sector_comms/proc/paperwork_has_centcom_stamp(obj/item/paper/ccpost_sector_paperwork/paperwork)
	if(!paperwork)
		return FALSE

	var/datum/asset/spritesheet/sheet = get_asset_datum(
		/datum/asset/spritesheet/simple/paper
	)

	var/centcom_stamp_class = sheet.icon_class_name("stamp-centcom")

	for(var/datum/paper_stamp/stamp as anything in paperwork.raw_stamp_data)
		if(stamp.class == centcom_stamp_class)
			return TRUE

	return FALSE


/obj/machinery/computer/ccpost_sector_comms/proc/build_sector_paperwork_print_text(datum/ccpost_sector_paperwork_request/request)
	if(!request)
		return ""

	var/print_text = "<center><b>[request.installation_name]</b></center><br>"
	print_text += "<center><small><i>Authenticated Sector Administrative Document</i></small></center><hr><hr><small>"
	print_text += "<b>Reference:</b> [request.paperwork_code]<br>"
	print_text += "<b>Installation:</b> [request.installation_name] ([request.installation_code])<br>"
	print_text += "<b>Sender:</b> [request.sender_role] [request.sender_name]<br>"
	print_text += "<b>Type:</b> ADMINISTRATIVE DOCUMENT<br>"
	print_text += "<b>Priority:</b> [request.priority]<br>"
	print_text += "<b>Issued:</b> [request.issued_at]<br>"
	print_text += "<hr><br>"
	print_text += "<b>[request.title]</b><br><br>"
	print_text += "[request.body]<br><br>"
	print_text += "<hr>"
	print_text += "<b>Required Action:</b> Review this document, apply an official Central Command authorization stamp, and return it through the Sector Communications Terminal.<br><br>"
	print_text += "<i>Machine reference: [request.paperwork_code]</i></small>"

	return print_text


/obj/machinery/computer/ccpost_sector_comms/proc/print_sector_paperwork(datum/ccpost_sector_paperwork_request/request)
	if(!request || request.status != CCPOST_PAPERWORK_AWAITING_REVIEW)
		return FALSE

	var/obj/item/paper/ccpost_sector_paperwork/paperwork = new /obj/item/paper/ccpost_sector_paperwork(
		drop_location()
	)

	paperwork.paperwork_code = request.paperwork_code
	paperwork.name = "administrative document [request.paperwork_code]"
	paperwork.add_raw_text(build_sector_paperwork_print_text(request))
	paperwork.update_appearance()
	request.register_physical_copy(paperwork)

	playsound(src, 'sound/machines/printer.ogg', vol = 50, vary = FALSE)
	visible_message(span_notice("[src] prints an incoming sector administrative document."))

	return TRUE


/obj/machinery/computer/ccpost_sector_comms/proc/paperwork_to_ui_data()
	if(!GLOB.ccpost_sector_network.validate_active_sector_paperwork(FALSE))
		return null

	var/datum/ccpost_sector_paperwork_request/request = GLOB.ccpost_sector_network.active_sector_paperwork

	if(!request)
		return null

	var/datum/ccpost_sector_installation/installation = GLOB.ccpost_sector_network.get_installation_by_code(
		request.installation_code
	)

	if(!GLOB.ccpost_sector_network.can_issue_sector_paperwork(installation))
		return null

	return list(
		"paperwork_code" = request.paperwork_code,
		"installation_code" = request.installation_code,
		"installation_name" = request.installation_name,
		"installation_status" = installation.status,
		"installation_trust_label" = GLOB.ccpost_sector_network.get_installation_trust_label(installation),
		"sender_name" = request.sender_name,
		"sender_role" = request.sender_role,
		"type" = "ADMINISTRATIVE DOCUMENT",
		"priority" = request.priority,
		"title" = request.title,
		"body" = request.body,
		"issued_at" = request.issued_at,
		"status" = request.status,
		"submitted_by" = request.submitted_by,
		"submitted_at" = request.submitted_at,
		"allocation_reward" = request.allocation_reward,
		"document_inserted" = submitted_paperwork ? TRUE : FALSE,
		"document_name" = submitted_paperwork?.name,
		"stamp_verified" = paperwork_has_centcom_stamp(submitted_paperwork)
	)


/obj/machinery/computer/ccpost_sector_comms/ui_interact(
	mob/user,
	datum/tgui/ui
)
	. = ..()

	ui = SStgui.try_update_ui(user, src, ui)

	if(!ui)
		ui = new(
			user,
			src,
			"CCPostSectorComms",
			name
		)

		ui.open()


/// Builds a printable Central Command record for a single communication.
/obj/machinery/computer/ccpost_sector_comms/proc/build_sector_message_print_text(datum/ccpost_sector_message/message)
	if(!message)
		return ""

	var/response_text = "No recorded response."
	var/responded_by = "N/A"
	var/responded_at = "N/A"

	if(message.response)
		response_text = message.response

	if(message.responded_by)
		responded_by = message.responded_by

	if(message.responded_at)
		responded_at = message.responded_at

	var/print_text = "<center><b>Central Command Sector Communications Record</b></center><br>"
	print_text += "<hr>"
	print_text += "<b>Reference:</b> [message.message_code]<br>"
	print_text += "<b>Installation:</b> [message.installation_name] ([message.installation_code])<br>"
	print_text += "<b>Sender:</b> [message.sender_role] [message.sender_name]<br>"
	print_text += "<b>Type:</b> [message.message_type]<br>"
	print_text += "<b>Priority:</b> [message.priority]<br>"
	print_text += "<b>Issued:</b> [message.issued_at]<br>"
	print_text += "<b>Resolution:</b> [message.resolution_status]<br>"
	print_text += "<b>Responded By:</b> [responded_by]<br>"
	print_text += "<b>Responded At:</b> [responded_at]<br>"

	if(message.allocation_cost > 0)
		print_text += "<b>Requested Allocation:</b> [message.allocation_cost] CU<br>"

	if(message.allocation_reward > 0)
		print_text += "<b>Offered Transfer:</b> [message.allocation_reward] CU<br>"

	if(message.allocation_change)
		print_text += "<b>Recorded Liaison Allocation Change:</b> [message.allocation_change] CU<br>"

	print_text += "<hr>"
	print_text += "<b>[message.title]</b><br><br>"
	print_text += "[message.body]<br><br>"
	print_text += "<hr>"
	print_text += "<b>Recorded Response:</b> [response_text]<br>"
	print_text += "<hr>"
	print_text += "<small><i>Central Command Sector Liaison Communications Archive</i></small>"

	return print_text


/obj/machinery/computer/ccpost_sector_comms/proc/print_sector_message_record(datum/ccpost_sector_message/message)
	if(!message || message.resolution_status == CCPOST_MESSAGE_PENDING)
		return FALSE

	var/obj/item/paper/record = new /obj/item/paper(get_turf(src))
	record.name = "sector communication [message.message_code]"
	record.add_raw_text(build_sector_message_print_text(message))
	record.update_appearance()

	playsound(src, 'sound/machines/printer.ogg', vol = 50, vary = FALSE)
	visible_message(span_notice("[src] prints a Central Command sector communications record."))

	return TRUE


/// Prints the entire resolved communications archive in manageable batches.
/obj/machinery/computer/ccpost_sector_comms/proc/print_sector_archive()
	var/list/archive_messages = list()

	for(var/datum/ccpost_sector_message/message as anything in GLOB.ccpost_sector_network.sector_messages)
		if(QDELETED(message) || message.resolution_status == CCPOST_MESSAGE_PENDING)
			continue

		archive_messages += message

	if(!length(archive_messages))
		return 0

	var/messages_per_page = 10
	var/page_number = 1
	var/page_message_count = 0
	var/page_text = "<center><b>Central Command Sector Communications Archive</b></center><br><hr>"
	var/printed_pages = 0

	for(var/datum/ccpost_sector_message/message as anything in archive_messages)
		if(page_message_count >= messages_per_page)
			var/obj/item/paper/archive_page = new /obj/item/paper(get_turf(src))
			archive_page.name = "sector communications archive page [page_number]"
			archive_page.add_raw_text(page_text)
			archive_page.update_appearance()

			printed_pages++
			page_number++
			page_message_count = 0
			page_text = "<center><b>Central Command Sector Communications Archive</b></center><br><hr>"

		page_text += build_sector_message_print_text(message)
		page_text += "<br><br>"
		page_message_count++

	if(page_message_count > 0)
		var/obj/item/paper/final_archive_page = new /obj/item/paper(get_turf(src))
		final_archive_page.name = "sector communications archive page [page_number]"
		final_archive_page.add_raw_text(page_text)
		final_archive_page.update_appearance()
		printed_pages++

	if(printed_pages > 0)
		playsound(src, 'sound/machines/printer.ogg', vol = 50, vary = FALSE)
		visible_message(span_notice("[src] prints a Central Command sector communications archive."))

	return printed_pages


/obj/machinery/computer/ccpost_sector_comms/proc/message_to_ui_data(
	datum/ccpost_sector_message/message
)
	if(!message)
		return null

	var/datum/ccpost_sector_installation/installation = GLOB.ccpost_sector_network.get_installation_by_code(
		message.installation_code
	)

	var/current_status = "UNKNOWN"
	var/current_trust_label = "UNKNOWN"

	if(installation)
		current_status = installation.status
		current_trust_label = GLOB.ccpost_sector_network.get_installation_trust_label(installation)

	return list(
		"message_code" = message.message_code,
		"installation_code" = message.installation_code,
		"installation_name" = message.installation_name,
		"installation_status" = current_status,
		"installation_trust_label" = current_trust_label,

		"sender_name" = message.sender_name,
		"sender_role" = message.sender_role,

		"message_type" = message.message_type,
		"priority" = message.priority,
		"title" = message.title,
		"body" = message.body,
		"issued_at" = message.issued_at,

		"resolution_status" = message.resolution_status,

		"responded_by" = message.responded_by,
		"responded_at" = message.responded_at,
		"response" = message.response,

		"allocation_cost" = message.allocation_cost,
		"allocation_reward" = message.allocation_reward,
		"allocation_change" = message.allocation_change
	)


/obj/machinery/computer/ccpost_sector_comms/ui_data(mob/user)
	GLOB.ccpost_sector_network.ensure_started()

	var/list/data = list()

	var/datum/ccpost_logistics_network/logistics_network = GLOB.ccpost_logistics_network

	if(logistics_network)
		data["allocation"] = logistics_network.allocation
		data["available_allocation"] = logistics_network.get_available_allocation()
		data["max_allocation"] = logistics_network.max_allocation

	else
		data["allocation"] = 0
		data["available_allocation"] = 0
		data["max_allocation"] = 0

	var/list/inbox_data = list()
	var/list/archive_data = list()

	for(var/datum/ccpost_sector_message/message as anything in GLOB.ccpost_sector_network.sector_messages)
		if(QDELETED(message))
			continue

		var/list/message_data = message_to_ui_data(message)

		if(message.resolution_status == CCPOST_MESSAGE_PENDING)
			inbox_data += list(message_data)

		else
			archive_data += list(message_data)

	var/list/paperwork_data = paperwork_to_ui_data()
	var/pending_count = length(inbox_data)
	var/paperwork_pending = paperwork_data ? TRUE : FALSE

	data["inbox"] = inbox_data
	data["archive"] = archive_data
	data["archive_count"] = length(archive_data)
	data["paperwork"] = paperwork_data
	data["pending_count"] = pending_count
	data["paperwork_pending"] = paperwork_pending
	data["unresolved_work_count"] = pending_count + (paperwork_pending ? 1 : 0)

	return data


/obj/machinery/computer/ccpost_sector_comms/ui_act(
	action,
	list/params,
	datum/tgui/ui,
	datum/ui_state/state
)
	. = ..()

	if(.)
		return

	var/mob/user = ui.user

	// Archive-wide controls do not target an individual transmission.
	switch(action)
		if("print_archive")
			var/printed_pages = print_sector_archive()
			if(printed_pages <= 0)
				balloon_alert(user, "archive is empty")
			else
				balloon_alert(user, "[printed_pages] archive pages printed")
			return TRUE

		if("clear_archive")
			var/cleared_count = GLOB.ccpost_sector_network.clear_resolved_sector_messages()
			if(cleared_count <= 0)
				balloon_alert(user, "archive is empty")
			else
				balloon_alert(user, "[cleared_count] records cleared")
			return TRUE

		if("reprint_paperwork")
			if(!GLOB.ccpost_sector_network.validate_active_sector_paperwork())
				balloon_alert(user, "no active paperwork request")
				return TRUE

			var/datum/ccpost_sector_paperwork_request/reprint_request = GLOB.ccpost_sector_network.active_sector_paperwork

			if(reprint_request.status != CCPOST_PAPERWORK_AWAITING_REVIEW)
				balloon_alert(user, "document already transmitted")
				return TRUE

			if(submitted_paperwork)
				balloon_alert(user, "document slot occupied")
				return TRUE

			if(!COOLDOWN_FINISHED(src, paperwork_print_cooldown))
				balloon_alert(user, "printer cooling down")
				return TRUE

			COOLDOWN_START(src, paperwork_print_cooldown, 5 SECONDS)

			if(print_sector_paperwork(reprint_request))
				balloon_alert(user, "document reprinted")
			else
				balloon_alert(user, "unable to print document")

			return TRUE

		if("eject_paperwork")
			if(!eject_sector_paperwork(user))
				balloon_alert(user, "document slot empty")
			else
				balloon_alert(user, "document ejected")

			return TRUE

		if("transmit_paperwork")
			if(!GLOB.ccpost_sector_network.validate_active_sector_paperwork())
				balloon_alert(user, "paperwork request no longer valid")
				return TRUE

			var/datum/ccpost_sector_paperwork_request/transmit_request = GLOB.ccpost_sector_network.active_sector_paperwork

			if(!transmit_request || transmit_request.status != CCPOST_PAPERWORK_AWAITING_REVIEW)
				balloon_alert(user, "document already transmitted")
				return TRUE

			if(!submitted_paperwork)
				balloon_alert(user, "insert document first")
				return TRUE

			if(submitted_paperwork.paperwork_code != transmit_request.paperwork_code)
				balloon_alert(user, "incorrect document inserted")
				return TRUE

			if(!paperwork_has_centcom_stamp(submitted_paperwork))
				balloon_alert(user, "CentCom stamp required")
				return TRUE

			var/obj/item/paper/ccpost_sector_paperwork/transmitted_document = submitted_paperwork
			submitted_paperwork = null

			transmit_request.status = CCPOST_PAPERWORK_AWAITING_RECEIPT
			transmit_request.submitted_by = user.name
			transmit_request.submitted_at = station_time_timestamp()

			qdel(transmitted_document)

			playsound(src, 'sound/machines/terminal_alert.ogg', vol = 30, vary = TRUE)
			balloon_alert(user, "document transmitted")
			say("Administrative document [transmit_request.paperwork_code] transmitted. Awaiting receiving-installation confirmation.")

			addtimer(CALLBACK(GLOB.ccpost_sector_network, TYPE_PROC_REF(/datum/ccpost_sector_network, complete_sector_paperwork), transmit_request.paperwork_code), rand(20 SECONDS, 45 SECONDS))

			GLOB.ccpost_sector_network.refresh_comms_terminals()
			return TRUE

	var/message_code = params["message_code"]
	var/datum/ccpost_sector_message/message = GLOB.ccpost_sector_network.find_sector_message(message_code)

	if(!message)
		balloon_alert(user, "transmission not found")
		return TRUE

	// Archived messages may be printed individually, but cannot be acted upon.
	if(action == "print_message")
		if(message.resolution_status == CCPOST_MESSAGE_PENDING)
			balloon_alert(user, "resolve transmission first")
			return TRUE

		if(print_sector_message_record(message))
			balloon_alert(user, "record printed")
		else
			balloon_alert(user, "unable to print record")
		return TRUE

	if(message.resolution_status != CCPOST_MESSAGE_PENDING)
		balloon_alert(user, "transmission already resolved")
		return TRUE

	switch(action)
		if("acknowledge")
			if(message.message_type != CCPOST_MESSAGE_UPDATE)
				return TRUE

			var/acknowledgement_response = "Transmission acknowledged."

			if(message.allocation_reward > 0)
				var/datum/ccpost_sector_installation/reward_installation = GLOB.ccpost_sector_network.get_installation_by_code(message.installation_code)

				if(!GLOB.ccpost_sector_network.is_installation_green(reward_installation))
					message.resolution_status = CCPOST_MESSAGE_EXPIRED
					message.responded_by = "SYSTEM"
					message.responded_at = station_time_timestamp()
					message.response = "Sector transfer withdrawn after the installation left green operational status."
					GLOB.ccpost_sector_network.refresh_comms_terminals()
					balloon_alert(user, "transfer withdrawn")
					return TRUE

				var/credited_amount = GLOB.ccpost_logistics_network.credit_allocation(
					message.allocation_reward,
					"Sector transfer [message.message_code]: [message.installation_name]",
					message.sender_name
				)

				message.allocation_change = credited_amount
				GLOB.ccpost_logistics_network.refresh_logistics_outputs()

				var/rerouted_amount = message.allocation_reward - credited_amount

				if(rerouted_amount > 0)
					var/datum/ccpost_sector_installation/reroute_recipient = GLOB.ccpost_sector_network.get_allocation_reroute_recipient(message.installation_code)

					if(reroute_recipient)
						if(credited_amount > 0)
							acknowledgement_response = "[credited_amount] CU was credited to Liaison Operational Allocation. The remaining [rerouted_amount] CU exceeded local capacity and was rerouted to [reroute_recipient.installation_name] ([reroute_recipient.installation_code]) for local operational use."
							balloon_alert(user, "[credited_amount] CU received; remainder rerouted")
						else
							acknowledgement_response = "Liaison Operational Allocation is at maximum capacity. The full [rerouted_amount] CU transfer was rerouted to [reroute_recipient.installation_name] ([reroute_recipient.installation_code]) for local operational use."
							balloon_alert(user, "transfer rerouted")

					else
						if(credited_amount > 0)
							acknowledgement_response = "[credited_amount] CU was credited to Liaison Operational Allocation. The remaining [rerouted_amount] CU could not be placed with another surviving sector installation and was returned to Sector Accounting."
							balloon_alert(user, "[credited_amount] CU received")
						else
							acknowledgement_response = "Liaison Operational Allocation is at maximum capacity. No alternate surviving sector installation was available, so the [rerouted_amount] CU transfer was returned to Sector Accounting."
							balloon_alert(user, "allocation at capacity")

				else if(credited_amount > 0)
					acknowledgement_response = "Sector transfer acknowledged. [credited_amount] CU was credited to Liaison Operational Allocation."
					balloon_alert(user, "[credited_amount] CU received")

			message.resolution_status = CCPOST_MESSAGE_ACKNOWLEDGED
			message.responded_by = user.name
			message.responded_at = station_time_timestamp()
			message.response = acknowledgement_response
			GLOB.ccpost_sector_network.refresh_comms_terminals()
			return TRUE

		if("authorize")
			if(message.message_type != CCPOST_MESSAGE_REQUEST)
				return TRUE

			if(!GLOB.ccpost_sector_network.sector_message_still_valid(message))
				message.resolution_status = CCPOST_MESSAGE_EXPIRED
				message.responded_by = "SYSTEM"
				message.responded_at = station_time_timestamp()
				message.response = "Installation conditions changed before authorization could be processed."
				GLOB.ccpost_sector_network.refresh_comms_terminals()
				balloon_alert(user, "request no longer applicable")
				return TRUE

			if(message.allocation_cost > 0)
				if(!GLOB.ccpost_logistics_network.spend_allocation(message.allocation_cost, "Sector assistance [message.message_code]: [message.installation_name]", user.name))
					balloon_alert(user, "insufficient allocation")
					return TRUE

				message.allocation_change = -message.allocation_cost
				GLOB.ccpost_logistics_network.refresh_logistics_outputs()

			message.resolution_status = CCPOST_MESSAGE_AUTHORIZED
			message.responded_by = user.name
			message.responded_at = station_time_timestamp()

			var/datum/ccpost_sector_installation/authorized_installation = GLOB.ccpost_sector_network.get_installation_by_code(message.installation_code)
			var/authorized_critical = authorized_installation?.status == CCPOST_INSTALLATION_CRITICAL

			if(GLOB.ccpost_sector_network.apply_authorized_sector_request(message) && authorized_installation)
				var/trust_gain = authorized_critical ? 8 : 4
				GLOB.ccpost_sector_network.adjust_installation_trust(
					authorized_installation,
					trust_gain,
					"LIAISON ACTION",
					"Assistance authorized: [message.title]",
					"[user.name] authorized [message.allocation_cost] CU of requested operational assistance. The decision was recorded by [message.sender_role] [message.sender_name]."
				)

			GLOB.ccpost_sector_network.refresh_comms_terminals()
			balloon_alert(user, "request authorized")
			return TRUE

		if("deny")
			if(message.message_type != CCPOST_MESSAGE_REQUEST)
				return TRUE

			message.resolution_status = CCPOST_MESSAGE_DENIED
			message.responded_by = user.name
			message.responded_at = station_time_timestamp()

			var/datum/ccpost_sector_installation/denied_installation = GLOB.ccpost_sector_network.get_installation_by_code(message.installation_code)
			var/denied_critical = denied_installation?.status == CCPOST_INSTALLATION_CRITICAL && (CCPOST_INSTALLATION_CRITICAL in message.valid_statuses)

			message.response = GLOB.ccpost_sector_network.get_aid_decision_response(
				denied_installation,
				FALSE,
				denied_critical
			)

			if(denied_installation && message.allocation_cost > 0)
				GLOB.ccpost_sector_network.register_aid_denial(denied_installation, message, user)
				GLOB.ccpost_sector_network.adjust_installation_trust(
					denied_installation,
					denied_critical ? -10 : -6,
					"LIAISON ACTION",
					"Assistance denied: [message.title]",
					"[user.name] denied [message.allocation_cost] CU of requested operational assistance. The denial remains part of the installation's Liaison record."
				)

			GLOB.ccpost_sector_network.refresh_comms_terminals()
			balloon_alert(user, "request denied")
			return TRUE

	return FALSE

// DISPLAY NOTIFICATIONS

/datum/ccpost_sector_network/proc/notify_registered_displays(spoken_message = null, urgent = FALSE, sound_volume = 0, physical_message = null)
	for(var/obj/machinery/status_display/ccpost_remote_status/display as anything in registered_displays)
		if(QDELETED(display))
			continue

		SStgui.update_uis(display)

		if(display.machine_stat & (NOPOWER | BROKEN))
			continue

		if(sound_volume > 0)
			playsound(display, 'sound/machines/terminal_alert.ogg', vol = sound_volume, vary = !urgent)

		if(physical_message)
			if(urgent)
				display.visible_message(span_warning("[display] [physical_message]"))
			else
				display.visible_message(span_notice("[display] [physical_message]"))

		if(spoken_message)
			display.say(spoken_message)

// SECTOR NOTICE HANDLING

/datum/ccpost_sector_network/proc/is_medical_supply_recall_active()
	for(var/datum/ccpost_sector_notice/notice as anything in sector_notices)
		if(QDELETED(notice))
			continue

		if(!notice.blocks_medical_supplies)
			continue

		if(notice.has_active_logistics_effect())
			return TRUE

	return FALSE


/datum/ccpost_sector_network/proc/apply_sector_notice_installation_effects(datum/ccpost_sector_notice/notice)
	if(!notice)
		return

	if(notice.template_id != CCPOST_NOTICE_TEMPLATE_MEDICAL_BATCH_RECALL)
		return

	var/datum/ccpost_sector_installation/medical_center = get_installation_by_code(CCPOST_INSTALLATION_CODE_MED_M12)

	if(!medical_center || medical_center.destroyed)
		return

	if(!medical_supply_recall_was_active)
		add_installation_history(
			medical_center,
			"MEDICAL LOGISTICS",
			"Medical Supply Recall Issued",
			"Central Medical Logistics issued a sector medical-supply recall. Routine medical resupply is suspended while M-12 quarantines affected stock and validates outgoing inventory."
		)

	medical_supply_recall_was_active = TRUE

	// A recall places an otherwise functioning distribution center under review.
	// More serious existing states are never overwritten by the recall.
	if(is_installation_green(medical_center) || medical_center.status == CCPOST_INSTALLATION_MAINTENANCE)
		medical_center.status = CCPOST_INSTALLATION_UNDER_REVIEW
		medical_center.status_since = station_time_timestamp()
		apply_installation_status_metadata(medical_center)

	if(medical_center.status != CCPOST_INSTALLATION_CRITICAL && medical_center.status != CCPOST_INSTALLATION_NO_CONTACT && medical_center.status != CCPOST_INSTALLATION_OFFLINE)
		medical_center.condition_details = "Central Medical Logistics has placed affected supply batches under recall. M-12 is quarantining stock and validating outgoing inventory."
		medical_center.incident_summary = "An active sector medical-supply batch recall is being coordinated through M-12."

	notify_registered_displays(null, FALSE, 25, "chimes. Medical Distribution Center M-12 has entered recall review procedures.")


/datum/ccpost_sector_network/proc/refresh_notice_dependent_systems()
	if(GLOB.ccpost_logistics_network)
		GLOB.ccpost_logistics_network.refresh_logistics_outputs()

	var/recall_active = is_medical_supply_recall_active()
	var/datum/ccpost_sector_installation/medical_center = get_installation_by_code(CCPOST_INSTALLATION_CODE_MED_M12)

	if(recall_active)
		medical_supply_recall_was_active = TRUE

	// Record the end of the continuous recall window exactly once, even if M-12
	// changed operational state while the recall was active.
	else if(medical_supply_recall_was_active)
		if(medical_center && !medical_center.destroyed)
			add_installation_history(
				medical_center,
				"MEDICAL LOGISTICS",
				"Medical Supply Recall Lifted",
				"Central Medical Logistics lifted the sector medical-supply recall. Normal medical distribution authorization has been restored."
			)

		medical_supply_recall_was_active = FALSE

	// Clear recall-specific display text after the final active recall expires.
	if(!recall_active && medical_center && !medical_center.destroyed && medical_center.status == CCPOST_INSTALLATION_UNDER_REVIEW)
		if(findtext(medical_center.incident_summary, "medical-supply batch recall"))
			apply_installation_status_metadata(medical_center)
			medical_center.incident_summary = "No active incident."

	notify_registered_displays()


/datum/ccpost_sector_network/proc/create_sector_notice(datum/ccpost_sector_notice_template/template)
	var/round_identifier = GLOB.round_id ? GLOB.round_id : "LOCAL"
	var/notice_code = "CC-SN-[round_identifier]-[next_sector_notice_number]"

	next_sector_notice_number++

	var/datum/ccpost_sector_notice/new_notice = new(notice_code, template)

	sector_notices.Insert(1, new_notice)

	if(length(sector_notices) > max_sector_notices)
		var/datum/ccpost_sector_notice/oldest_notice = sector_notices[length(sector_notices)]

		sector_notices.Cut(
			length(sector_notices),
			length(sector_notices) + 1
		)

		qdel(oldest_notice)

	return new_notice

/datum/ccpost_sector_network/proc/create_dynamic_sector_notice(
	template_id,
	category,
	source,
	priority,
	title,
	body
)
	var/datum/ccpost_sector_notice_template/template = new(
		template_id,
		category,
		source,
		priority,
		title,
		body
	)

	var/datum/ccpost_sector_notice/notice = create_sector_notice(template)
	qdel(template)
	return notice


/datum/ccpost_sector_network/proc/schedule_next_sector_notice(minimum_delay = 10 MINUTES, maximum_delay = 18 MINUTES)
	if(sector_notice_timer)
		deltimer(sector_notice_timer)

	sector_notice_timer = addtimer(CALLBACK(src, PROC_REF(issue_sector_notice)), rand(minimum_delay, maximum_delay), TIMER_STOPPABLE)


/datum/ccpost_sector_network/proc/issue_sector_notice(silent = FALSE)
	sector_notice_timer = null

	var/datum/ccpost_sector_notice_template/chosen_template = pick(sector_notice_templates)

	if(length(sector_notice_templates) > 1)
		while(chosen_template.template_id == last_sector_notice_id)
			chosen_template = pick(sector_notice_templates)

	last_sector_notice_id = chosen_template.template_id

	var/datum/ccpost_sector_notice/new_notice = create_sector_notice(chosen_template)

	apply_sector_notice_installation_effects(new_notice)

	if(GLOB.ccpost_logistics_network)
		GLOB.ccpost_logistics_network.refresh_logistics_outputs()

	if(new_notice && new_notice.logistics_effect_duration > 0)
		addtimer(CALLBACK(src, PROC_REF(refresh_notice_dependent_systems)), new_notice.logistics_effect_duration)

	if(silent)
		notify_registered_displays()
	else
		notify_registered_displays(
			null,
			FALSE,
			30,
			"emits a brief notification tone. A new Central Command sector notice has been received."
		)

	schedule_next_sector_notice()

// INSTALLATION INITIALIZATION

/datum/ccpost_sector_network/proc/initialize_sector_installations()
	if(length(sector_installations))
		return

	for(var/datum/ccpost_sector_installation_template/installation_template as anything in sector_installation_templates)
		var/datum/ccpost_sector_installation/new_installation = new(installation_template)

		apply_installation_status_metadata(new_installation)

		sector_installations += new_installation

/datum/ccpost_sector_network/proc/get_installation_by_code(installation_code)
	if(!installation_code)
		return null

	ensure_started()

	for(var/datum/ccpost_sector_installation/installation as anything in sector_installations)
		if(installation.installation_code == installation_code)
			return installation

	return null

// NORMAL INSTALLATION STATUS

/datum/ccpost_sector_network/proc/apply_installation_status_metadata(datum/ccpost_sector_installation/installation)
	if(!installation || installation.destroyed)
		return

	switch(installation.status)
		if(CCPOST_INSTALLATION_ONLINE, CCPOST_INSTALLATION_ROUTINE)
			installation.condition = "OPERATIONAL"
			installation.telemetry = "ACTIVE"
			installation.condition_details = "No structural concerns reported."

		if(CCPOST_INSTALLATION_MAINTENANCE)
			installation.condition = "OPERATIONAL"
			installation.telemetry = "ACTIVE"
			installation.condition_details = "Local maintenance activity is currently registered."

		if(CCPOST_INSTALLATION_UNDER_REVIEW)
			installation.condition = "OPERATIONAL"
			installation.telemetry = "ACTIVE"
			installation.condition_details = "The installation is subject to an active Central Command administrative review."

		if(CCPOST_INSTALLATION_COMMS_DEGRADED)
			installation.condition = "DEGRADED"
			installation.telemetry = "DEGRADED"
			installation.condition_details = "Intermittent telemetry and communications loss has been detected."

		if(CCPOST_INSTALLATION_NO_CONTACT)
			installation.condition = "UNKNOWN"
			installation.telemetry = "SIGNAL LOST"
			installation.condition_details = "The installation is not responding to routine communications requests."

		if(CCPOST_INSTALLATION_OFFLINE)
			installation.condition = "NON-OPERATIONAL"
			installation.telemetry = "INACTIVE"
			installation.condition_details = "The installation is reporting an offline operational state."


/datum/ccpost_sector_network/proc/get_next_installation_status(datum/ccpost_sector_installation/installation)
	switch(installation.status)
		if(CCPOST_INSTALLATION_ONLINE)
			return pick(CCPOST_INSTALLATION_ONLINE, CCPOST_INSTALLATION_ROUTINE, CCPOST_INSTALLATION_ROUTINE, CCPOST_INSTALLATION_MAINTENANCE, CCPOST_INSTALLATION_UNDER_REVIEW, CCPOST_INSTALLATION_COMMS_DEGRADED)

		if(CCPOST_INSTALLATION_ROUTINE)
			return pick(CCPOST_INSTALLATION_ONLINE, CCPOST_INSTALLATION_ROUTINE, CCPOST_INSTALLATION_ROUTINE, CCPOST_INSTALLATION_MAINTENANCE, CCPOST_INSTALLATION_UNDER_REVIEW, CCPOST_INSTALLATION_COMMS_DEGRADED)

		if(CCPOST_INSTALLATION_MAINTENANCE)
			return pick(CCPOST_INSTALLATION_ONLINE, CCPOST_INSTALLATION_ROUTINE, CCPOST_INSTALLATION_MAINTENANCE, CCPOST_INSTALLATION_COMMS_DEGRADED, CCPOST_INSTALLATION_OFFLINE)

		if(CCPOST_INSTALLATION_UNDER_REVIEW)
			return pick(CCPOST_INSTALLATION_ONLINE, CCPOST_INSTALLATION_ROUTINE, CCPOST_INSTALLATION_MAINTENANCE, CCPOST_INSTALLATION_UNDER_REVIEW, CCPOST_INSTALLATION_COMMS_DEGRADED)

		if(CCPOST_INSTALLATION_COMMS_DEGRADED)
			return pick(CCPOST_INSTALLATION_ONLINE, CCPOST_INSTALLATION_ROUTINE, CCPOST_INSTALLATION_COMMS_DEGRADED, CCPOST_INSTALLATION_NO_CONTACT, CCPOST_INSTALLATION_OFFLINE)

		if(CCPOST_INSTALLATION_NO_CONTACT)
			return pick(CCPOST_INSTALLATION_ONLINE, CCPOST_INSTALLATION_COMMS_DEGRADED, CCPOST_INSTALLATION_NO_CONTACT, CCPOST_INSTALLATION_OFFLINE)

		if(CCPOST_INSTALLATION_OFFLINE)
			return pick(CCPOST_INSTALLATION_ONLINE, CCPOST_INSTALLATION_MAINTENANCE, CCPOST_INSTALLATION_COMMS_DEGRADED, CCPOST_INSTALLATION_NO_CONTACT, CCPOST_INSTALLATION_OFFLINE)

	return CCPOST_INSTALLATION_ROUTINE


/datum/ccpost_sector_network/proc/get_critical_chance(datum/ccpost_sector_installation/installation)
	if(!installation || installation.destroyed)
		return 0

	var/base_chance = 0

	switch(installation.status)
		if(CCPOST_INSTALLATION_ONLINE, CCPOST_INSTALLATION_ROUTINE)
			base_chance = 3

		if(CCPOST_INSTALLATION_MAINTENANCE, CCPOST_INSTALLATION_UNDER_REVIEW)
			base_chance = 8

		if(CCPOST_INSTALLATION_COMMS_DEGRADED)
			base_chance = 30

		if(CCPOST_INSTALLATION_NO_CONTACT)
			base_chance = 45

		if(CCPOST_INSTALLATION_OFFLINE)
			base_chance = 55

	if(base_chance <= 0)
		return 0

	return min(95, base_chance + installation.aid_denial_risk + get_sector_loss_critical_chance_modifier())

// NO CONTACT / OFFLINE NOTICES

/datum/ccpost_sector_network/proc/create_installation_status_notice(datum/ccpost_sector_installation/installation)
	var/spoken_update

	if(installation.status == CCPOST_INSTALLATION_NO_CONTACT)
		create_dynamic_sector_notice(
			"installation_no_contact_[installation.installation_code]",
			"Sector Operations",
			"Sector Network Operations",
			CCPOST_PRIORITY_ADVISORY,
			"Communications Lost: [installation.installation_name]",
			"Routine communications with [installation.installation_name] ([installation.installation_code]) have been lost. Automated systems will continue attempting to re-establish contact. No emergency response has been authorized at this time."
		)

		spoken_update = "Sector advisory. Routine communications with [installation.installation_name] have been lost. Automated reconnection attempts are ongoing."

	else if(installation.status == CCPOST_INSTALLATION_OFFLINE)
		create_dynamic_sector_notice(
			"installation_offline_[installation.installation_code]",
			"Sector Operations",
			"Sector Network Operations",
			CCPOST_PRIORITY_ADVISORY,
			"Installation Offline: [installation.installation_name]",
			"[installation.installation_name] ([installation.installation_code]) is presently reporting an offline operational state. Remote monitoring will continue pending restoration of normal systems."
		)

		spoken_update = "Sector advisory. [installation.installation_name] is reporting an offline operational state. Remote monitoring will continue."

	else
		return

	notify_registered_displays(
		spoken_update,
		FALSE,
		30,
		"emits a notification tone. A sector installation advisory has been received."
	)

// CRITICAL INSTALLATION STATE

/datum/ccpost_sector_network/proc/get_critical_incident_for_installation(datum/ccpost_sector_installation/installation)
	if(installation)
		var/list/installation_incidents = critical_incidents_by_installation[installation.installation_code]
		if(length(installation_incidents) && prob(70))
			return pick(installation_incidents)

	if(length(critical_incidents_common))
		return pick(critical_incidents_common)

	return null


/datum/ccpost_sector_network/proc/get_critical_aid_request_body(datum/ccpost_sector_installation/installation)
	if(!installation)
		return "Liaison, this installation is in a critical emergency. We need immediate Operational Allocation to keep essential systems and personnel alive."

	var/request_text = installation.critical_incident?.request_text
	if(!request_text)
		request_text = "Liaison, the installation is in a critical emergency and local personnel are losing the ability to contain it. We need immediate Operational Allocation for emergency continuity resources."

	if(installation.ert_dispatched)
		return "[request_text] Emergency Response Team deployment is confirmed. We need this allocation to hold the situation together until they can take over."

	return "[request_text] No Emergency Response Team has been assigned. If Central is not sending personnel, authorize the resources we need now or this installation may be lost before the next update."


/datum/ccpost_sector_network/proc/get_critical_aid_authorization_details(datum/ccpost_sector_installation/installation)
	if(!installation)
		return null

	if(installation.critical_incident?.aid_details)
		return installation.critical_incident.aid_details

	return "Emergency Central Command continuity resources have been committed to support local containment and preserve essential operations."


/datum/ccpost_sector_network/proc/clear_critical_aftermath(datum/ccpost_sector_installation/installation)
	if(!installation)
		return

	if(installation.critical_aftermath_active)
		add_installation_history(
			installation,
			"OPERATIONS",
			"Critical incident record closed",
			"Post-incident recovery concluded after the installation returned to green operational status."
		)

	installation.critical_aftermath_active = FALSE
	installation.critical_incident = null

	installation.critical_aid_authorized = FALSE
	installation.critical_aid_authorized_by = null
	installation.critical_aid_authorized_at = null
	installation.critical_aid_denied = FALSE
	installation.critical_aid_denied_by = null
	installation.critical_aid_denied_at = null

	installation.ert_dispatched = FALSE
	installation.response_status = "NONE"
	installation.incident_summary = "No active incident."
	installation.aid_denial_risk = 0


/datum/ccpost_sector_network/proc/set_installation_critical(datum/ccpost_sector_installation/installation)
	if(!installation || installation.destroyed)
		return

	installation.status = CCPOST_INSTALLATION_CRITICAL
	clear_installation_followup(installation)
	expire_sector_paperwork_for_installation(installation, "Source installation entered CRITICAL status.")
	installation.condition = CCPOST_INSTALLATION_CRITICAL
	installation.telemetry = "EMERGENCY"

	installation.critical_incident = get_critical_incident_for_installation(installation)
	if(installation.critical_incident?.description)
		installation.incident_summary = installation.critical_incident.description
	else
		installation.incident_summary = "an unresolved station-wide security emergency"
	installation.status_since = station_time_timestamp()
	record_installation_contact(installation)

	// A new Critical incident begins with no Liaison emergency allocation
	// committed to it. Previous post-incident state is superseded.
	installation.critical_aid_authorized = FALSE
	installation.critical_aid_authorized_by = null
	installation.critical_aid_authorized_at = null
	installation.critical_aid_denied = FALSE
	installation.critical_aid_denied_by = null
	installation.critical_aid_denied_at = null
	installation.critical_aftermath_active = FALSE

	if(prob(65))
		installation.ert_dispatched = TRUE
		installation.response_status = "ERT DISPATCHED"
		installation.condition_details = "Emergency containment procedures are active. An Emergency Response Team has been dispatched while local personnel attempt to maintain essential operations."
	else
		installation.ert_dispatched = FALSE
		installation.response_status = "NO ERT DISPATCHED"
		installation.condition_details = "Emergency containment procedures are active. No external response team has been dispatched; local personnel are attempting to maintain essential operations."

	var/ert_history_text = installation.ert_dispatched ? "Emergency Response Team deployment was authorized." : "No Emergency Response Team was dispatched at declaration."
	add_installation_history(
		installation,
		"EMERGENCY",
		"CRITICAL incident declared",
		"[installation.incident_summary]. [ert_history_text]"
	)

	create_installation_critical_notice(installation)

	var/spoken_update
	if(installation.ert_dispatched)
		spoken_update = "Central Command sector alert. [installation.installation_name] has entered a CRITICAL operational state. Emergency Response Team deployment has been authorized."
	else
		spoken_update = "Central Command sector alert. [installation.installation_name] has entered a CRITICAL operational state. No Emergency Response Team has been authorized at this time."

	notify_registered_displays(
		spoken_update,
		TRUE,
		45,
		"emits an urgent notification tone."
	)

	// A critical installation has the highest chance of directly requesting
	// Liaison-controlled emergency allocation.
	maybe_issue_installation_aid_request(installation)

	// Critical incidents receive a faster follow-up.
	schedule_next_sector_installation_update(4 MINUTES, 6 MINUTES)


/datum/ccpost_sector_network/proc/create_installation_critical_notice(datum/ccpost_sector_installation/installation)
	var/response_text

	if(installation.ert_dispatched)
		response_text = "Central Command has authorized deployment of an Emergency Response Team to the installation."
	else
		response_text = "No Emergency Response Team has been dispatched at this time. Remote monitoring remains active."

	create_dynamic_sector_notice(
		"installation_critical_[installation.installation_code]",
		"Emergency Operations",
		"Central Emergency Management",
		CCPOST_PRIORITY_IMPORTANT,
		"Critical Installation Status: [installation.installation_name]",
		"[installation.installation_name] ([installation.installation_code]) has been designated CRITICAL following reports of [installation.incident_summary]. [response_text] Nearby Nanotrasen installations are instructed to maintain present operations unless otherwise directed."
	)


// CRITICAL INCIDENT RESOLUTION

/datum/ccpost_sector_network/proc/resolve_critical_installation(datum/ccpost_sector_installation/installation)
	if(!installation || installation.destroyed || installation.status != CCPOST_INSTALLATION_CRITICAL)
		return

	var/recovery_chance

	if(installation.ert_dispatched)
		recovery_chance = 70
	else
		recovery_chance = 35

	// Liaison-authorized emergency allocation improves the chance that the
	// installation survives the incident, but it never guarantees recovery.
	if(installation.critical_aid_authorized)
		recovery_chance += 20

	// Denying emergency assistance does not doom an installation outright,
	// but it reduces the chance that the remaining local/ERT response succeeds.
	if(installation.aid_denial_risk > 0)
		var/denial_recovery_penalty = round(installation.aid_denial_risk / 2)
		recovery_chance -= denial_recovery_penalty

	// Every Critical incident retains at least some possibility of either
	// recovery or installation loss.
	recovery_chance = min(95, max(5, recovery_chance))

	if(prob(recovery_chance))
		resolve_critical_installation_success(installation)
	else
		destroy_sector_installation(installation)


/datum/ccpost_sector_network/proc/resolve_critical_installation_success(datum/ccpost_sector_installation/installation)
	if(!installation)
		return

	var/datum/ccpost_critical_incident/incident = installation.critical_incident
	var/incident_text = installation.incident_summary
	var/aftermath_status = CCPOST_INSTALLATION_UNDER_REVIEW
	var/aftermath_details = "The immediate critical incident has been contained. Recovery operations remain underway."

	if(incident)
		if(incident.description)
			incident_text = incident.description
		if(incident.recovery_status)
			aftermath_status = incident.recovery_status
		if(incident.recovery_details)
			aftermath_details = incident.recovery_details

	installation.status = aftermath_status
	installation.status_since = station_time_timestamp()
	installation.critical_aftermath_active = TRUE

	apply_installation_status_metadata(installation)

	if(installation.telemetry == "ACTIVE" || installation.telemetry == "DEGRADED")
		record_installation_contact(installation)

	var/support_text

	if(installation.ert_dispatched && installation.critical_aid_authorized)
		installation.response_status = "ERT + LIAISON RECOVERY"
		support_text = "Emergency Response Team intervention and Liaison-authorized emergency resources contributed to stabilization."
	else if(installation.ert_dispatched && installation.critical_aid_denied)
		installation.response_status = "ERT RECOVERY / AID DENIED"
		support_text = "Emergency Response Team intervention contained the incident after Liaison emergency assistance was denied."
	else if(installation.ert_dispatched)
		installation.response_status = "ERT OPERATION COMPLETE"
		support_text = "Emergency Response Team intervention contributed to stabilization."
	else if(installation.critical_aid_authorized)
		installation.response_status = "LIAISON-SUPPORTED RECOVERY"
		support_text = "Liaison-authorized emergency resources contributed to stabilization."
	else if(installation.critical_aid_denied)
		installation.response_status = "RECOVERY DESPITE AID DENIAL"
		support_text = "Local installation personnel contained the immediate emergency despite Liaison emergency assistance being denied."
	else
		installation.response_status = "INCIDENT STABILIZED"
		support_text = "Local installation personnel contained the immediate emergency without external response."

	installation.incident_summary = "CONTAINED - [incident_text]"
	installation.condition_details = "[aftermath_details] [support_text]"

	add_installation_history(
		installation,
		"EMERGENCY",
		"Critical incident contained",
		"[incident_text]. The installation entered [installation.status] for post-incident recovery. [support_text]"
	)

	create_installation_recovery_notice(installation, incident_text)

	var/spoken_update = "Sector update. The critical incident at [installation.installation_name] has been contained. The installation remains at [installation.status] while recovery operations continue."

	notify_registered_displays(
		spoken_update,
		FALSE,
		35,
		"chimes. A previously critical sector installation has entered post-incident recovery."
	)


// Recovery Sector Notice

/datum/ccpost_sector_network/proc/create_installation_recovery_notice(
	datum/ccpost_sector_installation/installation,
	incident_text
)
	if(!installation)
		return

	if(!incident_text)
		if(installation.critical_incident?.description)
			incident_text = installation.critical_incident.description
		else
			incident_text = installation.incident_summary

	var/recovery_text

	if(installation.ert_dispatched && installation.critical_aid_authorized)
		recovery_text = "Emergency Response Team intervention and Liaison-authorized emergency support contributed to successful containment."
	else if(installation.ert_dispatched && installation.critical_aid_denied)
		recovery_text = "Emergency Response Team operations contained the incident after Liaison emergency assistance was denied."
	else if(installation.ert_dispatched)
		recovery_text = "Emergency Response Team operations contributed to successful containment."
	else if(installation.critical_aid_authorized)
		recovery_text = "Liaison-authorized emergency support contributed to successful containment."
	else if(installation.critical_aid_denied)
		recovery_text = "Local installation personnel contained the incident despite Liaison emergency assistance being denied."
	else
		recovery_text = "Local installation personnel contained the immediate emergency without external response."

	create_dynamic_sector_notice(
		"installation_recovery_[installation.installation_code]",
		"Emergency Operations",
		"Central Emergency Management",
		CCPOST_PRIORITY_ADVISORY,
		"Critical Incident Contained: [installation.installation_name]",
		"[installation.installation_name] ([installation.installation_code]) is no longer classified as CRITICAL following [incident_text]. [recovery_text] Current operational status: [installation.status]. Continued recovery and monitoring are required before the incident can be closed."
	)


// INSTALLATION DESTRUCTION

/datum/ccpost_sector_network/proc/destroy_sector_installation(datum/ccpost_sector_installation/installation)
	if(!installation || installation.destroyed)
		return

	installation.destroyed = TRUE
	expire_sector_paperwork_for_installation(installation, "Source installation has been destroyed.")
	installation.status = CCPOST_INSTALLATION_OFFLINE
	installation.condition = "DESTROYED"
	installation.telemetry = "TERMINATED"
	installation.critical_aftermath_active = FALSE
	installation.condition_details = "Confirmed installation loss following [installation.incident_summary]."
	installation.status_since = station_time_timestamp()

	if(installation.loss_effect?.summary)
		installation.condition_details += " Sector consequence: [installation.loss_effect.summary]"

	var/spoken_update

	if(installation.ert_dispatched && installation.critical_aid_authorized)
		installation.response_status = "ERT + AID FAILED"
		installation.condition_details += " Emergency Response Team intervention and Liaison-authorized emergency support were insufficient to prevent the loss."

		spoken_update = "Central Command priority alert. [installation.installation_name] has been confirmed lost. Emergency Response Team intervention and Liaison-authorized emergency support were unsuccessful. The installation is classified as destroyed. All remote telemetry has terminated."

	else if(installation.ert_dispatched && installation.critical_aid_denied)
		installation.response_status = "ERT FAILED / AID DENIED"
		installation.condition_details += " Emergency Response Team intervention failed after Liaison emergency assistance was denied."

		spoken_update = "Central Command priority alert. [installation.installation_name] has been confirmed lost. Emergency Response Team intervention failed after Liaison emergency assistance was denied. The installation is classified as destroyed. All remote telemetry has terminated."

	else if(installation.ert_dispatched)
		installation.response_status = "ERT OPERATION FAILED"
		installation.condition_details += " Emergency Response Team intervention was unsuccessful."

		spoken_update = "Central Command priority alert. [installation.installation_name] has been confirmed lost. Emergency Response Team intervention was unsuccessful. The installation is classified as destroyed. All remote telemetry has terminated."

	else if(installation.critical_aid_authorized)
		installation.response_status = "LIAISON AID INSUFFICIENT"
		installation.condition_details += " Liaison-authorized emergency support was insufficient to prevent the loss."

		spoken_update = "Central Command priority alert. [installation.installation_name] has been confirmed lost despite Liaison-authorized emergency support. The installation is classified as destroyed. All remote telemetry has terminated."

	else if(installation.critical_aid_denied)
		installation.response_status = "AID DENIED / INSTALLATION LOST"
		installation.condition_details += " Liaison emergency assistance was denied before the installation was lost."

		spoken_update = "Central Command priority alert. [installation.installation_name] has been confirmed lost after Liaison emergency assistance was denied. The installation is classified as destroyed. All remote telemetry has terminated."

	else
		installation.response_status = "INSTALLATION LOST"

		spoken_update = "Central Command priority alert. [installation.installation_name] has been confirmed lost. The installation is classified as destroyed. All remote telemetry has terminated."

	clear_installation_followup(installation)
	var/loss_history_details = "Remote telemetry terminated following [installation.incident_summary]. Final recorded Central response: [installation.response_status]."

	if(installation.loss_effect?.summary)
		loss_history_details += " Permanent sector consequence: [installation.loss_effect.summary]"

	add_installation_history(
		installation,
		"EMERGENCY",
		"Installation confirmed lost",
		loss_history_details
	)

	create_installation_loss_notice(installation)
	apply_installation_loss_effects(installation)

	notify_registered_displays(
		spoken_update,
		TRUE,
		45,
		"emits an urgent priority alarm."
	)

// Installation Loss Sector Notice

/datum/ccpost_sector_network/proc/create_installation_loss_notice(datum/ccpost_sector_installation/installation)
	var/response_text

	if(installation.ert_dispatched && installation.critical_aid_authorized)
		response_text = "Emergency Response Team intervention and Liaison-authorized emergency support were unsuccessful."
	else if(installation.ert_dispatched && installation.critical_aid_denied)
		response_text = "Emergency Response Team intervention was unsuccessful after Liaison emergency assistance was denied."
	else if(installation.ert_dispatched)
		response_text = "Emergency Response Team intervention was unsuccessful."
	else if(installation.critical_aid_authorized)
		response_text = "Liaison-authorized emergency support was insufficient to prevent the loss."
	else if(installation.critical_aid_denied)
		response_text = "Liaison emergency assistance was denied prior to the confirmed loss."
	else
		response_text = "No Emergency Response Team or Liaison emergency allocation was committed prior to the confirmed loss."

	var/consequence_text = ""

	if(installation.loss_effect?.summary)
		consequence_text = " Regional contingency measures are now active: [installation.loss_effect.summary]"

	create_dynamic_sector_notice(
		"installation_loss_[installation.installation_code]",
		"Emergency Operations",
		"Central Emergency Management",
		CCPOST_PRIORITY_IMPORTANT,
		"Confirmed Installation Loss: [installation.installation_name]",
		"[installation.installation_name] ([installation.installation_code]) has been confirmed destroyed following [installation.incident_summary]. [response_text][consequence_text] The installation is classified as permanently non-operational and all remote telemetry has terminated. Nearby Nanotrasen installations are instructed to maintain present operations and await further direction. Unscheduled recovery operations are not authorized."
	)


// INSTALLATION UPDATE TIMER

/datum/ccpost_sector_network/proc/schedule_next_sector_installation_update(minimum_delay = 7 MINUTES, maximum_delay = 12 MINUTES)
	if(sector_installation_timer)
		deltimer(sector_installation_timer)

	sector_installation_timer = addtimer(CALLBACK(src, PROC_REF(update_sector_installation)), rand(minimum_delay, maximum_delay), TIMER_STOPPABLE)

// Installation Update

/datum/ccpost_sector_network/proc/update_sector_installation()
	sector_installation_timer = null

	if(!length(sector_installations))
		initialize_sector_installations()

	// Critical incidents take priority over ordinary network updates.
	var/list/critical_installations = list()

	for(var/datum/ccpost_sector_installation/installation as anything in sector_installations)
		if(installation.destroyed)
			continue

		if(installation.status == CCPOST_INSTALLATION_CRITICAL)
			critical_installations += installation

	if(length(critical_installations))
		var/datum/ccpost_sector_installation/critical_installation = pick(critical_installations)

		resolve_critical_installation(critical_installation)

		var/remaining_critical = FALSE

		for(var/datum/ccpost_sector_installation/check_installation as anything in sector_installations)
			if(check_installation.destroyed)
				continue

			if(check_installation.status == CCPOST_INSTALLATION_CRITICAL)
				remaining_critical = TRUE
				break

		if(remaining_critical)
			schedule_next_sector_installation_update(4 MINUTES, 6 MINUTES)
		else
			schedule_next_sector_installation_update()

		return

	// Select a valid non-destroyed installation.
	var/list/available_installations = list()

	for(var/datum/ccpost_sector_installation/installation as anything in sector_installations)
		if(installation.destroyed)
			continue

		if(installation.status == CCPOST_INSTALLATION_CRITICAL)
			continue

		available_installations += installation

	if(!length(available_installations))
		schedule_next_sector_installation_update()
		return

	var/datum/ccpost_sector_installation/selected_installation = pick(available_installations)

	if(length(available_installations) > 1 && last_updated_installation_code)
		while(selected_installation.installation_code == last_updated_installation_code)
			selected_installation = pick(available_installations)

	last_updated_installation_code = selected_installation.installation_code

	// Status determines the chance of escalation to CRITICAL.
	var/critical_chance = get_critical_chance(selected_installation)

	if(critical_chance && prob(critical_chance))
		set_installation_critical(selected_installation)
		return

	// Otherwise perform a normal status change. An unresolved denied aid
	// request can now directly bias this cycle toward a worse operational state,
	// in addition to increasing the separate CRITICAL escalation roll above.
	var/new_status
	var/denial_worsening_chance = get_aid_denial_worsening_chance(selected_installation)

	if(denial_worsening_chance > 0 && prob(denial_worsening_chance))
		new_status = get_denial_worsened_status(selected_installation)

	if(!new_status)
		new_status = get_next_installation_status(selected_installation)

	var/previous_status = selected_installation.status
	var/status_changed = new_status != previous_status

	if(status_changed)
		selected_installation.status = new_status
		selected_installation.status_since = station_time_timestamp()

	apply_installation_status_metadata(selected_installation)

	if(selected_installation.telemetry == "ACTIVE" || selected_installation.telemetry == "DEGRADED")
		record_installation_contact(selected_installation)

	if(status_changed)
		add_installation_history(
			selected_installation,
			"OPERATIONS",
			"Status changed: [previous_status] -> [selected_installation.status]",
			selected_installation.condition_details
		)

	// Routine paperwork disappears as soon as its source leaves an eligible
	// administrative state.
	validate_active_sector_paperwork()

	// A contained Critical incident remains visible through its aftermath.
	// Only returning to green operation fully closes the incident record.
	if(selected_installation.critical_aftermath_active)
		if(is_installation_green(selected_installation))
			clear_critical_aftermath(selected_installation)
		else if(selected_installation.critical_incident?.recovery_details)
			selected_installation.condition_details = "[selected_installation.critical_incident.recovery_details] Post-incident recovery remains ongoing."
		else
			selected_installation.condition_details += " Post-incident recovery from the contained Critical event remains ongoing."

	// A denial penalty is temporary. Returning to green operation clears it;
	// otherwise the extra escalation risk decays as the installation survives
	// additional operational cycles without Central assistance.
	if(is_installation_green(selected_installation))
		selected_installation.aid_denial_risk = 0
	else if(selected_installation.aid_denial_risk > 0)
		selected_installation.aid_denial_risk = max(0, selected_installation.aid_denial_risk - 3)

	// Any status below green gets a severity-based chance to generate a
	// direct aid request from the installation's named contact.
	maybe_issue_installation_aid_request(selected_installation)

	if(status_changed)
		if(selected_installation.status == CCPOST_INSTALLATION_NO_CONTACT || selected_installation.status == CCPOST_INSTALLATION_OFFLINE)
			create_installation_status_notice(selected_installation)
		else
			notify_registered_displays(
				null,
				FALSE,
				25,
				"chimes. Sector installation telemetry has been updated."
			)

	schedule_next_sector_installation_update()

// SECTOR COMMUNICATIONS TERMINAL REGISTRATION

/datum/ccpost_sector_network/proc/register_comms_terminal(
	obj/machinery/computer/ccpost_sector_comms/terminal
)
	if(!terminal)
		return

	registered_comms_terminals |= terminal

	ensure_started()


/datum/ccpost_sector_network/proc/unregister_comms_terminal(
	obj/machinery/computer/ccpost_sector_comms/terminal
)
	if(!terminal)
		return

	registered_comms_terminals -= terminal


/datum/ccpost_sector_network/proc/refresh_comms_terminals()
	for(var/obj/machinery/computer/ccpost_sector_comms/terminal as anything in registered_comms_terminals)
		if(QDELETED(terminal))
			continue

		SStgui.update_uis(terminal)


/datum/ccpost_sector_network/proc/notify_comms_terminals(
	datum/ccpost_sector_message/message
)
	if(!message)
		return

	for(var/obj/machinery/computer/ccpost_sector_comms/terminal as anything in registered_comms_terminals)
		if(QDELETED(terminal))
			continue

		SStgui.update_uis(terminal)

		if(terminal.machine_stat & (NOPOWER | BROKEN))
			continue

		var/urgent = message.priority == CCPOST_PRIORITY_PRIORITY || message.priority == CCPOST_PRIORITY_IMPORTANT

		playsound(
			terminal,
			'sound/machines/terminal_alert.ogg',
			vol = urgent ? 45 : 30,
			vary = !urgent
		)

		terminal.say(
			"Incoming authenticated transmission from [message.installation_name]. Sender: [message.sender_role] [message.sender_name]."
		)

// CENTRAL COMMAND REMOTE STATUS DISPLAY

/obj/machinery/status_display/ccpost_remote_status
	name = "Central Command remote status display"
	desc = "A secure Central Command display receiving read-only operational telemetry from nearby Nanotrasen installations. A label beneath the screen reads: 'INFORMATION IS NOT A SUBSTITUTE FOR VERIFICATION.'"

	current_mode = SD_MESSAGE
	text_color = COLOR_DISPLAY_CYAN
	header_text_color = COLOR_DISPLAY_BLUE

	/// Frequency of nearby station telemetry refreshes.
	var/refresh_interval = 10 SECONDS

	/// Next world.time at which telemetry refreshes.
	var/next_status_refresh = 0

	/// Timestamp of the last station telemetry update.
	var/last_status_update = "N/A"

	/// Prevents repeated installation-record printing.
	COOLDOWN_DECLARE(record_print_cooldown)


/obj/machinery/status_display/ccpost_remote_status/Initialize(mapload, ndir, building)
	. = ..()

	GLOB.ccpost_sector_network.register_display(src)

	update()


/obj/machinery/status_display/ccpost_remote_status/Destroy()
	GLOB.ccpost_sector_network.unregister_display(src)

	return ..()


/obj/machinery/status_display/ccpost_remote_status/process()
	if(machine_stat & NOPOWER)
		update_appearance()
		return PROCESS_KILL

	if(machine_stat & BROKEN)
		update_appearance()
		return

	if(world.time < next_status_refresh)
		return

	next_status_refresh = world.time + refresh_interval

	refresh_station_status()


/obj/machinery/status_display/ccpost_remote_status/proc/refresh_station_status()
	var/station = station_name()
	var/alert_level = uppertext(SSsecurity_level.get_current_level_as_text())

	set_messages(station, "ALERT: [alert_level]")

	last_status_update = station_time_timestamp()

	SStgui.update_uis(src)

// STATION COMMAND ROSTER

/obj/machinery/status_display/ccpost_remote_status/proc/get_command_roster()
	var/static/list/command_positions = list(
		"Captain" = JOB_CAPTAIN,
		"Head of Personnel" = JOB_HEAD_OF_PERSONNEL,
		"Head of Security" = JOB_HEAD_OF_SECURITY,
		"Chief Engineer" = JOB_CHIEF_ENGINEER,
		"Chief Medical Officer" = JOB_CHIEF_MEDICAL_OFFICER,
		"Research Director" = JOB_RESEARCH_DIRECTOR,
		"Nanotrasen Representative" = JOB_NANOTRASEN_REPRESENTATIVE
	)

	var/list/command_roster = list()

	for(var/display_name in command_positions)
		var/job_title = command_positions[display_name]
		var/registered_name = "UNSTAFFED"

		for(var/datum/record/crew/crew_record as anything in GLOB.manifest.general)
			if(crew_record.trim != job_title)
				continue

			registered_name = crew_record.name
			break

		command_roster += list(
			list(
				"role" = display_name,
				"name" = registered_name
			)
		)

	return command_roster

// EMERGENCY SHUTTLE INFORMATION

/obj/machinery/status_display/ccpost_remote_status/proc/get_emergency_shuttle_data()
	var/list/shuttle_data = list(
		"status" = "NOT CALLED",
		"timer" = 0
	)

	if(!SSshuttle?.emergency)
		shuttle_data["status"] = "UNAVAILABLE"
		return shuttle_data

	switch(SSshuttle.emergency.mode)
		if(SHUTTLE_IDLE, SHUTTLE_RECALL)
			shuttle_data["status"] = "NOT CALLED"

		if(SHUTTLE_CALL)
			shuttle_data["status"] = "EN ROUTE"
			shuttle_data["timer"] = SSshuttle.emergency.timeLeft()

		if(SHUTTLE_DOCKED)
			shuttle_data["status"] = "DOCKED"
			shuttle_data["timer"] = SSshuttle.emergency.timeLeft()

		if(SHUTTLE_IGNITING)
			shuttle_data["status"] = "DEPARTURE IMMINENT"
			shuttle_data["timer"] = SSshuttle.emergency.timeLeft()

		if(SHUTTLE_ESCAPE)
			shuttle_data["status"] = "IN TRANSIT TO CENTRAL COMMAND"
			shuttle_data["timer"] = SSshuttle.emergency.timeLeft()

		if(SHUTTLE_STRANDED)
			shuttle_data["status"] = "STRANDED"

		if(SHUTTLE_DISABLED)
			shuttle_data["status"] = "UNAVAILABLE"

		if(SHUTTLE_ENDGAME)
			shuttle_data["status"] = "EVACUATION COMPLETE"

	return shuttle_data

// INSTALLATION RECORD PRINTING

/obj/machinery/status_display/ccpost_remote_status/proc/build_installation_record_print_text(datum/ccpost_sector_installation/installation)
	if(!installation)
		return ""

	var/contact_name = sanitize(installation.contact_name)
	var/contact_role = sanitize(installation.contact_role)
	var/relationship = GLOB.ccpost_sector_network.get_installation_trust_label(installation)
	var/followup_state = GLOB.ccpost_sector_network.get_installation_followup_status_text(installation)
	var/followup_text = followup_state

	if(installation.active_followup_origin_code)
		followup_text = "[installation.active_followup_origin_title] - [followup_state]"

	var/print_text = "<center><b>Central Command Installation Administrative Record</b></center><br>"
	print_text += "<hr>"
	print_text += "<b>Installation:</b> [installation.installation_name] ([installation.installation_code])<br>"
	print_text += "<b>Function:</b> [installation.installation_function]<br>"
	print_text += "<b>Regional Dependency:</b> [installation.regional_dependency]<br>"
	print_text += "<b>Named Contact:</b> [contact_role] [contact_name]<br>"
	print_text += "<b>Relationship Assessment:</b> [relationship]<br>"
	print_text += "<b>Operational Status:</b> [installation.status]<br>"
	print_text += "<b>Condition:</b> [installation.condition]<br>"
	print_text += "<b>Telemetry:</b> [installation.telemetry]<br>"
	print_text += "<b>Last Authenticated Contact:</b> [installation.last_authenticated_contact]<br>"
	print_text += "<b>Last Status Change:</b> [installation.status_since]<br>"
	print_text += "<b>Central Response:</b> [installation.response_status]<br>"
	print_text += "<b>Active Follow-Up:</b> [followup_text]<br>"
	print_text += "<hr>"
	print_text += "<b>Incident:</b> [installation.incident_summary]<br>"
	print_text += "<b>Remarks:</b> [installation.condition_details]<br>"

	if(installation.destroyed && installation.loss_effect?.summary)
		print_text += "<b>Permanent Sector Consequence:</b> [installation.loss_effect.summary]<br>"

	print_text += "<hr>"
	print_text += "<b>Retained Administrative History</b><br><br>"

	if(!length(installation.history))
		print_text += "No notable history is currently retained for this installation.<br>"
	else
		for(var/datum/ccpost_installation_history_entry/entry as anything in installation.history)
			if(QDELETED(entry))
				continue
			print_text += "<b>[entry.timestamp] - [entry.category]: [entry.title]</b><br>"
			print_text += "[entry.details]<br><br>"

	print_text += "<hr><small><i>Central Command Remote Oversight Network - Shift administrative record</i></small>"

	return print_text


/obj/machinery/status_display/ccpost_remote_status/proc/print_installation_record(datum/ccpost_sector_installation/installation)
	if(!installation)
		return FALSE

	var/obj/item/paper/record = new /obj/item/paper(drop_location())
	record.name = "Central Command Installation Record - [installation.installation_code]"
	record.add_raw_text(build_installation_record_print_text(installation))
	record.update_appearance()

	playsound(src, 'sound/machines/printer.ogg', vol = 50, vary = FALSE)
	visible_message(span_notice("[src] prints a Central Command installation record."))

	return TRUE


//TGUI

/obj/machinery/status_display/ccpost_remote_status/ui_interact(mob/user, datum/tgui/ui)
	. = ..()

	ui = SStgui.try_update_ui(user, src, ui)

	if(!ui)
		ui = new(user, src, "CCPostRemoteStatus", name)
		ui.open()


/obj/machinery/status_display/ccpost_remote_status/ui_act(
	action,
	list/params,
	datum/tgui/ui,
	datum/ui_state/state
)
	. = ..()

	if(.)
		return

	var/mob/user = ui.user
	var/installation_code = params["installation_code"]
	var/datum/ccpost_sector_installation/installation = GLOB.ccpost_sector_network.get_installation_by_code(installation_code)

	if(!installation)
		balloon_alert(user, "installation record not found")
		return TRUE

	switch(action)
		if("print_installation_record")
			if(!COOLDOWN_FINISHED(src, record_print_cooldown))
				balloon_alert(user, "printer cooling down")
				return TRUE

			COOLDOWN_START(src, record_print_cooldown, 5 SECONDS)

			if(print_installation_record(installation))
				balloon_alert(user, "installation record printed")
			else
				balloon_alert(user, "unable to print record")

			return TRUE

		if("clear_installation_history")
			if(!length(installation.history))
				balloon_alert(user, "history already empty")
				return TRUE

			GLOB.ccpost_sector_network.clear_installation_history(installation)
			balloon_alert(user, "installation history cleared")
			SStgui.update_uis(src)
			return TRUE

	return FALSE


/obj/machinery/status_display/ccpost_remote_status/ui_data(mob/user)
	GLOB.ccpost_sector_network.ensure_started()

	var/list/data = list()

	data["station_name"] = station_name()
	data["alert_level"] = SSsecurity_level.get_current_level_as_text()
	data["registered_crew"] = length(GLOB.manifest.general)
	data["last_update"] = last_status_update
	data["command_roster"] = get_command_roster()
	data["shuttle"] = get_emergency_shuttle_data()

	var/list/sector_notice_data = list()

	for(var/datum/ccpost_sector_notice/notice as anything in GLOB.ccpost_sector_network.sector_notices)
		var/has_operational_effect = notice.has_operational_effect()
		var/operational_effect_active = has_operational_effect && notice.has_active_logistics_effect()

		sector_notice_data += list(
			list(
				"notice_code" = notice.notice_code,
				"category" = notice.category,
				"source" = notice.source,
				"priority" = notice.priority,
				"title" = notice.title,
				"body" = notice.body,
				"issued_at" = notice.issued_at,
				"has_operational_effect" = has_operational_effect,
				"operational_effect_active" = operational_effect_active,
				"operational_effect_seconds" = notice.get_operational_effect_seconds_remaining(),
				"operational_effect_summary" = notice.logistics_effect_summary
			)
		)

	data["sector_notices"] = sector_notice_data

	var/list/sector_installation_data = list()

	for(var/datum/ccpost_sector_installation/installation as anything in GLOB.ccpost_sector_network.sector_installations)
		var/list/history_data = list()

		for(var/datum/ccpost_installation_history_entry/entry as anything in installation.history)
			if(QDELETED(entry))
				continue

			history_data += list(
				list(
					"timestamp" = entry.timestamp,
					"category" = entry.category,
					"title" = entry.title,
					"details" = entry.details
				)
			)

		sector_installation_data += list(
			list(
				"code" = installation.installation_code,
				"name" = installation.installation_name,
				"function" = installation.installation_function,
				"regional_dependency" = installation.regional_dependency,
				"last_authenticated_contact" = installation.last_authenticated_contact,
				"last_contact_seconds_ago" = installation.last_authenticated_contact_at ? max(0, round((world.time - installation.last_authenticated_contact_at) / (1 SECONDS))) : 0,
				"loss_consequence" = installation.loss_effect?.summary,
				"contact_name" = installation.contact_name,
				"contact_role" = installation.contact_role,
				"status" = installation.status,
				"status_since" = installation.status_since,
				"condition" = installation.condition,
				"telemetry" = installation.telemetry,
				"condition_details" = installation.condition_details,
				"incident_summary" = installation.incident_summary,
				"response_status" = installation.response_status,
				"ert_dispatched" = installation.ert_dispatched,
				"destroyed" = installation.destroyed,
				"trust_label" = GLOB.ccpost_sector_network.get_installation_trust_label(installation),
				"followup_active" = installation.active_followup_origin_code ? TRUE : FALSE,
				"followup_subject" = installation.active_followup_origin_title,
				"followup_status" = GLOB.ccpost_sector_network.get_installation_followup_status_text(installation),
				"history" = history_data
			)
		)

	data["sector_installations"] = sector_installation_data

	return data


MAPPING_DIRECTIONAL_HELPERS(/obj/machinery/status_display/ccpost_remote_status, 32)

#undef CCPOST_INSTALLATION_ONLINE
#undef CCPOST_INSTALLATION_ROUTINE
#undef CCPOST_INSTALLATION_MAINTENANCE
#undef CCPOST_INSTALLATION_UNDER_REVIEW
#undef CCPOST_INSTALLATION_COMMS_DEGRADED
#undef CCPOST_INSTALLATION_NO_CONTACT
#undef CCPOST_INSTALLATION_OFFLINE
#undef CCPOST_INSTALLATION_CRITICAL
#undef CCPOST_PRIORITY_ROUTINE
#undef CCPOST_PRIORITY_ADVISORY
#undef CCPOST_PRIORITY_IMPORTANT
#undef CCPOST_PRIORITY_PRIORITY
#undef CCPOST_MESSAGE_UPDATE
#undef CCPOST_MESSAGE_REQUEST
#undef CCPOST_MESSAGE_PENDING
#undef CCPOST_MESSAGE_ACKNOWLEDGED
#undef CCPOST_MESSAGE_AUTHORIZED
#undef CCPOST_MESSAGE_DENIED
#undef CCPOST_MESSAGE_EXPIRED
#undef CCPOST_PAPERWORK_AWAITING_REVIEW
#undef CCPOST_PAPERWORK_AWAITING_RECEIPT
#undef CCPOST_INSTALLATION_CODE_REL_A17
#undef CCPOST_INSTALLATION_CODE_OUT_K04
#undef CCPOST_INSTALLATION_CODE_MIN_RC12
#undef CCPOST_INSTALLATION_CODE_LP_D03
#undef CCPOST_INSTALLATION_CODE_ADM_06
#undef CCPOST_INSTALLATION_CODE_LOG_H09
#undef CCPOST_INSTALLATION_CODE_MED_M12
#undef CCPOST_INSTALLATION_CODE_SEC_S08
#undef CCPOST_NOTICE_TEMPLATE_MEDICAL_BATCH_RECALL
