clear all;
close all;
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
train_size = 60000;
test_size = 10000;
y_train = (y_train(1:train_size) == 4);
y_test = (y_test(1:test_size) == 4);
x_train = x_train(:,1:train_size);
x_test = x_test(:,1:test_size);

%%  Parameters

m = size(x_train,2);    %Number of training examples
n = size(x_train,1);    %Number of features
maxIter = 1000;
alpha = 1;              %Step lenght

%% Inicializations

w = 0.1*randn(n,1);           %Vector of weights
b = 0.1*randn(1);           %Vector of offsets

%% Gradient

% load('BestParameters_Class_n_4_2.mat')

disp('Optimizing...')
for k = 1:maxIter
    [J, dw, db] = costfnc( w, b, x_train, y_train );
    w = w - alpha*dw;
    b = b - alpha*db;
    k
    J
end

% save('BestParameters_Class_n_4_2','w','b');

%% Test the results

%Predict the values based on the test features
y_pred = sigmoid(w'*x_test+b) > 0.5;

%Calculate how many of the predictions is correct
correct = sum(y_pred' == y_test);
total = length(y_test);

%Accuracy of the prediction
accuracy = correct/total*100

%% Iterative prediction

return
load('MNISTdataset.mat')

for i = 1:test_size
    imshow(x_test(:,:,i));
    correct = y_test(i)
    pred = y_pred(i)
    pause
end


























