classdef powerbus
    %BUS Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        type;
        P;
        Q;
        V;
    end
    
    methods
        function obj = initialguess(obj)
            switch obj.type
                case 'PQ'
                    obj.V = 1;
            end
        end
        function obj = powerbus(InType,InP,InQ,InV)
            obj.type = InType;
            obj.P = InP;
            obj.Q = InQ;
            obj.V = InV;
            obj = obj.initialguess;
        end
                  
    end
    
end

