clear all;

% Set default parameters
Num_BS_Antennas = 128;              % The number of antennas at BS 
Num_UE = 16;                        % The number of UEs
SNR = -10:2:16;                     % The range of SNR

MF_Ber = zeros(1, length(SNR));     % The matrix that used to store the BER
ZF_Ber = zeros(1, length(SNR));
WF_Ber = zeros(1, length(SNR));

% Infinite resolution and without CSI estimation error
[MF_Ber(1, :), ZF_Ber(1, :), WF_Ber(1, :)] = Transmit_linear(Num_BS_Antennas, Num_UE, SNR, 1, 0, 0);

figure(4)
QX4 = semilogy(SNR, MF_Ber(1,:), 'b--o', SNR, ZF_Ber(1,:), 'g--x', SNR, WF_Ber(1,:), 'k--+');
set(QX4, 'LineWidth', 2);
xlabel('SNR',  'FontSize', 16);
ylabel('Uncoded BER',  'FontSize', 16);
legend('MF Precoder','ZF Precoder','WF_Precoder');
title('Comparison between different precoders', 'FontSize', 20);
grid on;