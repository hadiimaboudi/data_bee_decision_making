%% Bee decision Model 
clear all; close all; clc
%%%  paramters of the model
% Stumulus=.1; % this is a value between +1 and -1. positive and nagative balues represent the degree of postive and negative valuance of the stimulus 
% 
% if Stumulus>0
% DriveAccept=Stumulus;
% DriveReject=1-Stumulus;
% else
% DriveAccept=1+Stumulus;
% DriveReject=-Stumulus;
% end


Stumulus=.9;% show the strongest of the stimulus (0 1)
StrgSti=.02;
VarRand=1e-3;

BoundAccept=1.5;
BoundReject=1;

sigmaAccept=0.1;
sigmaReject=0.1;

initial_valueA=0; % this presents the bee bias to one of the training stimuli. 
initial_valueR=0;

dt=1;
TimeEnd=200;


NTrials=1000;
Trial_index=randi([0 1],[1 NTrials]);
NumCR=0;
NumICR=0;
NumCA=0;
NumICA=0;
RT_CA=[];
RT_ICR=[]; 
RT_ICA=[];
RT_CR=[];

for k=1:length(Trial_index)
    if Trial_index(k)==1
        posSti=Stumulus+VarRand*randn;
        driveA=posSti;
        driveR=1-posSti;
        
        DriveAccept=StrgSti*driveA;
        DriveReject=StrgSti*driveR;
        
        [RT_cumul,RT,winX]=DecsionModel_AcceptReject(DriveAccept,DriveReject,sigmaAccept,sigmaReject,BoundAccept,BoundReject,initial_valueA,initial_valueR,dt,TimeEnd);

        if winX==1
            NumCA=NumCA+1;
            RT_CA(NumCA)=RT;
            
        else
            NumICR=NumICR+1;
            RT_ICR(NumICR)=RT;
            
        end
        
    else  % Visiting the negative stimuli
        
        negSti=-Stumulus+VarRand*randn;
        driveA=1+negSti;
        driveR=-negSti;
        
        DriveAccept=StrgSti*driveA;
        DriveReject=StrgSti*driveR;
        
        
        [RT_cumul,RT,winX]=DecsionModel_AcceptReject(DriveAccept,DriveReject,sigmaAccept,sigmaReject,BoundAccept,BoundReject,initial_valueA,initial_valueR,dt,TimeEnd);
        
        if winX==1
            NumICA=NumICA+1;
            RT_ICA(NumICA)=RT;
            
        else
            NumCR=NumCR+1;
            RT_CR(NumCR)=RT;
            
        end
    end
    k
end

figure
subplot(3,2,1)
plot(RT_cumul(:,1),'LineWidth',1.5,'Color',[0.4660 0.6740 0.1880])
ylim([-BoundAccept-.5 BoundAccept+.5])
yline(BoundAccept,'.-r','Threshold Accept');
yline(-BoundAccept,'.-r');

subplot(3,2,2)
plot(RT_cumul(:,2),'Color',[0.4940 0.1840 0.5560],'LineWidth',1.5)
ylim([-BoundReject-.5 BoundReject+.5])

yline(BoundReject,'.-r','Threshold Reject');
yline(-BoundReject,'.-r');

subplot(3,2,3)
xbin=0:10:300;

h1 = histogram(RT_CA,xbin);
hold on
h2 = histogram(RT_ICA,xbin);

h1.Normalization = 'probability';
h2.Normalization = 'probability';

h1.FaceColor = [0.4660 0.6740 0.1880];
h2.FaceColor = .2*[0.4660 0.6740 0.1880];
h1.EdgeColor = 'r';
h2.EdgeColor = 'r';

subplot(3,2,4)
h1 = histogram(RT_CR,xbin);
hold on
h2 = histogram(RT_ICR,xbin);

h1.Normalization = 'probability';
h2.Normalization = 'probability';

h1.FaceColor = [0.4940 0.1840 0.5560];
h2.FaceColor = .2*[0.4940 0.1840 0.5560];
h1.EdgeColor = 'w';
h2.EdgeColor = 'w';

subplot(3,2,5)
%bar(100*sum(ChoiceX)/NTrials)

bar(100*[NumCA,NumICA,0,NumCR,NumICR]/NTrials)
ylim([0 100])
xticks([1 2 3 4 5])
xticklabels({'CA','IA','','CR','IR'})

