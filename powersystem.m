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
        function obj = calculate(obj)
            obj.runnum = obj.runnum + 1;
            for b = 1:length(obj.systembusses)
                switch obj.systembusses(b).type
                    case 'PV'
                        I = Iarray(obj,0);
                        obj.systembusses(b).Q = -imag(conj(obj.systembusses(b).V)*I(b,1));
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
        function maxerror = error(obj,prev)
            error = zeros(2*length(obj.systembusses),1);
            for b = 1:length(obj.systembusses)
                error(b) = (abs(obj.systembusses(b).V) - abs(prev.systembusses(b).V))/abs(prev.systembusses(b).V);
                error(b+1) = (angle(obj.systembusses(b).V) - angle(prev.systembusses(b).V))/angle(prev.systembusses(b).V);
            end
            maxerror = max(error);
        end       
        function obj = solve(obj,desirederror)
            prev = obj;
            obj = obj.calculate;
            prev = obj;
            obj = obj.calculate;
            while obj.error(prev)*100.>(100.-abs(desirederror))
                prev = obj;
                obj = obj.calculate;
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
        function obj = calculatecompensated(obj,solvedsys)
            obj.runnum = obj.runnum + 1;
            for b = 1:length(obj.systembusses)
                switch obj.systembusses(b).type
                    case 'PV'
                        I = Iarray(obj,0);
                        obj.systembusses(b).Q = -imag(conj(obj.systembusses(b).V)*I(b,1));
                        I = Iarray(obj,b);
                        obj.systembusses(b).V = abs(obj.systembusses(b).V)*exp(1i*angle(1/obj.Ybus(b,b)*((obj.systembusses(b).P-1i*obj.systembusses(b).Q)/conj(obj.systembusses(b).V)-I(b,1))));
                    case 'PQ'
                        if abs(solvedsys.systembusses(b).V)<.96
                            obj.systembusses(b).VARCompensated = 1;
                            switch obj.systembusses(b).Q<0
                                case 1
                                    NewQ = -(obj.systembusses(b).Q-obj.systembusses(b).VARComp)*.99;
                                    obj.systembusses(b).Q = obj.systembusses(b).Q - obj.systembusses(b).VARComp + NewQ;
                                    obj.systembusses(b).VARComp = NewQ;
                            end
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
        function obj = solvecompensated(obj,desirederror)
            prev = obj;
            obj = obj.calculate;
            prev = obj;
            obj = obj.calculate;
            while obj.error(prev)*100.>(100.-abs(desirederror))
                prev = obj;
                obj = obj.calculate;
            end
            solvedregular = obj;
            prev = obj;
            obj = obj.calculatecompensated(solvedregular);
            prev = obj;
            obj = obj.calculatecompensated(solvedregular);
            while obj.error(prev)*100.>(100.-abs(desirederror))
                prev = obj;
                obj = obj.calculatecompensated(solvedregular);
            end
            prev = obj;
            obj = obj.calculate;
            prev = obj;
            obj = obj.calculate;
            while obj.error(prev)*100.>(100.-abs(desirederror))
                prev = obj;
                obj = obj.calculate;
            end
        end
    end
    
end

