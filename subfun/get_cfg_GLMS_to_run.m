function [sets] = get_cfg_GLMS_to_run()
% will load the sets of of GLM to compute at the subject level.
% see set_all_GLMS for what each analytical choice corresponds to

% opt.inc_mask_thres = [0 0.8]; 
sets{1} = 2;

% opt.HPF = 128; % high pass filter
sets{2} = 1;

% opt.time_der = [0 1]; 
sets{3} = 2;
% opt.disp_der = [0 1]; 
sets{4} = 2;

% opt.confounds = {...
%     {'FramewiseDisplacement', 'WhiteMatter', 'CSF'}, ...
%     {'X' 'Y' 'Z' 'RotX' 'RotY' 'RotZ'},...
%     {'FramewiseDisplacement', 'WhiteMatter', 'CSF', 'X', 'Y', 'Z', 'RotX', 'RotY', 'RotZ'},...
%     {'FramewiseDisplacement', 'WhiteMatter', 'CSF', 'X', 'Y', 'Z', 'RotX', 'RotY', 'RotZ' ...
%         'tCompCor00', 'tCompCor01', 'tCompCor02', 'tCompCor03', 'tCompCor04', 'tCompCor05'},...
% trans_x, trans_x_derivative1, trans_x_derivative1_power2, trans_x_power2, 
% trans_y, trans_y_derivative1, trans_y_power2, trans_y_derivative1_power2, 
% trans_z, trans_z_derivative1, trans_z_power2, trans_z_derivative1_power2, 
% rot_x, rot_x_derivative1, rot_x_power2, rot_x_derivative1_power2, 
% rot_y, rot_y_derivative1, rot_y_derivative1_power2, rot_y_power2, 
% rot_z, rot_z_derivative1, rot_z_power2, rot_z_derivative1_power2
sets{5} = 3;
% opt.FD_censor.do = [0 1]; 
sets{6} = 2;
% opt.FD_censor.thres = 0.5; 
sets{7} = 1;

% opt.spher_cor = {'AR1' 'FAST' 'none'}; 
sets{8} = 2;
    
end