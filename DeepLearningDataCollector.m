
% New Update: Dec. 05, 2015
% Sample Extraction

% *********************************************
% ==================== Start. Load Data =====================

for tt=1:4
    
    clc
    close all;
    warning off

    InpPool={'O14AK_20141210.mat','O14AK_20141210_response.mat';
    'O14AJ_20141103.mat','O14AJ_20141103_response.mat';
    'A15K_20150511.mat','A15K_20150511_response.mat'
    'J15M_20150608.mat','J15M_20150608_response.mat';
    'A15L_20150427.mat','A15L_20150427_response.mat'};

    NamPool={'O14AK';'O14AJ';'A15K';'J15M';'A15L'};
    chPool=[1;2;3];
    sidePool={'Left';'Right'};
    targetPool={'Button','Audio','Video','Reach','Random'};

    name1=InpPool{tt,1}
    name2=InpPool{tt,2}
    name=NamPool{tt}
    
   for tt3=1:5
    
      target=targetPool{tt3}
      
      for tt2=1:2
        
         side=sidePool{tt2}
        
         for tt1=1:3
             
             load(name1);
             load(name2);
             TempSignal=signal(:,1:8);   
             clear audio digital intracranial intracranial_channel_names ...
               original_parameters signal signal_channel_names states 
             signal=TempSignal;
             clear TempSignal
             
             ch=chPool(tt1)

             if strcmp(side,'Right')
                if ch==1
                   BipolarSignal=signal(:,2)-signal(:,1);
                elseif ch==2
                   BipolarSignal=signal(:,3)-signal(:,2);
                else
                   BipolarSignal=signal(:,4)-signal(:,3);
                end
    
             else
                if ch==1
                   BipolarSignal=signal(:,6)-signal(:,5);
                elseif ch==2
                   BipolarSignal=signal(:,7)-signal(:,6);
                else
                   BipolarSignal=signal(:,8)-signal(:,7);
                end
   
             end

            clear signal

            if strcmp(target,'Button')
   
               flag=1;
               LL=length(PCS_button_press);
               onset=zeros(1,LL);
               offset=zeros(1,LL);

               for i=1:LL
    
                  if PCS_button_press(i).valid==1 
%                 if strcmp(PCS_button_press(i).code,side)==1
        
                     onset(i)=PCS_button_press(i).response.index;
                     offset(i)=PCS_button_press(i).response.duration;
              
%                 end
                  end
    
               end
     
            elseif strcmp(target,'Audio')
   
                flag=1;
                LL=length(AudioEvents);
                onset=zeros(1,LL);
                offset=zeros(1,LL);

                for i=1:LL
    
                    if AudioEvents(i).valid==1 
        
                       onset(i)=AudioEvents(i).response.index;
                       offset(i)=AudioEvents(i).response.duration;
        
                    end
        
                end

           elseif strcmp(target,'Video')
   
                flag=1;
                LL=length(VideoEvents);
                onset=zeros(1,LL);
                offset=zeros(1,LL);

                for i=1:LL
    
                   if VideoEvents(i).valid==1 
        
                      onset(i)=VideoEvents(i).response.index;
                      offset(i)=VideoEvents(i).response.duration;
        
                   end
        
                end
    
           elseif strcmp(target,'Reach')
    
                flag=1;
                LL=length(PCS_reach);
                onset=zeros(1,LL);
                offset=zeros(1,LL);

                for i=1:LL
    
                   if PCS_reach(i).valid==1 
%                  if strcmp(PCS_reach(i).side,side)==1
        
                  onset(i)=PCS_reach(i).response.index;
                  offset(i)=PCS_reach(i).response.duration;
        
%                  end
                   end
    
                end
    
            else
                
                flag=0;
                StartPoint=round(-2*Fs);
                EndPoint=round(3*Fs);  
                Epoch=EndPoint-StartPoint;
                InitialValue=round(7*Fs/3); 
                LoopNumber=round((length(BipolarSignal)-Epoch)/Epoch);
                LoopNumber=min(LoopNumber,50);

            end

            if flag==1
   
               offset=offset+onset;

               index=find(onset>0);
               onset=onset(index).*Fs; 
               offset=offset(index).*Fs;

               StartPoint=round(-2*Fs);
               EndPoint=round(3*Fs);       
