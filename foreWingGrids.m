function [outSeg4Pts,wingGrids ]=foreWingGrids(wingMask,dorsal_key,LRside,numberOfIntervalDegree)
[B0,~]=bwboundaries(wingMask);
edgePt=B0{1};

if LRside=='L'
    lower_wing_body_join0=dorsal_key(7,:);
    keyPts0=[dorsal_key(2,:) ;dorsal_key(10,:) ];
elseif LRside=='R'
    lower_wing_body_join0=dorsal_key(9,:);
    keyPts0=[dorsal_key(3,:) ;dorsal_key(11,:) ];
end

keyPts=keyPts0;
for keyID=1:length(keyPts0)
    keyPts(keyID,:)=findCloestPt([edgePt(:,2),edgePt(:,1)],keyPts0(keyID,:));
end

lower_wing_body_join=findCloestPt([edgePt(:,2),edgePt(:,1)],lower_wing_body_join0);

tipPtAdj=findCloestPt([edgePt(:,2),edgePt(:,1)],keyPts(2,:));
keyPts=[keyPts(1,:);tipPtAdj];% Adjust tip point to fit on the edge
shoulderMIdPt=(keyPts(1,:)+keyPts(2,:))/2;

wingAxis=diff(keyPts);
wingOrtho=reshape(null(wingAxis(:).'),1,[]);

orthoSeg=[shoulderMIdPt-wingOrtho*max(size(wingMask)) ; shoulderMIdPt+wingOrtho*max(size(wingMask))];
[intersectX,intersectY]= polyxpoly(orthoSeg(:,1),orthoSeg(:,2),edgePt(:,2),edgePt(:,1));
if length(intersectX)<2
    [intersectX,intersectY]= polyxpoly(orthoSeg(:,1)-1,orthoSeg(:,2)-1,edgePt(:,2),edgePt(:,1)); %move the line a little bit to derive two intersection points
end
wingCorner=findFarestPt([intersectX,intersectY],shoulderMIdPt);
if wingCorner(2)<shoulderMIdPt(2) %error proofing for curved forewings
    wingCorner=findFarestPt([intersectX(intersectY>shoulderMIdPt(2)), intersectY(intersectY>shoulderMIdPt(2))], shoulderMIdPt);
end

if LRside=='L'
    inSeg4Pts=[lower_wing_body_join ; keyPts(1,:); keyPts(2,:) ; wingCorner];
elseif LRside=='R'
    inSeg4Pts=[wingCorner ; keyPts(2,:); keyPts(1,:) ; lower_wing_body_join];
end

outSeg4Pts=[lower_wing_body_join ; keyPts(1,:); keyPts(2,:) ; wingCorner];

wingGrids=generateGrids(inSeg4Pts,edgePt,numberOfIntervalDegree);

end