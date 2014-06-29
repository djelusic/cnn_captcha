path = fullfile(fileparts(mfilename('fullpath')), 'single_chars_trainset');
for k = 1:6;
which_testset = k;

fid = fopen(fullfile(fileparts(mfilename('fullpath')), 'chars_codes.txt'));
A = textscan(fid, '%s%s', 'delimiter',' ');
trainnames = A{1};
trailabels = A{2};
if which_testset == 1;
	trainnames = trainnames(10001:60000);
	trainlabels = trailabels(10001:60000);
elseif which_testset == 6;
	trainnames = trainnames(1:50000);
	trainlabels = trailabels(1:50000);
else
	trainnames = cat(2, trainnames(1:(which_testset-1)*10000)', trainnames(which_testset*10000+1:60000)');
	trainlabels = cat(2, trailabels(1:(which_testset-1)*10000)', trailabels(which_testset*10000+1:60000)');
	trainnames = trainnames'; trainlabels = trainlabels';
end
for i=1:50000
A = imread(fullfile(path, [trainnames{i}]));
A = im2double(A);
C = uint8(255 * ((A >= 0.4 & A <= 0.5) | ((A >= 0.9 & A <= 1))));
A = im2bw(C);
A = double(A);
images(:,:,i) = A(:,:);
end

images = images/255;

fid = fopen(fullfile(fileparts(mfilename('fullpath')), 'codes.txt'));
A = textscan(fid, '%s%s', 'delimiter',' ');
trainnames = A{1};
trailabels = A{2};

testnames = trainnames((which_testset-1)*10000+1:which_testset*10000);
testlabels = trailabels((which_testset-1)*10000+1:which_testset*10000);

for i=1:10000
A = imread(fullfile(path, [testnames{i}]));
%A = rgb2gray(A);
%A = single(A);
A = im2double(A);
C = uint8(255 * ((A >= 0.4 & A <= 0.5) | ((A >= 0.9 & A <= 1))));
A = im2bw(C);
A = double(A);
testImages(:,:,i) = A(:,:);
end

testImages = testImages/255;

for i = 1:50000
trainlabelsnew(i) = pretvori(trainlabels{i});
end

for i = 1:10000
testlabelsnew(i) = pretvori(testlabels{i});
end


testLabels = testlabelsnew';
labels = trainlabelsnew';

images = normalize_data(images, 50000, 28);
testImages = normalize_data(testImages, 10000, 28);

cnnTrain;
accuracies(k) = acc;

end