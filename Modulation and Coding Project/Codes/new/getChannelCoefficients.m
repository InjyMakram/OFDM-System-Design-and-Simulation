%Get phi and multiply with h to get H[n]
%in our case H(n)=
%h_0+h_1.exp(-j*phi_1)+h_2.exp(-j*phi_2)+h_3.exp(-j*phi_3)+h_4.exp(-j*phi_4)+h_5.exp(-j*phi_5)
function [coefficients] = getChannelCoefficients(N_c, BW, profile)
    % Get the number of paths from the profile matrix
    [paths, ~] = size(profile);
    coefficients = zeros(1, N_c);
    T_s = N_c / BW;

    % Generate Rayleigh channel coefficients
    for i = 1:N_c
        accumulator = 0;
        for k = 1:paths
            amplitude = sqrt(exprnd(1)) * sqrt(profile(k, 2));
            %"exprnd(1)" generates an exponential random variable with mean 1.
            %"sqrt(profile(k, 2))" is the square root of the average power of the corresponding resolvable path.
            
            phase = 2 * pi * rand; 
            %"rand" generates a uniformly distributed random variable between 0 and 1.
            %Phase is still randomly from 0:2*pi
            
            partial_sum = amplitude * exp(1j * phase) * exp(-1j * profile(k, 1) * 2 * pi * (i - 1) / T_s);
            accumulator = accumulator + partial_sum;
        end
        coefficients(i) = accumulator;
    end
end
