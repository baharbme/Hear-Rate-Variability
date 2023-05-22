%% Frequency domain HRV analysis
% -- Rose Lab
% -- June 2021
% -- Bahar Moghtadaei -- Email: mmoghtadaei@dal.ca
%%
function [d,f,Pxx1,PxxA1]=HRV_frequency_average(RR,VLow,Low,High,window,overlap,interpolation,burg,segmentsize)
% removes ectopic beats
N1=size(RR,1);
N=N1/segmentsize;
Pxx1=[];PxxA1=[];RRmean1=[];
for k=1:N
    RRs=RR(((k-1)*segmentsize)+1:k*segmentsize,2);    
%     for h=1:numel(RRs)
%         if abs(RRs(h))> 200
%             RRs(h)=0;
%         end
%     end
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
    RRmean =  mean(RRs1);
    dat=RRs1/1000;
    dat1=RRs/1000;
    % remove DC component from signal
    data = detrend(dat,'constant');
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
    % Power Spectral Density: Welch's method
    time = (length(valinterp)*step_size)/1000;
    LUN =length(valinterp);
    Fs =  LUN/time;
    length_data = 1/Fs;
    tint = (0:LUN-1)*length_data;
    NFFT = 2.^nextpow2(LUN);
    time_real = sum(dat);
    treal = (0:L -1)*(time_real/L); % time vector for real data without ectopic beats
    treal1=(0:length(data1)-1)*(sum(dat1)/length(data1)); % time vector for original data 
    % PSD: Welch's method with hamming window
    [Pxx,f] = pwelch(valinterp',hamming(window),overlap,NFFT,Fs,'psd');
    % autoregressive model: Burgs method
    e=zeros(120,1);
    AICburg=zeros(120,1);
    for p = 1:120
        [a,ki(p)]=arburg(valinterp,p);
        e(p)=ki(p);
        AICburg(p)=length(valinterp)*log(((e(p))^2))+2*p;
    end
    % AR PSD: Burg's method
    [PxxA,fA] = pburg(valinterp',burg,NFFT,Fs);
    length(fA);
    Pxx1=[Pxx1,Pxx];
    PxxA1=[PxxA1,PxxA];
    RRmean1=[RRmean1,RRmean];
end
size(Pxx1)
Pxx=mean(Pxx1,2);
PxxA=mean(PxxA1,2);
RRmean=mean(RRmean1);
% plots
figure; plot (f,Pxx,'k','linewidth',2) %  PSD
hold on; plot([VLow,VLow],[0,max(Pxx)],'k');
hold on; plot([Low,Low],[0,max(Pxx)],'k');
hold on; plot([High,High],[0,max(Pxx)],'k');
axis([-0.1 6 0 max(Pxx)]);
ylabel('PSD (s^2/Hz)')
xlabel('Frequency Hz')
set(gca,'FontSize',14)
% calculating the power in different frequency bands
nu = length(f);
a = f(nu);
VLFl = 1; 
VLFh = (nu*VLow)/a
size(Pxx)
VLF = sum(Pxx(VLFl:VLFh));
LFl =   VLFh+1;
LFh = (nu*Low)/a;
LF = sum(Pxx(LFl:LFh));
HFl = LFh+1;
HFh = (nu*High)/a;
HF = sum(Pxx(HFl:HFh));
TP = sum(Pxx(1:HFh));
VLFper = VLF/TP*100;
LFper = LF/(TP)*100 ;
HFper = HF/(TP)*100;
ratio = LF/HF;
% output: frequency domain HRV measures:
d = {L RRmean TP VLF LF HF VLFper LFper HFper};

