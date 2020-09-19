%% Size Dependence of Learning
% This script takes .sums.csv files from fishspy-plot-cohort outputs 
% all data into .csv files for import into Graphpad.
%
% Note, when running fishspy-plot-cohort, use the following syntax:
%    FISHSPY_SHOW_RAW=false FISHSPY_SUM_DUTY=true X_SLICE=0.25:0.45 
%    CACHE_DIR=/LocationToPlaceServerData
%    DUMP_DIR=/LocationToDumpOutputCSVs 
%    fishspy-plot-cohort 1DKJ 0.9:1.1
%

function [] = zebrafishSizeOrganization(fileName,filePath,numRounds,...
    CSV_Loc)
% fishID: fishspy-plot-cohort-summary.csv file
% filePath: The file path leading to the .csv files generated from
%       fishspy-plot-results 
% numRounds: vector with the total number of rounds for habituation,
%       training and testing (e.g., [20,20,5])
% CSV_Loc: path to where you want to output the .csv files for inputting
%       into e.g., Graphpad  

%% Important Variables
% Cutoffs for size
lowRangeCutoff = 0.0040; % exclusive - anything under this 
                      % value is considered lowest size range
hiRangeCutoff = 0.0046;  % exclusive - anything under this 
                      % value is considered middle or lowest size range
rangeTop = 0.0051;       % exclusive - anything under this 
                      % value is considered high, middle or lowest size

numTwitches_L = 5; % Number of twitches during testing done by a learner
        
numTwitches_N = 0; % Number of twitches during testing done by a nonlearner

% After running fishspy-plot-cohort, an additional folder is added to the
%      path for the CSV locations
pathAddition = 'w000_010/';

%% Input Files from the excel files made previously
% Read the matrices for each that were exported from fishspy-plot-cohort
    % Data is arranged in columns with various metadata, including the
    % length of the fish (std_len), which we care about in this instance.
    totName = [filePath,fileName];

% Import standard length values as a numerical matrix
opts = detectImportOptions(totName);
opts.SelectedVariableNames = {'std_len'};
totMat_num = readmatrix(totName,opts);

% Import RIDs as character arrays
opts.SelectedVariableNames = {'behavior_id'};
totMat_str = readmatrix(totName,opts);
%NOTE: # rows of totMat_num == # rows of totMat_str

%% Data Organization
% Separate data by Standard Length ('std_len')
% This will be used to determine fraction of learners/nonlearners/etc. in
% different size ranges
% Matrices can be no bigger than the original ones in # of rows, so
% initialize matrices with that

midRange_num = repmat(NaN,[size(totMat_num,1),size(totMat_num,2)]);
midRange_str = cell(size(totMat_str,1),size(totMat_str,2));
    midC = 1; % Counter for mid Range Matrix
hiRange_num = repmat(NaN,[size(totMat_num,1),size(totMat_num,2)]);
hiRange_str = cell(size(totMat_str,1),size(totMat_str,2));
    hiC = 1; % Counter for high Range Matrix
for i = 1:size(totMat_num,1)
    tmpVal = totMat_num(i,1); % What is the size of this fish?
    if tmpVal >= lowRangeCutoff && tmpVal < hiRangeCutoff
        midRange_num(midC,:) = totMat_num(i,:);
        midRange_str(midC,:) = totMat_str(i,:);
        midC = midC + 1; % Increment counter
    elseif tmpVal >= hiRangeCutoff && tmpVal < rangeTop
        hiRange_num(hiC,:) = totMat_num(i,:);
        hiRange_str(hiC,:) = totMat_str(i,:);
        hiC = hiC + 1; % Increment counter
    else
        % Debugging - checking for values outside the range
        disp(['The following value exists in row ',...
            num2str(i),' of the matrix. The value is: ',...
            num2str(tmpVal)]); 
    end
end

% Remove extraneous buffer space
% find(X,1,'first') finds the first element of X that has a nonzero value
% isnan gives logical matrix of 1s where there is an NaN value
midRange_str = midRange_str(1:find(isnan(midRange_num),1,'first')-1,:);
midRange_num = midRange_num(1:find(isnan(midRange_num),1,'first')-1,:);
hiRange_str = hiRange_str(1:find(isnan(hiRange_num),1,'first')-1,:);
hiRange_num = hiRange_num(1:find(isnan(hiRange_num),1,'first')-1,:);

