function gridsParameter=manual_grids(wingLF,wingRF,wingLH,wingRH,in_key,numberOfIntervalDegree)

ornamentRatio=1/350; %the ratio of object's area to mask area exceeding this value will be defined as an ornament
[refineAreaLH,regPtLH,reconstructRegPtLH]=refineHindWing2(wingLH,in_key,'L', ornamentRatio); %Left and right indicated by how the image currently looks
[refineAreaRH,regPtRH,reconstructRegPtRH]=refineHindWing2(wingRH,in_key,'R', ornamentRatio); %Left and right indicated by how the image currently looks

figinsp=figure('visible', 'off');
pairFig=imshowpair(wingLH+wingRH,refineAreaLH+refineAreaRH);

% Scripts below are saved for debugging purposes
% figure,imshowpair(wingLH+wingRH,refineAreaLH+refineAreaRH);hold on;
% plot(regPtLH(:,1),regPtLH(:,2),'rO');
% plot(regPtRH(:,1),regPtRH(:,2),'rO');

% %Forewings
% keyPtLoc=[2,3,7,9,10,11];
% figure,imshow(wingLF+wingRF);hold on;
% for keyID=1:length(keyPtLoc)
%     plot(in_key(keyPtLoc(keyID),1),in_key(keyPtLoc(keyID),2),'rO');
% end

%Manually define those key points
%Forewings
wingFPts=[in_key(2,:) ; in_key(7,:) ; in_key(3,:) ; in_key(9,:)]; %Better not to adjust
wingFPtNameList= {'L-F&B', 'L-F&H', 'R-F&B', 'R-F&H'};
tipFPts=[in_key(10,:) ; in_key(11,:)];
tipFNameList={'tip-LF','tip-RF'};
[newFTipPts, newFwingRefPts]=manuallyDefineKeyRefPts3(wingLF+wingRF, wingLF+wingRF, tipFPts, tipFNameList, wingFPts, wingFPtNameList);

%Hindwings
wingHPts=[regPtLH(1,:) ; in_key(6,:) ; regPtRH(1,:) ; in_key(5,:)];
wingHPtNameList={'L-Hjoint', 'L-H&B',  'R-Hjoint', 'L-H&B'};
tipHPts=[regPtLH(2:3,:) ; regPtRH(2:3,:)];
tipHNameList={'tip-LH', 'side-LH', 'tip-RH', 'side-RH'};
[newHTipPts, newHwingRefPts]=manuallyDefineKeyRefPts3(refineAreaLH+refineAreaRH, pairFig.CData, tipHPts, tipHNameList, wingHPts, wingHPtNameList);

close(figinsp);

new_in_key=[in_key(1,:) ; newFwingRefPts(1,:) ; newFwingRefPts(3,:) ; in_key(4,:) ; ...
    newHwingRefPts(4,:) ; newHwingRefPts(2,:) ; newFwingRefPts(2,:) ; in_key(8,:) ; newFwingRefPts(4,:) ; newFTipPts(1,:) ; newFTipPts(2,:)];

new_regPtLH=[newHwingRefPts(1,:) ; newHTipPts(1:2,:)];
new_regPtRH=[newHwingRefPts(3,:) ; newHTipPts(3:4,:)];


%generate grids for forewings
[seg4PtsLF,wingGridsLF ]=foreWingGrids(wingLF,new_in_key,'L',numberOfIntervalDegree);
[seg4PtsRF,wingGridsRF ]=foreWingGrids(wingRF,new_in_key,'R',numberOfIntervalDegree);

%generate grids for hindwings
[outSeg4PtsLH ,wingGridsLH ]=hindWingGrids(refineAreaLH,new_in_key, new_regPtLH,'L',numberOfIntervalDegree);
[outSeg4PtsRH ,wingGridsRH ]=hindWingGrids(refineAreaRH,new_in_key, new_regPtRH,'R',numberOfIntervalDegree);


gridsParameter=cell(0,6);
gridsParameter{1}={seg4PtsLF,wingGridsLF };
gridsParameter{2}={seg4PtsRF,wingGridsRF};
gridsParameter{3}={outSeg4PtsLH ,wingGridsLH};
gridsParameter{4}={outSeg4PtsRH ,wingGridsRH};
gridsParameter{5}={refineAreaLH,new_regPtLH,reconstructRegPtLH};
gridsParameter{6}={refineAreaRH,new_regPtRH,reconstructRegPtRH};
gridsParameter{7}=wingLH;
gridsParameter{8}=wingRH;

% %Scripts below are saved for debugging purposes
% %Plot refined regions
% figure,imshowpair(wingLH+wingRH,refineAreaLH+refineAreaRH);hold on;
% plot(new_regPtLH(:,1),new_regPtLH(:,2),'rX');plot(new_regPtLH(:,1),new_regPtLH(:,2),'yO');
% plot(new_regPtRH(:,1),new_regPtRH(:,2),'rX');plot(new_regPtRH(:,1),new_regPtRH(:,2),'yO');
% 
% %plot all grids on forewings
% figure,imshow(wingLF+wingRF);hold on;
% for i=2:size(wingGridsLF,1)-1
%     gridPlot=reshape(wingGridsLF(i,:,:),[],2);
%     plot(gridPlot(:,1),gridPlot(:,2),'r');
% end
% for j=2:size(wingGridsLF,2)-1
%     gridPlot=reshape(wingGridsLF(:,j,:),[],2);
%     plot(gridPlot(:,1),gridPlot(:,2),'r');
% end
% for i=2:size(wingGridsRF,1)-1
%     gridPlot=reshape(wingGridsRF(i,:,:),[],2);
%     plot(gridPlot(:,1),gridPlot(:,2),'r');
% end
% for j=2:size(wingGridsRF,2)-1
%     gridPlot=reshape(wingGridsRF(:,j,:),[],2);
%     plot(gridPlot(:,1),gridPlot(:,2),'r');
% end
% 
% %plot all grids on hindwings
% figure,imshow(wingLH+wingRH);hold on;
% for i=2:size(wingGridsLH,1)-1
%     gridPlot=reshape(wingGridsLH(i,:,:),[],2);
%     plot(gridPlot(:,1),gridPlot(:,2),'r');
% end
% for j=2:size(wingGridsLH,2)-1
%     gridPlot=reshape(wingGridsLH(:,j,:),[],2);
%     plot(gridPlot(:,1),gridPlot(:,2),'r');
% end
% for i=2:size(wingGridsRH,1)-1
%     gridPlot=reshape(wingGridsRH(i,:,:),[],2);
%     plot(gridPlot(:,1),gridPlot(:,2),'r');
% end
% for j=2:size(wingGridsRH,2)-1
%     gridPlot=reshape(wingGridsRH(:,j,:),[],2);
%     plot(gridPlot(:,1),gridPlot(:,2),'r');
% end
end