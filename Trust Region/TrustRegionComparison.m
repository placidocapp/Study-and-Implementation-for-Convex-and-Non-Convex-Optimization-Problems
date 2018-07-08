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
how_choose_step = 1; %If 0 then choose the step with cauchy, else use 
                     %dogleg
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
for how_choose_step = 0:2
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
            pu(k,:) = - pinv(B(:,:,k))*g(x(k,:)');
            pb(k,:) = - gk'*gk/(aux)*gk;

            %Find tau
        if norm(pu(k,:)) <= delta(k)
            %In this case we go with the step pu
            tau(k) = 1;
        elseif norm(pb(k,:)) <= delta(k)
            %In this case we fint the tau that reaches the maximum alowable
            %distance, if the problem os right programmed till here we
            %could have 2 solutions or 1 solution. In the first case the
            %line between pu and pb cross the circle (the trust region) 2
            %times from outside for inside and for outside again, in this
            %case we should choose the one with tau < 2 to give preference
            %for the direction pu since pb could rise the solution value
            %sometimes and finaly if we have one solution we choose it even
            %if it's not positive
            sol = solve(norm( pu(k,:) + ...
                (tau_aux-1)*(pb(k,:) - pu(k,:)) )^2 == delta(k)^2, tau_aux);
            aux = eval(sol) > 0;
            if sum(aux) == 2
                aux2 = eval(sol) <= 2;
            else 
                aux2 = ones(2,1);
            end
            tau(k) = max(eval(sol).*aux.*aux2);
        else
            tau(k) = 2;
        end

            %Choose next path direction based on tau
            if tau(k) < 1
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
            ( m(x(k,:)',zeros(n,1)) - m(x(k,:)',p(k,:)') );
        if ro(k) < 0.25
            delta(k+1) = 0.25*delta(k);
        else
            if (ro(k) > 3/4 || norm(p(k)) == delta(k))
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
    subplot(2,1,1), plot(k,x_error), title('Error in position x'),hold on
    legend('Cauchy Point','Dogleg','Subproblem')
    subplot(2,1,2), plot(k,x_error), title('Error in function value'),hold on
    legend('Cauchy Point','Dogleg','Subproblem')
end
        
        
        
        
        
        
        
        
        
        