log using "X:\Psychology\ResearchProjects\/GMJTaylor/CRUK Fellowship/Trial/Results/paper_tables_figures/analyse_smoke_session", replace

//This do file analyses smoking cessation treatment-related feasibility outcomes  and 
	//(x sessions attempted, x completed. 
	//number requesting to stop treatment in treatment arm, duration of sessions, medications used

//Gemma Taylor
//2023 12 08

//set drive 
cd "X:\Psychology\ResearchProjects\GMJTaylor\CRUK Fellowship\Trial\Results/REDCAP data/"

//open data
use working_data/_analysis_smoking_session_out, clear

	//In the treatment arm x IAPT sessions were delivered. 
		//those with missing IAPT session data - assume there were 0 sessions
		replace sess_attem_imputed=0 if sess_attem_imputed==. 
		bys rand_allocation: summarize sess_attem_imputed, detail
	
	//During these routine appointments on average xx smoking sessions were delivered.
	 bys rand_allocation: summarize smoke_sess_compl, detail

	//x sessions were unable to be delivered
	summarize smoke_sess_ncompl if rand_allocation==1, detail

	//x of participants requested to discontinue the smoking cessation treatment
	tab smoke_discon if rand_allocation==1
	
	//of those that discontinued x because...
	tab smoke_discon_reason  if rand_allocation==1

	//generate table
	estpost tabulate smoke_discon_reason  if rand_allocation==1
	esttab using "/Volumes/GMJTaylor/CRUK Fellowship/Trial/Results/paper_tables_figures/table_smoke_discon_reason.csv", cells("b(label(Frequency)) 	pct(fmt(1))) varlabels(`e(labels)', blist(Total))  label nonumber  noobs replace b(%  5.1f)

	//average duration of smoking cessation sessions were
	table1_mc if rand_allocation==1,   vars(sctd_duration1 contn %5.1f \ sctd_duration2 contn %5.1f \ sctd_duration3 contn  %5.1f \ sctd_duration4 contn %5.1f 		\ sctd_duration5 contn %5.1f \ sctd_duration6 contn %5.1f \ sctd_duration7 contn %   5.1f \ sctd_duration8 contn %5.1f \ sctd_duration9 contn %5.1f )  		saving ("/Volumes/GMJTaylor/CRUK Fellowship/Trial/Results/paper_tables_figures/table_smoke_sess_duration.xlsx", replace) 

	//mean average duration in minutes for appoinment 1 - smoking assessment session was
	sum sctd_duration1

	//mean duration of follow-up sessions were on average . 
	egen avgfollowup = rmean( sctd_duration2 sctd_duration3 sctd_duration4 sctd_duration5 sctd_duration6 sctd_duration7 sctd_duration8)
	sum avgfollowup
	
	//At appointment 1 and 2 what medicine was prescribed
	tab meds_appt1 if rand_allocation==1
	tab meds_appt2 if rand_allocation==1
	
		//appt 1 and gen table
		estpost tabulate meds_appt1  if rand_allocation==1
		esttab using "/Volumes/GMJTaylor/CRUK Fellowship/Trial/Results/paper_tables_figures/table_meds_appt1.csv", cells("b(label(Frequency)) pct(fmt(1))") varlabels(`e(labels)', blist(Total))  label nonumber  noobs replace b(%5.0f)
		//appt 2 and gen table
		estpost tabulate meds_appt2  if rand_allocation==1
		esttab using "/Volumes/GMJTaylor/CRUK Fellowship/Trial/Results/paper_tables_figures/table_meds_appt2.csv", cells("b(label(Frequency)) pct(fmt(1))") varlabels(`e(labels)', blist(Total))  label nonumber  noobs replace b(%5.0f)

	//%XX% of IAPT sessions contained smoking cessation behavioural support
		//using smoke_sess_compl sess_attem_imputed - replace missing .==0
		replace smoke_sess_compl=0 if smoke_sess_compl==.
		//gen var to indicate % of sessions that contained smoking cessation support
		gen sess_w_smok_support = (smoke_sess_compl/sess_attem_imputed)
		//what is the average % of sessions containing smoking cessation support
			
		//gen var to indicate if participant was offered any smoking cessation support
		gen sess_w_smok_yn=1 if smoke_sess_compl>=1
		replace sess_w_smok_yn=0 if sess_w_smok_yn==.
		tab  rand_allocation sess_w_smok_yn, row
		
log close

