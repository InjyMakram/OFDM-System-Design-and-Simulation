clc 
clear all 
close all
% Define parameters
total_power = 2;

% Initialize sigma(n) for each channel
sigma = [1.5 1 0.75 0.5];

% Initial value of k
k = (total_power + sum(sigma)) / length(sigma);

% Initialize powers
p = k - sigma;

% Waterfilling process
while any(p < 0)
    % Drop negative powers and their correlated noise powers
    negative_indices = find(p < 0);
    p(negative_indices) = [];
    sigma(negative_indices) = [];
    
    % Update k based on remaining  non-negative powers
    k = (total_power + sum(sigma)) / length(sigma);
    
    % Recalculate powers
    p = k - sigma;
end

% Calculate capacity for each user after checking that all powers are
% positive
capacity = log2(1 + p ./ sigma);
Total_capacity=sum(capacity)
disp('Capacity for each user:');
disp(capacity);
