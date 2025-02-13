function S = getDefaultStruct(ops)
    %% Task Setting
    S.GUI.MouseSetting = 1;
    S.GUIMeta.MouseSetting.Style = 'popupmenu';
    S.GUIMeta.MouseSetting.String = {'Alone 1 (Valve 1,4)',... 1
                                     'Alone 2 (Valve 2,3)',... 2
                                     'Joint'}; %4 
    S.GUI.Dependent = 1;
    S.GUIMeta.Dependent.Style = 'popupmenu';
    S.GUIMeta.Dependent.String = {'Congruent', 'Random', 'Anticorrelated'};
    % day of anticorrelated introduction 27/11/2024
    
    S.GUI.FlipStimulusOrientation = 0;
    S.GUIMeta.FlipStimulusOrientation.Style = 'checkbox';
    S.GUIMeta.FlipStimulusOrientation.String = 'Flip Sides of Stimulus';
    
    S.GUI.ScreenSetting = 1;
    S.GUIMeta.ScreenSetting.Style = 'popupmenu';
    S.GUIMeta.ScreenSetting.String = {'Default',... 1
                                     'Flipped',... 2
                                     'Both'}; %4 
    
    S.GUI.LEDIntensity = 30;

    S.GUI.RewardAmount = 8; % in ul
    S.GUIMeta.RewardAmount.Style = 'edit';
    S.GUIMeta.RewardAmount.String = 'Reward (ul)';
    
    S.GUI.ProtocolName  = 2;
    S.GUIMeta.ProtocolName.Style = 'popupmenu'; % the GUIMeta field is used by the ParameterGUI plugin to customize UI objects.
    S.GUIMeta.ProtocolName.String = {'ObservationalLearning',...
                                     'SequenceSingleMouse',...
                                     'OrientationSingleMouse',...
                                     'ContrastSingleMouse',...
                                     'MirrorSingleMouse',...
                                     'OrientationTwoMice',...
                                     'ContrastTwoMice',...
                                     'MirrorTwoMice',...
                                     'Tests'};

    S.GUIPanels.Task = {'MouseSetting',...
                        'Dependent',...
                        'FlipStimulusOrientation',...
                        'ScreenSetting',...
                        'LEDIntensity',...
                        'RewardAmount',...
                        'ProtocolName'};
    
    %% Stimulus Properties

    S.GUI.StimulusDuration = 0.5; % Duration of visual stimulus (s)
    
    S.GUI.StimulusRadius = 30;
    S.GUIMeta.StimulusRadius.Style = 'edit';
    S.GUIMeta.StimulusRadius.String = 'Stim Radius (deg)';

    S.GUI.StimulusOffset = 0.5; % Spatial offset of stimulus (0 to 1 which is max)

    S.GUI.Angle = 0.1;
    S.GUIMeta.Angle.Style='edit';
    S.GUIMeta.Angle.String="Angle (deg)";
    
    S.GUI.SquareWave = 0;
    S.GUIMeta.SquareWave.Style='checkbox';
    S.GUIMeta.SquareWave.String="SquareWave";

    S.GUI.RandomHeight = 0;
    S.GUIMeta.RandomHeight.Style='checkbox';
    S.GUIMeta.RandomHeight.String="RandomHeight";
    
    
    S.GUI.TemporalFrequency = 0;
    S.GUIMeta.TemporalFrequency.Style='edit';
    S.GUIMeta.TemporalFrequency.String="Temporal Frequency (cycles/s)";
    
    S.GUI.SpatialFrequency= 0.1; 
    S.GUIMeta.SpatialFrequency.Style='edit';
    S.GUIMeta.SpatialFrequency.String = "Spatial Frequency (cycles/deg)";

    S.GUIPanels.Stimulus = {'StimulusDuration',...
                            'StimulusRadius',...
                            'StimulusOffset',...
                            'Angle',...
                            'SquareWave',...
                            'RandomHeight', ...
                            'TemporalFrequency',...
                            'SpatialFrequency'};
    %% Timers
    %Initiation Timeout - the time mouse has from tone to start trial (5) s
    S.GUI.InitiationTimeout = 100000;
    %Punishment TimeOut (if incorrect choice) s
    S.GUI.PunishTimeoutDuration = 0; % Seconds to wait on errors before next trial can start
    %DecisionTime (default 5-7) s
    S.GUI.DecisionTime = 60;
    S.GUI.ITIMin = 1;
    S.GUI.ITIMax = 3;
    S.GUIPanels.Timers = {  'InitiationTimeout',...
                            'DecisionTime',...
                            'PunishTimeoutDuration',...
                            'ITIMin',...
                            'ITIMax'};
    %% Training Aids
  

    S.GUI.ContrastSet = 2;
    S.GUIMeta.ContrastSet.Style = 'popupmenu';
    S.GUIMeta.ContrastSet.String = ops.stimsetnames;

    S.GUI.RewardStimulusTimeout = 0;
    S.GUIMeta.RewardStimulusTimeout.Style = 'edit';
    S.GUIMeta.RewardStimulusTimeout.String = 'Stimulus duration (s) at Reward';
    
    S.GUI.BlackScreen = 0;
    S.GUIMeta.BlackScreen.Style = 'checkbox';
    S.GUIMeta.BlackScreen.String = 'Screens turn black at incorrect choice';
    
    %Terminate if wrong (boolean) 
    S.GUI.Terminate = 1;
    S.GUIMeta.Terminate.Style = 'checkbox';
    S.GUIMeta.Terminate.String = 'Terminate on incorrect choice';
        
    S.GUI.RewardMultiplier1  = 1;
    S.GUIMeta.RewardMultiplier1.String = 'Valve 1 (M1 Red)';
    S.GUIMeta.RewardMultiplier1.Style = 'edit';
    S.GUI.RewardMultiplier4 = 1;
    S.GUIMeta.RewardMultiplier4.String = 'Valve 4 (M1 Blue)';
    S.GUIMeta.RewardMultiplier4.Style = 'edit';
    S.GUI.RewardMultiplier2 = 1;
    S.GUIMeta.RewardMultiplier2.String = 'Valve 2 (M2 Red)';
    S.GUIMeta.RewardMultiplier2.Style = 'edit';
    S.GUI.RewardMultiplier3  = 1;
    S.GUIMeta.RewardMultiplier3.String = 'Valve 3 (M2 Blue)';
    S.GUIMeta.RewardMultiplier3.Style = 'edit';
    

    S.GUIPanels.TrainingAids = {'ContrastSet',...
                                'RewardStimulusTimeout',...
                                'BlackScreen',...
                                'Terminate',...
                                'RewardMultiplier1',...
                                'RewardMultiplier4',...
                                'RewardMultiplier2',...
                                'RewardMultiplier3'};
    %% Debugging

    S.GUI.ProbabilitySetting = 1;
    S.GUIMeta.ProbabilitySetting.Style = 'popupmenu';
    S.GUIMeta.ProbabilitySetting.String = ops.probsettings;

    S.GUI.ProbabilityBlue= 0.5; 
    S.GUIMeta.ProbabilityBlue.Style='edit';
    S.GUIMeta.ProbabilityBlue.String = "Probability blue side";

    S.GUIPanels.Debugging = {'ProbabilitySetting',...
                            'ProbabilityBlue'};
    %% Slider properties
    if ops.useSlider


        S.GUI.Performance = 0.9; 
        S.GUIMeta.Performance.Style='edit';
        S.GUIMeta.Performance.String = "Performance";

        S.GUI.MaxSpeed = 85; 
        S.GUIMeta.MaxSpeed.Style='edit';
        S.GUIMeta.MaxSpeed.String = "MaxSpeed(%)";

        S.GUI.DTimeMin = 0.05; 
        S.GUIMeta.DTimeMin.Style='edit';
        S.GUIMeta.DTimeMin.String = "DTimeMin";

        S.GUI.DTimeMax = 0.75; 
        S.GUIMeta.DTimeMax.Style='edit';
        S.GUIMeta.DTimeMax.String = "DTimeMax";


        S.GUI.RewardStayTime = 2; 
        S.GUIMeta.RewardStayTime.Style='edit';
        S.GUIMeta.RewardStayTime.String = "RewardStayTime";


        S.GUIPanels.Slider = {'Performance', 'MaxSpeed', 'DTimeMin', 'DTimeMax', 'RewardStayTime'};
    end

  
     %% Plotting
%      S.GUI.betaavg =0.8;
%      S.GUIMeta.betaavg.Style='edit';
%      S.GUIMeta.betaavg.String = 'Beta on averaging window';
%      
%      S.GUIPanels.Graphics = {'betaavg'};
end                    