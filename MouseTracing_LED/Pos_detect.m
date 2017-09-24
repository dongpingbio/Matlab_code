function pos_result=Pos_detect(mice_x,mice_y,t_xLeft, t_xRight, t_yUp, t_yDown)
if mice_x>t_xLeft&&mice_x<t_xRight&&mice_y>t_yUp&&mice_y<t_yDown
    pos_result=1;
else
    pos_result=0;
end