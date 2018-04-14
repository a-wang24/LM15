% Alan Wang
% GUI Example

% figure houses GUI
figure

% create annotation object ellipse
ellipse_position = [0.4 0.6 0.1 0.2];
ellipse_h = annotation('ellipse',ellipse_position,'facecolor',[1 0 0]);

% create editable text box
edit_box_h = uicontrol('style','edit','units','normalized',...
    'position',[0.3 0.4 0.4 0.1]);

% create push button interface object
but_h = uicontrol('style','pushbutton','string','Update Color',...
    'units','normalized','position',[0.3 0 0.4 0.2],'callback',{@eg_fun,edit_box_h, ellipse_h});

%Slider object to control ellipse size
uicontrol('style','Slider','Min',0.5,'Max',2,'Value',1,'units','normalized',...
    'position',[0.1 0.2 0.08 0.25],'callback',{@change_size,ellipse_h,ellipse_position});
uicontrol('Style','text','units','normalized','position',[0 0.45 0.2 0.1],...
    'String','Ellipse Size');
