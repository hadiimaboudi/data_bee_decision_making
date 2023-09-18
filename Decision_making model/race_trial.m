function [Choices, RT, Cumulative]=race_trial(dt, biaseX,biaseY, sigmaX,sigmaY,  BoundX, BoundY, initial_valuesX,initial_valuesY)


% The discrete version of the diffusion drift model can accommodate a two threshold paradigm, but even with two thresholds, the single iterator allows for only a single set of bias and
% variance values. Under some two choice scenarios, the race model may be a better match.
% Under the race model, each of the two choices has an independent iterator and threshold. The first process whose accumulated evidence exceeds its threshold is the choice of
% the system. This choice “wins the race.”
% The function below simulates a multiple choice task with free response. Parameters are
% vectors with length equal to the numbers of choices in the task. To specify a set of choices, set
% the parameters to vectors whose length is equal to the number of choices desired for the task.
% It should be noted that while the race model has been demonstrated to account accurately for experimental results in tasks with two choices, the appropriateness of multiple
% choice models is a subject of active debate.

X=initial_valuesX;
Y=initial_valuesY;
t=0;
Stopsign=0;
winX=0;
p=0;

while Stopsign==0
    p=p+1;
    
t= t + dt;
% draw from Weiner process
dWy =randn(size(biaseY))*dt;
dWx =randn(size(biaseX))*dt;

dY = biaseY * dt +sigmaY.*dWy;
dX = biaseX * dt +sigmaX.*dWx;

X = X + dX;
Y = Y + dY;

Cumulative(p,1)=X;
Cumulative(p,2)=Y;


    if abs(X)> BoundX
        Stopsign=1;
        winX=1;
    end
    
    if abs(Y)> BoundY
       Stopsign=1;
    end
    

end

if  winX==1 &&  X> BoundX
    Choices=[1 1];
elseif winX==1 &&  X< BoundX 
    Choices=[1 0];
elseif winX==0 &&  Y> BoundX
       Choices=[0 1];
elseif winX==0 &&  Y< BoundX
    Choices=[0 0];
end

RT=t;

end