close all;

%% DDM Model 
bias=.01;
sigma=.1;
dt=.1;
time_interval=500;
Bound=1;
NTrials=100;
choice=[];
time=[];
for k=1:NTrials
    [c time x] =simple_model(bias, sigma, dt, time_interval,Bound)
choice(k) =c;
timeall(k)=time;
end

figure 
subplot(1,3,1)
plot(x)
subplot(1,3,2)
hist(timeall)
subplot(1,3,3)

bar(100*sum(choice)/NTrials)
ylim([0 100])