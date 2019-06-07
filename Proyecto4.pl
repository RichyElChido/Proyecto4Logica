
%Definimos los operadores con la siguiente estructura op(precedencia, tipo, nombre)
%precedencia es un numero que va de 0 a 1200
%tipo puede ser de las siguientes maneras xf, yf, xfx, xfy, yfx, yfy, fy o fx.
%la f indica la posicion del operador y "x" y "y" indica la posicion de los argumentos.
:- op(1150,xfy,or). % Disjunction
:- op(1150,fx,neg). % Negation
:- op(1150,xfy,and). % Conjuction
:- op(1150,xfy,impl). % Implication
:- op(1150,xfy,iff). % Double Implication

%Regresa verdadero si la formula es atomica y si ambos argumentos son iguales.
dnf(A,A) :- atom(A).

dnf(neg A,neg C) :- dnf(A,C).
%Comprueba si la conjuncion es valida.
dnf(A or B,C or D) :- dnf(A,C),dnf(B,D).
%Comprueba si la conjuncion y la eliminacion de la conjuncion son validas.
dnf(A and B,neg((neg C) or (neg D))) :- dnf(A,C),dnf(B,D).
%Devuelve verdadero si ambos lados son equivalentes.
dnf(A impl B,(neg C) or D) :- dnf(A,C),dnf(B,D).
%Comprueba si el si solo si es valido al aplicar dnf a la eliminacion de la doble imoplicacion.
dnf(A iff B,C) :- dnf((A impl B) and (B impl A),C).

%aplica dnf con dos listas.
%toma el primer elemento de cada lista y aplica dnf con la cabeza de la primera lista
%y la cabeza de la segunda como argumentos.
%aplica la funcion dnfL recursivamente con el resto de ambas listas como argumentos.
dnfL([],[]).
dnfL([F|Fs],[G|Gs]) :- dnf(F,G),dnfL(Fs,Gs).


%Hipótesis.
%intersection es verdadero si L unifica a I y a D en un conjunto.
sc(I,D) :- not(intersection(I,D,L)).


%%%%%
%Negación

%Regla(neg I)
%Si el lado izquierdo contiene una negacion se aplica la regla de la negacion
%para el lado izquierdo, quitando la negacion y agregando a F del lado derecho. 
sc([(neg F)|I],D) :- sc_aux(I,[F|D]).

%Regla (neg D)
%Si el lado derecho contiene una negacion se aplica la regla de la negacion de sequentes
%para el lado derecho pasando a F del lado izquierdo.
sc(I,[(neg F)|D]) :- sc_aux([F|I],D).


%%%%%
%Disyunción

%Regla(V D)
%si se tiene una conjuncion del lado derecho se aplica la regla (V D) para el calculo de secuentes
%y se juntan a F1 y F2.
sc(I,[(F1 or F2)|D]) :- union([F1,F2],D,D1),sc_aux(I,D1).

%Regla (v I)
%Se aplica la regla (v I) del calculo de secuentes y se pasa a F1 y F2 que son parte del
%argumento de la disyuncion junto con delta en ambos lados como dice la regla.
sc([(F1 or F2)|I],D) :- sc_aux([F1|I],D),sc_aux([F2|I],D).

%%%%%
%Conjunción
%Regla (And I)
sc([(F1 and F2)|I], D):-union([F1,F2],D,D1),sc_aux(I,D1).
%Regla (And D)
sc(I, [(F1 and F2)|D]):-sc_aux(I,F1),sc_aux(I,F2).

%%%%%
%Implicación
%Regla (Imp I)
sc([(F1 impl F2)|I],D):-sc_aux([F1|I],D), sc_aux(I,[F2|D]).
%Regla (Imp D)
sc(I,[(F1 impl F2)|D]):-sc_aux([F1|I],D),sc_aux(F2,D).

%calcula permutaciones de I y de D y con cada permutacion aplica el 
%calculo de secuentes tomando la permutacion de I y de D como parametros.
sc_aux(I,D):-permutation(I,I1),permutation(D,D1),sc(I1,D1).

sc1(I,D) :- dnfL(I,I1),dnfL(D,D1),sc(I1,D1).