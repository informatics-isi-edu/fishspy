%% organizeTrials
% This script takes .sums.csv files from fishspy-plot-results and outputs 
% all data into .csv files for import into Graphpad.
%
% Note, when running fishspy-plot-results, use the following syntax (note
% that in this case, looking at the early CS window, late CS window would
% be 0.9:1.1 for FISHSPY_SUM_CSWINDOW):
% FISHSPY_SUM_CSWINDOW=0:.1 FISHSPY_SHOW_RAW=false FISHSPY_SUM_DUTY=true 
% fishspy-plot-results fishID.events.csv FishID.frame_measures.csv
%


function [] = organizeTrials(fishID,fishNum,filePath,numRounds,...
    studyType,habRoundsToConsider,CSV_Loc)

% fishID: list of RIDs of zebrafish behavior subjects in a given study type 
%       such as learners (e.g., 1-00DG).
% fishNum: The number of fish in a particular study type. (e.g., there are
%       N = 11 learners.
% filePath: The file path leading to the .csv files generated from
%       fishspy-plot-results
% numRounds: vector with the total number of rounds for habituation,
%       training and testing (e.g., [20,20,5])
% studyType: character vector distinguishing study type (e.g., "L" for
%       learners).
% habRoundsToConsider: The round # where you want to start the analysis of
%       whether the fish has habituated (e.g., round 16, which would
%       correspond to analyzing the last five rounds of habituation.
% CSV_Loc: path to where you want to output the .csv files for inputting
%       into e.g., Graphpad
                       
%% Read the matrices for each that were exported from fishspy-plot-results
    % Data is arranged as "Duty Cycle": ratio of "active" frames to total 
    % frames within the sampling window.  i.e. it is unweighted but 
    % normalized to the window width.  so it corresponds to the standard 
    % definition of "duty cycle" to measure periodic activity density.
    % Keep columns that tell the "duty cycle" column that gives an
    % indication of activity.
TotMat = repmat(NaN,[sum(numRounds),fishNum]);
TotMat_endCS = repmat(NaN,[sum(numRounds),fishNum]);
for i = 1:fishNum
    tmpName = [filePath{2},fishID{i},'.sums.csv'];
    opts = detectImportOptions(tmpName);
    % Note: in the .csv generated from fishspy-plot-results, the 3rd column
    %   holds the proper data
    opts.SelectedVariableNames = 3; 
    tempMat = readmatrix(tmpName,opts);
    TotMat(1:size(tempMat,1),i) = tempMat;
    
    tmpName = [filePath{3},fishID{i},'.sums.csv'];
    opts = detectImportOptions(tmpName);
    % Note: in the .csv generated from fishspy-plot-results, the 3rd column
    %   holds the proper data
    opts.SelectedVariableNames = 3;
    tempMat = readmatrix(tmpName,opts);
    TotMat_endCS(1:size(tempMat,1),i) = tempMat;
end
colNames = opts.SelectedVariableNames;
%% Organizing data
%
% There are numRounds(1) rounds of habituation and numRounds(2)
% rounds of training, so separate those out from the testing rounds, 
% because they will be considered separately.

habMat = TotMat(habRoundsToConsider:numRounds(1),:);
trainMat = TotMat(numRounds(1)+1:numRounds(1)+numRounds(2),:);
    trainMat_endCS = TotMat_endCS(numRounds(1)+1:numRounds(1)+...
        numRounds(2),:);
testMat = TotMat(numRounds(1)+numRounds(2)+1:numRounds(1)+...
    numRounds(2)+numRounds(3),:);

    % Store the data matrices as a long matrix to be read later
    % (store as a matrix because the total number of testing rounds are
    % less than e.g.,training... takes into account that this is the case).
    % So, keep this in mind when doing analysis
    % [last 20-habRoundsToConsider rounds of habituation;
    % 20 rounds of training (beginning of CS);
    % 20 rounds of training (end of CS, when US would be on);
    % 5 rounds of testing]
    totVec = [habMat;trainMat;trainMat_endCS;testMat];
    writematrix(totVec,[CSV_Loc,...
        '01_',studyType,'_everyAnalyzedRoundAllFish.csv']);
    writematrix(fishNum,[CSV_Loc,...
        '02_',studyType,'_fishNum.csv']);
    writematrix(reshape(habMat,numel(habMat),1),[CSV_Loc,...
        '03a',studyType,'_habRounds.csv']);
    writematrix(reshape(trainMat,numel(trainMat),1),[CSV_Loc,...
        '03b',studyType,'_trainRoundsEarlyCS.csv']);
    writematrix(reshape(trainMat_endCS,numel(trainMat_endCS),1),...
        [CSV_Loc,'04b',studyType,'_trainRoundsEndCS.csv']);
    writematrix(reshape(testMat,numel(testMat),1),[CSV_Loc,...
        '03c',studyType,'_testRounds.csv']);


end