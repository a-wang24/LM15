function input_values(objH,event,figH,editH1,editH2,editH3,editH4,editH5,editH6 )
    varxx = str2num(get(editH1,'string'));
    varyy = str2num(get(editH2,'string'));
    varzz = str2num(get(editH3,'string'));
    covxy = str2num(get(editH4,'string'));
    covxz = str2num(get(editH5,'string'));
    covyz = str2num(get(editH6,'string'));
    covMatrix = [varxx,covxy,covxz;covxy,varyy,covyz;covxz,covyz,varzz];
    setappdata(figH,'covMatrix',covMatrix);
    disp('values inputted');
end

