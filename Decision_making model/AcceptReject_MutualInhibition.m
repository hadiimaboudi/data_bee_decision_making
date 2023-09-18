
function [RT_cum,RT,winX]=AcceptReject_MutualInhibition(DriveAcept,DriveReject,sigmaV,Bounds,LeakV,W_iinhibit,initial_value,dt,TimeEnd)

K_leakx=LeakV(1);
K_leaky=LeakV(2);
BoundAccept=Bounds(1);
BoundReject=Bounds(2);
W_inhx=W_iinhibit(1); %% 
W_inhy=W_iinhibit(2); %% 

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
dWx =randn(size(DriveAcept))*dt;
dWy =randn(size(DriveReject))*dt;

dX = (-K_leakx*X-W_inhx*Y+DriveAcept)*dt +sigmaAccept.*dWx;
dY = (-K_leaky*Y-W_inhy*X+DriveReject)*dt+sigmaReject.*dWy;

X = max(X + dX,0);
Y = max(Y + dY,0);

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
