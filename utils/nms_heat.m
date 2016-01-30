function m = nms_heat(x,t)
x = padarray(x,[1,1],-inf,'both');
LT = x(2:end-1,2:end-1) > x(1:end-2,1:end-2);
LB = x(2:end-1,2:end-1) > x(3:end,1:end-2);
RT = x(2:end-1,2:end-1) > x(1:end-2,3:end);
RB = x(2:end-1,2:end-1) > x(3:end,3:end);
T = x(2:end-1,2:end-1) > x(1:end-2,2:end-1);
B = x(2:end-1,2:end-1) > x(3:end,2:end-1);
L = x(2:end-1,2:end-1) > x(2:end-1,1:end-2);
R = x(2:end-1,2:end-1) > x(2:end-1,3:end);

S = x(2:end-1,2:end-1) > t;
m = LT & LB & RT & RB & T & B & L & R & S;
