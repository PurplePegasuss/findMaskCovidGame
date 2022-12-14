:- use_module(library(clpfd)).
:- use_module(library(lists)).

/*
 * Kirill Glinskiy, BS19-06
 * The idea of implementing A* was adapted from:
 * https://medium.com/@nicholas.w.swift/easy-a-star-pathfinding-7e6689c7f7b2
 *
 * Common variable Name types:
 * FinalVariable - Stores the value after the usage of continuos rules.
 * AppendedVariable - Usually it's the name for appended list.
 * NewVariable - Something what is created using the previous variable.
 *
 * Hope you are not so bored reading all these function descriptions :)
 */

/*
 * TO START THE PROGRAM, RUN THE COMMAND:
 *
 * StartingPoint(9) or any lower number you prefer.
 */


/*
 * Prints the generated positions of roles, starts backtracking and A*,
 * prints final paths, their runtime performance and visualize them.
 *
 * @param {number} Size - size of the map.
 */
startingPoint(Size):-
    Size > 4,
    generatePositions(Size,Actor,Home,Cov1,Cov2,Doctor,Mask),
    writef("Actor Position:\n"),
    write(Actor),
    writef("\nHome Position:\n"),
    write(Home),
    writef("\nCovids Position:\n"),
    write(Cov1),
    write(Cov2),
    writef("\nDoctor & Mask Position:\n"),
    write(Doctor),
    write(Mask),
    writef("\n\n"),
    ListSize = 0,
    write("Runtime of Backtracking:\n"),
    statistics(runtime,[Start|_]),
    backtracking(Size,Actor,Home,Cov1,Cov2,Doctor,Mask,[Actor],0,ListSize,Size*Size,FinalSize,FinalList),
    minLengthBacktracking(Size,Actor,Home,Cov1,Cov2,Doctor,Mask,FinalSize,FinalList,AnswerPath),
    statistics(runtime,[End|_]),
    BacktrackingTime is End - Start,
    write(BacktrackingTime),
    write("\n\n"),
    writef("Backtracking minimal Path:\n"),
    write(AnswerPath),
    write("\n\nLength of A* Minimal Path:\n"),
    length(AnswerPath,L),
    Length is L - 1,
    write(Length),
    write("\n\n"),

    visualize(Size,Actor,Home,Cov1,Cov2,Doctor,Mask,0,Size-1,AnswerPath),
    startAStar(Size,Actor,Home,Cov1,Cov2,Doctor,Mask),
    writef("\n\n"),
    !.

/*
 * Visualizes the playgorund as a N x N cells.
 *
 * @param {number} Size - size of the map.
 * @param {[number,number]} Actor - position of Actor.
 * @param {[number,number]} Home - position of Home.
 * @param {[number,number]} Cov1 - position of first Covid.
 * @param {[number,number]} Cov2 - position of second Covid.
 * @param {[number,number]} Doctor - position of Doctor.
 * @param {[number,number]} Mask - position of Mask.
 * @param {number} X - current cell position with respect to X.
 * @param {number} Y - current cell position with respect to Y.
 * @param {[[number,number],...]} AnswerPath - minimal Path.
 */
visualize(Size,Actor,Home,Cov1,Cov2,Doctor,Mask,X,Y,AnswerPath):-
    ((Y =:= 0,
     X =:= Size - 1),
     chooseWhatToPrint(Actor,Home,Cov1,Cov2,Doctor,Mask,[X,Y],AnswerPath),
     write("\n\n"),
    !);
    (X > Size - 2,
     Y >= 0,
     Y =< Size-1,
     chooseWhatToPrint(Actor,Home,Cov1,Cov2,Doctor,Mask,[X,Y],AnswerPath),
     write("\n"),
     Y2 #= Y - 1,
     visualize(Size,Actor,Home,Cov1,Cov2,Doctor,Mask,0,Y2,AnswerPath),
    !);
    (X >= 0,
     X =< Size-1,
     Y >= 0,
     Y =< Size-1,
     chooseWhatToPrint(Actor,Home,Cov1,Cov2,Doctor,Mask,[X,Y],AnswerPath),
     X2 #= X + 1,
     visualize(Size,Actor,Home,Cov1,Cov2,Doctor,Mask,X2,Y,AnswerPath),
    !).