subplot(3,2,6)
bar([mean(RT_CA),mean(RT_ICA),0,mean(RT_CR),mean(RT_ICR)])
xticks([1 2 3 4 5])
xticklabels({'CA','IA','','CR','IR'})


%%

%% Bee decision Model 
clear all; close all; clc
%%%  paramters of the model
% Stumulus=.1; % this is a value between +1 and -1. positive and nagative balues represent the degree of postive and negative valuance of the stimulus 
% 
% if Stumulus>0
% DriveAccept=Stumulus;
% DriveReject=1-Stumulus;
% else
% DriveAccept=1+Stumulus;
% DriveReject=-Stumulus;
% end

Model='IndepdentPathway';
%Model='easy';
%Model='hard';
Model='Transfer';


switch Model

     case 'IndepdentPathway'
Stumulus=.9;% show the strongest of the stimulus (0 1)
StrgSti=.03; % .02 for the learning test. 
VarRand=1e-3;
Bounds=[3 1];

LeakV=[0 0];
W_iinhibit=[0.00 0.00];
initial_value=[0 0];
sigmaV=[0.1 0.1];

dt=1;
TimeEnd=1000;
NTrials=100;

    case 'easy'
Stumulus=.8;% show the strongest of the stimulus (0 1)
StrgSti=.03; % .02 for the learning test. 
VarRand=1e-3;
Bounds=[1.1 .9];

LeakV=[0.001 0.001];
W_iinhibit=[0.01 0.09];
initial_value=[0 0];
sigmaV=[0.1 0.1];

dt=1;
TimeEnd=2000;
NTrials=100;

    case 'hard'
        
Stumulus=.55;% show the strongest of the stimulus (0 1)
StrgSti=.03; % .02 for the learning test. 
VarRand=1e-3;
Bounds=[1.1 .9];

LeakV=[0.001 0.001];
W_iinhibit=[0.01 0.04];
initial_value=[0 0];

sigmaV=[0.1 0.1];

initial_valueA=0; % this presents the bee bias to one of the training stimuli. 
initial_valueR=0;
dt=1;
TimeEnd=2000;
NTrials=100;
    case 'Transfer'
Stumulus=.9;% show the strongest of the stimulus (0 1)
StrgSti=.006; % .02 for the learning test. 
VarRand=1e-3;

Bounds=[1.1 .9];

LeakV=[0.001 0.001];
W_iinhibit=[0.11 0.11];
initial_value=[0 0];
sigmaV=[0.1 0.1];

dt=1;
TimeEnd=2000;
NTrials=100;

end



for bee=1:50
    
Trial_index=randi([0 1],[1 NTrials]);
NumCR=0;
NumICR=0;
NumCA=0;
NumICA=0;
RT_CA=[];
RT_ICR=[]; 
RT_ICA=[];
RT_CR=[];

for k=1:length(Trial_index)
    
    if Trial_index(k)==1 % Visiting the poistive stimuli
        posSti=Stumulus+VarRand*randn;
        driveA=posSti;
        driveR=1-posSti;
        
        DriveAccept=StrgSti*driveA;
        DriveReject=StrgSti*driveR;
        
      %  [RT_cumul,RT,winX]=DecsionModel_AcceptReject(DriveAccept,DriveReject,sigmaAccept,sigmaReject,BoundAccept,BoundReject,initial_valueA,initial_valueR,dt,TimeEnd);
        [RT_cumul,RT,winX]=AcceptReject_MutualInhibition(DriveAccept,DriveReject,sigmaV,Bounds,LeakV,W_iinhibit,initial_value,dt,TimeEnd);
        
        CumSignal{k}=RT_cumul;
 
        if winX==1
            NumCA=NumCA+1;
            RT_CA(NumCA)=RT;
            
        else
            NumICR=NumICR+1;
            RT_ICR(NumICR)=RT;
            
        end
        
    else  % Visiting the negative stimuli
        
        negSti=-Stumulus+VarRand*randn;
        driveA=1+negSti;
        driveR=-negSti;
        
        DriveAccept=StrgSti*driveA;
        DriveReject=StrgSti*driveR;
        
        
        %[RT_cumul,RT,winX]=DecsionModel_AcceptReject(DriveAccept,DriveReject,sigmaAccept,sigmaReject,BoundAccept,BoundReject,initial_valueA,initial_valueR,dt,TimeEnd);
         [RT_cumul,RT,winX]=AcceptReject_MutualInhibition(DriveAccept,DriveReject,sigmaV,Bounds,LeakV,W_iinhibit,initial_value,dt,TimeEnd);
        
         
        CumSignal{k}=RT_cumul;

        if winX==1
            NumICA=NumICA+1;
            RT_ICA(NumICA)=RT;
            
           
        else
            NumCR=NumCR+1;
            RT_CR(NumCR)=RT;
            
        end
    end
    
    
    [bee k]
    
    Perf(bee,:)=[NumCA,NumICA,NumCR,NumICR];
    ReactionTime(bee,:)=[mean(RT_CA),mean(RT_ICA),mean(RT_CR),mean(RT_ICR)];
