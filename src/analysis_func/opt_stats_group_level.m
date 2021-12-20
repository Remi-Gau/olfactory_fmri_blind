function opt = opt_stats_group_level()
    %
    % returns a structure that contains the options chosen by the user to run
    % slice timing correction, pre-processing, FFX, RFX...
    %
    % (C) Copyright 2021 Remi Gau
    
    opt = [];
    
    %   opt.dryRun = true;
    %   opt.model.designOnly = true;
    
    % The directory where the data are located
    opt.dir.dataset_root = fullfile(fileparts(mfilename('fullpath')), '..', '..', '..');
    opt.dir.raw = fullfile(opt.dir.dataset_root, 'inputs', 'raw');
    opt.dir.derivatives = fullfile(opt.dir.dataset_root, 'outputs', 'derivatives');
    opt.dir.preproc = fullfile(opt.dir.derivatives, 'cpp_spm-preproc');
    opt.dir.stats = fullfile(opt.dir.derivatives, 'cpp_spm-stats');
    opt.dir.roi = fullfile(opt.dir.derivatives, 'cpp_spm-roi');
    opt.dir.input = opt.dir.preproc;
    
    % task to analyze
    opt.taskName = {'olfid', 'olfloc'};
    
    opt.verbosity = 1;
    
    opt.space = {'MNI152NLin2009cAsym'};
    
    opt.fwhm.func = 6;
    opt.fwhm.contrast = 0;
    
    opt.pipeline.type = 'stats';
    
    opt.model.file = fullfile(fileparts(mfilename('fullpath')), ...
        'models', ...
        'model-defaultOlfidOlfloc_smdl.json');
    
    alpha = 0.05;
    minimum_cluster_size = 10;
    
    % Specify the result to compute
    opt.result.Nodes(1) = returnDefaultResultsStructure();
    opt.result.Nodes(1).Level = 'Dataset';
    opt.result.Nodes(1).Contrasts(1).Name = 'Responses';
    opt.result.Nodes(1).Contrasts(1).MC =  'none';
    opt.result.Nodes(1).Contrasts(1).p = alpha;
    opt.result.Nodes(1).Contrasts(1).k = minimum_cluster_size;
    opt.result.Nodes(1).Output = default_output(opt);
    
    % post setup
    raw = bids.layout(opt.dir.raw);
    opt.subjects = bids.query(raw, 'subjects');
    
    opt.subjects =  cellstr({'blnd01', 'blnd02', 'ctrl01', 'ctrl02'});
    
    opt = get_options(opt);
    
    opt.subjects = rm_subjects(opt.subjects, opt);
    
    opt = checkOptions(opt);
    saveOptions(opt);
    
end


function Output = default_output(opt)
    Output = struct('png', true, ...
        'csv', false,...
        'thresh_spm', false,...
        'binary', false,...
        'NIDM_results', false);
    Output.montage.do = true();
    Output.montage.slices = -27:3:48; % in mm
    Output.montage.orientation = 'axial';
    Output.montage.background = ...
        spm_select('FPList', ...
        fullfile(opt.dir.stats, 'group', 'images'), ...
        '.*desc-meanSmth6Masked_T1w.nii');
end