function [x_opt,f_opt] = lp(c,A,b,Aeq,beq)
%lp is a function for solving linear problems
%The entrys are similar to linprog (matlab function)
%           f: the function to me minimized
%           A and b: The values to form an inequality system Ax <= b
%           Aeq and beq: The values to form an equality system Aeqx <= beq

%% Define variables
if ~exist('Aeq','var')
    Aeq = [];
end
   
if ~exist('beq','var')
    beq = [];
end

if ( ~isempty(A) && isempty(b) ) || ( isempty(A) && ~isempty(b) )
    disp('If A exist, b must exist too...')
    return
end

if ( ~isempty(Aeq) && isempty(beq) ) || ( isempty(Aeq) && ~isempty(beq) )
    disp('If Aeq exist, beq must exist too...')
    return
end

if size(Aeq,2) ~=  + size(A,2) && ~isempty(Aeq)
    disp('Number of variables in Aeq must be equal to A...')
    return
end

m = size(A,1) + size(Aeq,1);    %number of constrains
n = size(A,2);                  %number of variables
na = size(A,1);                 %number of slack variables

%Get together all restrictions
A = [A; Aeq];
b = [b; beq];
c = [c; zeros(m,1)];

%Slack variables and aditional variables
A = [A, eye(m)];
                                            
%% Fist Phase - Find an Feasible Solution

%Initial solution to auxiliary problem
x0 = [zeros(n,1); b]

%Vector with base variables
base = (n+1):(n+m);

%If there are not enought slack variables, than use the extra variables 
%to find an initial solution
if na < m
    %Auxiliary c
    caux = [zeros(n,1); ones(m,1)];

    [x0, fo] = simplex(c,A,b,x0,base)
end

%Given an initial condition, solve the problem
[x_opt, f_opt] = simplex(c,A,b,x0,base)


end