%                Epoch=int32([StartPoint:EndPoint]);
               LoopNumber=numel(onset);

            end
            
            flag
            
            DownSamp=1;
            DesiredFrequency=linspace(8,30,256);
            fw=DesiredFrequency/2;
            scales=Fs./fw;
            TF=cell(1,LoopNumber);
            TF1=cell(1,LoopNumber);
            TF2=cell(1,LoopNumber);
            TF3=cell(1,LoopNumber);
            DownRawSignal=cell(1,LoopNumber);
    
            for count=1:LoopNumber
    
                disp(['Iteration ', num2str(count), ' out of ', num2str(LoopNumber)])
    
                if strcmp(target,'Random')
                   ST1=InitialValue+(count-1)*Epoch;
                   EN1=InitialValue+count*Epoch;
                else
                   ST1=onset(count)+StartPoint;
                   EN1=onset(count)+EndPoint;
                end
       
                TempSignal=BipolarSignal(ST1:EN1);
                TempR=TempSignal';
                DownRawSignal(count)={downsample(TempR,DownSamp)};
        
                DesiredFrequency=scal2frq(scales,'cmor1.5-2',1/Fs);
                TempMap1=cwt(TempSignal,scales,'cmor1.5-2');
                TempMap=abs(TempMap1);
                DownS=(downsample(TempMap',DownSamp))';
    
                TF(count)={DownS}; 
                TF1(count)={DownS(:,Fs:3*Fs)};
                TF2(count)={DownS(:,0.75*Fs:2.75*Fs)};
                TF3(count)={DownS(:,1.25*Fs:3.25*Fs)};
    
            end

            Input=TF; 
            Input1=TF1;
            Input2=TF2;
            Input3=TF3;

            clear BipolarSignal TF TF1 TF2 TF3 TempSignal TempR DownRawSignal TempMap1 TempMap DownS

            if strcmp(side,'Left')
               SID='L';
            else 
               SID='R';
            end

            Row=numel(DesiredFrequency);
            NewInput=zeros(size(Input{1}));
            NewInput1=zeros(size(Input1{1}));
            NewInput2=zeros(size(Input2{1}));
            NewInput3=zeros(size(Input3{1}));

            AddressRaw=[name, '\Raw', '\Expanded\', target, '\', 'CH', num2str(ch), SID, '\', '999', '.png               ', '0']; 
            AddressRaw1=[name, '\Raw', '\Original\', target, '\',  'CH', num2str(ch), SID, '\', '999', '.png               ', '0']; 
            AddressRaw2=[name, '\Raw', '\ShiftLef\', target, '\', 'CH', num2str(ch), SID, '\', '999', '.png               ', '0']; 
            AddressRaw3=[name, '\Raw', '\ShiftRig\', target, '\', 'CH', num2str(ch), SID, '\', '999', '.png               ', '0']; 

            AddressFiltered=[name, '\Filtered', '\Expanded\', target, '\', 'CH', num2str(ch), SID, '\', '999', '.png               ', '0']; 
            AddressFiltered1=[name, '\Filtered', '\Original\', target, '\', 'CH', num2str(ch), SID, '\', '999', '.png               ', '0']; 
            AddressFiltered2=[name, '\Filtered', '\ShiftLef\', target, '\', 'CH', num2str(ch), SID, '\', '999', '.png               ', '0']; 
            AddressFiltered3=[name, '\Filtered', '\ShiftRig\', target, '\', 'CH', num2str(ch), SID, '\', '999', '.png               ', '0']; 

            [num,den]=butter(10,0.2);

            for z=1:numel(Input)
    
                TempInput=Input{z};
                TempInput1=Input1{z};
                TempInput2=Input2{z};
                TempInput3=Input3{z};
                DownFiltered=zeros(size(Input{1}));
                DownFiltered1=zeros(size(Input1{1}));
                DownFiltered2=zeros(size(Input2{1}));
                DownFiltered3=zeros(size(Input3{1}));
    
                for i=1:Row
    
                   NewInput(i,:)=TempInput(i,:);
                   DownFiltered(i,:)=filter(num,den,NewInput(i,:));
        
                   NewInput1(i,:)=TempInput1(i,:);
                   DownFiltered1(i,:)=filter(num,den,NewInput1(i,:));
        
                   NewInput2(i,:)=TempInput2(i,:);
                   DownFiltered2(i,:)=filter(num,den,NewInput2(i,:));
        
                   NewInput3(i,:)=TempInput3(i,:);
                   DownFiltered3(i,:)=filter(num,den,NewInput3(i,:));
                       
                end    

                TempInput=imresize(TempInput,[256,256],'cubic');
                TempInput1=imresize(TempInput1,[256,256],'cubic');
                TempInput2=imresize(TempInput2,[256,256],'cubic');
                TempInput3=imresize(TempInput3,[256,256],'cubic');
    
                if min(TempInput(:))<0
                   TempInput=TempInput+abs(min(TempInput(:)));
                   TempInput=TempInput*255/max(TempInput(:));
                else
                   TempInput=TempInput*255/max(TempInput(:));
                end
    
                if min(TempInput1(:))<0
                   TempInput1=TempInput1+abs(min(TempInput1(:)));
                   TempInput1=TempInput1*255/max(TempInput1(:));
                else
                   TempInput1=TempInput1*255/max(TempInput1(:));
                end
    
                if min(TempInput2(:))<0
                   TempInput2=TempInput2+abs(min(TempInput2(:)));
                   TempInput2=TempInput2*255/max(TempInput2(:));
                else
                   TempInput2=TempInput2*255/max(TempInput2(:));
                end
    
                if min(TempInput3(:))<0
                   TempInput3=TempInput3+abs(min(TempInput3(:)));
                   TempInput3=TempInput3*255/max(TempInput3(:));
                else
                   TempInput3=TempInput3*255/max(TempInput3(:));
                end
    
                DownFiltered=imresize(DownFiltered,[256,256],'cubic');
                DownFiltered1=imresize(DownFiltered1,[256,256],'cubic');
                DownFiltered2=imresize(DownFiltered2,[256,256],'cubic');
                DownFiltered3=imresize(DownFiltered3,[256,256],'cubic');
    
                if min(DownFiltered(:))<0
                   DownFiltered=DownFiltered+abs(min(DownFiltered(:)));
                   DownFiltered=DownFiltered*255/max(DownFiltered(:));
                else
                   DownFiltered=DownFiltered*255/max(DownFiltered(:));
                end
    
                if min(DownFiltered1(:))<0
                   DownFiltered1=DownFiltered1+abs(min(DownFiltered1(:)));
                   DownFiltered1=DownFiltered1*255/max(DownFiltered1(:));
                else
                   DownFiltered1=DownFiltered1*255/max(DownFiltered1(:));
                end
    
                if min(DownFiltered2(:))<0
                   DownFiltered2=DownFiltered2+abs(min(DownFiltered2(:)));
                   DownFiltered2=DownFiltered2*255/max(DownFiltered2(:));
                else
                   DownFiltered2=DownFiltered2*255/max(DownFiltered2(:));
                end
    
                if min(DownFiltered3(:))<0
                   DownFiltered3=DownFiltered3+abs(min(DownFiltered3(:)));
                   DownFiltered3=DownFiltered3*255/max(DownFiltered3(:));
                else
                   DownFiltered3=DownFiltered3*255/max(DownFiltered3(:));
                end
    
                if z<10
                   z1=['00',num2str(z)];
                elseif z>=10 && z<100
                   z1=['0',num2str(z)];
                else
                   z1=num2str(z);
                end
    
                TempInput=uint8(TempInput);TempInput1=uint8(TempInput1);TempInput2=uint8(TempInput2);TempInput3=uint8(TempInput3);
    
                imwrite(TempInput,['C:\Users\Lab User\Desktop\Hosein\DBS\DataSet\DeepLearningSamples\', name, '\Raw\', 'Expanded\', target,...
                '\CH', num2str(ch), SID,'\', name, '-Raw', '-Expanded-', target, '-', 'CH', num2str(ch), SID, '-', z1, '.png'])
                imwrite(TempInput1,['C:\Users\Lab User\Desktop\Hosein\DBS\DataSet\DeepLearningSamples\', name, '\Raw\', 'Original\', target,...
                '\CH', num2str(ch), SID,'\', name, '-Raw', '-Original-', target, '-', 'CH', num2str(ch), SID, '-', z1, '.png'])
                imwrite(TempInput2,['C:\Users\Lab User\Desktop\Hosein\DBS\DataSet\DeepLearningSamples\', name, '\Raw\', 'ShiftLef\', target,...
                '\CH', num2str(ch), SID,'\', name, '-Raw', '-ShiftLef-', target, '-', 'CH', num2str(ch), SID, '-', z1, '.png'])
                imwrite(TempInput3,['C:\Users\Lab User\Desktop\Hosein\DBS\DataSet\DeepLearningSamples\', name, '\Raw\', 'ShiftRig\', target,...
                '\CH', num2str(ch), SID,'\', name, '-Raw', '-ShiftRig-', target, '-', 'CH', num2str(ch), SID, '-', z1, '.png'])

                DownFiltered=uint8(DownFiltered);DownFiltered1=uint8(DownFiltered1);DownFiltered2=uint8(DownFiltered2);DownFiltered3=uint8(DownFiltered3);

                imwrite(DownFiltered,['C:\Users\Lab User\Desktop\Hosein\DBS\DataSet\DeepLearningSamples\', name, '\Filtered\', 'Expanded\', target,...
                '\CH', num2str(ch), SID,'\', name, '-Filtered', '-Expanded-', target, '-', 'CH', num2str(ch), SID, '-', z1, '.png'])
                imwrite(DownFiltered1,['C:\Users\Lab User\Desktop\Hosein\DBS\DataSet\DeepLearningSamples\', name, '\Filtered\', 'Original\', target,...
                '\CH', num2str(ch), SID,'\', name, '-Filtered', '-Original-', target, '-', 'CH', num2str(ch), SID, '-', z1, '.png'])
                imwrite(DownFiltered2,['C:\Users\Lab User\Desktop\Hosein\DBS\DataSet\DeepLearningSamples\', name, '\Filtered\', 'ShiftLef\', target,...
                '\CH', num2str(ch), SID,'\', name, '-Filtered', '-ShiftLef-', target, '-', 'CH', num2str(ch), SID, '-', z1, '.png'])
                imwrite(DownFiltered3,['C:\Users\Lab User\Desktop\Hosein\DBS\DataSet\DeepLearningSamples\', name, '\Filtered\', 'ShiftRig\', target,...
                '\CH', num2str(ch), SID,'\', name, '-Filtered', '-ShiftRig-', target, '-', 'CH', num2str(ch), SID, '-', z1, '.png'])
    
    
                if strcmp(target,'Button')
                   AddressRaw(z,:)=[name, '\Raw', '\Expanded\', target, '\', 'CH', num2str(ch), SID, '\', z1, '.png               ', '0']; 
                   AddressFiltered(z,:)=[name, '\Filtered', '\Expanded\', target, '\', 'CH', num2str(ch), SID, '\', z1, '.png               ', '0'];
                   AddressRaw1(z,:)=[name, '\Raw', '\Original\', target, '\', 'CH', num2str(ch), SID, '\', z1, '.png               ', '0']; 
                   AddressFiltered1(z,:)=[name, '\Filtered', '\Original\', target, '\', 'CH', num2str(ch), SID, '\', z1, '.png               ', '0'];
                   AddressRaw2(z,:)=[name, '\Raw', '\ShiftLef\', target, '\', 'CH', num2str(ch), SID, '\', z1, '.png               ', '0']; 
                   AddressFiltered2(z,:)=[name, '\Filtered', '\ShiftLef\', target, '\', 'CH', num2str(ch), SID, '\', z1, '.png               ', '0'];
                   AddressRaw3(z,:)=[name, '\Raw', '\ShiftRig\', target, '\', 'CH', num2str(ch), SID, '\', z1, '.png               ', '0']; 
                   AddressFiltered3(z,:)=[name, '\Filtered', '\ShiftRig\', target, '\', 'CH', num2str(ch), SID, '\', z1, '.png               ', '0'];
       
               elseif strcmp(target,'Audio')
                   AddressRaw(z,:)=[name, '\Raw', '\Expanded\', target, '\', 'CH', num2str(ch), SID, '\', z1, '.png               ', '1']; 
                   AddressFiltered(z,:)=[name, '\Filtered', '\Expanded\', target, '\', 'CH', num2str(ch), SID, '\', z1, '.png               ', '1'];
                   AddressRaw1(z,:)=[name, '\Raw', '\Original\', target, '\', 'CH', num2str(ch), SID, '\', z1, '.png               ', '1']; 
                   AddressFiltered1(z,:)=[name, '\Filtered', '\Original\', target, '\', 'CH', num2str(ch), SID, '\', z1, '.png               ', '1'];
                   AddressRaw2(z,:)=[name, '\Raw', '\ShiftLef\', target, '\', 'CH', num2str(ch), SID, '\', z1, '.png               ', '1']; 
                   AddressFiltered2(z,:)=[name, '\Filtered', '\ShiftLef\', target, '\', 'CH', num2str(ch), SID, '\', z1, '.png               ', '1'];
                   AddressRaw3(z,:)=[name, '\Raw', '\ShiftRig\', target, '\', 'CH', num2str(ch), SID, '\', z1, '.png               ', '1']; 
                   AddressFiltered3(z,:)=[name, '\Filtered', '\ShiftRig\', target, '\', 'CH', num2str(ch), SID, '\', z1, '.png               ', '1'];
       
               elseif strcmp(target,'Reach')
                   AddressRaw(z,:)=[name, '\Raw', '\Expanded\', target, '\', 'CH', num2str(ch), SID, '\', z1, '.png               ', '2']; 
                   AddressFiltered(z,:)=[name, '\Filtered', '\Expanded\', target, '\', 'CH', num2str(ch), SID, '\', z1, '.png               ', '2'];
                   AddressRaw1(z,:)=[name, '\Raw', '\Original\', target, '\', 'CH', num2str(ch), SID, '\', z1, '.png               ', '2']; 
                   AddressFiltered1(z,:)=[name, '\Filtered', '\Original\', target, '\', 'CH', num2str(ch), SID, '\', z1, '.png               ', '2'];
                   AddressRaw2(z,:)=[name, '\Raw', '\ShiftLef\', target, '\', 'CH', num2str(ch), SID, '\', z1, '.png               ', '2']; 
                   AddressFiltered2(z,:)=[name, '\Filtered', '\ShiftLef\', target, '\', 'CH', num2str(ch), SID, '\', z1, '.png               ', '2'];
                   AddressRaw3(z,:)=[name, '\Raw', '\ShiftRig\', target, '\', 'CH', num2str(ch), SID, '\', z1, '.png               ', '2']; 
                   AddressFiltered3(z,:)=[name, '\Filtered', '\ShiftRig\', target, '\', 'CH', num2str(ch), SID, '\', z1, '.png               ', '2'];
       
               elseif strcmp(target,'Video')
                   AddressRaw(z,:)=[name, '\Raw', '\Expanded\', target, '\', 'CH', num2str(ch), SID, '\', z1, '.png               ', '3']; 
                   AddressFiltered(z,:)=[name, '\Filtered', '\Expanded\', target, '\', 'CH', num2str(ch), SID, '\', z1, '.png               ', '3'];
                   AddressRaw1(z,:)=[name, '\Raw', '\Original\', target, '\', 'CH', num2str(ch), SID, '\', z1, '.png               ', '3']; 
                   AddressFiltered1(z,:)=[name, '\Filtered', '\Original\', target, '\', 'CH', num2str(ch), SID, '\', z1, '.png               ', '3'];
                   AddressRaw2(z,:)=[name, '\Raw', '\ShiftLef\', target, '\', 'CH', num2str(ch), SID, '\', z1, '.png               ', '3']; 
                   AddressFiltered2(z,:)=[name, '\Filtered', '\ShiftLef\', target, '\', 'CH', num2str(ch), SID, '\', z1, '.png               ', '3'];
                   AddressRaw3(z,:)=[name, '\Raw', '\ShiftRig\', target, '\', 'CH', num2str(ch), SID, '\', z1, '.png               ', '3']; 
                   AddressFiltered3(z,:)=[name, '\Filtered', '\ShiftRig\', target, '\', 'CH', num2str(ch), SID, '\', z1, '.png               ', '3'];
       
                else
                   AddressRaw(z,:)=[name, '\Raw', '\Expanded\', target, '\', 'CH', num2str(ch), SID, '\', z1, '.png               ', '4']; 
                   AddressFiltered(z,:)=[name, '\Filtered', '\Expanded\', target, '\', 'CH', num2str(ch), SID, '\', z1, '.png               ', '4'];
                   AddressRaw1(z,:)=[name, '\Raw', '\Original\', target, '\', 'CH', num2str(ch), SID, '\', z1, '.png               ', '4']; 
                   AddressFiltered1(z,:)=[name, '\Filtered', '\Original\', target, '\', 'CH', num2str(ch), SID, '\', z1, '.png               ', '4'];
                   AddressRaw2(z,:)=[name, '\Raw', '\ShiftLef\', target, '\', 'CH', num2str(ch), SID, '\', z1, '.png               ', '4']; 
                   AddressFiltered2(z,:)=[name, '\Filtered', '\ShiftLef\', target, '\', 'CH', num2str(ch), SID, '\', z1, '.png               ', '4'];
                   AddressRaw3(z,:)=[name, '\Raw', '\ShiftRig\', target, '\', 'CH', num2str(ch), SID, '\', z1, '.png               ', '4']; 
                   AddressFiltered3(z,:)=[name, '\Filtered', '\ShiftRig\', target, '\', 'CH', num2str(ch), SID, '\', z1, '.png               ', '4'];
       
                end
    
            end
    
            fName = ['C:\Users\Lab User\Desktop\Hosein\DBS\DataSet\DeepLearningSamples\', name, '\Raw\', 'Expanded\', target,'\CH', num2str(ch), SID, '\Labels.txt'];        
            fid = fopen(fName,'w'); 
            for i=1:size(AddressRaw,1)  
               fprintf(fid,'%s \n',AddressRaw(i,:));  
            end
            fclose(fid);   
            fName = ['C:\Users\Lab User\Desktop\Hosein\DBS\DataSet\DeepLearningSamples\', name, '\Filtered\', 'Expanded\', target,'\CH', num2str(ch), SID, '\Labels.txt'];        
            fid = fopen(fName,'w'); 
            for i=1:size(AddressFiltered,1) 
               fprintf(fid,'%s \n',AddressFiltered(i,:));  
            end
            fclose(fid);   
    
            fName = ['C:\Users\Lab User\Desktop\Hosein\DBS\DataSet\DeepLearningSamples\', name, '\Raw\', 'Original\', target,'\CH', num2str(ch), SID, '\Labels.txt'];        
            fid = fopen(fName,'w');    
            for i=1:size(AddressRaw1,1)      
               fprintf(fid,'%s \n',AddressRaw1(i,:));  
            end
            fclose(fid);      
            fName = ['C:\Users\Lab User\Desktop\Hosein\DBS\DataSet\DeepLearningSamples\', name, '\Filtered\', 'Original\', target,'\CH', num2str(ch), SID, '\Labels.txt'];        
            fid = fopen(fName,'w');  
            for i=1:size(AddressFiltered1,1)      
                fprintf(fid,'%s \n',AddressFiltered1(i,:));  
            end
            fclose(fid);   

            fName = ['C:\Users\Lab User\Desktop\Hosein\DBS\DataSet\DeepLearningSamples\', name, '\Raw\', 'ShiftLef\', target,'\CH', num2str(ch), SID, '\Labels.txt'];        
            fid = fopen(fName,'w'); 
            for i=1:size(AddressRaw2,1)    
                fprintf(fid,'%s \n',AddressRaw2(i,:));  
            end
            fclose(fid);    
            fName = ['C:\Users\Lab User\Desktop\Hosein\DBS\DataSet\DeepLearningSamples\', name, '\Filtered\', 'ShiftLef\', target,'\CH', num2str(ch), SID, '\Labels.txt'];        
            fid = fopen(fName,'w'); 
            for i=1:size(AddressFiltered2,1)
               fprintf(fid,'%s \n',AddressFiltered2(i,:));  
            end
            fclose(fid); 
    
            fName = ['C:\Users\Lab User\Desktop\Hosein\DBS\DataSet\DeepLearningSamples\', name, '\Raw\', 'ShiftRig\', target,'\CH', num2str(ch), SID, '\Labels.txt'];        
            fid = fopen(fName,'w');    
            for i=1:size(AddressRaw3,1)
                fprintf(fid,'%s \n',AddressRaw3(i,:));  
            end
            fclose(fid);   
            fName = ['C:\Users\Lab User\Desktop\Hosein\DBS\DataSet\DeepLearningSamples\', name, '\Filtered\', 'ShiftRig\', target,'\CH', num2str(ch), SID, '\Labels.txt'];        
            fid = fopen(fName,'w'); 
            for i=1:size(AddressFiltered3,1)  
                fprintf(fid,'%s \n',AddressFiltered3(i,:));  
            end
            fclose(fid); 
            clear TempInput TempInput1 TempInput2 TempInput3 DownFiltered DownFiltered1 DownFiltered2 DownFiltered3 ...
                Input Input1 Input2 Input3 NewInput NewInput1 NewInput2 NewInput3 flag
         end
      end
   end
   
end









