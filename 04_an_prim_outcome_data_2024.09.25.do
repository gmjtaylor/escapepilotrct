//This do file analyses the primary outcome data
//Gemma Taylor
//2024 09 21


//set drive
cd "X:\Psychology\ResearchProjects\GMJTaylor\CRUK Fellowship\Trial\Results\"

//Gen table with disagregated feasibility outcomes and save for each follow-up
	use "REDCAP data/working_data/primaryoutcome", clear
	foreach i in 3 6 {
		table1_mc, by(rand_allocation) vars(quit_itt_`i'm cat %5.1f \ quit_attempt_`i'm cat %5.1f \ iapt_completed_treatment_`i'm cat %5.1f) saving ("paper_tables_figures/table_prim_outcome_perc`i'm.xlsx", replace) 
		}

//set drive
**# Bookmark #1
cd "/Volumes/GMJTaylor/CRUK Fellowship/Trial/Results/"
	
//Conduct adjusted and unadjusted logistic regression models to examine the effect of random allocation on IAPT completion at 3 and 6-months follow-up
	//open data saved above.
	use "REDCAP data/working_data/primaryoutcome.dta", clear
	foreach i in 3 6 {	
		//conduct unadjusted logistic regression model 
			logistic iapt_completed_treatment_`i'm rand_allocation
			regsave rand_allocation using "REDCAP data/working_data/iapt_complete_`i'm_unadj", detail(all) replace ci pval 

		//conduct mixed effects logistic regression model, with site as a random effect
			xtmelogit  iapt_completed_treatment_`i'm  rand_allocation || site: , or 

		//save unadjusted estimate
			regsave rand_allocation using "REDCAP data/working_data/iapt_complete_`i'm_adj", detail(all) replace ci pval 
			}

//Generate table with unadjusted and unadjusted outcome data, and clean output
	foreach i in 3 6 {	
			use "REDCAP data/working_data/iapt_complete_`i'm_unadj", clear
			append using "REDCAP data/working_data/iapt_complete_`i'm_adj"

		//Convert coeficients into odds ratios
			gen or=exp(coef)
			gen or_ci_lower=exp(ci_lower)
			gen or_ci_upper=exp(ci_upper)
			
		//Clean and order data
			gen model_type="Unadjusted logistic regression" if title=="Logistic regression" 
			replace model_type="Mixed-effects adjusted logistic regression" if title=="Mixed-effects logistic regression" 
			gen follow_up="`i'-months"
			
		//set to two decimal places
			foreach d in or or_ci_lower or_ci_upper pval {
					format `d' %3.2f
				}
				
		//order table and export to dta
			order cmdline title depvar follow_up model_type N or or_ci_lower or_ci_upper pval
			keep follow_up model_type N or or_ci_lower or_ci_upper pval
			compress
			save "/Volumes/GMJTaylor/CRUK Fellowship/Trial/Results/REDCAP data/working_data/iapt_complete_`i'm.dta", replace
				}
				
//Append dta output and export to excel, and label		
	use "/Volumes/GMJTaylor/CRUK Fellowship/Trial/Results/REDCAP data/working_data/iapt_complete_3m.dta", replace
	append using	"/Volumes/GMJTaylor/CRUK Fellowship/Trial/Results/REDCAP data/working_data/iapt_complete_6m.dta"	
	label variable follow_up "Follow-up"
	label variable model_type "Model"
	label variable or "Odds ratio"
	label variable or_ci_lower "95% CI lower"
	label variable or_ci_upper "95% CI upper"
	label variable N "Number analysed"
	label variable pval "P-value"
	export excel using "/Volumes/GMJTaylor/CRUK Fellowship/Trial/Results/paper_tables_figures/table_prim_outcome_reg.xlsx", firstrow(varlabels) replace