/*
 * Prints the current position onto the map, based on equality with roles.
 *
 * @param {[number,number]} [ActorX,ActorY] - position of Actor.
 * @param {[number,number]} [HomeX,HomeY] - position of Home.
 * @param {[number,number]} [Cov1X,Cov1Y] - position of first Covid.
 * @param {[number,number]} [Cov2X,Cov2Y] - position of second Covid.
 * @param {[number,number]} [DoctorX,DoctorY] - position of Doctor.
 * @param {[number,number]} [MaskX,MaskY] - position of Mask.
 * @param {[number,number]} [X,Y] - current position to print.
 * @param {[[number,number],...]} AnswerPath - minimal Path.
 */

chooseWhatToPrint([ActorX,ActorY],[HomeX,HomeY],[Cov1X,Cov1Y],[Cov2X,Cov2Y],[DoctorX,DoctorY],[MaskX,MaskY],[X,Y],AnswerPath):-
    (ActorX =:= X,
     ActorY =:= Y,
     write("A"),
    !);
    (HomeX =:= X,
     HomeY =:= Y,
     write("H"),
    !);
    (Cov1X =:= X,
     Cov1Y =:= Y,
     write("C"),
    !);
    (Cov2X =:= X,
     Cov2Y =:= Y,
     write("C"),
    !);
    (DoctorX =:= X,
     DoctorY =:= Y,
     write("D"),
    !);
    (MaskX =:= X,
     MaskY =:= Y,
     write("M"),
    !);
    (member([X,Y],AnswerPath),
     write("+"));
    write("*"),
    !.

/*
 * A function that finds F by adding up the distance traveled and heuristics to the house.
 *
 * @param {number} CurrentLength - length of the path from initial position to the current.
 * @param {[number,number]} [CurrentX,CurrentY] - current position
 * @param {[number,number]} [HomeX,HomeY] - position of Home.
 * @param {number} F - sum of distance traveled and heuristics to the house.
 */
findF(CurrentLength,[CurrentX,CurrentY],[HomeX,HomeY],F):-
    F is (CurrentLength - 1 +(HomeX-CurrentX)*(HomeX-CurrentX) + (HomeY-CurrentY)*(HomeY-CurrentY)).

/*
 * Runs A* algorithm, calculates its runtime, outputs the minimum path, and visualizes it.
 *
 * @param {number} Size - size of the map.
 * @param {[number,number]} Actor - position of Actor.
 * @param {[number,number]} Home - position of Home.
 * @param {[number,number]} Cov1 - position of first Covid.
 * @param {[number,number]} Cov2 - position of second Covid.
 * @param {[number,number]} Doctor - position of Doctor.
 * @param {[number,number]} Mask - position of Mask.
 */
startAStar(Size,Actor,Home,Cov1,Cov2,Doctor,Mask):-
    write("Runtime of A*:\n"),
    statistics(runtime,[Start|_]),
    a_star(Size,Actor,Home,Cov1,Cov2,Doctor,Mask,1,[0],[Actor],[],0,0,FinalList,[],[],FinalParents),
    statistics(runtime,[End|_]),
    AstarTime is End - Start,
    write(AstarTime),
    write("\n\n"),
    write("A* Minimal Path:\n"),
    collectPath(FinalList,FinalParents,[Home],Home,FinalAnswer),
    write(FinalAnswer),
    write("\n\nLength of A* Minimal Path:\n"),
    length(FinalAnswer,L),
    Length is L - 1,
    write(Length),
    write("\n\n"),
    visualize(Size,Actor,Home,Cov1,Cov2,Doctor,Mask,0,Size-1,FinalAnswer).


/*
 * A* algorithm that computes the minimum path by choosing optimal transitions from the pool of open nodes.
 *
 * @param {number} Size - size of the map.
 * @param {[number,number]} Actor - position of Actor.
 * @param {[number,number]} Home - position of Home.
 * @param {[number,number]} Cov1 - position of first Covid.
 * @param {[number,number]} Cov2 - position of second Covid.
 * @param {[number,number]} Doctor - position of Doctor.
 * @param {[number,number]} Mask - position of Mask.
 * @param {number} OpenListSize - size of the pool of open nodes.
 * @param {[[number,number],...]} [FH|FT] - list of F values for each open node.
 * @param {[[number,number],...]} [NodesH|NodesT] - list of open nodes.
 * @param {[[number,number],...]} ClosedList - list of closed nodes.
 * @param {number} Length - distance traveled.
 * @param {1 or 0} MaskFlag - flag to check either Actor visited the Doctor or weared Mask.
 * @param {[[number,number],...]} FinalList - closed list on the final iteration.
 * @param {[[number,number],...]} Parents - list of parents for each open node.
 * @param {[[number,number],...]} ClosedParents - list of parents for each closed node.
 * @param {[[number,number],...]} FinalParents - parents for closed nodes on the final iteration.
 */
