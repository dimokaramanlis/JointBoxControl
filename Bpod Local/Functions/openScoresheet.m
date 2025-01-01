function scoresheetpath = openScoresheet(mousestr)
%NEWMOUSESCORESHEET Summary of this function goes here
%   Detailed explanation goes here
%-------------------------------------------------------------------------
datapath     = 'S:\ElboustaniLab\#SHARE\Data';
%-------------------------------------------------------------------------
% generate mouse folder and copy base template
mousepath = fullfile(datapath, mousestr);
scorepath = fullfile(mousepath, 'Mouse');
afile     = dir(fullfile(scorepath, sprintf('*%s*.xlsx',mousestr)));
% scoresheetpath = fullfile(scorepath, sprintf('Scoresheet%s.xlsx', mousestr));
scoresheetpath = fullfile(scorepath, afile.name);

if ~exist(scoresheetpath, 'file')
    error('Scoresheet does not exist!')
end
%-------------------------------------------------------------------------
% load template-scoresheet and edit

% Start an instance of Excel
Excel = actxserver('Excel.Application');
% Make Excel visible (set to 0 to keep Excel hidden)
Excel.Visible = 1;

% Open the workbook
Workbook = Excel.Workbooks.Open(scoresheetpath);
%-------------------------------------------------------------------------
end
