clear all;
close all;

clear all;
close all;

mybusses = [powerbus('Ref',1.04,-.65/100,-.3/100),powerbus('PQ',1,-1.15/100,-.6/100),powerbus('PV',1.02,(1.8-.7)/100,-.4/100),powerbus('PQ',1,-.7/100,-.3/100),powerbus('PQ',1,-.85/100,-.4/100)];
myTLs = [powerTL(1,2,'Med',.042,.168,4.1/100),powerTL(1,5,'Med',.031,.126,3.1/100),powerTL(2,3,'Med',.031,.126,3.1/100),powerTL(3,4,'Med',.084,.336,8.2/100),powerTL(3,5,'Med',.053,.210,5.1/100),powerTL(5,4,'Med',.063,.252,6.1/100)];
orig = powersystem(mybusses,myTLs);

error = 99.999999999;
basic = orig.solveloadflow(error,0);
basic.displaysystembusses(1);
basic = basic.displayflows;
basic = basic.displaysystemflows;

% compd = orig.solveloadflowcompensated(error);
% compd.displaysystembusses(1);
% compd = compd.displayflows;
% compd = compd.displaysystemflows;