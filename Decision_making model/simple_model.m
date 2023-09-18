function [choice time x] =simple_model(bias, sigma, dt, time_interval,Bound)
x=[0];
time =0;
eps=1e-3;
xnew=0;
%while ((x(end)< Bound || x(end)> -1*Bound) && time< time_interval)
 while abs(xnew)< Bound
%while time< time_interval
%[time xnew]
time =time +dt;
dW =randn * (dt^0.5); % randn is always N(0,1)
dX = bias * dt + sigma * dW;
% add dx to the most previous value of x
xnew=x(length(x))+dX;
x = [x ; xnew];

end
% time is up
choice =x(length(x)) > (Bound-eps);
end