function run_spm(file)

% function run_spm(file)
% file - input file consisting of scanIDs(top-level directory), one per line
% Passes scanID to run_spm_manual, starting point of SPM fMRI-REST task pre-processing pipeline

fid = fopen(file);
line = fgetl(fid);
while ischar(line)
	line = str2num(line);
	run_spm_manual(line);
	line = fgetl(fid);
end
fclose(fid)
