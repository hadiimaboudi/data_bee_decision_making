
function [RT_cum,RT,winX]=AcceptReject_BeeDecision23(action,DriveInput,sigmaV,Bounds,LeakV,W_inhibitAccept,W_inhibitReject,W_feedback,initial_value,dt,TimeEnd)

Kc=1;

if action==1 
W_inhx=W_inhibitAccept(1); %% 
W_inhy=W_inhibitAccept(2); %% 
else
W_inhx=W_inhibitReject(1); %% 
W_inhy=W_inhibitReject(2); %%  
end

K_leakx=LeakV(1);
K_leaky=LeakV(2);

BoundAccept=Bounds(1);
BoundReject=Bounds(2);

W_feedbackXY=W_feedback(1);
W_feedbackYX=W_feedback(2);

sigmaAccept=sigmaV(1);
sigmaReject=sigmaV(2);

X=initial_value(1);
Y=initial_value(2);


Stopsign=0;
winX=0;
p=0;
t=0;

while Stopsign==0
    
p=p+1;   
t=t+dt;

% draw from Weiner process
dWx =randn(size(DriveInput))*dt;
dWy =randn(size(DriveInput))*dt;

% dX = (-K_leakx*X-W_inhx*Y+DriveAcept)*dt +sigmaAccept.*dWx;
% dY = (-K_leaky*Y-W_inhy*X+DriveReject)*dt+sigmaReject.*dWy;

if t>3*dt
    
    MBONx=Kc*Y;
    MBONy=Kc*X;
else
    MBONx=0;
    MBONy=0;
end

 dX = (-K_leakx*X-W_inhx*MBONx+DriveInput)*dt+sigmaAccept.*dWx;
 dY = (-K_leaky*Y-W_inhy*MBONy+DriveInput)*dt+sigmaReject.*dWy;

 %dX = (-K_leakx*X-W_inhyx*Y+DriveAcept)*dt +sigmaAccept.*dWx;
 %dY = (-K_leaky*Y-W_inhxy*X+DriveReject)*dt+sigmaReject.*dWy;

if t>5*dt
X = max(X+dX-W_feedbackYX*mean(RT_cum(p-2:p-1,2)),0);
Y = max(Y+dY-W_feedbackXY*mean(RT_cum(p-2:p-1,1)),0);

else    
X = max(X+dX,0);
Y = max(Y+dY,0);
end


RT_cum(p,1)=X;
RT_cum(p,2)=Y;


    if X> BoundAccept
        Stopsign=1;
        winX=1;
    end
    
    if Y> BoundReject
       Stopsign=1;
    end
    
    if t>TimeEnd
    Stopsign=1;
    if (X-BoundAccept)<(Y-BoundReject)
    winX=1;
    end
    end
    
end

RT=t;
