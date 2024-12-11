//This do file analyses pilot primary outcomes 
//Gemma Taylor
//2024 09 25

//set drive 
cd "X:\Psychology\ResearchProjects\GMJTaylor\CRUK Fellowship/Trial/Results/REDCAP data/"

//open data
use "working_data/mimic_trial", clear
set more off	
	
//generate table for quit rates at 3 and 6-months follow-up, loop over follow-ups 

	//loop over complete case and itt quit rates
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

	//append quit rates to gen table
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
//analyse quit data - exact logistic regression models - ITT
	//set drive 
	cd "X:\Psychology\ResearchProjects\GMJTaylor/CRUK Fellowship/Trial/Results/REDCAP data/"

	//open data
	use "working_data/mimic_trial", clear
	
	//We will present the unadjusted model
	
	foreach i in 3 6  {
		exlogistic quit_itt_`i'm rand_allocation 
	}
	
**# Bookmark #3
//analyse quit data - exact logistic regression models - complete case
	//set drive 
	cd "X:\Psychology\ResearchProjects\/GMJTaylor/CRUK Fellowship/Trial/Results/REDCAP data/"

	//open data
	use "working_data/mimic_trial", clear
	
	//We will present the unadjusted model
	foreach i in 3 6  {
		exlogistic quit_cc_`i'm rand_allocation 
	}
	
**# Bookmark #4
	//analyse quit attempt data - logistic regression models 
	cd "X:\Psychology\ResearchProjects\GMJTaylor/CRUK Fellowship/Trial/Results/REDCAP data/"

	//open data
	use "working_data/mimic_trial", clear
	
	//We will present the unadjusted model in itt data
	foreach i in 3 6  {
		exlogistic quit_attempt_`i'm rand_allocation 
	}
	
	
	//We will present the unadjusted model in cc data
	foreach i in 3 6  {
		exlogistic quit_attempt_cc`i'm rand_allocation 
	}
	
**# Bookmark #5
	//analyse  IAPT treatment completion  - logistic regression models
	cd "X:\Psychology\ResearchProjects\GMJTaylor/CRUK Fellowship/Trial/Results/REDCAP data/"

	//open data
	use "working_data/primaryoutcome", clear
	
	//We will present the unadjusted model cc data
	foreach i in 3 6  {
		exlogistic iapt_completed_treatment_`i'm rand_allocation 
	}
	
	//We will present the unadjusted model itt data
		foreach i in 3 6  {
			exlogistic iapt_completed_treatment_`i'mitt rand_allocation 
	}
	