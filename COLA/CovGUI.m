% Alan Wang 8/13/2015
% Covariance GUI to input covariance values manually in case the info is
% not included within CSM or CDM
% This file will contain the layout for the GUI

f = figure;

uicontrol('Style','text','units','normalized','position',[0.125 .85 .75 .1],...
    'string','Input Covariance Data','FontSize',28);

uicontrol('Style','text','units','normalized','position',[1/12 .7 1/3 .08],...
    'string','variance-xx','FontSize',20);

uicontrol('Style','text','units','normalized','position',[1/12 .6 1/3 .08],...
    'string','variance-yy','FontSize',20);

uicontrol('Style','text','units','normalized','position',[1/12 .5 1/3 .08],...
    'string','variance-zz','FontSize',20);

uicontrol('Style','text','units','normalized','position',[1/12 .4 1/3 .08],...
    'string','covariance-xy','FontSize',20);

uicontrol('Style','text','units','normalized','position',[1/12 .3 1/3 .08],...
    'string','covariance-xz','FontSize',20);

uicontrol('Style','text','units','normalized','position',[1/12 .2 1/3 .08],...
    'string','covariance-yz','FontSize',20);

varxx_h = uicontrol('style','edit','units','normalized',...
    'position',[7/12 .7 1/3 .08]);

varyy_h = uicontrol('style','edit','units','normalized',...
    'position',[7/12 .6 1/3 .08]);

varzz_h = uicontrol('style','edit','units','normalized',...
    'position',[7/12 .5 1/3 .08]);

covxy_h = uicontrol('style','edit','units','normalized',...
    'position',[7/12 .4 1/3 .08]);

covxz_h = uicontrol('style','edit','units','normalized',...
    'position',[7/12 .3 1/3 .08]);

covyz_h = uicontrol('style','edit','units','normalized',...
    'position',[7/12 .2 1/3 .08]);

but_h = uicontrol('style','pushbutton','string','Input Values','units',...
    'normalized','position',[.25 .05 .5 .1],'callback',{@input_values,f,varxx_h,varyy_h,varzz_h,covxy_h,covxz_h,covyz_h});