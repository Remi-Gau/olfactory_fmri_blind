function opt = get_options(opt)
  %
  % set some options for the analysis and plotting of the behavioral results.
  %
  % (C) Copyright 2021 Remi Gau

  opt.samp_freq = 25;
  opt.timecourse_dur = 280;

  opt.RT = 0.785;
  opt.nb_dummies = 8;
  opt.nb_vol = 295;

  opt.trial_type = {'ch1', ...
                    'ch3', ...
                    'ch5', ...
                    'ch7', ...
                    'resp_03', ...
                    'resp_12'};

  opt.rm_subjects.do = true;
  opt.rm_subjects.list = {'blnd04', 'ctrl04', 'ctrl07'}';

  opt.stim_color = {'-g'; ...  % Eucalyptus Left
                    '-r'; ... % Almond Left
                    '--g'; ...  % Eucalyptus Right
                    '--r'};    % Almond Right

  % color used to plot the stimuli
  opt.stim_color_mat = [ ...
                        0 1 0
                        1 0 0
                        0 1 0
                        1 0 0];

  % linestyle for plotting the stimuli
  opt.stim_linestyle = {'-', ...
                        '-', ...
                        '--', ...
                        '--'};

  opt.stim_legend = {'Euc - Left'; ...
                     'Alm - Left'; ...
                     'Euc - Right'; ...
                     'Alm - Right'};

  opt.blnd_color = [255 158 74];
  opt.sighted_color = [105 170 153];

end
