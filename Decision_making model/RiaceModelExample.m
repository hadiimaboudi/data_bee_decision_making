% Race Model
clear all; close all; clc

biaseX=.001;
biaseY=.002;

biaseX=.9;
biaseY=-(1-biaseX);

biaseX=biaseX/50;
biaseY=biaseY/50;

sigmaX=0.1;
sigmaY=0.1;

BoundX=1.1;
BoundY=1;

initial_valuesX=0;
initial_valuesY=0;

NcorrectAcept=0;
NcorrectAcept_In=0;
NcorrectReject=0;
NcorrectReject_In=0;

indCR=1;
indICR=1;
indICA=1;
indCA=1;

RT_CA=[];
RT_ICA=[];
RT_CR=[];
RT_ICR=[];

dt=1;
NTrials=500;

for k=1:NTrials
    
    [Choices, RT, Cumulative]=race_trial(dt, biaseX,biaseY, sigmaX,sigmaY,  BoundX, BoundY, initial_valuesX,initial_valuesY);
    
    ReactionTime(k)=RT;
    
    if (Choices(1)==1 &&  Choices(2)==1 )
        NcorrectAcept=NcorrectAcept+1;
        RT_CA(indCA)=RT;
        indCA=indCA+1;
        
    elseif (Choices(1)==1 &&  Choices(2)==0 )
        NcorrectAcept_In=NcorrectAcept_In+1;
        RT_ICA(indICA)=RT;
        indICA=indICA+1;
    elseif (Choices(1)==0 &&  Choices(2)==1 )
        NcorrectReject=NcorrectReject+1;
        
        RT_CR(indCR)=RT;
        indCR=indCR+1;
        
    elseif (Choices(1)==0 &&  Choices(2)==0 )
        NcorrectReject_In=NcorrectReject_In+1;
        RT_ICR(indICR)=RT;
        indICR=indICR+1;
        
        
    end
    
    
end

figure
subplot(4,2,1)
plot(Cumulative(:,1),'LineWidth',2)
ylim([-BoundX BoundX])

subplot(4,2,2)
plot(Cumulative(:,2),'r','LineWidth',2)
ylim([-BoundY BoundY])

subplot(4,2,3)
hist(RT_CA)

subplot(4,2,4)
hist(RT_CR)

subplot(4,2,5)
hist(RT_ICA)

subplot(4,2,6)
hist(RT_ICR)

subplot(4,1,4)
%bar(100*sum(ChoiceX)/NTrials)
bar(100*[NcorrectAcept,NcorrectAcept_In,NcorrectReject,NcorrectReject_In]/NTrials)
ylim([0 100])

xticks([1 2 3 4])
xticklabels({'CA','IA','CR','IR'})
