% (C) Copyright 2021 Remi Gau

opt = options();

opt.dir.mriqc = '/home/remi/gin/olfaction_blind/mriqc';

mriqcQA(opt, 'T1w');
mriqcQA(opt, 'bold');
