function FixationScreen(wkspc,duration)
%FIXATIONSCREEN makes fixation cross screen
%   wkspc: screen workspace
%   duration: random wait time




% Get the centre coordinate of the window
[screenWidth, screenHeight]=Screen('WindowSize', wkspc);  %Get window size
xCenter = screenWidth/2;
yCenter = screenHeight/2;

black = BlackIndex(wkspc);                      %Get Black color
Screen(wkspc, 'FillRect', black);               %Fill window with Black

% Here we set the size of the arms of our fixation cross
fixCrossDimPix = 40;

% Now we set the coordinates (these are all relative to zero we will let
% the drawing routine center the cross in the center of our monitor for us)
xCoords = [-fixCrossDimPix fixCrossDimPix 0 0];
yCoords = [0 0 -fixCrossDimPix fixCrossDimPix];
allCoords = [xCoords; yCoords];

% Set the line width for our fixation cross
lineWidthPix = 4;

% Draw the fixation cross in white, set it to the center of our screen
white = WhiteIndex(wkspc);
Screen('DrawLines', wkspc, allCoords,lineWidthPix, white, [xCenter yCenter]);


%% Wait until duration, subtracting setup time.
% Flip to the screen
Screen('Flip', wkspc);


WaitSecs(duration);

end

