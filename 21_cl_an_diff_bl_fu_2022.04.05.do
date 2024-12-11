//This do file gives the duration between 1st iapt appointment and 3 and 6 months follow-up
//Gemma Taylor 
//2022 04 05

//set path
cd "/Volumes/GMJTaylor/CRUK Fellowship/Trial/Results/REDCAP data/" 

//open data and save "pre-clinical baseline" dates
	use  "working_data/clinical.dta", replace
		keep if redcap_event_name== "baseline_arm_1" 
		keep ou_bl_date pcmis_iaptus_no 
		save "working_data/ou_bl_date", replace 

//open data and save 3 and 6 month follow-up dates
	foreach i in 3 6 {
		use  "working_data/clinical.dta", replace
		keep if redcap_event_name== "`i'_month_follow_up_arm_1" 
		keep ou_appt_date_3m pcmis_iaptus_no 
		rename ou_appt_date_3m ou_appt_date_`i'm
		save "working_data/`i'_month_follow_up_arm_1", replace 
		}

//open randomisation data
	use "working_data/admin", replace 
	keep pcmis_iaptus_no rand_allocation randomisation_complete rand_dte
	drop if 	randomisation_complete!=2
	drop randomisation_complete
	//bring in baseline date, and follow-up dates
	foreach i in ou_bl_date 3_month_follow_up_arm_1 6_month_follow_up_arm_1	 {
		merge 1:1  pcmis_iaptus_no using working_data/`i'
		drop _m 
		}

order pcmis_iaptus_no rand_allocation rand_dte ou_bl_date ou_appt_date_3m ou_appt_date_6m
save "working_data/cl_an_diff_bl_du", replace 

//what is the difference between dates
use "working_data/cl_an_diff_bl_du", clear 

	//difference between rand_allocation and "baseline" date between trial arms.
	gen diff_rand_bl=ou_bl_date-rand_dte	
	
	//difference between baseline and 3 month follow-up
	foreach i in 3 6  {
	gen diff_oubl_`i'm=ou_bl_date-ou_appt_date_`i'm
	}
	
	//t-tests to see if there's a difference in n days difference
	foreach i in diff_rand_bl diff_oubl_3m diff_oubl_6m {
	ttest `i', by (rand_allocation)
	}

 
