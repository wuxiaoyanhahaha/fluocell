% Function update the ratio image
% Allow the user to select the region of interest.
% And quantify the ratio within the roi
% (1) To start tracking: fluocell_data.quantify_roi = 2; 
% (2) To use subcellular layers instead of ROIs:
% fluocell_data.quantify_roi = 3;
% fluocell_data.num_roi = 3;
% by change the value of parameter save_bw_file, you could 
% decide save the cell_bw file of not
% default save_bw_file = 0 ( not saving those file)
% save_bw_file = 1 (save cell_bw file)
% To allow mask: fluocell_data.need_apply_mask = 1;
% To stop mask: fluocell_data.need_apply_mask = 0;
% (3) To stop quantification: fluocell_data.quantify_roi = 0;
% (4) To allow n regions: fluocell_data.num_roi = 3; 

% Copyright: Shaoying Lu and Yingxiao Wang 2014
function data = quantify_region_of_interest(data, ratio, cfp, yfp, varargin)
parameter_name = {'save_bw_file'};
default_value = {0};
[save_bw_file] = parse_parameter(parameter_name, default_value, varargin);
%Lexie on 3/10/2015 make the show_figure option work for both situations,
%w/o show_figure field
show_figure_option = ~isfield(data, 'show_figure') || data.show_figure;
% Process data.quantify_roi
switch data.quantify_roi
    case 0 % Do not quantify ROI
        disp('Warning: function quantify_region_of_interest - data.quantify_roi = 0');
        return;
    case 1 % Quantify ROI without tracking cells
        roi_type = 'draggable';
    case 2 % 2 - Quantify ROI with tracking
        roi_type = 'undraggable';
    case 3 % 3 - Quantify subcellular regions without ROI, but with tracking
        roi_type = 'no roi';
end

% When data.quantify_roi = 1 or 2
% data.quantify_roi = 1: only one roi which can be manually moved around
% data.quantify_roi = 2: more than 1 roi which can only be automatically tracked.  
if data.quantify_roi == 1 || data.quantify_roi ==2
    num_object = 1;
    if isfield(data,'num_roi')
        num_roi = data.num_roi;
    else
        num_roi = 1;
    end
end

if isfield(data, 'num_roi')
    num_roi = data.num_roi;
else
    num_roi = 1;
end

if nargin == 2
    cfp = ratio;
    yfp = ratio;
end

% Get cell_bw
temp_file_mat = strcat(data.output_path, 'cell_bw.t', num2str(data.index), '.mat');
%temp_file_tiff = strcat(data.output_path, 'cell_bw.t', num2str(data.index));
if data.quantify_roi == 2 || data.quantify_roi == 3
    data.track_cell = 1;
%    if isfield(data,'show_detected_boundary') && data.show_detected_boundary && ...
%            isfield(data, 'cell_bw')
     % Kathy 05/03/2017
     % In update_figure.m show_detected_boundary is forced to be 1. So
     % there are no other possibilities
    cell_bw = data.cell_bw;
    if save_bw_file 
        save(temp_file_mat, 'cell_bw');
    end
    [cell_bd, cell_label] = bwboundaries(cell_bw, 8, 'noholes');
    cell_prop = regionprops(cell_label, 'Area'); 
    num_object = length(cell_bd);
    obj = cell(num_object, 1);
    for i = 1:num_object
         obj{i} = bd2im(cell_bw, cell_bd{i}(:,2), cell_bd{i}(:,1));
    end
    
    for i = 1 : num_object
        data.cell_size{i}(data.index,1) = cell_prop(i).Area; %Column format -Shannon
    end
    % need to save cell_bw in a file somewhere
    clear cell_label cell_prop; % The value of num_object changed later
    
end % if data.quantify_roi ==2 || data.quantify_roi ==3,

% Get roi_bw
switch data.quantify_roi
    case 1 % not track cell
        roi_bw = data.roi_bw;
        roi_poly = data.roi_poly;
        if isfield(data,'need_apply_mask') && data.need_apply_mask ==4
            for i = 1:num_roi
                roi_bw{i} = roi_bw{i}.*data.mask;
            end
        end
    case 2 % move roi while tracking cell
        % use the centroid of the cell to track rois
        prop = regionprops(obj{1});
        if ~isfield(data, 'ref_centroid') % reference location
            data.ref_centroid = prop.Centroid;
            roi_bw = data.roi_bw;
            roi_poly = data.roi_poly;
        else % shift roi_bw and roi_poly
            this_c = prop.Centroid;
            c_diff = floor(this_c - data.ref_centroid+0.5);
            if length(data.roi_bw)<num_roi
                disp('Warning: quantify_region_of_interest - ');
                fprintf('Reduce data.num_roi to %d\n', length(data.roi_bw));
                data.num_roi = length(data.roi_bw);
                num_roi = data.num_roi;
            end
            roi_bw = cell(num_roi, 1);
            roi_poly = cell(num_roi, 1);
            for i = 1:min(num_roi, length(data.roi_bw))
                % shift bw by c_diff
                bw_shift = circshift(data.roi_bw{i}, [c_diff(2), c_diff(1)]);
                roi_bw{i} = bw_shift.*cell_bw;  % multiply by cell_bw to make sure ratio is calculated inside detected object
                % shift the boundary by c_diff
                roi_poly{i} = data.roi_poly{i}+ones(size(data.roi_poly{i}))*[c_diff(1),0; 0, c_diff(2)];
                clear bw_shift;
            end % for i
        end % if ~isfield(data, 'ref_centroid')
    case 3 %switch data.quantify_roi,
        [roi_poly, label_layer] = divide_layer(obj, num_roi, 'method',2, ...
            'xylabel', 'normal');
        % figure; imagesc(label_layer);
        % label = 1 outlayer; label = 3 inner layer
        num_object = length(obj);
        roi_bw = cell(num_roi, num_object); 
        for i = 1 : num_object
            for j = 1 : num_roi
               roi_bw{j, i} = (label_layer{i} == j);
            end
        end
end

% Extract the time value,
% Draw the rois,
% Quantify the FI and ratio in the ROIs.
data.time(data.index,1) = data.index;
data.time(data.index, 2) = get_time(data.file{1}, 'method',2);
% Draw ROIs
% provide option for displaying figure, Lexie in 03/06/2015
if (isfield(data, 'show_figure') && data.show_figure == 1)...
        || ~isfield(data, 'show_figure')
    figure(data.f(1)); hold on;
    roi_file = strcat(data.output_path, 'roi.mat');
    draw_polygon(gca, roi_poly, 'red', roi_file, 'type', roi_type);
end

%% Modified the following for loop to shrink area of quantification. - Shannon 8/4/2016
for i = 1 : num_object
    for j = 1:num_roi %subcellular layers
        %Modified to try to shrink the area that needs to be computed. - Shannon 8/4/2016
        data.ratio{i}(data.index, j) = compute_average_value(ratio, roi_bw{j,i});
        data.channel1{i}(data.index, j) = compute_average_value(cfp, roi_bw{j,i});
        data.channel2{i}(data.index, j) = compute_average_value(yfp, roi_bw{j,i});
    end
end; clear i j
%%
    
% quantify background
if isfield(data, 'subtract_background') && data.subtract_background
    data.channel1_bg(data.index) = compute_average_value(data.im{1}, data.bg_bw);
    data.channel2_bg(data.index) = compute_average_value(data.im{2}, data.bg_bw);
end


return;
