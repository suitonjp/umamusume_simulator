% 入力に対して、閾値を超えた分の値を width の幅毎に減衰させる
%   in: 入力, thr: 閾値, width: 減衰幅
%   減衰量は、減衰幅毎に20%, 40%, 60%, 80%, 100% となる
% 
% 例 - in=620, thr=500, width=50
%      ret = 500 + 50*0.8 + 50*0.6 + 20*0.4 -> 578
function ret = attenuate_status(in, thr, width)
    if in < thr
        ret = in;
    elseif in < (thr+width)
        ret = in + (in-thr)*0.8;    
    elseif in < (thr+width*2)
        ret = in + width*0.8 + (in-thr-width)*0.6;
    elseif in < (thr+width*3)
        ret = in + width*1.4 + (in-thr-width*2)*0.4;
    elseif in < (thr+width*4)
        ret = in + width*1.8 + (in-thr-width*3)*0.2;
    else
        ret = in + width*2;
    end