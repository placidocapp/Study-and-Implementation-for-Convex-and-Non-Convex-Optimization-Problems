function [ y ] = df( x )
%   Derivative of the function to solve
% y = 4*x + (5420896949983055*conj(x))/1125899906842624 + x^3*((153933462881711*conj(x))/140737488355328 + (16744969452561441*conj(x)^2)/1125899906842624 + 627122237356493/2251799813685248) + (8158648460577917*conj(x)^2)/9007199254740992 + (1143795557080799*conj(x)^3)/9007199254740992 + x*((8158648460577917*conj(x))/4503599627370496 + (3431386671242397*conj(x)^2)/9007199254740992 + 5420896949983055/1125899906842624) + 3*x^2*((627122237356493*conj(x))/2251799813685248 + (153933462881711*conj(x)^2)/281474976710656 + (5581656484187147*conj(x)^3)/1125899906842624) + 2*x*((8226958330713791*conj(x))/9007199254740992 + (1303893210946689*conj(x)^2)/281474976710656 + (109820732902227*conj(x)^3)/1125899906842624) + x^2*((1303893210946689*conj(x))/140737488355328 + (329462198706681*conj(x)^2)/1125899906842624 + 8226958330713791/9007199254740992) + 9*x^2 + 1;
% y = 2*x;
% y = cos(x);
y = 2*x + 3;
 
end

