%%%
% This function generates initial channel matrix 
%%%
function [H, H1_est, H2_est, H3_est, H4_est, H5_est, f_dop, f_symb] = Gen_Channel2(Num_UE, Num_BS_Antennas)
    % Dopler shift
    % f_dop = V * f / c, assume frequency at 28GHz, mean speed 5m/s
    % correlation time --- 2ms
    f_dop = 466 + 100 * randn(Num_UE, 1);
    
    
    f_symb = 1000 * 32 * 8;
    t_symb = 1 / f_symb;
    iteration = 20010;
    
    % Each Antenna - UE pair forms a rayleigh fading channel
    H = zeros(Num_UE * Num_BS_Antennas, iteration);
    count = 1;
    
    for m = 1 : Num_UE
         % rayleigh channel requires two parameters, 
         h = rayleighchan(t_symb, f_dop(m));
         h.ResetBeforeFiltering = 1;
         h.StorePathGains = 1;
        for n = 1 : Num_BS_Antennas
               % Construct a Rayleigh Channel for each Antenna-UE pair       
               H(count, :) = filter(h, ones(1, iteration));
               count = count + 1;
        end   
    end
    
    % Extracting channel parameters out from vector to form channel matrix
    multi = 0.1; % error rate
    
    % Real chnnel matrix
    H1 = zeros(Num_UE, Num_BS_Antennas);
    for m = 1 : Num_UE
        H1(m, : ) = H((m - 1) * Num_BS_Antennas + 1 : m * Num_BS_Antennas, 1);
    end

    % Channel matrix with estimation error
    H_err = multi * (randn(Num_UE, Num_BS_Antennas) + 1i * randn(Num_UE, Num_BS_Antennas));
    H1_est = H1 + H_err;

    
    H2 = zeros(Num_UE, Num_BS_Antennas);
    for m = 1 : Num_UE
        H2(m, : ) = H((m - 1) * Num_BS_Antennas + 1 : m * Num_BS_Antennas, 3);
    end

    H_err = multi * (randn(Num_UE, Num_BS_Antennas) + 1i * randn(Num_UE, Num_BS_Antennas));
    H2_est = H2 + H_err;

    
    H3 = zeros(Num_UE, Num_BS_Antennas);
    for m = 1 : Num_UE
        H3(m, : ) = H((m - 1) * Num_BS_Antennas + 1 : m * Num_BS_Antennas, 5);
    end

    H_err = multi * (randn(Num_UE, Num_BS_Antennas) + 1i * randn(Num_UE, Num_BS_Antennas));
    H3_est = H3 + H_err;
    
    H4 = zeros(Num_UE, Num_BS_Antennas);
    for m = 1 : Num_UE
        H4(m, : ) = H((m - 1) * Num_BS_Antennas + 1 : m * Num_BS_Antennas, 7);
    end
    H_err = multi * (randn(Num_UE, Num_BS_Antennas) + 1i * randn(Num_UE, Num_BS_Antennas));
    H4_est = H4 + H_err;
    
    H5 = zeros(Num_UE, Num_BS_Antennas);
    for m = 1 : Num_UE
        H5(m, : ) = H((m - 1) * Num_BS_Antennas + 1 : m * Num_BS_Antennas, 9);
    end
    
    H_err = multi * (randn(Num_UE, Num_BS_Antennas) + 1i * randn(Num_UE, Num_BS_Antennas));
    H5_est = H5 + H_err;
    
end