%% Output matrices that contain RID information and associated fish size
 writecell(midRange_str,[CSV_Loc,'fishSize_MiddleRangeStrings.csv']);
 writematrix(midRange_num,[CSV_Loc,'fishSize_MiddleRangeNumbers.csv']);
 
 writecell(hiRange_str,[CSV_Loc,'fishSize_HighRangeStrings.csv']);
 writematrix(hiRange_num,[CSV_Loc,'fishSize_HighRangeNumbers.csv']);
 
%% Generate a matrix of testing rounds

midFishNum = numel(midRange_num);
mid_TotMat = repmat(NaN,[sum(numRounds),midFishNum]);
    for i = 1:midFishNum
        tmpName = [[filePath,pathAddition],midRange_str{i},'.sums.csv'];
        opts = detectImportOptions(tmpName);
        % Note: in the .csv generated from fishspy-plot-results, the
        % 3rd column holds the proper data
        opts.SelectedVariableNames = 3; 
        tempMat = readmatrix(tmpName,opts);
        mid_TotMat(1:size(tempMat,1),i) = tempMat;
    end
    testMat_mid = mid_TotMat(sum(numRounds(1:2))+1:sum(numRounds(1:3)),:);

hiFishNum = numel(hiRange_num);
hi_TotMat = repmat(NaN,[sum(numRounds),hiFishNum]);
    for i = 1:hiFishNum
        tmpName = [[filePath,pathAddition],hiRange_str{i},'.sums.csv'];
        opts = detectImportOptions(tmpName);
        % Note: in the .csv generated from fishspy-plot-results, the
        % 3rd column holds the proper data
        opts.SelectedVariableNames = 3; 
        tempMat = readmatrix(tmpName,opts);
        hi_TotMat(1:size(tempMat,1),i) = tempMat;
    end
    testMat_hi = hi_TotMat(sum(numRounds(1:2))+1:sum(numRounds(1:3)),:);
    
    
%% Separate into Learner, Nonlearner, Partial learner (L, N, P)
% numMat will be a 6x3 matrix containing L, NL, and P information as
% columns and low, mid, hi size range information as rows. P information
% will be split into 1,2,3,4. So the matrix columns record:
% [Nonlearners 1xPartial 2xPartial 3xPartial 4xPartial Learners]
% First, figure out which are learners by looking at the testMats (low,
% mid, hi)

  binTestMat_mid = makeBinary(testMat_mid);
  binTestMat_hi = makeBinary(testMat_hi);
  
  % Sum the rounds of testing to show which are L (sum of 5), NL (sum of
  % 0), or P (sum of 1 to 4)
  mid_LNLPvec = sum(binTestMat_mid,1); % Sum all rows for each column
  hi_LNLPvec = sum(binTestMat_hi,1); % Sum all rows for each column
  
  % Categorize into NL (0), P (1), and L (2)  
  mid_CategoryLNLP = repmat(-1,size(mid_LNLPvec));
  for i = 1:numel(mid_LNLPvec)
      if mid_LNLPvec(i) == 5
        mid_CategoryLNLP(i) = 2;
      elseif mid_LNLPvec(i) > 0 && mid_LNLPvec(i) < 5
        mid_CategoryLNLP(i) = 1;
      elseif mid_LNLPvec(i) == 0
        mid_CategoryLNLP(i) = 0;
      else
        mid_CategoryLNLP(i) = NaN; % Debug
      end
  end
  
  hi_CategoryLNLP = repmat(-1,size(hi_LNLPvec));
  for i = 1:numel(hi_LNLPvec)
      if hi_LNLPvec(i) == 5
        hi_CategoryLNLP(i) = 2;
      elseif hi_LNLPvec(i) > 0 && hi_LNLPvec(i) < 5
        hi_CategoryLNLP(i) = 1;
      elseif hi_LNLPvec(i) == 0
        hi_CategoryLNLP(i) = 0;
      else
        hi_CategoryLNLP(i) = NaN; % Debug
      end
  end
  
  % Write out matrices to bring into graphpad for graphing stacked bar
  % graphs
  writematrix(mid_LNLPvec',[CSV_Loc,...
        '0_mid_NumOfTestingRoundsTwitched.csv']);
  writematrix(mid_CategoryLNLP',[CSV_Loc,...
        '0_mid_NL0-P1-L2.csv']);
    
  writematrix(hi_LNLPvec',[CSV_Loc,...
        '0_hi_NumOfTestingRoundsTwitched.csv']);
  writematrix(hi_CategoryLNLP',[CSV_Loc,...
        '0_hi_NL0-P1-L2.csv']);
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