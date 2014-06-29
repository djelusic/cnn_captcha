pad = 1;

for k=1:5
path = fullfile(fileparts(mfilename('fullpath')), 'captcha_xval_set');
fid = fopen(fullfile(fileparts(mfilename('fullpath')), 'captcha_xval_codes.txt'));

which_testset = k;

B = textscan(fid, '%s%s', 'delimiter',' ');
captcha_names = B{1};
captcha_labels = B{2};

if which_testset == 1;
	captcha_names = captcha_names(1001:5000);
	captcha_labels = captcha_labels(1001:5000);
elseif which_testset == 5;
	captcha_names = captcha_names(1:4000);
	captcha_labels = captcha_labels(1:4000);
else
	captcha_names = cat(2, captcha_names(1:(which_testset-1)*1000)', captcha_names(which_testset*1000+1:5000)');
	captcha_labels = cat(2, captcha_labels(1:(which_testset-1)*1000)', captcha_labels(which_testset*1000+1:5000)');
	captcha_names = captcha_names'; captcha_labels = captcha_labels';
end

for i=1:length(captcha_names)
A = imread(fullfile(path, [captcha_names{i}]));

si = segmentiranje(A);
%pad and resize
if pad == 1
for j=1:5
img = si(:,:,j);
imgSize=size(img);
finalSize=36;   
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
temp = captcha_labels(i);
labs(j) = pretvori(temp{1}(j));
end

for j=1:5
images(:,:,(i-1)*5+j) = si_res(:,:,j);
labels((i-1)*5+j) = labs(j);
end

end

path = fullfile(fileparts(mfilename('fullpath')), 'captcha_xval_set');
fid = fopen(fullfile(fileparts(mfilename('fullpath')), 'captcha_xval_codes.txt'));
B = textscan(fid, '%s%s', 'delimiter',' ');
captcha_names = B{1};
captcha_labels = B{2};

captcha_names = captcha_names((which_testset-1)*1000+1:which_testset*1000);
captcha_labels = captcha_labels((which_testset-1)*1000+1:which_testset*1000);

for i=1:length(captcha_names)
A = imread(fullfile(path, [captcha_names{i}]));

si = segmentiranje(A);
%pad and resize
if pad == 1
for j=1:5
img = si(:,:,j);
imgSize=size(img);
finalSize=36;   
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

cnnTrain;
accuracies(k) = acc;

end