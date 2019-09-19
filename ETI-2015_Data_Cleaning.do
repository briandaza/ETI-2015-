/* =============================================================================
                     
					  Encuesta Especializada de Trabajo 
				      Adolescente e Infantil (ETI)2015
					  
								Data Cleaning
					 
					     	      Brian Daza
                         https://briandaza.github.io/
				   					
============================================================================= */


* Let's prepare the environment:

clear all
global dir "C:\Users\\`c(username)'\OneDrive\ETI 2015"
global dataprocesada "$dir\Data Procesada"
cd "$dir\Data"

* Raw data needs translation:
unicode analyze "eti_2015_hogar_vivienda.dta"
unicode analyze "eti_2015_miembros_del_hogar.dta"
unicode analyze "eti_2015_ninos_5_a_17anios.dta"

* So, we codify them:
unicode encoding set "ISO-8859-1"
unicode translate "eti_2015_hogar_vivienda.dta"
unicode translate "eti_2015_miembros_del_hogar.dta"
unicode translate "eti_2015_ninos_5_a_17anios.dta"

* Let's explore the data

* Living place / household module:

use "eti_2015_hogar_vivienda.dta", clear

isid qhconglomerado qhvivienda qhhogar

tab qhresultado

* Household members module:

use "eti_2015_miembros_del_hogar.dta", clear

isid qhconglomerado qhvivienda qhhogar qhorden

tab qhresultado

tab qh110 // 6,240 in the objective population

* 5-17 y.o. Children Module.

use "eti_2015_ninos_5_a_17anios.dta", clear

isid qhconglomerado qhvivienda qhhogar qhorden

count // 6,240 as previously noted.

* Datasets integration
* ------------------------------

* 5-17 y.o. Children Module:

use "eti_2015_ninos_5_a_17anios.dta"

merge 1:1 qhconglomerado qhvivienda qhhogar qhorden using "eti_2015_miembros_del_hogar.dta"

* Identify objective population using "_merge"

rename _merge n5a17

label variable n5a17 "Tiene entre 5 y 17 años"
replace n5a17=1 if n5a17==3
replace n5a17=0 if n5a17==2
label define n5a17 1 "Sí" 0 "No"
label values n5a17 n5a17

* Verifying with the original indicator:

tab qh110 n5a17

* Merging with household data

merge m:1 qhconglomerado qhvivienda qhhogar using "eti_2015_hogar_vivienda.dta"

drop _merge

* Schooling years:
* - - - - - - - - -
* Generamos un indicador de años aprobados: (does not apply to people who went school prior 1969)

* Last level completed:
* tab qh205_n, nolabel
* The survey does not count initial level (kindergarden).
* "grados" corresponds to years in primary school, "años" for other educational levels. (Peruvian denominations) 

gen anioedu=.
* None
replace anioedu=0 if qh205_n==1 | qh205_n==99 
* Primary school
replace anioedu=1 if qh205_g==1 & qh205_n==2
replace anioedu=2 if qh205_g==2 & qh205_n==2
replace anioedu=3 if qh205_g==3 & qh205_n==2
replace anioedu=4 if qh205_g==4 & qh205_n==2
replace anioedu=5 if qh205_g==5 & qh205_n==2
replace anioedu=6 if qh205_g==3
* Secondary school
replace anioedu=7 if qh205_a==1 & qh205_n==4
replace anioedu=8 if qh205_a==2 & qh205_n==4
replace anioedu=9 if qh205_a==3 & qh205_n==4
replace anioedu=10 if qh205_a==4 & qh205_n==4
replace anioedu=11 if qh205_n==5
* Superior level of any type
replace anioedu=12 if qh205_a==1 & inlist(qh205_n,6,7,8,9)
replace anioedu=13 if qh205_a==2 & inlist(qh205_n,6,7,8,9)
replace anioedu=14 if qh205_a==3 & inlist(qh205_n,6,7,8,9)
replace anioedu=15 if qh205_a==4 & inlist(qh205_n,6,7,8,9)
replace anioedu=16 if qh205_a==5 & inlist(qh205_n,6,7,8,9)
* Graduate studies or undergraduate studies with programs longer than 5 years
replace anioedu=19 if (qh205_a>6 & inlist(qh205_n,6,7,8,9)) | inlist(qh205_n,10)

* Farm land:

* Cultivable:
* Una hectárea será equivalente a 10000 metros cuadrados, por lo tanto, haremos la
* transformación de la variable en metros.

* Farmable land:
* Own
gen qhcul_tpm = qhcul_ph*1000 + qhcul_pm  // tpm: Total propio en metros
* ^2
gen qhcul_tpm2=qhcul_tpm^2
* Other
gen qhcul_tom = qhcul_oh*1000 + qhcul_om 

* Non farmable land:
* Own
gen qhnocul_tpm = qhnocul_ph*1000 + qhnocul_pm 
* Other
gen qhnocul_tom = qhnocul_oh*1000 + qhnocul_om 

* Hours of market child labor:

egen htt= rowtotal(qh310h qh312_h)
replace  htt=. if  qh310h==. &  qh312_h==.

* Hours of domestic child labora:
egen htd=rowtotal(qd301c_h qd302c_h)
replace  htd=. if  qd301c_h==. &  qd302c_h==.

* Total hours of child labor
egen at=rowtotal(htt htd)
replace  at=. if  htt==. &  htd==.

* Años de educación de la familia:
egen edfam=mean(anioedu), by(qhconglomerado qhvivienda qhhogar) 

* Generating a province variable as factor:
encode qhprovincia, generate(provincia)

save "ETI 2015.dta", replace

