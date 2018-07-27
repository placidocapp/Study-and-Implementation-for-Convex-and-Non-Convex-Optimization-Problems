close all;
clear all;
clc

%% Load dataset

disp('Loading data ...')

%We recive here the pictures in x and labels in y. The variables are
%x_train, y_train, x_test and y_test. For trainning
load('MNISTdataset.mat')

% Now to work on the data I will transform each pixel in one feature, so I
% will change the format of the matrices x_train and x_test
x_train = reshape(x_train,[400 60000]);
x_test = reshape(x_test,[400 10000]);

%The logistic regression can only classify into two different groups, so i
%will modify the original y 
train_size = 100;
test_size = 50;
y_train = y_train(1:train_size);
y_test = y_test(1:test_size);
x_train = x_train(:,1:train_size);
x_test = x_test(:,1:test_size);

%% Change the format of y

%Here we need that for each example the y variable become a column with
%10 values, just one for the respective number (from 0 to 9) and zeros
%for the others
aux = zeros(10,train_size);
for i = 1:train_size
    aux(:,i) = (0:9)'==y_train(i);
end
y_train = aux;

%%  Parameters

%For the main loop
ChooseMethod = 4;   %if 0 uses batch gradient, if 1 uses mini batch 
                    %gradient (note that if the mini batch has size 1 it's 
                    %a sthocastic gradient descent). if 2 use batch
                    %gradient with momentum.if 3 use desterov method
                    
maxIter = 1000;     %Stop creteria
grad_eps = 10^-10;  %Stop creteria
m = size(x_train,2);    %Number of training examples
n = size(x_train,1);    %Number of features

%The neural network have just 3 layers, but one can change the size of
%them
nlayers = 3;            %Number of layers
layers = [ n; 20; 20; 10 ]; %Size of each layer, the first layer is the                             
                            %number of features itself
activation = 'sigmoid';     %Activation function for all but the last layer 

%Gradients step length
alpha = 0.3;              %Step lenght

%Batch gradient
batch_size = 5;

%In case we want batch gradient descent the batch_size is m
if ChooseMethod == 0
    batch_size = m;
end

%Momentum
lambda = 0.9;

%Adagrad
forget_rate = 0.8;
                       
%% Initializations
rng(157024)
w1 = 0.1*randn(layers(2), layers(1));
w2 = 0.1*randn(layers(3), layers(2));
w3 = 0.1*randn(layers(4), layers(3));
b1 = 0.1*randn(layers(2),1);
b2 = 0.1*randn(layers(3),1);
b3 = 0.1*randn(layers(4),1);
J = zeros(maxIter,1);

%Variable for momentum
u1 = zeros(size(w1));
u2 = zeros(size(b1));
u3 = zeros(size(w2));
u4 = zeros(size(b2));
u5 = zeros(size(w3));
u6 = zeros(size(b3));

%Variables for best sol
best_J = 10^10;
best_w1 = zeros(size(w1));
best_w2 = zeros(size(w2));
best_w3 = zeros(size(w3));
best_b1 = zeros(size(b1));
best_b2 = zeros(size(b2));
best_b3 = zeros(size(b3));

%Variables for Adagrad
Gw1 = zeros(size(w1,1),size(w1,1))
Gb1 = zeros(size(b1,1),size(b1,1));
Gw2 = zeros(size(w2,1),size(w2,1));
Gb2 = zeros(size(b2,1),size(b2,1));
Gw3 = zeros(size(w3,1),size(w3,1));
Gb3 = zeros(size(b3,1),size(b3,1));

%% Algorithm

