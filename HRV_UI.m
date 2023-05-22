%% HRV analysis User Interface
% -- Dr. Rose Lab - University of Calgary
% -- June 2021
% -- Motahareh Moghtadaei -- Email: motahareh.moghtadaei@ucalgary.ca - bahar.moghtadaei@gmail.com
%%
clear; clc; close all
screensize = get( groot, 'Screensize' );
Parent_Height = 250;
Parent_Left = 10;
f = figure('Visible','off','Position',[Parent_Left 3*screensize(4)/5-200 Parent_Left+350 Parent_Height],'menubar','none','Name','HRV Rose Lab','NumberTitle','off'); %[left bottom width height]
global data SelectData edtspath edtsfile edtVlow edtLow edtHigh edtSegSizeF edtSegSizeT chbxF chbxT
% Create push button for loading data
btnload = uicontrol(f, 'Style', 'pushbutton', 'String', 'Load data','Position', [Parent_Left+20 Parent_Height-30 120 20],'Callback', @LoadFun,'ForegroundColor','blue'); %Buildstack
% Create edit for PathName
edtspath = uicontrol(f,'Style', 'edit','String',' ','Position', [Parent_Left+120 Parent_Height-55 220 20]);
txt = uicontrol(f,'Style','text','Position',[Parent_Left+20 Parent_Height-57 100 20],'String','Path Name','HorizontalAlignment','Left');
% Create edit for FileName
edtsfile = uicontrol(f,'Style', 'edit','String',' ','Position', [Parent_Left+120 Parent_Height-80 220 20]);
txt = uicontrol(f,'Style','text','Position',[Parent_Left+20 Parent_Height-82 100 20],'String','File Name','HorizontalAlignment','Left');
% Create push button for signal plot
btnplot = uicontrol(f, 'Style', 'pushbutton', 'String', 'Show Signal','Position', [Parent_Left+20 Parent_Height-105 120 20],'Callback', @PlotFun,'ForegroundColor','blue'); %Buildstack
% % Create edit for VLow
edtVlow = uicontrol(f,'Style', 'edit','String','0.4','Position', [Parent_Left+120 Parent_Height-130 50 20]);
txt = uicontrol(f,'Style','text','Position',[Parent_Left+20 Parent_Height-132 100 20],'String','Vlow','HorizontalAlignment','Left');
% Create edit for Low
edtLow = uicontrol(f,'Style', 'edit','String','1.5','Position', [Parent_Left+120 Parent_Height-155 50 20]);
txt = uicontrol(f,'Style','text','Position',[Parent_Left+20 Parent_Height-157 100 20],'String','Low','HorizontalAlignment','Left');
% Create edit for High
edtHigh = uicontrol(f,'Style', 'edit','String','5','Position', [Parent_Left+120 Parent_Height-180 50 20]);
txt = uicontrol(f,'Style','text','Position',[Parent_Left+20 Parent_Height-182 100 20],'String','High','HorizontalAlignment','Left');
% Create push button for Frequency domain HRV analysis
btnFreqRun = uicontrol(f, 'Style', 'pushbutton', 'String', 'Frequency domain HRV','Position', [Parent_Left+20 Parent_Height-207 120 20],'Callback', @FreqRunFun,'ForegroundColor','blue'); %Buildstack
% % Create edit for Segment size for Frequency domain
edtSegSizeF = uicontrol(f,'Style', 'edit','String','1500','Position', [Parent_Left+230 Parent_Height-205 50 20]);
txt = uicontrol(f,'Style','text','Position',[Parent_Left+155 Parent_Height-207 70 20],'String','Segment Size','HorizontalAlignment','Left');
% Create checkbox for Max Segment size
chbxF = uicontrol(f,'Style','checkbox','Position',[Parent_Left+290 Parent_Height-205 150 20],'String','Max','HorizontalAlignment','Left');
% Create push button for Time domain HRV analysis
btnTimeRun = uicontrol(f, 'Style', 'pushbutton', 'String', 'Time domain HRV','Position', [Parent_Left+20 Parent_Height-232 120 20],'Callback', @TimeRunFun,'ForegroundColor','blue'); %Buildstack
% % Create edit for Segment size for time domain
edtSegSizeT = uicontrol(f,'Style', 'edit','String','6000','Position', [Parent_Left+230 Parent_Height-230 50 20]);
txt = uicontrol(f,'Style','text','Position',[Parent_Left+155 Parent_Height-232 70 20],'String','Segment Size','HorizontalAlignment','Left');
% Create checkbox for Max Segment size
chbxT = uicontrol(f,'Style','checkbox','Position',[Parent_Left+290 Parent_Height-230 150 20],'String','Max','HorizontalAlignment','Left');
f.Visible = 'on';

