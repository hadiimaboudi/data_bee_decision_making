function [RT_cum,RT,winX]=DecsionModel_AcceptReject (DriveAcept, DriveReject,sigmaAccept,sigmaReject,BoundAccept,BoundReject,initial_valueA,initial_valueR,dt,TimeEnd)



X=initial_valueA;
Y=initial_valueR;

Stopsign=0;
winX=0;
p=0;
t=0;

while Stopsign==0
    
p=p+1;   
t= t+dt;

% draw from Weiner process
dWx =randn(size(DriveAcept))*dt;
dWy =randn(size(DriveReject))*dt;

dX = DriveAcept*dt +sigmaAccept.*dWx;
dY = DriveReject*dt +sigmaReject.*dWy;

X = X + dX;
Y = Y + dY;

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
    (X-BoundAccept)<(Y-BoundReject);
    winX=1;
    end
    
end

RT=t;
