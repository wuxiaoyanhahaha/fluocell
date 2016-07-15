% read the image file and give a warning if the file does not exist.

% Copyright: Shaoying Lu and Yingxiao Wang 2011
function im = my_imread(file_name, data)
% >> fluocell_data.image_type = 'z-stack';
% %% insert these lines at >>> 1 >>>
% if ~isfield(data,'image_type'), 
%     im = imread(file_name);
% elseif strcmp(data.image_type,'z-stack'),
%      im = imread(file_name, data.index),
% end;
% 
    if exist(file_name, 'file') == 2,
        % insert >>> 1 >>>
        im = imread(file_name);
        % Lexie on 1/22/2015
        % temperory solve the jpg format problem.
        if isfield(data, 'image_format') && strcmp(data.image_format, 'jpg1'),
            im = sum(im, 3);
 %       else
 %           im = im;
        end
    else
        im = [];
        display(sprintf('%s : %s\n', file_name, 'This file does not exist!'));
    end;
return;