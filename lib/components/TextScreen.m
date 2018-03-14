function duration = TextScreen(wkspc,dispText,wait,keyKill)
%TEXTSCREEN Displays a text for a certain amount of time and return key
%press
%   wkspc: workspace Screen var
%   dispText: String of text to display
%   wait: time to wait for response, 0 for infinite
%   keyKill: 1 to kill on click, 0 not to kill on click

% Run commands once to prevent compile issues. 
GetSecs;KbCheck;

% Setup Screen view
[~, screenHeight]=Screen('WindowSize', wkspc);  %Get window size
black = BlackIndex(wkspc);                      %Get Black color
Screen(wkspc, 'FillRect', black);               %Fill window with Black
Screen(wkspc,'TextSize',24);                    %Set text to 24pt
DrawFormattedText(wkspc,...
    dispText,...                                %Set text to show
    'center',...                                %Center horizontally
    screenHeight/2,...                          %Center Vertically (different method)
    [255,255,255,255]);                         %White and opaque


%% Keyboard Checking loop for sub-ms precision

Screen('Flip',wkspc);                               % Put buffer onto the screen

startSecs = GetSecs();                              % Get Inital timepointa

WaitSecs(.2);                                       % Initial Wait to prevent key from prior
duration = wait;                                    % set default duration (if no keys were pressed)
while (wait -(GetSecs()-startSecs)>0) || wait==0    % If within time or wait is 0 (infinite)
    keyIsDown = KbCheck;                            % Check key
    if keyIsDown && keyKill                         % If a key is down and key can end the screen, end 
        duration = GetSecs()-startSecs;             % find actual duration
        break                                       % end while loop
    end
end


end

