//This do file analyses pilot primary outcomes 
//Gemma Taylor
//2023 12 15

//set drive 
cd "X:\Psychology\ResearchProjects\GMJTaylor\CRUK Fellowship/Trial/Results/REDCAP data/"

//open data
use "working_data/mimic_trial", clear
set more off	
	
//Generate table for quit rates at 3 and 6-months follow-up, loop over follow-ups 

	//Loop over complete case and itt quit rates
	foreach q in cc itt {

		//loop over follow-ups
		foreach i in 3 6 {
			use "working_data/mimic_trial", clear
			putexcel set  "X:\Psychology\ResearchProjects\GMJTaylor\CRUK Fellowship/Trial/Results/REDCAP data/working_data/quit_`q'`i'", replace
			putexcel A1=("group") B1=("treatment") C1=("smoke") D1=("quit")  E1=("total_n")
			tabulate  rand_allocation quit_`q'_`i'm, row matcell(cell) matrow(rows)				
			putexcel B2=matrix(rows) C2=matrix(cell) E2=(r(n))
					
		//import sheet to edit to save as .dta
			import excel "X:\Psychology\ResearchProjects\GMJTaylor/CRUK Fellowship/Trial/Results/REDCAP data/working_data/quit_`q'`i'", sheet("Sheet1") firstrow clear
			gen followup = "`i'-months"
			gen type="`q'"
			drop group
			replace total_n=smoke+quit
			gen perc=(quit/total_n)*100
			drop smoke
			order type followup treatment quit total_n perc
			save "X:\Psychology\ResearchProjects\GMJTaylor/CRUK Fellowship/Trial/Results/REDCAP data/working_data/quit_`q'`i'", replace
			}
		}

	//Append quit rates to gen table
	use "X:\Psychology\ResearchProjects\GMJTaylor/CRUK Fellowship/Trial/Results/REDCAP data/working_data/quit_itt3", clear

		//Loop over complete case and itt quit rates and quit attempts
			foreach q in itt cc {
				//loop over follow-ups
				foreach i in 3 6 {
					append using   "X:\Psychology\ResearchProjects\GMJTaylor/CRUK Fellowship/Trial/Results/REDCAP data/working_data/quit_`q'`i'"
				}
			}
	duplicates drop
	format %9.1g perc
	sort type followup treatment

	compress
	export excel using "X:\Psychology\ResearchProjects\GMJTaylor/CRUK Fellowship/Trial/Results/paper_tables_figures/table_quit_rates.xlsx", sheetreplace firstrow(variables)
	
	
**# Bookmark #2
//analyse quit data - logistic regression models - ITT
	//set drive 
	cd "X:\Psychology\ResearchProjects\GMJTaylor/CRUK Fellowship/Trial/Results/REDCAP data/"

	//open data
	use "working_data/mimic_trial", clear
	
	//We will present the unadjusted model, and adjusted model for site
	
	foreach i in 3 6  {
		logistic quit_itt_`i'm rand_allocation , or
		regsave using "working_data/itt_mimic_`i'_unadj", detail(all)  replace ci pval 
		logistic quit_itt_`i'm rand_allocation site , or
		regsave using "working_data/itt_mimic_`i'_adj", detail(all) replace ci pval 
	}
	
	///Append estimates table 
	foreach model in adj unadj { 
		foreach i in 3 6 {  
			use "working_data/itt_mimic_`i'_`model'" , replace
			keep if (var=="eq1:rand_allocation" | var=="quit_itt_`i'm:rand_allocation")
			keep  coef ci_lower ci_upper N var pval

			//Convert coeficients into odds ratios
			gen or=exp(coef)
			gen or_ci_lower=exp(ci_lower)
			gen or_ci_upper=exp(ci_upper)
			keep N or or_ci_lower or_ci_upper var pval
			order var or or_ci_lower or_ci_upper pval N  
			save "working_data/itt_table_mimic_`i'_`model'.dta" , replace
		} 
	}

	///Build table 
	use "working_data/itt_table_mimic_3_unadj.dta" , clear
	append using "working_data/itt_table_mimic_3_adj.dta" 
	append using "working_data/itt_table_mimic_6_adj.dta" 
	append using "working_data/itt_table_mimic_6_unadj.dta" 
	export excel using "X:\Psychology\ResearchProjects\GMJTaylor/CRUK Fellowship/Trial/Results/paper_tables_figures/table_mimic_itt_quit.xlsx", sheetreplace firstrow(variables)

	