%%
function LoadFun(source,event)
    global data SelectData edtspath edtsfile
    [FileN,PathN] = uigetfile({'*.mat';'*.xls';'*.xlsx';'*.csv'},'FileSelector');
    edtspath.String = PathN;
    edtsfile.String = FileN;
    if strcmp(FileN(end-3:end),'.mat')
        Data = load (fullfile(PathN,FileN));
        data= cell2mat(struct2cell(Data));
    elseif strcmp(FileN(end-4:end),'.xlsx')...
            | strcmp(FileN(end-3:end),'.xls')...
            | strcmp(FileN(end-3:end),'.csv')
        Data = readtable(fullfile(PathN,FileN),'basic',true);
        data=[Data{:,1},Data{:,2}];
    end
    if nanmean(data(:,2))<1
        data = data*1000;
    end
    data(find(data(:,2)>1000),:)=[];
    SelectData = data;
end

function PlotFun(source,event)
    global data SelectData
    pushbuttonPlot
end

function FreqRunFun(source,event)
    global SelectData
    global edtspath edtsfile edtVlow edtLow edtHigh edtSegSizeF chbxF
    data = SelectData;
    figure; plot(data(:,1),data(:,2));
    ylabel('NN interval (s)');
    xlabel('time (s)');
    title('Analyzed Tachogram');
    PathN = edtspath.String;
    FileN = edtsfile.String;
    MaxSelect = chbxF.Value * length(data);
    SegSize = max(MaxSelect,str2double(edtSegSizeF.String));

    VLow = str2double(edtVlow.String);
    Low  = str2double(edtLow.String);
    High  = str2double(edtHigh.String);
    window_size = 1024;
    overlap = 512;
    [d,f,Pxx1,PxxA1]=HRV_frequency_average(data,VLow,Low,High,window_size,overlap,'spline',5,SegSize);
    d1=d;
    d2 = {'Length of data', 'meanNN [ms]', 'TP',...
        'VLF','LF', 'HF','VLFper [%]', 'LFper [%]', 'HFper [%]'};
    d3=[d2;d1];
    extI = '.xls';
    res = strcat(PathN,FileN(1:find(FileN=='.')-1),'-frequency',extI);
    xlswrite(res, d3);
    
end

function TimeRunFun(source,event)
    global SelectData;
    global edtspath edtsfile edtSegSizeT chbxT
    data = SelectData;
    figure; plot(data(:,1),data(:,2));
    ylabel('NN interval (s)');
    xlabel('time (s)');
    title ('Analyzed Tachogram');
    PathN = edtspath.String;
    FileN = edtsfile.String;
    MaxSelect = chbxT.Value * length(data);
    SegSize = max(MaxSelect,str2double(edtSegSizeT.String));
    
    N1=size(data,1);
    N=N1/SegSize;
    d1=[];
    for k=1:N
        [d]=HRV_timedomain(data(((k-1)*SegSize)+1:k*SegSize,2),'spline',5);
        d1=[d1;d];
        subplot(2,1,1);title(['segment ', num2str(k)])
    end
    if ~isempty(k) && k*SegSize<N1 && (N1-k*SegSize)>100
        [d]=HRV_timedomain(data(k*6000:end,2),'spline',5);
        d1=[d1;d];
        subplot(2,1,1);title(['segment ', num2str(k+1)])

    end
    if isempty(k)
        [d]=HRV_timedomain(data(1:end,2),'spline',5);
        d1=[d1;d];
    end
    d2 = {'Length of data', 'RRmean [ms]', 'SDNN','RMSSD','RR+x', 'RR-x', 'pNN+x', 'pNN-x','PNNperxms [%]'};
    d3=[d2;d1];
    extI = '.xls';
    res = strcat(PathN,FileN(1:find(FileN=='.')-1),'-time',extI);
    xlswrite(res, d3);
end