%% APV Treatments
% This script takes .sums.csv files from fishspy-plot-results outputs 
% all data into .csv files for import into Graphpad.
%
% Note, when running fishspy-plot-results, use the following syntax:
% FISHSPY_SUM_CSWINDOW=0:.1 FISHSPY_SHOW_RAW=false FISHSPY_SUM_DUTY=true 
% fishspy-plot-results fishID.events.csv FishID.frame_measures.csv
%

function [] = APV_Trials(fishID,filePath,numRounds,studyType,CSV_Loc)
% fishID: list of RIDs of zebrafish behavior subjects in +/-APV trials.
% filePath: The file path leading to the .csv files generated from
%       fishspy-plot-results
% numRounds: vector with the total number of rounds for habituation,
%       training and testing (e.g., [20,20,5])
% CSV_Loc: path to where you want to output the .csv files for inputting
%       into e.g., Graphpad  
% studyType: String, indicating whether the list of fishID elements
%       are from +APV treated fish or control (-APV) fish
    
%% Input Files from the excel files made previously
% Read the matrices for each that were exported from fishspy-plot-results
    % Data is arranged as "Duty Cycle": ratio of "active" frames to total 
    % frames within the sampling window.  i.e. it is unweighted but 
    % normalized to the window width.  so it corresponds to the standard 
    % definition of "duty cycle" to measure periodic activity density.
    % Keep columns that tell the "duty cycle" column that gives an
    % indication of activity.
    fishNum = length(fishID);
TotMat = repmat(NaN,[sum(numRounds),fishNum]);
for i = 1:fishNum
    tmpName = [filePath,fishID{i},'.sums.csv'];
    opts = detectImportOptions(tmpName);
    % Note: in the .csv generated from fishspy-plot-results, the 3rd column
    %   holds the proper data
    opts.SelectedVariableNames = 3;
    tempMat = readmatrix(tmpName,opts);
    TotMat(1:size(tempMat,1),i) = tempMat;
end

% Organizing data
%
% Only consider testing rounds in the data (which occur after habituation
% and training.

APV_Mat = TotMat(sum(numRounds(1:2))+1:sum(numRounds(1:3)),:);

% Write out matrix for testing statistics later
%
% In this case, make a single column of data for all fish (so, first five
% rows are the testing rounds from the first fish, the second five rows are
% the testing rounds from the second fish, etc.).
    
    writematrix(reshape(APV_Mat,numel(APV_Mat),1),[CSV_Loc,...
        '0_',studyType,'_testRounds.csv']);
end