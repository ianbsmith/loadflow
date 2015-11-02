classdef powerbus
    %BUS Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        type;
        P;
        Q;
        V;
        VARCompensated;
        VARComp;
        Qorig;
        Porig;
    end
    
    methods
        function obj = initialguess(obj)
            switch obj.type
                case 'PQ'
                    obj.V = 1;
            end
        end
        function obj = powerbus(InType,InV,InP,InQ)
            obj.type = InType;
            obj.P = InP;
            obj.Q = InQ;
            obj.Qorig = InQ;
            obj.Porig = InP;
            obj.V = InV;
            obj = obj.initialguess;
            obj.VARCompensated = 0;
            obj.VARComp = 0;
            
           
        end
                  
    end
    
end

