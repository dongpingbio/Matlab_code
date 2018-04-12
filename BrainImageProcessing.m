% Brain Image Processing
warning off;
clc;
close all;

xls_name = '1.xlsx';

% Read all data from folder
folder_name = 'E:\Dong Ping\data\pic sample to be tested\';
my_file = dir([folder_name, '*.tif']);
len = length(my_file);

pic_sel = '01.tif';  % Empty, Name

FileName_CellNumber = cell(2, len);

for i = 1:len
    tmp_file = my_file(i).name;
    %filename = 'I:\[PhD backup]\[Projects]\TRN\2014-10-11 T-A-7#\2014-10-11 T-A-7# B-1.lif_TileScan_001_Merging001\2014-10-11 T-A-7# B-1.lif_TileScan_001_Merging001_z0.tif';
    I0 = imread([folder_name, tmp_file]);

    I0_R = I0(:,:, 1);  % 8-bit
    I0_G = I0(:,:, 2);
    I0_B = I0(:,:, 3);

    h_fig = figure;
    imshow(I0_R);

    [I0_R_w,noise]=wiener2(I0_R,[30 30]);  % Filtering, to be set
    I0_R_w_a = imadjust(I0_R_w,[0.25 1], [0.2 1]);  % Adjust contrast, to be set
    I0_R_BW = im2bw(I0_R_w_a, 0.25);  % Gray to BW,  to be set
    I0_R_BW_m = medfilt2(I0_R_BW,[5,5]);  % Medium Filter, get rid of pepper noise

    % Count the connected area
    L = bwlabeln(I0_R_BW_m, 8); 
    S = regionprops(L, 'Area');
    pos = ([S.Area] <= 400) & ([S.Area] >= 20);  % To be set the area threshold
    pos_ex = ~pos;
    bw2 = ismember(L, find(pos));
    bw2_ex = ismember(L, find(pos_ex));

    % Plot normal and exceptions
    %{
    figure(101);
    imshow(bw2);
    figure(102);
    imshow(bw2_ex);
    %}
    
    S1 = [S.Area];
    S1 = S1(pos);  % Final Area and number of connected regions

    N = length(S1);  % Number
    disp('Cell Number:')
    disp(N);

    % Get the center of connected areas
    C = regionprops(bw2, 'Centroid');  % to be processed
    C1 = [C.Centroid];
    C1 = reshape(C1, 2, length(C1)/2)';

    % For exception
    C_ex = regionprops(bw2_ex, 'Centroid');  % to be processed
    C1_ex = [C_ex.Centroid];
    C1_ex = reshape(C1_ex, 2, length(C1_ex)/2)';


    % Mark the connected region on the orignal picture
    figure(h_fig); hold on;
    plot(C1(:,1), C1(:,2), 'r+', 'MarkerSize', 10);
    plot(C1_ex(:,1), C1_ex(:,2), 'g+', 'MarkerSize', 10);
    hold off;
    title([tmp_file, '  Cell Number:', num2str(N)]);
    
    FileName_CellNumber{1, i} = tmp_file(1:end-4);
    FileName_CellNumber{2, i} = N;
    
    if strcmp(pic_sel, tmp_file)
        figure(102);
        imshow(I0_R_BW_m);
        figure(103);
        imshow(bw2);  % Show BW picture after counting the connected region
        figure(104);
        hist(S1);  % Statistics
    end

end

xlswrite([folder_name, xls_name], FileName_CellNumber);  % Output to XLS file.

% Output the the image of the same size from the original, and mark with
% different color
%{
M0 = size(I0_R, 1);
N0 = size(I0_R, 2);
C1_int = fix(C1);  % integer
idx = sub2ind([M0, N0], C1_int(:,2), C1_int(:,1));
I0_RR = zeros(M0, N0);
I0_RR(idx) = 255;
I0_RR = uint8(I0_RR);

I0_R1 = I0_R;  % Eliminate other G, B Channels' Color
I0_R1(idx) = 0;

I0_new = uint8(zeros(M0, N0, 3));
I0_new(:,:,1) = I0_R;
I0_new(:,:,2) = I0_R1;
I0_new(:,:,3) = I0_R1;
%}


% For Normal Points
%{
M0 = size(I0_R, 1);
N0 = size(I0_R, 2);
C1_int = fix(C1);  % integer
idx = sub2ind([M0, N0], C1_int(:,2), C1_int(:,1));
I0_RR = zeros(M0, N0);
I0_RR(idx) = 255;
I0_RR = uint8(I0_RR);

% For Exceptional Points
C1_int_ex = fix(C1_ex);  % integer
idx_ex = sub2ind([M0, N0], C1_int_ex(:,2), C1_int_ex(:,1));
I0_RG = zeros(M0, N0);
I0_RG(idx_ex) = 255;
I0_RG = uint8(I0_RG);

I0_new = uint8(zeros(M0, N0, 3));
I0_new(:,:,1) = I0_RR;
I0_new(:,:,2) = I0_RG;
I0_new(:,:,3) = I0_R;


figure(201);
imshow(I0_new);

imwrite(I0_new, 'Marked_Figure.tif');
%}

%I0_R() = 


disp('test');