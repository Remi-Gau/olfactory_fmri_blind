clear
clc

% spm_path = '/home/remi-gau/Documents/SPM/spm12';
% addpath(spm_path)
spm('defaults','fmri')

addpath(genpath(fullfile(pwd, 'subfun')))

tgt_dir = 'D:\BIDS\olf_blind\raw';

bids =  spm_BIDS(tgt_dir);

%%
close all
out_dir = fullfile('output', 'figures', 'beh_avg');
mkdir(out_dir)

tasks = spm_BIDS(bids, 'tasks');
tasks(3) = [];

opt.visible = 'on';
opt.bin_size = 50;

group(1).name = 'blnd';
group(2).name = 'ctrl';

for iGroup = 1:numel(group)
    
    opt.group = group(iGroup).name;

for iTask = 1:numel(tasks)
    
    subjects = spm_BIDS(bids, 'subjects', ...
        'task', tasks{iTask});
    
    idx = strfind(subjects, {group(iGroup).name});
    idx = find(~cellfun('isempty', idx)); %#ok<STRCL1>
    
    subjects(idx)
    
    [all_stim, task] = average_beh(bids, tasks{iTask}, subjects(idx));
    
    opt.norm_resp = 0;
    make_figure(all_stim, task, opt)
    print(gcf, fullfile(out_dir, ...
        ['beh_grp-' group(iGroup).name '_task-' task '_binsize-' num2str(opt.bin_size) '_norm-0.jpg']), '-djpeg')
    
    opt.norm_resp = 1;
    make_figure(all_stim, task, opt)
    print(gcf, fullfile(out_dir, ...
        ['beh_grp-' group(iGroup).name '_task-' task '_binsize-' num2str(opt.bin_size) '_norm-1.jpg']), '-djpeg')
    
end

end