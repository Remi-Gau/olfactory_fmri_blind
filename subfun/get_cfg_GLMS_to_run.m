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
sets{5} = 1;
% opt.FD_censor.do = [0 1]; 
sets{6} = 1;
% opt.FD_censor.thres = 0.5; 
sets{7} = 1;

% opt.spher_cor = {'AR1' 'FAST' 'none'}; 
sets{8} = 2;
    
end