tic
for k = 1:maxIter
    %% Batch sizes
    
    %Next Batch 
    batch = 1:m;
    batch = batch(randperm(length(batch))); %Shuffle the batch
    batch = batch(1:batch_size);

    %% Function value and it's derivatives
    %Calculate the function value and derivatives with foward and back
    %propagation
    J(k) = fcost( w1, b1, w2, b2, w3, b3, x_train,...
        y_train, activation );
    
    %If the we need the nesterov method we need to choose the gradient for
    %a point ahead, otherwise we use regular gradient
    if ChooseMethod == 3
        [ dw1, db1, dw2, db2, dw3, db3 ] = fgrad( w1-lambda*u1...
            , b1-lambda*u2, w2-lambda*u3, b2-lambda*u4, w3-lambda*u5...
            , b3-lambda*u6, x_train,...
            y_train, activation, batch );
    else
        [ dw1, db1, dw2, db2, dw3, db3 ] = fgrad( w1, b1, w2, b2, w3, b3, x_train,...
            y_train, activation, batch );
    end
    k
    kcost = J(k)      %Uncoment to see the evolution of cost

    %% Save the best solution
    if J(k) < best_J
        best_J = J(k);
        best_w1 = w1;
        best_w2 = w2;
        best_w3 = w3;
        best_b1 = b1;
        best_b2 = b2;
        best_b3 = b3;
    end
    
    %% Gradient methods
    if ChooseMethod == 0 || ChooseMethod == 1
        % Mini Batch Gratient descent
        w1 = w1 - alpha*dw1;
        b1 = b1 - alpha*db1;
        w2 = w2 - alpha*dw2;
        b2 = b2 - alpha*db2;
        w3 = w3 - alpha*dw3;
        b3 = b3 - alpha*db3;
        
        %One can decrease the alpha value on each iteration, it's good for
        %stochastic gradient descent
        alpha = alpha*0.999;
    elseif ChooseMethod == 2
        % Momentum gradient descent
        %Update the momentum variable
        u1 = lambda*u1 + alpha*dw1;
        u2 = lambda*u2 + alpha*db1;
        u3 = lambda*u3 + alpha*dw2;
        u4 = lambda*u4 + alpha*db2;
        u5 = lambda*u5 + alpha*dw3;
        u6 = lambda*u6 + alpha*db3;
        
        %Update the weights points
        w1 = w1 - u1;
        b1 = b1 - u2;
        w2 = w2 - u3;
        b2 = b2 - u4;
        w3 = w3 - u5;
        b3 = b3 - u6;
    elseif ChooseMethod == 3
        %Nesterov Gradient descent
        %Update the momentum variable
        u1 = lambda*u1 + alpha*dw1;
        u2 = lambda*u2 + alpha*db1;
        u3 = lambda*u3 + alpha*dw2;
        u4 = lambda*u4 + alpha*db2;
        u5 = lambda*u5 + alpha*dw3;
        u6 = lambda*u6 + alpha*db3;
        
        %Update the weights points
        w1 = w1 - u1;
        b1 = b1 - u2;
        w2 = w2 - u3;
        b2 = b2 - u4;
        w3 = w3 - u5;
        b3 = b3 - u6;
    elseif ChooseMethod == 4
        %Adagrad Gradient Descent
        %Auxiliar variable G
        Gw1 = Gw1*forget_rate + dw1*dw1';
        Gb1 = Gw1*forget_rate + db1*db1';
        Gw2 = Gw2*forget_rate + dw2*dw2';
        Gb2 = Gw2*forget_rate + db2*db2';
        Gw3 = Gw3*forget_rate + dw3*dw3';
        Gb3 = Gw3*forget_rate + db3*db3';
        
        %Update
        w1 = w1 - alpha/diag(Gw1).*dw1;
        b1 = b1 - alpha/diag(Gb1).*db1;
        w2 = w2 - alpha/diag(Gw2).*dw2;
        b2 = b2 - alpha/diag(Gb2).*db2;
        w3 = w3 - alpha/diag(Gw3).*dw3;
        b3 = b3 - alpha/diag(Gb3).*db3;
    end
    
    %% Stop creteria
    norm([norm(dw1) norm(db1) norm(dw2) norm(db2) norm(dw3) norm(db3)])
    if norm([norm(dw1) norm(db1) norm(dw2) norm(db2) norm(dw3) norm(db3)])...
            <= grad_eps
        break;
    end
end
time = toc

%Before prediction uses the best values achived
w1 = best_w1;
w2 = best_w2;
w3 = best_w3;
b1 = best_b1;
b2 = best_b2;
b3 = best_b3;

