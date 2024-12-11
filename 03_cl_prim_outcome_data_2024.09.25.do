//This do file cleans primary feasibilty outcome data and generates outcome varaibles and saves them into their own dta files. 
//Gemma Taylor
//2024 09 25

//set drive
cd "GMJTaylor/CRUK Fellowship/Trial/Results/REDCAP data/"
	
//Main feasibility study outcome cleaning
	
	//Generate primary outcome at 3 - month follow-up
		//Proportion of study completers protocol definition "Participants will be considered a completer if they: (1) continue with smoking cessation treatment /// 
		//up until the point of smoking cessation, (2) OR a quit attempt, and (3) completion of IAPT care. /// The proportion of study completers will be ///
		//calculated by (N completers/N randomised at baseline)"
									
		
	//Condition 1: use ITT bioverified smoking cessation data, as defined in "an_mimic_quit_data"			
		///Already cleaned in 16_cl_mimic_quit_data_2022.03.10, data available from use "working_data/quit_data_3m" "working_data/quit_data_6m"
	
	
	
	//Condition 2: Extract quit attempt data between baseline and follow-up - complete cases & missing data = no quit attempt					
															
				//Open clinical data and extract variables needed - extract quit attempt data in appointment 2-10 and `i' month follow-up data ///
					//(unhelpfully xxx variables are labelled as "_3m" in redcap, although the represent data at 3 and 6 month when selected using "redcap event name"
**# Bookmark #1
															
				//keep relevant variables and keep relevant data collection points (need to do this separately as recap_event name doesn't like loop)
					//3 months 
					use "working_data/clinical.dta", replace	
					keep pcmis_iaptus_no ou_appt_date ou_appt_date_3m quit_yn_3m sctd_notsmoke7_yn redcap_event_name
					drop if (redcap_event_name== "baseline_arm_1" | redcap_event_name== "6_month_follow_up_arm_1" | redcap_event_name== "iapt_appointment_1_arm_1" | ///
					redcap_event_name== "iapt_appointment_1_arm_1b")
					compress
					save "working_data/clinical_3month.dta", replace	
					
					//6 months 
					use "working_data/clinical.dta", replace	
					keep pcmis_iaptus_no ou_appt_date_a1 ou_appt_date ou_appt_date_3m quit_yn_3m sctd_notsmoke7_yn redcap_event_name
					drop if (redcap_event_name== "baseline_arm_1" | redcap_event_name== "3_month_follow_up_arm_1" | redcap_event_name== "iapt_appointment_1_arm_1" | ///
					redcap_event_name== "iapt_appointment_1_arm_1b")
					compress
					save "working_data/clinical_6month.dta", replace	
					
				//Loop to clean quit attempt data between baseline and 3 and 6 months	complete case
					foreach i in 3 6 {		
						use "working_data/clinical_`i'month.dta", replace	
						
						//keep records with data only
						keep if (sctd_notsmoke7_yn==0 | sctd_notsmoke7_yn==1 | quit_yn_3m==0 | quit_yn_3m==1)
							
						//keep quit attempt data that was recorded before or on `i'-month follow-up date
						//copy 3month follow-up date within patient & set random sorting seed
						set seed 1369841
						gen double random=runiform()
						bysort pcmis_iaptus_no (random): egen copy_ou_appt_date_3m = max(ou_appt_date_3m) 			
						format copy_ou_appt_date_3m %td
							
						//within person - drop IAPT appointment data if appointment date occured after the `i'-month follow-up 
						gen drop=1 if (ou_appt_date>copy_ou_appt_date_3m & ou_appt_date!=.)
						drop if drop==1
						drop drop
							
						//gen quit attempt variable
						gen quit_attempt_cc`i'm=.
						label values quit_attempt_cc`i'm quit_yn_3m_
							
						//replace quit attempt variable with `i'_month follow-up quit attempt data
						replace quit_attempt_cc`i'm=quit_yn_3
							
						//replace quit_attempt_`i'm with IAPT appointment data IF quit_attempt_`i'm data are missing 
						replace quit_attempt_cc`i'm = sctd_notsmoke7_yn if (quit_attempt_cc`i'm==.)
						
						//keep only one record within patient - keep evidence of quit attempt over no-quit attempt
						bysort pcmis_iaptus_no (random quit_attempt_cc`i'm): keep if _n==_N				
						
						
						//drop those who weren't randomised.
						merge 1:1 pcmis_iaptus_no using "working_data/randomisation_complete"
						drop if _m==1
**# Bookmark #1
						
						//assume that missing data equals "no quit attempt"
						/*replace quit_attempt_`i'm=0 if quit_attempt_`i'm==.*/

						//keep only relevant variables and drop duplicates
					/*	keep pcmis_iaptus_no quit_attempt_`i'm */
						duplicates drop
						
						label variable quit_attempt_cc`i'm "Participant made quit attempt between baseline and `i' month follow-up"
						
						//label variables to indicate follow-up	
						foreach x of varlist _all  {
							local y: variable label `x'
							label var `x' "Follow-up - `y'"
							}	
						
						compress
						drop _m
						save "working_data/quit_attempt_cc_data_`i'm", replace	
						
						}


	
	
	
//Condition 3: completion of IAPT care	
	//Already cleaned in 11_cl_service_related_outcomes_2022.03.10, data available from "working_data/service_outcomes_analysis"
	
//Gen data file for analysis
	//merge .dta files - quit data, quit attempt data and service outcomes data
**# Bookmark #2
	use  "working_data/quit_data_3m", clear
	merge 1:1 pcmis_iaptus_no using "working_data/quit_data_6m"
	drop _m
	merge 1:1 pcmis_iaptus_no using "working_data/quit_attempt_data_3m"
	drop _merge
	merge 1:1 pcmis_iaptus_no using "working_data/quit_attempt_data_6m"
	drop _m
	merge 1:1 pcmis_iaptus_no using "working_data/quit_attempt_cc_data_3m"
	drop _m
	merge 1:1 pcmis_iaptus_no using "working_data/quit_attempt_cc_data_6m"
	drop _m
	merge 1:1 pcmis_iaptus_no using "working_data/service_outcomes_analysis"
	drop _m
	//drop those who weren't randomised.
	merge 1:1 pcmis_iaptus_no using "working_data/randomisation_complete"
	drop if _m==1
	drop _m

	order pcmis_iaptus_no rand_allocation site
	save "working_data/primaryoutcome", replace
