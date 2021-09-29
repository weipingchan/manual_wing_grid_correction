morph_mat_directory='D:\Milk desk\Dropbox\Harvard\Coloration_research\Drawer_result\tribal_wing-seg_matrices_Mar2020_final';
Code_directory='D:\Milk desk\Dropbox\Harvard\Coloration_research\Multi_spectra_processing/shape_analysis_v3';
% spp_mat_directory='D:\Milk desk\Dropbox\Harvard\Coloration_research\Drawer_result\spp_matrices';
Result_directory=fullfile(Code_directory,'manually_defined_grids');
% Turn off this warning "Warning: Image is too big to fit on screen; displaying at 33% "
% To set the warning state, you must first know the message identifier for the one warning you want to enable. 
warning('off', 'Images:initSize:adjustingMag');

addpath(genpath(Code_directory)) %Add the library to the path
all_morph_data = dir(fullfile(morph_mat_directory,['**',filesep,'*morph-seg.mat']));

% all_morph_name0=struct2dataset(all_morph_data);
% all_morph_name=all_morph_name0(:,1).name;

% tarID = find(contains(all_morph_name,template));

%generate a unique barcode list from morph directory
barcodelist=cell(0,1);
rec=1;
for matinID=1:length(all_morph_data)
    matinname=all_morph_data(matinID).name;
    [barcode, side, flag]=file_name_decoder(matinname);
    
    if  isempty(find(contains(barcodelist,barcode)))
        barcodelist{rec}=barcode;
        rec=rec+1;
    end
end

%%
%Manual define based on a folder of images
manual_grid_redo_directory='D:\Milk desk\Dropbox\Harvard\Coloration_research\Multi_spectra_photos\tribal_level_wing-grids_inspection\manual';
%generate a unique barcode list for manual defind grids
redo_data = dir(fullfile(manual_grid_redo_directory,'*.jpg'));
redobarcodelist=cell(0,1);
rec=1;
for matinID=1:length(redo_data)
    matinname=redo_data(matinID).name;
    [barcode, side, flag]=file_name_decoder(matinname);
    if  isempty(find(contains(redobarcodelist,barcode)))
        redobarcodelist{rec}=barcode;
        rec=rec+1;
    end
end

%Run in a loop for a small number of file
numberOfIntervalDegree=5; %minimum is 3
for barID=1:length(redobarcodelist)
    barcodein=redobarcodelist{barID};
    try
        dorsal_ventral_manual_define_grids(morph_mat_directory,Code_directory,Result_directory,barcodein,numberOfIntervalDegree);
        %Move those images having been analyzed to a subdirectory
        finishedDir='done';
        if ~exist(fullfile(manual_grid_redo_directory,finishedDir), 'dir')
            mkdir(fullfile(manual_grid_redo_directory,finishedDir));
        end
        movefile(fullfile(manual_grid_redo_directory,[barcodein,'*.jpg']),fullfile(manual_grid_redo_directory,finishedDir));
    catch
        disp(['No. [ ', num2str(barID), '] cannnot be processed.']);
    end
end
%%
%Manual define based on a list of barcode
listdir='D:\Milk desk\Dropbox\Harvard\Coloration_research\Multi_spectra_photos\tribal_level_wing-grids_inspection';
listfilename='tribal_level_wing-grids_inspection_not_yet_done_barcode_list.txt';
fileID = fopen(fullfile(listdir,listfilename),'r');
barcodelist = textscan(fileID,'%s','delimiter','\n'); 
fclose(fileID);

redobarcodelist=barcodelist{1};

%Run in a loop for a small number of file
numberOfIntervalDegree=5; %minimum is 3
for barID=1:length(redobarcodelist)
    barcodein=redobarcodelist{barID};
    try
        dorsal_ventral_manual_define_grids(morph_mat_directory,Code_directory,Result_directory,barcodein,numberOfIntervalDegree);
    catch
        disp(['No. [ ', num2str(barID), '] cannnot be processed.']);
    end
end

%%
%manually key in barcode
%Input specific barcode
barcodein='MCZ-ENT00210891'; %Mask issue
barcodein='MCZ-ENT00061676';
numberOfIntervalDegree=5; %minimum is 3
dorsal_ventral_manual_define_grids(morph_mat_directory,Code_directory,Result_directory,barcodein,numberOfIntervalDegree);
