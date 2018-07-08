% Algorithm from Numerical Optimization. Jorge Nocedal and Stephen J. Wright.
% Second edition. This algorithm can be found at pages 69, and the way to
% choose pk can be found at pages 71-77
% MATLAB code by Pl�cido Campos

clear all;
close all;
clc

%%  Parameters

maxIter = 50;  %Maximun number of iterations
n = 4;          %Dimension of the problem   
eta = 0.20;     %Parameter that decides if the algorithm steps or not,
                %the book recomends it between (0,0.25)
how_choose_step = 1; %If 0 then choose the step with cauchy, if 1 use 
                     %dogleg else use the subproblem technique 
maxIterSub = 10;    %Max Iterations of the subproblem
eps = 10^-8;        %Stop criteria to Trust region subptoblem

%% Inicialization

p = zeros(maxIter,n);       %Direction of the step
ro = zeros(maxIter,1);      %rate of real decrease divided by estimatede decrease
x = zeros(maxIter,n);       %Actual point
x(1,:) = randn(1,n);
delta = zeros(maxIter,1);   %Radius of trust area
delta(1) = 1;
deltaMax = 4;
tau = zeros(maxIter,1);
B = zeros(n,n,maxIter);     %Hessian or modified hessian
k = 1;
pu = zeros(maxIter,n);      %Dogleg mehtod
pb = zeros(maxIter,n);      %Dogleg mehtod
syms tau_aux;               %Dogleg method
lambda = zeros(maxIterSub,1);  %Trust Region subproblem
lambda(1) = 1;
q = zeros(n,1);             %Trust Region subproblem

%% Function

%Function values
A = randn(n);
A = A'*A;
A = A'+ A;
b = randn(n,1);

%Calculate the function value and its derivatives
f = @(x) 0.5*x'*A*x + b'*x;
g = @(x) A*x + b;
H = @(x) A;

% f = @(x) sin(x(1))+sin(x(2));
% g = @(x) [cos(x(1));
%           cos(x(2))];
% H = @(x) [  -sin(x(1)) 0;
%             0          -sin(x(2))];


m = @(x,p) f(x) + g(x)'*p + 0.5*p'*B(:,:,k)*p;

%% Algorithm

for k = 1:maxIter
    %% Calculate the values of gradient and hessian
    B(:,:,k) = H(x(k,:)');
    gk = g(x(k,:)');
    fk = f(x(k,:)');
    
    %Check if B is semidefinite positive, if not then correct it with
    %modified cholesky factorization
    if sum(eig(B(:,:,k)) < 0) > 0
        [L,D] = mcfac(B(:,:,k));
        B(:,:,k) = L*D*L';
    end
    
    %% Solve argmin mk(p) to find pk
    aux = gk'*B(:,:,k)*gk;
    %Cauchy algorithm
    if how_choose_step == 0
        if aux >= 0
            tau(k) = 1;
        else 
            tau(k) = min( 1, norm(gk)^3/(delta(k)*aux) );
        end
        p(k,:) = - tau(k)*delta(k)*gk/norm(gk);
    elseif how_choose_step == 1
        %Dogleg Method from Numerical optimization page 87
        pu(k,:) = - gk'*gk/(aux)*gk;
        pb(k,:) = - pinv(B(:,:,k))*gk;

        %Find tau
        if norm(pu(k,:)) > delta(k)
            %If pu is already bigger than the trust regian then choose tau
            %to the limit
            tau(k) = delta(k)/norm(pu(k,:));
        elseif norm(pb(k,:)) <= delta(k)
            %if pb is inside the trust region than we can go with it
            tau(k) = 2;
        else
            %If tau is between 1 and 2 then we find the maximum feasible
            %tau
            sol = solve(norm( pu(k,:) + ...
                (tau_aux-1)*(pb(k,:) - pu(k,:)) )^2 == delta(k)^2, tau_aux);
            res = eval(sol)
            tau(k) = max(eval(sol));
        end
    
        %Choose next path direction based on tau
        if tau(k) <= 1
            p(k,:) = tau(k)*pu(k,:);
        else 
            p(k,:) = pu(k,:) + (tau(k) - 1)*( pb(k,:) - pu(k,:) );
        end
    else
        %Trust Region Subproblem
        for i = 1:maxIterSub
            %If B + lambda*I <= 0 than correct lambda
            aux2 = eig(B(:,:,k)+lambda(i)*eye(n));
            if sum(aux2 < 0) > 0
                lambda(i) = lambda(i)-min(aux2)+eps;
            end
                
            R = chol(B(:,:,k)+lambda(i)*eye(n));
            p(k,:) = -pinv(R'*R)*gk;
            q = pinv(R')*p(k,:)';
            lambda(i+1) = lambda(i) + ( norm(p(k,:))/norm(q) )^2*...
            ( ( norm(p(k,:))-delta(k) )/delta(k) ); 
            
            %Stop creteria
            if abs(lambda(i+1) - lambda(i)) < eps
                break
            end
        end
        %Gess the initial lambda equals to the last one
        lambda(1) = lambda(i);
    end
    %% Decide to step or to rise/decrease the area delta
    
    %Evaluate ro(k)
    ro(k) = ( fk - f(x(k,:)'+p(k,:)') )/...
        ( m(x(k,:)',zeros(n,1)) - m(x(k,:)',p(k,:)') +10^-6);
    
    %Correct the case when both increase, just happens with dogleg
%     if (fk - f(x(k,:)'+p(k,:)') < 0) || ro(k) > 0        
%         disp('Entrou')
%         ro(k) = -ro(k);      
%     end
    
    if ro(k) < 0.25
        delta(k+1) = 0.25*delta(k);
    else
        if (ro(k) > 3/4 || norm(p(k,:)) > delta(k) - 10^-6)
            delta(k+1) = min(2*delta(k), deltaMax);
        else
            delta(k+1) = delta(k);
        end
    end
    
    %Decide to take the step or not
    if ro(k) > eta
        x(k+1,:) = x(k,:) + p(k,:);
    else
        x(k+1,:) = x(k,:);
    end
    k
end
        
x(end,:)
f(x(end,:)')
sol = -(pinv(A)*b)'

%% Plot some graphs
x_error = zeros(maxIter,1);
f_error = zeros(maxIter,1);
for i = 1:maxIter
    x_error(i) = norm(sol) - norm(x(i,:));
    f_error(i) = f(sol') - f(x(i,:)');
end

k = 1:maxIter;
subplot(2,1,1), plot(k,x_error), title('Error in position x')
subplot(2,1,2), plot(k,f_error), title('Error in function value')
        
        
        
        
        
        
        
        
        
        
        