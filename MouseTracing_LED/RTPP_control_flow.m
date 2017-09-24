clc;
close all;
clear all;
% This program is used for video-based RTPP experiment for the mouse.
% This program is written by Ping Dong (ZJU-ION), with the help of Di Zheng
% Contact email dongping@zju.edu.cn

% 01-1 Connect the arduino
a=arduino('com7','uno');

% 01 Before experiment start, Load the camera, take a snap, a) draw the
% analysis_area boundary, b) draw the TurnOn_area which turn on the laser

% Connect to the webcam.
cam = webcam(1);
% To open a Video Preview window, use the preview function.
preview(cam);
% To acquire a single frame, use the snapshot function.
% img = snapshot(cam);

% Display the frame in a figure window.
% image(img);
% A common task is to repeatedly acquire a single image, process it, ...
% and then store the result. To do this, snapshot should be called in a loop.

    figure(1000);
    img = snapshot(cam);
    imshow(img);
    pause(1);

% Clean up
clear cam;

% Draw the analysis area
[a_xLeft, a_xRight, a_yUp, a_yDown,a_x,a_y,a_w,a_h]=ManualDraw_analysisArea;
% Draw the Turn_on area
[t_xLeft, t_xRight, t_yUp, t_yDown,t_x,t_y,t_w,t_h]=ManualDraw_analysisArea;

% 02-0 setting the analysis area
area_L=10; % pixel
area_H=1000; % pixel

% 02 RTPP experiment start, countiously monitor the video
cam = webcam(1);
pos_sum=[];
pos_result_tmp=[];
for idx = 1:30
    figure(idx);
    img = snapshot(cam);
    % 02-1 Find the position of the mouse
    c_pos=Extract_RedLed(img,a_xLeft, a_xRight, a_yUp, a_yDown,area_L,area_H);
    imshow(img); hold on;
    rectangle('Position',[a_x,a_y,a_w,a_h],'EdgeColor','k','LineWidth',2);
    rectangle('Position',[t_x,t_y,t_w,t_h],'EdgeColor','b','LineWidth',2);
    
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
        writeDigitalPin(a,13,1);
        pause(0.5);
        writeDigitalPin(a,13,0);
        pause(0.1);
    else 
        disp('Laser off!')
    end
    % Summary the pos data
    pos_sum=[pos_sum; pos_result];
    plot(mice_x,mice_y, 'g+', 'MarkerSize', 10); hold on;
    % 02-3 Turn on the laser by arduino, wait for a interval time, go to
    % step 02-1
    pause(1);
    pos_result_tmp=pos_result;
end
clear cam;

