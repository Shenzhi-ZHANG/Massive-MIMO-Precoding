%%%
% This function simulates the source generation, precoding, transmission
% and deciding at receiver end.
% Parameters:
%   InfDAC_Flag = 1;                The flag that denotes whether 1 bit DAC is used
%   ErrCha_Flag = 1;                The flag that denotes whether channel estimation error exists
%   Rob_Flag = 1;                   The flag that denotes whether robust WF precoding is used
%   The power contraint Etr is set to 2, in QPSK case equals to the symbol energy

function [MF_Ber, ZF_Ber, WF_Ber] = Transmit_linear(Num_BS_Antennas, Num_UE, SNR, InfDAC_Flag, ErrCha_Flag, Rob_Flag)
    
    % Set default modulation scheme QPSK
    Symbols = [ -1-1i,-1+1i,1-1i,1+1i ];

    % Average power of symbols and number of bits per symbol
    Power_Symbol = mean(abs(Symbols).^2);           % Symbol Power = 2 in QPSK
    Power_Total = Power_Symbol * Num_BS_Antennas;   % Total Power of sending signal
    Power_Total = Power_Total / 2;                  
    Bits_Per_Symbol = log2(length(Symbols));        % 2 bit for each symbol
    
    Quantize_Bits = 256;
    
    for j = 1:length(SNR)   % for each SNR

        % Record the bit error for each precoder
        ZF_BER = zeros(1, 1000);
        WF_BER = zeros(1, 1000);
        MF_BER = zeros(1, 1000);
       
        % Experiment 1000 times
        for t = 1:1000
            
            % Generate information bits matrix, B x log2(M), each row represents a symbol
            Bits = randi([0, 1], Num_UE, Bits_Per_Symbol);

            % Convert bits matrix to symbol vector, B x 1
            index_s = bi2de(Bits, 'left-msb') + 1; % convert binary to decimal
            s = Symbols(index_s)';                 % index into the symbols array
            
            % Set channel state matrix: U x B,
            H = randn(Num_UE, Num_BS_Antennas)+ 1i * randn(Num_UE, Num_BS_Antennas);
            H  = H / norm(H); % Unit Norm
           
            if ErrCha_Flag == 1
                H_err = randn(Num_UE, Num_BS_Antennas)+ 1i * randn(Num_UE, Num_BS_Antennas);
                H_err = H_err / norm(H_err);
                H_err = 1.0* H_err;
                H_est = H + H_err;
                H_est = H_est / norm(H_est);
            else
                H_est = H;
            end
            
            % Set noise matrix and calculate the variance
            n = randn(Num_UE, 1)+i * randn(Num_UE, 1);
            n = n / norm(n);
            
            % SNR = Power_Total * Num_UE / (Num_UE * trace(n * n'))
            N0 = Power_Total * Num_UE * 10^(-SNR(j) / 10) / Num_BS_Antennas;
            n = sqrt(N0) * n;
            
            % Calculate the precoder matrix, rescale factor Beita and precoded vector x
            % ZF precoder
            [P1, Beita1, x1] = ZF_Precoder(H_est, s, Power_Symbol, Power_Total, InfDAC_Flag, Num_BS_Antennas);
            % WF precoder
            if Rob_Flag == 0
                [P2, Beita2, x2] = WF_Precoder(H_est, s, n, Power_Symbol, Power_Total, InfDAC_Flag, Num_BS_Antennas, Num_UE);
            else
                [P2, Beita2, x2] = Robust_WF_Precoder(H_est, s, n, Power_Symbol, Power_Total, InfDAC_Flag, Num_BS_Antennas, Num_UE, Quantize_Bits, ave_norm);
            end
            % MF precoder
            [P3, Beita3, x3] = MF_Precoder(H_est, s, Power_Symbol, Power_Total, InfDAC_Flag, Num_BS_Antennas);        
            
            y1 =  (H * x1 +  n) / Beita1;
            y2 =  (H * x2 +  n) / Beita2;
            y3 =  (H * x3 +  n) / Beita3;
            
            % Decide the symbols and calculate BER
            ZF_BER(t) = Decider(Num_UE, Symbols, s, y1);
            WF_BER(t) = Decider(Num_UE, Symbols, s, y2);
            MF_BER(t) = Decider(Num_UE, Symbols, s, y3);

        end
        
        ZF_Ber(j) = sum(ZF_BER) / (1000 * Num_UE);
        WF_Ber(j) = sum(WF_BER) / (1000 * Num_UE);
        MF_Ber(j) = sum(MF_BER) / (1000 * Num_UE);
    end
end