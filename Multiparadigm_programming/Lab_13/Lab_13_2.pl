read_el(C):-
    read_el([],0,C),!.
read_el(C,N,C):-
    N=32,!.
read_el(C,N,X):-
    write('Number '),
    write(N),
    write(' :'),
    read(EL),
    append(C,[EL],C1),
    N1 is N + 1,
    read_el(C1,N1,X).

movlist(L,F):-
    movlist(L,0,F).
movlist([EL|L],N,F):-
    N<3,N1 is N+1,append(L,[EL],L1),movlist(L1,N1,F).
movlist(L,3,L).
interf2(X):-
    write('Ввеcти список элементов: '),
    read_el(L),
    movlist(L,X).