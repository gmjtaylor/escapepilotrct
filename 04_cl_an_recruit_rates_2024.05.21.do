//This do file cleans and analyses recruitment rate data
//Gemma Taylor 
//2024 05 21

//Set path
cd "X:\Psychology\ResearchProjects\GMJTaylor\CRUK Fellowship\Trial\Results"
 
//open data
use "REDCAP data/working_data/admin.dta", clear

//drop those where randomisation wasn't completed
keep if randomisation_complete==2

//Split date variable by year and month
g rand_year = year(rand_dte)
g rand_month = month(rand_dte)

//gen var to indicate cumulative count (i.e., 1-135) showing the number of participants recruited into the trial
sort rand_dte
gen count = 1
gen cumulative_count = sum(count)

//Generate graphs for overall study recruitment rate
	//Make line graph to show cumulative count overtime
	format rand_dte %dM,_CY
	line cumulative_count rand_dte, name(fig_1, replace) subtitle("Trusts 1 to 4 combined") xtitle("Participant randomisation date") ytitle("Cumulative recruitment count") graphregion(color(white)) xlabel(21366 "July 2018" 21731  "July 2019" 22097 "July 2020" 22462 "July 2021") scale(.8) 

	//Make bar graph to show recruitment count per month
	ssc install dataex
	gen date = mofd(rand_dte)
	format date %tm
	egen n_recruited = total(count), by(date)
	twoway bar n_recruited date, base(0) name(fig_2, replace) subtitle("Trusts 1 to 4 combined") xtitle("Participant randomisation date") ytitle("Monthly recruitment count") graphregion(color(white))  xlabel(702 "July 2018" 714  "July 2019" 726 "July 2020" 738 "July 2021") scale(.8)  

//Generate graphs for each site's recruitment rate
	//Make bar graph to show recruitment count per month
	foreach i in 1 2 3 4 {
	twoway bar n_recruited date if site==`i', base(0) name(fig_1_site_`i', replace) subtitle("Trust `i'") xtitle("Participant randomisation date") ytitle("Monthly recruitment count") graphregion(color(white))  xlabel(702 "July 2018" 714  "July 2019" 726 "July 2020" 738 "July 2021") scale(.8)  
		}
	
	//Combine graphs into one figure and export
	graph combine  fig_1_site_1 fig_1_site_2 fig_1_site_3 fig_1_site_4 fig_1 fig_2,  graphregion(color(white))    graphregion( margin(medium) ) plotregion( margin(medium) ) row (3)   
	graph save Graph "/Volumes/GMJTaylor/CRUK Fellowship/Trial/Results/paper_tables_figures/fig_recruitment_rates.gph", replace
	graph export "/Volumes/GMJTaylor/CRUK Fellowship/Trial/Results/paper_tables_figures/fig_recruitment_rates.eps", as(eps) preview(off) replace


//gen median recruitment rate, by month, by site (reviewer comment)
bysort rand_year rand_month site : egen count_by_group = count( rand_month )
keep rand_year rand_month count_by_group site count
duplicates drop
summarize count_by_group , detail



 
