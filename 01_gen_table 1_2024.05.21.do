//This do file generates table 1 - Participant characteristics
//Gemma Taylor
//2022 03 10

//Set path
cd "X:\Psychology\ResearchProjects\GMJTaylor\CRUK Fellowship\Trial\"

//Open data
use "Results\REDCAP data\working_data/baseline_characteristics", replace 
		
//Generate table 1 and save
	table1_mc, by(rand_allocation) vars(site cat %5.1f \ age  contn  %5.1f \ gender cat %5.1f \ ethnicity cat %5.1f \ education cat %5.1f \  ///
	contact_imd_score  conts   %5.1f \ mh_phq9_total_score_calc contn %5.1f \ mh_gad7_total_score contn %5.1f\ ///
	mh_comorbid___1 cat %5.1f\ mh_comorbid___2 cat %5.1f \  mh_comorbid___3 cat %5.1f\  mh_comorbid___4 cat %5.1f \ smoking_hsi_index contn %5.1f \   ///
	smoking_cigs_per_day contn %5.1f \ smoking_quit_attempts contn %5.1f )   ///
	saving ("Results/paper_tables_figures/table_1_baseline_char.xlsx", replace) 