end

end

%
C1=[0.4660 0.6740 0.1880];
C2=[0.4940 0.1840 0.5560];
figure
subplot(3,2,1)
plot(RT_cumul(:,1),'LineWidth',1.5,'Color',C1)
ylim([-Bounds(1)-.5 Bounds(1)+.5])
yline(Bounds(1),'.-r','Threshold Accept');
yline(-Bounds(1),'.-r');

subplot(3,2,2)
plot(RT_cumul(:,2),'Color',C2,'LineWidth',1.5)
ylim([-Bounds(2)-.5 Bounds(2)+.5])

yline(Bounds(2),'.-r','Threshold Reject');
yline(-Bounds(2),'.-r');

subplot(3,2,3)
xbin=0:10:300;

h1 = histogram(RT_CA,xbin);
hold on
h2 = histogram(RT_ICA,xbin);

h1.Normalization = 'probability';
h2.Normalization = 'probability';

h1.FaceColor = C1;
h2.FaceColor = .2*C1;
h1.EdgeColor = 'r';
h2.EdgeColor = 'r';

subplot(3,2,4)
h1 = histogram(RT_CR,xbin);
hold on
h2 = histogram(RT_ICR,xbin);

h1.Normalization = 'probability';
h2.Normalization = 'probability';

h1.FaceColor = C2;
h2.FaceColor = .2*C2;
h1.EdgeColor = 'w';
h2.EdgeColor = 'w';

subplot(3,2,5)
%bar(100*sum(ChoiceX)/NTrials)

meanPerf=nanmean(100*Perf/NTrials);
stdPerf=nanstd(100*Perf/NTrials)/sqrt(size(Perf,1));

bar([meanPerf(1) 0 0 0 0],'FaceColor',C1)
hold on 
bar([0 meanPerf(2) 0 0 0],'FaceColor',.8*C1)
bar([0 0 0 meanPerf(3) 0],'FaceColor',C2)
bar([0 0 0 0 meanPerf(4)],'FaceColor',.2*C2)

errorbar([meanPerf(1),meanPerf(2),0,meanPerf(3),meanPerf(4)],[stdPerf(1),stdPerf(2),0,stdPerf(3),stdPerf(4)],'.k')
ylim([0 100])
xticks([1 2 3 4 5])
xticklabels({'CA','IA','','CR','IR'})

subplot(3,2,6)

meanReactionTime=nanmean(ReactionTime);
stdReactionTime=nanstd(ReactionTime)/sqrt(size(ReactionTime,1));


bar([meanReactionTime(1) 0 0 0 0],'FaceColor',C1)
hold on 
bar([0 meanReactionTime(2) 0 0 0],'FaceColor',.2*C1)
bar([0 0 0 meanReactionTime(3) 0],'FaceColor',C2)
bar([0 0 0 0 meanReactionTime(4)],'FaceColor',.6*C2)

errorbar([meanReactionTime(1),meanReactionTime(2),0,meanReactionTime(3),meanReactionTime(4)],...
    [stdReactionTime(1),stdReactionTime(2),0,stdReactionTime(3),stdReactionTime(4)],'.k')
xticks([1 2 3 4 5])
xticklabels({'CA','IA','','CR','IR'})


%%

figure 
for k=1:5%length(CumSignal)
    
RT_cumul=CumSignal{k};
subplot(1,2,1)
plot(RT_cumul(:,1),'LineWidth',1.5,'Color',C1)
hold on

subplot(1,2,2)
plot(RT_cumul(:,2),'Color',C2,'LineWidth',1.5)
hold on
end


subplot(1,2,1)
ylim([-.5 BoundAccept+.5])
yline(BoundAccept,'.-r','Threshold Accept');

subplot(1,2,2)
ylim([-.5 BoundReject+.5])

yline(BoundReject,'.-r','Threshold Reject');
