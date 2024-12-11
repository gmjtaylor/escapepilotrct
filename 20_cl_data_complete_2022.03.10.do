//This file cleans data collection and completeness of full trial outcomes 
//Gemma Taylor
//2022 03 10				

//set drive 
cd "/Volumes/GMJTaylor/CRUK Fellowship/Trial/Results/REDCAP data/"

//number of clinical studies officers
	//loop over each follow-up
	foreach i in 3 6 {
		use "working_data/clinical.dta", clear
		keep if redcap_event_name=="`i'_month_follow_up_arm_1"
		//take out blank spaces from string id
		replace ou_researcher_3m = subinstr(ou_researcher_3m," ","",.)
		drop if ou_researcher_3m==""
		replace ou_researcher_3m = upper(ou_researcher_3m)
		replace ou_researcher_3m="ES" if ou_researcher_3m=="ERICASUGITA"
		replace ou_researcher_3m="AC" if ou_researcher_3m=="ANACARDOSO"

		bysort ou_researcher_3m : gen nvals = _n ==1
		replace nvals = sum(nvals)
		replace nvals = nvals[_N]
		keep nvals ou_researcher_3m redcap_data_access_group
		order redcap_data_access_group ou_researcher_3m nvals
		sort redcap_data_access_group ou_researcher_3m 
		compress
		save "/Volumes/GMJTaylor/CRUK Fellowship/Trial/Results/REDCAP data/working_data/n_researcher_`i'm.dta", replace
		tab nvals
		}

