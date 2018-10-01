use "/Users/fumiyau/Desktop/SecondaryData/0417/data/pm7.dta", clear
append using "/Users/fumiyau/Desktop/SecondaryData/0417/data/py7.dta"
** Handling on wide data *********************************************************************************
varcase _all
varcase YBIRTH MBIRTH AQ11_21A AQ11_21B AQ11_21C AQ11_21D AQ11_21E AQ11_22A AQ11_22B AQ11_22C AQ11_22D AQ11_22E AQ11_23A AQ11_23B AQ11_23C AQ11_23D AQ11_23E AQ11_24A AQ11_24B AQ11_24C AQ11_24D AQ11_24E AQ11_25A AQ11_25B AQ11_25C AQ11_25D AQ11_25E AQ11_26A AQ11_26B AQ11_26C AQ11_26D AQ11_26E AQ11_27A AQ11_27B AQ11_27C AQ11_27D AQ11_27E AQ11_28A AQ11_28B AQ11_28C AQ11_28D AQ11_28E
varcase DQ10_22Z DQ10_23Z DQ10_24Z DQ10_25Z EQ12_NUM EQ12_OTH EQ12_FAM EQ12_CHD DQ10_26Z DQ10_27Z DQ10_28Z DQ10_29Z DQ10_210Z CQ17BZ CQ17BB CQ17BC CQ17CZ CQ17CB CQ17CC CQ17DZ CQ17DB CQ17DC CQ17EZ CQ17EB CQ17EC CQ17FZ CQ17FB CQ17FC CQ17GZ CQ17GB CQ17GC CQ17HZ CQ17HB CQ17HC CQ17IZ CQ17IB CQ17IC
rename pANELid id
rename SEX sex

/******働き方******/
/*1"経営者、役員"2"正社員"3"パート、契約、臨時、嘱託"4"派遣"5"請負"6"自営"7"家族従業"8"内職"10"無職（学生除）"11"学生（働いていない）"12"学生（現在非正規で働いている）"*/
/*recode 1"正規雇用"2"非正規雇用"3"自営、家族従業"4"内職/無職"5"学生"*/
/******本人******/
rename jc_1 type1
rename aq03_1 type2
rename bq03_1 type3
rename cq03_1 type4
rename dq03_1 type5
rename eq03_1 type6
rename fq03_1 type7
recode type* (1/2=1)(3/5=2)(6/7=3)(8=4)(9=.)(10=4)(11/12=5)(99=.)
/******配偶者******/
rename zq55_1 sptype1
rename aq55_1 sptype2
rename bq44_1 sptype3
rename cq46_2 sptype4
rename dq44_1 sptype5
rename eq42_1 sptype6
rename fq45_1 sptype7

/****** 本人学歴 ******/
/*w1時点で最後に通った学校が学歴となる*/
/*元のコード：zq23a 1"中学"2"高校"3"専門"4"短大高専"5"大学"6"大学院"*/
/*1"中学高校"2"専門3"短大高専"4"大学・大学院"."欠損値"*/
gen redu = zq23a
recode redu (1/2=1)(3=2)(4=3)(5/6=4)(7=.)(9=.)

/****** generate marriage status ******/
* 1"未婚"2"既婚"3"死別"4"離別"（w1）
* 1"既婚"2"未婚"3"死別"4"離別"（w2-6）
* w1をw2-6に合わせるかたちで修正
rename zq50 marstat1
recode marstat1 (1=2)(2=1)(3=3)(4=4)
rename aq52 marstat2
rename bq42 marstat3
rename cq45 marstat4
rename dq43 marstat5
rename eq41 marstat6
rename fq44 marstat7

/****** w4配偶者学歴 ******/
rename zq23b spedu1 
recode spedu1 7=. 8=. 9=.
rename cq46_1 spedu4
recode spedu4 7=. 8=.
gen spedu5 = dq48_2 
replace spedu5 = spedu4 if marstat4==1 & marstat5==1 & (spedu5==8 | spedu5==9)
gen spedu6 = eq47
replace spedu6 = spedu5 if marstat5==1 & marstat6==1 & (spedu6==8 | spedu6==9)
gen spedu7 = fq50
replace spedu7 = spedu6 if marstat6==1 & marstat7==1 & (spedu7==8 | spedu7==9)

/*w2w3の学歴を埋める*/
gen spedu2 =spedu1 if marstat1 == 1 & marstat2 ==1
replace spedu2 =. if marstat2 == 2 | marstat2 == 3 | marstat2 == 4
replace spedu2 = spedu4 if (marstat1 == 2 | marstat1 == 3 | marstat1 == 4) & marstat2 == 1 & marstat4 == 1

gen spedu3 =spedu1  if marstat1 == 1 & marstat3 ==1
replace spedu3 =. if marstat3 == 2 | marstat3 == 3 | marstat3 == 4
replace spedu3 = spedu4 if (marstat1 == 2 | marstat1 == 3 | marstat1 == 4) & marstat3 == 1 & marstat4 == 1

forvalues i=1/7{
recode spedu`i' 7=. 8=. 9=. 99=.
}
/******年収******/
/*個人年収*/
rename zq47a income1
rename aq48a income2
rename bq36a income3
rename cq37a income4
rename dq35a income5
rename eq34a income6
rename fq38a income7
/*配偶者年収*/
rename zq47b sincome1
rename aq48b sincome2
rename bq36b sincome3
rename cq37b sincome4
rename dq35b sincome5
rename eq34b sincome6
rename fq38b sincome7
/*世帯年収*/
rename zq47c hincome1
rename aq48c hincome2
rename bq36c hincome3
rename cq37c hincome4
rename dq35c hincome5
rename eq34c hincome6
rename fq38c hincome7

*世帯人員
rename zq13_1 numberoffamily1
rename aq11_1 numberoffamily2
rename bq13_1 numberoffamily3
rename cq17_1 numberoffamily4
rename dq10_1 numberoffamily5
rename eq12_1 numberoffamily6
rename fq10_1 numberoffamily7

*子ども数
/*wave1における子ども人数*/
recode zq14_31 (88=0)(99=.),gen(numchild1)
/*wave6-7における子ども人数*/
recode eq11s (8=0)(9=.)(88=0)(99=.),gen(numchild6)
recode fq09s (8=0)(9=.)(88=0)(99=.),gen(numchild7)

reshape long type marstat spedu income sincome hincome ychild sptype numchild numberoffamily, i(id) j(wave)




