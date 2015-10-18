classdef powerTL
    %POWERTL Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        Rpu;
        Xpu;
        CCurrent;
        Y;
        Yend;
        FromBus;
        ToBus;
    end
    
    methods
        function obj=powerTL(InFromBus,InToBus,InRpu,InXpu,InCCurrent)
            obj.FromBus = InFromBus;
            obj.ToBus = InToBus;
            obj.Rpu = InRpu;
            obj.Xpu = InXpu;
            obj.CCurrent = InCCurrent;
            obj.Y = 1/(obj.Rpu+j*obj.Xpu);
        end
            
    end
    
end

