%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%------------------------------------------------------%
%
% Machine Perception and Cognitive Robotics Laboratory
%
%     Center for Complex Systems and Brain Sciences
%
%              Florida Atlantic University
%
%------------------------------------------------------%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%------------------------------------------------------%
%
% Locally Competitive Algorithms Demonstration
% Using natural images data, see:
% Rozell, Christopher J., et al.
% "Sparse coding via thresholding and
% local competition in neural circuits."
% Neural computation 20.10 (2008): 2526-2563.
%
%------------------------------------------------------%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function MPCR_LCA_Dictionary_Block
clear all
close all
clc

load('IMAGES.mat')

I=IMAGES;

k=0.1;
patch_size=256;
neurons=576;
batch_size=100;
h=10/batch_size;

W = randn(patch_size, neurons);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for j=1:50000
    
    W = W*diag(1./sqrt(sum(W.^2,1)));
    
    X=create_batch(I,patch_size,batch_size);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    b = W'*X;
    G = W'*W - eye(neurons);
    
    u = zeros(neurons,batch_size);
    
    for i =1:10
        
        
        switch randi(6) % mod(j,7)+1%
            case 1
                a=blocksparse_vec(u,12);
            case 2
                a=blocksparse_vec(u,8);
            case 3
                a=blocksparse_vec(u,6);
            case 4
                a=blocksparse_vec(u,4);
            case 5
                a=blocksparse_vec(u,3);
            case 6
                a=blocksparse_vec(u,2);
            case 7 
                a=u.*(abs(u) > k);
        end

        u = 0.9 * u + 0.01 * (b - G*a);
        
    end
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    W = W + h*((X-W*a)*a');
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    imagesc(filterplot(W))
    
    colormap(jet)
    
    drawnow()
    
    
end




end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function XX = blocksparse_vec(XX,blocksize)

s=size(XX(:,1));
n=sqrt(s(1));

blocks=n/blocksize;

A = reshape(1:n^2,[n n])';
B = im2col1(A,[n/blocks n/blocks]);

for i=1:size(XX,2)
    
    X=reshape(XX(:,i),[n n]);
    
    [m1 m2]=max(sum(abs(X(B)),1));
    
    D=0*B;
    
    D(:,m2)=X(B(:,m2));
    
    XX(:,i)=reshape(im2col1(D,[blocksize blocks]),s);
    
end

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function E = im2col1(A,blocksize)

r = blocksize(1);
c = blocksize(2);
e = r*c;

B = zeros(size(A,1)+((mod(size(A,1),r)~=0)*(r - mod(size(A,1),r))),size(A,2)+((mod(size(A,2),c)~=0)*(c - mod(size(A,2),c))));
B(1:size(A,1),1:size(A,2)) = A;

C = reshape(B,r,size(B,1)/r,[]);
D = reshape(permute(C,[1 3 2]),size(C,1)*size(C,3),[]);
E = reshape(permute(reshape(D,e,size(D,1)/e,[]),[1 3 2]),e,[]);

return;

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function I=create_batch(Images,patch_size,batch_size)

[imsize, imsize, num_Images] = size(Images);

border=10;
patch_side = sqrt(patch_size);

I = zeros(patch_size,batch_size);

im_num= ceil(num_Images * rand());

for i=1:batch_size
    
    row = border + ceil((imsize-patch_side-2*border) * rand());
    col = border + ceil((imsize-patch_side-2*border) * rand());
    
    I(:,i) = reshape(Images(row:row+patch_side-1, col:col+patch_side-1, im_num),[patch_size, 1]);
    
    
end


end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [D] = filterplot(X)

X=X';

[m n] = size(X);


w = round(sqrt(n));
h = (n / w);

c = floor(sqrt(m));
r = ceil(m / c);

p = 1;

D = - ones(p + r * (h + p),p + c * (w + p));

k = 1;
for j = 1:r
    for i = 1:c
        D(p + (j - 1) * (h + p) + (1:h), p + (i - 1) * (w + p) + (1:w)) = reshape(X(k, :), [h, w]) / max(abs(X(k, :)));
        k = k + 1;
    end
    
end

end