% This script file sets up a Multi-Layer Feed-Forward Neural Network 
% in order to predict the future values of the S&P 500 index as a function 
% of time and its past values. The daily values of the stock market index
% are normalized through logarithmization while the time values are
% normalized in the [1/N,1] interval.

clc
clear all

% Load daily time series data from file: SP500.mat
load('SP500.mat');

% SP500: is a structure variable containing daily values for quantities that
% specifically relate to the S&P 500 stock market index for the time period  
% between 1/1/1950 and 1/1/2015, that is a total amount of 16355 entries.

% The individual variables stored within the structure variable include the 
% following fields:
% (i)   AdjClose: row vector storing the adjusted closing value per day.
% (ii)  Date: cell array storing row-wise the corresponding dates.
% (iii) High: row vector storing the highest index value per day.
% (iv)  Low: row vector storing the highest index value per day.
% (v)   Close: row vector storing the closing index value per day.
% (vi)  Open: row vector storing the opening index value per day.
% (vi)  Volume: row vector storing the daily volume of transactions.

% Set the variable X under investigation to be the adjusted closing value
% of the index.
X = SP500.AdjClose;

% Get the number of observations.
N = length(X);

% Set X observations in ascending time order.
X = X(N:-1:1);

% Set the vector of corresponding time instances.
t = [1:1:N];

% Plot the original time series.
figure('Name','Original S&P 500 Time Series');
plot(t,X,'-.','LineWidth',1.8);
ylabel('Adjusted Closing Value');
xlabel('Time');
grid on

% Normalize the time series under investigation.
X_norm = log(X);
t_norm = t ./ N;

% Plot normalized time series.
figure('Name','Normalized S&P 500 Time Series');
plot(t_norm,X_norm,'-.','LineWidth',1.8);
ylabel('Adjusted Closing Value');
xlabel('Time');
grid on

% Set the time window of past values to be utilized.
time_window = 10;

% Generate the appropriate sequences of past time series  
% (normalized) data for the given time window.
[Xps_norm,Tps] = generate_past_sequences(X_norm,time_window);

% Set training, validation and testing (normalized) data instances.
[Xps_norm_train,Xps_norm_val,Xps_norm_test,Tps_train,Tps_val,Tps_test] = generate_training_validation_testing_data(Xps_norm,Tps);

% -------------------------------------------------------------------------
% TRAINING MODE:
% -------------------------------------------------------------------------
% Set training data patterns and corresponding targets (normalized).
Pnorm = [Xps_norm_train(:,2:end),Tps_train];
Tnorm = Xps_norm_train(:,1);
% Transposition of training patterns and corresponding targets (normalized).
Pnorm = Pnorm';
Tnorm = Tnorm';

% Set the neural network for the normalized version of input variables.
net = newff(Pnorm,Tnorm,[8 4 4 1],{'tansig' 'tansig' 'tansig' 'purelin'});
% Initialize network object.
init(net);
% Set internal network parameters.
net.trainParam.epochs = 1000;
net.trainParam.showCommandLine = 1;
net.trainParam.goal = 10^(-5);
% Train network object.
net = train(net,Pnorm,Tnorm);
% Get network predictions on training data.
Yps_norm_train = sim(net,Pnorm);
% Compute the corresponding RMSE value.
RMSE_norm_train = sqrt(mean((Yps_norm_train-Tnorm).^2));

% -------------------------------------------------------------------------
% VALIDATION MODE:
% -------------------------------------------------------------------------
% Set validation data patterns and corresponding targets (normalized).
Pnorm = [Xps_norm_val(:,2:end),Tps_val];
Tnorm = Xps_norm_val(:,1);
% Transposition of training patterns and corresponding targets (normalized).
Pnorm = Pnorm';
Tnorm = Tnorm';

% Get network predictions on normalized validation data.
Yps_norm_val = sim(net,Pnorm);
% Compute the corresponding RMSE value for the normalized validation data.
RMSE_norm_val = sqrt(mean((Yps_norm_val-Tnorm).^2));

% -------------------------------------------------------------------------
% TESTING MODE:
% -------------------------------------------------------------------------
% Set testing data patterns and corresponding targets (normalized).
Pnorm = [Xps_norm_test(:,2:end),Tps_test];
Tnorm = Xps_norm_test(:,1);
% Transposition of training patterns and corresponding targets (normalized).
Pnorm = Pnorm';
Tnorm = Tnorm';

% Get network predictions on normalized testing data.
Yps_norm_test = sim(net,Pnorm);
% Compute the corresponding RMSE value for the normalized testing data.
RMSE_norm_test = sqrt(mean((Yps_norm_test-Tnorm).^2));
% Plot corresponding fitting performance.
figure_name = 'S&P 500 Normalized Values';
plot_fitting_performance(figure_name,Xps_norm_train(:,1),Tps_train,Yps_norm_train,Xps_norm_val(:,1),Tps_val,Yps_norm_val,Xps_norm_test(:,1),Tps_test,Yps_norm_test)

% Output training, validation and testing performance metrics in terms of RMSE.
fprintf('RMSE TRAINING: %f\n',RMSE_norm_train);
fprintf('RMSE VALIDATION: %f\n',RMSE_norm_val);
fprintf('RMSE TESTING: %f\n',RMSE_norm_test);

% -------------------------------------------------------------------------
% INVESTMENT ALGORITHM:
% -------------------------------------------------------------------------
Wo = 1;
DYt_estimate = Tnorm-Yps_norm_test;
z = sign(DYt_estimate);
DYt = diff(Yps_norm_test);
x = sign(DYt);
plot(DYt_estimate,z);
plot(DYt,x);
ylim([-1 1]);
grid on
limit = RMSE_norm_val;
for l1 = 0:0.01:1
    for l2 = 0:0.01:1
        if DYt_estimate > limit/2
            Wt = Wo + (l1 * Wo);
        else
            Wt = Wo - (l1 * Wo);
        end
        if DYt_estimate > limit/2
            Wt = Wo + (l1 * Wo) + l2 * (Wo + (l1 * Wo));
        else
            Wt = Wo + (l1 * Wo) - l2 * (Wo - (l1 * Wo));
        end
    end
end
Pt = z*Wt;
Wfinal = Wo+sum(Pt);
fprintf('Wfinal: %f\n',Wfinal);