clear all
close all
clc

%%define the path for loading the excel file that contains the behavioral
%%codes for all subjects (Nao Expreirment, 2nd Protocol, 5 Tasks)
LastDateCoded= '_Jan25_2014';
File_Path = 'C:\Users\MahoorLab04\MMavadati_Files\Autism_Reserach\NaoExperiment\Protocol_2\';
% ExcelFileName= 'NaoExp_2ndProtocol_BehavioralCoding.xlsx'
ExcelFileName= ['NaoExp_2ndProtocol_BehavioralCoding' LastDateCoded  '.xlsx'];



%T1:    Answering 5Questions , (about 10 Questions) 
%T2.1:  Following Pointing, (Nao Pointing -> 2vs3 Boxes)
%T2.2: Recognizing Facial Expression (Nao Pointing -> 2vs3 Boxes)
%T3: Following EyeGaze ofNao, (Joint Attention toward a Box)
%T4: Show Facial Expression-FE, (Imitate Expressions, Similar to T2.1,T2.2) 
%T4.1: recognize facail expression correctly
%T4.2: imitate facial expression correctly
%T5: Kid Point Should point at a Box (NaoDescribe a Box, Kid Pointing to that)

Subjs_ID = {'SN019','SN020','SN021','SN022','SN023','SN024' , 'SN025'};
NumSubjs = length (Subjs_ID)
Tasks_ID = {'T1','T2.1' ,'T2.2', 'T3', 'T4.1' ,'T4.2', 'T5'};
DateGame = 'Date Game:'
NumTasks = length (Tasks_ID)

for i_sub = 1:NumSubjs
    SelectedSubj = Subjs_ID{i_sub};
    [num,txt,Behavior_Data] = xlsread(fullfile(File_Path,ExcelFileName),SelectedSubj);
    
    Task_Accuracy =[];
    for i_task = 1:NumTasks
        SelectedTask = Tasks_ID{i_task};
        Ind_rows =  find( strcmp(Behavior_Data(:,1), SelectedTask) );%%Find the rows for the selected Tast 
        NumSessions = length(Ind_rows);
        
        if (i_task ==1)%%extract the data of the experiment from the excel sheet
            Dates =[];
            IndRowDate = Ind_rows -3;%dates come three rows above the T1 column
            Dates = cell2mat(Behavior_Data(IndRowDate,1));
            Dates =Dates(:,12:end);
           %%check baseline vs Inervention by checking 5th column in the same row as IndRowDate 
            Base_Vs_Intervention = Behavior_Data(IndRowDate,5);%% cell correspond to 'Intervention Game_Sess ID: Ixx_yy'
            GameType =[];
            base_itr = 1;
            for i_sess=1:NumSessions
                ID_interv = Base_Vs_Intervention{i_sess}
                if (isnan(ID_interv))
                    GameType =[GameType ; ['BaseLine' num2str(base_itr)]];
                    base_itr=base_itr+1;
                else 
                    GameType = [GameType ; ID_interv(end-8:end)];
                end
            end
        end
        
        %extract the accuracy percentate for all sessions.
        Ind_Col_Percentage = 7; %column correpsond to the percentage value

        Accuracy = Behavior_Data(Ind_rows,Ind_Col_Percentage);

        Ind_NotValue = find(strcmp(Accuracy, '#VALUE!'));%specify the indices that are either not coded or correspond to the templates (last row)
        for i=1:length(Ind_NotValue)
            Accuracy{Ind_NotValue(i)} = -1;%those values which are '#VALUE!' are represented by -1
        end
        Task_Accuracy(:,i_task) = cell2mat(Accuracy);%each task has been represented by one column 
    end
    Subj_Task_Accuracy{i_sub}.AccuracyBehaviors = Task_Accuracy; %All the sessions, Tasks for each subject will be recorded
    Subj_Task_Accuracy{i_sub}.Subj = SelectedSubj;
    Subj_Task_Accuracy{i_sub}.TasksID = Tasks_ID';
    Subj_Task_Accuracy{i_sub}.Date = Dates;
    Subj_Task_Accuracy{i_sub}.GameType = GameType;
    Subj_Task_Accuracy{i_sub}.ReadMe = {['Number of Tasks(Games): ' num2str(length(Tasks_ID))];...
                                         ['Dimension of AccuracyBehavior(Number of Experiments x NumTasks)'];
                                         ['First 3 Experiments are baseline(Check Dates) and ther others are Interventions, (Date Nov,xx,2013 is template, Disregard it)']};
                                     
                                     
    %% Ploting the results for each subject separeatly
    figure()
end
%%Subj_Task_Accuracy: in each cell keep the values for each subject, 
save (fullfile(File_Path, ['Prot2_Behavioral_Results_AllSubjs' LastDateCoded]), 'Subj_Task_Accuracy' )


