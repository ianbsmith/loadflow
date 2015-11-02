clear all;
close all;

mybusses = [powerbus('Ref',0,0,1),powerbus('PV',1.2,0,1),powerbus('PQ',-1.5,0,1)];
myTLs = [powerTL(1,2,'Short',0,.5,0),powerTL(2,3,'Short',0,.5,0)];
mysystem = powersystem(mybusses,myTLs);

mysystem2 = mysystem.solveloadflow(99.999999999,0);
mysystem2.displaysystembusses(1);
mysystem2 = mysystem2.displayflows;
mysystem2 = mysystem2.displaysystemflows;