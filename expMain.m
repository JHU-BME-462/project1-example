%% Example Experiment
% This is a script file for running an experiment. Scripts are useful for
% debugging, but consider converting to a function.


%% Setup

% refresh the workspace to act like a function
clc     % clear output
clear all;  % clear all variables. ('all' important for PTB options)

rng('shuffle'); % reset random seed

% include all files in lib
addpath(genpath('./lib'))

% get local settings from file
P = LOCAL_CONFIG();

% Set Screen Options
% see ptb help pages
Screen('Preference', 'SkipSyncTests', 1);
MaxPriority('GetSecs','KbCheck','KbWait','GetClicks');
KbName('UnifyKeyNames');
HideCursor;
Screen('Preference','VisualDebugLevel', 0);

% Configure debug mode if set in the configuration file.
if P.PTBDebug==true
    PsychDebugWindowConfiguration();
end

% Expemeriment Settings
expName = 'example';

%% Get participant ID
% Enter a subjectID or press eneter for default
sid_input = input('Press Enter to proceed with TestSubject or enter subject id:','s');
if isempty(sid_input)
    sid_input='Test';
end

%% Create Subject Folder

DATA_PATH = [P.DATA_ROOT expName '_' sid_input '_' datestr(now,'yyyy_mm_dd-HH_MM_SS') '/'];
mkdir(DATA_PATH);


%% Start Experiment
% Create the Screen wkspc object

whichScreen = P.SCREEN_PTR;
wkspc = Screen(whichScreen, 'OpenWindow');


%% Run Testing Phase
% We want to construct a random list of values to test, and then fill in
% information about the subject's response (Reaction Time, Choice,etc)

% Build example set  
% 2 Gains [2 10]
% 2 Losses [-1 -5]
% 2 Sures [0 5]

Gains = [2 10];
Losses = [-1 -5];
Sures = [0 5];

[matG,matL,matS] = ndgrid(Gains,Losses,Sures); %create 3d space sampling all combinations
ordG = matG(:); %Flatten Gains
ordL = matL(:); %Flatten Losses
ordS = matS(:); %Flatten Sures

% Sample each point randomly without replacement, and then a second time randomly without replacement.
sampleInds = [randperm(length(ordG))';randperm(length(ordG))'];

% Construct data table
%first build an empty row
test_data_table = table({sid_input},0,0,0,0,0,-1,0,...
    'VariableNames',{'SubjectID','TrialNum','Gain','Loss','Sure','FixationWait','Choice','ReactionTime'});
%repeat for the number of trials
test_data_table = repmat(test_data_table,length(sampleInds),1);
%insert the known values(trialnum, gain, sure, loss)
test_data_table.TrialNum = (1:height(test_data_table))';
test_data_table.FixationWait = rand(length(sampleInds),1)*2+2; % random number Uniform(2,4)
test_data_table.Gain = ordG(sampleInds);
test_data_table.Loss = ordL(sampleInds);
test_data_table.Sure = ordS(sampleInds);

% Begin Test section PTB commands
TextScreen(wkspc,'Please wait for instructions.',0,1)   % wait for key
TextScreen(wkspc,'Testing Phase',5,0)                   % wait for 5 seconds

% Testing Loop
% 1) Fixation Cross for FixationWait seconds
% 2) Present Gamble choice with known Gain Loss Sure
% 3) Record the ReactionTime and Choice, nan for not answered.
% if halfway, provide a skippiable 5 minute break
for i = 1:height(test_data_table)
    
    % check if half way (mod is useful for other multiples)
    if mod(i,height(test_data_table)/2)==1&&i~=1
        TextScreen(wkspc,'Break!',300,1)
    end
    
    FixationScreen(wkspc,test_data_table.FixationWait(i))
    [choice,reactiontime] = GambleScreen(wkspc,test_data_table.Gain(i),test_data_table.Loss(i),test_data_table.Sure(i));
    test_data_table.Choice(i) = choice;
    test_data_table.ReactionTime(i) = reactiontime;

end

% write results to csv in the subjects folder (csv useful for moving to
% python or another language)
writetable(test_data_table,[DATA_PATH 'testing_data.csv'])
    
%% Run Payout Phase
% choose a random trial that has a valid response and then evaluate outcome. 

validTrials = test_data_table.TrialNum(test_data_table.Choice==1|test_data_table.Choice==0);
selectedTrial = validTrials(randi(length(validTrials)));

% extract row associated with trial
selectedTrialRow = test_data_table(test_data_table.TrialNum==selectedTrial,:);

preString = sprintf('The selected trial proposed: Gain $%.02f vs Loss -$%.02f or Sure $%.02f',...
    selectedTrialRow.Gain,abs(selectedTrialRow.Loss),selectedTrialRow.Sure);

% If gamble is selected, flip a coin and determine outcome;
if selectedTrialRow.Choice==1 && rand>.5
    gambleOutcome = 1;
    choiceString = 'You chose to gamble and won.';
    winnings = selectedTrialRow.Gain;
elseif selectedTrialRow.Choice==1
    gambleOutcome = 0;
    choiceString = 'You chose to gamble and lost.';
    winnings = selectedTrialRow.Loss;
else
    gambleOutcome = nan;
    choiceString = 'You chose the sure amount.';
    winnings = selectedTrialRow.Sure;
end

if winnings>=0
    outcomeString = sprintf('Outcome: $%.02f',winnings);
else
    outcomeString = sprintf('Outcome: -$%.02f',abs(winnings));
end

TextScreen(wkspc,'Payout Phase.',0,1);
TextScreen(wkspc,preString,0,1);
TextScreen(wkspc,choiceString,0,1);
TextScreen(wkspc,outcomeString,0,1);

save([DATA_PATH 'payout.mat'],'selectedTrialRow','gambleOutcome','preString','choiceString','outcomeString');

%% End Experiment
sca;
    
