*access data;
libname cup "/home/u58481968/CurisityCup2024";
option validvarname=v7;

*import data;
proc import datafile="/home/u58481968/CurisityCup2024/FINAL_MENTAL_HEALTH.xls" 
		out=CUP.FINAL_MENTAL_HEALTH dbms=xls replace;
run;

proc print data=cup.maternal_mental (obs=500);
	*prepare data;
	*1 remove unuseless columns;
	ods pdf file="/home/u62098731/c/maternal_mental_health.pdf";
run;


data  CUP.FINAL_MENTAL_HEALTH;
	set CUP.MENTAL_HEALTH;
	
	drop  EPDS_1 EPDS_2 EPDS_3 EPDS_4 EPDS_5 EPDS_6 EPDS_7 EPDS_8 EPDS_9 EPDS_10 HADS_1 HADS_3 HADS_5 HADS_7 HADS_9
         HADS_11 HADS_13  Age_bb Marital_status_edit Education Type_pregnancy sex_baby1
         how_falling_asleep_bb1 CBTS_M_3 CBTS_M_4 CBTS_M_5 CBTS_M_6 CBTS_M_7 CBTS_M_8 CBTS_M_9 CBTS_M_10
         CBTS_M_11 CBTS_M_12 CBTS_13 CBTS_14 CBTS_15 CBTS_16 CBTS_17 CBTS_18 CBTS_19 CBTS_20 CBTS_21 CBTS_22
         IBQ_R_VSF_3_bb1 IBQ_R_VSF_4_bb1 IBQ_R_VSF_9_bb1 IBQ_R_VSF_10_bb1 IBQ_R_VSF_16_bb1
		 IBQ_R_VSF_17_bb1 IBQ_R_VSF_28_bb1 IBQ_R_VSF_29_bb1 IBQ_R_VSF_32_bb1 IBQ_R_VSF_33_bb1
		 EPDS_1 EPDS_2 EPDS_3 EPDS_4 EPDS_5 EPDS_6 EPDS_7 EPDS_8 EPDS_9 EPDS_10 HADS_1 HADS_3 HADS_5
		 HADS_7 HADS_9 HADS_11 HADS_13 Sleep_night_duration_bb1 night_awakening_number_bb1 Marital_status_Autre;
        
        *edit the length of the new columns ;
    length Marital_status $100 Education_level $100 pregnancy_type $100 sex_baby $100 
    baby_age $100 how_falling_asleep $200 ;
    
    	*calculate the night duration from time format to numeric ;
    format Sleep_night_duration_bb1 BEST12.;
     Sleep_night_duration=(Sleep_night_duration_bb1/3600);
     
     *remove the outliers; 
     if Sleep_night_duration>=25 then delete;
     
     		*convert the gestational age from weeks to years to unified the factor of the ages ;
     Gestationnal_age=Gestationnal_age/52;
     format Gestationnal_age comma10.2;
     
     	*label the column ;
     night_awakening_number=night_awakening_number_bb1;
 
	*2 handle Marital_status_edit column;
	if Marital_status_Autre="Pacse" then
		Marital_status_edit="2";
		
	*3 create new column EPDS_score;
	EPDS_score=sum(of EPDS_1 - EPDS_10);
	
	*4 create new column EPDS_info;
	if EPDS_score>10 then
		EPDS_info="minor or major depression";
	else
		EPDS_info="normal";
	
	*5 create new column HADS_score;
	HADS_score=sum(of HADS_1 HADS_3 HADS_5 HADS_7 HADS_9 HADS_11 HADS_13);
	
	*6 create new column HADS_info;
	if HADS_score  >=0 and HADS_score<=7 then
		HADS_info="normal";
	else if HADS_score >=8 and HADS_score<=10 then
		HADS_info="Borderline abnormal";
	else if HADS_score >=11 and HADS_score<=21 then
		HADS_info="Abnormal";
		
	*handel the CBTS SCORE devide it by 2 to make normalizaion of the values;
	CBTS_score=sum(of CBTS_M_3 CBTS_M_4 CBTS_M_5 CBTS_M_6 CBTS_M_7 CBTS_M_8 CBTS_M_9 CBTS_M_10 CBTS_M_11 CBTS_M_12 CBTS_13
					CBTS_14 CBTS_15 CBTS_16 CBTS_17 CBTS_18 CBTS_19 CBTS_20 CBTS_21 CBTS_22)/2;
	
	*assume the CBTS Score information based on the previous assumptions ;
	if CBTS_score>=15 then CBTS_info='Abnormal';
	else CBTS_info='normal';
	
	*handel the IBQ_R_VSF SCORE;
	IBQ_R_VSF_score=sum(of IBQ_R_VSF_3_bb1 IBQ_R_VSF_4_bb1 IBQ_R_VSF_9_bb1 IBQ_R_VSF_10_bb1 IBQ_R_VSF_16_bb1
					IBQ_R_VSF_17_bb1 IBQ_R_VSF_28_bb1 IBQ_R_VSF_29_bb1 IBQ_R_VSF_32_bb1 IBQ_R_VSF_33_bb1);	
	
	*assume the CBTS Score information based on the previous assumptions ;
	if IBQ_R_VSF_score>=50 then IBQ_R_VSF_info='Abnormal';
	else IBQ_R_VSF_info='normal';
	
	*edit the marital status column;
	if Marital_status_edit=1 then
		Marital_status='single';
	else if Marital_status_edit=2 then
		Marital_status='in a relationship';
	else if Marital_status_edit=3 then
		Marital_status='separated, divorced or widow';

	*edit the education column;
	if Education=1 then
		Education_level='no education';
	else if Education=2 then
		Education_level='compulsory school';
	else if Education=3 then
		Education_level='post-compulsory education';
	else if Education=4 then
		Education_level='university of Applied Science or University Technology Degree';
	else if Education=5 then
		Education_level='no education and compulsory school';

	*edit the pregnancy type column;
	if Type_pregnancy=1 then
		pregnancy_type='single pregnance';
	else if Type_pregnancy=2 then
		pregnancy_type='twin pregnancy';
	
	*edit the sex of the baby column; 
	if sex_baby1=1 then
		sex_baby='girl';
	else if sex_baby1=2 then
		sex_baby='boy';

	*edit the age of the baby column;
	if Age_bb=1 then
		baby_age='3 to 5 months';
	else if Age_bb=2 then
		baby_age='6 to 8 months';
	else if Age_bb=3 then 
		baby_age='9 to 12 months';

	*edit the how faling asleep column;
	if how_falling_asleep_bb1=1 then
		how_falling_asleep='while being fed';
	else if how_falling_asleep_bb1=2 then
		how_falling_asleep='while being rocked';
	else if how_falling_asleep_bb1=3 then
		how_falling_asleep='while being held';
	else if how_falling_asleep_bb1=4 then
		how_falling_asleep='alone in the crib';
	else if how_falling_asleep_bb1=5 then
		how_falling_asleep='in the crib with parental presence';
run;

*statistics and information about data;

proc contents data=cup.maternal_mental_cleaned;
run;

proc means data=cup.maternal_mental_cleaned;
run;

*export statistics and information into pdf file;
ods pdf close;
*export data into csv and excel files;

proc export data=cup.maternal_mental_cleaned dbms=csv 
		outfile="/home/u62098731/c/maternal_mental_health";
run;

proc export data=CUP.FINAL_MENTAL_HEALTH dbms=xls 
		outfile="/home/u58481968/CurisityCup2024/FINAL_MENTAL_HEALTH.xls" replace;
run;