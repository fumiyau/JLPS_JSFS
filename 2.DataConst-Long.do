drop if marstat ~= 1
drop if numchild ==. & wave == 1
drop if numchild ==. & wave == 7
recode numberoffamily 99=.
drop if numberoffamily == .
/*Educaitonal assortative mating*/
recode spedu  (1/2=1)(3=2)(4=3)(5/6=4)
gen husedu = redu 
replace husedu = spedu if sex == 2
gen wifedu = redu 
replace wifedu = spedu if sex == 1
drop if husedu ==.
drop if wifedu ==.
gen husedu3 = husedu
recode husedu3 (3=2) (4=3)
gen wifedu3 = wifedu
recode wifedu3 (3=2) (4=3)
*Create spouse paring patterns
gen homogamy = 0
recode homogamy 0 = 1 if husedu3 == 1 & wifedu3 == 1
recode homogamy 0 = 2 if husedu3 == 2 & wifedu3 == 2
recode homogamy 0 = 3 if husedu3 == 3 & wifedu3 == 3
recode homogamy 0 = 4 if husedu3 > wifedu3
recode homogamy 0 = 5 if husedu3 < wifedu3
label define  homogamyl 1 "低学歴同類婚" 2 "中学歴同類婚" 3 "高学歴同類婚" 4 "妻上昇婚" 5 "妻下降婚" 
label values homogamy homogamyl
recode homogamy 2=1 3=1 4=2 5=3,gen(xhom)
label define  hom3l 1 "同類婚" 2 "妻上昇婚" 3 "妻下降婚" 
label values xhom hom3l
*Generate spouse birth year
gen spbirth=.
replace spbirth=1900+zq52y if zq52a==1 & wave == 1
replace spbirth=1925+zq52y if zq52a==2 & wave == 1
by id: generate spbirth_w1 = sum(spbirth)

*generate age variables
gen age = .
replace age = 2007 + wave - 1 - ybirth if mbirth <= 3 & mbirth >= 1
replace age = 2007 + wave - 2 - ybirth if mbirth <= 12 & mbirth >= 4

gen spage =. 
replace spage = 2007 + wave - 2 - spbirth_w1 
replace spage = . if spage >= 2006

gen husage = age 
replace husage = spage if sex == 2
gen wifage = age 
replace wifage = spage if sex == 1

/*従業上の地位_1"正規雇用"2"非正規雇用"3"自営、家族従業"4"内職/無職"5"学生"*/
/*自営、家族従業、内職、学生、無職は除外*/
/*recode type (1/2=1)(3/5=2)(6/7=3)(8=4)(9=.)(10=4)(11/12=5)(99=.)*/
recode sptype (1/2=1)(3=2) (4/6=3)(7=4)(8=5)(9=.)(10=4)(88/99=.)

gen hustype = type
replace hustype = sptype if sex == 2  
gen wiftype = type 
replace wiftype = sptype if sex == 1

drop if type == .
drop if sptype == .
drop if wiftype == 5
drop if hustype == 5

/*本人、配偶者、世帯収入*/
gen rpincomes = income
recode rpincomes (1=0)(2=12.5)(3=50)(4=112.5)(5=200)(6=300)(7=400)(8=525)(9=725)(10=1050)(11=1500)(12=2000)(13=2500)(14=.)(99=.)
gen spincomes = sincome
recode spincomes (1=0)(2=12.5)(3=50)(4=112.5)(5=200)(6=300)(7=400)(8=525)(9=725)(10=1050)(11=1500)(12=2000)(13=2500)(14=.)(15=.)(88=.)(99=.)
gen houseincomes = hincome
recode houseincomes (1=0)(2=12.5)(3=50)(4=112.5)(5=200)(6=300)(7=400)(8=525)(9=725)(10=1050)(11=1500)(12=2000)(13=2500)(14=.)
gen houseincomess = houseincomes*10000

gen rpincomess = rpincomes*10000
gen spincomess = spincomes*10000
gen rpincomesln = ln(rpincomes)

gen husincome = rpincomess 
replace husincome = spincomess if sex == 2

gen wifincome = rpincomess 
replace wifincome = spincomess if sex == 1

