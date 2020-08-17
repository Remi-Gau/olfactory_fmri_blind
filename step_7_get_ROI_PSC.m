clear;

clc;

if ~exist('machine_id', 'var')
    machine_id = 2; % 0: container ;  1: Remi ;  2: Beast
end

% 'MNI' or  'T1w' (native)
if ~exist('space', 'var')
    space = 'T1w';
end

if ~exist('randomize', 'var')
    randomize = 1;
end

% event specification for getting fitted event time-courses
contrast_idx = 1 ;
event_session_no = repmat(1:4, 1, 4);
event_type_no = repmat([1:4]', 1, 4)';
event_spec = [event_session_no; event_type_no(:)'];
event_duration = 16; % default SPM event duration

% FOR INFO
% contrast_ls = {
%     'Euc-Left + Alm-Left + Euc-Right + Alm-Right > 0';
%     'Euc-Left + Alm-Left + Euc-Right + Alm-Right < 0'
%     'Euc-Left > 0';
%     'Euc-Left < 0';
%     'Alm-Left > 0';
%     'Alm-Left < 0';
%     'Euc-Right > 0';
%     'Euc-Right < 0';
%     'Alm-Right > 0';
%     'Alm-Right < 0';
%     'resp-03 > 0';
%     'resp-03 < 0';
%     'resp-12 > 0';
%     'resp-12 < 0'};

%%
% setting up directories
[data_dir, code_dir, output_dir, fMRIprep_DIR] = set_dir(machine_id);

% Set up the SPM defaults, just in case
addpath(fullfile(spm('dir'), 'toolbox', 'marsbar'));
% Start marsbar to make sure spm_get works
marsbar('on');

% get data info
bids =  spm_BIDS(fullfile(data_dir, 'raw'));

% get subjects
folder_subj = get_subj_list(output_dir);
folder_subj = cellstr(char({folder_subj.name}')); % turn subject folders into a cellstr
[~, ~, folder_subj] = rm_subjects([], [], folder_subj, true);
nb_subjects = numel(folder_subj);
group_id = ~cellfun(@isempty, strfind(folder_subj, 'ctrl')); %#ok<*STRCLFH>

% see what GLM to run
opt = struct();
[sets] = get_cfg_GLMS_to_run();
[opt, all_GLMs] = set_all_GLMS(opt, sets);

if randomize
    shuffle_subjs = randperm(length(group_id));
end

%% for each subject

time_course = {};
percent_signal_change = {};

for i_subj = 1:nb_subjects

    fprintf('running %s\n', folder_subj{i_subj});

    subj_dir = fullfile(output_dir, [folder_subj{i_subj}]);

    roi_src_folder = fullfile(data_dir, 'derivatives', 'ANTs', folder_subj{i_subj}, 'roi');

    roi_tgt_folder = fullfile(subj_dir, 'roi');
    mkdir(roi_tgt_folder);

    % list ROIs
    roi_ls =  spm_select('FPList', ...
        roi_src_folder, ...
        '^ROI-V1.*_space-T1w.nii$');
    roi_ls = cellstr(roi_ls);

    fprintf(' running GLMs\n');
    for i_GLM = 1:size(all_GLMs)

        cfg = get_configuration(all_GLMs, opt, i_GLM);

        cfg_list{i_GLM} = cfg;

        % directory for this specific analysis
        analysis_dir = name_analysis_dir(cfg, space);
        analysis_dir = fullfile ( ...
            output_dir, ...
            folder_subj{i_subj}, 'stats', analysis_dir);

        SPM = load(fullfile(analysis_dir, 'SPM.mat'));

        for i_roi = 1:size(roi_ls, 1)

            roi = roi_ls{i_roi};
            [path, file] = spm_fileparts(roi);

            % create ROI object for Marsbar and convert to matrix format to avoid delicacies of image format
            roi_obj = maroi_image(struct('vol', spm_vol(roi), 'binarize', 1, ...
                'func', []));
            roi_obj = maroi_matrix(roi_obj);
            % give it a label
            label(roi_obj, strrep(file, 'ROI-', ''));
            saveroi(roi_obj, fullfile(roi_tgt_folder, [file '_roi.mat']));

            D = mardo(SPM);

            % Extract data
            Y = get_marsy(roi_obj, D, 'mean');

            % MarsBaR estimation
            E = estimate(D, Y);

            % Get, store statistics
            stat_struct = compute_contrasts(E, contrast_idx);

            % And fitted time courses
            [tc, dt] = event_fitted(E, event_spec, event_duration);

            dt;

            % Get percent signal change
            psc = event_signal(E, event_spec, event_duration, 'abs max');

            % Make fitted time course into ~% signal change
            block_means(E);
            tc = tc / mean(block_means(E)) * 100;

            %             % Show calculated t statistics and contrast values
            %             % NB this next line only works when we have only one stat/contrast
            %             % value per analysis
            %             vals = [ [1 3]; [stat_struct(:).con]; [stat_struct(:).stat]; ];
            %             fprintf('Statistics for %s\n', label(roi));
            %             fprintf('Session %d; contrast value %5.4f; t stat %5.4f\n', vals);

            %             % Show fitted event time courses
            %             figure
            %             secs = [0:length(tc) - 1] * dt;
            %             plot(secs, tc)
            %             title(['Time courses for ' label(roi_obj)], 'Interpreter', 'none');
            %             xlabel('Seconds')
            %             ylabel('% signal change');

            time_course{i_roi, i_GLM}(i_subj, :) = tc; %#ok<SAGROW>
            percent_signal_change{i_GLM}(i_subj, i_roi) = psc;

        end
    end

    if randomize
        time_course{i_roi, i_GLM} = time_course{i_roi, i_GLM}(shuffle_subjs, :);
        percent_signal_change{i_GLM} = percent_signal_change{i_GLM}(shuffle_subjs);
    end

end

%% Show fitted event time courses
opt = get_option(opt);
Colors = [ ...
    opt.blnd_color / 255; ...
    opt.sighted_color / 255];
Colors_desat = Colors + (1 - Colors) * (1 - .3);

black = [0 0 0];

close all;
figure;
hold on;

secs = [0:size(time_course{1}, 2) - 1] * dt;

for i_group = 0:1

    data = time_course{1}(group_id == i_group, :);

    to_plot = mean(data);
    sem = std(data) / size(data, 1)^.5;

    plot(secs, data, 'color', Colors_desat(i_group + 1, :), 'linewidth', .5);

    shadedErrorBar(secs, to_plot, sem, ...
        {'color', Colors(i_group + 1, :), 'linewidth', 2}, 1);

end

title(['Time courses for V1'], 'Interpreter', 'none');
xlabel('Seconds');
ylabel('% signal change');
