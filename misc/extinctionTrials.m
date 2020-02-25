%% Extinction
% This script takes .sums.csv files from fishspy-plot-results outputs 
% all data into .csv files for import into Graphpad.
%
% Note, when running fishspy-plot-results, use the following syntax:
% FISHSPY_SUM_CSWINDOW=0:.1 FISHSPY_SHOW_RAW=false FISHSPY_SUM_DUTY=true 
% fishspy-plot-results fishID.events.csv FishID.frame_measures.csv
%
%

function [] = extinctionTrials(fishID,filePath,numRounds,CSV_Loc)
% fishID: list of RIDs of zebrafish behavior subjects in extinction trials.
% filePath: The file path leading to the .csv files generated from
%       fishspy-plot-results
% numRounds: vector with the total number of rounds for habituation,
%       training and testing (e.g., [20,20,30])
% CSV_Loc: path to where you want to output the .csv files for inputting
%       into e.g., Graphpad  
    
%% Input Files from the excel files made previously
% Read the matrices for each that were exported from fishspy-plot-results
    % Data is arranged as "Duty Cycle": ratio of "active" frames to total 
    % frames within the sampling window.  i.e. it is unweighted but 
    % normalized to the window width.  so it corresponds to the standard 
    % definition of "duty cycle" to measure periodic activity density.
    % Keep columns that tell the "duty cycle" column that gives an
    % indication of activity.
TotMat = repmat(NaN,sum(numRounds),length(fishID));
for i = 1:length(fishID)
    tmpName = [filePath,fishID{i},'.sums.csv'];
    opts = detectImportOptions(tmpName);
    % Note: in the .csv generated from fishspy-plot-results, the 3rd column
    %   holds the proper data
    opts.SelectedVariableNames = 3;
    tempMat = readmatrix(tmpName,opts);
    TotMat(1:size(tempMat,1),i) = tempMat;
end

%% Organizing data
%
% Only consider testing rounds in the data (which occur after habituation
% and training.

extinMat = TotMat(sum(numRounds(1:2))+1:sum(numRounds(1:3)),:);

% Write out extinction matrix for testing statistics later
% Remember, # rows is # of rounds of extinction, # of columns is # of fish
writematrix(extinMat,[CSV_Loc,'0_ExtinctionMat.csv']);
end