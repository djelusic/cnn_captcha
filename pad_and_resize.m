for i=1:6
img = si(:,:,i);
imgSize=size(img);
finalSize=40;   
padImg=ones(finalSize);
padImg(finalSize/2+(1:imgSize(1))-floor(imgSize(1)/2),...
    finalSize/2+(1:imgSize(2))-floor(imgSize(2)/2))=img;
padImg_res = imresize(padImg, [28 28]);
si_res(:,:,i) = padImg_res(:,:);
end