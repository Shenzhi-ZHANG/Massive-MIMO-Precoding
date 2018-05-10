function x = Robust_DAC(H_est, b, Num_BS_Antennas, Power_Total)
    
    b_real = real(b);
    thresh = mean(abs(b_real));
    check = zeros(1, 2 * Num_BS_Antennas);
    count = 1;
    for j = 1 :2 *  Num_BS_Antennas
        if abs(b_real(j)) < 0.99 * thresh
            check(count) = j;
            count = count + 1;
        end
    end
    
    x_temp = sqrt(Power_Total / (2 * Num_BS_Antennas)) * sign(b);
    
    for k = 1 : count-1
         x_temp(check(k)) = sqrt(Power_Total / (2 * Num_BS_Antennas));
         x = x_temp(1 : Num_BS_Antennas) + 1i * x_temp(Num_BS_Antennas + 1: 2 * Num_BS_Antennas);
         tr_pos = trace((H_est * x)*(H_est * x)');
         x_temp(check(k)) = -sqrt(Power_Total / (2 * Num_BS_Antennas));
         x = x_temp(1 : Num_BS_Antennas) + 1i * x_temp(Num_BS_Antennas + 1: 2 * Num_BS_Antennas);
         tr_neg = trace((H_est * x)*(H_est * x)');
         
         if (tr_pos > tr_neg)
             x_temp(check(k)) = sqrt(Power_Total / (2 * Num_BS_Antennas));
         else
              x_temp(check(k)) = -sqrt(Power_Total / (2 * Num_BS_Antennas));
         end
    end
    
    x = x_temp(1 : Num_BS_Antennas) + 1i * x_temp(Num_BS_Antennas + 1: 2 * Num_BS_Antennas);
end