/* =============================================================================
                     
					  Encuesta Especializada de Trabajo 
				      Adolescente e Infantil (ETI)2015
					  
							Descriptive Analysis
					 
					     	     Brian Daza
                         https://briandaza.github.io/
				   					
============================================================================= */


* Let's prepare the environment:

clear all
global dir "C:\Users\\`c(username)'\OneDrive\ETI 2015"
global dataprocesada "$dir\Data Procesada"
cd "$dir\Data"

* Descriptive Analysis
* --------------------

use "ETI 2015.dta", clear

* Defining global macros to set survey design according the level of analysis:

* For individuals:
global svyind svyset qhconglomerado [pweight = factorexp_1], strata(estrato) || qhvivienda

* For children:
global svyni svyset qhconglomerado [pweight = factorexp_niÑos], strata(estrato) || qhvivienda
 
* Defining groups of control variables:

global xs qh313 edfam anioedu qc_sexo qhcul_tpm qhcul_tom
global xs2  qh313 edfam anioedu qc_sexo qhcul_tpm qhcul_tpm2 qhcul_tom
global xsfe qh313 edfam anioedu qc_sexo qhcul_tpm qhcul_tom i.provincia
global xs2fe  qh313 edfam anioedu qc_sexo qhcul_tpm qhcul_tpm2 qhcul_tom i.provincia

* Empirical Analysis
* ---------------------------------

$svyni // Survey design for children

* Linear
svy: reg htt $xs if n5a17==1
estimates store htt1

svy: reg htd $xs if n5a17==1
estimates store htd1

svy: reg  at $xs if n5a17==1
estimates store at1

* Quadratic
svy: reg htt $xs2 if n5a17==1
estimates store htt2

svy: reg htd $xs2 if n5a17==1
estimates store htd2

svy: reg  at $xs2 if n5a17==1
estimates store at2

* With fixed effects:
* -----------------
* Linear
svy: reg htt $xsfe if n5a17==1
estimates store htt1fe

svy: reg htd $xsfe if n5a17==1
estimates store htd1fe

svy: reg  at $xsfe if n5a17==1
estimates store at1fe

* Quadratic
svy: reg htt $xs2fe if n5a17==1
estimates store htt2fe

svy: reg htd $xs2fe if n5a17==1
estimates store htd2fe

svy: reg  at $xs2fe if n5a17==1
estimates store at2fe


* Summary of results

esttab htt1 htt2 htt1fe htt2fe, b(%6.5f) ///
se(%4.3f) keep($xs2) star(* 0.10 ** 0.05 *** 0.01) ///
label title("Hours of market child labor") 

esttab htd1 htd2 htd1fe htd2fe, b(%6.5f) ///
se(%4.3f) keep($xs2) star(* 0.10 ** 0.05 *** 0.01) ///
label title("Hours of domestic child labor") 

esttab at1 at2 at1fe at2fe, b(%6.5f) ///
se(%4.3f) keep($xs2) star(* 0.10 ** 0.05 *** 0.01) ///
label title("Total hours of child labor") 

* Exporting results

esttab htt1 htt2 htt1fe htt2fe using "uno.rtf", replace b(%6.5f) ///
se(%6.5f) keep($xs2) star(* 0.10 ** 0.05 *** 0.01) ///
label title("Table 1: Hours of market child labor") 

esttab htd1 htd2 htd1fe htd2fe using "dos.rtf", replace  b(%6.5f) ///
se(%6.5f) keep($xs2) star(* 0.10 ** 0.05 *** 0.01) ///
label title("Table 2: Hours of domestic child labor") 

esttab at1 at2 at1fe at2fe using "tres.rtf", replace  b(%6.5f) ///
se(%6.5f) keep($xs2) star(* 0.10 ** 0.05 *** 0.01) ///
label title("Table 3: Total hours of child labor") 


* There is still needed more data cleaning: 
sum htt htd qh313 edfam anioedu qc_sexo qhcul_tpm qhcul_tom qhcul_tpm2