//data completeness by month for PHQ/GAD/Smoking status/Bio data - highlight periods where katherine or shadi led on data collection
	//first gen baseline date for clinical data
	use "working_data/clinical.dta", clear
	keep if redcap_event_name=="baseline_arm_1"
	keep ou_bl_date pcmis_iaptus_no
	compress
	save "working_data/baselinedate.dta", replace

	//extract present/missingness of variables at 3 and 6 months, and save to separate data sets
	foreach i in 3 6 {
		use "working_data/clinical.dta", replace
		keep if redcap_event_name=="`i'_month_follow_up_arm_1"
		
		//gen var to indicate that data were collected and within 2 months of due date
		gen quityn=1 if quit_yn_3m!=. 
		gen phqyn=1 if mh_phq9_score_calc_3m!=. 
		gen gadyn=1 if mh_gad7_score_calc_3m!=. 
		keep quityn phqyn gadyn pcmis_iaptus_no ou_appt_date_3m

		//merge in baseline (clinical) dates
		merge 1:1 pcmis_iaptus_no using  "working_data/baselinedate"
		compress
		save working_data/data_`i', replace
		}
		
		//gen variable to indicate month and year that data were due - 3 months
		use working_data/data_3, clear
		gen due=ou_bl_date+120
			//if clinical baseline date is missing assume due date is 3 month follow-up data entry date minus 4 months
			replace due=(ou_appt_date_3m-120) if ou_appt_date_3m==.
			//if clinical baseline date and follow-up data entry date are missing assume clinical baseline date is randomisation date plus 2 months (average waiting time between randomisation and clinical baseline
				//bring in randomisation date
				drop _m
				merge 1:1 pcmis_iaptus_no using working_data/admin.dta, keepusing(rand_dte)
				replace due=(rand_dte+120) if ou_bl_date==. & ou_appt_date_3m==.
				replace due=(rand_dte+120) if due==.
				drop _m
				drop if rand_dte==.
				compress
				save working_data/data_3new, replace
		
		//gen variable to indicate month and year that data were due - 6 months
		use working_data/data_6, clear
		gen due=ou_bl_date+240
			//if clinical baseline date is missing assume due date is 3 month follow-up data entry date minus 4 months
			replace due=(ou_appt_date_3m-240) if ou_appt_date_3m==.
			//if clinical baseline date and follow-up data entry date are missing assume clinical baseline date is randomisation date plus 2 months (average waiting time between randomisation and clinical baseline
				//bring in randomisation date
				drop _m
				merge 1:1 pcmis_iaptus_no using working_data/admin.dta, keepusing(rand_dte)
			replace due=(rand_dte+240) if ou_bl_date==. & ou_appt_date_3m==.
			replace due=(ou_bl_date+210) if due==.
			replace due=ou_appt_date_3m if due==.
			drop _m
			drop if rand_dte==.
			compress
			save working_data/data_6new, replace
		
		//reopen data files to generate variable to indicate when data were due
		foreach i in 3 6 {
			use working_data/data_`i'new, clear
			gen duedate = mofd(due)
			gen collectiondate = mofd(ou_appt_date_3m)
			drop due
			sort duedate
			gen due_month = month(dofm(duedate))
			gen due_year = yofd(dofm(duedate))
			gen due_date=duedate
			format %tmMonth_CCYY due_date
					
			//drop unused variables	
			drop  ou_bl_date 
			order pcmis_iaptus_no duedate due_date due_year due_month collectiondate
			label variable collectiondate "Date of data collection"
			label variable duedate "Date followup was due"
			order pcmis_iaptus_no rand_dte duedate due_date due_year due_month collectiondate ou_appt_date_3m
			compress
			save working_data/present_`i', replace
			}
		
		//extract n complete data from start of trial to follow-up due date
		//loop over duedates for each follow-up period
		foreach f in 3 6 {	
			foreach var in quit gad phq { 
				use working_data/present_`f', clear			
				su duedate, meanonly
			
			foreach i of num `r(min)'/`r(max)'    {
					use working_data/present_`f', clear			
					su duedate, meanonly
				
				//keep all participants due from start of trial to x due date
					keep if duedate<=`i'
						
				//what is the denominator = accumulative n participatns overall since start of trial to new month 
					gen count=1
					egen denominator = total(count)
					label variable denominator "denominator - n participants with follow-up due from start of trial to x month"

				//what is the numberator = n participants with complete data from start of trial to new month - loop over each variable
					//generate accumulative count/sum of present data for var
						gen numerator_`var'= sum(`var'yn)
						label variable numerator_`var' "numerator gad - n participants with complete data from start of trial to x month"
				//keep row with largest value as the numerator
					generate keep`var' = 1 if _n == _N
					keep if  keep`var'==1
					keep due_date denominator numerator_`var'
					compress
					save working_data/datacomplete_`f'_`var'_`i', replace
						}
					}
				}
		
		//build table by appending rows which represent the numer of participicants with complete data from start of trial, who are due, by month
		foreach f in 3 6 {	
			use working_data/present_`f', clear			
			su duedate, meanonly
			foreach var in quit gad phq { 
			use working_data/present_`f', clear			
			su duedate, meanonly

					use "/Volumes/GMJTaylor/CRUK Fellowship/Trial/Results/REDCAP data/working_data/datacomplete_`f'_`var'_709.dta", clear
					foreach i of num `r(min)'/`r(max)'  {
						append using working_data/datacomplete_`f'_`var'_`i'
									}
						duplicates drop
					gen perc_`var'= numerator_`var'/denominator
					compress
					save working_data/table_datacomplete_`f'_`var', replace
					}
				
				//merge rows by due_date
				use working_data/table_datacomplete_`f'_gad, clear
					merge 1:1 due_date using working_data/table_datacomplete_`f'_phq
					drop _m
					merge 1:1 due_date using working_data/table_datacomplete_`f'_quit
					drop _m
					order due_date denominator numerator_quit perc_quit
					compress
					save working_data/table_datacomplete_`f', replace
					export excel using "/Volumes/GMJTaylor/CRUK Fellowship/Trial/Results/paper_tables_figures/table_datacomplete_`f'0302.xlsx", firstrow(variables) replace
					}								
					
