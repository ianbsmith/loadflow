classdef powersystem
    %SYSTEM Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        systembusses = powerbus.empty;
        Ybus;
    end
    
    methods
        function obj = powersystem(Busses)
            obj.systembusses = Busses;
        end
        function obj = calculate(obj)
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
                
    end
    
end

