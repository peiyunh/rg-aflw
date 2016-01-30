close all;
%
load face_data_info;

% load matconvnet
addpath utils
addpath matconvnet/matlab;
vl_setupnn;

% load in models
model = 'models/qp2-aflw-fcn4s/net-epoch-1.mat';
obj = load(model);
net = dagnn.DagNN.loadobj(obj.net);
net.move('gpu');
net.mode = 'test';

% remove loss layer and labels
net.removeLayer('objective');
net.addLayer('sigmoid',dagnn.Sigmoid(),'prediction','score');

% load test image
avg = reshape(net.meta.normalization.averageImage,1,1,3);
bd = net.meta.normalization.border; 
%img = single(imread('00000007.jpg'));
%img = single(imread('00000001.jpg'));
img = single(imread('00000002.jpg'));

% remove border to make it [224,224]
im_ = img(bd(1)/2+1:end-bd(1)/2,bd(2)/2+1:end-bd(2)/2,:);
im = bsxfun(@minus, im_, avg);
im = gpuArray(im);
                             
% evaluate
scoreIdx = net.getVarIndex('score');
net.vars(scoreIdx).precious = 1;
net.eval({'input', im});
res = gather(net.vars(scoreIdx).value);

% visualize heatmap
figure(1);
imagesc(tile_3d_heat(res));
axis equal;
axis off;
colormap gray;

% visualize prediction
figure(2);
colors = distinguishable_colors(21*2);
imshow(im_./255);
hold on;
for i = 1:21
    heat = res(:,:,i);
    mask = nms_heat(heat,0);
    % nms
    [pV,pI] = max(reshape(heat.*mask,[],1));
    [py,px] = ind2sub([size(im,1),size(im,2)],pI);
    % 
    if pV > 0.5
        scatter(px,py,50,'filled','MarkerFaceColor',colors(i,:));
    end
    % pin text
    %text(px,py,[num2str(i) '-' landmark_names{i}], ...
    %     'BackgroundColor', 'yellow');
end
hold off;
