//This do file analyses the client smoking satisfcation questionnaire data
//Gemma Taylor
//2022 03 10

//Set path
cd "/Volumes/GMJTaylor/CRUK Fellowship/Trial/Results/REDCAP data/"	

//install package
ssc install estout

//Open data
use "working_data/css.dta", clear
	
//Generate tables and export each table to an individual file in excel 	(http://repec.org/bocode/e/estout/estpost.html#estpost108)
	foreach i in access_stop_smoke_session how_long_css satis_css recm_css rtn_css welcome_css smoked_css appt_css ///
	time_css encrg_css cnvn_css staff_css advice_css writ_css info_css mdcn_css {
		quietly: estpost tabulate `i' if rand_allocation==1
		quietly : esttab using working_data/`i'.csv, cells("b(label(Frequency)) pct(fmt(1))") varlabels(, blist(Total)) label nonumber  noobs replace 
		}

//Generate tables and export each table to an individual file in excel 	(http://repec.org/bocode/e/estout/estpost.html#estpost108)
	foreach i in access_stop_smoke_session how_long_css satis_css recm_css rtn_css welcome_css smoked_css appt_css ///
	time_css encrg_css cnvn_css staff_css advice_css writ_css info_css mdcn_css {
		quietly: import delimited "working_data/`i'.csv", delimiter("") clear 
		quietly: save "working_data/`i'", replace
		}

	use "working_data/access_stop_smoke_session" , clear

	foreach i in how_long_css satis_css recm_css rtn_css welcome_css smoked_css appt_css ///
	time_css encrg_css cnvn_css staff_css advice_css writ_css info_css mdcn_css {
		quietly: append using "working_data/`i'"
		}
		
//export final table to excel
compress
export delimited using "/Volumes/GMJTaylor/CRUK Fellowship/Trial/Results/paper_tables_figures/table_css_statisf.csv", replace


