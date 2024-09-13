function [BER] = ofdm_function(N_c, BW, M, SNR, channel_profile)
    % Bits per symbol.
    bps = log2(M);

    % Adjust N_b to be divisible by bps.
    N_b = 1000;  
    N_b = N_b - mod(N_b, bps); % Ensure this is divisible by bps.

    % Random binary signal.
    x_b = randi([0 1], 1, N_b);

    % Converts Bits to symbols 
    N_s = N_b / bps; %calculate the number of symbols. 
    x_s = zeros(1, N_s);% to store the symbols.
    index = 1;
    %convert each group of bits into symbols.
    for i = 1:bps:N_b
        accumulator = 0;
        for n = 0:bps-1
            accumulator = accumulator + (x_b(i+n))*(2^n);
        end
        x_s(index) = accumulator;
        index = index + 1;
    end

    % QAM Modulation
    y = qammod(x_s, M, 'PlotConstellation', false , 'UnitAveragePower', true);% M is modulation ex: order 2 for BPSK,
                                                                                                         %4 for QAM.
    % Multi-path Channel Loop
    received_Symbols = [];
    N_OFDM_Symbols = ceil(N_s / N_c);  % Adjusted to handle non-divisible cases.
    
    % Zero-pad y to fit the OFDM symbols by ensuring that each OFDM symbol has N_c subcarriers.
    y = [y zeros(1, N_OFDM_Symbols * N_c - N_s)];  

    for OFDM_Symbol = 1:N_OFDM_Symbols
        index = (OFDM_Symbol - 1) * N_c + 1; %calculates the starting index.
        current_OFDM_Symbol = y(index:index+N_c-1); % extracts the current OFDM symbol.
        rayleighCoefficients = getChannelCoefficients(N_c, BW, channel_profile);
        %apply the Rayleigh fading coefficients to the current OFDM symbol to simulate multipath fading. 
        faded_OFDM_Symbol = current_OFDM_Symbol .* rayleighCoefficients;
        %Add AWGN noise to the faded OFDM symbol to simulate noise.
        noisy_OFDM_Symbol = awgn(faded_OFDM_Symbol, SNR);
        
        %Equalization
        
        equalized_OFDM_Symbol = noisy_OFDM_Symbol ./ rayleighCoefficients; %cancel the effect of the channel.
        received_Symbols = [received_Symbols equalized_OFDM_Symbol]; %Append equalizaed OFDM symbols.
    end

    % Check the received OFDM Symbols
    if isempty(received_Symbols)
        error('received_Symbols is empty');
    end

    % Demodulation
    x_s_received = qamdemod(received_Symbols, M, 'PlotConstellation', false ,'UnitAveragePower', true);

    % Check OFDM symbol_received
    if isempty(x_s_received)
        error('x_s_received is empty');
    end

    % convert Symbols to bits
    binary_received = zeros(1, length(x_b));
    for i = 1:N_s
        temp = de2bi(x_s_received(i), bps);
        binary_received((i-1)*bps+1:i*bps) = temp;
    end

    % Results
    BER = sum(xor(binary_received, x_b)) / N_b;
end
