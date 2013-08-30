function flag = isoctave
% ISOCTAVE   Checks whether the code is running in Octave
%   ISOCTAVE is returning the value TRUE if executed within the
%   Octave environment, else it is returning FALSE (e.g. when
%   called within Matlab.

% Copyright (c) 2013
% Norbert Marwan, Potsdam Institute for Climate Impact Research, Germany
% http://www.pik-potsdam.de
%
% $Date$
% $Revision$

a = ver('Octave');

if ~isempty(a) && strfind(a(1).Name,'Octave')
    flag = true;
else
    flag = false;
end
