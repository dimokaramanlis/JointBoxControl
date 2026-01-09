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

%%%%%%%%%%% Start Beatriz Edited
    S.GUI.RewardPercentageSecond = 1; % in %
    S.GUIMeta.RewardPercentageSecond.Style = 'edit';
    S.GUIMeta.RewardPercentageSecond.String = 'Reward (%)';
%%%%%%%%%%% End Beatriz Edited
    
    S.GUI.ProtocolName  = 2;
    S.GUIMeta.ProtocolName.Style = 'popupmenu'; % the GUIMeta field is used by the ParameterGUI plugin to customize UI objects.
    S.GUIMeta.ProtocolName.String = {'SequenceSingleMouse',...
                                     'OrientationSingleMouse',...
                                     'ContrastSingleMouse',...
                                     'MirrorSingleMouse',...
                                     'OrientationTwoMice',...
                                     'ContrastTwoMice',...
                                     'MirrorTwoMice',...
                                     'SliderSingleMouse',...
                                     'ContrastSingleMouseOpto',...
                                     'ContrastTwoMiceOpto',...                                     
                                     'Tests'};

    S.GUIPanels.Task = {'MouseSetting',...
                        'Dependent',...
                        'FlipStimulusOrientation',...
                        'ScreenSetting',...
                        'LEDIntensity',...
                        'RewardAmount',...
                        'RewardPercentageSecond',...   %BA
                        'ProtocolName'};
    
    %% Stimulus Properties

    S.GUI.ContrastSet1 = 2;
    S.GUIMeta.ContrastSet1.Style = 'popupmenu';
    S.GUIMeta.ContrastSet1.String = ops.stimsetnames;
    
    S.GUI.ContrastSet2 = 2;
    S.GUIMeta.ContrastSet2.Style = 'popupmenu';
    S.GUIMeta.ContrastSet2.String = ops.stimsetnames;
    
    S.GUI.StimulusDuration = 1; % Duration of visual stimulus (s)
    
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

%     S.GUI.RandomHeight = 0;
%     S.GUIMeta.RandomHeight.Style='checkbox';
%     S.GUIMeta.RandomHeight.String="RandomHeight";
    
    S.GUI.TemporalFrequency = 0;
    S.GUIMeta.TemporalFrequency.Style='edit';
    S.GUIMeta.TemporalFrequency.String="Temporal Frequency (cycles/s)";
    
    S.GUI.SpatialFrequency= 0.1; 
    S.GUIMeta.SpatialFrequency.Style='edit';
    S.GUIMeta.SpatialFrequency.String = "Spatial Frequency (cycles/deg)";

    S.GUIPanels.Stimulus = {'ContrastSet1',...
                            'ContrastSet2',...
                            'StimulusDuration',...
                            'StimulusRadius',...
                            'StimulusOffset',...
                            'Angle',...
                            'SquareWave',...
                            'TemporalFrequency',...
                            'SpatialFrequency'};
    %% Timers
    %Initiation Timeout - the time mouse has from tone to start trial (5) s
    S.GUI.InitiationTimeout = 100000;
    %Punishment TimeOut (if incorrect choice) s
    S.GUI.PunishTimeoutDuration = 0; % Seconds to wait on errors before next trial can start
    %DecisionTime (default 5-7) s
    S.GUI.DecisionTime = 60;
    S.GUI.ITIMin = 2;
    S.GUI.ITIMax = 5;
    S.GUIPanels.Timers = {  'InitiationTimeout',...
                            'DecisionTime',...
                            'PunishTimeoutDuration',...
                            'ITIMin',...
                            'ITIMax'};
    %% Training Aids
  
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
    
    S.GUI.ProbabilitySetting = 1;
    S.GUIMeta.ProbabilitySetting.Style = 'popupmenu';
    S.GUIMeta.ProbabilitySetting.String = ops.probsettings;

    S.GUI.ProbabilityBlue= 0.5; 
    S.GUIMeta.ProbabilityBlue.Style='edit';
    S.GUIMeta.ProbabilityBlue.String = "Probability blue side";

    S.GUIPanels.TrainingAids = {'RewardStimulusTimeout',...
                                'BlackScreen',...
                                'Terminate',...
                                'RewardMultiplier1',...
                                'RewardMultiplier4',...
                                'RewardMultiplier2',...
                                'RewardMultiplier3', ...
                                'ProbabilitySetting',...
                                'ProbabilityBlue'};

    %% Slider properties
    if ops.useSlider


        S.GUI.Performance = 0.8; 
        S.GUIMeta.Performance.Style='edit';
        S.GUIMeta.Performance.String = "Performance";

        S.GUI.MaxSpeed = 100; 
        S.GUIMeta.MaxSpeed.Style='edit';
        S.GUIMeta.MaxSpeed.String = "MaxSpeed(%)";

        S.GUI.DTimeAvg = 0.3; 
        S.GUIMeta.DTimeAvg.Style='edit';
        S.GUIMeta.DTimeAvg.String = "DTimeMean";

        S.GUI.UncertaintySD = 50; 
        S.GUIMeta.UncertaintySD.Style='edit';
        S.GUIMeta.UncertaintySD.String = "UncertaintySD(steps)";


        S.GUI.RewardStayTime = 3; 
        S.GUIMeta.RewardStayTime.Style='edit';
        S.GUIMeta.RewardStayTime.String = "RewardStayTime";
        
        S.GUI.RoamingType  = 2;
        S.GUIMeta.RoamingType.Style = 'popupmenu'; % the GUIMeta field is used by the ParameterGUI plugin to customize UI objects.
        S.GUIMeta.RoamingType.String = {'Platform',...
                                         'Full'};

        S.GUIPanels.Slider = {'Performance', 'MaxSpeed', ...
            'DTimeAvg', 'UncertaintySD', 'RewardStayTime', 'RoamingType'};
    end
    %% Opto Properties
    if ops.useOpto
        S.GUI.ProbOpto  = 0.3;
        S.GUIMeta.ProbOpto.Style = 'edit';
        S.GUIMeta.ProbOpto.String = {'ProbabilityOpto'};

        S.GUI.OptoDuration  = 0.5;
        S.GUIMeta.OptoDuration.Style = 'edit';
        S.GUIMeta.OptoDuration.String = {'OptoDuration'};

        S.GUIPanels.Opto = {'ProbOpto', 'OptoDuration'};
    end
  
     %% Plotting
%      S.GUI.betaavg =0.8;
%      S.GUIMeta.betaavg.Style='edit';
%      S.GUIMeta.betaavg.String = 'Beta on averaging window';
%      
%      S.GUIPanels.Graphics = {'betaavg'};
end                    