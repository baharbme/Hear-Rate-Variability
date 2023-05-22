%% Time domain HRV analysis
% -- Rose Lab
% -- June 2021
% -- Bahar Moghtadaei -- Email: mmoghtadaei@dal.ca
%%
function [d]=HRV_timedomain(RRs,interpolation,burg)
% removes ectopic beats
% for h=1:numel(RRs)    
%     if abs(RRs(h))> 200
%       RRs(h)=0;
%     end
%     if abs(RRs(h))< 50
%       RRs(h)=0;
%     end
% end
RRs = RRs(RRs~=0); 
le=numel(RRs);
RRs1=RRs; 
% moving average
window_size = 80;
mov_av=tsmovavg(RRs,'s',window_size,1); 
        
for h=1:le    
    if abs(RRs(h))< 0.80*mov_av(h) || abs(RRs(h))>1.20*mov_av(h)
      RRs1(h)=0;
    end
end
RRs1 = RRs1(RRs1~=0); 
RR=RRs1/1000;  
dat1=RRs/1000;  
% calculate mean:
RRmean =  mean(RRs1);
% calculate standard deviation:
SDNN = rms(RRs1-mean(RRs1)) ;  
% calculate root mean square of the standard deviation
rmd = zeros(length(RRs1)-1,1);
for j=1:(length(RRs1)-1)
    rmd(j) = (RRs1(j)-RRs1(j+1));    
end
RMSSD = rms(rmd);
% calculate pNN6
N= length(RR); 
x=6/1000;  
nnp=0;
nnm=0;
for i = 1:(N-1)                                                            
    if (RR(i)-RR(i+1))> x                              
        nnp = nnp +1; % add 1 to num
    end    
    if (RR(i)-RR(i+1))< -x
        nnm = nnm +1;
    end
end
pNNp = nnp/N * 100;
pNNm = nnm/N * 100;
PNNper = (nnp+nnm)/N*100; 
% detrend: remove DC component from signal
data = detrend(RR,'constant');
data1 = detrend(dat1,'constant');
% signal detrending using smoothness prior approach 
length_data = length(data);
g = 40;
Mat = speye(length_data);
Mat_2 = spdiags(ones(length_data-2,1)*[1 -2 1],[0:2],length_data-2,...
    length_data);
data = (Mat-inv(Mat+g^2*Mat_2'*Mat_2))*data;
% interpolation:
timems = sum (RRs);
step_size = 50;
dataPoints = timems/step_size; 
L =length(data);
delta = L/(dataPoints); 
v =  1:delta:L;
ve = 1:L; 
valinterp_long = interp1(ve,data',v,interpolation);
% reduce interpolated data to 2048 data points
if length(valinterp_long)>= 2048
valinterp = valinterp_long(1:2048);
else
    valinterp=valinterp_long;
    disp('not enough data points <2048')
    disp(length(valinterp))
end
time = (length(valinterp)*step_size)/1000; 
LUN =length(valinterp); % Length of signal 
tint = (0:LUN-1)*length_data; % Time vector for interpolated data
time_real = sum(RR);
treal = (0:L -1)*(time_real/L); % time vector for real data without ectopic beats
treal1=(0:length(data1)-1)*(sum(dat1)/length(data1));  % time vector for original data 
% optional plot 
figure;subplot(2,1,1)
plot (treal,data,'r') % Tachogram
hold off;ylabel('RR interval (s)')
xlabel('time (s)');
subplot(2,1,2)
hist(RRs,15);% Histogram
ylabel('count')
% output: time domain HRV measures:
d = length(RRs1);
xpoi = RRs1(1:(d-1));
ypoi = RRs1(2:d);
d = { L,RRmean SDNN...
     RMSSD nnp nnm pNNp pNNm PNNper  };
