function [sets] = get_cfg_GLMS_to_run()
  % will load the sets of of GLM to compute at the subject level.
  % see set_all_GLMS for what each analytical choice corresponds to
  %
  % (C) Copyright 2021 Remi Gau

  % opt.explicit_mask = [0 1];
  sets{1} = 2;

  % opt.inc_mask_thres = [0.1 0.8];
  sets{2} = 1;

  % opt.HPF = 128; % high pass filter
  sets{3} = 1;

  % opt.time_der = [0 1];
  sets{4} = [2];
  % opt.disp_der = [0 1];
  sets{5} = [2];

  % opt.confounds = {...
  %     {'FramewiseDisplacement', 'WhiteMatter', 'CSF'}, ...
  %     {'X' 'Y' 'Z' 'RotX' 'RotY' 'RotZ'},...
  %     {'FramewiseDisplacement', 'WhiteMatter', 'CSF', 'X', 'Y', 'Z', 'RotX', 'RotY', 'RotZ'},...
  %     {'FramewiseDisplacement', 'WhiteMatter', 'CSF', 'X', 'Y', 'Z', 'RotX', 'RotY', 'RotZ' ...
  %         'tCompCor*'},...
  % trans_x, trans_x_derivative1, trans_x_derivative1_power2, trans_x_power2,
  % trans_y, trans_y_derivative1, trans_y_power2, trans_y_derivative1_power2,
  % trans_z, trans_z_derivative1, trans_z_power2, trans_z_derivative1_power2,
  % rot_x, rot_x_derivative1, rot_x_power2, rot_x_derivative1_power2,
  % rot_y, rot_y_derivative1, rot_y_derivative1_power2, rot_y_power2,
  % rot_z, rot_z_derivative1, rot_z_power2, rot_z_derivative1_power2
  sets{6} = 4;
  % opt.FD_censor.do = [0 1];
  sets{7} = [2];
  % opt.FD_censor.thres = [0.5 0.9];
  sets{8} = [2];

  % opt.FD_censor.nb = [1 3 5]; % FD threshold to censor points (in mm)
  sets{9} = 3;

  % opt.spher_cor = {'AR1' 'FAST' 'none'};
  sets{10} = [2];

end
