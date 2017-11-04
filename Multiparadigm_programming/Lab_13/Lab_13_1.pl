nlist(L,R):-
    nlist(L,[],R).
nlist([],R,R).
nlist([T|[]],X,R):-
    R1 is T/3,append(X,[R1],L1),nlist([],L1,R),!.
nlist([O,T|[]],X,R):-
    R1 is (O+T)/3,append(X,[R1],L1),nlist([],L1,R),!.
nlist([O,T,TH|[]],X,R):-
    R1 is (O+T+TH)/3,append(X,[R1],L1),nlist([],L1,R),!.
nlist([O,T,TH|OT],X,R):-
    R1 is (O+T+TH)/3,append(X,[R1],L1),nlist(OT,L1,R).
list([T],T).
interf(X):-
    write('Please type the list:'),
    nl,
    read(L),
    nlist(L,X),
    write(L),
    write(' : ').