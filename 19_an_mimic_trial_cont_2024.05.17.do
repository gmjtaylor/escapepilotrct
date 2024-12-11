//This do file generates tables for means and standard deviations for pilot of full trial outcomes (phq gad his and cpd)
//Gemma Taylor 
//2024 05 17

//set drive 
cd "X:\Psychology\ResearchProjects\GMJTaylor\CRUK Fellowship\Trial\Results\REDCAP data/working_data/"

//open data
use "mimic_trial", clear
	
//generate table for means and standard deviations at 3 and 6-months follow-up, loop over follow-ups using complete case data.
	// variables being analysed phq9_score_calc6m gad7_score_calc6m smoking_cigs_per_day6m hsi_score6m
	//gen rows for table - mean and sd at follow-up for phq gad cpd hsi
	
	//loop over each follow-up
	foreach fu in 3 6 	{
		
		//loop over each outcome
		foreach out in phq gad cpd hsi  {
		
			//foreach arm 
			foreach arm in 0 1 { 
				use "mimic_trial", clear
				putexcel set  "X:\Psychology\ResearchProjects\GMJTaylor/CRUK Fellowship/Trial/Results/REDCAP data/working_data/mimic_`out'_`fu'm_`arm'.xlsx", replace
				putexcel A1=("N") B1=("mean") C1=("sd") D1=("followup")  E1=("arm") F1=("outcome") 
				
				//sum mental health score for one arm and put data into excel sheet, import, add information then export
				sum `out'_`fu'm if rand_allocation==`arm'
				putexcel (a2) = ( `r(N)' )
				putexcel (b2) = ( `r(mean)' )
				putexcel (c2) = ( `r(sd)' )
				import excel "X:\Psychology\ResearchProjects\GMJTaylor/CRUK Fellowship/Trial/Results/REDCAP data/working_data/mimic_`out'_`fu'm_`arm'.xlsx", sheet("Sheet1") firstrow clear
				replace followup=`fu'
				replace arm=`arm'
				tostring outcome, replace force
				replace outcome="`out'"
				compress
				save "mimic_`out'_`fu'm_`arm'", replace
				}
			}
		}
	
	//append rows	
	use "mimic_phq_3m_1", clear
		//loop over each follow-up
		foreach fu in 3 6 	{
			
			//loop over each outcome
			foreach out in phq gad cpd hsi  {
			
				//foreach arm 
				foreach arm in 0 1 { 
					append using "mimic_`out'_`fu'm_`arm'"
				}
			}
		}
		
	//save excel table
	duplicates drop
	sort followup outcome arm
	order followup outcome arm mean sd N
	compress
	export excel using "X:\Psychology\ResearchProjects\GMJTaylor/CRUK Fellowship/Trial/Results/paper_tables_figures/table_mimic_cont.xlsx", firstrow(variables) replace

//generate table for means and standard deviations at 3 and 6-months follow-up, loop over follow-ups using Imputed data.
cd "X:\Psychology\ResearchProjects\GMJTaylor\CRUK Fellowship\Trial\Results\REDCAP data/working_data/"

	//gen rows for table - mean and sd at follow-up for phq gad cpd hsi
	//loop over each follow-up
	foreach fu in 3 6 	{
		
		//loop over each outcome
		foreach out in phq gad cpd hsi  {
		
			//foreach arm 
			foreach arm in 0 1 { 
				use "mimic_trial_imputed", clear
				putexcel set  "X:\Psychology\ResearchProjects\GMJTaylor/CRUK Fellowship/Trial/Results/REDCAP data/working_data/mimic_`out'_`fu'm_`arm'_mi.xlsx", replace
				putexcel A1=("N") B1=("mean") C1=("sd") D1=("followup")  E1=("arm") F1=("outcome") 
				
				//sum mental health score for one arm and put data into excel sheet, import, add information then export
				sum `out'_`fu'm if rand_allocation==`arm' & `out'_`fu'm!=0
				putexcel (a2) = ( `r(N)' )
				putexcel (b2) = ( `r(mean)' )
				putexcel (c2) = ( `r(sd)' )
				import excel "X:\Psychology\ResearchProjects\GMJTaylor/CRUK Fellowship/Trial/Results/REDCAP data/working_data/mimic_`out'_`fu'm_`arm'_mi.xlsx", sheet("Sheet1") firstrow clear
				replace followup=`fu'
				replace arm=`arm'
				tostring outcome, replace force
				replace outcome="`out'"
				compress
				save "mimic_`out'_`fu'm_`arm'_mi", replace
				}
			}
		}
	
	//append rows	
	use "mimic_phq_3m_1_mi", clear
		//loop over each follow-up
		foreach fu in 3 6 	{
			
			//loop over each outcome
			foreach out in phq gad cpd hsi  {
			
				//foreach arm 
				foreach arm in 0 1 { 
					append using "mimic_`out'_`fu'm_`arm'_mi"
				}
			}
		}
		
	//save excel table
	duplicates drop
	sort followup outcome arm
	order followup outcome arm mean sd N
	compress
	export excel using "X:\Psychology\ResearchProjects\GMJTaylor/CRUK Fellowship/Trial/Results/paper_tables_figures/table_mimic_cont_mi.xlsx", firstrow(variables) replace
 
**# Bookmark #3
 
 //COMPLETE CASE: generate effect estimates for the effect of random allocation on gad and phq-9 outcomes
 
	 //analyse gad and phq data - linear regression models
		//set drive 
		cd "X:\Psychology\ResearchProjects\GMJTaylor\CRUK Fellowship\Trial\Results\REDCAP data\"

		//open data
		use "working_data/mimic_trial", clear
		
		//We will present the unadjusted model, and adjusted model for site.  loop over followup and outcome
		rename mh_phq9_total_score_calc phq_baseline
		rename mh_gad7_total_score gad_baseline
		rename smoking_cigs_per_day cpd_baseline
		rename smoking_hsi_index hsi_baseline
		
		foreach outcome in phq gad cpd hsi {
			foreach i in 3 6  {
				
				regress `outcome'_`i'm rand_allocation `outcome'_baseline
				regsave using "working_data/mimic_`outcome'_`i'_unadj", detail(all)  replace ci pval 
				regress `outcome'_`i'm rand_allocation site `outcome'_baseline
				regsave using "working_data/mimic_`outcome'_`i'_adj", detail(all) replace ci pval 
			}
		}
		
		///append estimates table 
		foreach outcome in phq gad cpd hsi {
			foreach model in adj unadj { 
				foreach i in 3 6 {  
					use "working_data/mimic_`outcome'_`i'_`model'" , replace
					keep if var=="rand_allocation"
					gen analysis="`outcome'_`i'_`model'"
					keep analysis coef ci_lower ci_upper N var
					order analysis coef ci_lower ci_upper N var
					save "working_data/table_mimic_`outcome'_`i'_`model'.dta" , replace
				} 
			}
		}
		
		///build table for PHQ GAD cpd hsi
		foreach outcome in phq gad cpd hsi {
		use "working_data/table_mimic_`outcome'_3_unadj.dta" , clear
		append using "working_data/table_mimic_`outcome'_3_adj.dta" 
		append using "working_data/table_mimic_`outcome'_6_adj.dta" 
		append using "working_data/table_mimic_`outcome'_6_unadj.dta" 
		export excel using "X:\Psychology\ResearchProjects\GMJTaylor\CRUK Fellowship/Trial/Results/paper_tables_figures/table_mimic_`outcome'.xlsx", sheetreplace firstrow(variables) 
		}

**# Bookmark #4
 //imputed: generate effect estimates for the effect of random allocation on gad and phq-9 outcomes
 
	 //analyse gad and phq data - linear regression models
		//set drive 
		cd "X:\Psychology\ResearchProjects\GMJTaylor\CRUK Fellowship\Trial\Results\REDCAP data\"

		//open data
		use "working_data/mimic_trial_imputed", clear
		
		rename mh_phq9_total_score_calc phq_baseline
		rename mh_gad7_total_score gad_baseline
		rename smoking_cigs_per_day cpd_baseline
		rename smoking_hsi_index hsi_baseline

		//we will present the unadjusted model, and adjusted model for site.  loop over followup and outcome
		foreach outcome in phq gad cpd hsi {
			foreach i in 3 6  {
				mi estimate: regress `outcome'_`i'm rand_allocation  `outcome'_baseline
				regsave using "working_data/mimic_`outcome'_`i'_unadj_mi", detail(all)  replace ci pval 
				mi estimate: regress `outcome'_`i'm rand_allocation site `outcome'_baseline
				regsave using "working_data/mimic_`outcome'_`i'_adj_mi", detail(all) replace ci pval 
							}
											}	
		
		///append estimates table 
		foreach outcome in phq gad cpd hsi {
			foreach model in adj unadj { 
				foreach i in 3 6 {  
					use "working_data/mimic_`outcome'_`i'_`model'_mi" , replace
					keep if var=="rand_allocation"
					gen analysis="`outcome'_`i'_`model'_mi"
					keep analysis coef ci_lower ci_upper N var
					order analysis coef ci_lower ci_upper N var
					save "working_data/table_mimic_`outcome'_`i'_`model'_mi.dta" , replace
				} 
			}
		}
		
		///build table for PHQ & GAD
		foreach outcome in phq gad cpd hsi {
		use "working_data/table_mimic_`outcome'_3_unadj_mi.dta" , clear
		append using "working_data/table_mimic_`outcome'_3_adj_mi.dta" 
		append using "working_data/table_mimic_`outcome'_6_unadj_mi.dta" 
		append using "working_data/table_mimic_`outcome'_6_adj_mi.dta" 

		export excel using "X:\Psychology\ResearchProjects\GMJTaylor\CRUK Fellowship\Trial\Results\paper_tables_figures\table_mimic_`outcome'_mi.xls", firstrow(variables) replace
}

//paper revisions may 17 2024
	 //analyse gad and phq data - linear regression models
		//set drive 
		cd "X:\Psychology\ResearchProjects\GMJTaylor\CRUK Fellowship\Trial\Results\REDCAP data\"

		//open data
		use "working_data/mimic_trial", clear

//gen difference scores
gen diff_phq_3m = phq_3m - mh_phq9_total_score_calc
gen diff_phq_6m = phq_6m - mh_phq9_total_score_calc

gen diff_gad_3m = gad_3m - mh_gad7_total_score
gen diff_gad_6m = gad_6m - mh_gad7_total_score

//mean change scores
tabulate quit_cc_3m if rand_allocation==0 ,summarize( diff_phq_3m ) 
tabulate quit_cc_3m if rand_allocation==1, summarize( diff_phq_3m ) 
tabulate quit_cc_3m if rand_allocation==0, summarize( diff_gad_3m  )
tabulate quit_cc_3m if rand_allocation==1, summarize( diff_gad_3m  )
tabulate quit_cc_6m if rand_allocation==0, summarize( diff_phq_6m )
tabulate quit_cc_6m  if rand_allocation==1, summarize( diff_phq_6m )
tabulate quit_cc_6m if rand_allocation==0, summarize( diff_gad_6m )
tabulate quit_cc_6m if rand_allocation==1, summarize( diff_gad_6m ) 

//mean scores
tabulate quit_cc_3m if rand_allocation==0 ,summarize( phq_3m ) 
tabulate quit_cc_3m if rand_allocation==1, summarize( phq_3m ) 
tabulate quit_cc_3m if rand_allocation==0, summarize( gad_3m  )
tabulate quit_cc_3m if rand_allocation==1, summarize( gad_3m  )
tabulate quit_cc_6m if rand_allocation==0, summarize( phq_6m )
tabulate quit_cc_6m  if rand_allocation==1, summarize( phq_6m )
tabulate quit_cc_6m if rand_allocation==0, summarize( gad_6m )
tabulate quit_cc_6m if rand_allocation==1, summarize( gad_6m ) 
