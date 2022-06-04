function subjects = rm_subjects(subjects, opt)
  %
  % Removes the particpants from the subject listing that have been
  % excluded because of their func/anat/beh data
  %
  % (C) Copyright 2021 Remi Gau

  if  ~opt.rm_subjects.do
    return
  end

  to_rm = ismember(subjects, opt.rm_subjects.list);
  subjects(to_rm) = [];

end
