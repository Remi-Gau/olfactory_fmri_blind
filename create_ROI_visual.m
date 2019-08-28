% create visual ROIS

clear
clc

% based on the anatomy toolbox
% https://www.fz-juelich.de/SharedDocs/Downloads/INM/INM-1/DE/Toolbox/Toolbox_22c.html?nn=563092
MPM_img = fullfile(spm('dir'), 'toolbox', 'Anatomy', 'Anatomy_v22c.nii');
label_LUT = fullfile(spm('dir'), 'toolbox', 'Anatomy', 'Anatomy_v22c_MPM.txt');


% coding for each area
% Visual areas = 'hOC*

ROI_names = { ...
    'hOc1', ...
    'hOc2', ...
    'hOc3d', ...
    'hOc3v', ...
    'hOc4d', ...
    'hOc4v', ...
    'hOc5', ...
    'hOc4la', ...
    'hOc4lp'};

ROI_ref = { ...
    'V1'
    'V2'
    'V3d'
    'V3v'
    'V4d'
    'V4v'
    'V5'
    'LOa'
    'LOp'};

if ~exist(label_LUT, 'file')
    error('Did you install the spm Anatomy toolbox?')
end

FID = fopen(label_LUT);
FORMAT = ['%s' repmat('%f', [1, 22])];
C = textscan(FID, FORMAT, 'Headerlines', 1, 'Delimiter', '\t');
fclose(FID)


for iROI = 1:numel(ROI_names)
    ROI_idx = ~cellfun('isempty', strfind(C{1}, ROI_names{iROI}));
    C{1}(ROI_idx)
    C{3}(ROI_idx)
    ROIs_2_select(iROI).label = C{3}(ROI_idx); %#ok<*SAGROW>
    ROIs_2_select(iROI).name = ROI_ref{iROI};
end

%% read maximum probability map (sum both hemispheres)
hdr = spm_vol(MPM_img);
vol = spm_read_vols(hdr);
% correct offset of the anatomy toolbox
hdr.mat(2,4) = hdr.mat(2,4)+4;
hdr.mat(3,4) = hdr.mat(3,4)-5;



%% Create an image for each ROI and one that combines them all
all_rois = zeros(size(vol));

for i = 1:numel(ROIs_2_select)
    % save this ROI
    this_roi = zeros(size(vol));
    this_roi(vol==ROIs_2_select(i).label) = 1;
    hdr.fname = fullfile(pwd, 'inputs', ...
        ['ROI-' ROIs_2_select(i).name '_space-MNI.nii']);
    spm_write_vol(hdr, this_roi);
    
    % aupdate all ROIs
    all_rois(vol==ROIs_2_select(i).label) = 1;
end

% save all ROIs
hdr.fname = fullfile(pwd, 'inputs', 'ROI-AllVisual_space-MNI.nii');
spm_write_vol(hdr, all_rois);

