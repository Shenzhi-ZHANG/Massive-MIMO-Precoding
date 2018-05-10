function [P, Beita, x] = Robust_ZF_Precoder(H_rea, H_est, H1, H3, H5, H7, H9, rk1, rk3, rk5, rk7, rk9, s, Power_Symbol, Power_Total, InfDAC_Flag, Num_UE, Num_BS_Antennas)
    
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
    Seita = diag(seita);
    
    P = H' * (H * H' + Num_BS_Antennas * Seita)^-1;
    Beita = sqrt(Power_Total / trace(P * s * s' * P'));
    P = Beita * P;
    
    % Initialize parameters in the loop
    G = sqrt(inv(diag(diag(P * P'))));
    W = G^-1;
    G_init = G;
    P_init = P;
    
    % Calculate the expected diagonal matrix
    V = H' * (H * H')^-1;
    V_abs = power(abs(V), 2);
    D = sqrt(diag((V_abs' * V_abs)^-1 * V_abs' * ones(Num_BS_Antennas, 1)));
    
    error1 = 1;
    error2 = 1;
    count = 0;

    MSE_2 = trace((P - W * V * D) * (P - W * V * D)');
    
    % Gradient descent algorithm
    while  ((error1 > -1) && (count <= 20) && (error2 > -1))
        MSE_1 = MSE_2;
        P_former = P;
     
        P = P - 0.05 * conj((conj(P) - W^-1 * diag(diag(P * D * V')) * conj(P)/ 2 - diag(diag(W^-1 * V * D * P')) * conj(P) / 2 + diag(diag(V * D * D * V')) * conj(P)));
        G = sqrt(inv(diag(diag(P * P'))));
        W = sqrt(diag(diag(P * P')));
        error1 = MSE_1 - MSE_2;

        if error1 < -0.0001
            P =  P_former;
            error1 = -1;
        end
        count = count + 1;
    end
   
    % Use the precoding matrix that creates noiseless received signal far away from deciding boundary
   if trace((H * G_init * P_init * s) * (H * G_init * P_init * s)') > trace((H * G * P * s) * (H * G * P * s)')
       P = P_init;
   end
   
   x = P * s;
    % 1 bit DAC processing
    if InfDAC_Flag == 1
         x = Quantize_x(Power_Total, Num_BS_Antennas, Num_UE, x);
    end
end