//values imputed from clinical contact notes (PHQ/GAD/ smoking)
	//open clinical data, and keep yes/no imputation variables. collapse values to create table.
	foreach i in 3 6 { 
		use "working_data/clinical.dta", clear
		keep if redcap_event_name=="`i'_month_follow_up_arm_1"
		keep phq9_iapt_input gad7_iapt_input quit_stts_iapt_input
		collapse (sum) phq9_iapt_input gad7_iapt_input quit_stts_iapt_input
		gen followup="`i'months"
		order followup
		compress
		save working_data/table_n_imputed`i', replace
	}

	//build table, and export to excel
	use working_data/table_n_imputed3, clear
	append using working_data/table_n_imputed6
	export excel using "/Volumes/GMJTaylor/CRUK Fellowship/Trial/Results/paper_tables_figures/table_n_imputed.xlsx", firstrow(variables) replace

//differential drop out by month
	//extract questions about drop out, and then collapse by month 
		foreach i in 3 6 {   
			use "working_data/clinical.dta", clear
			keep if redcap_event_name=="`i'_month_follow_up_arm_1"
			merge 1:1 pcmis_iaptus_no using  "working_data/admin" , keepusing (randomisation_complete rand_allocation)
			drop if randomisation_complete==.
		//merge two variables that have asked the same question and keep relevant variables
			replace difficulty_contacting= ou_fu_not_completed_3m if difficulty_contacting==.
			keep pcmis_iaptus_no rand_allocation stop_study difficulty_contacting 	

			//merge due date from file generated above
			merge 1:1 pcmis_iaptus_no using  "working_data/present_`i'", keepusing (due_date)
			drop _m
			
			//extract due year
			gen due_year = yofd(dofm(due_date))
			drop due_date
			
			//reshape wide by treatment arm 
			reshape wide stop_study difficulty_contacting, i(pcmis_iaptus_no) j(rand_allocation)
			drop pcmis_iaptus_no
			
			//collapse variables by due year to create table
			collapse (sum) stop_study0 difficulty_contacting0 stop_study1 difficulty_contacting1, by (due_year)			
			
			//gen month and n variables for table
			gen followup="`i' months"
			gen n=135
			
			//gen var for percent of people dropping out divided by n in trial
			foreach var in stop_study0 stop_study1 difficulty_contacting0 difficulty_contacting1 {
				gen `var'_perc= `var'/n
				}
			
			//order, compress and save
			compress
			order followup due_year n stop_study0 stop_study0_perc stop_study1 stop_study1_perc difficulty_contacting0 difficulty_contacting0_perc difficulty_contacting1 difficulty_contacting1_perc
			compress
			save working_data/table_diff_followup`i', replace
			}

	//gen overall differential drop out
			foreach i in 3 6 {   
			use "working_data/clinical.dta", clear
			keep if redcap_event_name=="`i'_month_follow_up_arm_1"
			merge 1:1 pcmis_iaptus_no using  "working_data/admin" , keepusing (randomisation_complete rand_allocation)
			drop if randomisation_complete==.
		//merge two variables that have asked the same question and keep relevant variables
			replace difficulty_contacting= ou_fu_not_completed_3m if difficulty_contacting==.
			keep pcmis_iaptus_no rand_allocation stop_study difficulty_contacting 	

			//reshape wide by treatment arm 
			reshape wide stop_study difficulty_contacting, i(pcmis_iaptus_no) j(rand_allocation)
			drop pcmis_iaptus_no
			
			//collapse variables by due year to create table
			collapse (sum) stop_study0 difficulty_contacting0 stop_study1 difficulty_contacting1		
			
			//gen month and n variables for table
			gen followup="`i' months"
			gen due_year="overall"
			gen n=135
			
			//gen var for percent of people dropping out divided by n in trial
			foreach var in stop_study0 stop_study1 difficulty_contacting0 difficulty_contacting1 {
				gen `var'_perc= `var'/n
				}
			//order, compress and save
			compress
			order followup due_year n stop_study0 stop_study0_perc stop_study1 stop_study1_perc difficulty_contacting0 difficulty_contacting0_perc difficulty_contacting1 difficulty_contacting1_perc
			compress
			save working_data/table_diff_followup`i'ovr, replace
}
	
	//build table, and export to excel
	use working_data/table_diff_followup3, clear
	append using working_data/table_diff_followup6
	append using working_data/table_diff_followup3ovr, force
	append using working_data/table_diff_followup6ovr, force
	
	//gen var to indicate % diff in drop out
	gen stop_study_diff= stop_study1_perc-stop_study0_perc
	gen difficulty_contacting_diff= difficulty_contacting1_perc-difficulty_contacting0_perc
	order followup due_year n stop_study0 stop_study0_perc stop_study1 stop_study1_perc stop_study_diff difficulty_contacting0 difficulty_contacting0_perc difficulty_contacting1 difficulty_contacting1_perc difficulty_contacting_diff
	compress
	export excel using "/Volumes/GMJTaylor/CRUK Fellowship/Trial/Results/paper_tables_figures/table_diff_followup.xlsx", firstrow(variables) replace
