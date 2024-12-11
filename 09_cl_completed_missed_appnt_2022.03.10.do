//This do file extracts and cleans planned, completed, and missed IAPT appointments
//Gemma Taylor
//2022 03 10

//set drive
cd "/Volumes/GMJTaylor/CRUK Fellowship/Trial/Results/REDCAP data"

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

		//save data to recall and save for 3 and 6 months cleaning
		compress
		save working_data/dates, replace
	
	//keep three month data only and save
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

	//clean 3 and 6 month datasets and create variables needed for analysis 	
		foreach i in 3 6 {
		use working_data/dates_`i'm,replace

		//replace ou_attendance_yn where missing to replicate the first appointment attendance value, but one line below so that we can add it to the 2-10 appointment data
		replace ou_attendance_yn =  ou_attendance_yn_a1 if  ou_attendance_yn==.
			
		//gen variable to indicate the count number of appointments completed for each participant 
		egen n_complete = count(ou_attendance_yn) if  ou_attendance_yn==1, by (pcmis_iaptus_no)

		//gen variable to indicate the count number of appointments missed for each participant
		egen n_missed = count(ou_attendance_yn) if  ou_attendance_yn==0, by (pcmis_iaptus_no)

		//gen new variable to indicate max n compelte or missing within person, so that we can keep one value for each variable within participant
		egen new_n_compelete= max (n_complete),  by (pcmis_iaptus_no)
		egen new_n_missed= max (n_missed),  by (pcmis_iaptus_no)

		drop n_missed n_complete
		rename new_n_compelete n_complete_appt_`i'm
		rename new_n_missed n_missed_appt_`i'm

		//save data
		label variable n_complete "Number of completed iapt appointments between baseline and `i' months follow-up acording to appointment data"
		label variable n_missed "Number of missed iapt appointments between baseline and `i' months follow-up acording to appointment data"
		keep pcmis_iaptus_no n_complete_appt_`i'm n_missed_appt_`i'm
		duplicates drop pcmis_iaptus_no n_complete_appt_`i'm n_missed_appt_`i'm, force
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

	//merge appointment data, follow-up data with randomisation status and resave ready for analysis
		foreach i in 3 6 {	
			use working_data/completed_missed_BLto`i', clear
			merge 1:1 pcmis_iaptus_no using working_data/completed_missed_`i'm
			drop _m
			merge 1:1 	pcmis_iaptus_no using "working_data/randomisation_complete"
			drop _m	
			compress
			save working_data/service_outcomes_`i'm, replace
			}

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
	drop if iapt_non_attend_reason1=="" & iapt_non_attend_reason2=="" & iapt_discontinue_reason==""
	compress
	order id allocation site iapt_discontinue_reason iapt_non_attend_reason1 iapt_non_attend_reason2
	sort  site allocation
	compress
	export excel using  "/Volumes/GMJTaylor/CRUK fellowship/Trial/Results/paper_tables_figures/reasons_discontinuation_non-attendance.xlsx", firstrow(variables) replace

	

	

