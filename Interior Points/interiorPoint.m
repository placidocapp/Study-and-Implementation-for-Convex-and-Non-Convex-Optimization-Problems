function [x_opt,f_opt,status] = interiorPoint(c,A,b,Aeq,beq)
%This interior Point Method solves a problem of the form
%       min c'*x
%       subject to
%           A*x <= b
%           Aeqx = beq

%% Variables

m = size(A,1) + size(Aeq,1);    %number of constrains
n = size(A,2);                  %number of variables
na = size(A,1);                 %number of slack variables

%Get together all restrictions
A = [A; Aeq];
b = [b; beq];

if m ~= length(b)
    disp('Number of elements in b and lines in A must be equal');
    return
end

if n ~= length(c)
    disp('Number of elements in c and columns in A must be equal');
    return
end

%Add slack variables
c = [c; zeros(na,1)];
A = [A eye(m,na)];

%Variables of the problem
x = zeros(n,1);
l = zeros(m,1);
s = zeros(n,1);

%Precision
eps = 10^-4;

%% Initial Solution (Heuristic)

%Initial values, satisfy the restrictions but not the 
aux = pinv(A*A');
x = A'*aux*b;
l = aux*A*c;
s = c - A'*l;

%Now values of x and s will be positive
x = x + max( -1.5*min(x), 0);
s = s + max( -1.5*min(s), 0);

%Garantee x0 and s0 are not too close to zero and not too dissimilar
x = x + ( 0.5*(x'*s)/sum(s) );
s = s + ( 0.5*(x'*s)/sum(x) );

%% Algorithm

%First mi
mi = x'*s;

%First eta
eta = 0.9;

while(1)
    
    %Jacobian Update
    J = [zeros(m,n)         A'              eye(m,1);
         A                  zeros(m,n)      zeros(m,n);
         S                  zeros(m,n)      X];
     
    %Get affine delta
    F = [ c-s-A'*l; b-A*x; -diag(x)*diag(s)*ones(n,1)];
    da = J\F;

    %Calculate the step length
    aux = da(1:n,1) < 0;
    ax = min(1, min(-x(aux)./da(aux,1)));
    aux = da((end-n+1):end,1) < 0;
    aux = [zeros(n+m,1) == 1; aux];
    as = min(1, min(-x(aux)./da(aux,1)));
    
    %Value of mi that will be obtained
    miaff = (x + ax*da(1:n,1))'*(s + ds*da((end-n+1):end,1))/n;
    
    %Centering parameter
    sigma = (miaff/mi)^3;
    mi = miaff;
    mi = x'*s;      %TESTE
    
    %Stop Criteria
    if mi < eps
        status = 'solved';
        break;
    end
    
    %Find the direction
    F((end-n+1):end, :) = F((end-n+1):end, :) + sigma*mi -...
                            diag(da(1:n,:))*diag(da((end-n+1):end,:));
    d = J\F;
    
    %Calculate the new step lengths
    aux = d(1:n,1) < 0;
    ax = min(1, min(-x(aux)./d(aux,1)));
    aux = d((end-n+1):end,1) < 0;
    aux = [zeros(n+m,1) == 1; aux];
    as = min(1, min(-x(aux)./d(aux,1)));
    
    %Finaly the step lengths
    eta = min(eta*1.01, 1);
    ax = min(1, eta*ax);
    as = min(1, eta*as);
    
   %Update the position
   x = x + ax*d(1:n,:);
   s = s + as*d((end-n):end,:);
   l = l + as*d((n+1):(n+m),:);
end

%Return the solution
x_opt = x;
f_opt = c'*x;
status = 'solved';

end

