//This do file cleans and analyses blinded outcome data collection at 2- and 6-months follow-up
//Gemma Taylor
//2022 10 03

//set drive 
cd "/Volumes/GMJTaylor/CRUK Fellowship/Trial/Results/REDCAP data/"

//open data
use redcap_event_name pcmis_iaptus_no  ou_aware_trtmnt_yn_3m using "working_data/clinical.dta", replace
order pcmis_iaptus_no redcap_event_name 

//clean redcap event name ready for reshape
rename ou_aware_trtmnt_yn_3m ou_aware_trtmnt_
keep if redcap_event_name== "3_month_follow_up_arm_1" | redcap_event_name=="6_month_follow_up_arm_1"
	foreach i in 3 6 {
		replace redcap_event_name= "`i'm" if redcap_event_name== "`i'_month_follow_up_arm_1"
		}
		
//compress and clean
destring, replace
compress

//reshape wide
reshape wide ou_aware_trtmnt_ , i(pcmis_iaptus_no) j(redcap_event_name) string

//bring in randomisation data
merge 1:1 pcmis_iaptus_no using working_data/randomisation_complete

//clean
drop _m
drop if rand_allocation==.

//appt 1 and gen table
estpost tab ou_aware_trtmnt_3m rand_allocation
esttab using "/Volumes/GMJTaylor/CRUK Fellowship/Trial/Results/paper_tables_figures/table_blinding.csv", cells("b(label(Frequency_3m)) colpct(fmt(1))") varlabels(`e(labels)', blist(Total))  label nonumber  noobs replace b(%5.3f)

estpost tab ou_aware_trtmnt_6m rand_allocation
esttab using "/Volumes/GMJTaylor/CRUK Fellowship/Trial/Results/paper_tables_figures/table_blinding.csv", cells("b(label(Frequency_6m)) colpct(fmt(1))") varlabels(`e(labels)', blist(Total))  label nonumber  noobs  append  b(%5.0f)

estpost tab  ou_aware_trtmnt_3m site
esttab using "/Volumes/GMJTaylor/CRUK Fellowship/Trial/Results/paper_tables_figures/table_blinding.csv", cells("b(label(Frequency_3m)) colpct(fmt(1))") varlabels(`e(labels)', blist(Total))  label nonumber  noobs  append  b(%5.0f)

estpost tab ou_aware_trtmnt_6m site
esttab using "/Volumes/GMJTaylor/CRUK Fellowship/Trial/Results/paper_tables_figures/table_blinding.csv", cells("b(label(Frequency_6m)) colpct(fmt(1))") varlabels(`e(labels)', blist(Total))  label nonumber  noobs  append  b(%5.0f)


