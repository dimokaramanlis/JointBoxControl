function S = getDefaultStruct(ops)
%% Plotting
    S.GUI.Normalization = 1;
    S.GUIMeta.Normalization.Style = 'popupmenu';
    S.GUIMeta.Normalization.String = {'NTrials',...      1
                                 'CorrectVSIncorrect'}; %2
                                     
    S.GUIPanels.Plotting = {'Normalization'};

%% Task Setting
    S.GUI.MouseSetting = 1;
    S.GUIMeta.MouseSetting.Style = 'popupmenu';
    S.GUIMeta.MouseSetting.String = {'Alone 1 (Valve 1,4)',... 1
                                     'Alone 2 (Valve 2,3)',... 2
                                     'Joint'}; 
                                 
    S.GUI.TaskType = 1;
    S.GUIMeta.TaskType.Style = 'popupmenu';
    S.GUIMeta.TaskType.String = {'Normal',...               1
                                 'Competition',...          2
                                 'Cooperation',...          3
                                 'SameSide',... 4
                                 'OneMouseNoGlass'};%5

    S.GUI.Dependent = 1;
    S.GUIMeta.Dependent.Style = 'popupmenu';
    S.GUIMeta.Dependent.String = {'Congruent', 'Random', 'Anticorrelated','Complementary'};
    % day of anticorrelated introduction 27/11/2024
    % day of complementary introduction 20/10/2025
    
    S.GUI.FlipStimulusOrientation = 0;
    S.GUIMeta.FlipStimulusOrientation.Style = 'checkbox';
    S.GUIMeta.FlipStimulusOrientation.String = 'Flip Sides of Stimulus';
    
    S.GUI.ScreenSetting = 1;
    S.GUIMeta.ScreenSetting.Style = 'popupmenu';
    S.GUIMeta.ScreenSetting.String = {'Default',... 1
                                     'Flipped',... 2
                                     'Both'}; %4 
    
    S.GUI.LEDIntensity = 20;

    S.GUI.RewardAmount = 8; % in ul
    S.GUIMeta.RewardAmount.Style = 'edit';
    S.GUIMeta.RewardAmount.String = 'Reward (ul)';

    S.GUI.RewardPercentageSecond = 1; % in %
    S.GUIMeta.RewardPercentageSecond.Style = 'edit';
    S.GUIMeta.RewardPercentageSecond.String = 'Reward (%)';
    
    S.GUI.ProtocolName  = 2;
    S.GUIMeta.ProtocolName.Style = 'popupmenu'; % the GUIMeta field is used by the ParameterGUI plugin to customize UI objects.
    S.GUIMeta.ProtocolName.String = {'SequenceSingleMouse',...
                                     'OrientationSingleMouse',...
                                     'ContrastSingleMouse',...
                                     'MirrorSingleMouse',...
                                     'RewardDelaySingleMouse',...
                                     'OrientationTwoMice',...
                                     'ContrastTwoMice',...
                                     'MirrorTwoMice',...
                                     'CompetitionTwoMice',...
                                     'CooperationTwoMice',...
                                     'SameSideBaseline',...
                                     'SameSideCompetition',...
                                     'RecoveryDay',...
                                     'Tests'};

    S.GUIPanels.Task = {'MouseSetting',...
                        'TaskType',...
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
    
    S.GUI.CooperationTimeout = 10000;   
    S.GUI.SoftDelay = 0; % in %
    S.GUI.OutOfPokeWindow = 10000;
    S.GUI.NoCrossTimeout = 1000;
    
    S.GUI.TerminateUponNoCross = 0;
    S.GUIMeta.TerminateUponNoCross.Style = 'checkbox';
    S.GUIMeta.TerminateUponNoCross.String = 'Terminate when 2nd mouse doesnt cross';

    
    S.GUIPanels.Timers = {  'InitiationTimeout',...
                            'DecisionTime',...
                            'PunishTimeoutDuration',...
                            'ITIMin',...
                            'ITIMax',...
                            'CooperationTimeout',...
                            'SoftDelay',...
                            'OutOfPokeWindow',...
                            'NoCrossTimeout',...
                            'TerminateUponNoCross'};
    %% Training Aids
  
    S.GUI.RewardStimulusTimeout = 0;
    S.GUIMeta.RewardStimulusTimeout.Style = 'edit';
    S.GUIMeta.RewardStimulusTimeout.String = 'Stimulus duration (s) at Reward';
      
    S.GUI.RewardDelayMin = 0;
    S.GUIMeta.RewardDelayMin.Style = 'edit';
    S.GUIMeta.RewardDelayMin.String = 'seconds'; 
    
    S.GUI.RewardDelayMax = 0;
    S.GUIMeta.RewardDelayMax.Style = 'edit';
    S.GUIMeta.RewardDelayMax.String = 'seconds'; 
    
    S.GUI.BlackScreen = 0;
    S.GUIMeta.BlackScreen.Style = 'checkbox';
    S.GUIMeta.BlackScreen.String = 'Screens turn black at incorrect choice';
    
    %Terminate if wrong (boolean) 
    S.GUI.Terminate = 1;
    S.GUIMeta.Terminate.Style = 'checkbox';
    S.GUIMeta.Terminate.String = 'Terminate on incorrect choice';
        
    S.GUI.SustainedPoke = 0;
    S.GUIMeta.SustainedPoke.Style='checkbox';
    S.GUIMeta.SustainedPoke.String="Time poking to release water (s)";
        
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
                                'RewardDelayMin',...
                                'RewardDelayMax',...
                                'BlackScreen',...
                                'Terminate',...
                                'SustainedPoke',...
                                'RewardMultiplier1',...
                                'RewardMultiplier4',...
                                'RewardMultiplier2',...
                                'RewardMultiplier3', ...
                                'ProbabilitySetting',...
                                'ProbabilityBlue'};

  
  
     %% Plotting
%      S.GUI.betaavg =0.8;
%      S.GUIMeta.betaavg.Style='edit';
%      S.GUIMeta.betaavg.String = 'Beta on averaging window';
%      
%      S.GUIPanels.Graphics = {'betaavg'};
end                    