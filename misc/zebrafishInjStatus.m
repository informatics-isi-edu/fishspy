%% Injected versus Uninjected
% This script takes .sums.csv files from fishspy-plot-cohort outputs 
% all data into .csv files for import into Graphpad.
%
% Note, when running fishspy-plot-cohort, use the following syntax:
%    FISHSPY_SHOW_RAW=false FISHSPY_SUM_DUTY=true X_SLICE=0.25:0.45 
%    CACHE_DIR=/LocationToPlaceServerData
%    DUMP_DIR=/LocationToDumpOutputCSVs 
%    fishspy-plot-cohort 1DKJ 0.9:1.1
%
function [] = zebrafishInjStatus(fileName,filePath,numRounds,...
    CSV_Loc)
% fishID: fishspy-plot-cohort-summary.csv file
% filePath: The file path leading to the .csv files generated from
%       fishspy-plot-results 
% numRounds: vector with the total number of rounds for habituation,
%       training and testing (e.g., [20,20,5])
% CSV_Loc: path to where you want to output the .csv files for inputting
%       into e.g., Graphpad  

%% Important Variables
numTwitches_L = 5; % Number of twitches during testing done by a learner
        
numTwitches_N = 0; % Number of twitches during testing done by a nonlearner

% After running fishspy-plot-cohort, additional folders is added to the
%      path for the CSV locations
pathAddition = 'w000_010/';
injectedPath = 'injected/'; 
UIPath = 'non-injected/';
%% Input Files from the excel files made previously
% Read the matrices for each that were exported from fishspy-plot-cohort
    % Data is arranged in columns with various metadata, including the
    % status of the fish (Inj or UI), which we care about in this instance.
    totName = [filePath,fileName];
% List all fish (prepared in a file created by fishspy-plot-cohort) and
% each fish's associated injection status (injected or not); this is a
% matrix of character arrays
opts = detectImportOptions(totName);
opts.SelectedVariableNames = {'injection_status',...
    'behavior_id'};
totMat_str = readmatrix(totName,opts);

%% Data Organization
% Separate data by injection status (injected or uninjected)
% This will be used to determine fraction of learners/nonlearners/etc. to
% compare the two conditions
    % Since the matrix may repeat Behavior ID elements, make sure that the
    % matrix contains only unique values
    [tempTotMat,indx1,indx2] = unique(totMat_str,'first');
        % Only care about indx1 NOT indx2.
        % Remove the two entries for "injected" and "non-injected"
        tmpVal = ismember(tempTotMat,{'injected','non-injected'});
        tempTotMat(tmpVal) = []; % Removes two values
        indx1(tmpVal) = [];
        
        % Now, only consider unique Behavior ID elements of tempTotMat
        totMat_Inj = cell(size(totMat_str,1));
            totMat_Inj = {''}; % Empty padded cell string array
            count_Inj = 1; % counter for injected matrix
        totMat_UI = cell(size(totMat_str,1));
            totMat_UI = {''}; % Empty padded cell string array
            count_UI = 1; % counter for uninjected matrix
        for i = 1:numel(indx1)
            [j,k] = ind2sub(size(totMat_str),indx1(i));
            if strcmp(totMat_str(j,1),'injected')
                totMat_Inj(count_Inj) = totMat_str(j,k);
                count_Inj = count_Inj+1;
            elseif strcmp(totMat_str(j,1),'non-injected')
                totMat_UI(count_UI) = totMat_str(j,k);
                count_UI = count_UI+1;
            else
                % Debugging - check for entries without injection status
                fprintf(['Missing injection status for index (',...
                    num2str(j),',',num2str(k),').']);
            end
        end
