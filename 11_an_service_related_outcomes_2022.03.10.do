//This do file analyses Service-related feasibility outcomes (planned, completed, and missed IAPT appointments)
//Gemma Taylor
//2022 03 10

//set drive
cd "X:\Psychology\ResearchProjects\GMJTaylor\CRUK Fellowship\Trial\Results\"

//open data
use  "REDCAP data\working_data\complete_case_service_outcomes_analysis.dta", clear

//generate table 1 and save for each follow-up - complete case
foreach i in 3 6 {
	table1_mc, by(rand_allocation) vars(n_missed_apt_`i'm contn %5.1f \ n_compl_apt_`i'm contn %5.1f \ n_planned_apt_`i'm contn %5.1f \ ///
	iapt_completed_treatment_`i'm cat %5.1f \ iapt_discontinue_treatment_`i'm cat %5.1f \ iapt_ongoing_treatment_`i'm cat %5.1f) saving ///
	("paper_tables_figures/completecase_table_service_outcomes_`i'm.xlsx", replace) 
	
	}
