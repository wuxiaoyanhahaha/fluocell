% function test_seq(lib_name, varargin)
% data = seq_init_data(lib_name);
% parameter_name = {'total_num_seqs', 'num_seqs', 'num_iters','select_good_sequence'};
% parameter_default = {0, data.num_seqs, 0, true};
% Parameter priorities: (1) input from command line,  
% (2) specified in seq_init_data. 
%
% Example: 
% >> data = seq_init_data('LIB03');
% >> test_seq(data,'start_seq', 10e6+1, 'num_seqs', 1e3, 'get_info', false);

% Author: Shaoying Lu , shaoying.lu@gmail.com
% Date: 03/24/2016 - 08/30/2016
function output_seq = test_seq(data, varargin)
% Parameter priorities: (1) input from command line,  
% (2) specified in seq_init_data. 
parameter_name = {'total_num_seqs', 'num_seqs', 'num_iters','select_good_sequence'};
parameter_default = {0, data.num_seqs, 0, 1};
[total_num_seqs, num_seqs, num_iters, select_good_sequence] = parse_parameter(parameter_name,...
    parameter_default, varargin);

output = true;
count_sanger = false;
output_num_seqs = 10;

%% Load sequences
% Initialize library information
% 56 seconds for 1 million sequences of all three libraries
% Original sequece 
p = data.path;
library_file = data.library_file;
output_file = strcat(p, data.lib_name, '_result.mat');
start_code = data.start_code;
num_codes = data.num_codes;

% Initialize the library
if output,
    display(strcat('Library file: ', library_file));
end;

% total_num_seqs = 2e6; 
% num_seqs = 1e6;
% num_iters = 2;
if ~total_num_seqs,
    [~, total_num_seqs] = get_seq_array(strcat(p, library_file), 'get_info', true);
    num_iters = floor(total_num_seqs/num_seqs);
end;
num_res = total_num_seqs - num_iters*num_seqs;
% ignore the residual sequence if they are less than 0.05*2M =  0.1M
if num_res <= 0.05*num_seqs,
    output_seq = cell(num_iters, 1);
else % total_num_seqs > num_iters*num_seqs + 0.05*num_seqs 
    output_seq = cell(num_iters+1, 1);
end
for i = 1:length(output_seq),
    % Extract the seq_array from start_seq and extract each sequence from
    % start_code
    start_seq = (i-1)*num_seqs+1;
    if i == num_iters+1,
        num_seqs = num_res;
    end;
    seq_array = get_seq_array(strcat(p, library_file), 'start_seq', start_seq, 'num_seqs', num_seqs, ...
    'start_code', start_code, 'num_codes', num_codes, 'get_info', false, ...
    'select_good_sequence', select_good_sequence);
    if count_sanger,
        count_sanger_sequence(seq_array, library_file);
    end;
    output_seq{i} = count_unique_sequence(seq_array, output_num_seqs);
    clear seq_array;
end

frequency= []; nucleotide = []; amino_acid = [];
for i = 1:length(output_seq), %Usually <10 loops
    frequency = cat(1, frequency, output_seq{i}.frequency);
    nucleotide = cat(1, nucleotide, output_seq{i}.nucleotide);
    amino_acid = cat(1, amino_acid, output_seq{i}.amino_acid);
end;
% save files
if output,
    save(output_file, 'frequency', 'nucleotide', 'amino_acid');
end;

[seq_unique, ~, index_unique] = unique(nucleotide, 'rows'); 
num_unique_seqs = length(seq_unique);
count = zeros(num_unique_seqs,1);
for j = 1:num_unique_seqs,
    count(j) = sum(frequency(index_unique == j));
end;
[count_sort, index_count] = sort(count, 'descend');


assert(num_unique_seqs>= output_num_seqs, ...
    'test_seq() Error: num_unique_seqs< output_num_seqs');
for j = 1:output_num_seqs,
    nt = seq_unique(index_count(j), :);
    amino_acid = nt2aa(nt, 'ACGTOnly', 'false');
    % if output & regexp(amino_acid, 'Y'),
    if output && ~isempty(regexp(amino_acid, 'Y', 'ONCE')),
         display(sprintf('%d\t%s\t%s', count_sort(j), amino_acid, nt)); 
    end;
    clear nt amino_acid;
end    
clear lib_index library_file aa_seq_array;
return; 

% Count the frequency of unique sequences. 
%     frequency = cat(1, output_seq.frequency);
%     nucleotide = cat(1, output_seq.nucleotide);
%     amino_acid = cat(1, output_seq.amino_acid);
function output_seq = count_unique_sequence(seq_array, output_num_seqs)
    % The output of unique() is: 
    %         seq_unique = seq_array(index_array)
    %         seq_array = seq_unique(index_unique)
    [seq_unique, index_array, index_unique] = unique(seq_array, 'rows');
    count = hist(index_unique, length(index_array));
    % sum(count == 1) + sum(count >=2) should be num_seqs

    % Collect the squences in the order from the most to least frequent 
    % up to output_num_seqs sequences, including sequences
    % with the same number of counts. 
    count_sort = sort(count, 'descend');
    count_unique = unique(count_sort); % in ascending order
    nn = length(count_unique);
    nn_end = max(1, nn-output_num_seqs);
    % count the number of sequences collected
    ii = 0;
    for j = nn:-1:nn_end,
        cuj = count_unique(j);
        nt = seq_unique(count == cuj, :);
        ii = ii+size(nt,1); clear nt;
    end;
    % collect the high-frequency sequences
    output_seq_cell = cell(ii, 3);
    field_name = {'frequency', 'nucleotide', 'amino_acid'};
    ii = 0;
    for j =nn:-1:max(1, nn-output_num_seqs),
        % Count
        cuj = count_unique(j); 
        nt = seq_unique(count == cuj, :);
        for kk = 1:size(nt,1),
            ii = ii+1;
            output_seq_cell{ii, 1} = cuj; % frequency
            output_seq_cell{ii, 2} = nt(kk,:); % nucleotide
            output_seq_cell{ii, 3} = nt2aa(nt(kk,:), 'ACGTOnly', 'false'); % amino_acid
        end;
        clear nt;
    end;
    output_seq = cell2struct(output_seq_cell, field_name, 2);
return;

% Count the frequency of ATCG as sanger sequencing
% Plot the counts. 
function count_sanger_sequence(seq_array, title_string)
    num_codes = size(seq_array, 2);
    freq = zeros(num_codes, 4); % ' a t c g'  
    for j = 1:num_codes,
        count = basecount(seq_array(:,j));
        freq(1, j) = count.A;
        freq(2, j) = count.T;
        freq(3, j) = count.C;
        freq(4, j) = count.G;
    end;
    figure; hold on; freq_color = 'rgbk';
    title(title_string);
    for k= 1:4,
        plot(freq(k,:),freq_color(k));
    end;
    legend('A', 'T', 'C', 'G');
    xlabel('Position'); ylabel('Count');

    % Draw the sequence logo. 
    if num_codes<1000, 
        aa_seq_array = nt2aa(seq_array, 'ACGTOnly', false);
        seqlogo(aa_seq_array);
    end;
return;
