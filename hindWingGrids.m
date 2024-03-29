function [outSeg4Pts,wingGrids ]=hindWingGrids(wingMask,inKey,inRegKey,LRside,numberOfIntervalDegree)

[B0,~]=bwboundaries(wingMask);
edgePt=B0{1};

wing_body_join=inRegKey(1,:);
if LRside=='L'
    keyPts0=[inKey(6,:) ;inRegKey(2,:) ];
elseif LRside=='R'
    keyPts0=[inKey(5,:) ;inRegKey(2,:) ];
end

keyPts=keyPts0;
for keyID=1:length(keyPts0)
    keyPts(keyID,:)=findCloestPt([edgePt(:,2),edgePt(:,1)],keyPts0(keyID,:));
end

tipPtAdj=findCloestPt([edgePt(:,2),edgePt(:,1)],keyPts(2,:));
keyPts=[keyPts(1,:);tipPtAdj];% Adjust tip point to fit on the edge
wingCorner=inRegKey(3,:);

if LRside=='L'
    inSeg4Pts=[keyPts(1,:) ; wing_body_join ; wingCorner ; keyPts(2,:)];
elseif LRside=='R'
    inSeg4Pts=[keyPts(2,:) ; wingCorner ; wing_body_join ; keyPts(1,:)];
end

outSeg4Pts=[wing_body_join ; keyPts(1,:); keyPts(2,:) ; wingCorner];
%generate grids
wingGrids=generateGrids(inSeg4Pts,edgePt,numberOfIntervalDegree);

end