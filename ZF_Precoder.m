function [P, Beita, x] = ZF_Precoder(H, s, Power_Symbol, Power_Total,InfDAC_Flag,Num_UE, Num_BS_Antennas)
    Beita = sqrt( Power_Total / trace((inv(H*H')) * Power_Symbol));   
    P =  Beita * H' * inv((H * H'));
    x = P * s;
    % 1 bit DAC processing
    if (InfDAC_Flag)
        x = Quantize_x(Power_Total, Num_BS_Antennas, Num_UE, x);
    end
    
end