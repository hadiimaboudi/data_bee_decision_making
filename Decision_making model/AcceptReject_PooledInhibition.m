
function [RT_cum,RT,winX]=AcceptReject_PooledInhibition(DriveAcept,DriveReject,sigmaV,Bounds,LeakV,W_lateralInhibit,W_feedback,V_pooled,W_pooled2Acc,initial_value,dt,TimeEnd)

K_leakx=LeakV(1);
K_leaky=LeakV(2);
K_leakz=LeakV(3);

BoundAccept=Bounds(1);
BoundReject=Bounds(2);

W_inhxy=W_lateralInhibit(1); %% 
W_inhyx=W_lateralInhibit(2); %% 

V_pooledx=V_pooled(1);
V_pooledy=V_pooled(2);

W_pooled2Accx=W_pooled2Acc(1);
W_pooled2Accy=W_pooled2Acc(2);


W_feedbackXY=W_feedback(1);
W_feedbackYX=W_feedback(2);


sigmaAccept=sigmaV(1);
sigmaReject=sigmaV(2);

x=initial_value(1);
y=initial_value(2);
z=initial_value(3);

Stopsign=0;
winX=0;
p=0;
t=0;

X=0;
Y=0;


RT_cum([1 5],1)=0;
RT_cum([1 5],2)=0;


while Stopsign==0
    
p=p+1;   
t=t+dt;

% draw from Weiner process
dWx =randn(size(DriveAcept))*dt;
dWy =randn(size(DriveReject))*dt;

% dX = (-K_leakx*X-W_inhx*Y+DriveAcept)*dt +sigmaAccept.*dWx;
% dY = (-K_leaky*Y-W_inhy*X+DriveReject)*dt+sigmaReject.*dWy;

 dx = (-K_leakx*x-W_inhyx*y-W_pooled2Accx*z+DriveAcept)*dt +sigmaAccept.*dWx;
 dy = (-K_leaky*y-W_inhxy*x-W_pooled2Accy*z+DriveReject)*dt+sigmaReject.*dWy;
 dz= (-K_leakz*z+V_pooledx*x+V_pooledy*y)*dt;
 
 if t>2*dt
 x=x-W_feedbackYX*mean(RT_cum(p-2:p-1,2))+dx;
 y=y-W_feedbackXY*mean(RT_cum(p-2:p-1,1))+dy;
 z=max(z+dz,0);
 
 else
     
 x=x+dx;
 y=y+dy;
 z=max(z+dz,0); 
 end
 


X = max(x,0);
Y = max(y,0);



RT_cum(p,1)=X;
RT_cum(p,2)=Y;
RT_cum(p,3)=z;



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
