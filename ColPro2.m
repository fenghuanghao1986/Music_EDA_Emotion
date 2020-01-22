

function o = ColPro2(Input, Inverse, ColorMap, Index, MaskLevel)

% Hosein M. Golshan
% Last Update: Mon Jul 11 2016

% Supported Color Maps: cm, bone, cool, copper, hot, rgb, ycbcr
% Example: o = ColPro(Input, 1, 'cm');

f = double(Input);
dz = size(f, 3);

if dz > 1
    o = Input;
    return
end

f1 = f + abs(min(f(:)));
f = 255* (f1 / max(f1(:)));

r = zeros(size(f));
g = zeros(size(f));
b = zeros(size(f));

if Inverse == 0
    
    Coder = load(ColorMap);
    
    if strcmp(ColorMap, 'cm')
        Coder = Coder.cm;
    elseif strcmp(ColorMap, 'cmy')
        Coder = Coder.cmy;
    elseif strcmp(ColorMap, 'bone')
        Coder = Coder.bone;
    elseif strcmp(ColorMap, 'cool')
        Coder = Coder.cool;
    elseif strcmp(ColorMap, 'copper')
        Coder = Coder.copper;
    elseif strcmp(ColorMap, 'hot')
        Coder = Coder.hot;
    elseif strcmp(ColorMap, 'ntsc')
        Coder = Coder.ntsc;
    elseif strcmp(ColorMap, 'rgb')
        Coder = Coder.rgb;
    elseif strcmp(ColorMap, 'ycbcr')
        Coder = Coder.ycbcr;
    end  
    
    k = 1;
    for i = 0 : 255
    
        index = find(f >= i & f <= i + 1);
        r(index) = Coder(k, 1);
        g(index) = Coder(k, 2);
        b(index) = Coder(k, 3);
        k = k + 1;
    
    end
    
else
    
    Coder = load(ColorMap);
    
    if strcmp(ColorMap, 'cm')
        Coder = Coder.cm;
    elseif strcmp(ColorMap, 'cmy')
        Coder = Coder.cmy;
    elseif strcmp(ColorMap, 'bone')
        Coder = Coder.bone;
    elseif strcmp(ColorMap, 'cool')
        Coder = Coder.cool;
    elseif strcmp(ColorMap, 'copper')
        Coder = Coder.copper;
    elseif strcmp(ColorMap, 'hot')
        Coder = Coder.hot;
    elseif strcmp(ColorMap, 'ntsc')
        Coder = Coder.ntsc;
    elseif strcmp(ColorMap, 'rgb')
        Coder = Coder.rgb;
    elseif strcmp(ColorMap, 'ycbcr')
        Coder = Coder.ycbcr;
    end
    
    Coder = Coder(end:-1:1, :);
    
    k = 1;
    for i = 0 : 255
    
        index = find(f >= i & f <= i + 1);
        r(index) = Coder(k, 1);
        g(index) = Coder(k, 2);
        b(index) = Coder(k, 3);
        k = k + 1;
    
    end
    
end

r = r * 255;
g = g * 255;
b = b * 255;
r(Index == 0) = MaskLevel;
g(Index == 0) = MaskLevel;
b(Index == 0) = MaskLevel;

o = cat(3, r, g, b);  







    
    
    
    
    