function input_values1(objH,event,figH,editH1,editH2,editH3,editH4,editH5,editH6,editH7,editH8,editH9,editH10,editH11,editH12)
    varxx = str2num(get(editH1,'string'));
    varyy = str2num(get(editH2,'string'));
    varzz = str2num(get(editH3,'string'));
    covxy = str2num(get(editH4,'string'));
    covxz = str2num(get(editH5,'string'));
    covyz = str2num(get(editH6,'string'));
    varVxx = str2num(get(editH7,'string'));
    varVyy = str2num(get(editH8,'string'));
    varVzz = str2num(get(editH9,'string'));
    covVxy = str2num(get(editH10,'string'));
    covVxz = str2num(get(editH11,'string'));
    covVyz = str2num(get(editH12,'string'));
    covPosMatrix = [varxx,covxy,covxz;covxy,varyy,covyz;covxz,covyz,varzz];
    covVelMatrix = [varVxx,covVxy,covVxz;covVxy,varVyy,covVyz;covVxz,covVyz,varVzz];
    setappdata(figH,'covPosMatrix',covPosMatrix);
    setappdata(figH,'covVelMatrix',covVelMatrix);
    disp('values inputted');
end
