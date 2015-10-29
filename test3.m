clear all;
close all;
mybusses = [powerbus('Ref',0,0,1.04),powerbus('PV',1.2,0,1.02),powerbus('PQ',-1.5,-3.5,0)];
myTLs = [powerTL(1,2,'Short',.3,.6,0),powerTL(1,3,'Short',.1,.2,0),powerTL(2,3,'Short',.125,.25,0)];
mysystem = powersystem(mybusses,myTLs);

mysystemcompd = mysystem.solveloadflowcompensated(99.9999);
mysystem2 = mysystem;
mysystem2 = mysystem2.copyVARCompensators(mysystemcompd);
mysystem2 = mysystem2.solveloadflow(99.9999);
mysystem3 = mysystem2.solveloadflow(99.9999);
if abs(mysystem3.error(mysystem2))>((100-80)/100)
    error('System does not converge!');
end
mysystem2.displaysystembusses(1);