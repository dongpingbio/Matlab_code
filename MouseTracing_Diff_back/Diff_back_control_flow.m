clc;
close all;
clear all;
% This program is used for video-based RTPP experiment for the mouse.
% This program is written by Ping Dong (ZJU-ION), with the help of Di Zheng
% Contact email dongping@zju.edu.cn

% 01-1 Connect the arduino
a=arduino('com7','uno');
writeDigitalPin(a,2,0);
pause(0.1);

% 01 Before experiment start, Load the camera, take a snap, a) draw the
% analysis_area boundary, b) draw the TurnOn_area which turn on the laser

% Connect to the webcam.
cam = webcam(1);
% To open a Video Preview window, use the preview function.
preview(cam);
% To acquire a single frame, use the snapshot function.
% img = snapshot(cam);

% To get a background frame
figure(1000);
background_frame = snapshot(cam);
imshow(background_frame);
pause(1);

% Clean up
clear cam;

% Draw the analysis area
[a_xLeft, a_xRight, a_yUp, a_yDown,a_x,a_y,a_w,a_h]=ManualDraw_analysisArea;
% Draw the Turn_on area
[t_xLeft, t_xRight, t_yUp, t_yDown,t_x,t_y,t_w,t_h]=ManualDraw_analysisArea;

% 02-0 setting the analysis area
area_L=800;
area_H=5000;

% 02 RTPP experiment start, countiously monitor the video
cam = webcam(1);
pos_sum=[];
pos_result_tmp=[];
mice_x=0;
mice_y=0;
for idx = 1:2000
    % Get the picture from the cam
    input_frame = snapshot(cam);
    figure(02);
    imshow(input_frame);
    % 02-1 Find the position of the mouse
    c_pos=Extract_diff_back(background_frame,input_frame,a_xLeft, a_xRight, a_yUp, a_yDown,area_L,area_H);
    if ~isempty(c_pos)
        % 02-2 Logical determinant whether the mouse is within the TurnOn_area
        mice_x=c_pos(1)+a_xLeft;
        mice_y=c_pos(2)+a_yUp;
        pos_result=Pos_detect(mice_x,mice_y,t_xLeft, t_xRight, t_yUp, t_yDown);
    else
        pos_result = pos_result_tmp;
    end
    % Turn on the laser by arduino output
    Laser_output=pos_result;
    if Laser_output==1
        disp('Laser on!')
        figure(02); hold on;
        rectangle('Position',[a_x,a_y,a_w,a_h],'EdgeColor','k','LineWidth',2);
        rectangle('Position',[t_x,t_y,t_w,t_h],'EdgeColor','b','LineWidth',2);
        plot(mice_x,mice_y, 'b+', 'MarkerSize', 10); hold off;
        writeDigitalPin(a,2,1);
        pause(0.5);
        writeDigitalPin(a,2,0);
        pause(0.1);
    else
        figure(02); hold on;
        rectangle('Position',[a_x,a_y,a_w,a_h],'EdgeColor','k','LineWidth',2);
        rectangle('Position',[t_x,t_y,t_w,t_h],'EdgeColor','b','LineWidth',2);
        plot(mice_x,mice_y, 'r+', 'MarkerSize', 10); hold off;
        disp('Laser off!')
    end
    pause(0.1);
    pos_result_tmp=pos_result;
end
clear cam;