a_star(_,_,[HomeX,HomeY],_,_,_,_,OpenListSize,[FH|FT],[NodesH|NodesT],ClosedList,_,_,FinalList,_,ClosedParents,FinalParents):-
    OpenListSize > 0,
    chooseMinFInList(FT,NodesT,FH,NodesH,_,[FinalNodeX,FinalNodeY]),
    HomeX =:= FinalNodeX,
    HomeY =:= FinalNodeY,
    last(ClosedList,LastParent),
    append(ClosedList,[[HomeX,HomeY]],ClosedList1),
    append(ClosedParents,[LastParent],ClosedParents1),
    FinalParents = ClosedParents1,
    FinalList = ClosedList1.

a_star(Size,Actor,Home,Cov1,Cov2,Doctor,Mask,OpenListSize,[FH|FT],[NodesH|NodesT],ClosedList,Length,1,FinalList,Parents,ClosedParents,FinalParents):-
    OpenListSize > 0,
    chooseMinFInList(FT,NodesT,FH,NodesH,FinalF,[FinalNodeX,FinalNodeY]),
    nth0(OpenNodeIndex,[NodesH|NodesT],[FinalNodeX,FinalNodeY]),
   (nth0(OpenNodeIndex,Parents,CheckParent);
    CheckParent = [-1,-1]),
    delete([NodesH|NodesT],[FinalNodeX,FinalNodeY],NewOpenedNodes),
    delete([FH|FT],FinalF,NewOpenedF),
    append(ClosedList,[[FinalNodeX,FinalNodeY]],AppendedClosedList),
    append(ClosedParents,[CheckParent],AppendedClosedParents),
    (nth0(OpenNodeIndex,Parents,_,Parents0);
    Parents0 = []),
    NewLength is Length + 1,
    A1 #= FinalNodeX + 1,
    A2 #= FinalNodeY + 1,
    A3 #= FinalNodeX - 1,
    A4 #= FinalNodeY - 1,
    Neighbours = [[A1,A2],
                  [A1,FinalNodeY],
                  [FinalNodeX,A2],
                  [A3,A2],
                  [A1,A4],
                  [FinalNodeX,A4],
                  [A3,FinalNodeY],
                  [A3,A4]],
    (bagof(Y,(member(Y,Neighbours),conditionsWithMask(Size,AppendedClosedList,NewOpenedNodes,Y)),FilteredNeighbours);
    FilteredNeighbours = []),
    length(FilteredNeighbours, NSize),
    length(ParentsFiltered, NSize),
    maplist(=([FinalNodeX,FinalNodeY]), ParentsFiltered),
    append(Parents0,ParentsFiltered,ParentsNew),

    append(NewOpenedNodes,FilteredNeighbours,StepOpenList),
    collectPathLength(AppendedClosedList,AppendedClosedParents,0,[FinalNodeX,FinalNodeY],G),
    findall(F,(member(E,FilteredNeighbours),findF(G,E,Home,F)),FilteredF),
    append(NewOpenedF,FilteredF,StepOpenF),
    length(StepOpenList,StepOpenListSize),
    a_star(Size,Actor,Home,Cov1,Cov2,Doctor,Mask,StepOpenListSize,StepOpenF,StepOpenList,AppendedClosedList,NewLength,1,FinalList,ParentsNew,AppendedClosedParents,FinalParents).


