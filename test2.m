clear all;
close all;
mybusses = [powerbus('Ref',0,0,1.04),powerbus('PV',1.2,0,1.02),powerbus('PQ',-1.5,-.5,0)];
myTLs = [powerTL(1,2,0,.6,0),powerTL(1,3,0,.2,0),powerTL(2,3,0,.25,0)];
mysystem = powersystem(mybusses,myTLs);

mysystem = mysystem.solve(99.99999);
mysystem.displaysystem(1)