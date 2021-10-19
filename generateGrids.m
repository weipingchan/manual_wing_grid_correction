function wingGriddeep=generateGrids(seg4Pts,edgePt,numberOfIntervalDegree)
%Do a basic Grid first: haveing 2^3 * 2^3 grids
numberOfIntervalDegree0=3;
numberOfInterval0=2^numberOfIntervalDegree0;
evenIntEdge0=getEvenSpaceForGrid(seg4Pts,edgePt,numberOfIntervalDegree0);

%The order for each side is super important
wingGrid=zeros(numberOfInterval0+1,numberOfInterval0+1,2);
wingGrid(:,1,:)=flip(evenIntEdge0{3});
wingGrid(:,numberOfInterval0+1,:)=flip(evenIntEdge0{1});
wingGrid(numberOfInterval0+1,:,:)=evenIntEdge0{4};
wingGrid(1,:,:)=evenIntEdge0{2};

cen0=mean(seg4Pts);
wingGrid(numberOfInterval0/2+1,numberOfInterval0/2+1,:)=cen0;

for itr=1:numberOfIntervalDegree0-1
    intv=2^(numberOfIntervalDegree0-itr);
    if itr==1
        dimList=[[1,1]];
    else
        dimList=[[1,1];[1,2];[2,1];[2,2]];
    end
    wingGrid=generate4dimGrids(dimList,intv,wingGrid);
end

%solve the final empty points
wingGrid=solveGap(wingGrid);

%%
%Use loop to reach the final resolution
numberOfIntervalDegree2=numberOfIntervalDegree0+1;
originalGrid=wingGrid;
while 1
    numberOfInterval2=2^numberOfIntervalDegree2;
    wingGriddeep=zeros(2^numberOfIntervalDegree2+1,2^numberOfIntervalDegree2+1,2);

    for i=1:size(originalGrid,1)
        for j=1:size(originalGrid,2)
            wingGriddeep((i-1)*2+1,(j-1)*2+1,:)= originalGrid(i,j,:);
        end
    end

    evenIntEdge=getEvenSpaceForGrid(seg4Pts,edgePt,numberOfIntervalDegree2);
    %The order for each side is super important
    wingGriddeep(:,1,:)=flip(evenIntEdge{3});
    wingGriddeep(:,numberOfInterval2+1,:)=flip(evenIntEdge{1});
    wingGriddeep(numberOfInterval2+1,:,:)=evenIntEdge{4};
    wingGriddeep(1,:,:)=evenIntEdge{2};

    for i=1:size(originalGrid,1)-1
        for j=1:size(originalGrid,2)-1
            cendat=[originalGrid(i,j,:) ; originalGrid(i,j+1,:) ; originalGrid(i+1,j,:) ; originalGrid(i+1,j+1,:)];
            cen=mean(cendat);
            wingGriddeep((i-1)*2+1+1,(j-1)*2+1+1,:)=cen;
        end
    end

    %solve the final empty points
    wingGriddeep=solveGap(wingGriddeep);

    if numberOfIntervalDegree2>=numberOfIntervalDegree
        break
    else
        numberOfIntervalDegree2=numberOfIntervalDegree2+1;
        originalGrid=wingGriddeep;
    end
end

end