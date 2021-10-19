function hit=interactPt(refPts,hid,ptNameList,color)
        hit = impoint(gca,refPts(hid,:));
        fcn = makeConstrainToRectFcn('impoint',get(gca,'XLim'),get(gca,'YLim'));
        setPositionConstraintFcn(hit,fcn);
        setColor(hit,color);
        title([ptNameList{hid}]);
end