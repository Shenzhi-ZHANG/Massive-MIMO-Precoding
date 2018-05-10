function H = Robust_CSI(H1, H3, H5, H7, H9, rk1, rk3, rk5, rk7, rk9, Num_UE, Num_BS_Antennas)
    
    % Predict CSI in current time slot
    Rk = zeros(5, 5);
    for m = 1 : Num_UE
        for n = 1 : Num_BS_Antennas
            Rk = Rk + [H9(m,n); H7(m,n); H5(m,n); H3(m,n); H1(m,n)] * [H9(m,n); H7(m,n); H5(m,n); H3(m,n); H1(m,n)]';
        end
    end
    Rk = Rk / (Num_UE * Num_BS_Antennas);
    
    H = zeros(Num_UE, Num_BS_Antennas);
    seita = zeros(Num_UE, 1);
    for m = 1 : Num_UE
        rk = [rk9(m); rk7(m); rk5(m); rk3(m); rk1(m)];
        for n = 1 : Num_BS_Antennas     
            H(m,n) = rk' * Rk^-1 * [H9(m,n); H7(m,n); H5(m,n); H3(m,n); H1(m,n)];
        end
        seita(m) = (1 - rk' * Rk^-1 * rk);
    end
    
end