//This do file extracts and Smoking cessation treatment-related feasibility outcomes 
	//IAPT sessions delievered, smoking sessions completed, x not-completed
	//number requesting to stop treatment in treatment arm
	//duration of sessions in minutes 
	//medications used
//Gemma Taylor
//2022 03 10

//install missings
/*ssc install missings*/

//set drive 
cd "/Volumes/GMJTaylor/CRUK Fellowship/Trial/Results/REDCAP data/"

//in the treatment arm x IAPT sessions were delivered. 
	//open appointment data from clinical data 
	use pcmis_iaptus_no redcap_event_name ou_appt_date_a1 ou_appt_date sctd_yn sctd_yn_s2_6 using "working_data/clinical.dta", replace
	order pcmis_iaptus_no redcap_event_name ou_appt_date_a1 ou_appt_date sctd_yn sctd_yn_s2_6 
	destring, replace
	compress

	//set random seed for sorting purposes
	set seed 1369841
	gen double random=runiform()

	//gen variable indicating merged session 1 and session 2-10 data, assuming that missing sctd_yn are 0 if there is a date recorded but no sctd_yn
	gen sess_attem_imputed= 1 if ou_appt_date_a1!=.
	replace sess_attem_imputed = 1 if ou_appt_date!=.
	bysort pcmis_iaptus_no (random): egen sess_attem_imputed_count = count(sess_attem_imputed) 
	drop sess_attem_imputed
	rename sess_attem_imputed_count sess_attem_imputed
	
	//keep 1 record per participant, and save variable to merge for analytical file. 
	keep pcmis_iaptus_no sess_attem_imputed random
	bysort pcmis_iaptus_no (random): keep if _n==1.
	label variable sess_attem_imputed "Count number of IAPT appointments per participant"
	drop random
	compress
	save working_data/sess_attem_imputed, replace

//x smoking sessions completed
	use pcmis_iaptus_no redcap_event_name ou_appt_date_a1 ou_appt_date sctd_yn sctd_yn_s2_6 using "working_data/clinical.dta", replace
	order pcmis_iaptus_no redcap_event_name ou_appt_date_a1 ou_appt_date sctd_yn sctd_yn_s2_6 
	destring, replace
	compress
	
	//set random seed for sorting purposes
	set seed 1369841
	gen double random=runiform()

	//gen variable indicating the number of completed smoking cessation sessions
	gen smoke_sess_compl= sctd_yn 
	replace smoke_sess_compl = sctd_yn_s2_6 if smoke_sess_compl==.
	label values smoke_sess_compl sctd_yn_
	bysort pcmis_iaptus_no (random): egen smoke_sess_compl_count = count(smoke_sess_compl) if smoke_sess_compl==1
	
	//keep 1 record per participant, and save variable to merge for analytical file. 
	keep pcmis_iaptus_no smoke_sess_compl_count random
	drop if smoke_sess_compl_count==.
	bysort pcmis_iaptus_no (random): keep if _n==1.
	rename smoke_sess_compl_count smoke_sess_compl
	label variable smoke_sess_compl "Number of smoking treatment sessions completed"
	drop random
	compress
	save working_data/smoke_sess_compl, replace

//x smoking sessions not completed
	use pcmis_iaptus_no redcap_event_name ou_appt_date_a1 ou_appt_date sctd_yn sctd_yn_s2_6 sctd_no_reason_s2_6 using "working_data/clinical.dta", replace
	order pcmis_iaptus_no redcap_event_name ou_appt_date_a1 ou_appt_date sctd_yn sctd_yn_s2_6 
	destring, replace
	
	//set random seed for sorting purposes
	set seed 1369841
	gen double random=runiform()

	//gen variable indicating the number of non-completed smoking cessation sessions
	gen smoke_sess_ncompl= sctd_yn 
	replace smoke_sess_ncompl = sctd_yn_s2_6 if smoke_sess_ncompl==.
	label values smoke_sess_ncompl sctd_yn_
	bysort pcmis_iaptus_no (random): egen smoke_sess_ncompl_count = count(smoke_sess_ncompl) if smoke_sess_ncompl==0
	
	//keep 1 record per participant, and save variable to merge for analytical file. 
	keep pcmis_iaptus_no smoke_sess_ncompl_count random
	drop if smoke_sess_ncompl_count==.
	bysort pcmis_iaptus_no (random): keep if _n==1.
	drop random
	rename smoke_sess_ncompl_count smoke_sess_ncompl
	
	//keep variables, label and save for analysis
	label variable smoke_sess_ncompl "Number of smoking treatment sessions NOT completed"
	compress
	save working_data/smoke_sess_ncompl, replace
	
