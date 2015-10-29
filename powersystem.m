classdef powersystem
    %SYSTEM Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        systembusses = powerbus.empty;
        Ybus;
        runnum;
        systemTLs = powerTL.empty;
    end
    
    methods
        function obj = powersystem(Busses,TLs)
            obj.systembusses = Busses;
            obj.systemTLs = TLs;
            obj = obj.generateYbus;
            obj.runnum = 0;
        end
        function obj = generateYbus(obj)
            obj.Ybus = zeros(length(obj.systembusses),length(obj.systembusses));
            for i = 1:length(obj.systemTLs)
                obj.Ybus(obj.systemTLs(i).FromBus,obj.systemTLs(i).ToBus) = obj.Ybus(obj.systemTLs(i).FromBus,obj.systemTLs(i).ToBus) - (obj.systemTLs(i).Y);
                obj.Ybus(obj.systemTLs(i).ToBus,obj.systemTLs(i).FromBus) = obj.Ybus(obj.systemTLs(i).ToBus,obj.systemTLs(i).FromBus) - (obj.systemTLs(i).Y);
                obj.Ybus(obj.systemTLs(i).ToBus,obj.systemTLs(i).ToBus) = obj.Ybus(obj.systemTLs(i).ToBus,obj.systemTLs(i).ToBus) + (obj.systemTLs(i).Y);
                obj.Ybus(obj.systemTLs(i).FromBus,obj.systemTLs(i).FromBus) = obj.Ybus(obj.systemTLs(i).FromBus,obj.systemTLs(i).FromBus) + (obj.systemTLs(i).Y);
            end
        end
        function obj = calculateloadflow(obj)
            obj.runnum = obj.runnum + 1;
            for b = 1:length(obj.systembusses)
                switch obj.systembusses(b).type
                    case 'PV'
                        I = Iarray(obj,0);
                        obj.systembusses(b).Q = obj.systembusses(b).Qorig -imag(conj(obj.systembusses(b).V)*I(b,1));
                        I = Iarray(obj,b);
                        obj.systembusses(b).V = abs(obj.systembusses(b).V)*exp(1i*angle(1/obj.Ybus(b,b)*((obj.systembusses(b).P-1i*obj.systembusses(b).Q)/conj(obj.systembusses(b).V)-I(b,1))));
                    case 'PQ'
                        I = Iarray(obj,b);
                        obj.systembusses(b).V = (1/obj.Ybus(b,b)*((obj.systembusses(b).P-1i*obj.systembusses(b).Q)/conj(obj.systembusses(b).V)-I(b,1)));
                    case 'Ref'
                        I = Iarray(obj,-1);
                        S = conj(obj.systembusses(b).V)*I(b,1);
                        obj.systembusses(b).P = real(S);
                        obj.systembusses(b).Q = imag(S);
                end
            end
        end
        function I = Iarray(obj,except)
            I = zeros(length(obj.systembusses),1);
            for k = 1:length(obj.systembusses)
                for n = 1:length(obj.systembusses)
                    switch except==n
                        case 1
                            I(k,1) = I(k,1) + 0;
                        otherwise
                            I(k,1) = I(k,1) + obj.Ybus(k,n)*obj.systembusses(n).V;
                    end
                end
            end
        end
        function I = Iarraypick(obj,except,selectedvoltage)
            I = zeros(length(obj.systembusses),1);
            for k = 1:length(obj.systembusses)
                for n = 1:length(obj.systembusses)
                    switch except==n
                        case 1
                            I(k,1) = I(k,1) + 0;
                        otherwise
                            I(k,1) = I(k,1) + obj.Ybus(k,n)*selectedvoltage;
                    end
                end
            end
        end
        function maxerror = error(obj,prev)
            error = zeros(2*length(obj.systembusses),1);
            for b = 1:length(obj.systembusses)
                error(b) = (abs(obj.systembusses(b).V) - abs(prev.systembusses(b).V))/abs(prev.systembusses(b).V);
                error(b+1) = (angle(obj.systembusses(b).V) - angle(prev.systembusses(b).V))/angle(prev.systembusses(b).V);
            end
            maxerror = abs(max(error));
        end
        function minvoltage = minvoltage(obj)
            voltage = zeros(length(obj.systembusses),1);
            for b = 1:length(obj.systembusses)
                voltage(b) = abs(obj.systembusses(b).V);
            end
            minvoltage = min(voltage);
        end 
        function obj = solveloadflow(obj,desirederror)
            prev = obj;
            obj = obj.calculateloadflow;
            prev = obj;
            obj = obj.calculateloadflow;
            while obj.error(prev)*100.>(100.-abs(desirederror))
                prev = obj;
                obj = obj.calculateloadflow;
            end
        end
        function displaysystembusses(obj,runs)
            s = sprintf('After %d Runs:',obj.runnum);
            if runs==1
                disp(s);
            end
            for b = 1:length(obj.systembusses)
                s = sprintf('Bus %d (%s Bus): V=%0.3f@%0.3f%c Vpu, P=%0.3f Wpu, Q= %0.3f VARpu',b,obj.systembusses(b).type,abs(obj.systembusses(b).V),angle(obj.systembusses(b).V)/(2*pi)*360,char(176),obj.systembusses(b).P,obj.systembusses(b).Q);
                if obj.systembusses(b).VARCompensated
                    s = strcat(s,sprintf(', Static VAR Compensated, X=%0.4f Ohms(pu)',(abs(obj.systembusses(b).V)^2/obj.systembusses(b).VARComp)));
                end
                disp(s);
            end
        end
        function obj = calculateloadflowcompensated(obj,solvedsys)
            obj.runnum = obj.runnum + 1;
            for b = 1:length(obj.systembusses)
                switch obj.systembusses(b).type
                    case 'PV'
                        I = Iarray(obj,0);
                        obj.systembusses(b).Q = obj.systembusses(b).Qorig - imag(conj(obj.systembusses(b).V)*I(b,1));
                        I = Iarray(obj,b);
                        obj.systembusses(b).V = abs(obj.systembusses(b).V)*exp(1i*angle(1/obj.Ybus(b,b)*((obj.systembusses(b).P-1i*obj.systembusses(b).Q)/conj(obj.systembusses(b).V)-I(b,1))));
                    case 'PQ'
                        if abs(solvedsys.systembusses(b).V)<.96
                            obj.systembusses(b).VARCompensated = 1;
                            I = Iarraypick(solvedsys,b,.99);
                            NewQ = (-solvedsys.systembusses(b).Q - real(((1*exp(1i*angle(solvedsys.systembusses(b).V))*solvedsys.Ybus(b,b)+I(b,1))*conj(solvedsys.systembusses(b).V)-solvedsys.systembusses(b).P)/(-1i)));
                            obj.systembusses(b).Q = obj.systembusses(b).Q - obj.systembusses(b).VARComp + NewQ;
                            obj.systembusses(b).VARComp = NewQ;
                        end
                        I = Iarray(obj,b);
                        obj.systembusses(b).V = (1/obj.Ybus(b,b)*((obj.systembusses(b).P-(1i*(obj.systembusses(b).Q)))/conj(obj.systembusses(b).V)-I(b,1)));
                    case 'Ref'
                        I = Iarray(obj,-1);
                        S = conj(obj.systembusses(b).V)*I(b,1);
                        obj.systembusses(b).P = real(S);
                        obj.systembusses(b).Q = imag(S);
                end
            end
        end
        function obj = solveloadflowcompensated(obj,desirederror)
            prev = obj;
            obj = obj.calculateloadflow;
            prev = obj;
            obj = obj.calculateloadflow;
            while obj.error(prev)*100.>(100.-abs(desirederror))
                prev = obj;
                obj = obj.calculateloadflow;
            end
            solvedregular = obj;
            prev = obj;
            obj = obj.calculateloadflowcompensated(solvedregular);
            prev = obj;
            obj = obj.calculateloadflowcompensated(solvedregular);
            while obj.error(prev)*100.>(100.-abs(desirederror)) || obj.minvoltage<.96
                prev = obj;
                obj = obj.calculateloadflowcompensated(prev);
            end
            prev = obj;
            obj = obj.calculateloadflow;
            prev = obj;
            obj = obj.calculateloadflow;
            while obj.error(prev)*100.>(100.-abs(desirederror))
                prev = obj;
                obj = obj.calculateloadflow;
            end
        end
        function obj = copyVARCompensators(obj,compd)
            for i=1:length(obj.systembusses)
                obj.systembusses(i).VARComp = compd.systembusses(i).VARComp;
                obj.systembusses(i).VARCompensated = compd.systembusses(i).VARCompensated;
                obj.systembusses(i).Q = compd.systembusses(i).Q;
            end
        end
    end
    
end

