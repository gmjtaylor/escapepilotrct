//This do file impuptes missing values in mimic_trial data
//Gemma Taylor 
//2022 03 10

//install ice
/*ssc install ICE, replace */

//set drive 
cd "X:\Psychology\ResearchProjects\GMJTaylor\CRUK Fellowship\Trial\Results\REDCAP data"

//open data
use "working_data/mimic_trial", clear

set more off
mi set mlong
order phq_3m gad_3m cpd_3m hsi_3m phq_6m gad_6m cpd_6m hsi_6m mh_phq9_total_score_calc mh_gad7_total_score smoking_hsi_index smoking_cigs_per_day

//impute the data
ice site rand_allocation age dob gender ethnicity education contact_imd_score phq_3m gad_3m cpd_3m hsi_3m phq_6m gad_6m cpd_6m hsi_6m mh_phq9_total_score_calc mh_gad7_total_score smoking_hsi_index smoking_cigs_per_day, saving(working_data/mimic_trial_imputed, replace) m(20) seed(12345) 

//open the imputed dataset
use "working_data/mimic_trial_imputed",clear

//reset all the MI data
mi unset
mi import ice, automatic clear 
mi describe

//save the imputed data set
compress
save "working_data/mimic_trial_imputed",replace


