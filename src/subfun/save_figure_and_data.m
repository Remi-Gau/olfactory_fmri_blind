function save_figure_and_data(output_dir, main_title, data_to_save)
  %
  % (C) Copyright 2023 Remi Gau

  mtit(sprintf('%s', main_title), ...
       'fontsize', 16, ...
       'xoff', 0, ...
       'yoff', 0.04);

  output_file = fullfile(output_dir, [strrep(main_title, ' - ', '_'), '.png']);
  print(gcf, '-dpng', output_file);
  output_file = fullfile(output_dir, [strrep(main_title, ' - ', '_'), '.svg']);
  print(gcf, '-dsvg', output_file);
  output_file = fullfile(output_dir, [strrep(main_title, ' - ', '_'), '.tsv']);
  bids.util.tsvwrite(output_file, data_to_save);

end
