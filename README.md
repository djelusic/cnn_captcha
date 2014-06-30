cnn_captcha
===========

Upute za pokretanje
-------------------

Prije pokretanja staviti sadržaje datoteke datasets.zip u radni direktorij i dodati radni
direktorij i direktorij segment u MATLAB path. 

**ogledni_primjer.m** - uzima prvih 2000+500 (zbog brzine) captchi iz skupa `captcha_xval_set` i 
trenira mrežu pa potom testira prepoznavanje captchi (pomoću `test_captcha.m`) od 5 
znakova i ispisuje rezultat. Za najbolji rezultat trenirati mrežu na čitavom skupu
`captcha_xval_set` (recimo pomoću `captcha_xval.m`) pa pokrenuti `test_captcha.m`

**captcha_xval.m** - vrši k-struku cross-validaciju (`k=5`) nad skupom `captcha_xval_set`
koji se sastoji od 5000 captchi duljine 5 sa defaultnom distorzijom i šumom. Prilikom
importiranja trening i testnih skupova se vrši segmentacija, čišćenje šuma i normalizacija.
Oznake skupa se nalaze u `captcha_xval_codes.txt`

**import_chars.m** - vrši k-struku cross-validaciju (`k=6`) nad skupom single_chars_trainset
koji se sastoji od 60000 znakova (generiranih istom skriptom kao i captche)
sa defaultnom distorzijom i šumom. Prilikom importiranja trening i testnih skupova 
se vrši normalizacija podataka. Oznake skupa se nalaze u `chars_codes.txt`

**test_captcha.m** - testira prepoznavanje cijelih captchi od 5 znakova. Potrebna je
varijabla opttheta koja se dobije treniranjem modela (npr. pomoću oglednog primjera ili 
`captcha_xval.m`)

Programska dokumentacija
------------------------

Za neuronsku mrežu korištena je nadopunjena verzija konvolucijske neuronske mreže
iz Stanfordovog UFLDL tutoriala. Ta je mreža prvenstveno bila namijenjena za
prepoznavanje rukom pisanih znamenki iz MNIST skupa podataka, no pokazalo se da uz
neke korekcije radi zadovoljavajuće za naše potrebe.

Glavni koraci samog algoritma su:
 
0. inicijalizacija parametara i pohranjivanje iz ručno generiranih podataka
1. implementacija računanja funkcije troška i gradijenta
2. učenje parametara (treniranje modela)
3. testiranje performansi modela i ispisivanje rezultata
 
 
Opišimo ukratko o čemu se radi u svakom koraku. Za 0. korak se brine funkcija `cnnInitParams`. 
Najbitnije je bilo inicijalizirati parametre kao što su `Wc`,`Wd`, `bc`,`bd` koji postavljaju inicijalne težine i 
inicijalne bias gradijente. 

Cijeli prvi korak se svodi na implementiranje funkcije `cnnCost` gdje 
dobivamo više rezultata. Dobijemo ukupno odstupanje od pravog rezultata, sve gradijente koji su nam 
potrebni za gradijentni spust te predviđanja modela (klasifikaciju). Glavni dio funkcije `cnnCost` 
se svodi na 4 dijela. 

U prvom dijelu se radi propagacija unaprijed kroz konvolucijski / pooling sloj. 
U njemu konvoluiramo svaku sliku i svaki filter, dodamo bias (`bc`) i primijenimo funkciju u ovisnosti o `activationType`-u.
Potom uzorkujemo konvoluirane aktivacije pomoću poolinga (bazično je riječ o matrici koja sadrži same jedinice - `meanPoolingFilter`). 
Rezultat konvolucije se spremi u `activations`, a rezultat dodatnog poolinga se pohrani u `activationsPooled`. Dobiveni podaci 
iz poolinga će se dalje propagirati do softmax regresijskog sloja, a rezultate spremimo u `probs`. 

U drugom dijelu se računa cost funkcija kojoj se dodaje `weightDecayCost` koji dodatno penalizira velike 
vrijednosti parametara. Računa se vrijednost varijable cost po ovom algoritmu. Također se vrati lista predikcija 
za svaki primjerak (ukoliko je `pred==True`). 

