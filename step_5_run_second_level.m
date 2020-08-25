% runs group level on the olf blind data and export the results in the NIDM format

% there is an option to randomize the data between groups when doing a 2
% sample t-test to blind results

%% parameters
clc;
clear;

debug_mode = 0;

machine_id = 2; % 0: container ;  1: Remi ;  2: Beast

% to randomize between groups analysis (for blinding purposes)
randomize = 0;

space = 'MNI';

opt.task = {'olfid' 'olfloc'};
opt.grp_name = {'blnd', 'ctrl'};

opt.p = 0.05;
opt.k = 0;

% contrast name / directory name / ROI for inclusive mask
opt.ctrsts = { ...
    'resp-03 + resp-12 > 0', 'resp-03 + resp-12', 'ROI-hand_Z_.1_k_10_space-MNI.nii'; ...
    'Euc-Left + Alm-Left + Euc-Right + Alm-Right > 0', 'all (in visual ROIS)', 'ROI-AllVisual_space-MNI.nii'; ...
    'Euc-Left + Alm-Left + Euc-Right + Alm-Right > 0', 'all (in olfactory ROIS)', 'ROI-olfactory_Z_.1_k_10_space-MNI.nii'
    };

%%
contrast_ls = {
    'Euc-Left + Alm-Left + Euc-Right + Alm-Right > 0'
    'Euc-Left + Alm-Left + Euc-Right + Alm-Right < 0'
    'Alm-Left + Alm-Right > 0'
    'Alm-Left + Alm-Right < 0'
    'Euc-Left + Euc-Right > 0'
    'Euc-Left + Euc-Right < 0'
    'Euc-Right + Alm-Right > 0'
    'Euc-Right + Alm-Right < 0'
    'Euc-Left + Alm-Left > 0'
    'Euc-Left + Alm-Left < 0'
    'Euc-Left > 0'
    'Euc-Left < 0'
    'Alm-Left > 0'
    'Alm-Left < 0'
    'Euc-Right > 0'
    'Euc-Right < 0'
    'Alm-Right > 0'
    'Alm-Right < 0'
    'resp-03 + resp-12 > 0'
    'resp-03 + resp-12 < 0'};

%% setting up
% setting up directories
[data_dir, code_dir, output_dir, fMRIprep_DIR] = set_dir(machine_id);

