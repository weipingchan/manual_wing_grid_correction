function dorsal_ventral_manual_define_grids(morph_mat_directory,Code_directory,Result_directory,barcodein,numberOfIntervalDegree)
    addpath(genpath(Code_directory)) %Add the library to the path
    vdlist={'dorsal','ventral'};
    subFolderList={'inspect_manual_grids','spp_manual_grid_parameters'};
    %Create result directory
    if ~exist(Result_directory, 'dir')
        mkdir(Result_directory);
    end

    for fold=1:length(subFolderList)
        if ~exist(fullfile(Result_directory,subFolderList{fold}), 'dir')
            mkdir(fullfile(Result_directory,subFolderList{fold}));
        end
        disp(['corresponding folder ', subFolderList{fold}, ' is created / found.']);
    end

    %%
    all_morph_data = dir(fullfile(morph_mat_directory,'*morph-seg.mat')); %read only one layer of directory; '**/*morph-seg.mat': reald all subfolders
    all_morph_name0=struct2dataset(all_morph_data);
    all_morph_name=all_morph_name0(:,1).name;
    fileID=find(contains(all_morph_name,[barcodein,'_']));
    both_sides_morph=cell(0,2);
    if length(fileID)==2
        for matinID=1:length(fileID)
            matindir=all_morph_data(fileID(matinID)).folder;
            matinname=all_morph_data(fileID(matinID)).name;
            pathdirs=strsplit(matindir,filesep);
            lowestdir=pathdirs{end};
            [barcode, side, flag]=file_name_decoder(matinname);
            matin=fullfile(matindir,matinname);
            sppmat0=load(matin);
            fieldName=cell2mat(fieldnames(sppmat0));
            sppmat=sppmat0.(fieldName);
            clear sppmat0;
            disp(['[',matinname,'] in {',lowestdir,'} has been read into memory']);

            both_sides_morph{side}={sppmat,barcode,side,flag};
        end
    else
        disp('cannot find both sides of morpho-seg mat files');
        matinname=all_morph_data(fileID).name;
        disp(['[',matinname,']']);
    end

    %%
    %derive the corresponding images for both sides
    dorsal_seg=both_sides_morph{1}{1}{13};
    ventral_seg=both_sides_morph{2}{1}{13};
    ventral_seg_flip = flip(ventral_seg ,2); 

    keyPts=cell(0,2);
    for sideID=1:2
        refPts=both_sides_morph{sideID}{1}{6};
        tipPts=both_sides_morph{sideID}{1}{5};
        keyPts{sideID}=[refPts;tipPts];
    end

    dorsal_key=keyPts{1};
    ventral_key=keyPts{2};
    ventral_key_flip0=ventral_key;
    ventral_key_flip0(:,1)=size(ventral_seg,2)+1-ventral_key(:,1);
    ventral_key_flip=[ventral_key_flip0(4,:);ventral_key_flip0(3,:);ventral_key_flip0(2,:);ventral_key_flip0(1,:);ventral_key_flip0(6,:);ventral_key_flip0(5,:);ventral_key_flip0(9,:);ventral_key_flip0(8,:);ventral_key_flip0(7,:);ventral_key_flip0(11,:);ventral_key_flip0(10,:)];

    %%
    %Create potential intact wing region based on ventral-dorsal mapping
    disp('Begin to create potential wing area based on dosal-ventral sides mapping');
    
    %Check all wings
    %If wing is missing, provide a fake one
    dorsal_wingLF=checkWingMask(dorsal_seg==1, dorsal_key, 'LF');
    dorsal_wingRF=checkWingMask(dorsal_seg==2, dorsal_key, 'RF');
    dorsal_wingLH=checkWingMask(dorsal_seg==3, dorsal_key, 'LH');
    dorsal_wingRH=checkWingMask(dorsal_seg==4, dorsal_key, 'RH');
    
    ventral_flip_wingLF=checkWingMask(ventral_seg_flip==1, ventral_key_flip, 'LF');
    ventral_flip_wingRF=checkWingMask(ventral_seg_flip==2, ventral_key_flip, 'RF');
    ventral_flip_wingLH=checkWingMask(ventral_seg_flip==3, ventral_key_flip, 'LH');
    ventral_flip_wingRH=checkWingMask(ventral_seg_flip==4, ventral_key_flip, 'RH');
    
    %Use dorsal image
    segLineLF=extractSegLineF(dorsal_wingLF,dorsal_key,'L');
    segLineRF=extractSegLineF(dorsal_wingRF,dorsal_key,'R');

    %Use ventral-flip image
    segLineLH=extractSegLineH(ventral_flip_wingLH,ventral_key_flip,'L');
    segLineRH=extractSegLineH(ventral_flip_wingRH,ventral_key_flip,'R');

    disp('The fore-hind wing joint lines are extracted from dosal and ventral sides');
    
    %Scripts below are saved for debugging purpose
    % figure,imshow(dorsal_wingLF);hold on;
    % plot(segLineLF(:,1),segLineLF(:,2),'r.');
    % figure,imshow(wingRF);hold on;
    % plot(segLineRF(:,1),segLineRF(:,2),'r.');
    % figure,imshow(wingLH);hold on;
    % plot(segLineLH(:,1),segLineLH(:,2),'r.');
    % figure,imshow(wingRH);hold on;
    % plot(segLineRH(:,1),segLineRH(:,2),'r.');
%%
    %Map ventral-side hind wing on dorsal side hind wing
    segLineLH_dorsal=projectSegLine(dorsal_wingLH, dorsal_key,segLineLH,'L');
    segLineRH_dorsal=projectSegLine(dorsal_wingRH, dorsal_key, segLineRH,'R');
    segLineLF_ventral=projectSegLine(ventral_flip_wingLF, ventral_key_flip,segLineLF,'L');
    segLineRF_ventral=projectSegLine(ventral_flip_wingRF, ventral_key_flip,segLineRF,'R');

