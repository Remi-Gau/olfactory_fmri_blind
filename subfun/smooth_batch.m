function smooth_batch(FWHM, prefix, folder_path, filter)

tic

% Check about 'FWHM' var input
if ~exist('FWHM', 'var')
    FWHM = [8 8 8];
    fprintf('\n- FWHM set to 8 mm as default\n')
else
    fprintf('\n- FWHM set to %d mm\n', FWHM)
end

% Check about 'prefix' var input
if ~exist('prefix', 'var')
    fprintf('\n- "prefix" not provided, set to "s" as default\n')
    prefix = 's';
else fprintf('\n- "prefix" of the smoothed data is %s\n', prefix); %#ok<*SEPEX>
end

% Check about 'folder_path' var input
if ~exist('folder_path', 'var')
    folder_path = pwd;
    fprintf('\n- Folder path not provided, I assume we are in the data folder\n')
elseif ~exist(folder_path, 'dir')
    error('-The path is not a folder, please insert a valid folder path')
else fprintf('\n- I will look for data to smooth here %s\n', folder_path);
end

% Filter only the func data to smooth
if ~exist('filter', 'var')
    filter =  'sub-.*space-MNI152.*preproc.nii$';
    fprintf('\n- filter not provided, set to %s as default\n', filter)
else fprintf('\n- "filter" of the smoothed data is %s\n', filter);
end


% Get subject list and folders
folder_subj = get_subj_list(folder_path);

% Loop across folder and unpack .gz files
parfor isubj = 1 : length(folder_subj)

    tic

    matlabbatch = [];

    fprintf('\nProcessing Subject n. %d of %d\n\n',isubj, size(folder_subj,1))
    % Build subj folder path
    folder_files = fullfile(folder_path, folder_subj(isubj).name, 'func');
    % Make a list of the file in it with '.gz' extension
    file_list = cellstr(spm_select('ExtFPList', folder_files, filter, Inf));

    if isempty(file_list)
        warning('no file to smooth for subject %s', folder_subj(isubj).name)
    elseif size(file_list,1)<4
        warning('some files are missing from subject %s', folder_subj(isubj).name)
    else
        % Create the batch
        matlabbatch{1}.spm.spatial.smooth.data   = cellstr(file_list);
        matlabbatch{1}.spm.spatial.smooth.fwhm   = [ FWHM FWHM FWHM ];
        matlabbatch{1}.spm.spatial.smooth.dtype  = 0;
        matlabbatch{1}.spm.spatial.smooth.prefix = prefix;

        save_the_job(matlabbatch, folder_files, folder_subj(isubj).name);

        spm_jobman('run',matlabbatch);
    end

    toc

end

toc

end


function save_the_job(matlabbatch, folder_files, folder_subj_name) %#ok<INUSL>
job_name = fullfile(folder_files,['job_' folder_subj_name '_smoothing.mat' ]);
save(job_name, 'matlabbatch')
end
