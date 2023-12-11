clear all;clc;close all;

% define input and outpud directories
input_dir= 'C:\Users\emreb\Downloads\ECG_DB\ECG_DB\WFDBRecords\01\0';
output_dir='database\';

% gather 1052 ECG samples from sub folders

for z=10:19
    parse_signals([input_dir num2str(z)],output_dir)
end
plot_it=true;

j=1;
for i=1:4 % can use up to 1052
    try % It is for continuity, some file names are missing <ie. JS00003> 
        load(output_dir+"JS" +num2str(i,'%05.f')+ ".mat");
        signal = eval(['JS' num2str(i,'%05.f') '_II']); % II numbered signal selected for processing
        arrhythmia = eval(['JS' num2str(i,'%05.f') '_arrhythmia']); % arrhytmia codes are used for model classes
        arrhythmia_name = eval(['JS' num2str(i,'%05.f') '_arrhythmia_name']); % arrhttmia names are gathered for visualisation.
        [hrv,rr_int,RR]=analyzeECG(signal,arrhythmia_name,i,plot_it);% HRVs calculated
        for k=1:length(arrhythmia)% HRV plots are combined with each related arrhytmia 
            hrv_art(j,:)=[hrv arrhythmia(k)]; % hrv and arrhythmia in same array (training with this is not succesfully)
            rr_intervals(j,:)=rr_int;
            hrv_set(j,:)=hrv;
            r_peaks(j,:)=RR;

            j=j+1;
        end
    catch
        i;
    end
end

%%  features that can be used in arrhythmia classification

% Time Domain Features:
%%%%%%%%%%%%%%%%%%%%%%%
% Mean RR Interval: The average duration between successive R-peaks.
for i = 1:length(rr_intervals(:,1))
    mean_rr_intervals(i,1) = mean(nonzeros(rr_intervals(i,:)));
end
% Standard Deviation of RR Intervals (SDNN): Reflects overall variability in heart rate.
for i = 1:length(rr_intervals(:,1))
    sdnn(i,1)= std(nonzeros(rr_intervals(i,:)));

end
% Root Mean Square of RR Interval Differences (RMSRD): 
for i = 1:length(rr_intervals(:,1))
    rmsrd(i,1)= sqrt(mean(diff(nonzeros(rr_intervals(i,:))).^2));

end
% Percentage of successive RR intervals differing by more than 50 ms (pNN50): 
for i = 1:length(rr_intervals(:,1))
    pnn50(i,1)=sum(abs(diff(nonzeros(rr_intervals(i,:))) > 50)) / length(rr_intervals(i,:)) * 100;
end

% Frequency Domain Features:
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Power spectral density: Decompose HRV into frequency bands.
for i = 1:length(rr_intervals(:,1))
    [pxx, f] = pwelch([r_peaks(i,:)], [], [], [],500); % Power spectral density
    psd_sum(i,1)=sum(pxx(1:10));
end    

% Time-frequency domain features
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Wavelet Transform Coefficients: Provide information in both time and frequency domains.
% (You may need to choose an appropriate wavelet and decomposition level)
for i = 1:length(rr_intervals(:,1))
    [c, l] = wavedec(nonzeros(rr_intervals(i,:)), 5, 'db4');
    wavelet_c(i,1)=sum(pxx(1:10));
    wavelet_c(i,2)=sum(pxx(1:10));
    
end

%Collect all futures and attach labels column as arrhythmia
featset=[mean_rr_intervals,sdnn,rmsrd,pnn50,psd_sum,wavelet_c,hrv_art(:,end)];