a_star(Size,Actor,Home,Cov1,Cov2,Doctor,Mask,OpenListSize,[FH|FT],[NodesH|NodesT],ClosedList,Length,0,FinalList,Parents,ClosedParents,FinalParents):-
    OpenListSize > 0,
    chooseMinFInList(FT,NodesT,FH,NodesH,FinalF,[FinalNodeX,FinalNodeY]),
    nth0(OpenNodeIndex,[NodesH|NodesT],[FinalNodeX,FinalNodeY]),
    checkMask([FinalNodeX,FinalNodeY],Doctor,Mask,MaskFlag),
    (nth0(OpenNodeIndex,Parents,CheckParent);
    CheckParent = [-1,-1]),
    delete([NodesH|NodesT],[FinalNodeX,FinalNodeY],NewOpenedNodes),
    delete([FH|FT],FinalF,NewOpenedF),
    append(ClosedList,[[FinalNodeX,FinalNodeY]],AppendedClosedList),
    append(ClosedParents,[CheckParent],AppendedClosedParents),
    (nth0(OpenNodeIndex,Parents,_,Parents0);
    Parents0 = []),
    NewLength is Length + 1,
    A1 #= FinalNodeX + 1,
    A2 #= FinalNodeY + 1,
    A3 #= FinalNodeX - 1,
    A4 #= FinalNodeY - 1,
    Neighbours = [[A1,A2],
                  [A1,FinalNodeY],
                  [FinalNodeX,A2],
                  [A3,A2],
                  [A1,A4],
                  [FinalNodeX,A4],
                  [A3,FinalNodeY],
                  [A3,A4]],
    ((([FinalNodeX,FinalNodeY] = Doctor;
     [FinalNodeX,FinalNodeY] = Mask),
     (bagof(Y,(member(Y,Neighbours),conditionsWithMask(Size,AppendedClosedList,NewOpenedNodes,Y)),FilteredNeighbours);
    FilteredNeighbours = []));
    (bagof(Y,(member(Y,Neighbours),conditions(Size,Cov1,Cov2,AppendedClosedList,NewOpenedNodes,Y)),FilteredNeighbours);
    FilteredNeighbours = [])),

    length(FilteredNeighbours, NSize),
    length(ParentsFiltered, NSize),
    maplist(=([FinalNodeX,FinalNodeY]), ParentsFiltered),
    append(Parents0,ParentsFiltered,ParentsNew),
    append(NewOpenedNodes,FilteredNeighbours,StepOpenList),
    collectPathLength(AppendedClosedList,AppendedClosedParents,0,[FinalNodeX,FinalNodeY],G),
    findall(F,(member(E,FilteredNeighbours),findF(G,E,Home,F)),FilteredF),
    append(NewOpenedF,FilteredF,StepOpenF),
    length(StepOpenList,StepOpenListSize),
    a_star(Size,Actor,Home,Cov1,Cov2,Doctor,Mask,StepOpenListSize,StepOpenF,StepOpenList,AppendedClosedList,NewLength,MaskFlag,FinalList,ParentsNew,AppendedClosedParents,FinalParents).


/*
 * Checking conditions without the mask for forming a list of neighbors.
 *
 * @param {number} Size - size of the map.
 * @param {[number,number]} Cov1 - position of first Covid.
 * @param {[number,number]} Cov2 - position of second Covid.
 * @param {[[number,number],...]} ClosedList - list of closed nodes.
 * @param {[[number,number],...]} OpenList - list of open nodes.
 * @param {[number,number]} [NeighbourX,NeighbourY] - neighbour position.
 */
conditions(Size,Cov1,Cov2,ClosedList,OpenList,[NeighbourX,NeighbourY]):-
    \+(member([NeighbourX,NeighbourY],OpenList)),
    notOutOfBorders([NeighbourX,NeighbourY],0,Size - 1),
    notAdjacent([NeighbourX,NeighbourY],Cov1),
    notAdjacent([NeighbourX,NeighbourY],Cov2),
    \+(member([NeighbourX,NeighbourY],ClosedList)),
    !.
/*
 * Checking conditions with the mask for forming a list of neighbors.
 *
 * @param {number} Size - size of the map.
 * @param {[[number,number],...]} ClosedList - list of closed nodes.
 * @param {[[number,number],...]} OpenList - list of open nodes.
 * @param {[number,number]} [NeighbourX,NeighbourY] - neighbour position.
 */
conditionsWithMask(Size,ClosedList,OpenList,[NeighbourX,NeighbourY]):-
    \+(member([NeighbourX,NeighbourY],OpenList)),
    notOutOfBorders([NeighbourX,NeighbourY],0,Size-1),
    \+(member([NeighbourX,NeighbourY],ClosedList)),
    !.


