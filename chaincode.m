function [cc] = chaincode(b,unwrap)

    if nargin>2 
        error('Too many arguments');
    elseif nargin==0
        error('Too few arguments');
    elseif nargin==1
        unwrap=false;
    end    
    sb=circshift(b,[-1 0]);
    delta=sb-b;
    if abs(delta(end,1)) > 1 || abs(delta(end,2)) > 1
        delta=delta(1:(end-1),:);
    end

    n8c=find(abs(delta(:,1)) > 1 | abs(delta(:,2)) > 1);
    if size(n8c,1)>0 
        s='';
        for i=1:size(n8c,1)
            s =[s sprintf(' idx -> %d \n',n8c(i))];
        end
        error('Curve isn''t 8-connected in elements: \n%s',s);
    end
    idx=3*delta(:,1)+delta(:,2)+5;
    cm([1 2 3 4 6 7 8 9])=[5 6 7 4 0 3 2 1];
    cc.x0=b(1,2);
    cc.y0=b(1,1);
    cc.code=(cm(idx))';
    if (unwrap) 
        a=cc.code;
        u(1)=a(1);
        la=size(a,1);
        for i=2:la
            n=round((u(i-1)-a(i))/8);
            u(i)=a(i)+n*8;
        end
        cc.ucode=u';
    end    
end