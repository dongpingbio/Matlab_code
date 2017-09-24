function c_pos=Extract_RedLed(input_frame,xLeft, xRight, yUp, yDown,area_L,area_H)

% To chop the ori_image based on analysis area
I0=input_frame(yUp:yDown,xLeft:xRight,:);

% figure(01);
% imshow(I0);
% Extract red signal
I0_R=I0(:,:,1);
I0_R_BW = im2bw(I0_R, 0.99); % Gray to BW,  to be set
I0_R_BW_m = medfilt2(I0_R_BW,[5,5]); % Medium Filter, get rid of pepper noise
figure(02);
imshow(I0_R_BW_m);

% Count the connected area
L = bwlabeln(I0_R_BW_m, 8);
S = regionprops(L, 'Area');

% To be set the area threshold
pos = ([S.Area] <= area_H) & ([S.Area] >= area_L);

bw2 = ismember(L, find(pos));


S1 = [S.Area];
S1 = S1(pos);
C = regionprops(bw2, 'Centroid');  % to be processed
% Get the center of connected areas
C1 = [C.Centroid];
C1 = reshape(C1, 2, length(C1)/2)';
c_pos=C1;

% Mark the connected region on the orignal picture

% figure(01); hold on;
% plot(C1(:,1), C1(:,2), 'g+', 'MarkerSize', 10);
% hold off;

end