//This do file cleans the client smoking satisfcation questionnaire data
//Gemma Taylor
//2022 03 10

//Set path
cd "/Volumes/GMJTaylor/CRUK Fellowship/Trial/Results/REDCAP data/"

//Install relevant programes
	/*ssc install estout 
	ssc install outreg2 */

//Open admin data
 use "working_data/randomisation_complete", clear
 
//Merge 3 month analysis data
	merge 1:1 pcmis_iaptus_no using  "working_data/analysis_3m_data", update
	keep pcmis_iaptus_no rand_allocation site access_stop_smoke_session satis_css recm_css rtn_css welcome_css smoked_css appt_css ///
	how_long_css time_css encrg_css cnvn_css staff_css advice_css writ_css info_css mdcn_css

//Save data for analytical purposes
	save "working_data/css.dta", replace
	use "working_data/css.dta", clear
	
//fix labels on long variable lables
	label variable satis_css "Overall how satisfied are you with the support you have received to stop smoking"
	label variable access_stop_smoke_session "Since you started therapy with IAPT have you recieved smoking cessation support?"
	label variable satis_css "Overall how satisfied are you with the support you have received to stop smoking?"
	label variable how_long_css "How long did you have to wait before your first appointment?"
	
//Categorise - how_long_css
	gen how_long_css_copy = how_long_css
	replace how_long_css_copy= 0 if how_long_css<30 & how_long_css!=.
	replace how_long_css_copy= 1 if how_long_css>=30 & how_long_css<=60
	replace how_long_css_copy= 2 if how_long_css>60 & how_long_css<=90
	replace how_long_css_copy= 3 if how_long_css>90 & how_long_css<=120
	replace how_long_css_copy= 4 if how_long_css>120  & how_long_css!=.
	replace how_long_css=how_long_css_copy
	label define how_long 0 "Less than 30 days" 1 "Between 30 and 60 days" 2 "Between 61 and 90 days" 3 "Between 91 and 120 days" 4 "More than 120 days"
	drop how_long_css_copy
	label values how_long_css how_long
	
//Save data for analytical purposes
	compress
	save "working_data/css.dta", replace






