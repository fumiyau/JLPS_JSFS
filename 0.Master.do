cd "/Users/fumiyau/Documents/GitHub/JLPS-JSFS/"
log using `"`path'JLPS_JSFS`=subinstr("`c(current_date)'"," ","",.))'.log"', replace
set more off
do "/Users/fumiyau/Documents/GitHub/JLPS-JSFS/1.DataConst-Wide.do"
do "/Users/fumiyau/Documents/GitHub/JLPS-JSFS/2.DataConst-Long.do" 
do "/Users/fumiyau/Documents/GitHub/JLPS-JSFS/3.Analysis.do"
log close