/*
 * Reconstructs the path using the parents of the closed list.
 *
 * @param {[[number,number],...]} List - list of closed nodes.
 * @param {[[number,number],...]} Parents - list of parents for each open node.
 * @param {[[number,number],...]} CollectList - reconstructed nodes list.
 * @param {[number,number]} CurNode - current position to reconstruct.
 * @param {[[number,number],...]} FinalList - reconstructed minimal path.
 */
collectPath(List,Parents,CollectList,CurNode,FinalList):-
    nth0(Index,List,CurNode),
    nth0(Index,Parents,CurParent),

    append(CollectList,[CurParent],NewCollectList),
    collectPath(List,Parents,NewCollectList,CurParent,FinalList).

collectPath(_,_,CollectList,[-1,-1],FinalList):-
    delete(CollectList,[-1,-1],CollectList1),
    reverse(CollectList1, CollectList2),
    FinalList = CollectList2,
    !.
/*
 * Reconstructs the length using the parents of the closed list.
 *
 * @param {[[number,number],...]} List - list of closed nodes.
 * @param {[[number,number],...]} Parents - list of parents for each open node.
 * @param {number} Length - reconstructed length.
 * @param {[number,number]} CurNode - current position to reconstruct.
 * @param {[[number,number],...]} FinalList - reconstructed length on final iteration.
 */
collectPathLength(List,Parents,Length,CurNode,FinalLength):-
    nth0(Index,List,CurNode),
    nth0(Index,Parents,CurParent),
    Length1 is Length +1,
    collectPathLength(List,Parents,Length1,CurParent,FinalLength).

collectPathLength(_,_,Length,[-1,-1],FinalLength):-
    FinalLength = Length,
    !.

/*
 * Finds minimal F from the pool of open nodes.
 * @param {[[number,number],...]} [FH|FT] - list of F values for each open node.
 * @param {[[number,number],...]} [NodesH|NodesT] - list of open nodes.
 * @param {number} MinF - minimal F value,
 * @param {[number,number]} MinNode - node with minimal F value,
 * @param {number} FinalF - minimal F value at final iteration,
 * @param {[number,number]} FinalNode - node with minimal F value at final iteration.
 */
chooseMinFInList([FH|FT],[NodesH|NodesT],MinF,MinNode,FinalF,FinalNode):-
    (FH < MinF,
     chooseMinFInList(FT,NodesT,FH,NodesH,FinalF,FinalNode));
    chooseMinFInList(FT,NodesT,MinF,MinNode,FinalF,FinalNode).

chooseMinFInList([],[],MinF,MinNode,FinalF,FinalNode):-
    FinalF is MinF,
    FinalNode = MinNode.


/*
 * Generates the positions of Roles.
 *
 * @param {number} Size - size of the map.
 * @param {[number,number]} Actor - position of Actor.
 * @param {[number,number]} Home - position of Home.
 * @param {[number,number]} Cov1 - position of first Covid.
 * @param {[number,number]} Cov2 - position of second Covid.
 * @param {[number,number]} Doctor - position of Doctor.
 * @param {[number,number]} Mask - position of Mask.
 */
generatePositions(Size,Actor,Home,Cov1,Cov2,Doctor,Mask):-
    N = 0,
    M is Size,
    Actor = [0,0],
    List_of_Roles1 = [Actor],
    putHomeOnTheMap(N,M,List_of_Roles1,List_of_Roles2,Home),
    putCovOnTheMap(N,M,List_of_Roles2,List_of_Roles3,Cov1,Home),
    putCovOnTheMap(N,M,List_of_Roles3,List_of_Roles4,Cov2,Home),
    putMask(N,M,Cov1,Cov2,List_of_Roles4,List_of_Roles5,Doctor),
    putMask(N,M,Cov1,Cov2,List_of_Roles5,_,Mask).

/*
 * Generates the position of home.
 *
 * @param {number} N - lower boundary of our map (usually 0).
 * @param {number} M - upper boundary of our map (usually Size - 1).
 * @param {[[number,number],...]} List - list of roles.
 * @param {[[number,number],...]} AppendedList - list of roles after inserting a new role.
 * @param {[number,number]} Role - generated position of role.
 */
