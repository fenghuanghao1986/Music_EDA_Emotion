
function TransparentView(Input, Alpha)

figure; 
image(Input(:,:,1:3));

for i = 2 : size(Input, 3)/3
    
    hold on
    Temp = image(Input(:,:,3*(i-1)+1:3*i));
    set(Temp, 'AlphaData', Alpha);
    
end





