// CCPost HR correspondence nodes. Contact names and titles resolve in ccpost_hr.dm.
/proc/ccpost_hr_dialogue_node(node_id)
	switch(node_id)
		if("HR-002-C")
			return list(
				"title" = "Compensation, salary or benefits",
				"body" = "Your compensation inquiry has been entered into the official ledger. Before this office can assess its potential cost to NanoTrasen, please identify the nature of your request.\n\nKindly refrain from submitting personal account statements. Finance has assured me that the figures would only complicate matters.\n\n*“Responsible compensation begins with responsible expectations.”*",
				"from" = "C",
				"options" = list("C01" = "I believe my recurring salary should be increased.", "C02" = "I wish to discuss a bonus, allowance, or employee benefit."),
			)
		if("HR-002-G")
			return list(
				"title" = "Workplace grievance or colleague complaint",
				"body" = "Your grievance has been accepted for procedural review. The employee concerned and the conduct reported must be identified clearly so that this office may determine whether a formal response is warranted.\n\nPlease confine your statement to relevant, verifiable facts. Assertions made on the basis of personal irritation do not constitute supporting evidence.\n\n*“Fairness requires due process. Due process requires the correct form.”*",
				"from" = "G",
				"options" = list(
				"G01" = "The employee identified above is not contributing their fair share of duties appropriate to their posting.",
				"G02" = "I wish to report unprofessional workplace conduct by the employee identified above."
			),
			)
		if("HR-002-W")
			return list(
				"title" = "Working conditions and office facilities",
				"body" = "Your report concerning outpost working conditions has been received. I will assess whether the issue falls below approved workplace standards, rather than merely below personal expectations.\n\nPlease specify the affected equipment, compartment, or safety procedure. A defective chair and a damaged pressure seal are not interchangeable inspection categories.\n\n*“A compliant workplace is one in which the inspection is properly documented.”*",
				"from" = "W",
				"options" = list(
				"W01" = "Our equipment, furniture, or office amenities are insufficient.",
				"W02" = "I believe the outpost presents a workplace safety concern."
			),
			)
		if("HR-002-L")
			return list(
				"title" = "Leave, personal welfare or employee wellbeing",
				"body" = "Thank you for taking an active interest in your wellbeing! Personnel Welfare is delighted to provide a supportive environment in which every concern can be acknowledged, classified, and carefully evaluated.\n\nWhether you need leave or assistance with morale, we are confident that completing this process will be a positive experience, regardless of the eventual decision.\n\n*“A brighter workplace begins with a brighter attitude.”*",
				"from" = "L",
				"options" = list(
				"L01" = "I would like to request personal leave or time away from duties.",
				"L02" = "I would like assistance with stress, morale, or employee wellbeing."
			),
			)
		if("HR-003-C01")
			return list(
				"title" = "Statement of Financial Inadequacy",
				"body" = "Your request for increased compensation has reached my desk. Please understand that this does not mean it has reached my sympathy. Before the Compensation Committee begins its extremely economical deliberations, identify the reason for your request.\n\nSubmitting all three reasons will be interpreted as an application for managerial responsibility.",
				"from" = "",
				"options" = list(
				"A" = "I have performed considerably more work than expected in my assigned position.",
				"B" = "My responsibilities exceed those described in my original posting.",
				"C" = "My current salary does not adequately cover the cost of living."
			),
			)
		if("HR-004-C01-A")
			return list(
				"title" = "On exceptional productivity",
				"body" = "Your account of exceptional service has been recorded. Human Resources is pleased to learn that an employee is performing the duties for which the employee is paid. Whether those duties involve administrative reports or installation security, we are prepared to consider recognition under our Proficiency Without Financial Liability initiative.",
				"from" = "",
				"options" = list(
				"A1" = "I insist that exceptional productivity deserves actual compensation.",
				"A2" = "I would accept a formal acknowledgment of my contributions."
			),
			)
		if("HR-005-C01-A1")
			return list(
				"title" = "Final, productivity pay demand",
				"body" = "Your insistence has been documented under *Pay-Related Persistence*. Employee compensation is determined by the approved payroll schedule, not by the intensity of an argument conducted through office stationery. We appreciate your persistence; our accountants report a mild physical reaction to it. Accordingly, a **one-time discretionary compensation award of exactly one credit** has been approved. This is not a recurring salary increase. For transparency, the single bill will arrive by CentCom supply pod.",
				"from" = "",
				"options" = list(),
			)
		if("HR-005-C01-A2")
			return list(
				"title" = "Final, acknowledgement accepted",
				"body" = "HR is delighted to grant your request. This fax serves as your **Certificate of Reported Occupational Activity**, attesting that you informed us of having performed the job we assigned to you. Please display this declaration prominently. Its appraised value is zero credits, though its motivational value is whatever you decide it is.",
				"from" = "",
				"options" = list(),
			)
		if("HR-004-C01-B")
			return list(
				"title" = "On additional responsibilities",
				"body" = "We have registered your concerns regarding duties beyond your job description. As your job description includes “other duties as required,” its practical boundaries are reassuringly flexible. To clarify the record:",
				"from" = "",
				"options" = list(
				"B1" = "These duties were explicitly assigned to me by management.",
				"B2" = "I accepted these duties because nobody else was doing them."
			),
			)
		if("HR-005-C01-B1")
			return list(
				"title" = "Final, management assigned duties",
				"body" = "You state that additional responsibilities were assigned by management. HR has provisionally classified them as *existing assigned responsibilities*, effective retroactively from the moment they were allegedly assigned. This semantic adjustment resolves your concern without creating a payroll liability.",
				"from" = "",
				"options" = list(),
			)
		if("HR-005-C01-B2")
			return list(
				"title" = "Final, self-assigned duties",
				"body" = "Your voluntary assumption of neglected duties demonstrates initiative, flexibility, and a regrettable unfamiliarity with our compensation policy. Such initiative is classified as **unpaid professional development**. You are now **compulsorily recognized** as a *Temporary Initiative Enthusiast*. This resolution doubles as an official certificate confirming the unwanted distinction. Please refrain from using it as authority over anyone else.",
				"from" = "",
				"options" = list(),
			)
		if("HR-004-C01-C")
			return list(
				"title" = "On the cost of living",
				"body" = "Central Command recognizes that prices throughout Nanotrasen territory have increased. Accordingly, we have recently increased the number of seminars explaining why this cannot be reflected in wages.",
				"from" = "",
				"options" = list(
				"C1" = "I require more credits for food and ordinary living expenses.",
				"C2" = "I require more credits to maintain a standard of living appropriate to my rank."
			),
			)
		if("HR-005-C01-C1")
			return list(
				"title" = "Final, essentials",
				"body" = "We appreciate your disclosure that basic living expenses are of financial concern. As part of this correspondence we offer advice from *Twenty Affordable Ways to Appreciate the Concept of Lunch*. Recommendation seven suggests enjoying a colleague's description of a meal. Your actual payroll remains governed by your authorized employment terms, not dietary necessity.",
				"from" = "",
				"options" = list(),
			)
		if("HR-005-C01-C2")
			return list(
				"title" = "Final, status consumption",
				"body" = "Your desire for rank-appropriate luxury has been reviewed. Central Command confirms that the dignity of an outpost employee is represented by professional conduct, responsible performance of assigned duties, and the avoidance of visibly cheap stationery. We have authorized the use of the phrase **Executive-Level Lifestyle Aspirant** on personal correspondence. This is not a rank, security clearance, or command appointment.",
				"from" = "",
				"options" = list(),
			)
		if("HR-003-C02")
			return list(
				"title" = "Supplemental Compensation Review",
				"body" = "Your inquiry regarding additional benefits has been noted. To avoid mistakenly authorizing something valuable, we require a precise classification of the benefit being sought.",
				"from" = "",
				"options" = list(
				"A" = "I deserve an extraordinary performance bonus.",
				"B" = "I require reimbursement for work-related expenditure.",
				"C" = "I wish to know which benefits my position includes."
			),
			)
		if("HR-004-C02-A")
			return list(
				"title" = "On a performance bonus",
				"body" = "A discretionary bonus is, by definition, at our discretion. At present, that discretion is leaning against expenditure. Please specify the form of recognition you would find acceptable.",
				"from" = "",
				"options" = list("A1" = "A financial bonus, in credits.", "A2" = "A formal award, preferably one that sounds important."),
			)
		if("HR-005-C02-A1")
			return list(
				"title" = "Final, monetary bonus",
				"body" = "The Compensation Committee has voted unanimously to consider your suggestion further at its next meeting, which is scheduled for an unspecified fiscal year. In the meantime, the requested credit bonus is **not approved**. We appreciate your faith in an institution that has never encouraged it.",
				"from" = "",
				"options" = list(),
			)
		if("HR-005-C02-A2")
			return list(
				"title" = "Final, formal award",
				"body" = "Congratulations! You have been designated a **Highly Commendable Candidate for Future Recognition**, a distinction reserved for employees who specifically ask for it. This fax is your official record of the nomination. To qualify for our prestigious **Employee of the Day** programme and its Gold Medal of Adequacy, complete, sign, and obtain a CentCom stamp on the incoming Form HR-A01. No medal will be dispatched before successful authorization.",
				"from" = "",
				"options" = list(),
			)
		if("HR-004-C02-B")
			return list(
				"title" = "On reimbursement",
				"body" = "We sympathize with the distress of spending personal funds on corporate necessities, though we would prefer not to experience the distress of repaying them. What was the expenditure for?",
				"from" = "",
				"options" = list(
				"B1" = "Essential work equipment or office supplies.",
				"B2" = "Hospitality, refreshments, or luxury comforts used during official duties."
			),
			)
		if("HR-005-C02-B1")
			return list(
				"title" = "Final, essential equipment",
				"body" = "Your purchase has been classified as an **unauthorized demonstration of initiative**. HR thanks you for helping the company avoid a procurement expense. This fax serves as proof that our appreciation has been communicated in writing. Properly authorized supplies may be requested through the outpost's normal requisition process by personnel with the appropriate access; our department will not reimburse purchases made on its behalf. Your unauthorized purchasing initiative has also qualified you for **Mandatory Workplace Re-Education**. Complete, sign, and have a CentCom officer stamp the incoming Form HR-T01.",
				"from" = "",
				"options" = list(),
			)
		if("HR-005-C02-B2")
			return list(
				"title" = "Final, hospitality and luxuries",
				"body" = "We regret to inform you that the phrase “essential executive hospitality” has been removed from our reimbursable categories after an incident involving twelve cakes and a departmental shuttle. Refreshments may be requested through authorized supply channels when allocations permit; your personal expenditure remains classified as **personal morale research**.",
				"from" = "",
				"options" = list(),
			)
		if("HR-004-C02-C")
			return list(
				"title" = "On employee benefits",
				"body" = "As a Central Command employee, you have access to a comprehensive portfolio of benefits, many of which are currently being redesigned for affordability. Which part concerns you most?",
				"from" = "",
				"options" = list(
				"C1" = "Healthcare, workplace injury coverage, or basic security.",
				"C2" = "Holidays, retirement, or long-term employee privileges."
			),
			)
		if("HR-005-C02-C1")
			return list(
				"title" = "Final, healthcare",
				"body" = "We are delighted to confirm you qualify for **Priority Consideration for Medical Consideration**, provided the relevant department is operational and your paperwork survives the emergency. This acknowledgement is not medical authorization or a treatment plan. Please obtain appropriate medical care when required.",
				"from" = "",
				"options" = list(),
			)
		if("HR-005-C02-C2")
			return list(
				"title" = "Final, holidays and retirement",
				"body" = "Under current policy, employees become eligible for retirement upon reaching the minimum retirement age, completing all outstanding duties, and obtaining approval from their immediate superior and that superior's eventual successor. Vacation entitlements are described in an appendix currently awaiting translation; no leave is approved by this notice.",
				"from" = "",
				"options" = list(),
			)
		if("HR-003-G01")
			return list(
				"title" = "Formal Allocation of Blame",
				"body" = "You have alleged an imbalance in professional responsibilities involving %TARGET%, %TARGET_ROLE%. HR considers balanced workloads an essential component of workplace harmony, especially when everyone is equally dissatisfied. Which statement most accurately describes the conduct of **%TARGET%, %TARGET_ROLE%**? Your complaint will be assessed in relation to that employee's actual assignment, not against duties belonging to another position.\n\nPlease note that your answer may be shared with %TARGET%, including your name. The right to complain is not the right to remain anonymous in an office staffed by three people.",
				"from" = "",
				"options" = list(
				"A" = "%TARGET% avoids duties appropriate to their assigned post and contributes very little.",
				"B" = "%TARGET% repeatedly attempts to pass their assigned responsibilities to me.",
				"C" = "I have no evidence of misconduct by %TARGET%, but I remain deeply suspicious."
			),
			)
		if("HR-004-G01-A")
			return list(
				"title" = "On apparent inactivity",
				"body" = "Your allegation regarding %TARGET% has been recorded. A Liaison may legitimately be occupied with reports, sector coordination and approved tasking paperwork; an Outpost Security Officer may be occupied with perimeter security, visitor screening and incident response. Lack of visible administrative paperwork does not establish inactivity. Please clarify your evidence.",
				"from" = "",
				"options" = list("A1" = "I have direct observations or records supporting it.", "A2" = "It is obvious from how much work I do in comparison."),
			)
		if("HR-005-G01-A1")
			return list(
				"title" = "Final, evidence-based concern",
				"body" = "You state that you have firsthand observations or records concerning %TARGET%. HR has recorded this assertion without independently verifying it. The matter is now **Eligible for Supervisory Conversation**, a classification rather than a finding of misconduct. The employee concerned may be reminded of their documented responsibilities, while you are reminded that ordinary periods away from a desk are not proof of neglect.",
				"from" = "",
				"options" = list(),
			)
		if("HR-005-G01-A2")
			return list(
				"title" = "Final, comparative workload",
				"body" = "Your comparison relies heavily on the amount of work that *you* undertake. HR cannot rule out the possibility that you are simply excessively productive. Accordingly, your comparative assessment has been entered into the **Standardization of Effort Awareness Programme**. We ask you and %TARGET% to cease competing over duties that may not even be comparable.",
				"from" = "",
				"options" = list(),
			)
		if("HR-004-G01-B")
			return list(
				"title" = "On unwanted delegation",
				"body" = "We understand that %TARGET% has attempted to transfer duties to you. Delegation is an important leadership skill, provided one actually possesses the relevant authority. Legitimate security instructions concerning this installation are a separate matter from transferring someone else's job responsibilities. Please clarify how the arrangement arose.",
				"from" = "",
				"options" = list(
				"B1" = "I accepted the extra duties to keep the outpost functioning.",
				"B2" = "I refused, but %TARGET% continued attempting to assign them anyway."
			),
			)
		if("HR-005-G01-B1")
			return list(
				"title" = "Final, accepted duties",
				"body" = "Your willingness to assume additional tasks has been categorized as **Voluntary Coverage of Operational Gaps**. While admirably selfless, it has made the disputed arrangement look alarmingly functional. %TARGET% is reminded that you are not an unlimited replacement for their role-specific duties. You are advised to stop demonstrating otherwise.",
				"from" = "",
				"options" = list(),
			)
		if("HR-005-G01-B2")
			return list(
				"title" = "Final, refused delegation",
				"body" = "You allege that %TARGET% continued transferring duties after you refused. HR has classified the alleged conduct as a **Potentially Unauthorized Management Initiative**, pending confirmation of what instructions were actually issued. Neither employee acquires supervisory powers by being more persistent on paper.",
				"from" = "",
				"options" = list(),
			)
		if("HR-004-G01-C")
			return list(
				"title" = "On evidence-free suspicion",
				"body" = "We acknowledge your statement that you possess no evidence of misconduct by %TARGET%, but remain deeply suspicious. Suspicion, regardless of depth, is not an approved productivity indicator under Employment Policy 62-B. %TARGET% has therefore been cleared of **this unsubstantiated allegation**, while your accusation has prompted a review of your professional judgment.\n\n**Finding:** Human Resources recommends a voluntary Workplace Cooperation Programme for you and %TARGET%. The alleged misconduct is unsubstantiated; this office is now considerably more concerned about your mutual willingness to communicate. No pay or authority adjustment is authorized by this finding.",
				"from" = "",
				"options" = list("C1" = "I accept the findings and will attempt to cooperate.", "C2" = "I would like to file a complaint against Human Resources."),
			)
		if("HR-005-G01-C1")
			return list(
				"title" = "Final, reluctant cooperation",
				"body" = "Your willingness to accept the finding has been entered into the record as **Encouraging Evidence of Administrative Maturity**. HR recommends delivering a written compliment to %TARGET%. We recognize this may be challenging, and suggest the following: “Your presence at this installation has been noted.”",
				"from" = "",
				"options" = list(),
			)
		if("HR-005-G01-C2")
			return list(
				"title" = "Final, complaint against HR",
				"body" = "Your complaint against Human Resources has been forwarded to the appropriate independent reviewing authority. Unfortunately, that authority is also Human Resources. After an eleven-second investigation, we have found ourselves entirely compliant with company policy. %TARGET% remains cleared of the allegation made in this case. Our previously recommended training remains entirely voluntary, despite its name. HR has awarded itself a commendation for its exemplary handling of this dispute.",
				"from" = "",
				"options" = list(),
			)
		if("HR-003-G02")
			return list(
				"title" = "Conduct Incident Classification",
				"body" = "Your report of unprofessional conduct has been received. We remind you that the expression “unprofessional” must be applied carefully, as a significant portion of corporate leadership would otherwise require immediate review.",
				"from" = "",
				"options" = list(
				"A" = "%TARGET% is misusing office equipment or supplies.",
				"B" = "%TARGET% behaves disruptively or speaks to me disrespectfully.",
				"C" = "%TARGET% acts as though they possess authority beyond their posting."
			),
			)
		if("HR-004-G02-A")
			return list(
				"title" = "On misuse of equipment",
				"body" = "We take the alleged misuse of corporate assets seriously. Not all equipment has sufficient dignity to be mistreated, but the principle remains. What kind of misuse did you observe?",
				"from" = "",
				"options" = list(
				"A1" = "Repeated use of the fax or office machines for personal amusement.",
				"A2" = "Wasteful consumption of paper, stationery, or office supplies."
			),
			)
		if("HR-005-G02-A1")
			return list(
				"title" = "Final, office machine misuse",
				"body" = "We regret that communications equipment has become a source of entertainment. This fax serves as a **Professional Fax Conduct Advisory** reminding you and %TARGET% that fax machines are to be used for official purposes, including but not limited to Human Resources correspondence. We encourage you to share this interpretation with %TARGET%, provided doing so does not create a new incident.",
				"from" = "",
				"options" = list(),
			)
		if("HR-005-G02-A2")
			return list(
				"title" = "Final, stationery misuse",
				"body" = "Your account suggests that stationery has been consumed during outpost operations, though its emotional distress could not be established. HR advises both you and %TARGET% to use paper, pens and official stamps responsibly. To conserve paper, we have elected not to print the four-page paper-conservation guide.",
				"from" = "",
				"options" = list(),
			)
		if("HR-004-G02-B")
			return list(
				"title" = "On interpersonal disruption",
				"body" = "Respectful workplace dialogue is essential. To determine the correct form of mediation, identify the kind of disruption you have experienced.",
				"from" = "",
				"options" = list(
				"B1" = "My colleague repeatedly interrupts or mocks my work.",
				"B2" = "My colleague refuses to participate in ordinary team communication."
			),
			)
		if("HR-005-G02-B1")
			return list(
				"title" = "Final, mockery and interruptions",
				"body" = "We condemn unnecessary interruptions. They distract employees from the important work of generating future interruptions in writing. You and %TARGET% have been nominated for **Mandatory Mutual Listening Practice**, participation in which is voluntary. Mockery is not constructive feedback, and doing ordinary assigned work does not entitle either party to applause.",
				"from" = "",
				"options" = list(),
			)
		if("HR-005-G02-B2")
			return list(
				"title" = "Final, refusal to communicate",
				"body" = "A refusal to communicate can undermine teamwork. Accordingly, HR recommends that %TARGET% improve their workplace communication, and that you use reasonable official channels for operational matters. We hope the existence of this very long sentence demonstrates how easily communication can become an administrative burden.",
				"from" = "",
				"options" = list(),
			)
		if("HR-004-G02-C")
			return list(
				"title" = "On imaginary authority",
				"body" = "Your allegation suggests that %TARGET% may be claiming an authority not granted by their assignment. A Security Officer may issue legitimate **installation security instructions**, whereas Liaisons coordinate administrative matters and do not command station departments. Which behavior concerns you?",
				"from" = "",
				"options" = list(
				"C1" = "My colleague issues orders as though they are my supervisor.",
				"C2" = "My colleague has adopted a grandiose title or ceremonial office."
			),
			)
		if("HR-005-G02-C1")
			return list(
				"title" = "Final, issuing orders",
				"body" = "Human Resources confirms that volume, confidence and ornamental titles are not recognized sources of command authority. Your complaint has been registered, but it does not itself establish that %TARGET% gave an unlawful instruction. No workplace hierarchy is changed by this decision.",
				"from" = "",
				"options" = list(),
			)
		if("HR-005-G02-C2")
			return list(
				"title" = "Final, grandiose title",
				"body" = "You have reported an alleged unauthorized title adopted by %TARGET%. While the naming of oneself *Supreme Administrative Chancellor* is technically free, representing that title as corporate authority is not. Your colleague may retain it for personal amusement but must not place it on official requisitions. HR has offered you the equally ceremonial title **Deputy Assistant to Nobody**.",
				"from" = "",
				"options" = list(),
			)
		if("HR-003-W01")
			return list(
				"title" = "Office Improvement Request",
				"body" = "Your dissatisfaction with the office environment has been logged for inclusion in the next Facilities Appreciation Review. Please identify the improvement you believe is most necessary.",
				"from" = "",
				"options" = list(
				"A" = "We require better furniture or a more comfortable workspace.",
				"B" = "We need additional administrative equipment or stationery.",
				"C" = "The outpost requires improved refreshments and amenities."
			),
			)
		if("HR-004-W01-A")
			return list(
				"title" = "On office furniture",
				"body" = "Our inventory identifies furniture as a normal component of office environments. Whether the current arrangement is comfortable is a considerably more expensive question. Please clarify your concern.",
				"from" = "",
				"options" = list(
				"A1" = "The furniture is uncomfortable or poorly suited to long shifts.",
				"A2" = "The furnishings fail to convey the dignity of Central Command."
			),
			)
		if("HR-005-W01-A1")
			return list(
				"title" = "Final, uncomfortable furniture",
				"body" = "Facilities recognizes that seated employees occasionally experience discomfort. We have approved a **Furniture Appreciation Assessment**, advising employees to adjust their posture and appreciate any suitable seating currently available. No replacement furniture is authorized by this letter.",
				"from" = "",
				"options" = list(),
			)
		if("HR-005-W01-A2")
			return list(
				"title" = "Final, insufficient prestige",
				"body" = "Your concern that office furniture does not reflect Central Command's authority has been substantiated in principle. We approve your use of the phrase **THIS FURNITURE IS EXECUTIVE-GRADE** when describing authorized office furnishings. The designation has no material implications but has passed our branding review.",
				"from" = "",
				"options" = list(),
			)
		if("HR-004-W01-B")
			return list(
				"title" = "On administrative supplies",
				"body" = "As you know, a functioning bureaucracy requires adequate tools, although excessive access to such tools can encourage bureaucracy beyond budgeted limits. What is missing?",
				"from" = "",
				"options" = list("B1" = "Essential writing, printing, or filing supplies.", "B2" = "Specialized equipment that would make my job easier."),
			)
		if("HR-005-W01-B1")
			return list(
				"title" = "Final, essential stationery",
				"body" = "We acknowledge your request for ordinary administrative materials. Our department has initiated an **Assessment of Potential Stationery Assessment Needs**. In recognition of your dedication to essential office supplies, Facilities has approved one small emergency stationery delivery by CentCom supply pod. Further supplies should be requested through the normal Logistics Terminal and its Operational Allocation.",
				"from" = "",
				"options" = list(),
			)
		if("HR-005-W01-B2")
			return list(
				"title" = "Final, specialized equipment",
				"body" = "Your request for equipment that would make work easier has raised an important question: if the work becomes easier, how will the corporation measure your dedication? We therefore refuse to fund the improvement through Human Resources. If the item is included in the approved Logistics catalog, an authorized requisition may still be made using available Operational Allocation.",
				"from" = "",
				"options" = list(),
			)
		if("HR-004-W01-C")
			return list(
				"title" = "On refreshments and amenities",
				"body" = "Facilities understands the value of employee morale, provided that morale does not consume departmental resources. Which enhancement do you seek?",
				"from" = "",
				"options" = list("C1" = "Better coffee or refreshments for staff.", "C2" = "Leisure facilities or entertainment equipment."),
			)
		if("HR-005-W01-C1")
			return list(
				"title" = "Final, refreshments",
				"body" = "Your request for improved coffee has been reviewed. Facilities cannot determine whether any coffee has actually been supplied to the outpost. To avoid unnecessary delays, one emergency refreshment has been authorized for delivery by CentCom supply pod. It may officially be described as **Robustly Corporate**. Further refreshments remain subject to the normal supply budget.",
				"from" = "",
				"options" = list(),
			)
		if("HR-005-W01-C2")
			return list(
				"title" = "Final, leisure equipment",
				"body" = "HR agrees that recreational opportunities can improve productivity. To avoid reducing productive time, This fax constitutes a **Recreation Authorization Certificate** valid for imagining a comfortable lounge during authorized breaks. Actual card games, plushies, costumes and other approved amenities may be requested through Logistics by authorized personnel, subject to the available allocation. Please do not confuse an imaginary lounge with an automatically supplied crate.",
				"from" = "",
				"options" = list(),
			)
		if("HR-003-W02")
			return list(
				"title" = "Occupational Hazard Assessment",
				"body" = "Your safety concern has been registered. Facilities considers every incident an opportunity to distinguish **preventable harm** from **contractually interesting exposure**. Please select the threat you wish to report.",
				"from" = "",
				"options" = list(
				"A" = "The perimeter defense turrets concern me.",
				"B" = "Visitors may pose a danger to outpost personnel.",
				"C" = "I am concerned about structural or equipment-related hazards."
			),
			)
		if("HR-004-W02-A")
			return list(
				"title" = "On perimeter defenses",
				"body" = "Automated turrets are part of the outpost's Employee Protection Enhancement Programme. They are intended to protect personnel from danger, preferably without introducing further danger. What is your specific concern?",
				"from" = "",
				"options" = list(
				"A1" = "The turrets may fire at someone they should recognize.",
				"A2" = "Their presence is intimidating and makes the workplace unpleasant."
			),
			)
		if("HR-005-W02-A1")
			return list(
				"title" = "Final, targeting fault concern",
				"body" = "A report of potential friendly-fire risk is a genuine safety concern. Facilities recommends that Outpost Security make the surrounding area safe, apply appropriate access precautions and contact qualified technical personnel if hardware repair is needed. Our office cannot confirm whether the targeting system is safe or alter the turret controller. As a safety measure, we strongly advise: **PLEASE DO NOT TEST THIS WITH YOUR BODY**.",
				"from" = "",
				"options" = list(),
			)
		if("HR-005-W02-A2")
			return list(
				"title" = "Final, intimidating turrets",
				"body" = "Our review confirms that defensive machinery can appear intimidating. This is considered a desirable quality when directed at intruders and an unfortunate aesthetic choice when directed at employees. We recommend referring to the devices as **Colleague-Assisting Perimeter Partners**.",
				"from" = "",
				"options" = list(),
			)
		if("HR-004-W02-B")
			return list(
				"title" = "On dangerous visitors",
				"body" = "Unscheduled visitors are a recognized challenge in isolated administrative environments. Please identify the principal issue you have experienced.",
				"from" = "",
				"options" = list(
				"B1" = "Individuals enter the outpost without appropriate permission.",
				"B2" = "Visitors act threateningly or interfere with outpost duties."
			),
			)
		if("HR-005-W02-B1")
			return list(
				"title" = "Final, unauthorized entry",
				"body" = "Unauthorized entry concerns are serious. We recommend referring visitors to the posted access rules and notifying the outpost's Security Officer when appropriate. This fax serves as a **Visitor Courtesy and Boundary Recognition** notice, containing the words “Please leave” in three increasingly professional forms: politely, firmly and while contacting Outpost Security.",
				"from" = "",
				"options" = list(),
			)
		if("HR-005-W02-B2")
			return list(
				"title" = "Final, threats and interference",
				"body" = "Threats to staff should be handled through the outpost's legitimate local security procedures, with appropriate wider assistance requested if necessary, not through our complaint-resolution office. We have nonetheless classified your experience as **Elevated Interpersonal Friction** to ensure it fits in our quarterly report. Please prioritize your actual safety over additional forms.",
				"from" = "",
				"options" = list(),
			)
		if("HR-004-W02-C")
			return list(
				"title" = "On structural and equipment hazards",
				"body" = "Facilities is prepared to investigate your concern, insofar as investigation can be performed remotely from a comfortable office. What type of danger have you identified?",
				"from" = "",
				"options" = list("C1" = "Damage or malfunction affecting essential infrastructure.", "C2" = "A recurring minor hazard that management has ignored."),
			)
		if("HR-005-W02-C1")
			return list(
				"title" = "Final, infrastructure problem",
				"body" = "Infrastructure damage requires attention from properly equipped personnel. Your report has been categorized as **Operationally Relevant**, an uncommon distinction in this office. We advise immediate local maintenance or emergency response as appropriate. Our contribution is an official acknowledgement suitable for filing after repairs are complete.",
				"from" = "",
				"options" = list(),
			)
		if("HR-005-W02-C2")
			return list(
				"title" = "Final, ignored minor hazard",
				"body" = "Your complaint describes a recurring hazard that has not received attention. HR recognizes the troubling precedent this sets. We have therefore upgraded its paperwork classification from **Minor** to **Persistent Minor**, which is a separate color in our annual spreadsheet. The hazard still requires practical attention from outpost personnel.",
				"from" = "",
				"options" = list(),
			)
		if("HR-003-L01")
			return list(
				"title" = "Leave Eligibility Consultation",
				"body" = "How exciting that you are planning personal time! Central Command fully endorses a healthy work-life balance, provided the two are arranged in the correct order and neither affects quarterly performance. What kind of leave would you like to discuss?",
				"from" = "",
				"options" = list(
				"A" = "I would like a short break during my shift.",
				"B" = "I would like to take an extended vacation.",
				"C" = "I require leave for an urgent personal matter."
			),
			)
		if("HR-004-L01-A")
			return list(
				"title" = "On a short break",
				"body" = "We applaud your interest in using a modest amount of time to rest. Short breaks can be restorative, provided they are managed responsibly. How will you spend this break?",
				"from" = "",
				"options" = list("A1" = "I intend to rest quietly and return to my duties.", "A2" = "I intend to leave the office and socialize with colleagues."),
			)
		if("HR-005-L01-A1")
			return list(
				"title" = "Final, quiet break",
				"body" = "**Approved!** HR authorizes a ceremonial **Five-Minute Rest Appreciation Period**, subject to your judgment and immediate operational needs. You are not required to remain at your desk to appreciate the period, though we recommend keeping your paperwork neatly stacked. This letter is a courtesy, not a change to shift duties.",
				"from" = "",
				"options" = list(),
			)
		if("HR-005-L01-A2")
			return list(
				"title" = "Final, social break",
				"body" = "We support healthy social interaction! Unfortunately, your proposal to leave the office introduces a risk that you might enjoy yourself without being available for meetings. Your break is therefore approved as a **Workplace Sociability Reflection Exercise**, best undertaken wherever you deem safe. HR accepts no responsibility for the quality of the conversation.",
				"from" = "",
				"options" = list(),
			)
		if("HR-004-L01-B")
			return list(
				"title" = "On extended vacation",
				"body" = "How wonderful that you are exploring the concept of a vacation. Before we send the request to the Absence Committee, please clarify the reason for this ambitious proposal.",
				"from" = "",
				"options" = list(
				"B1" = "I need genuine rest from extended work responsibilities.",
				"B2" = "I would simply like to experience somewhere that is not this outpost."
			),
			)
		if("HR-005-L01-B1")
			return list(
				"title" = "Final, rest needed",
				"body" = "We recognize the importance of recovery from prolonged work. Unfortunately, HR cannot approve an indefinite absence from your current outpost posting through routine fax correspondence. We can, however, designate this correspondence your **Long-Term Rest Planning Certificate**, confirming that your desire to rest has been professionally acknowledged. Any actual absence from the installation must follow the applicable operational arrangements.",
				"from" = "",
				"options" = list(),
			)
		if("HR-005-L01-B2")
			return list(
				"title" = "Final, dissatisfaction with location",
				"body" = "Your wish to experience somewhere other than your assigned outpost has been recorded as an **Exploratory Attitude**. Facilities advises that an alternate perspective can often be obtained by looking in a different direction. We are pleased to recommend this economical tourism initiative.",
				"from" = "",
				"options" = list(),
			)
		if("HR-004-L01-C")
			return list(
				"title" = "On urgent personal leave",
				"body" = "We are sorry to hear that a personal matter requires attention. We will handle your request with utmost discretion, within the limitations of a fax machine. Please specify the urgency in general terms only.",
				"from" = "",
				"options" = list("C1" = "It concerns my health or immediate wellbeing.", "C2" = "It concerns an unavoidable personal or family obligation."),
			)
		if("HR-005-L01-C1")
			return list(
				"title" = "Final, health concern",
				"body" = "Your wellbeing is more important than our paperwork, which is an exceptionally rare admission from this division. Please seek appropriate medical assistance or take necessary safe action without waiting for administrative permission. We have marked your case **Health Concern Acknowledged**.",
				"from" = "",
				"options" = list(),
			)
		if("HR-005-L01-C2")
			return list(
				"title" = "Final, family or personal obligation",
				"body" = "We understand that personal obligations can arise unexpectedly. HR has approved your request **in principle**, subject to the practical arrangements available to you during your deployment. This fax serves as a **Letter of Understanding**, demonstrating that someone in management is capable of writing the word *understanding*.",
				"from" = "",
				"options" = list(),
			)
		if("HR-003-L02")
			return list(
				"title" = "Workplace Happiness Assessment",
				"body" = "Thank you for contacting our Employee Happiness Division! Recognizing the need for support is a positive step. Our current goal is to increase measured happiness while reducing the number of forms required to measure it, a goal we are not yet close to achieving. What is the main source of your concern?",
				"from" = "",
				"options" = list(
				"A" = "I feel overwhelmed by the workload associated with my posting.",
				"B" = "I have difficulty cooperating with my colleague.",
				"C" = "Working on this remote outpost feels isolating or monotonous."
			),
			)
		if("HR-004-L02-A")
			return list(
				"title" = "On workload stress",
				"body" = "Too many simultaneous responsibilities can be draining, whether they involve stamped task reports and coordination or perimeter patrols, visitor screening and emergency response. Which outcome would help you most?",
				"from" = "",
				"options" = list(
				"A1" = "A more manageable workload or an opportunity to pause.",
				"A2" = "Recognition that my workload has been unusually demanding."
			),
			)
		if("HR-005-L02-A1")
			return list(
				"title" = "Final, manageable workload",
				"body" = "We support your right to arrange work in a reasonable, safe order. HR cannot reprioritize your authorized duties through this fax, but we have approved a handwritten reminder reading **ONE RESPONSIBILITY AT A TIME** for use during non-emergency work. Please remember that urgent hazards should still be handled urgently.",
				"from" = "",
				"options" = list(),
			)
		if("HR-005-L02-A2")
			return list(
				"title" = "Final, acknowledgment",
				"body" = "Your workload has been officially classified as **Noticeably Work-Shaped**. We appreciate your efforts in fulfilling the responsibilities of your outpost posting. This fax constitutes a **Certificate of Continued Occupational Endurance**, carrying no monetary value but a generous allotment of ink.",
				"from" = "",
				"options" = list(),
			)
		if("HR-004-L02-B")
			return list(
				"title" = "On colleague relations",
				"body" = "We applaud your desire for a happier workplace! Relationships can be improved through mutual respect, constructive dialogue, and, where necessary, separate rooms. What sort of support would be most useful?",
				"from" = "",
				"options" = list("B1" = "A cooperative activity with the colleague concerned.", "B2" = "Formal help settling a disagreement."),
			)
		if("HR-005-L02-B1")
			return list(
				"title" = "Final, teamwork activity",
				"body" = "Congratulations! You may invite a fellow outpost employee to participate in the **Mutual Appreciation Exercise**. Each participant is encouraged to offer one sincere compliment and one observation about the other person's actual duties. The exercise is entirely optional, and no reward depends on participation. HR reminds you that sarcasm must be declared in advance.",
				"from" = "",
				"options" = list(),
			)
		if("HR-005-L02-B2")
			return list(
				"title" = "Final, mediation",
				"body" = "Our mediation specialists have examined your request and concluded that the first step toward resolution is listening. We recommend discussing the issue directly if appropriate, or using the dedicated grievance process for a specific complaint. To help, this fax serves as a **Neutral Phrase Reference Card** featuring “I hear your concern” and “Please stop stamping my paperwork.”",
				"from" = "",
				"options" = list(),
			)
		if("HR-004-L02-C")
			return list(
				"title" = "On isolation and monotony",
				"body" = "Remote office assignments can feel lonely, particularly when one's most reliable correspondent is a printer. Which of these initiatives would you prefer?",
				"from" = "",
				"options" = list(
				"C1" = "Something entertaining to make the workplace less monotonous.",
				"C2" = "More opportunity for meaningful interaction with other people."
			),
			)
		if("HR-005-L02-C1")
			return list(
				"title" = "Final, entertainment",
				"body" = "The Employee Happiness Division is pleased to launch its **Five-Minute Office Entertainment Programme**. Suggested activities include identifying shapes in nearby nebulae, alphabetizing your complaints, and guessing what the fax machine will print next. Approved games and small recreational supplies may also be requested through proper supply channels if authorized. For a limited engagement, Central Command has approved the dispatch of a certified Corporate Morale Clown by supply pod to the Liaison Outpost office. Please note that honking is the sole deliverable specified in the entertainer's contract.",
				"from" = "",
				"options" = list(),
			)
		if("HR-005-L02-C2")
			return list(
				"title" = "Final, social contact",
				"body" = "We encourage responsible cooperation with other outpost staff and appropriate contact with nearby installations through existing authorized communications. This fax serves as a **Professional Small-Talk Prompt Sheet**: “How was your latest incident report?” and “Have you considered a more efficient filing system?” Please do not use restricted administrative terminals without authorization.",
				"from" = "",
				"options" = list(),
			)
		if("R01")
			return list(
				"title" = "Reduction of Paper Consumption",
				"body" = "To demonstrate our commitment to sustainability, employees are encouraged to reduce unnecessary paperwork wherever practical. A four-page memorandum explaining the policy has been drafted, but its printing has been suspended in the interests of paper conservation. This single-page notice therefore constitutes the entire initiative. Its printing cost is classified as environmental education and exempt from the new restrictions.",
				"from" = "W",
				"options" = list(),
			)
		if("R02")
			return list(
				"title" = "Workplace Satisfaction Monitoring",
				"body" = "We are delighted to announce that the latest Happiness Pulse will assess morale across all outposts. Employees should select the statement that best describes their current wellbeing: **Extremely Happy**, **Very Happy**, or **Seeking Approval to Become Extremely Happy**. Please do not attempt to return this notice as an HR-001 form. Your participation has already been appreciated on your behalf.",
				"from" = "L",
				"options" = list(),
			)
		if("R03")
			return list(
				"title" = "Coffee Quality Clarification",
				"body" = "In the event that coffee is available through the outpost's approved requisition channels, Facilities reminds staff that the term “terrible” lacks scientific precision. Unappetizing coffee should instead be described as **Robustly Corporate**. The terminology change is expected to improve satisfaction metrics without requiring us to purchase coffee.",
				"from" = "W",
				"options" = list(),
			)
		if("R04")
			return list(
				"title" = "Emergency Vocabulary Management",
				"body" = "The term *emergency* must be reserved for events presenting immediate operational risk. Examples do not include missing pens, lukewarm refreshments, or a colleague's refusal to appreciate your organizational system. A genuine emergency should still be handled immediately. Please complete the appropriate paperwork afterward, when you are sufficiently alive to do so.",
				"from" = "G",
				"options" = list(),
			)
		if("R05")
			return list(
				"title" = "Employee of the Month Programme",
				"body" = "HR is pleased to announce that the Employee of the Month award has been suspended pending a review of whether the award creates unequal outcomes. All employees are therefore considered equally eligible for **Employee of an Indeterminate Period**. Certificates may be printed at employee expense.",
				"from" = "L",
				"options" = list(),
			)
		if("R06")
			return list(
				"title" = "Furniture Inventory Compliance",
				"body" = "Facilities requests that personnel count any chairs currently present at the outpost. A chair moved without prior authorization may be reclassified as **Mobile Furniture** and entered into a separate register. Please do not report an absent chair as having gone missing unless it existed in the first place. This notice does not authorize new furniture requisitions.",
				"from" = "W",
				"options" = list(),
			)
		if("R07")
			return list(
				"title" = "Workplace Civility",
				"body" = "Employees are encouraged to compliment their colleagues periodically. Acceptable statements include “Your paperwork is legible” and “Your presence was helpful during that incident.” Statements such as “You are tolerable today” should be used only when accompanied by a smile and supporting evidence.",
				"from" = "G",
				"options" = list(),
			)
		if("R08")
			return list(
				"title" = "Information Security",
				"body" = "Confidential correspondence should be treated with care. In particular, employees must not leave sensitive records unattended in publicly accessible areas. As an example of appropriate handling, this reminder contains no sensitive information whatsoever, except the fact that several departments have repeatedly required such reminders.",
				"from" = "G",
				"options" = list(),
			)
		if("R09")
			return list(
				"title" = "Celebrating Our Corporate Family",
				"body" = "This week is Company Loyalty Week. Staff are invited to reflect upon the many benefits of serving Nanotrasen, including professional development, close proximity to paperwork, and the possibility of future benefits. Celebration expenses are not reimbursable. We encourage enthusiastic participation within your ordinary duties.",
				"from" = "L",
				"options" = list(),
			)
		if("R10")
			return list(
				"title" = "Break Scheduling Efficiency",
				"body" = "HR supports the concept of adequate rest. However, recent financial modeling suggests that scheduling breaks exclusively during employees' free time produces excellent productivity results. This is a recommendation from Finance, not a revision of the outpost's operational or safety requirements. Please direct any concerns to the department that authored it, which is unavailable.",
				"from" = "C",
				"options" = list(),
			)
		if("R11")
			return list(
				"title" = "Shared Office Resources",
				"body" = "A reminder that official Central Command stamps are corporate assets, not hereditary property.\n\nEmployees who identify a particular stamp as “mine” are encouraged to rephrase this as “the stamp I am currently entrusted to safeguard.”\n\nHuman Resources has received several concerning reports of employees claiming exclusive stamping privileges, withholding stamps from colleagues, and questioning the legitimacy of documents stamped by others.\n\nPlease remember that possession of an official stamp does not grant its holder additional authority, regardless of how enthusiastically they apply it.\n\nDo not begin a physical dispute over office stationery. Human Resources will not be issuing a formal ruling on stamp custody.",
				"from" = "G",
				"options" = list(),
			)
		if("R12")
			return list(
				"title" = "Measuring Workplace Contentment",
				"body" = "HR has introduced the **Voluntary Mandatory Contentment Index**. The metric is calculated using employee smiles, completed surveys, and the percentage of reported unhappiness successfully reclassified as feedback. We are delighted to report that preliminary results are excellent, though no surveys have yet been returned.",
				"from" = "L",
				"options" = list(),
			)
		if("R13")
			return list(
				"title" = "Professional Appearance",
				"body" = "Central Command reminds staff that clothing should project administrative credibility. Ceremonial capes, novelty hats, and suspiciously theatrical uniforms may be appropriate at authorized receptions, but should not replace assignment-appropriate protective clothing or official dress during formal administrative proceedings. Approved novelty attire is not a substitute for required security equipment.",
				"from" = "G",
				"options" = list(),
			)
		if("R14")
			return list(
				"title" = "Corporate Financial Discipline",
				"body" = "Due to economic uncertainty, Finance encourages all employees to practice fiscal restraint. This includes questioning unnecessary purchases, minimizing luxury expenses, and maintaining realistic expectations regarding salary increases. Executive retention bonuses are managed by a different department and must not be used for comparison purposes.",
				"from" = "C",
				"options" = list(),
			)
		if("R15")
			return list(
				"title" = "Responsible Use of Communication Equipment",
				"body" = "Fax machines are intended for professional correspondence. We strongly discourage repeatedly transmitting the same document, sending prank paperwork to unknown departments, or using the printer to settle arguments about who is in charge. HR recognizes the unfortunate irony of sending this reminder via fax and requests that it not be discussed.",
				"from" = "G",
				"options" = list(),
			)
		if("R16")
			return list(
				"title" = "Recognition of Balanced Lifestyles",
				"body" = "All employees are hereby awarded an electronic acknowledgment of their commitment to work-life balance. Whether a balance has actually been achieved is outside the scope of this initiative. Please remember that the certificate is not itself a vacation, rest period, or reason to stop responding to emergencies.",
				"from" = "L",
				"options" = list(),
			)
		if("R17")
			return list(
				"title" = "Decorative Vegetation Responsibility",
				"body" = "Should decorative plants ever be approved and installed at this outpost, Facilities reminds the staff that they are not inherently self-maintaining. If a plant becomes unwell, do not assign responsibility to another plant. The correct procedure is to identify the employee who requested the decoration, preferably before it ceases being decorative.",
				"from" = "W",
				"options" = list(),
			)
		if("R18")
			return list(
				"title" = "Administrative Efficiency",
				"body" = "To reduce time lost in unnecessary meetings, HR will convene a committee to determine which meetings are unnecessary. Preliminary planning requires two introductory meetings and a review meeting to discuss the introductory meetings. Your attendance is not required, but minutes may be circulated regardless.",
				"from" = "G",
				"options" = list(),
			)
		if("R19")
			return list(
				"title" = "Social Cohesion Development",
				"body" = "Friendly conversation improves workplace culture. Suggested discussion topics include your favorite filing method, the current sector traffic conditions, and which department is least likely to answer a request promptly. Please avoid discussing salaries within earshot of Finance personnel. Their morale is fragile.",
				"from" = "L",
				"options" = list(),
			)
		if("R20")
			return list(
				"title" = "Standardized Apology Templates",
				"body" = "When apologizing to a colleague, HR recommends using the phrase **“I regret the administrative inconvenience caused by my actions.”** Please avoid apologizing on behalf of the corporation unless specifically authorized. The corporation retains exclusive authority to decide whether it has done anything wrong.",
				"from" = "G",
				"options" = list(),
			)
		if("R21")
			return list(
				"title" = "Informal Workplace Customs",
				"body" = "Facilities has learned that some outposts establish unofficial traditions involving office furniture, novelty decorations, or ceremonial desk ownership. Such customs, including the ceremonial use of approved entertainment or reception supplies, are permitted so long as they do not obstruct operations, damage equipment, authorize unapproved requisitions, or require reimbursement. Any tradition that survives three shifts may be submitted for classification as an **Established Informal Procedure**.",
				"from" = "W",
				"options" = list(),
			)
		if("R22")
			return list(
				"title" = "Celebrations and Cake Allocation",
				"body" = "Human Resources celebrates the continued existence of its employees. Birthdays may be acknowledged with verbal good wishes and, if properly requisitioned and available, celebratory refreshments or cake. Please do not submit invoices for celebratory candles. Our department has already been investigated for an excessive birthday-cake forecast.",
				"from" = "L",
				"options" = list(),
			)
		if("R23")
			return list(
				"title" = "Workplace Performance Expectations",
				"body" = "HR reminds personnel that unusually competent colleagues are not automatically engaged in misconduct. They may simply understand their duties. Reports of **suspicious competence** should include objective evidence, preferably beyond the statement “they seem too organized.” Inappropriate allegations can lead to additional forms for everyone involved.",
				"from" = "G",
				"options" = list(),
			)
		if("R24")
			return list(
				"title" = "Updated Human Resources Values",
				"body" = "After an extensive consultation process, Human Resources has adopted a new mission statement: **“We are here to help, insofar as helping is compatible with policy.”** This represents a major commitment to service excellence. Employees are encouraged to memorize the statement, but requests to place it on paid working time will not be considered.",
				"from" = "C",
				"options" = list(),
			)
		if("P01")
			return list(
				"title" = "Approved Compensation Adjustment, Stage I",
				"body" = "A routine review of your administrative output indicates that you have now completed **%ASSIGNMENTS% qualifying assignments**. This has placed your productivity marginally above the threshold at which the corporation is legally and emotionally comfortable increasing your salary.\n\nYour recurring compensation has been adjusted from **%OLD_PAY% to %NEW_PAY% credits per pay cycle**.\n\nPlease understand that this change is not a promotion in rank, a guarantee of future prosperity, or authorization to order more expensive coffee. It is simply a budgetary acknowledgment that we can no longer pretend your work has gone unnoticed.\n\nCongratulations on reaching the minimum standard for financial optimism.\n\n*“At Nanotrasen, your success is our controlled expense.”*",
				"from" = "C",
				"options" = list(),
			)
		if("P02")
			return list(
				"title" = "Unscheduled Compensation Review, Stage II",
				"body" = "Our payroll monitors have identified a recurring pattern of competence associated with your employment. This is unusual enough to warrant review. Following considerable resistance from Finance, HR has authorized another adjustment.\n\nYour recurring compensation has increased from **%OLD_PAY% to %NEW_PAY% credits per pay cycle**.\n\nAs part of this adjustment, you are now classified as a **Financially Inconvenient High Performer**. This distinction carries no additional privileges and should not be disclosed during negotiations with your colleagues.\n\nWe request that you maintain your present output without doing anything further that might justify another increase.\n\n*“Your achievements are making the forecast more difficult.”*",
				"from" = "C",
				"options" = list(),
			)
		if("P03")
			return list(
				"title" = "Final Authorized Compensation Review, Stage III",
				"body" = "It is with professionally controlled reluctance that we acknowledge your continued administrative effectiveness. Despite repeated opportunities to return to ordinary productivity, you have reached the maximum compensation tier currently approved for your outpost assignment.\n\nYour recurring compensation has increased from **%OLD_PAY% to %NEW_PAY% credits per pay cycle**.\n\nThis represents the final scheduled performance-based increase available in your present position. Further requests for additional compensation should be directed to the Department of Unreasonable Expectations, currently operating out of my office.\n\nPlease accept our sincere congratulations, which are considerably less expensive than your salary.\n\n*“We have reviewed the numbers. Unfortunately, they are correct.”*",
				"from" = "C",
				"options" = list(),
			)
	return null

