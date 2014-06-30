pad = 1;
path = fullfile(fileparts(mfilename('fullpath')), 'captcha_testset');
fid = fopen(fullfile(fileparts(mfilename('fullpath')), 'captcha_testset_codes.txt'));
B = textscan(fid, '%s%s', 'delimiter',' ');
captcha_names = B{1};
captcha_labels = B{2};

suma = 0;

for i=1:length(B{1})
A = imread(fullfile(path, [captcha_names{i}]));

si = segmentiranje(A);
%pad and resize
if pad == 1
for j=1:5
img = si(:,:,j);
imgSize=size(img);
finalSize=34;   
padImg=ones(finalSize);
padImg(finalSize/2+(1:imgSize(1))-floor(imgSize(1)/2),...
    finalSize/2+(1:imgSize(2))-floor(imgSize(2)/2))=img;
padImg_res = imresize(padImg, [28 28]);
%padImg_res = im2bw(padImg_res);
si_res(:,:,j) = padImg_res(:,:);
end
end
if pad == 1
si_res = double(si_res);
si_res = normalize_data(si_res, 5, 28);
else
si = double(si);
si_res = normalize_data(si, 5, 28);
end

for j=1:5
temp = B{2}(i);
labs(j) = pretvori(temp{1}(j));
end

[~,cost,preds]=cnnCost(opttheta,si_res,labs',numClasses,...
                filterDim,numFilters,poolDim,true);
				
if preds' == labs
suma = suma+1;
end
end

fprintf('%d of 500 captchas have been successfully identified, accuracy is %f%%\n',suma, suma/5);