father('Ганс','Марго').
father('Ганс','Анрі').
father('Христиан','Герда').
father('Христиан','Карина').
father('Мігель','Анхем').
father('Анрі','Робін').
father('Анрі','Том').
father('Том','Фріц').
father('Том','Карп').

mother('Марія','Марго').
mother('Марія','Анрі').
mother('Габріела','Герда').
mother('Габріела','Карина').
mother('Герда','Робін').
mother('Герда','Том').
mother('Гретхен','Анхем').
mother('Анхем','Фріц').
mother('Анхем','Карп').

daughter('Марго','Ганс').
daughter('Марго','Марія').
daughter('Герда','Христиан').
daughter('Герда','Габріела').
daughter('Карина','Христиан').
daughter('Карина','Габріела').
daughter('Анхем','Мігель').
daughter('Анхем','Гретхен').

son('Анрі','Ганс').
son('Анрі','Марія').
son('Робін','Анрі').
son('Робін','Герда').
son('Том','Анрі').
son('Том','Герда').
son('Фріц','Том').
son('Фріц','Анхем').
son('Карп','Том').
son('Карп','Анхем').

brother(X,Y):-son(X,Z),mother(Z,Y). 
sister(X,Y):-daughter(X,Z),mother(Z,Y).

uncle(X,Y) :- brother(X, Z),father(Z,Y). 
uncle(X,Y) :- brother(X, Z),mother(Z,Y). 

aunt(X,Y):-sister(X,Z),father(Z,Y). 
aunt(X,Y):-sister(X,Z),mother(Z,Y). 

grandfather(X,Y):-son(Z,X),father(Z,Y). 
grandfather(X,Y):-daughter(Z,X),father(Z,Y). 

grandmother(X,Y):-mother(X,Z),son(Y,Z). 
grandmother(X,Y):-mother(X,Z),daughter(Y,Z). 

grandson(X,Y):-son(X,Z),daughter(Z,Y). 
grandson(X,Y):-son(X,Z),son(Z,Y). 

granddaughter(X,Y):-daughter(X,Z),daughter(Z,Y). 
granddaughter(X,Y):-daughter(X,Z),son(Z,Y). 

nephew(X,Y):-son(X,Z),sister(Z,Y). 
nephew(X,Y):-son(X,Z),brother(Z,Y). 

niece(X,Y):-daughter(X,Z),sister(Z,Y). 
niece(X,Y):-daughter(X,Z),brother(Z,Y). 

married(X,Y):-daughter(Z,X),daughter(Z,Y). 
married(X,Y):-son(Z,X),son(Z,Y). 

hismotherinlaw(X,Y):-married(Z,Y),daughter(Z,X),mother(X,Z). 

hisfatherinlaw(X,Y):-married(Z,Y),daughter(Z,X),father(X,Z). 

hermotherinlaw(X,Y):-married(Z,Y),son(Z,X),mother(X,Z). 

herfatherinlaw(X,Y):-son(Z,X),married(Z,Y),father(X,Z). 


soninlaw(X,Y):-married(X,Z),father(Z,Y). 

daughterinlaw(X,Y):-married(X,Z),son(Z,Y). 

brotherinlaw(X,Y):-married(X,Z),sister(Z,D),married(D,Y). 

sisterinlaw(X,Y):-sister(X,Z),married(Z,Y),sister(Z,X). 

diver(X,Y):-married(Y,Z),brother(X,Z). 

greatnephew(X,Y):-grandson(X,Z),sister(Z,Y). 
greatnephew(X,Y):-grandson(X,Z),brother(Z,Y). 

greatniece(X,Y):-granddaughter(X,Z),sister(Z,Y). 
greatniece(X,Y):-granddaughter(X,Z),brother(Z,Y).

