clear
close all
clc

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% setup
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

BW = 20e6;
N_c = 1024;
channel_profile = [0e-9 0.485; 310e-9 0.3852;
    710e-9 0.0611; 1090e-9 0.0485; 1730e-9 0.0153; 2510e-9 0.0049];


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% QAM order ( 4 / 16 / 64 )
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

M = 4;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% bits per symbol
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

bps = log2(M);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% random binary signal
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

N_b = 720000;
x_b = randi([0 1],1,N_b);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% bits to symbols
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

N_s = N_b / bps;
x_s = zeros(1, N_s);

index = 1;
for i=1:bps:N_b
    accumulator = 0;
    for n=0:1:bps-1
        accumulator = accumulator + (x_b(i+n))*(2^n);
    end
    x_s(index) = accumulator;
    index = index + 1;
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% QAM
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

y = qammod(x_s, M,'PlotConstellation',true);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Multi-path Channel Loop
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

received_Symbols = [];
N_OFDM_Symbols = N_s/N_c;

% channel loop

for OFDM_Symbol = 1:1:N_OFDM_Symbols
    
    index = (OFDM_Symbol - 1)*N_c + 1;
    current_OFDM_Symbol = y(index:1:index+N_c-1);

    rayleighCoefficients = getChannelCoefficients(N_c, BW, channel_profile);
    faded_OFDM_Symbol = current_OFDM_Symbol.*rayleighCoefficients;
    noisy_OFDM_Symbol = awgn(faded_OFDM_Symbol, 30);
    equalized_OFDM_Symbol = noisy_OFDM_Symbol./rayleighCoefficients;
    received_Symbols = [received_Symbols equalized_OFDM_Symbol];

end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% demodulation
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

x_s_received = qamdemod(received_Symbols, M);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% symbols to bits
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

binary_received = zeros(1, length(x_b));
for i=1:1:N_s
    temp = de2bi(x_s_received(i), bps);
    binary_received((i-1)*bps+1:1:(i-1)*bps+bps) = temp;
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% results
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

BER = sum(xor(binary_received,x_b))/N_b

color = "yellow";
colors = repelem(color, N_s);

scatfig = scatterplot(received_Symbols);
xlim([-bps bps])
ylim([-bps bps])
title("Scatter Plot of Received Symbols")
grid on;
ax = gca;
ax.LineWidth = 2;