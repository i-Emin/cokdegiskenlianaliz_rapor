/* Generated Code (IMPORT) */
/* Source File: student_health_data.xlsx */
/* Source Path: /home/u64113504/sasuser.v94 */
/* Code generated on: 6.01.2025 22:38 */

%web_drop_table(data);


FILENAME REFFILE '/home/u64407848/sasuser.v94/duzenli_data.xlsx';

PROC IMPORT DATAFILE=REFFILE
	DBMS=XLSX
	OUT=data;
	GETNAMES=YES;
RUN;

PROC CONTENTS DATA=data; RUN;


%web_open_table(data);

proc factor data=data 
 nobs=397 
 corr 
 method=principal 
 nfactors=3 
 maxiter=25 
 rotate=varimax reorder 
 msa 
 scree 
 preplot 
 plot 
 heywood; 

var Kan_Basinci_Sistolik Kan_Basinci_Diyastolik Nabiz Stress_Seviyesi_Bildirim Stress_Seviyesi_Biosensor; /* analizde yer alacak değişkenler */
run;

