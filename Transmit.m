% InfDAC_Flag = 1;        The flag that denotes whether 1 bit DAC is used
% ErrCha_Flag = 1;        The flag that denotes whether channel estimation error exists
% Rob_Flag = 1;           The flag that denotes whether robust WF precoding is used
% The power contraint Etr is set to 2, in QPSK case equals to the symbol energy
function ZF_Ber = Transmit(Num_BS_Antennas, Num_UE, SNR, H_Total, H1, H3, H5, H7, H9, f_dop, f_slot, InfDAC_Flag, ErrCha_Flag, Rob_Flag)
    
    % Set default modulation scheme QPSK
    % Symbols = [ -3-3i,-3-1i,-3+3i,-3+1i, -1-3i,-1-1i,-1+3i,-1+1i, ...
    %             +3-3i,+3-1i,+3+3i,+3+1i,+1-3i,+1-1i,+1+3i,+1+1i ];
    Symbols = [ -1-1i,-1+1i,1-1i,1+1i ];

    % Average power of symbols and number of bits per symbol
    Power_Symbol = mean(abs(Symbols).^2);
    Power_Total = Power_Symbol * Num_BS_Antennas;
    Power_Total = Power_Total / 2;
    Bits_Per_Symbol = log2(length(Symbols));
   
    rk1 = besselj(0, 2 * pi * 11 * f_dop /  f_slot);
    rk3 = besselj(0, 2 * pi * 9 * f_dop / f_slot);
    rk5 = besselj(0, 2 * pi * 7 * f_dop / f_slot);
    rk7 = besselj(0, 2 * pi * 5 * f_dop / f_slot);
    rk9 = besselj(0, 2 * pi * 3 * f_dop / f_slot);

    for j = 1:length(SNR)

        ZF_BER = zeros(1, 10000);

        % Conduct 1000 times
        for t = 1:10000
            % Generate information bits matrix, B x log2(M), each row represents a symbol
            Bits = randi([0, 1], Num_UE, Bits_Per_Symbol);

            % Convert bits matrix to symbol vector, B x 1
            index_s = bi2de(Bits, 'left-msb') + 1;
            s = Symbols(index_s)';
            
            % Set channel state matrix: U x B,
            % Rayleigh Channel in this time slot
            H = zeros(Num_UE, Num_BS_Antennas);

            for m = 1 : Num_UE
                H(m, : ) = H_Total((m - 1) * Num_BS_Antennas + 1 : m * Num_BS_Antennas, 2 * t + 10);
            end
            
            if ErrCha_Flag == 1
                H_est = H9;
            else
                H_est = H;
            end
            
            % Calculate the precoder matrix, rescale factor Beita and precoded vector x
            % ZF precoder
            if Rob_Flag == 0
                [P1, Beita1, x1] = ZF_Precoder(H_est, s, Power_Symbol, Power_Total, InfDAC_Flag, Num_UE, Num_BS_Antennas);
            else
                %[P1, Beita1, x1] = ZF_Precoder(H_est, s, Power_Symbol, Power_Total, InfDAC_Flag, Num_BS_Antennas);
                %if Quantize_x(Num_UE, H_est * x1) ~= s
                    %disp('error')
                    [P1, Beita1, x1] = Robust_ZF_Precoder(H, H_est, H1, H3, H5, H7, H9, rk1, rk3, rk5, rk7, rk9, s, Power_Symbol, Power_Total, InfDAC_Flag, Num_UE, Num_BS_Antennas);
                %end
            end
            
            % Set noise matrix and calculate the variance
            n = randn(Num_UE, 1)+i * randn(Num_UE, 1);
            n = n / norm(n);
            
            %SNR = trace(H * H') * Power_Total * Num_UE / (Num_BS_Antennas * trace(n * n'))
            N0 = trace(H * (x1 * x1') * H') * Num_UE * 10^(-SNR(j) / 10) / Num_BS_Antennas;
            n = sqrt(N0) * n;
            
            y1 =  (H * x1 +  n) / Beita1;
            
            % Decide the symbols and calculate BER
            ZF_BER(t) = Decider(Num_UE, Symbols, s, y1);
            
            H1 = H3;
            H3 = H5;
            H5 = H7;
            H7 = H9;   
            H_err = randn(Num_UE, Num_BS_Antennas) + 1i * randn(Num_UE, Num_BS_Antennas);
            H_up = zeros(Num_UE, Num_BS_Antennas);
            for m = 1 : Num_UE
                H_up(m, : ) = H_Total((m - 1) * Num_BS_Antennas + 1 : m * Num_BS_Antennas, 2 * t + 9);
                %H_up(m, :) = H_up(m, :) / sqrt(sigma(m) / mean(power(abs(H_up(m,:)), 2)));
            end
            
            H9 = H_up + 0.5 * H_err;
        end
       
        ZF_Ber(j) = sum(ZF_BER) / (10000 * Num_UE);
    end
end