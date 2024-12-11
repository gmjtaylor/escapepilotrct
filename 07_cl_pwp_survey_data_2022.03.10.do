//This file cleans and extracts descriptive data for the client smoking satisfcation questionnaire data
//Gemma Taylor
//2021 03 10

/* //install  labutil.pkg
    // from:  http://fmwww.bc.edu/RePEc/bocode/l/ */

//set path
cd "/Volumes/GMJTaylor/CRUK Fellowship/Trial/Results"

//install relevant programes
	/*ssc install estout 
	ssc install outreg2 */
	
//import csv string and numerical file	s
	//numerical
		import delimited "Qualtrics data/Clinical+Audit+-+ESCAPE+Trial_November+9,+2021_01.58.csv", varnames(1) clear
		
		foreach i in q2 q4 q6 q7 q8 q9  q10 q12 q13 q14 q15 q16 q17 q18  q21 q22 q23 q32 q26 q35 q28 q29 q31 v50 q33 q34 v53 {
			rename `i' `i'_num
			}
		
		drop in 1/33
		drop if responseid==""	
		compress
		drop distributionchannel durationinseconds enddate externalreference finished ipaddress locationlatitude ///
		   locationlongitude recipientemail recipientfirstname recipientlastname sc0 startdate status userlanguage
		order responseid recordeddate progress
		
		//drop variables with 100% missing
		mdesc
		drop q7_4_text q9_13_text q9_16_text q9_18_text
		compress
		save "Qualtrics data/working_data/numerical_data.dta", replace
		
	//string
		import delimited "Qualtrics data/Clinical+Audit+-+ESCAPE+Trial_November+4,+2021_06.12.csv", varnames(1) clear
		
		drop in 1/33
		drop if responseid==""
		order responseid recordeddate progress
			drop distributionchannel durationinseconds enddate externalreference finished ipaddress locationlatitude ///
		   locationlongitude recipientemail recipientfirstname recipientlastname sc0 startdate status userlanguage
		order responseid recordeddate progress
		
		//drop variables with 100% missing
		mdesc
		drop q7_4_text q9_13_text q9_16_text q9_18_text
		compress
		save "Qualtrics data/working_data/string_data.dta", replace
	
	
//merge string and numerical data
		use "Qualtrics data/working_data/string_data.dta", clear
		merge 1:1 responseid using  "Qualtrics data/working_data/numerical_data.dta"
		destring, replace
		compress
		drop _m
		
		foreach i in q2 q4 q6 q7 q8 q9  q10 q12 q13 q14 q15 q16 q17 q18  q21 q22 q23 q32 q26 q35 q28 q29 q31 v50 q33 q34 v53  {
			labmask `i'_num, values (`i')
			drop `i'
			rename `i'_num `i'
				}

//Label variables		
			
	//label demographic information
		label variable q2 "consent"
		label variable q4 "role"
		label variable q4_5_text  "role other"     
		label variable q5 "how many years have you been working in your current role?"
		label variable q6 "site"
		label variable q7 "gender"
		label variable q8 "age"
		label variable q9 "ethnicity"
		label variable q9_4_text "ethnicity other"
		label variable q9_8_text "ethnicity other"
		label variable q10 "smoking status"

	//label satisfaction
		label variable q12 "Satisfaction- I was satisfied with the delivery of the smoking cessation intervention"
		label variable q13 "Satisfaction- The length of sessions was adequate"
		label variable q14 "Satisfaction- The structure of sessions was logical"
		label variable q15 "Satisfaction- The intervention manual was easy to use"
		label variable q16 "Satisfaction- I kept to the intervention framework in the sessions"
		label variable q17 "Satisfaction- The intervention seemed to meet my patient’s needs"
		label variable q18 "Satisfaction- I would be happy to offer this intervention again"
		label variable q19 "Satisfaction- Do you have any comments or further information you would like to offer about the statements above. Or any other thoughts or comments about the intervention"

	//label accacptaibility of intervention
		label variable q21 "AIM The smoking cessation intervention meets my approval"
		label variable q22 "AIM The smoking cessation intervention is appealing to me"
		label variable q23 "AIM I like the smoking cessation intervention"
		label variable q32 "AIM I welcome the smoking cessation intervention"

	//label apprropriateness of intervention
		label variable q26 "IAM The smoking cessation intervention seems fitting"
		label variable q35 "IAM The smoking cessation intervention seems suitable"
		label variable q28 "IAM The smoking cessation intervention seems applicable"
		label variable q29 "IAM The smoking cessation intervention seems like a good match"
		label variable q31 "FIM The smoking cessation intervention seems implementable"

	//label feasibility of intervention
		label variable v50 "FIM The smoking cessation intervention seems possible"
		label variable q33 "FIM The smoking cessation intervention seems doable"
		label variable q34 "FIM The smoking cessation intervention seems easy to use"
	
	//sustainaibility of the intervention	
		label variable v53 "Sustainability - Please rate how well you think the smoking cessation intervention could be sustained in the service in the future"
		label variable q36 "Sustainability - Please provide a little more information about your answer in the box below"

//clean number of years working
	replace q5= "4" if q5 =="1 (4yrs in PWP roles total)" 
	replace q5= "0.83" if q5 =="I started in January 2021" 
	replace q5= "1" if q5 =="1 year" 
	replace q5= "0.42" if q5 =="5 months" 
	replace q5= "6" if q5 =="6 years" 
	destring, replace

	order responseid progress recordeddate  q6 q8 q7 q8 q9 q9_4_text q9_8_text q10 q2 q4 q4_5_text q5 q12 q13 q14 q15 q16 q17 q18 q19 q21 q22 q23 q32 q26 q35 q28 q29 q31 v50 q33 q34 q36 v53

	compress
	save "Qualtrics data/clean data.dta", replace