gen cpincome = husincome + wifincome
gen raincome = wifincome / cpincome
drop if husincome == . | wifincome == .

*Keep non-missing cases
egen n_obs=count(id),by(id)
keep if n_obs==7

*Job sequence
gen jobflag = .
recode jobflag . = 1 if wiftype  <= 3
/*正規*/
gen jobflag_regular = .
recode jobflag_regular . = 1 if wiftype == 1
/*非正規*/
gen jobflag_noregular = .
recode jobflag_noregular . = 1 if wiftype == 2

egen j_obs=count(jobflag),by(id)
egen j_obsr=count(jobflag_regular),by(id)
egen j_obsn=count(jobflag_noregular),by(id)

gen flag1 = 0
replace flag1 = 1 if wiftype ~= 4 & wave == 1
gen flag2 = 0
replace flag2 = 1 if wiftype ~= 4 & wave == 2
gen flag3 = 0
replace flag3 = 1 if wiftype ~= 4 & wave == 3
gen flag4 = 0
replace flag4 = 1 if wiftype ~= 4 & wave == 4
gen flag5 = 0
replace flag5 = 1 if wiftype ~= 4 & wave == 5
gen flag6 = 0
replace flag6 = 1 if wiftype ~= 4 & wave == 6
gen flag7 = 0
replace flag7 = 1 if wiftype ~= 4 & wave == 6

by id: generate wiftype1 = sum(flag1)
by id: generate wiftype2 = sum(flag2)
by id: generate wiftype3 = sum(flag3)
by id: generate wiftype4 = sum(flag4)
by id: generate wiftype5 = sum(flag5)
by id: generate wiftype6 = sum(flag6)
by id: generate wiftype7 = sum(flag7)

gen seq = 0 
recode seq 0 = 1 if j_obsr == 7 & wiftype == 1 & wave == 7
recode seq 0 = 2 if j_obsn == 7 & wiftype == 2 & wave == 7
recode seq 0 = 3 if j_obs == 0 & wiftype == 4 & wave == 7
recode seq 0 = 4 if wiftype1 == 0 & wiftype2 == 1 & wiftype3 == 1 & wiftype4 == 1 & wiftype5 == 1 & wiftype6 == 1 & wiftype7 == 1 & wave == 7
recode seq 0 = 4 if wiftype1 == 0 & wiftype2 == 0 & wiftype3 == 1 & wiftype4 == 1 & wiftype5 == 1 & wiftype6 == 1 & wiftype7 == 1  & wave == 7
recode seq 0 = 4 if wiftype1 == 0 & wiftype2 == 0 & wiftype3 == 0 & wiftype4 == 1 & wiftype5 == 1 & wiftype6 == 1 & wiftype7 == 1  & wave == 7
recode seq 0 = 4 if wiftype1 == 0 & wiftype2 == 0 & wiftype3 == 0 & wiftype4 == 0 & wiftype5 == 1 & wiftype6 == 1 & wiftype7 == 1  & wave == 7
recode seq 0 = 4 if wiftype1 == 0 & wiftype2 == 0 & wiftype3 == 0 & wiftype4 == 0 & wiftype5 == 0 & wiftype6 == 1 & wiftype7 == 1  & wave == 7
recode seq 0 = 4 if wiftype1 == 0 & wiftype2 == 0 & wiftype3 == 0 & wiftype4 == 0 & wiftype5 == 0 & wiftype6 == 0 & wiftype7 == 1  & wave == 7
recode seq 0 = 5 if wiftype1 == 1 & wiftype2 == 1 & wiftype3 == 1 & wiftype4 == 1 & wiftype5 == 1 & wiftype6 == 1 & wiftype7 == 0  & wave == 7
recode seq 0 = 5 if wiftype1 == 1 & wiftype2 == 1 & wiftype3 == 1 & wiftype4 == 1 & wiftype5 == 1 & wiftype6 == 0 & wiftype7 == 0  & wave == 7
recode seq 0 = 5 if wiftype1 == 1 & wiftype2 == 1 & wiftype3 == 1 & wiftype4 == 1 & wiftype5 == 0 & wiftype6 == 0 & wiftype7 == 0  & wave == 7
recode seq 0 = 5 if wiftype1 == 1 & wiftype2 == 1 & wiftype3 == 1 & wiftype4 == 0 & wiftype5 == 0 & wiftype6 == 0 & wiftype7 == 0  & wave == 7
recode seq 0 = 5 if wiftype1 == 1 & wiftype2 == 1 & wiftype3 == 0 & wiftype4 == 0 & wiftype5 == 0 & wiftype6 == 0 & wiftype7 == 0  & wave == 7
recode seq 0 = 5 if wiftype1 == 1 & wiftype2 == 0 & wiftype3 == 0 & wiftype4 == 0 & wiftype5 == 0 & wiftype6 == 0 & wiftype7 == 0  & wave == 7
recode seq 0 = 6 if wave == 7

