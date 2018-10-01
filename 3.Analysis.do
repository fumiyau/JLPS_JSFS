*Husband's income category
gen huscat = husincome 
recode huscat (0/3000000 = 1) (4000000=2) (5250000=3) (7250000=4) (10500000/25000000 = 5)
gen huscat1 =. 
replace huscat1 = huscat if wave == 1
by id: gen huscat1sum  = sum(huscat1)
by id: gen huscatsum  = sum(husincome/7)
by id: egen husincav = max(huscatsum)
recode husincav (0/3500000 = 1) (3500001/4500000=2) (4500001/6000000=3) (6000001/8500000=4) (8500001/25000000 = 5)
recode husincav 5=4,gen(husincavx) 
*Labeling
label define  husincavl 1 "0-350万円" 2 "350-450万円" 3 "450-600万円" 4 "600-850万円" 5 "850万円以上" 
label values husincav husincavl
label define  husincavxl 1 "0-350万円" 2 "350-450万円" 3 "450-600万円" 4 "600万円以上" 
label values husincavx husincavxl 
label define  wiftypel 1 "正規" 2 "非正規" 3 "自営・家族従業" 4 "無職" 
label values wiftype wiftypel 
*Create dummy variables
drop wiftype1 wiftype2 wiftype3 wiftype4 wiftype5 wiftype6 wiftype7 husedu3 wifedu3
tabulate husedu,gen(husedu)
tabulate wifedu,gen(wifedu)
tabulate hustype,gen(hustype)
tabulate wiftype,gen(wiftype)
tabulate seq6,gen(seq6)
tabulate homogamy,gen(homogamy)

*Table1
cd "/Users/fumiyau/Documents/GitHub/JLPS-JSFS/Results/"
quietly estpost tabstat husedu1 husedu2 husedu3 husedu4 wifedu1 wifedu2 wifedu3 wifedu4 hustype1 hustype2 hustype3 hustype4 wiftype1 wiftype2 wiftype3 wiftype4 husincome wifincome wifage numchild seq61 seq62 seq63 seq64 seq65 seq66 homogamy1 homogamy2 homogamy3 homogamy4 homogamy5 if wave == 1, statistics(mean sd max min) columns(statistics)
quietly esttab . using descwave1.csv, replace cells("mean(fmt(3)) sd(fmt(3)) min max(fmt(3))") noobs nonote label
quietly estpost tabstat wiftype1 wiftype2 wiftype3 wiftype4 husincome wifincome  if wave == 7, statistics(mean sd max min) columns(statistics)
quietly esttab . using descwave7.csv, replace cells("mean(fmt(3)) sd(fmt(3)) min max(fmt(3))") noobs nonote label

*Figure 1
tab3way husincavx wiftype4 wave, rowpct

*Table 2
ta husincav wiftype if wave ==1,row

*Figure 2: Gini coefficients
forvalues i=1/7{
fastgini husincome if wave == `i'
}
forvalues i=1/7{
fastgini wifincome if wave == `i'
}
forvalues i=1/7{
fastgini cpincome if wave == `i'
}
forvalues i=1/7{
fastgini sq_husincome if wave == `i'
}
forvalues i=1/7{
fastgini sq_wifincome if wave == `i'
}
forvalues i=1/7{
fastgini sq_cpincome if wave == `i'
}

*Counter factual analysis
forvalues i=1/7{
fastgini cf_husincome if wave == `i'
}
forvalues i=1/7{
fastgini cf_cpincome if wave == `i'
}
forvalues i=1/7{
fastgini sq_cf_husincome if wave == `i'
}
forvalues i=1/7{
fastgini sq_cf_cpincome if wave ==`i'
}

*Table 3: 
*Descriptive stats
mean(wifage) if wave == 1, over(homogamy)
mean(husincome) if wave == 1, over(homogamy)
mean(husincome) if wave == 7, over(homogamy)
mean(wifincome) if wave == 1, over(homogamy)
mean(wifincome) if wave == 7, over(homogamy)
tab seq6 homogamy if wave == 1,col
mean(numchild) if wave == 1, over(homogamy)
mean(numchild) if wave == 7, over(homogamy)

*Table 4: Theil index
ineqdeco cpincome if wave == 1, bygroup(seq_hom)
*within 0.08434, between 0.03140
ineqdeco cpincome if wave == 7, bygroup(seq_hom)
*within 0.07649, between 0.02712
ineqdeco cf_cpincome if wave == 7, bygroup(seq_hom)
*within 0.07636, between 0.03087

*Figure 3
bysort seq6: sum husincome wifincome cpincome if wave ==1 & homogamy==3
bysort seq6: sum husincome wifincome cpincome if wave ==7 & homogamy==3


