% >> lib_name = 'LIB03', 'fyn_low_fret', or 'fyn_high_fret' etc
% >> data =seq_init_data( lib_name);
function data = seq_init_data( lib_name )
% root = 'F:/data/2015/mint_1029/';
% root = 'E:/data/2016/mint/';
root = '/Volumes/KathyWD2TB/data/';
data.lib_name = lib_name;
data.num_seq = 2e6; % 1e3

switch lib_name 
    case 'LIB03' % Additiona libraries LIB01 and LIB02
        data.path = strcat(root, 'mutseq_firstrun/');
        data.library_file = 'LIB03_R1.fastq';
        data.start_seq = 1;         % 4e6+1
        data.start_code = 40;
        data.num_code = 21;
    case 'LIB02' % Additiona libraries LIB01 and LIB02
        data.path = strcat(root, 'mutseq_firstrun/');
        data.library_file = 'LIB02_R1.fastq';
        data.start_seq = 1;         % 4e6+1
        data.start_code = 40;
        data.num_code = 21;
    case 'aligned_lib3' % Aligned sequence of mutation region only
        data.path = strcat(root, 'mutregion/');
        data.library_file = 'lib3.mutregion.fastq';
        data.start_seq = 4e6+1;
        data.start_code = 1;
        data.num_code = 21;
        % Results of 'aligned_lib3' in 12/2/2015 email. 
        % (1) The high-frequency counts are much lower in frequency
        % 20/2M in comparison to the original sequence which had 
        % about 1000 counts/2M. 
        % (2) Most of the identified sequences had many 3-5 Xs out 
        % of 7 residues in them. 
        % (3) The only good one "EGTYGVV" could not find a match 
        % in blast. 
        % Therefore, I suspect that there is some kind of 
        % mis-alignment. 
    % ---8/30/2016 ---
    % 2nd round of library sorting
    % selection criteria: has 'CAT' in the NT sequence
    % select_good_sequence = 2
    % >> data = seq_init_data('fyn_low_fret');
    % >> test_seq(data,'total_num_seq', 0, 'num_seq', data.num_seq, 'num_iter', 0, ...
    % >> 'select_good_sequence', 0);
%     case 'fyn_low_fret' % low FRET/ECFP
%         data.path = strcat(root, '0829_2016/');
%         data.library_file = 'Fyn-LowFRET_S1_L007_R1_001.fastq';
%         data.start_seq = 1;         
%         data.start_code = 21;
%         data.num_code = 21;
%     case 'fak_low_fret' 
%         data.path = strcat(root, '0829_2016/');
%         data.library_file = 'FAK-LowFRET_S3_L007_R1_001.fastq';
%         data.start_seq = 1;         
%         data.start_code = 21;
%         data.num_code = 21;
%     case 'fak_high_fret' 
%         data.path = strcat(root, '0829_2016/');
%         data.library_file = 'FAK-HighFRET_S4_L007_R1_001.fastq';
%         data.start_seq = 1;        
%         data.start_code = 21;
%         data.num_code = 21;
%     case 'lck_low_fret' 
%         data.path = strcat(root, '0829_2016/');
%         data.library_file = 'LckKD-LowFRET_2nd_S5_L007_R1_001.fastq';
%         data.start_seq = 1;         
%         data.start_code = 21;
%         data.num_code = 21;
%     case 'lck_high_fret' 
%         data.path = strcat(root, '0829_2016/');
%         data.library_file = 'LckKD-HighFRET_2nd_S6_L007_R1_001.fastq';
%         data.start_seq = 1;         
%         data.start_code = 21;
%         data.num_code = 21;
%     case 'src_low_fret' 
%         data.path = strcat(root, '0829_2016/');
%         data.library_file = 'Src-LowFRET_S7_L007_R1_001.fastq';
%         data.start_seq = 1;        
%         data.start_code = 21;
%         data.num_code = 21;
%     case 'src_high_fret' 
%         data.path = strcat(root, '0829_2016/');
%         data.library_file = 'Src-HighFRET_S8_L007_R1_001.fastq';
%         data.start_seq = 1;        
%         data.start_code = 21;
%         data.num_code = 21;
        
        % 03/20/2017
    case 's3' % Corresponding to LIB03
        data.path = strcat(root, '2017/mint/0320/');
        data.library_file = 'YW003_S3_L001_R1_001.fastq';
        data.start_seq = 1;         % 4e6+1
        data.start_code = 1;
        data.num_code = 21;
        
    case 's2' % Corresponding to LIB02
        data.path = strcat(root, '2017/mint/0320/');
        data.library_file = 'YW002_S2_L001_R1_001.fastq';
        data.start_seq = 1;         
        data.start_code = 1;
        data.num_code = 21;

    case 's1' % Corresponding to LIB01
        data.path = strcat(root, '2017/mint/0320/');
        data.library_file = 'YW001_S1_L001_R1_001.fastq';
        data.start_seq = 1;         
        data.start_code = 1;
        data.num_code = 21;

        % 04/26/2017
    case 'fyn_high_fret'
        data.path = strcat(root, '2017/mint/0426/');
        data.library_file = 'FynSub_HighFRET1_18C_S3_L008_R1_001.fastq';
        data.start_seq = 1;
        data.start_code = 21;
        data.num_code = 21;
    case 'fyn_low_fret'
        data.path = strcat(root, '2017/mint/0426/');
        data.library_file = 'FynSub_LowFRET1_18C_S2_L008_R1_001.fastq';
        data.start_seq = 1;
        data.start_code = 21;
        data.num_code = 21;

    % 03/07/2018
    case '1ka_lib2_low'
        data.path = strcat(root, '2017/mint/HiSeq4000_0306_2018/');
        data.library_file = '1_KA-Lib2-Low_S10_L006_R1_001.fastq';
        data.start_seq = 1;
        data.start_code = 21;
        data.num_code = 21;   
    case '1km_lib2_high'
        data.path = strcat(root, '2017/mint/HiSeq4000_0306_2018/');
        data.library_file = '1_KM-Lib2-High_S11_L006_R1_001.fastq';
        data.start_seq = 1;
        data.start_code = 21;
        data.num_code = 21;   
    case '1ka_lib1_low'
        data.path = strcat(root, '2017/mint/HiSeq4000_0306_2018/');
        data.library_file = '1_KA-Lib1-Low_S6_L006_R1_001.fastq';
        data.start_seq = 1;
        data.start_code = 21;
        data.num_code = 21;      
    case '1km_lib1_high'
        data.path = strcat(root, '2017/mint/HiSeq4000_0306_2018/');
        data.library_file = '1_KM-Lib1-High_S7_L006_R1_001.fastq';
        data.start_seq = 1;
        data.start_code = 21;
        data.num_code = 21;      
end
return;

