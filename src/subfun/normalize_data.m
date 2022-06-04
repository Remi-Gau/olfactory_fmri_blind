function to_plot = normalize_data(to_plot)
  %
  % (C) Copyright 2021 Remi Gau

  for iRow = 1:size(to_plot, 1)
    to_plot(iRow, :) = to_plot(iRow, :) / sum(to_plot(iRow, 1:end));
  end
end