by id: egen maxseq = max(seq)
replace seq = maxseq if wave ==1

by id: egen seq6 = sum(maxseq)
recode seq6 7=1 14=2 21=3 28=4 35=5 42=6 
label define seq6l 1 "正規継続" 2 "非正規継続" 3 "無職継続" 4"途中参入" 5"途中退出" 6"その他"
label values seq6 seq6l

*30 patterns for Theil analysis
gen seq_hom = 0
recode seq_hom 0 = 1 if seq6 == 1 & hom == 1
recode seq_hom 0 = 2 if seq6 == 1 & hom == 2
recode seq_hom 0 = 3 if seq6 == 1 & hom == 3
recode seq_hom 0 = 4 if seq6 == 1 & hom == 4
recode seq_hom 0 = 5 if seq6 == 1 & hom == 5
recode seq_hom 0 = 6 if seq6 == 2 & hom == 1
recode seq_hom 0 = 7 if seq6 == 2 & hom == 2
recode seq_hom 0 = 8 if seq6 == 2 & hom == 3
recode seq_hom 0 = 9 if seq6 == 2 & hom == 4
recode seq_hom 0 = 10 if seq6 == 2 & hom == 5
recode seq_hom 0 = 11 if seq6 == 3 & hom == 1
recode seq_hom 0 = 12 if seq6 == 3 & hom == 2
recode seq_hom 0 = 13 if seq6 == 3 & hom == 3
recode seq_hom 0 = 14 if seq6 == 3 & hom == 4
recode seq_hom 0 = 15 if seq6 == 3 & hom == 5
recode seq_hom 0 = 16 if seq6 == 4 & hom == 1
recode seq_hom 0 = 17 if seq6 == 4 & hom == 2
recode seq_hom 0 = 18 if seq6 == 4 & hom == 3
recode seq_hom 0 = 19 if seq6 == 4 & hom == 4
recode seq_hom 0 = 20 if seq6 == 4 & hom == 5
recode seq_hom 0 = 21 if seq6 == 5 & hom == 1
recode seq_hom 0 = 22 if seq6 == 5 & hom == 2
recode seq_hom 0 = 23 if seq6 == 5 & hom == 3
recode seq_hom 0 = 24 if seq6 == 5 & hom == 4
recode seq_hom 0 = 25 if seq6 == 5 & hom == 5
recode seq_hom 0 = 26 if seq6 == 6 & hom == 1
recode seq_hom 0 = 27 if seq6 == 6 & hom == 2
recode seq_hom 0 = 28 if seq6 == 6 & hom == 3
recode seq_hom 0 = 29 if seq6 == 6 & hom == 4
recode seq_hom 0 = 30 if seq6 == 6 & hom == 5

*Income variables
gen husincome_year1 = husincome if wave == 1
by id: generate cf_husincome = sum(husincome_year1)
gen cf_cpincome = cf_husincome + wifincome
gen cf_raincome = wifincome / cf_cpincome
gen sq_husincome = husincome/sqrt(numberoffamily)
gen sq_wifincome = wifincome/sqrt(numberoffamily)
gen sq_cpincome = cpincome/sqrt(numberoffamily)
gen sq_cf_husincome = cf_husincome/sqrt(numberoffamily)
gen sq_cf_cpincome = cf_cpincome/sqrt(numberoffamily)
