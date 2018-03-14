function [choice,duration] = GambleScreen(wkspc,gain,loss,sure)
%GAMBLESCREEN Displays a proposed gamble
%   wkspc: workspace Screen var
%   gain: Gain amount
%   loss: Loss amount
%   sure: Sure amount

WAIT = 4; % hard coded wait duration

left_select = 'LeftArrow';
right_select = 'RightArrow';

% Setup Screen view
[screenWidth, screenHeight]=Screen('WindowSize', wkspc);  %Get window size
black = BlackIndex(wkspc);                      %Get Black color
Screen(wkspc, 'FillRect', black);               %Fill window with Black
Screen(wkspc,'TextSize',48);                    %Set Text Size


% Display strings
gain_text = sprintf('$%10.02f',gain); 
loss_text = sprintf('-$%10.02f',abs(loss)); 
sure_text = sprintf('$%10.02f',sure);
flip_label = 'Flip';
sure_label = 'Sure';

% draw left side
[normBoundsRect]= Screen('TextBounds', wkspc, gain_text);
Screen('DrawText', wkspc, gain_text  , ...
    ((screenWidth/2)-(normBoundsRect(1,3))/2)-200, (screenHeight/2)-100, [0, 255, 0, 255]);

[normBoundsRect]= Screen('TextBounds', wkspc, loss_text);
Screen('DrawText', wkspc, loss_text , ...
    ((screenWidth/2)-(normBoundsRect(1,3))/2)-200, (screenHeight/2)+100, [255, 0, 0, 255]);

[normBoundsRect]= Screen('TextBounds', wkspc, flip_label);
Screen('DrawText', wkspc, flip_label , ...
    ((screenWidth/2)-(normBoundsRect(1,3))/2)-200, (screenHeight/2)+200, [255, 255, 255, 255]);


% draw right side
[normBoundsRect]= Screen('TextBounds', wkspc, sure_text);
Screen('DrawText', wkspc, sure_text  , ...
    ((screenWidth/2)-(normBoundsRect(1,3))/2)+200, (screenHeight/2), [0, 255, 0, 255]);

[normBoundsRect]= Screen('TextBounds', wkspc, sure_label);
Screen('DrawText', wkspc, sure_label  , ...
    ((screenWidth/2)-(normBoundsRect(1,3))/2)+200, (screenHeight/2)+200,[255, 255, 255, 255]);


%% Keyboard Checking loop for sub-ms precision

Screen('Flip',wkspc);                                       % Put buffer onto the screen

startSecs = GetSecs();                                      % Get Inital timepoint

WaitSecs(.2);                                               % Initial Wait to prevent key from prior
duration = WAIT;                                            % set default duration (if no keys were pressed)
choice = nan;
while (WAIT -(GetSecs()-startSecs)>0)                       % If within time or wait is 0 (infinite)
    [keyIsDown,~,keyCode] = KbCheck;                        % Check key
    if keyIsDown &&...                                      % If a key is down and key if left or right arrow
            (sum(strcmp(KbName(keyCode),left_select))...        
            ||sum(strcmp(KbName(keyCode),right_select)))           
        duration = GetSecs()-startSecs;                     % find actual duration
        if sum(strcmp(KbName(keyCode),left_select))         % assign choice, by convention left is 1
            choice = 1;
        else
            choice = 0;
        end
        break                                               % end while loop
    end
end


end

