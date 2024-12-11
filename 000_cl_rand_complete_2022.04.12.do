//This do file generates randomisation complete file for linkage purposes
//Gemma Taylor
//2022 04 12

//Set path
cd "X:\Psychology\ResearchProjects\GMJTaylor\CRUK Fellowship\Trial\Results\REDCAP data\"

//Clean admin data and save 
	use "working_data/admin.dta", clear
	drop if old_pcmis_iaptus_no==""
	keep if randomisation_complete==2
	keep rand_allocation pcmis_iaptus_no site
	compress
	save "working_data/randomisation_complete", replace

	
	