fprintf('Loading datasets...\n');

pad = 1;
path = fullfile(fileparts(mfilename('fullpath')), 'captcha_xval_set');
fid = fopen(fullfile(fileparts(mfilename('fullpath')), 'captcha_xval_codes.txt'));

B = textscan(fid, '%s%s', 'delimiter',' ');
captcha_names = B{1};
captcha_labels = B{2};
progress = 0;
for i=1:2000
if mod(i, 250) == 0
progress = progress+1;
fprintf('%d%%...\n', progress*10);
end
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
temp = captcha_labels(i);
labs(j) = pretvori(temp{1}(j));
end

for j=1:5
images(:,:,(i-1)*5+j) = si_res(:,:,j);
labels((i-1)*5+j) = labs(j);
end

end

captcha_names = captcha_names(2001:2500);
captcha_labels = captcha_labels(2001:2500);

for i=1:500
if mod(i+2000, 250) == 0
progress = progress+1;
fprintf('%d%%...\n', progress*10);
end
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
temp = captcha_labels(i);
labs(j) = pretvori(temp{1}(j));
end

for j=1:5
testImages(:,:,(i-1)*5+j) = si_res(:,:,j);
testLabels((i-1)*5+j) = labs(j);
end

end

if size(labels, 1) == 1
labels = labels';
end
if size(testLabels, 1) == 1
testLabels = testLabels';
end

fprintf('Training neural net...\n');

cnnTrain;

fprintf('Loading captcha set...\n');

test_captcha;