% Save this code in a file named analyzeECG.m

function [hrv,rr_int,RR]=analyzeECG(sig,arrhythmia,index,plot_it)

    
    %Low pass filter
    B = [1 0 0 0 0 0 -2 0 0 0 0 0 1]/32;
    A = [1 -2 1];
    lp = filter(B, A, sig);
    
    %High pass filter
    B1 = [-1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 32 -32 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1]/32;
    A1 = [1 -1];
    hp = filter(B1, A1, lp);
    
    %Differentiation
    B2 = [2 1 0 -1 -2]/8;
    A2 = 1;
    dif= filter(B2, A2, hp);
    
    %Taking Square
    sq=zeros(1,length(dif));
    for i = 1:length(dif)
        sq(i) = dif(i)^2;
    end

    %Taking Integral
    sabit =30; 
    int=zeros(1,length(dif));
    sq_padding = [zeros(1, sabit) sq];
    for i = sabit+1:length(sq_padding)
        sum = 0;
        for j = 1:sabit
            sum = sum + sq_padding(i-j);
        end
        int(i-sabit) = sum/sabit;
    end

    %Thresholding
    th=int;
    for i=1:length(int)
        if(int(i)<max(int)/5)
            th(i)=0;
        end
    end
    
    %Search R-Peaks
    RR=zeros(1,length(th));
    for i=1:length(th)-4
        if(th(i+1)>th(i)&& th(i+2)>th(i+1)&& th(i+2)>th(i+3)&& th(i+3)>th(i+4))
            RR(i)=10000;
        end
    end
    
    % R-Peaks Indexes
    j=1;
    for i=1:length(RR)
        if(RR(i)==10000)
            temp2(j)=i;
            j=j+1;
        end
    end

    % HRV Calculation using RR Intervals
    j=1;
    hrv=zeros(1,50);
    rr_int=zeros(1,50);
    
    for i=1:length(temp2)-1
        rr_diff=temp2(i+1)-temp2(i);
        if rr_diff>100
            freq=1/(rr_diff/500); %beat per sec 
            hrv(j)=freq*60; % beat per min
            rr_int(j)=rr_diff;
            j=j+1;
        end
    end
    art='';
    for i=1:length(arrhythmia)
        art=[art, arrhythmia{i}];
    end
    if plot_it
        figure;
        set(gcf, 'Visible', 'off');
        set(gcf, 'WindowState', 'maximized');
        subplot(3,3,1);plot(sig);title ('Input ');
        subplot(3,3,2);plot(lp);title ('LowPass Filter Output');
        subplot(3,3,3);plot(hp);title ('HighPass Filter Output');
        subplot(3,3,4);plot(dif);title ('Differentiation Output');
        subplot(3,3,5);plot(sq);title ('Taking Square Output');
        subplot(3,3,6);plot(int);title ('Taking Integral Output');
        subplot(3,3,7);plot(th,'r');hold on;stem(RR/10,'g');hold on;title ('Thresholding Output vs. R Peaks');
        subplot(3,3,8);plot(hrv);title ('HRV (bpm) Output');
        subplot(3,3,9);text(0.5, 0.5, art, 'FontSize', 12, 'HorizontalAlignment', 'center');
        
        
        saveas(gcf, ['database\JS' num2str(index,'%05.f') '.png']);
        close(gcf);
    end
end