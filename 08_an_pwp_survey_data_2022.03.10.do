//This do file analyses data for the client smoking satisfcation questionnaire data
//Gemma Taylor
//2022 03 10
	
//Set path
cd "/Volumes/GMJTaylor/CRUK Fellowship/Trial/Results"

//Open data
use "Qualtrics data/clean data.dta", clear
	
//Generate tables and export each table to an individual file in excel 	(http://repec.org/bocode/e/estout/estpost.html#estpost108)
	foreach i in q12 q13 q14 q15 q16 q17 q18 q21 q22 q23 q32 q26 q35 q28 q29 q31 v50 q33 q34    {
		quietly: estpost tabulate `i' 
		quietly : esttab using "Qualtrics data/working_data/`i'.csv", cells("b(label(Frequency)) pct(fmt(1))") varlabels(, blist(Total)) label nonumber  noobs replace 
		}

//Generate tables and export each table to an individual file in excel 	(http://repec.org/bocode/e/estout/estpost.html#estpost108)
	foreach i in q12 q13 q14 q15 q16 q17 q18 q21 q22 q23 q32 q26 q35 q28 q29 q31 v50 q33 q34 v53   {
		quietly: import delimited "Qualtrics data/working_data/`i'.csv", delimiter("") clear 
		quietly: save "Qualtrics data/working_data/`i'", replace
		}

	use "Qualtrics data/working_data/q12" , clear

	foreach i in  q13 q14 q15 q16 q17 q18 q21 q22 q23 q32 q26 q35 q28 q29 q31 v50 q33 q34  {
		quietly: append using "Qualtrics data/working_data/`i'"
		}
	
//Export table of PWP satisfaction results
	export delimited using "paper_tables_figures/table_pwp_satis.csv", replace
	
//Export table of PWP characteristics and sustainability question
	use "Qualtrics data/clean data.dta", clear
	table1_mc, vars(q6 cat %5.1f \ q8  contn  %5.1f \ q7 cat %5.1f \ q9 cat %5.1f\ q10 cat %5.1f\  ///
	q4 cat  %5.1f \ q5 contn %5.1f \ v53 contn %5.1f) saving("paper_tables_figures/table_pwp_char_sustain.xlsx", replace) 