putHomeOnTheMap(N,M,List,AppendedList,Role):-
    repeat,
    random(N,M,RoleX),
    random(N,M,RoleY),
    \+(member([RoleX,RoleY],List)),
    Role = [RoleX,RoleY],
    append(List,[[RoleX,RoleY]],AppendedList),
    !.

/*
 * Generates the position of Covid.
 *
 * @param {number} N - lower boundary of our map (usually 0).
 * @param {number} M - upper boundary of our map (usually Size - 1).
 * @param {[[number,number],...]} List - list of roles.
 * @param {[[number,number],...]} AppendedList - list of roles after inserting a new role.
 * @param {[number,number]} Role - generated position of role.
 * @param {[number,number]} Home - position of Home.
 */
putCovOnTheMap(N,M,List,AppendedList,Role,Home):-
    repeat,
    random(N,M,RoleX),
    random(N,M,RoleY),
    \+(member([RoleX,RoleY],List)),
    notAdjacent([RoleX,RoleY],Home),
    Role = [RoleX,RoleY],
    append(List,[[RoleX,RoleY]],AppendedList),
    !.

/*
 * Generates the position of Mask.
 *
 * @param {number} N - lower boundary of our map (usually 0).
 * @param {number} M - upper boundary of our map (usually Size - 1).
 * @param {[number,number]} Cov1 - position of first Covid.
 * @param {[number,number]} Cov2 - position of second Covid.
 * @param {[[number,number],...]} List - list of roles.
 * @param {[[number,number],...]} AppendedList - list of roles after inserting a new role.
 * @param {[number,number]} Role - generated position of role.
 */
putMask(N,M,Cov1,Cov2,List,AppendedList,Role):-
    repeat,
    random(N,M,RoleX),
    random(N,M,RoleY),
    \+(member([RoleX,RoleY],List)),
    notAdjacent([RoleX,RoleY],Cov1),
    notAdjacent([RoleX,RoleY],Cov2),
    Role = [RoleX,RoleY],
    append(List,[[RoleX,RoleY]],AppendedList),
    !.

/*
 * Check if position is out of borders.
 *
 * @param {[number,number]} [X,Y] - position to be checked.
 * @param {number} N - lower boundary of our map (usually 0).
 * @param {number} M - upper boundary of our map (usually Size - 1).
 */
notOutOfBorders([X,Y],N,M):-
    \+(X =:= N-1),
    \+(Y =:= N-1),
    \+(X =:= M+1),
    \+(Y =:= M+1).

/*
 * Checks if the currently computed backtracking path is less than the previous one and keeps the minimum path.
 *
 * @param {number} Size - size of the map.
 * @param {[number,number]} Actor - position of Actor.
 * @param {[number,number]} Home - position of Home.
 * @param {[number,number]} Cov1 - position of first Covid.
 * @param {[number,number]} Cov2 - position of second Covid.
 * @param {[number,number]} Doctor - position of Doctor.
 * @param {[number,number]} Mask - position of Mask.
 * @param {number} MinSize - path length.
 * @param {[[number,number],...]} MinFinalList - current minimal path.
 * @param {[[number,number],...]} AnswerPath - final minimal path.
 */
minLengthBacktracking(Size,Actor,Home,Cov1,Cov2,Doctor,Mask,MinSize,MinFinalList,AnswerPath):-
    (backtracking(Size,Actor,Home,Cov1,Cov2,Doctor,Mask,[Actor],0,0,MinSize,FinalSize,FinalList),
     minLengthBacktracking(Size,Actor,Home,Cov1,Cov2,Doctor,Mask,FinalSize,FinalList,AnswerPath));
     AnswerPath = MinFinalList.


/*
 * Standard backtracking with Chebyshev optimization and cut-off paths, less than the current minimum.
 *
 * @param {number} Size - size of the map.
 * @param {[number,number]} [X,Y] - current position.
 * @param {[number,number]} [HomeX,HomeY] - position of Home.
 * @param {[number,number]} Cov1 - position of first Covid.
 * @param {[number,number]} Cov2 - position of second Covid.
 * @param {[number,number]} Doctor - position of Doctor.
 * @param {[number,number]} Mask - position of Mask.
 * @param {[[number,number],...]} List - storage for current path.
 * @param {1 or 0} MaskFlag - flag to check either Actor visited the Doctor or weared Mask.
 * @param {number} ListSize - storage for length of current path.
 * @param {number} MinSize - storage for length of minimal path.
 * @param {number} StoreMinSize - length of minimal path on final iteration.
 * @param {[[number,number],...]} StoreList - storage for current path on final iteration.
 */

