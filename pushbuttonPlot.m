%% Tachogram User Interface
% -- Rose Lab
% -- June 2021
% -- Bahar Moghtadaei -- Email: mmoghtadaei@dal.ca
%%
function pushbuttonPlot
global data SelectData
f = figure('Name','Tachogram (press ESC when finished)','NumberTitle','off','menubar','none');
ax = axes(f);
ax.Units = 'pixels';
ax.Position = [75 75 400 300]
plot(data(:,1),data(:,2));drawnow
ylabel('NN interval (s)')
xlabel('time (s)')
% title('Tachogram');
% SelectData = data;
c = uicontrol;
c.String = 'Select Data';
c.Callback = @plotButtonPushed;
c.Position = [20,20,60,20]
c2 = uicontrol;
c2.String = 'Reset';
c2.Callback = @ResetButtonPushed;
c2.Position = [80,20,60,20]
H=imrecanglecon
    function plotButtonPushed(source,event)
        H.Position %[x y w h]
        t1=floor(H.Position(1));
        t2=floor(H.Position(1)+H.Position(3));
        L1=floor(H.Position(2));
        L2=floor(H.Position(2)+H.Position(4));
        SelectData = data(max(t1,1):min(t2,length(data)),:);
        SelectData(find(SelectData(:,2)>L2|SelectData(:,2)<L1),:)=[];
        plot(SelectData(:,1),SelectData(:,2));drawnow
        ylabel('NN interval (s)')
        xlabel('time (s)')
        title('Tachogram');
        H=imrecanglecon
    end

    function ResetButtonPushed(source, event)
        close(f)
        SelectData = data;
        pushbuttonPlot

    end

end