%     Scripts below are saved for debugging purpose
%     figure,imshow((ventral_seg_flip==1)+(ventral_seg_flip==2));hold on;
%     plot(segLineLF_ventral(:,1),segLineLF_ventral(:,2),'r.');
%     plot(segLineRF_ventral(:,1),segLineRF_ventral(:,2),'r.');
%     
%     figure,imshow((dorsal_seg==3)+(dorsal_seg==4));hold on;
%     plot(segLineLH_dorsal(:,1),segLineLH_dorsal(:,2),'r.');
%     plot(segLineRH_dorsal(:,1),segLineRH_dorsal(:,2),'r.');
%%
    %Generate potential mask
    [potentialWingMask_LH_dorsal,nullArea_LH_dorsal]=getPotentialWingMask2(dorsal_wingLH,segLineLH_dorsal,'LH');
    [potentialWingMask_RH_dorsal,nullArea_RH_dorsal]=getPotentialWingMask2(dorsal_wingRH,segLineRH_dorsal,'RH');
    [potentialWingMask_LF_ventral,nullArea_LF_ventral]=getPotentialWingMask2(ventral_flip_wingLF,segLineLF_ventral,'LF');
    [potentialWingMask_RF_ventral,nullArea_RF_ventral]=getPotentialWingMask2(ventral_flip_wingRF,segLineRF_ventral,'RF');

    % figure,imshowpair(potentialWingMask_LH_dorsal+potentialWingMask_RH_dorsal,nullArea_LH_dorsal+nullArea_RH_dorsal);
    % figure,imshowpair(potentialWingMask_LF_ventral+potentialWingMask_RF_ventral,nullArea_LF_ventral+nullArea_RF_ventral);
    disp('The potential wing area are estimated');

    % numberOfIntervalDegree=5; %minimum is 3
    disp(['The resolution of wing matrix is: ' num2str(2^numberOfIntervalDegree),' x ',num2str(2^numberOfIntervalDegree)]);

    %dorsal image
    gridsParameter_dorsal=manual_grids(dorsal_wingLF,dorsal_wingRF,potentialWingMask_LH_dorsal,potentialWingMask_RH_dorsal,dorsal_key,numberOfIntervalDegree);
    disp('Grids of dorsal wing is generated');

    %ventral image
    gridsParameter_ventral=manual_grids(potentialWingMask_LF_ventral,potentialWingMask_RF_ventral,ventral_flip_wingLH,ventral_flip_wingRH,ventral_key_flip,numberOfIntervalDegree);
    disp('Grids of ventral wing is generated');

    % {1}={seg4PtsLF,wingGridsLF }; %4 key points & grids
    % {2}={seg4PtsRF,wingGridsRF}; %4 key points & grids
    % {3}={outSeg4PtsLH ,wingGridsLH}; %4 key points & grids
    % {4}={outSeg4PtsRH ,wingGridsRH}; %4 key points & grids
    % {5}={refineAreaLH,regPtLH,reconstructRegPtLH}; %mask without ornament, 3
    % key points & key points of the mask without ornament
    % {6}={refineAreaRH,regPtRH,reconstructRegPtRH}; %mask without ornament, 3
    % key points & key points of the mask without ornament
    % {7}=original mask of LH
    % {8}=original mask of RH
%%
    %Save image for inspection
    %Save dorsal side
    inspvisoutname=fullfile(Result_directory,subFolderList{1},[barcode,'_',vdlist{1},flag,'_keys_grids_res-',num2str(2^numberOfIntervalDegree),'x',num2str(2^numberOfIntervalDegree),'.jpg']);
    figinsp=figure('visible', 'off');
    plotGridInspect(dorsal_wingLF,dorsal_wingRF,potentialWingMask_LH_dorsal,potentialWingMask_RH_dorsal,nullArea_LH_dorsal,nullArea_RH_dorsal,gridsParameter_dorsal);
    %saveas(figmask, maskoutname);
    export_fig(figinsp,inspvisoutname, '-jpg','-r200');
    close(figinsp);

    %Save ventral side
    inspvisoutname=fullfile(Result_directory,subFolderList{1},[barcode,'_',vdlist{2},flag,'_keys_grids_res-',num2str(2^numberOfIntervalDegree),'x',num2str(2^numberOfIntervalDegree),'.jpg']);
    figinsp=figure('visible', 'off');
    plotGridInspect(potentialWingMask_LF_ventral,potentialWingMask_RF_ventral,ventral_flip_wingLH,ventral_flip_wingRH,nullArea_LF_ventral,nullArea_RF_ventral,gridsParameter_ventral);
    %saveas(figmask, maskoutname);
    export_fig(figinsp,inspvisoutname, '-jpg','-r200');
    close(figinsp);
    disp('Two images showing keys ang grids of both sides of a specimen has been saved.');


    %Save all result
    manualGrids={gridsParameter_dorsal,gridsParameter_ventral}; %All parameters and grids
    matoutname=fullfile(Result_directory,subFolderList{2},[barcode,'_res-',num2str(2^numberOfIntervalDegree),'x',num2str(2^numberOfIntervalDegree),'_d-v_manual_grids.mat']);
    save(matoutname,'manualGrids'); %save the specimen matrix
    disp(['################################']);
    disp(['Manual grids of [',barcode,'_res-',num2str(2^numberOfIntervalDegree),'x',num2str(2^numberOfIntervalDegree),'] has been saved' ]);
    disp(['################################']);
end