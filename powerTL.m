classdef powerTL
    %POWERTL Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        Rpu;
        Xpu;
        CMVAR;
        Y;
        Yend;
        FromBus;
        ToBus;
        Type;
        Ss;
        Sr;
        Sl;
    end
    
    methods
        function obj=powerTL(InFromBus,InToBus,InType,InRpu,InXpu,InCMVAR)
            obj.FromBus = InFromBus;
            obj.ToBus = InToBus;
            obj.Type = InType;
            obj.Rpu = InRpu;
            obj.Xpu = InXpu;
            obj.CMVAR = InCMVAR;
            obj.Y = 1/(obj.Rpu+j*obj.Xpu);
            switch InType
                case 'Short'
                    obj.Yend = 0; %per end
                otherwise
                    obj.Yend = 1i*obj.CMVAR/2;
            end
        end
            
    end
    
end

