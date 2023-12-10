clear all;

clc;

close all;
input_dir= '....\01\010';
output_dir='database\';
parse_signals(input_dir,output_dir)
plot=false;
j=1
for i=1:104
    try
        load(output_dir+"JS" +num2str(i,'%05.f')+ ".mat");
        signal = eval(['JS' num2str(i,'%05.f') '_II']);
        arrhythmia = eval(['JS' num2str(i,'%05.f') '_arrhythmia']);
        arrhythmia_name = eval(['JS' num2str(i,'%05.f') '_arrhythmia_name']);
        hrv=analyzeECG(signal,arrhythmia_name,i,plot);
        for k=1:length(arrhythmia)
            hrv_art(j,:)=[hrv arrhythmia(k)];
            j=j+1;
        end
    end
end
% nonZeroRows = ~all(hrv_art == 0, 2);
% hrv_art = hrv_art(nonZeroRows, :);