%% Prediction

y_pred = zeros(test_size,1);

for i = 1:test_size
    
    %Foward propagation
    z1 = w1*x_test(:,i) + b1;
    a1 = g(z1, activation);
    z2 = w2*a1 + b2;
    a2 = g(z2, activation);
    z3 = w3*a2 + b3;
    a3 = g(z3, 'sigmoid');

    %Transform in numbers again
    [aux, val] = max(a3);
    y_pred(i) = val - 1;

end

correct = sum(y_pred == y_test);
accuracy = correct/test_size

save('MiniBatchGradientWithAdagrad_100','J','time','accuracy','best_J')

%% Plot comparisson for 10000 training examples

clear all

%Load the Batch gradient
load('BatchGradient.mat')
Time_Optimizing = time;
Accuracy = accuracy;
Best_Sol = best_J;
plot(J), hold on

%Load the Stochastic gradient
load('Stochastic gradient descent.mat')
Time_Optimizing = [Time_Optimizing; time];
Accuracy = [Accuracy; accuracy];
Best_Sol = [Best_Sol; best_J];
plot(J)

%Load the Mini Batch gradient
load('MiniBatchGradient.mat')
Time_Optimizing = [Time_Optimizing; time];
Accuracy = [Accuracy; accuracy];
Best_Sol = [Best_Sol; best_J];
plot(J)

%Load the Mini Batch gradient with momentum
load('MiniBatchGradientWithMomentum.mat')
Time_Optimizing = [Time_Optimizing; time];
Accuracy = [Accuracy; accuracy];
Best_Sol = [Best_Sol; best_J];
plot(J)

%Load the Mini Batch gradient with nesterov
load('MiniBatchGradientWithNesterov.mat')
Time_Optimizing = [Time_Optimizing; time];
Accuracy = [Accuracy; accuracy];
Best_Sol = [Best_Sol; best_J];
plot(J)

Method = {'Batch Gradient'; 'Stochastic gradient';'Mini Batch Gradient';...
    'Mini Batch Gradient With Momentum';'Mini Batch Gradient With Nesterov'};
legend(Method)
table(Method, Time_Optimizing, Accuracy, Best_Sol)

%% Plot comparisson for 100 training examples

clear all
figure()

%Load the Batch gradient
load('BatchGradient_100.mat')
Time_Optimizing = time;
Accuracy = accuracy;
Best_Sol = best_J;
plot(J), hold on

%Load the Stochastic gradient
load('StochasticGradientDescent_100.mat')
Time_Optimizing = [Time_Optimizing; time];
Accuracy = [Accuracy; accuracy];
Best_Sol = [Best_Sol; best_J];
plot(J)

%Load the Mini Batch gradient
load('MiniBatchGradient_100.mat')
Time_Optimizing = [Time_Optimizing; time];
Accuracy = [Accuracy; accuracy];
Best_Sol = [Best_Sol; best_J];
plot(J)

%Load the Mini Batch gradient with momentum
load('MiniBatchGradientWithMomentum_100.mat')
Time_Optimizing = [Time_Optimizing; time];
Accuracy = [Accuracy; accuracy];
Best_Sol = [Best_Sol; best_J];
plot(J)

%Load the Mini Batch gradient with nesterov
load('MiniBatchGradientWithNesterov_100.mat')
Time_Optimizing = [Time_Optimizing; time];
Accuracy = [Accuracy; accuracy];
Best_Sol = [Best_Sol; best_J];
plot(J)

%Load the Mini Batch gradient with nesterov
load('MiniBatchGradientWithAdagrad_100.mat')
Time_Optimizing = [Time_Optimizing; time];
Accuracy = [Accuracy; accuracy];
Best_Sol = [Best_Sol; best_J];
plot(J)

Method = {'Batch Gradient'; 'Stochastic gradient';'Mini Batch Gradient';...
    'Mini Batch Gradient With Momentum';'Mini Batch Gradient With Nesterov'...
    ;'Mini Batch Gradient With Adagrad'};
legend(Method)
table(Method, Time_Optimizing, Accuracy, Best_Sol)