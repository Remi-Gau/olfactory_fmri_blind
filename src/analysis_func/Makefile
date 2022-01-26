# the path to matlab might need to be changed
# for this to work on your machine
MATLAB = /usr/local/MATLAB/R2017a/bin/matlab
ARG    = -nodisplay -nosplash -nodesktop

.PHONY:
run_all_models: step_4_run_all_models.m
	$(MATLAB) $(ARG) -r "run('step_4_run_all_models.m');exit;"

run_model_selection: step_5_model_selection.m
	$(MATLAB) $(ARG) -r "run('step_5_model_selection.m');exit;"	