backtracking(_,Home,Home,_,_,_,_,List,_,ListSize,_,StoreMinSize,StoreList):-
    StoreMinSize is ListSize,
    StoreList = List,
    true.

backtracking(Size,[X,Y],[HomeX,HomeY],Cov1,Cov2,Doctor,Mask,List,1,ListSize,MinSize,StoreMinSize,StoreList):-
    findAdjacent([X,Y],[NeighbourX,NeighbourY]),
    \+(member([NeighbourX,NeighbourY],List)),
    notOutOfBorders([NeighbourX,NeighbourY],0,Size-1),
    append(List,[[NeighbourX,NeighbourY]],AppendedList),
    IncrementedListSize is ListSize + 1,
    IncrementedListSize + max(abs(HomeX-NeighbourX),abs(HomeY-NeighbourY)) < MinSize,
    backtracking(Size,[NeighbourX,NeighbourY],[HomeX,HomeY],Cov1,Cov2,Doctor,Mask,AppendedList,1,IncrementedListSize,MinSize,StoreMinSize,StoreList).

backtracking(Size,[X,Y],[HomeX,HomeY],Cov1,Cov2,Doctor,Mask,List,0,ListSize,MinSize,StoreMinSize,StoreList):-
    findAdjacent([X,Y],[NeighbourX,NeighbourY]),
    \+(member([NeighbourX,NeighbourY],List)),
    notAdjacent([NeighbourX,NeighbourY],Cov1),
    notAdjacent([NeighbourX,NeighbourY],Cov2),
    notOutOfBorders([NeighbourX,NeighbourY],0,Size-1),
    append(List,[[NeighbourX,NeighbourY]],AppendedList),
    IncrementedListSize is ListSize + 1,
    IncrementedListSize + max(abs(HomeX-NeighbourX),abs(HomeY-NeighbourY)) < MinSize,
    checkMask([NeighbourX,NeighbourY],Doctor,Mask,MaskFlag),
    backtracking(Size,[NeighbourX,NeighbourY],[HomeX,HomeY],Cov1,Cov2,Doctor,Mask,AppendedList,MaskFlag,IncrementedListSize,MinSize,StoreMinSize,StoreList).

/*
 * Check if current position is the mask.
 *
 * @param {[number,number]} CurrentPos - position to be checked.
 * @param {[number,number]} Doctor - position of Doctor.
 * @param {[number,number]} Mask - position of Mask.
 * @param {1 or 0} MaskFlag - flag to check if Mask is in CurrentPos.
 */
checkMask(CurrentPos,Doctor,Mask,MaskFlag):-
    ((CurrentPos = Doctor;
    CurrentPos = Mask),
    MaskFlag #= 1);
    MaskFlag #= 0.

/*
 * Finds suitable adjacent neighbour. If it's not suitable, checks another one.
 *
 * @param {[number,number]} [CurX,CurY] - current position.
 * @param {[number,number]} [NbrX,NbrY] - neighbours position.
 */
findAdjacent([CurX,CurY],[NbrX,NbrY]):-
   (CurX + 1 #= NbrX,
    CurY + 1 #= NbrY);
   (CurX + 1 #= NbrX,
    CurY  #= NbrY);
   (CurX #= NbrX,
    CurY + 1#= NbrY);
   (CurX - 1 #= NbrX,
    CurY + 1 #= NbrY);
   (CurX + 1 #= NbrX,
    CurY - 1 #= NbrY);
   (CurX #= NbrX,
    CurY - 1 #= NbrY);
   (CurX - 1 #= NbrX,
    CurY #= NbrY);
   (CurX - 1 #= NbrX,
    CurY - 1#= NbrY).

/*
 * Check if 2 given positions are adjacent.
 *
 * @param {[number,number]} [X,Y] - position to be checked.
 * @param {[number,number]} [X1,Y1] - second position to be checked.
 */
notAdjacent([X,Y],[X1,Y1]):-
    abs(X-X1) > 1;
    abs(Y-Y1) > 1.

