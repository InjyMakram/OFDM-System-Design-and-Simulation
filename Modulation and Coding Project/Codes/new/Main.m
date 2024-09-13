clear
close all
clc

% Initializing Variables
BW = 20e6;
%No. of sub-carriers
N_c = 1024;
%No. of bits
N_b = 1000; 
      %Average power/Path & Multi-path reference delay
channel_profile = [0        0.485; 
                   310e-9   0.3852;
                   710e-9   0.0611;
                   1090e-9  0.0485;
                   1730e-9  0.0153;
                   2510e-9  0.0049]; 

SNR = [0:2:40];
%Initializing BER Arrays to store the values at each iteration
BER_4 = zeros(1, length(SNR)); 
BER_16 = zeros(1, length(SNR));
BER_64 = zeros(1, length(SNR));

for i=1:1:length(SNR)
    %Get BER values from ofdm_function and store it in the array 
    ber = ofdm_function(N_c, BW, 4, SNR(i), channel_profile);
    BER_4(i) = ber;
    ber = ofdm_function(N_c, BW, 16, SNR(i), channel_profile);
    BER_16(i) = ber;
    ber = ofdm_function(N_c, BW, 64, SNR(i), channel_profile);
    BER_64(i) = ber;
end


% Plotting SNR vs BER on a semi-logarithmic scale
figure;
hold on;
semilogy(SNR, BER_4, 'DisplayName', 'M = 4','LineWidth',2);
semilogy(SNR, BER_16, 'DisplayName', 'M = 16','LineWidth',2);
semilogy(SNR, BER_64, 'DisplayName', 'M = 64','LineWidth',2);
title("SNR vs BER performance of OFDM with various QAM constellations");
legend("M = 4", "M = 16", "M = 64");
xlabel("SNR");
ylabel("BER");