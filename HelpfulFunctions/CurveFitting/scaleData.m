function scaledData = scaleData(d,minval,maxval)
% js 04132015- scale data from minval to maxval
    scaledData = d - min(d);
    scaledData = (scaledData/range(scaledData))*(maxval-minval);
    scaledData = scaledData + minval;