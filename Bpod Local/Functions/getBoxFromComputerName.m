function boxnum = getBoxFromComputerName()
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

switch getenv('COMPUTERNAME')
    case 'CD-BH9P8F3'
        boxnum = 1;
    case 'CD-HZYRJQ3'
        boxnum = 2;
    case 'CD-6BFBMW3'
        boxnum = 3;
    case 'CD-7BFBMW3'
        boxnum = 4;
end

end