//x participants requested to stop the smoking cessation treatment
	use pcmis_iaptus_no redcap_event_name ou_appt_date_a1 ou_appt_date sctd_end_yn sctd_end_yn_s2_6 using "working_data/clinical.dta", replace
	order pcmis_iaptus_no redcap_event_name ou_appt_date_a1 ou_appt_date sctd_end_yn sctd_end_yn_s2_6
	destring, replace
		
	//set random seed for sorting purposes
	set seed 1369841
	gen double random=runiform()

	//gen variable indicating the number of participants who requested to discontinue their smoking cessation treatment
	gen smoke_discon= sctd_end_yn 
	replace smoke_discon = sctd_end_yn_s2_6 if smoke_discon==.
	
	//assume those with missing data not request to discontinue
	replace smoke_discon=0 if smoke_discon==. 

	//gen new variable to indicate max n compelte or missing within person, so that we can keep one value for each variable within participant
	egen max_smoke_discon= max (smoke_discon),  by (pcmis_iaptus_no random)
	
	//gen new variable to indicate date of discontinuation
	gen smoke_discon_date = ou_appt_date_a1 if smoke_discon==1
	replace smoke_discon_date = ou_appt_date if smoke_discon_date==. & smoke_discon==1
	format %tdM_d,_CY smoke_discon_date

	//drop old smoke_discon and replace with max_smoke_discon
	drop smoke_discon
	rename max_smoke_discon smoke_discon
	label values smoke_discon sctd_end_yn_ 
	bysort pcmis_iaptus_no (smoke_discon_date random): keep if _n==1 
	
	//keep variables, label and save for analysis
	keep pcmis_iaptus_no smoke_discon smoke_discon_date
	label variable smoke_discon "Has participant discontinued smoking cessation treatment?"
	label variable smoke_discon_date "Smoking cessation treatment - participant requested to discontinue treatment date"
	compress
	save working_data/smoke_discon, replace
	
	//extract follow-up dates so that we can split the smoke_dicon and reasons by follow-up
	use working_data/clinical, clear
	keep if redcap_event_name=="3_month_follow_up_arm_1"
	gen date3m=ou_appt_date_3m
	keep pcmis_iaptus_no date3m
	compress
	save working_data/date3m, replace
	
	use working_data/clinical, clear
	keep if redcap_event_name=="6_month_follow_up_arm_1"
	gen date6m=ou_appt_date_3m
	keep pcmis_iaptus_no date6m
	compress
	save working_data/date6m, replace
	
	use working_data/clinical, clear
	keep if redcap_event_name=="baseline_arm_1"
	keep pcmis_iaptus_no ou_bl_date
	compress
	save working_data/datebl, replace
	
	use working_data/date3m, clear
	merge 1:1 pcmis_iaptus_no using "working_data/date6m"
	drop _m
	
	merge 1:1 pcmis_iaptus_no using "working_data/datebl"
	replace date3m=ou_bl_date+160 if date3m==.
	replace date6m=ou_bl_date+240 if date6m==.

	keep pcmis_iaptus_no date3m date6m

	//format dates
	format %tdM_d,_CY date3m
	format %tdM_d,_CY date6m
	compress
	save "working_data/followupdates", replace

