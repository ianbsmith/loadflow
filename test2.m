clear all;
close all;
mysystem = powersystem([powerbus('Ref',0,0,1.04),powerbus('PV',1.2,0,1.02),powerbus('PQ',-1.5,-4,0)],powerTL.empty);
mysystem.Ybus = -1i.*[[6.67,-1.67,-5];[-1.67,5.67,-4];[-5,-4,9-3.85]];
mysystem.Ybus(3,3) = mysystem.Ybus(3,3);

mysystem = mysystem.solve(99.99999);
mysystem.displaysystembusses(1)

clear all;
close all;

mybusses = [powerbus('Ref',0,0,1.04),powerbus('PV',1.2,0,1.02),powerbus('PQ',-1.5,-4,0)];
myTLs = [powerTL(1,2,0,.6,0),powerTL(1,3,0,.2,0),powerTL(2,3,0,.25,0)];
mysystem = powersystem(mybusses,myTLs);

mysystem = mysystem.solvecompensated(99.99999);
mysystem.displaysystembusses(1);