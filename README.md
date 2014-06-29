cnn_captcha
===========

Prije pokretanja staviti sadržaje datoteke datasets.zip u radni direktorij.

**captcha_xval.m** - vrši k-struku cross-validaciju (k=5) nad skupom captcha_xval_set
koji se sastoji od 5000 captchi duljine 5 sa defaultnom distorzijom i šumom. Prilikom
importiranja trening i testnih skupova se vrši segmentacija, čišćenje šuma i normalizacija.
Oznake skupa se nalaze u captcha_xval_codes.txt

**importC74k.m** - importira font dataset iz baze C74k. Slike se resizaju na 50x50
i normaliziraju.

**import_chars.m** - vrši k-struku cross-validaciju (k=6) nad skupom single_chars_trainset
koji se sastoji od 60000 znakova (generiranih istom skriptom kao i captche)
sa defaultnom distorzijom i šumom. Prilikom importiranja trening i testnih skupova 
se vrši normalizacija podataka. Oznake skupa se nalaze u chars_codes.txt

**test_captcha.m** - testira prepoznavanje cijelih captchi od 5 znakova. Potrebna je
varijabla opttheta koja se dobije treniranjem modela (npr. pomoću captcha_xval.m)