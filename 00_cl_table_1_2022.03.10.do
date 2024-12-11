//This do file cleans data for table 1
//Gemma Taylor 
//2022 03 10

//Set path
	
	cd "X:\Psychology\ResearchProjects\GMJTaylor\CRUK Fellowship\Trial\Results\REDCAP data"
	
//Clean IMD data created by Rita
	import excel "/Volumes/GMJTaylor/MSc Projects/ESCAPE IMD/Postcode data - 2.xlsx", sheet("Sheet1") firstrow clear
	
	//replace missing IMD with GP IMD
	replace contact_imd_score=gp_imd_score if contact_imd_score==.
	replace contact_imd_quintile = gp_imd_quintile if contact_imd_quintile ==.
	
	keep pcmis_iaptus_no contact_imd_score contact_imd_quintile
	//take out blank spaces from string
	replace pcmis_iaptus_no = subinstr(pcmis_iaptus_no," ","",.)
	compress
	save "/Volumes/GMJTaylor/MSc Projects/ESCAPE IMD/imd.dta", replace
	
//Open admin data and keep only those with randomisation complete
	use "working_data/admin.dta", clear
	drop if old_pcmis_iaptus_no==""
	tab rand_allocation
	keep if randomisation_complete==2
	
//Merge with baseline data
	merge 1:1  pcmis_iaptus_no using "working_data/analysis_baseline_data.dta", update replace
	drop _m
	
//Merge IMD data
	merge 1:1  pcmis_iaptus_no using "/Volumes/GMJTaylor/MSc Projects/ESCAPE IMD/imd.dta", update replace
	drop _m
	order pcmis_iaptus_no

	
//Clean variabels to be included in table 1
	gen age=(rand_dte-dob)/365
	label variable age "Age in years"
	label variable smoking_cigs_per_day "Cigarettes per day (CPD)"
	label variable mh_phq9_total_score_calc "Patient Health Questionnaire (PHQ-9)"
	label variable mh_gad7_total_score "Generalised Anxiety Disorder Questionnaire (GAD-7)"
	label variable smoking_quit_attempts "Previous number of quit attempts"
	label define site_ 1 "Avon and Wiltshire Mental Health Partnership NHS Trust", modify
	label define site_ 2 "Oxford Health NHS Foundation Trust", modify
	label define site_ 3 "North East London NHS Foundation Trust", modify
	label define site_ 4 "Black Country Healthcare NHS FT", modify
	label variable contact_imd_score "Index of Multiple Deprivation score"
	label variable contact_imd_quintile "Index of Multiple Deprivation quintile"
	//clean comorbidities 
	label variable mh_comorbid___1 "Comorbid anxiety"
	label variable mh_comorbid___2 "Comorbid panic attacks"
	label variable mh_comorbid___3 "Comorbid obessive compulsive disorder"
	label variable mh_comorbid___4 "Other comorbid mental health condition"
	//replace mh_comorbid_4 where data indicate that participant had other mh condition
	gen var=1 if mh_comorbid___5==1 | mh_comorbid_othr!=""
	replace  mh_comorbid___4=1 if var==1
	//gen comorbid depression variable
	gen mh_comorbid_dep=1 if mh_phq9_total_score_calc>=10
	replace mh_comorbid_dep=0 if mh_phq9_total_score_calc<10 & mh_phq9_total_score_calc!=.

//Save cleaned baseline characterisitcs
	order pcmis_iaptus_no rand_allocation site age dob gender ethnicity ethnicity_othr  education contact_imd_score contact_imd_quintile mh_phq9_total_score_calc ///
	mh_gad7_total_score mh_comorbid_dep mh_comorbid___1 mh_comorbid___2 mh_comorbid___3 mh_comorbid___4 smoking_hsi_index smoking_cigs_per_day  smoking_quit_attempts      

	keep pcmis_iaptus_no rand_allocation site age dob gender ethnicity ethnicity_othr  education contact_imd_score contact_imd_quintile mh_phq9_total_score_calc ///
	mh_gad7_total_score mh_comorbid_dep mh_comorbid___1 mh_comorbid___2 mh_comorbid___3 mh_comorbid___4 smoking_hsi_index smoking_cigs_per_day  smoking_quit_attempts   

//label variables to indicate baseline	
foreach x of varlist _all  {
	local y: variable label `x'
	label var `x' "Baseline - `y'"

	}	
	
//Compress and save	
compress	
save "working_data/baseline_characteristics", replace 
	
	
