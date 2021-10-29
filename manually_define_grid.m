%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Manually define grids based on a folder of problematic images (jpg format)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
morph_mat_directory='..\tribal_wing-seg_matrices_Mar2020_final';
Code_directory='../shape_analysis_v3';
manual_grid_redo_directory='..\tribal_level_wing-grids_inspection\manual';
numberOfIntervalDegree =5; %minimum is 3
%%%%%%%%%%%%%%%%%%%%Specify only above%%%%%%%%%%%%%%%%%%%%

% Turn off this warning "Warning: Image is too big to fit on screen; displaying at 33% "
% To set the warning state, you must first know the message identifier for the one warning you want to enable. 
warning('off', 'Images:initSize:adjustingMag');
Result_directory=fullfile(Code_directory,'manually_defined_grids');

addpath(genpath(Code_directory)) %Add the library to the path
%generate a unique barcode list for manual corrections
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

%Run in a loop for a small number of files
for barID=1:length(redobarcodelist)
    barcodein=redobarcodelist{barID};
    try
        dorsal_ventral_manual_define_grids(morph_mat_directory,Code_directory,Result_directory,barcodein,numberOfIntervalDegree);
        %Move those images that have been analyzed to a subdirectory
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
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Manually define grids based on a list of barcodes (in txt format)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
morph_mat_directory='..\tribal_wing-seg_matrices_Mar2020_final';
Code_directory='../shape_analysis_v3';
listdir='..\tribal_level_wing-grids_inspection';
listfilename='tribal_level_wing-grids_inspection_not_yet_done_barcode_list.txt';
numberOfIntervalDegree=5; %minimum is 3
%%%%%%%%%%%%%%%%%%%%Specify only above%%%%%%%%%%%%%%%%%%%%

% Turn off this warning "Warning: Image is too big to fit on screen; displaying at 33% "
% To set the warning state, you must first know the message identifier for the one warning you want to enable. 
warning('off', 'Images:initSize:adjustingMag');
Result_directory=fullfile(Code_directory,'manually_defined_grids');

addpath(genpath(Code_directory)) %Add the library to the path
fileID = fopen(fullfile(listdir,listfilename),'r');
barcodelist = textscan(fileID,'%s','delimiter','\n'); 
fclose(fileID);
redobarcodelist=barcodelist{1};

%Run in a loop for a small number of files
for barID=1:length(redobarcodelist)
    barcodein=redobarcodelist{barID};
    try
        dorsal_ventral_manual_define_grids(morph_mat_directory,Code_directory,Result_directory,barcodein,numberOfIntervalDegree);
    catch
        disp(['No. [ ', num2str(barID), '] cannnot be processed.']);
    end
end

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Manually define grids based on a barcode being typed in
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
morph_mat_directory='..\tribal_wing-seg_matrices_Mar2020_final';
Code_directory='../shape_analysis_v3';
%Input specific barcode
barcodein='MCZ-ENT00210891'; %The barcode with problematic grids
numberOfIntervalDegree=5; %minimum is 3
%%%%%%%%%%%%%%%%%%%%Specify only above%%%%%%%%%%%%%%%%%%%%

% Turn off this warning "Warning: Image is too big to fit on screen; displaying at 33% "
% To set the warning state, you must first know the message identifier for the one warning you want to enable. 
warning('off', 'Images:initSize:adjustingMag');

addpath(genpath(Code_directory)) %Add the library to the path
Result_directory=fullfile(Code_directory,'manually_defined_grids');
dorsal_ventral_manual_define_grids(morph_mat_directory,Code_directory,Result_directory,barcodein,numberOfIntervalDegree);