**# Bookmark #3
//analyse quit data - logistic regression models - complete case
	//set drive 
	cd "X:\Psychology\ResearchProjects\/GMJTaylor/CRUK Fellowship/Trial/Results/REDCAP data/"

	//open data
	use "working_data/mimic_trial", clear
	
	//We will present the unadjusted model, and anadjustedmodel for site
	
	foreach i in 3 6  {
		logistic quit_cc_`i'm rand_allocation , or
		regsave using "working_data/cc_mimic_`i'_unadj_cc", detail(all)  replace ci pval 
		logistic quit_cc_`i'm rand_allocation site, or
		regsave using "working_data/cc_mimic_`i'_adj_cc", detail(all) replace ci pval 
	}
	
	///Append estimates table 
	foreach model in adj unadj { 
		foreach i in 3 6 {  
			use "working_data/cc_mimic_`i'_`model'_cc" , replace
			keep if (var=="eq1:rand_allocation" | var=="quit_cc_`i'm:rand_allocation")
			keep  coef ci_lower ci_upper N var pval

			//Convert coeficients into odds ratios
			gen or=exp(coef)
			gen or_ci_lower=exp(ci_lower)
			gen or_ci_upper=exp(ci_upper)
			keep N or or_ci_lower or_ci_upper var pval
			order var or or_ci_lower or_ci_upper pval  N 
			save "working_data/cc_table_mimic_`i'_`model'_cc.dta" , replace
		} 
	}

	///Build table 
	use "working_data/cc_table_mimic_3_unadj_cc.dta" , clear
	append using "working_data/cc_table_mimic_3_adj_cc.dta" 
	append using "working_data/cc_table_mimic_6_adj_cc.dta" 
	append using "working_data/cc_table_mimic_6_unadj_cc.dta" 
	export excel using "X:\Psychology\ResearchProjects/GMJTaylor/CRUK Fellowship/Trial/Results/paper_tables_figures/table_mimic_quit_cc.xlsx", sheetreplace firstrow(variables)


	
**# Bookmark #4
	//analyse quit attempt data - logistic regression models 
	cd "X:\Psychology\ResearchProjects\GMJTaylor/CRUK Fellowship/Trial/Results/REDCAP data/"

	//open data
	use "working_data/mimic_trial", clear
	
	//We will present the unadjusted model, and adjusted model for site

	foreach i in 3 6  {
		logistic quit_attempt_`i'm rand_allocation , or
		regsave using "working_data/mimic_quitattempt_`i'_unadj", detail(all)  replace ci pval 
		logistic quit_attempt_`i'm rand_allocation site , or
		regsave using "working_data/mimic_quitattempt_`i'_adj", detail(all) replace ci pval 
	}
	
	///Append estimates table 
	foreach model in adj unadj { 
		foreach i in 3 6 {  
			use "working_data/mimic_quitattempt_`i'_`model'" , replace
			keep if (var=="eq1:rand_allocation" | var=="quit_attempt_`i'm:rand_allocation")
			keep  coef ci_lower ci_upper N var pval

			//Convert coeficients into odds ratios
			gen or=exp(coef)
			gen or_ci_lower=exp(ci_lower)
			gen or_ci_upper=exp(ci_upper)
			keep N or or_ci_lower or_ci_upper var pval
			order var or or_ci_lower or_ci_upper pval N 
			save "working_data/table_mimic_quitattempt_`i'_`model'.dta" , replace
		} 
	}

	///Build table 
	use "working_data/table_mimic_quitattempt_3_unadj.dta" , clear
	append using "working_data/table_mimic_quitattempt_3_adj.dta" 
	append using "working_data/table_mimic_quitattempt_6_adj.dta" 
	append using "working_data/table_mimic_quitattempt_6_unadj.dta" 
	export excel using "X:\Psychology\ResearchProjects\GMJTaylor/CRUK Fellowship/Trial/Results/paper_tables_figures/table_mimic_quitattempt.xlsx", sheetreplace firstrow(variables)

**# Bookmark #5
	//analyse  IAPT treatment completion  - logistic regression models
	cd "X:\Psychology\ResearchProjects\GMJTaylor/CRUK Fellowship/Trial/Results/REDCAP data/"

	//open data
	use "working_data/primaryoutcome", clear
	
	//We will present the unadjusted model, and adjusted model for site

	foreach i in 3 6  {
		logistic iapt_completed_treatment_`i'm rand_allocation , or
		regsave using "working_data/iapt_completed_treatment_`i'_unadj", detail(all)  replace ci pval 
		logistic iapt_completed_treatment_`i'm rand_allocation site , or
		regsave using "working_data/iapt_completed_treatment_`i'_adj", detail(all) replace ci pval 
	}
	
	///Append estimates table 
	foreach model in adj unadj { 
		foreach i in 3 6 {  
			use "working_data/iapt_completed_treatment_`i'_`model'" , replace
			keep if (var=="eq1:rand_allocation" | var=="iapt_completed_treatment_`i'm:rand_allocation")
			keep  coef ci_lower ci_upper pval N var 

			//Convert coeficients into odds ratios
			gen or=exp(coef)
			gen or_ci_lower=exp(ci_lower)
			gen or_ci_upper=exp(ci_upper)
			keep N or or_ci_lower or_ci_upper var pval
			order var or or_ci_lower or_ci_upper pval N 
			save "working_data/table_iapt_completed_treatment_`i'_`model'.dta" , replace
		} 
	}

	///Build table 
	use "working_data/table_iapt_completed_treatment_3_unadj.dta" , clear
	append using "working_data/table_iapt_completed_treatment_3_adj.dta" 
	append using "working_data/table_iapt_completed_treatment_6_adj.dta" 
	append using "working_data/table_iapt_completed_treatment_6_unadj.dta" 
	export excel using "X:\Psychology\ResearchProjects\GMJTaylor/CRUK Fellowship/Trial/Results/paper_tables_figures/iapt_completed_treatment.xlsx", sheetreplace firstrow(variables)

		