//This file cleans smoking cessation outcome data and generates smoking cessation varaibles and saves data to their own dta file. 
//Gemma Taylor
//2022 03 10	

//set drive 
cd "/Volumes/GMJTaylor/CRUK Fellowship/Trial/Results/REDCAP data/"
	
//smoking cessation outcome cleaning - clean smoking cessation and bioverfication data at 3 and 6 months

foreach i in 3 6 {
	///extract smoking cessation data at 3 & 6 months (this is in 6 month follow-up data)
			
			//open analysis data			
			use "working_data/clinical.dta", clear
			keep if redcap_event_name=="`i'_month_follow_up_arm_1"
			
				///complete case - gen gio-verified smoking status at 6 month follow-up - complete cases only
						
				//gen variable to indicate if passed bioverification
				gen bio_ver_`i'm=1 if (co_reading_3m<11 & co_reading_3m!=.)		
				replace bio_ver_`i'm=1 if (bio_cotinine_level<12 & bio_cotinine_level!=.)
				replace bio_ver_`i'm=0 if (co_reading_3m>=11 & co_reading_3m!=.)	
				replace bio_ver_`i'm=0 if (bio_cotinine_level>=12 & bio_cotinine_level!=.)	
				
				//gen bioverified smoking cessation, complete case only
					//gen var to equal bioverification variable
					gen quit_cc_`i'm=bio_ver_`i'm if bio_ver_`i'm!=.
					
					//replace var to equal smoking if var is missing and self-reported data equal smoker
					replace quit_cc_`i'm =0  if quit_cc_`i'm==. & quit_yn_3m==0
					
					//replace var to equal smoking is var is missing, and bioverification data are failed or missing
					replace quit_cc_`i'm =0  if quit_cc_`i'm==. & quit_yn_3m==1 & (bio_ver_`i'm==. | bio_ver_`i'm==0)
				
				//label values
				label values quit_cc_`i'm quit_yn_3m_
			
				//ITT - gen bioverified smoking cessation, those with missing data=smoking
				gen quit_itt_`i'm=quit_cc_`i'm	
				replace quit_itt_`i'm=0 if quit_itt_`i'm==.
				label values quit_itt_`i'm quit_yn_3m_
				
				//save quit complete case and itention to treat variables in a separate file
				keep pcmis_iaptus_no quit_cc_`i'm quit_itt_`i'm  
				
				//label variables
				label variable quit_cc_`i'm "Bioverifed as quit @ `i' - complete cases only (i.e. self report + bio data)"
				label variable quit_itt_`i'm "Bioverifed as quit @ `i' - intention to treat only (i.e. self report + bio data)"
				
				//label variables to indicate follow-up	
				foreach x of varlist _all  {
					local y: variable label `x'
					label var `x' "Follow-up - `y'"
					}	
				
				//ITT only - to ensure all those ranomised are accounted for merge in admin data and assume those randmised and missing data are smokers
				merge 1:1 pcmis_iaptus_no using  "working_data/admin" , keepusing (randomisation_complete)
				replace quit_itt_`i'm=0 if (quit_itt_`i'm==. & randomisation_complete==2)						
				drop if randomisation_complete==.
				
				drop randomisation_complete _m
				compress
				save "working_data/quit_data_`i'm", replace
						}
						



							
							
