//This do file extracts and cleans service-related feasibility outcomes (planned, completed, and missed IAPT appointments)
//Gemma Taylor
//2024 05 17


//set drive
 cd "X:\Psychology\ResearchProjects\GMJTaylor\CRUK Fellowship\Trial\Results\REDCAP data"

//extract appointment data from clinical data between baseline and 3 months
use "working_data/clinical.dta", replace

	//keep only IAPT appointment data
	keep pcmis_iaptus_no ou_appt_date_a1 ou_attendance_yn_a1 ou_appt_nonattendance 	///
	ou_non_attend_rsn_a1  ou_appt_date ou_attendance_yn  redcap_event_name ou_bl_date ou_appt_date_a1 ou_appt_date ///
	 	 
	//order variables	
	order pcmis_iaptus_no redcap_event_name ou_bl_date ou_appt_date_a1 ou_attendance_yn_a1 ou_appt_nonattendance ou_non_attend_rsn_a1 ou_appt_date ou_attendance_yn 

	//keep attempt data that was recorded before or on `i'-month follow-up date
		//copy baseline date within patient & set random sorting seed
		set seed 1369841
		gen double random=runiform()
		bysort pcmis_iaptus_no (random): egen copy_ou_bl_date = max(ou_bl_date)	
		format copy_ou_bl_date %dM_d,_CY

		//gen difference variable for the difference between baseline and appointment dates
		gen diff=ou_appt_date_a1-copy_ou_bl_date
		replace diff=ou_appt_date-copy_ou_bl_date if diff==.

		//save data to recall and save for 3 and 6 months cleaning.	
		compress
		save working_data/dates, replace
	
	//keep three month data only and save
		compress
		use working_data/dates, clear
	
		//drop if difference is more than 120 days
		gen drop=1 if diff>125 & diff!=.
		compress
		save working_data/dates_3m,replace
	
	//keep three month data only and save
		use working_data/dates, clear
		//drop if difference is more than 120 days
		gen drop=1 if diff>250 & diff!=.
		compress
		save working_data/dates_6m,replace

	//clean 3 and 6 month datasets and create variables needed for analysis (Note:doing this for completed and missed data only, as there were problems with recording the number of planned appointments during the appointment data extraction)
		foreach i in 3 6 {
		use working_data/dates_`i'm,replace

		//replace ou_attendance_yn where missing to replicate the first appointment attendance value, but one line below so that we can add it to the 2-10 appointment data
		replace ou_attendance_yn =  ou_attendance_yn_a1 if  ou_attendance_yn==.
			
		//gen variable to indicate the count number of appointments completed for each participant 
		egen n_complete_`i' = count(ou_attendance_yn) if  ou_attendance_yn==1, by (pcmis_iaptus_no)

		//gen variable to indicate the count number of appointments missed for each participant
		egen n_missed = count(ou_attendance_yn) if  ou_attendance_yn==0, by (pcmis_iaptus_no)

		//gen new variable to indicate max n compelte or missing within person, so that we can keep one value for each variable within participant
		egen new_n_complete= max (n_complete_`i'),  by (pcmis_iaptus_no)
		egen new_n_missed= max (n_missed),  by (pcmis_iaptus_no)

		drop n_missed n_complete_`i'
		rename new_n_complete n_complete_appt_`i'm
		rename new_n_missed n_missed_appt_`i'm

		//save data
		label variable n_complete_appt_`i' "Number of completed IAPT appointments between baseline and `i' months follow-up acording to appointment data"
		label variable n_missed_appt_`i' "Number of missed IAPT appointments between baseline and `i' months follow-up acording to appointment data"

		keep pcmis_iaptus_no n_complete_appt_`i'm n_missed_appt_`i'm
		duplicates drop pcmis_iaptus_no n_complete_appt_`i'm  n_missed_appt_`i'm, force
		compress
		save working_data/completed_missed_BLto`i', replace
		}

	//extract 3 and 6 months data for appointment keep relevant variables
		foreach i in 3 6 {		
			use "working_data/clinical.dta", replace
			keep if redcap_event_name== "`i'_month_follow_up_arm_1"
			keep pcmis_iaptus_no redcap_event_name iapt_attended_3m iapt_planned_3m iapt_dna_3m iapt_completed_treatment iapt_discontinue_treatment iapt_ongoing_treatment		
			order pcmis_iaptus_no redcap_event_name iapt_attended_3m iapt_planned_3m iapt_dna_3m iapt_completed_treatment iapt_discontinue_treatment iapt_ongoing_treatment		
			//open recently cleaned data and bring in 3 and 6 month variables that are the same			
			compress
			save working_data/completed_missed_`i'm, replace
			}
		 
//merge appointment data, follow-up data with randomisation status and resave ready for analytical file
		foreach i in 3 6 {	
			use working_data/completed_missed_BLto`i', clear
			merge 1:1 pcmis_iaptus_no using working_data/completed_missed_`i'm
			drop _m
			merge 1:1 	pcmis_iaptus_no using "working_data/randomisation_complete"
			compress
			drop _m	 redcap_event_name
			order pcmis_iaptus_no rand_allocation site 
		
			//determine if the data about "missed/DNA" data and "attended/completed" are the same. Keep the higher value, and keep whichever value is not missing
			gen n_compl_apt_`i'm = max(n_complete_appt_`i'm, iapt_attended_3m )
			drop  n_complete_appt_`i'm iapt_attended_3m 
			gen n_missed_apt_`i'm = max(n_missed_appt_`i'm, iapt_dna_3m )
			drop  n_missed_appt_`i'm iapt_dna_3m

			//rename variables to indicate they're at `i' month follow-up
			foreach var in iapt_completed_treatment iapt_discontinue_treatment iapt_ongoing_treatment {
				rename `var' `var'_`i'm
				}
			rename iapt_planned_3m n_planned_apt_`i'm
			label variable n_missed_apt_`i'm "Num of missed appointments (combined appointment and `i'm follow-up data)"
			label variable n_compl_apt_`i'm "Num of completed appointments (combined appointment and `i'm follow-up data)"
			label variable n_planned_apt_`i'm "Num of planned appointments (follow-up data only)"
			label variable iapt_completed_treatment_`i'm "`i' month follow-up treatment completion status"
			label variable iapt_discontinue_treatment_`i'm "`i' month follow-up treatment discontinuation status"
			label variable iapt_ongoing_treatment_`i'm "`i' month follow-up treatment ongoing status"
			
			/*//assume missing data ==0
			foreach var in iapt_completed_treatment_`i'm iapt_discontinue_treatment_`i'm iapt_ongoing_treatment_`i'm {
				replace `var'=0 if `var'==. 
				} */
			
			//assume "9 n/a" data ==.
			foreach var in iapt_completed_treatment_`i'm iapt_discontinue_treatment_`i'm iapt_ongoing_treatment_`i'm {
				replace `var'=. if `var'==9
				}
			
			//compress, order and save
			compress
			order pcmis_iaptus_no rand_allocation site 
			compress
			save working_data/complete_case_service_outcomes_`i'm, replace
			}
						
	
	
	//merge service outcomes files at 3 & 6 months follow-up to create analytical file
		use working_data/complete_case_service_outcomes_3m, clear
		merge 1:1 	pcmis_iaptus_no using working_data/complete_case_service_outcomes_6m
		drop _m 
		compress
		save working_data/complete_case_service_outcomes_analysis, replace
	
	
	
	
//extract reasons why iapt discontinued and reasoned for non-attendance from cappointment and follow-up data
	use "working_data/clinical.dta", clear
	keep pcmis_iaptus_no redcap_event_name iapt_discontinue_reason ou_non_attend_rsn_a1 ou_non_attend_rsn
	order pcmis_iaptus_no redcap_event_name iapt_discontinue_reason ou_non_attend_rsn_a1 ou_non_attend_rsn
	append using "working_data/randomisation_complete"
	bysort pcmis_iaptus_no (rand_allocation): egen allocation = max(rand_allocation)	
	label values allocation rand_allocation_
	drop rand_allocation redcap_event_name
	gen id = pcmis_iaptus_no
	replace id= substr(id, 2, 6)	
	drop pcmis_iaptus_no
	 
	duplicates drop id iapt_discontinue_reason ou_non_attend_rsn_a1 ou_non_attend_rsn, force
	rename ou_non_attend_rsn_a1 iapt_non_attend_reason1
	rename ou_non_attend_rsn iapt_non_attend_reason2
	
	order id allocation site iapt_discontinue_reason iapt_non_attend_reason1 iapt_non_attend_reason2
	cd "/Volumes/GMJTaylor/CRUK Fellowship/Trial/Results/paper_tables_figures"
	compress
	export excel using  "reasons_discontinuation_non-attendance.xlsx", firstrow(variables) replace

	/*

//extract duration between enrollment and first appointment
	use "working_data/clinical.dta", clear
	keep if redcap_event_name=="baseline_arm_1"
	merge 1:1 pcmis_iaptus_no using working_data/admin
	keep  pcmis_iaptus_no rand_dte ou_bl_date
	gen diff=ou_bl_date- rand_dte
	replace diff = -diff if diff<0
	sum diff
*/
