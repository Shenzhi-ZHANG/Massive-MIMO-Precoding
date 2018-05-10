clear all;

% Set default parameters
Num_BS_Antennas = 128;              % The number of antennas at BS 
Num_UE = 8;                         % The number of UEs
SNR = -10:2:26;                     % The range of SNR

ZF_Ber = zeros(6, length(SNR));

% Generate Rayleigh Channel
[H, H1, H3, H5, H7, H9, f_dop, f_slot] = Gen_Channel2(Num_UE, Num_BS_Antennas);

% 1 bit DAC + perfect CSI + non Robust
ZF_Ber(1, :) = Transmit(Num_BS_Antennas, Num_UE, SNR, H, H1, H3, H5, H7, H9, f_dop, f_slot, 0, 0, 0);

% 1 bit DAC + perfect CSI + Robust
ZF_Ber(2, :) = Transmit(Num_BS_Antennas, Num_UE, SNR, H, H1, H3, H5, H7, H9, f_dop, f_slot, 0, 0, 1);

% infinite DAC + imperfect CSI + non Robust
ZF_Ber(3, :) = Transmit(Num_BS_Antennas, Num_UE, SNR, H, H1, H3, H5, H7, H9, f_dop, f_slot, 1, 1, 0);

% Infinite resolution + imperfect CSI + Robust
ZF_Ber(4, :) = Transmit(Num_BS_Antennas, Num_UE, SNR, H, H1, H3, H5, H7, H9, f_dop, f_slot, 1, 1, 1);

% 1 bit DAC + imperfect CSI + non Robust
ZF_Ber(5, :) = Transmit(Num_BS_Antennas, Num_UE, SNR, H, H1, H3, H5, H7, H9, f_dop, f_slot, 0, 1, 0);

% 1 bit DAC  + imperfect CSI + Robust
ZF_Ber(6, :) = Transmit(Num_BS_Antennas, Num_UE, SNR, H, H1, H3, H5, H7, H9, f_dop, f_slot, 0, 1, 1);

figure(1)
QX1 = semilogy(SNR, ZF_Ber(1,:), 'b--o', SNR, ZF_Ber(2,:), 'g--x', SNR, ZF_Ber(3,:), 'y--s', SNR, ZF_Ber(4,:), 'k--+', SNR, ZF_Ber(5,:), 'm--*', SNR, ZF_Ber(6,:), 'c--p');
ylim([10^(-6), 1]);
set(QX1, 'LineWidth', 3);
xlabel('SNR',  'FontSize', 20);
ylabel('Uncoded BER',  'FontSize', 20);
legend('CxZF: 1 bit DAC with perfect H', 'RxZF: 1 bit DAC with perfect H','CxZF: Infinite Resolution with Imperfect CSI', 'RxZF: Infinite Resolution with Imperfect CSI', 'CxZF: 1 bit DAC with Imperfect CSI',  'RxZF: 1 bit DAC with Imperfect CSI');
title('ZF precoding', 'FontSize', 24);
grid on;