Nakon računanja cost-a slijedi backpropagation. U tom koraku se greška propagira unatrag redoslijedom : 
softmax sloj  konvolucijski/pooling. Greške se trebaju pohraniti za sljedeći korak da možemo izračunati 
gradijente. Propagacija unatrag u odnosu na softmax sloj se radi na klasičan način. Propagacija unatrag
kod pooling sloja se radi pomoću `kron` i `ones` funkcija (upsample greške za svaki filter i svaku sliku) 
i sve spremimo u `errorsPooling`.  

Konačno u zadnjem koraku propagacije greške unatrag popunjavamo `errorsConvolution` pomoću 
`errorsPooling` (sada koristimo activations koje smo spremili u propagaciji unaprijed). 
Posljednji korak se odnosi na računanje gradijenta. Koristimo izračunate greške tokom faze 
backpropagationa. U `Wd_grad` spremimo gradijent od softmax sloja (uz možebitno dodani `WEIGHT_DECAY`), 
a u bd_grad odgovarajući bias. Za dobiti gradijent konvolucijskog sloja, konvoluiramo greške 
iz backpropagationa za taj filter sa svakom slikom i iteriramo po svim slikama 
(spremimo težine u `Wc_grad`, a odgovarajuće biase u `bc_grad`). 

Sljedeći korak nam daje uvid u način učenja parametara. Tu je osnovna stvar `minFuncSGD`
funkcija i u njoj SGD petlja koja nam ubrzava i poboljšava samo izvršavanje koristeći stohastički 
gradijentni spust (napredna vrsta optimizacije koja bitno utječe na brzinu izvršavanja) 
umjesto postupnog računanja cost funkcije i pojedinih gradijenata. Također se koristi kaljenje inicijalnog 
koeficjenta učenja da se dobije bolja konvergencija k rješenju kao što se koristi i 
miješanje podataka tokom svake epohe (korisno za izbjegavanje lokalnih minimuma). 
Također se opcionalno može provjeravati greška nakon određenog broja epoha/iteracija i to 
grafički prikazivati. Za kraj ostaje još testirati rješenja (zadnje linije skripte `cnnTrain`).

U svakom od ovih koraka smo se susretali s raznim izazovima. Uzmimo, za početak, 0. korak. 
Tu je implementirana verzija koja stvara array nula, ali bi bolje radilo kada bi se tu generiralo 
niz malih vrijednosti oko 0 koje su, uz to, normalno distribuirane (dobijemo nešto malo bolji rezultat). 
Važnost ovakvog postupka je u tome da ako svi parametri krenu s istom vrijednosti, tada 
će svi skriveni slojevi završiti učeći istu funkciju inputa, tako da randomiziranje služi 
u svrhu razbijanja simetrije. 

Prvi korak ima nekoliko zanimljivih dodataka. Tu smo dodali 
npr. varijablu `USE_GPU` koja može služiti pri paralelizaciji koda (koja i inače prirodno 
odgovara neuronskoj mreži). To mogu iskoristiti računala s više CPU-ova i GPU-ova. Još jedan 
dodatak se odnosi na `USE_WEIGHT_DECAY` varijablu koja koristi pri smanivanju težina u svakoj iteraciji 
za neki maleni faktor (sprječava kompleksne aprokcimacije). 

Također je uvedena opcionalnost korištenja 2 aktivacijske funkcije, pa tako 
možemo birati sigmoidu ili ReLU funkciju. U našem slučaju 
se pokazalo kako ReLU funcija daje malo bolje rezultate (90.24% naspram 88.6% u korist ReLU), pa je ista 
i korištena. Sama ideja traženja minimuma počiva na metodi gdje se postupno približavamo minimumu uz 
pomoć našeg koeficjenta učenja  i verzije derivacije (koja ako je negativna gura pretragu “natrag”, 
dok u suprotnom smjeru gura pretragu “naprijed” prema minimumu). 


**Autori:**

Jure Šiljeg i Daniel Jelušić