//of those who discontinued - what's their reason	
	use "working_data/smoke_discon", replace
	merge 1:m	pcmis_iaptus_no using "working_data/clinical"

	//merge with those who have discontinued
	keep if smoke_discon==1
	keep if (smoke_discon_date >= ou_appt_date_a1 )    | (smoke_discon_date> = ou_appt_date)
	
	//gen variable to indicate category
	gen smoke_discon_reason=.
	label variable smoke_discon_reason "Reason participant withdrew from the smoking cessation intervention"
	label define smoke_discon_reason 1 "Not the right time to quit" 2 "Does not want to share personal data" ///
		3 "Concerned that they won't be able to cope without smoking"  ///
		4 "Failed quit attempt" /*5 "Quit smoking" 6 "Dropped out of IAPT (DNA)" ///
		7 "Completed IAPT treatment/discharged" 8 "Discontinued IAPT treatment" */9 "Other reason"
	label values smoke_discon_reason smoke_discon_reason
	replace smoke_discon_reason=1 if sctd_end_reason_s2_6___1
	replace smoke_discon_reason=2 if sctd_end_reason_s2_6___2
	replace smoke_discon_reason=3 if sctd_end_reason_s2_6___3
	replace smoke_discon_reason=4 if sctd_end_reason_s2_6___4
	replace smoke_discon_reason=9 if sctd_end_reason_s2_6___5

	/*replace smoke_discon_reason=. if sctd_end_reason_oth=="Quit smoking on his own between enrollment and first IAPT appointment. "
	replace smoke_discon_reason=. if (sctd_notsmoke7_yn==1 & smoke_discon_reason==9)*/
	replace smoke_discon_reason=6 if sctd_end_reason_oth=="Patient did not respond to invite to start treatment." /*
	replace smoke_discon_reason=. if (sctd_trtmnt_cmplt_s2_6==1 & smoke_discon_reason==9)
	replace smoke_discon_reason=. if (sctd_trtmnt_cmplt_s2_7==1 & smoke_discon_reason==9)
	replace smoke_discon_reason=. if (sctd_edn_iapt_yn_s2_6==1 & smoke_discon_reason==9)
	replace smoke_discon_reason=. if (sctd_edn_iapt_yn_s1==1 & smoke_discon_reason==9)*/
	
	//if they discontinued with the intervention because they quit smoking this doesn't count as "discontinuing" this is completing intervention
	replace smoke_discon=. if smoke_discon_reason==5
	replace smoke_discon_reason=. if smoke_discon_reason==5 

	//keep first reason if there are multiple reasons
		//set random seed for sorting purposes
		set seed 1369841
		gen double random=runiform()
	bys pcmis_iaptus_no (random): egen firstreason = min(smoke_discon_reason)	
	bysort pcmis_iaptus_no (random) : keep if _n==1 
	replace smoke_discon_reason=firstreason
	keep pcmis_iaptus_no  smoke_discon smoke_discon_date smoke_discon_reason
	
	//if they discontinued with the intervention because they quit smoking this doesn't count as "discontinuing" this is completing intervention, also DNA doesn't count as requesting to stop smoking cessation but continuing with IAPT
	replace smoke_discon=. if smoke_discon_reason==5 | smoke_discon_reason==6 | smoke_discon_reason==7| smoke_discon_reason==8
	replace smoke_discon_reason=. if smoke_discon_reason==5 | smoke_discon_reason==6 | smoke_discon_reason==7| smoke_discon_reason==8
	
	//if they have discontinued but no reason record, give "other reason"
	replace smoke_discon_reason=9 if smoke_discon_reason==. & smoke_discon==1
	drop if smoke_discon!=1
	
	//compress and save
	save working_data/smoke_discon_reason, replace
  
//how long did the behavioural/psychological component of the smoking cessation last, in minutes
	use pcmis_iaptus_no redcap_event_name ou_appt_date_a1 ou_appt_date sctd_duration sctd_duration_s2_6  using "working_data/clinical.dta", replace
	order pcmis_iaptus_no
	
	//drop if duration data are missing
	drop if (sctd_duration==. & sctd_duration_s2_6==.)
	
	//tidy up data to create one line per participant. First destring and label redcap_event_name
	forvalues val = 1(1)10 {
		replace redcap_event_name = "`val'" if redcap_event_name == "iapt_appointment_`val'_arm_1"
		}
	destring redcap_event_name, replace
	
	//label redcap_event_name
	label variable redcap_event_name "appointment number"
	label define redcap_event_name 1 "Appointment 1" 2 "Appointment 2" 3 "Appointment 3" 4 "Appointment 4" 5 "Appointment 5" ///
		6 "Appointment 6" 7 "Appointment 7" 8 "Appointment 7" 9 "Appointment 9" 10 "Appointment 10"
	label values redcap_event_name redcap_event_name

	//copy date and duration to missing fields within person - to allow for 1 record per participant
	replace ou_appt_date = ou_appt_date_a1 if ou_appt_date==.
	drop ou_appt_date_a1
	replace sctd_duration = sctd_duration_s2_6 if sctd_duration==.
	drop sctd_duration_s2_6
	label variable sctd_duration "1st session - Approximately how long did the behavioural/psychological component of the smokin"
	
	//reshape data from long to wide
	reshape wide ou_appt_date sctd_duration, i(pcmis_iaptus_no) j(redcap_event_name) 
	
	//label variables
	forvalues val = 1(1)9 {
		label variable sctd_duration`val' "session `val' duration in mins"
		label variable ou_appt_date`val' "session `val' date"
		}
	compress
	save working_data/smoke_session_dur, replace
	
