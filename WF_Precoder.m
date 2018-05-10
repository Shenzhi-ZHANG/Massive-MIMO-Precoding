%%%
% Wiener Precoder
%%%
function [P, Beita, x] = WF_Precoder(H, s, n, Power_Symbol, Power_Total,InfDAC_Flag,Num_BS_Antennas, Num_UE)
    n_power = mean(abs(n).^2); 
    
    F = H' * H + (trace(n_power * eye(Num_UE)) / Power_Total) * eye(Num_BS_Antennas);
    Beita = sqrt(Power_Total / trace(inv(F) * inv(F) * H' * Power_Symbol * H));
    P = Beita * inv(F) * H';
    x = P * s;  
    
     % 1 bit DAC processing
    if InfDAC_Flag == 0
           % 1 bit DAC processing
            x = Quantize_x(Power_Total, Num_BS_Antennas, Num_UE, x);
    end
end