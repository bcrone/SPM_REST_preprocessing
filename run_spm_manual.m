function run_spm_manual(id_string)
% function run_spm_manual(id_string)
% - id_string: string consisting of "scanID,externalID"
% Runs SPM pre-processing pipeline for REST fMRI scans
% Pipeline protocol:
% 1) Convert DICOM -> NII format
% 2) Realign - coregister/reslice and write out mean
% 3) Despike with AFNI 3dDespike
% 4) Slice-time correct - set to 31 slices and use 15th slice for correction
% 5) Normalize - use EPI.nii image to normalize
% 6) Smooth with Gaussian kernel to 10m
tic

% Script paths
addpath('/raid0/homes/bcrone/INRIAlign');
addpath('/Shared/pinc/sharedopt/apps/matlab/Darwin/x86_64/R2013b/toolbox/spm8');
addpath('/Shared/pinc/sharedopt/apps/matlab/Darwin/x86_64/R2013b/toolbox/spm8/toolbox');
addpath('/Shared/pinc/sharedopt/apps/matlab/Darwin/x86_64/R2013b/toolbox/center_scripts_v1.0');
addpath('/Shared/paulsen/Experiments/20150630_turner_calhoun_connectivity/SPM');

% SPM cmdline mode
spm('cmdline')

% Input Directories
start = pwd;
id_array = strsplit(id_string,',');
scan = char(id_array(1));
extid = char(id_array(2));
top_path = '/Shared/paulsen/Experiments/20150630_turner_calhoun_connectivity/data2/'; % REPLACE WITH PATH TO SCANS
full_path = strcat(top_path,extid,'/',scan,'/REST/');
out_path = strcat(full_path,'output/');

% 1) DICOM -> NII convert
dicom_dcm_f = strcat(full_path,'*.dcm');
dcm2nii(full_path)
to4d(full_path)
cd(full_path)
!mkdir -p output
movefile(strcat(full_path,'4D.nii'),strcat(out_dir,scan,'.nii'))
system(['rm ' full_path '*'])
movefile(strcat(out_dir,scan,'.nii'),strcat(full_path,scan,'.nii'))
system(['rm -rf ' out_dir])

% 2) REALIGN
realign_spm(full_path)
cd(full_path)

% 3) AFNI DESPIKE
afni_file = strcat(full_path,scan,'.nii');
system(['/Shared/pinc/sharedopt/apps/afni/Linux/x86_64/2011_12_21_1014/3dDespike -prefix pp ' afni_file])
cd(full_path)

% 4) SLICE-TIME CORRECTION
slice_timing_spm(full_path)

% 5) NORMALIZE
normalize_spm(scan,full_path)

% 6) GAUSSIAN SMOOTHING
smooth_spm(scan,full_path)

toc
cd(start)
clear all