% listing subjects
folder_subj = get_subj_list(output_dir);
folder_subj = cellstr(char({folder_subj.name}')); % turn subject folders into a cellstr

% remove excluded subjects
[~, ~, folder_subj] = rm_subjects([], [], folder_subj, true);
group_id = ~cellfun(@isempty, strfind(folder_subj, 'ctrl')); %#ok<*STRCLFH>
disp(folder_subj);

nb_subj = numel(folder_subj);

if ~exist('space', 'var')
    space = 'MNI';
end

if ~exist('randomize', 'var')
    randomize = 1;
end

%% figure out which GLMs to run
% set up all the possible of combinations of GLM possible given the
% different analytical options we have
[sets] = get_cfg_GLMS_to_run();
[opt, all_GLMs] = set_all_GLMS(opt, sets);

%%
for iGLM = 1:size(all_GLMs)

    %% get configuration for this GLM
    cfg = get_configuration(all_GLMs, opt, iGLM);

    % set output dir for this GLM configutation
    analysis_dir = name_analysis_dir(cfg, space);
    grp_lvl_dir = fullfile (output_dir, 'group', analysis_dir);
    mkdir(grp_lvl_dir);

    contrasts_file_ls = struct('con_name', {}, 'con_file', {});

    %% list the fields
    for isubj = 1:nb_subj

        subj_lvl_dir = fullfile ( ...
            output_dir, folder_subj{isubj}, 'stats', analysis_dir);

        fprintf('\nloading SPM.mat %s',  folder_subj{isubj});
        load(fullfile(subj_lvl_dir, 'SPM.mat'));

        %% Stores names of the contrast images
        for iCtrst = 1:numel(contrast_ls)

            contrasts_file_ls(isubj).con_name{iCtrst, 1} = ...
                SPM.xCon(iCtrst).name;

            contrasts_file_ls(isubj).con_file{iCtrst, 1} = ...
                fullfile(subj_lvl_dir, SPM.xCon(iCtrst).Vcon.fname);

            if ~exist(contrasts_file_ls(isubj).con_file{iCtrst, 1}, 'file')
                error('file not found');
            end

        end

    end

    for i_ttest = 1:size(opt.ctrsts, 1)

        ctrsts = opt.ctrsts(i_ttest, 1);

        disp(ctrsts);

        subdir_name = opt.ctrsts{i_ttest, 2};

        mask = fullfile(code_dir, 'inputs', opt.ctrsts{i_ttest, 3});

        %% ttest
        for iGroup = 1:numel(opt.grp_name)

            subj_to_include = find(group_id(1:nb_subj) == iGroup - 1);
            grp_name = opt.grp_name{iGroup};

            % identify the right con images for each subject to bring to
            % the grp lvl as summary stat

            [scans, con_names] = scans_for_grp_lvl(contrast_ls, ctrsts, contrasts_file_ls, subj_to_include);

            disp(grp_name);
            disp(con_names);
            disp(scans');

            matlabbatch = [];
            matlabbatch = set_ttest_batch(matlabbatch, ...
                fullfile(grp_lvl_dir, grp_name), ...
                scans, ...
                {subdir_name}, ...
                {'>'}, ...
                mask, opt);

            %             spm_jobman('run', matlabbatch)

            % rename NIDM output file
            %             NIDM_file = spm_select('FPList', ...
            %                 matlabbatch{1}.spm.stats.factorial_design.dir{1}, ...
            %                 '^spm.*.*nidm.*zip$');
            %             [path, file, ext] = spm_fileparts(NIDM_file);
            %             file = [grp_name, '_', strrep(ctrsts{1}, ' ', ''), '_', file]; %#ok<*AGROW>
            %             movefile(NIDM_file, fullfile(path, [file ext]))

            clear scans;
        end

        %% two sample ttest
        % identify the right con images for each subject to bring to
        % the grp lvl as summary stat
        for iGroup = 1:numel(opt.grp_name)
            subj_to_include = find(group_id(1:nb_subj) == iGroup - 1);
            [scans{iGroup, 1}, con_names] = scans_for_grp_lvl(contrast_ls, ctrsts, contrasts_file_ls, subj_to_include);

            disp(con_names);
        end

        % shuffle date from both groups to blind analysis
        if randomize
            tmp = cat(1, scans{1}', scans{2}');
            tmp = tmp(randperm(size(tmp, 1)), :);
            for iGroup = 1:numel(opt.grp_name)
                scans{iGroup} = cellstr(tmp(1:size(scans{iGroup}, 2), :))';
            end
        end

        % display
        for iGroup = 1:numel(opt.grp_name)
            disp(scans{iGroup}');
        end

        matlabbatch = [];
        matlabbatch = set_ttest_batch(matlabbatch, ...
            fullfile(grp_lvl_dir), ...
            scans, ...
            {subdir_name}, ...
            {'>'}, ...
            mask, opt);

        spm_jobman('run', matlabbatch);

        % rename NIDM output file
        NIDM_file = spm_select('FPList', ...
            matlabbatch{1}.spm.stats.factorial_design.dir{1}, ...
            '^spm.*.*nidm.*zip$');
        [path, file, ext] = spm_fileparts(NIDM_file);
        file = ['ts_ttest_', strrep(ctrsts{1}, ' ', ''), '_', file]; %#ok<*AGROW>
        movefile(NIDM_file, fullfile(path, [file ext]));

        clear scans;

    end

end
