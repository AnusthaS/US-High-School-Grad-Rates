PROC IMPORT OUT= WORK.GRADUATION 
             DATAFILE= "\\tsclient\Anustha Shrestha\Documents\Baruch Coll
ege\Spring 2019\STA 9714 Experiental Design\Final Project\US Graduation 
RatesSAS.xlsx"  
            DBMS=EXCEL REPLACE;
     RANGE="GraduationRates$"; 
     GETNAMES=YES;
     MIXED=NO;
     SCANTEXT=YES;
     USEDATE=YES;
     SCANTIME=YES;
RUN;

PROC PRINT DATA = graduation;
run;

/*Question 1
ANOVA test to see if there are differences in the graduation rate between races*/
PROC ANOVA DATA = graduation;
class race;
model GradRate = race;
means race / tukey hovtest = levene;
RUN;

/*Failed Levene's test, so we use log transformation*/
DATA GraduationT;
Set Graduation;
logGrad = log (GradRate);
sqGrad = GradRate**2;
sqrtGrad = sqrt (GradRate);
expGrad = exp (GradRate);
RUN;

PROC ANOVA DATA = GraduationT;
class race;
model logGrad= race;
means race / tukey hovtest = levene;
RUN;

/*Question 2: Differences in graduation rates by race and by region*/
/*interaction effect*/
proc glm data = GraduationT;
class Region race;
model GradRate = region*race/ ss1 ss2 ss3 ss4;
run;

/*race as first main factor*/
proc glm data = GraduationT;
class region race;
model GradRate= race region race*region/ ss1 ss2 ss3 ss4;
run;
lsmeans race / pdiff = all adjust = tukey;
run;

ods graphics on;
proc glm data = GraduationT plot = meanplot (cl);
class race region;
model GradRate= race region race*region;
lsmeans race / pdiff = all adjust = tukey;
run;
ods graphics off;

/*region as first main factor*/
proc glm data = Graduation;
class region race;
model GradRate= region race race*region/ ss1 ss2 ss3 ss4;
run;
lsmeans region/ pdiff = all adjust = tukey;
run;

ods graphics on;
proc format;
value region
1 = 'Northeast'
2 = 'Midwest'
3 = 'South'
4 = 'West'
;
proc glm data = Graduation plot = meanplot (cl);
class region race;
model GradRate= region race race*region;
lsmeans region / pdiff = all adjust = tukey;
run;
ods graphics off;



/*QUESTION 3*/
/*Do Average Systolic BP depend on body weight and sex?*/

proc glm data=NHANEStrans plot = meanplot (cl);
class sex;
model SYSBP = sex weight sex*weight / solution;
lsmeans sex weight sex*weight / stderr pdiff cov out = adjmeans;
run;
proc print data = adjmeans;
run;

/*Interaction term was not significant, so run the model using main treatement and covariate*/
PROC GLM data = NHANEStrans;
model SYSBP = sex weight / solution ;
lsmeans sex weight / stderr pdiff cov out = adjmeans; 
RUN;
proc print data = adjmeans;
RUN;


