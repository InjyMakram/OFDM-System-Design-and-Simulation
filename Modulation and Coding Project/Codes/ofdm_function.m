function [BER] = ofdm_function(N_c, BW, M, SNR, channel_profile)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% bits per symbol
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

bps = log2(M);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% random binary signal
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

N_b = 48000*6;
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

y = qammod(x_s, M,'PlotConstellation',false,'UnitAveragePower',true);


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
    noisy_OFDM_Symbol = awgn(faded_OFDM_Symbol, SNR);
    equalized_OFDM_Symbol = noisy_OFDM_Symbol./rayleighCoefficients;
    received_Symbols = [received_Symbols equalized_OFDM_Symbol];

end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% demodulation
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

x_s_received = qamdemod(received_Symbols, M, UnitAveragePower=true);


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

BER = sum(xor(binary_received,x_b))/N_b;

end