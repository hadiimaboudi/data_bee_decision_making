
function [RT_cum,RT,winX]=AcceptReject_BeeDecision(action,DriveInput,sigmaV,Bounds,LeakV,W_inhibitAccept,W_inhibitReject,W_feedback,initial_value,dt,TimeEnd)

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
    MBONx=Kc*DriveInput;
    MBONy=Kc*DriveInput;
else
    MBONx=0;
    MBONy=0;
end



if t<5*dt
 dX = (-K_leakx*X-W_inhx*MBONx+DriveInput)*dt+sigmaAccept.*dWx;
 dY = (-K_leaky*Y-W_inhy*MBONy+DriveInput)*dt+sigmaReject.*dWy;

else
    
 dX = (-K_leakx*X-W_inhx*MBONx+DriveInput-W_feedbackYX*mean(RT_cum(p-2:p-1,2)))*dt+sigmaAccept.*dWx;
 dY = (-K_leaky*Y-W_inhy*MBONy+DriveInput-W_feedbackXY*mean(RT_cum(p-2:p-1,1)))*dt+sigmaReject.*dWy;
    
end

 %dX = (-K_leakx*X-W_inhyx*Y+DriveAcept)*dt +sigmaAccept.*dWx;
 %dY = (-K_leaky*Y-W_inhxy*X+DriveReject)*dt+sigmaReject.*dWy;

  
 X = max(X+dX,0.05);
 Y = max(Y+dY,0.05);

% X = X+dX;
% Y = Y+dY;


Px=1;
Py=1;

Xm=max(Px*X+.05,0.05);
Ym=max(Py*Y+.05,0.05);

RT_cum(p,1)=Xm;
RT_cum(p,2)=Ym;


    if Xm> BoundAccept
        Stopsign=1;
        winX=1;
    end
    
    if Ym> BoundReject
       Stopsign=1;
    end
    
    if t>TimeEnd
    Stopsign=1;
    if (Xm-BoundAccept)<(Ym-BoundReject)
    winX=1;
    end
    end
    
end

RT=t;
