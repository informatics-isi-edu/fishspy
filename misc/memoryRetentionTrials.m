%% Memory Retention
% This script takes .sums.csv files from fishspy-plot-results outputs 
% all data into .csv files for import into Graphpad.
%
% Note, when running fishspy-plot-results, use the following syntax:
% FISHSPY_SUM_CSWINDOW=0:.1 FISHSPY_SHOW_RAW=false FISHSPY_SUM_DUTY=true 
% fishspy-plot-results fishID.events.csv FishID.frame_measures.csv
%
%

function [] = memoryRetentionTrials(fishID,filePath,numRounds,CSV_Loc)
% fishID: list of RIDs of zebrafish behavior subjects in extinction trials.
% filePath: The file path leading to the .csv files generated from
%       fishspy-plot-results
% numRounds: vector with the total number of rounds for habituation,
%       training, testing, and re-testing (e.g., [20,20,5,5])
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
    fishNum = length(fishID);
TotMat = repmat(NaN,[sum(numRounds),fishNum]);
for i = 1:fishNum
    tmpName = [filePath,fishID{i},'.sums.csv'];
    opts = detectImportOptions(tmpName);
    opts.SelectedVariableNames = 3; % 3rd column keeps the proper data
    tempMat = readmatrix(tmpName,opts);
    TotMat(1:size(tempMat,1),i) = tempMat;
end

%% Organizing data
%
% Only consider testing rounds in the data (which occur after habituation
% and training) as well as 5 rounds after an 85 minute gap after testing.

testMat = TotMat(sum(numRounds(1:2))+1:sum(numRounds(1:3)),:);
  % write out testing rounds matrix
  % In this case, make a single column of data for all fish (so, first five
  % rows are the testing rounds from the first fish, the second five rows are
  % the testing rounds from the second fish, etc.).
  writematrix(reshape(testMat,numel(testMat),1),...
      [CSV_Loc,'0_MemRetTestingRoundsMat.csv']);
  
memRetMat = TotMat(sum(numRounds(1:3))+1:sum(numRounds(1:4)),:);
  % Write out memory retention matrix
  % In this case, make a single column of data for all fish (so, first five
  % rows are the testing rounds from the first fish, the second five rows are
  % the testing rounds from the second fish, etc.).
  writematrix(reshape(memRetMat,numel(memRetMat),1),...
      [CSV_Loc,'0_MemoryRetention85MinLaterMat.csv']);

end