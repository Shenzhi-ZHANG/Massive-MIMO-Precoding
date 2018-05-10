%%% 
% This function determines the received symbol and counts the bit(symbol)
% error rate.
%%%
function BER = Decider(Num_UE, Symbols, s, y)
    Decision = zeros(Num_UE, 1);
    for l = 1 : Num_UE
        % Compare the received symbol with QPSK symbols
        % Choose the QPSK symbol that is closest to received symbol
        Dist_Min = abs(Symbols(1) - y(l));
        Decision(l) = Symbols(1);
        for k = 2 : length(Symbols)
            dist = abs(Symbols(k) - y(l));
            if (dist < Dist_Min)
                Dist_Min = dist;
                Decision(l) = Symbols(k);
            end
        end
    end

    % Count the number of bit error(actually symbol error rate)
    BER = 0;
    for  k = 1 : Num_UE
        if abs(Decision(k) - s(k)) > 0
            BER = BER + 1;
        end
    end  