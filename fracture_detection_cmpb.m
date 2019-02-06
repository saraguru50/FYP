I = imread('./hairline/hairline63.jpg');
isRGB = ndims(I);
if(isRGB == 3)
   I = rgb2gray(I);
end
I = imresize(I,[320,150]);
%imwrite(I,'sample1.jpg','Quality',100);
figure, imshow(I),impixelinfo; title('Original Image');
entropy = entropy_segmentation(I);

s = size(I);
r = s(1,1);
c = s(1,2);

skeletonImage = entropy;

figure, imshow(skeletonImage),impixelinfo; title('Bone Contour');

fracture_points = 0;

% Contour correction in the generated contour using Chain codes and RDSS

global vis idx dfs_nodes prevx prevy;
prev = 1;
prevx = 0;
prevy = 0;
vis = zeros(r,c);
dfs_nodes = zeros(r*c,2);
idx = 1;
cnt = 0;
num = zeros(r*c,1);
chaincode_plot = zeros(r*c,1);
d = 1;


chaincode_value = zeros(r,c);

figure, imshow(I), impixelinfo; title('Location of Fracture Points'); hold on;


for i=1:r
    for j=1:c
        if(vis(i,j) == 0 && skeletonImage(i,j) == 1)
            prevx = i;
            prevy = j;
            dfs(i,j,r,c);
            b = zeros(idx-prev,2);
            l = 1;
            for k=prev:idx-1
                b(l,1) = dfs_nodes(k,1);
                b(l,2) = dfs_nodes(k,2);
                l = l + 1;
            end
            val = size(b);
            if(val(1,1) == 0)
                continue;
            end
            cnt = cnt + 1;
            cc = chaincode(b);
            m = size(cc.code);
            %disp(m(1,1));
            l = 1;
            for k=1:m(1,1)
                chaincode_value(b(l,1),b(l,2)) = cc.code(k,1) + 1;
                for ij=k-5:k-1
                    if(ij <= 0)
                        continue;
                    end
                    if(abs(cc.code(k,1) - cc.code(ij,1)) > 3 && skeletonImage(b(l,1),b(l,2)) == 1)
                        ellipse(25,25,5,b(l,2),b(l,1),'r');
                        fracture_points = fracture_points + 1;
                    %    disp(b(l,1)); disp(b(l,2)); disp(skeletonImage(b(l,1),b(l,2)));
                        break;
                    end
                end
                num(d,1) = d;
                chaincode_plot(d,1) = cc.code(k,1);
                d = d + 1;
                l = l + 1;
            end
            prev = idx;
        end
    end
end


%ellipse(25,25,5,70,120,'r');
hold off;

figure; title('Chain Code Plot');
hold on;
plot(num,chaincode_plot);
hold off;

if(fracture_points > 0)
    f = msgbox('Possible fracture points are found');
else
    f = msgbox('No fracture points are found');
end

%figure, imshow(chaincode_value),impixelinfo;




function dfs(x,y,r,c)
    global vis skeletonImage idx dfs_nodes prevx prevy;
    move = [-1 -1; -1 0; -1 1; 0 -1; 0 1; 1 -1; 1 0; 1 1];
    tempx = prevx - x;
    tempy = prevy - y;
    if(tempx < 0) 
        tempx = -tempx;
    end
    if(tempy < 0)
        tempy = -tempy;
    end
    if(x < r && x > 0 && y < c && y > 0 && vis(x,y) == 0 && skeletonImage(x,y) == 1 && tempx <= 1 && tempy <= 1)
        vis(x,y) = 1;
        dfs_nodes(idx,1) = x;
        dfs_nodes(idx,2) = y;
        idx = idx + 1;
        prevx = x;
        prevy = y;
        for i=1:8
            x1 = x + move(i,1);
            y1 = y + move(i,2);
            dfs(x1,y1,r,c);
        end
    end
end


