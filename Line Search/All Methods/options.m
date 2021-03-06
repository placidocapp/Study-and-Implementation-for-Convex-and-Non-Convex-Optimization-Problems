function [opt] = options(algorithm,stepMethod,modHessMethod)
%Create a struct with the options for the algorithm
%algorithm     = 'newton', 'bfgs', 'dfp', 'sr1', 'gradient'
%stepMethod    = 'backtacking','wolfeCond','bisection'
%modHessMethod = 'norm2', 'cholesky'

%Default Structure
opt = struct(                              ...
    'Algorithm', 'bfgs',                   ...
    'Step_Length_Method','backtacking',     ...
    'Modified_Hessian_Method','cholesky');

if exist('algorithm','var')
    opt.Algorithm = algorithm;
end

if exist('stepMethod','var')
    opt.Step_Length_Method = stepMethod;
end

if exist('modHessMethod','var')
    opt.Modified_Hessian_Method = modHessMethod;
end

end

