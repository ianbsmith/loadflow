clear all;
close all;
mysystem = powersystem([powerbus('Ref',0,0,1),powerbus('PV',.6,0,1),powerbus('PQ',-.8,-.6,0)]);
mysystem.Ybus = -1i.*[[7,-2,-5];[-2,6,-4];[-5,-4,9]];

mysystem = mysystem.solvecompensated(99.99999);
mysystem.displaysystem(1);