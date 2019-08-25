% create visual ROIS based on retinotoic atlased from Kastner's lab

% URL = 'http://scholar.princeton.edu/sites/default/files/napl/files/probatlas_v4.zip';
unzip(fullfile(pwd, 'inputs', 'probatlas_v4.zip'), fullfile(pwd, 'inputs'));
gunzip(fullfile(pwd, 'inputs', 'ProbAtlas_v4', 'subj_vol_all', 'maxprob_vol_*h.nii.gz'), fullfile(pwd, 'inputs'));


% coding for each area
% 01 , ... V1v	    
% 02 , ... V1d	   
% 03 , ... V2v	   
% 04 , ... V2d	   
% 05 , ... V3v	    
% 06 , ... V3d	    
% 07 , ... hV4	  
% 08 , ... VO1	    
% 09 , ... VO2	    
% 10 , ... PHC1	    
% 11 , ... PHC2	    
% 12 , ... MST	    
% 13 , ... hMT	   
% 14 , ... LO2	    
% 15 , ... LO1	   
% 16 , ... V3b	    
% 17 , ... V3a	  
% 18 , ... IPS0	   
% 19 , ... IPS1	    
% 20 , ... IPS2	    
% 21 , ... IPS3	  
% 22 , ... IPS4	  
% 23 , ... IPS5	  
% 24 , ... SPL1	 
% 25 , ... FEF

ROI_names = { ...
'V1v'
'V1d'
'V2v'
'V2d'
'V3v'
'V3d'
'hV4'
'VO1'
'VO2'
'PHC1'
'PHC2'
'MST'
'hMT'
'LO2'
'LO1'
'V3b'
'V3a'};

for iROI = 1:numel(ROI_names)
    ROIs_2_select(iROI).label = iROI; %#ok<*SAGROW>
    ROIs_2_select(iROI).name = ROI_names{iROI};
end

%% read maximum probability map (sum both hemispheres)
files =  spm_select('FPList', fullfile(pwd, 'inputs'), '^maxprob_vol_.*h.nii$');
hdr = spm_vol(files);
vol = spm_read_vols(hdr);
vol = sum(vol,4);

%% Create an image for each ROI and one that combines them all
hdr = hdr(1);

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

