function [Xps_train,Xps_val,Xps_test,Tps_train,Tps_val,Tps_test] = generate_training_validation_testing_data(Xps,Tps)

% This function generates training, validation and testing patterns given 
% the past time series sequences and the corresponding time instances stored 
% in matrices Xps and Tps. The fraction of data instances to be utilized as
% training patterns is determined by the input numbers for training,
% validation and testing. For example 0.6, 0.1 and the rest 0.3 respectively.

Nps = length(Tps);
% test_cutoff = round(0.3*Nps);
% train_cutoff = round(training_percentage*Nps);
train_cutoff = round(0.6*Nps); % training_percentage = 0.6
val_cutoff = round(0.1*Nps); % validation_percentage = 0.1
% Tps_train = Tps(1:cutoff);
% Tps_test = Tps(cutoff+1:Nps);
Tps_train = Tps(1:train_cutoff);
Tps_val = Tps(train_cutoff+1:train_cutoff+val_cutoff);
Tps_test = Tps(train_cutoff+val_cutoff+1:Nps);
% Xps_train = Xps(1:cutoff,:);
% Xps_val = Xps(1:cutoff,:);
% Xps_test = Xps(cutoff+1:Nps,:);
Xps_train = Xps(1:train_cutoff,:);
Xps_val = Xps(train_cutoff+1:train_cutoff+val_cutoff,:);
Xps_test = Xps(train_cutoff+val_cutoff+1:Nps,:);

end