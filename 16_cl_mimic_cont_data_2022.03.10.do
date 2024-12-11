//This do file cleans pilot of full trial outcomes (phq gad his and cpd)
//Gemma Taylor 
//2022 03 10

//set drive 
	cd "X:\Psychology\ResearchProjects\GMJTaylor\CRUK Fellowship\Trial\Results\REDCAP data"

//open data
	use  using "working_data/clinical.dta", replace
	keep redcap_event_name pcmis_iaptus_no ///
		mh_phq9_score_calc_3m phq9_imputed_score phq9_iapt_input  ///
		mh_gad7_score_calc_3m gad7_imputed_score gad7_iapt_input ///
		smoking_wake_up_3m smoking_cigarette_no_3m smoking_cigs_per_day_3m

//keep relevant time points
	order pcmis_iaptus_no redcap_event_name 
	keep if redcap_event_name== "3_month_follow_up_arm_1" | redcap_event_name=="6_month_follow_up_arm_1"

//clean redcap event name ready for reshape, rename other variables for streamlining
	rename mh_phq9_score_calc_3m phq9_score_calc_3m
	rename mh_gad7_score_calc_3m gad7_score_calc_3m

	foreach var in phq9_score_calc gad7_score_calc smoking_wake_up smoking_cigarette_no smoking_cigs_per_day {
		rename `var'_3m `var'
		}

	foreach i in 3 6 {
		replace redcap_event_name= "`i'm" if redcap_event_name== "`i'_month_follow_up_arm_1"
		}

	destring, replace
	compress

//replace phq & gad values with "imputed" data from phq9_imputed_score
	foreach i in phq9 gad7 {
		replace `i'_imputed_score="" if real(`i'_imputed_score)==.
		destring, replace
		replace `i'_score_calc=`i'_imputed_score if `i'_score_calc==.
		drop `i'_imputed_score
		}

//calculate HSI score
	gen hsi_score = smoking_wake_up+smoking_cigarette_no
	drop smoking_wake_up smoking_cigarette_no phq9_iapt_input gad7_iapt_input

//reshape wide
	reshape wide  phq9_score_calc gad7_score_calc smoking_cigs_per_day hsi_score , i(pcmis_iaptus_no) j(redcap_event_name) string
	compress

//label variables to indicate follow-up	
	foreach x in phq9_score_calc3m gad7_score_calc3m smoking_cigs_per_day3m hsi_score3m phq9_score_calc6m gad7_score_calc6m smoking_cigs_per_day6m hsi_score6m {
		local y: variable label `x'
		label var `x' "Follow-up - `y'"

		}	
	compress	

//Bring in randomisation data
merge 1:1  pcmis_iaptus_no using working_data/randomisation_complete	
drop if rand_allocation==.
drop _m
			
//Merge baseline data
	 merge 1:1 pcmis_iaptus_no using "working_data/baseline_characteristics"
	 drop _m
				
//Merge 3- and 6- month primary outcome data	
	foreach i in 3 6 {		
			//open quit attempt/quit data
			merge 1:1 pcmis_iaptus_no using "working_data/quit_attempt_data_`i'm"
			drop _m				
					
			//merge bioverified smoking cessation data
			merge 1:1 pcmis_iaptus_no using "working_data/quit_data_`i'm"
			drop _m
			}

//replace missing CPD and HSI values as 0 for those who have quit smoking with biovalidation			
foreach i in 3 6 {
	replace smoking_cigs_per_day`i'm=0 if quit_itt_`i'm==1
	replace hsi_score`i'm=0 if quit_itt_`i'm==1
	}
			
//order, compress and save
order pcmis_iaptus_no site rand_allocation age dob gender ethnicity ethnicity_othr education contact_imd_score ///
	contact_imd_quintile mh_phq9_total_score_calc mh_gad7_total_score mh_comorbid___1 mh_comorbid___2 mh_comorbid___3 ///
	mh_comorbid___4 smoking_hsi_index smoking_cigs_per_day smoking_quit_attempts

//shorted variable names
foreach i in 3 6 {	
	rename hsi_score`i'm hsi_`i'm
	rename phq9_score_calc`i'm phq_`i'm
	rename gad7_score_calc`i'm gad_`i'm
	rename smoking_cigs_per_day`i'm cpd_`i'm
	}
compress
drop if rand_allocation==.
compress
save "working_data/mimic_trial", replace
	
	

	
	


	
	
	
	