%% Output matrices that contain RID information for each classification
 writecell(totMat_Inj',[CSV_Loc,'Inj_BehaviorIDs.csv']);
 writecell(totMat_UI',[CSV_Loc,'UI_BehaviorIDs.csv']);

%% Generate a matrix of testing rounds
injectedFishNum = numel(totMat_Inj);
injected_TotMat = repmat(NaN,[sum(numRounds),injectedFishNum]);
    for i = 1:injectedFishNum
        tmpName = [[filePath,injectedPath,pathAddition],...
            totMat_Inj{i},'.sums.csv'];
        opts = detectImportOptions(tmpName);
        % Note: in the .csv generated from fishspy-plot-results, the
        % 3rd column holds the proper data
        opts.SelectedVariableNames = 3; 
        tempMat = readmatrix(tmpName,opts);
        injected_TotMat(1:size(tempMat,1),i) = tempMat;
    end
    testMat_Inj = ...
        injected_TotMat(sum(numRounds(1:2))+1:sum(numRounds(1:3)),:);

UIFishNum = numel(totMat_UI);
UI_TotMat = repmat(NaN,[sum(numRounds),UIFishNum]);
    for i = 1:UIFishNum
        tmpName = [[filePath,UIPath,pathAddition],...
            totMat_UI{i},'.sums.csv'];
        opts = detectImportOptions(tmpName);
        % Note: in the .csv generated from fishspy-plot-results, the
        % 3rd column holds the proper data
        opts.SelectedVariableNames = 3; 
        tempMat = readmatrix(tmpName,opts);
        UI_TotMat(1:size(tempMat,1),i) = tempMat;
    end
    testMat_UI = UI_TotMat(sum(numRounds(1:2))+1:sum(numRounds(1:3)),:);
    
    % Write out test matrices so that they can be used for calculating
    % flick ratio plots
    writematrix(reshape(testMat_Inj,numel(testMat_Inj),1),[CSV_Loc,...
        'Inj_flickRatios.csv']);
    writematrix(reshape(testMat_UI,numel(testMat_UI),1),[CSV_Loc,...
        'UI_flickRatios.csv']);
    
%% Separate into Learner, Nonlearner, Partial learner (L, N, P)
% numMat will be a 6x3 matrix containing L, NL, and P information as
% columns and low, Inj, UI size range information as rows. P information
% will be split into 1,2,3,4. So the matrix columns record:
% [Nonlearners 1xPartial 2xPartial 3xPartial 4xPartial Learners]
% First, figure out which are learners by looking at the testMats (Inj, UI)
  binTestMat_Inj = makeBinary(testMat_Inj);
  binTestMat_UI = makeBinary(testMat_UI);
  
  % Sum the rounds of testing to show wUIch are L (sum of 5), NL (sum of
  % 0), or P (sum of 1 to 4)
  Inj_LNLPvec = sum(binTestMat_Inj,1); % Sum all rows for each column
  UI_LNLPvec = sum(binTestMat_UI,1); % Sum all rows for each column
  
  % Categorize into NL (0), P (1), and L (2)
  Inj_CategoryLNLP = repmat(-1,size(Inj_LNLPvec));
  for i = 1:numel(Inj_LNLPvec)
      if Inj_LNLPvec(i) == 5
        Inj_CategoryLNLP(i) = 2;
      elseif Inj_LNLPvec(i) > 0 && Inj_LNLPvec(i) < 5
        Inj_CategoryLNLP(i) = 1;
      elseif Inj_LNLPvec(i) == 0
        Inj_CategoryLNLP(i) = 0;
      else
        Inj_CategoryLNLP(i) = NaN; % Debug
      end
  end
  
  UI_CategoryLNLP = repmat(-1,size(UI_LNLPvec));
  for i = 1:numel(UI_LNLPvec)
      if UI_LNLPvec(i) == 5
        UI_CategoryLNLP(i) = 2;
      elseif UI_LNLPvec(i) > 0 && UI_LNLPvec(i) < 5
        UI_CategoryLNLP(i) = 1;
      elseif UI_LNLPvec(i) == 0
        UI_CategoryLNLP(i) = 0;
      else
        UI_CategoryLNLP(i) = NaN; % Debug
      end
  end
  
  % Write out matrices to bring into graphpad for graphing stacked bar
  % graphs
  writematrix(Inj_LNLPvec',[CSV_Loc,...
        '0_Inj_NumOfTestingRoundsTwitched.csv']);
  writematrix(Inj_CategoryLNLP',[CSV_Loc,...
        '0_Inj_NL0-P1-L2.csv']);
    
  writematrix(UI_LNLPvec',[CSV_Loc,...
        '0_UI_NumOfTestingRoundsTwitched.csv']);
  writematrix(UI_CategoryLNLP',[CSV_Loc,...
        '0_UI_NL0-P1-L2.csv']);
    

end
%% Helper functions
function binMake = makeBinary(bigMat)
    % The purpose of this function is to see whether an element in a matrix
    % is greater than zero. If so, then turn that value into a "1". If not,
    % leave it as a zero. This is to make it easier to calculate whether a
    % fish is a learner or not.
    binMake = bigMat;
    for i = 1:numel(bigMat)
        if bigMat(i)>0
            binMake(i)=1;
        end
    end
end