//what type of medicine was used
	//first extract follow-up data
 	use  "working_data/clinical.dta", replace
	keep if (redcap_event_name=="3_month_follow_up_arm_1") | (redcap_event_name=="6_month_follow_up_arm_1")
	
		//generate label
		label define stp_smk_meds 1 "Nicotine patches, low strength patch (24-hour patch, 7 milligrams)" 2 "Nicotine patches, low strength patch (16-hour patch, 10 milligrams)" ///
			3 "Nicotine patches, medium strength patch (24-hour patch, 14 milligrams)" 4 "Nicotine patches, medium strength patch (16-hour patch, 15 milligrams)" ///
			5 "Nicotine patches, high strength patch (24-hour patch, 7 milligrams)" 6 "Nicotine patches, high strength patch (16-hour patch, 10 milligrams)" ///
			7 "Nicotine chewing gum, 2 milligrams" 8 "Nicotine chewing gum, 4 milligrams" 9 "Nicotine inhalator, 10 milligrams" 10 "Nicotine inhalator, 15 milligrams" ///
			11 "Nicotine nasal spray" 12 "Nicotine lozenges, 1 milligrams" 13 "Nicotine lozenges, 1.5 milligrams" 14 "Nicotine lozenges, 2 milligrams" ///
			15 "Nicotine lozenges, 4 milligrams" 16 "Nicotine mouth spray" 17 "E-cigarette or vape" 18 "Varenicline (i.e., Champix)" 19 "Participant did not try to quit" ///
			20 "Cold turkey" 21 "Participant does not remember" 22 "Other"
			
		//gen var to indicate meds at these timepoints
		foreach fu in 3 6 {
				gen meds_`fu'm=.
				foreach i of num 1/22	 {	
					replace meds_`fu'm=`i' if (stp_smk_meds___`i'==1 & redcap_event_name=="`fu'_month_follow_up_arm_1") 
				}
				label values  meds_`fu'm stp_smk_meds
			}	
		
		//keep variables, and drop those with missing data
		keep pcmis_iaptus_no meds_3m meds_6m
		drop if (meds_3m==. &  meds_6m==.)
		label variable meds_3m "Participant self-reported  smoking cessation medicine at follow-up"
		label variable meds_6m "Participant self-reported  smoking cessation medicine at follow-up"
		
		//copy medication type upwards and downwards to missing fields within person - to allow for 1 record per participant
		foreach fu in 3 6 {
			bysort pcmis_iaptus_no: egen newvar`fu'=max(meds_`fu'm) 
			label values  newvar`fu' stp_smk_meds
			drop meds_`fu'm
			rename newvar`fu' meds_`fu'm
			}
		duplicates drop
		compress
		save working_data/meds_followup, replace
	
	//then extract appointment 1 data (LABEL IS CORRECT)
	use "working_data/clinical.dta", replace
		
		//generate label
		label define meds_appt1 1 "Single-nicotine replacement therapy (NRT)"  2 "Dual-NRT"  3 "Champix (Varenicline)"  4 "E-cigarettes" 0 "No medication (i.e., cold turkey)"
	
		//generate var to indicate meds prescribed at first appointmet
		gen meds_appt1=.
			foreach i of num 0/4	 {	
				replace meds_appt1=`i' if (sctd_medication_plan___`i'==1) 
				}
		label values meds_appt1 meds_appt1		
		
		//keep variables, and drop those with missing data
		label variable meds_appt1 "PWP recorded smoking cessation medicine at appointment 1"
		keep pcmis_iaptus_no meds_appt1
		drop if meds_appt1==.
		compress
		save working_data/meds_appt1, replace
		
	//then extract appointment 2-10 data (LABEL IS CORRECT)	
	use  "working_data/clinical.dta", replace
			
		//generate label
		label define meds_appt2 1 "Single-nicotine replacement therapy (NRT)"  2 "Dual-NRT" 3 "Champix (Varenicline)" 4 "E-cigarettes" 0 "No medication"

		//generate var to indicate meds prescribed at appointments 2-10
			foreach apt of num 2/10 {
				gen meds_appt`apt'=.
					foreach i of num 0/4	 {	
						replace meds_appt2=`i' if (sctd_medication_plan_s2_6___`i'==1 & redcap_event_name=="iapt_appointment_`apt'_arm_1")
					}
				label variable meds_appt`apt' "PWP recorded smoking cessation medicine at appointment `apt'"		
				label values meds_appt`apt' meds_appt2		
			}
		
		//keep relevant variables, drop duplicates and variables with 100% missing data
		keep pcmis_iaptus_no meds_appt2-meds_appt10
		drop if (meds_appt2==. & meds_appt3==. & meds_appt4==. & meds_appt5==. & meds_appt6==. & meds_appt7==. & meds_appt8==. & meds_appt9==. & meds_appt10==.)
		/* dropvars, force */
		duplicates drop
		compress
			//set random seed for sorting purposes
			set seed 1369841
			gen double random=runiform()
		bysort pcmis_iaptus_no (random): keep if _n==1
		drop random
		compress
		save working_data/meds_appt210, replace
	
//merge all files to generate one working dataset
	use working_data/randomisation_complete, clear 
	foreach file in  sess_attem_imputed smoke_sess_compl smoke_sess_ncompl followupdates smoke_discon smoke_discon_reason smoke_session_dur meds_followup meds_appt1 meds_appt210 {
		merge 1:1  pcmis_iaptus_no using working_data/`file'
		drop _m
	}
	
	drop if rand_allocation==.
	order pcmis_iaptus_no rand_allocation site
	compress
	save working_data/_analysis_smoking_session_out, replace


