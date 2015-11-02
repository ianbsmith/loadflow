clear all;
close all;

mybusses = [powerbus('Ref',1.04,0,0),powerbus('PV',1.02,1.2,0),powerbus('PQ',1,-1.5,0)];
myTLs = [powerTL(1,2,'Med',.2,.5,4/100),powerTL(1,3,'Med',.2,.6,4/100),powerTL(2,3,'Med',.2,.3,4/100)];
mysystem = powersystem(mybusses,myTLs);

mysystem2 = mysystem.solveloadflowcompensated(99.999999999);
mysystem2.displaysystembusses(1);
mysystem2 = mysystem2.displayflows;
mysystem2 = mysystem2.displaysystemflows;