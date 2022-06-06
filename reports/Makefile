.PHONY: fmriprep/preprocessing.docx data_description.docx fmri_statistics.docx

fmriprep/preprocessing.docx:
	pandoc -i fmriprep/CITATION.md -o fmriprep/preprocessing.docx

data_description.docx:
	pandoc -i sub-ctrl01/dataset-raw_bids-matlab_report.md -o data_description.docx

fmri_statistics.docx:
	pandoc -i stats.md -o fmri_statistics.docx
