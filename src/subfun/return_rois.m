function ROIs = return_rois(model_type)
  %
  % Return list of ROI names to run a specific model on
  %

  % (C) Copyright 2022 Remi Gau

  switch lower(model_type)
    case 'default'
      ROIs = {'Broadmann28Ento'
              'Broadmann34Piriform'
              'Hippocampus'
              'Insula'
              'OFCant'
              'OFClat'
              'OFCmed'
              'OFCpost'
              'ACC'
              'Thalamus'
              'Amygdala'};

    case 'tissueconfounds'
      ROIs = {'V1'
              'V2'
              'V3'
              'hV4'
              'hMT'
              'VO1'
              'VO2'
              'LO2'
              'LO1'
              'auditory'
              'hand'
              'S1'
              'IPS'
              'pons'
              'midbrain'};
  end
end
