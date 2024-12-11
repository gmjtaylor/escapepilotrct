//This do file generates log with CONSORT flow chart data
//Gemma Taylor 
//2022 03 10

//Set log 
log using "/Volumes/GMJTaylor/CRUK Fellowship/Trial/Results/paper_tables_figures/flowchart", replace

//Set path
cd "/Volumes/GMJTaylor/CRUK Fellowship/Trial/Results/REDCAP data"

//Allocation
	//clean data - recieved allocated intervention? (3 ways to look at these data so merge data from clinical notes, and question about correct allocation at followup")
		//looking at iapt_appointment_1_arm_1  iapt_appointment_1_arm_1b data to determine if they attended first appointment
		use "working_data/admin.dta", clear
		merge 1:m pcmis_iaptus_no using "working_data/clinical.dta"
		keep if redcap_event_name== "iapt_appointment_1_arm_1"
		gen received_bl=1 if sctd_yn==1 & rand_allocation==1
		replace received_bl=1 if sctd_end_yn==0 & received==. & rand_allocation==1
		replace received_bl=0 if sctd_end_yn==1 & received==. & rand_allocation==1
		keep pcmis_iaptus_no received_bl
		compress
		save  working_data/received_bl, replace

		//looking at follow-up data
		foreach i in 3 6 {
		use "working_data/clinical.dta", clear
		keep if redcap_event_name== "`i'_month_follow_up_arm_1" 
		gen received_`i'=1 if intervention_receipt==1
		replace received_`i'=0 if intervention_receipt==0
		rename intervention_receipt_note intervention_receipt_note_`i'
		keep pcmis_iaptus_no received_`i' intervention_receipt_note_`i'
		compress
		save  working_data/received_`i', replace
		}
		
		//merge appointment and clinical reasons for non-recipt
		use "working_data/admin.dta", clear
		foreach var in received_bl received_3 received_6 {
			merge 1:1 pcmis_iaptus_no using "working_data/`var'.dta"
			drop _m
			}
		drop if rand_allocation==.
		keep pcmis_iaptus_no rand_allocation received_bl received_3 received_6 intervention_receipt_note_3 intervention_receipt_note_6

		//gen variable to indicate reciept my merging all recipt data
		gen recieved = received_6
		replace recieved=received_3 if recieved==.
		replace recieved=received_bl if recieved==.
		replace recieved=1 if recieved==.

		//look at reasons for non-recipet - need to do this manually to some extent. Do not assume if people have recieved or not, and take numbers for flow chart 
		replace intervention_receipt_note_3= intervention_receipt_note_6 if intervention_receipt_note_3==""
		drop intervention_receipt_note_6

		sort rand_allocation intervention_receipt_note_3

	//How many did not recieve allocated intervention
		tab  rand_allocation recieved

	//Reasons for non-reciept
		//data saved in **MUST UPDATE THIS FILE USING BROWSE /Volumes/GMJTaylor/CRUK Fellowship/Trial/Results/REDCAP data/reasonsfornonreciept_030222.xlsx
		sort rand_allocation intervention_receipt_note_3
		/*browse pcmis_iaptus_no rand_allocation intervention_receipt_note_3 if recieved==0 */
		import excel "/Volumes/GMJTaylor/CRUK Fellowship/Trial/Results/REDCAP data/reasonsfornonreciept_030222.xlsx", sheet("Sheet2") firstrow clear

//Follow-up - loss to follow-up 
	//extract data from 3 and 6 months
	foreach i in 3 6 {
		use "working_data/clinical.dta", clear
		keep if redcap_event_name== "`i'_month_follow_up_arm_1" 
		keep pcmis_iaptus_no stop_study difficulty_contacting
		rename stop_study stop_study`i'
		rename difficulty_contacting difficulty_contacting`i'
		compress
		save working_data/followup`i', replace
		}
	
	use "working_data/admin.dta", clear
	keep   pcmis_iaptus_no rand_allocation
	drop if rand_allocation==.
	merge 1:1  pcmis_iaptus_no using working_data/followup3.dta
	drop _m
	merge 1:1  pcmis_iaptus_no using working_data/followup6.dta
	drop _m
	
	//gen var to indicate if someone was difficult to contact or requested to stop doing followups
	
		//reasons for loss to follow-up by arm
			//n lost to follow-up at 3m
			foreach i in 3 6 {
			gen ltfu`i'="difficulty contacting" if difficulty_contacting`i'==1
			replace ltfu`i'="request to stop providing data" if stop_study`i'==1 & ltfu`i'==""
			}
		
			//how many lost to follow-up at 3ms and reasons why
			tab ltfu3 rand_allocation
			tab ltfu6 rand_allocation

//Follow-up - discontinued intervention w reasons
		
	//how many discontinued the intervention, and why (use data made by 13_clean do file
	use working_data/_analysis_smoking_session_out, clear
	keep date3m date6m smoke_discon smoke_discon_date smoke_discon_reason pcmis_iaptus_no rand_allocation
	replace smoke_discon_reason=9 if smoke_discon_reason==. & smoke_discon==1

	//3 months
	tab smoke_discon rand_allocation if smoke_discon_date<=date3m
	tab smoke_discon_reason rand_allocation if smoke_discon_date<=date3m

	//6 months
	tab smoke_discon rand_allocation if smoke_discon_date<=date6m & smoke_discon_date>=date6m
	tab smoke_discon_reason rand_allocation if smoke_discon_date<=date6m & smoke_discon_date>=date6m

//close log
log close

	
	

