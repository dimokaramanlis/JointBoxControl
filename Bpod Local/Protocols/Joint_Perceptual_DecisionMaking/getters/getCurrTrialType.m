function [currTrialTypeM1,...
          currTrialTypeM2,...
          currentContrastIndexM1,...
          currentContrastIndexM2,...
          contrastIndexRightM1,...
          contrastIndexLeftM1,...
          contrastIndexRightM2,...
          contrastIndexLeftM2] = getCurrTrialType(currentTrial,totalNumberofConditions,...
                                                  LeftRightTrialsM1,...
                                                  LeftRightTrialsM2,...
                                                  contrastIndexRightM1,...
                                                  contrastIndexLeftM1,...
                                                  contrastIndexRightM2,...
                                                  contrastIndexLeftM2)
%GETCURRTRIALTYPE Summary of this function goes here
%   Detailed explanation goes here
if mod(currentTrial,totalNumberofConditions)>0
    currTrialTypeM1 = LeftRightTrialsM1(mod(currentTrial,totalNumberofConditions));
    currTrialTypeM2 = LeftRightTrialsM2(mod(currentTrial,totalNumberofConditions));
else
    currTrialTypeM1 = randi([1 2]);
    currTrialTypeM2 = randi([1 2]);
end
if currTrialTypeM1==1
    if ~isempty(contrastIndexRightM1)
        currentContrastIndexM1 = contrastIndexRightM1(1);
        contrastIndexRightM1(1) = [];
    else %If right is empty but not left.
        if ~isempty(contrastIndexLeftM1)
            currTrialTypeM1=2;
            currentContrastIndexM1 = contrastIndexLeftM1(1);
            contrastIndexLeftM1(1) = [];
        else
            currentContrastIndexM1 = stimuliNumberPerSide^2 -1;
        end
    end
elseif currTrialTypeM1==2
    if ~isempty(contrastIndexLeftM1)
        currentContrastIndexM1 = contrastIndexLeftM1(1);
        contrastIndexLeftM1(1) = [];
    else
        if ~isempty(contrastIndexRightM1)
            currTrialTypeM1=1;
            currentContrastIndexM1 = contrastIndexRightM1(1);
            contrastIndexRightM1(1) = [];
        else
            currentContrastIndexM1 = stimuliNumberPerSide^2 -1;
        end
    end
end

% M2
if currTrialTypeM2==1
    if ~isempty(contrastIndexRightM2)
        currentContrastIndexM2 = contrastIndexRightM2(1);
        contrastIndexRightM2(1) = [];
    else
        if ~isempty(contrastIndexLeftM2)
            currTrialTypeM2=2;
            currentContrastIndexM2 = contrastIndexLeftM2(1);
            contrastIndexLeftM2(1) = [];
        else
            currentContrastIndexM2 = stimuliNumberPerSide^2 -1;
        end
    end
elseif currTrialTypeM2==2
    if ~isempty(contrastIndexLeftM2)
        currentContrastIndexM2 = contrastIndexLeftM2(1);
        contrastIndexLeftM2(1) = [];
    else
        if ~isempty(contrastIndexRightM2)
            currTrialTypeM2=1;
            currentContrastIndexM2 = contrastIndexRightM2(1);
            contrastIndexRightM2(1) = [];
        else
            currentContrastIndexM2 = stimuliNumberPerSide^2 -1;
        end
    end
end
end

