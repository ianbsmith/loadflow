clear all;
close all;
mysystem = powersystem([powerbus('Ref',0,0,1.04),powerbus('PV',1.2,0,1.02),powerbus('PQ',-1.5,-.5,0)]);
mysystem.Ybus = -1i.*[[6.67,-1.67,-5];[-1.67,5.67,-4];[-5,-4,9]];