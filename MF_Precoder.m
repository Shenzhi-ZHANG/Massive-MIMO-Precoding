function [P, Beita, x] = MF_Precoder(H,s,Power_Symbol, Power_Total,InfDAC_Flag,Num_BS_Antennas)
    Beita = sqrt( Power_Total / trace(H' * Power_Symbol * H));   
    P =  Beita * H';
    x = P * s;
    % 1 bit DAC processing
    x = Quantize_x(Power_Total, Num_BS_Antennas, Num_UE, x);
end