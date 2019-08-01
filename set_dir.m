function [data_dir, code_dir, output_dir, fMRIprep_DIR] = set_dir(machine_id)
% Returns directory to work with depending on which computer/container we
% are on

if nargin<1
    machine_id = 0;
end

switch machine_id
    case 0 % container
        % containers
        data_dir = '/data';
        code_dir = '/code';
        output_dir = '/output/derivatives/spm12';
        addpath(fullfile('/opt/spm12'));
    case 1 % windows matlab/octave : Remi
        code_dir = 'D:\github\chem_sens_blind';
        data_dir = 'D:\BIDS\olf_blind\raw';
        output_dir = fullfile(data_dir, 'derivatives', 'spm12');
    case 2 % mac matlab/octave : Chris
        error('directory paths not set up');
        code_dir = '';% ???????
        data_dir = '';% ???????
        output_dir = fullfile(data_dir, 'derivatives', 'spm12');
end

% add subfunctions to path
[~]  = addpath(fullfile(code_dir,'subfun'));

% define derivatives fMRIprep dir
fMRIprep_DIR = fullfile(data_dir, 'derivatives', 'fmriprep');
end
