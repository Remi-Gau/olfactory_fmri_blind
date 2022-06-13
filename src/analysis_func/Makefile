# the path to matlab might need to be changed
# for this to work on your machine
MATLAB = /usr/local/MATLAB/R2017a/bin/matlab
ARG    = -nodisplay -nosplash -nodesktop

.PHONY:
run_all_models: step_2_run_all_models.m
	$(MATLAB) $(ARG) -r "run('step_2_run_all_models.m');exit;"

run_model_selection: step_2_model_selection.m
	$(MATLAB) $(ARG) -r "run('step_2_model_selection.m');exit;"

glm_subject: step_3_glm_subject.m
	$(MATLAB) $(ARG) -r "run('step_3_glm_subject.m');exit;"

glm_subject_roi: step_3_glm_subject_roi.m
	$(MATLAB) $(ARG) -r "run('step_3_glm_subject_roi.m');exit;"

glm_group: step_4_glm_group.m
	$(MATLAB) -r "run('step_4_glm_group.m');exit;"
