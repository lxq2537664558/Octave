## Copyright (C) 1996, 1997 John W. Eaton
##
## This file is part of Octave.
##
## Octave is free software; you can redistribute it and/or modify it
## under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 2, or (at your option)
## any later version.
##
## Octave is distributed in the hope that it will be useful, but
## WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
## General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with Octave; see the file COPYING.  If not, write to the Free
## Software Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
## 02110-1301, USA.

## -*- texinfo -*-
## @deftypefn {Function File} {} __bar__ (@dots{})
## Support function for @code{bar} and @code{hbar}. 
## @seealso{bar, hbar}
## @end deftypefn

## Author: jwe

function varargout = __bar__ (vertical, func, varargin)
  width = 0.8;
  group = true;

  if (nargin < 3)
    print_usage();
  endif

  if (nargin > 3 && isnumeric(varargin{2}))
    x = varargin{1};
    if (isvector(x))
      x = x(:);
    endif
    y = varargin{2};
    if (isvector(y))
      y = y(:);
    endif
    if (size(x,1) != size(y,1))
      y = varargin{1};
      if (isvector(y))
	y = y(:);
      endif
      x = [1:size(y,1)]';
      idx = 2;
    else
      if (! isvector(x))
	error ("%s: x must be a vector", func);
      endif
      idx = 3;
    endif
  else
    y = varargin{1};
    if (isvector(y))
      y = y(:);
    endif
    x = [1:size(y,1)]';
    idx = 2;
  endif
      
  newargs = {};
  HaveLineSpec = false;
  while (idx <= nargin -2)
    if (isstr(varargin{idx}) && strcmp(varargin{idx},"grouped"))
      group = true;
      idx++;
    elseif (isstr(varargin{idx}) && strcmp(varargin{idx},"stacked"))
      group = false;
      idx++;
    else
      if ((isstr(varargin{idx}) || iscell(varargin{idx})) && !HaveLineSpec)
	[dummy, valid] = __pltopt__ (func, varargin{idx}, false);
	if (valid)
	  HaveLineSpec = true;
	  newargs = [newargs,varargin(idx++)];
	  continue;
	endif
      endif
      if (isscalar(varargin{idx}))
	width = varargin{idx++};
      elseif (idx == nargin - 2)
	newargs = [newargs,varargin(idx++)];
      else
	newargs = [newargs,varargin(idx:idx+1)];
	idx += 2;
      endif
    endif
  endwhile

  xlen = size (x, 1);
  ylen = size (y, 1);

  if (xlen != ylen)
    error ("%s: length of x and y must be equal", func)
  endif
  if (any (x(2:end) < x(1:end-1)))
    error ("%s: x vector values must be in ascending order", func);
  endif

  ycols = size (y, 2);
  if (group)
    width = width / ycols;
  endif

  cutoff = (x(1:end-1) + x(2:end)) / 2;
  delta_p = [(cutoff - x(1:end-1)); (x(end) - cutoff(end))]  * width;
  delta_m = [(cutoff(1) - x(1)); (x(2:end) - cutoff)] * width;
  x1 = (x - delta_m)(:)';
  x2 = (x + delta_p)(:)';
  xb = repmat([x1; x1; x2; x2; NaN * ones(1,ylen)](:), 1, ycols);

  if (group)
    width = width / ycols;
    offset = ((delta_p + delta_m) * [-(ycols - 1) / 2 : (ycols - 1) / 2]);
    xb(1:5:5*ylen,:) += offset;
    xb(2:5:5*ylen,:) += offset;
    xb(3:5:5*ylen,:) += offset;
    xb(4:5:5*ylen,:) += offset;
    xb(5:5:5*ylen,:) += offset;
    y0 = zeros (size (y));
    y1 = y;
  else
    y1 = cumsum(y,2);
    y0 = [zeros(ylen,1), y1(:,1:end-1)];
  endif

  yb = zeros (5*ylen, ycols);
  yb(1:5:5*ylen,:) = y0;
  yb(2:5:5*ylen,:) = y1;
  yb(3:5:5*ylen,:) = y1;
  yb(4:5:5*ylen,:) = y0;
  yb(5:5:5*ylen,:) = NaN;

  if (vertical)
    if (nargout < 1)
      plot (xb, yb, newargs{:});
    elseif (nargout < 2)
      varargout{1} = plot (xb, yb, newargs{:});
    else
      varargout{1} = xb;
      varargout{2} = yb;
    endif
  else
    if (nargout < 1)
      plot (yb, xb, newargs{:});
    elseif (nargout < 2)
      varargout{1} = plot (yb, xb, newargs{:});
    else
      varargout{1} = yb;
      varargout{2} = xb;
    endif
  endif    

endfunction
