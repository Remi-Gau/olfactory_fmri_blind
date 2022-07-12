function C = cartesian(varargin)
  %
  %
  %
  % USAGE::
  %
  %     C = cartesian(varargin)
  %
  %
  % Example::
  %
  %     C = cartesian(1:2, 3:5, 3:8)
  %
  % (C) Copyright 2022 Remi Gau

  args = varargin;
  n = nargin;

  [F{1:n}] = ndgrid(args{:});

  for i = n:-1:1
    G(:, i) = F{i}(:);
  end

  C = unique(G, 'rows');

end
