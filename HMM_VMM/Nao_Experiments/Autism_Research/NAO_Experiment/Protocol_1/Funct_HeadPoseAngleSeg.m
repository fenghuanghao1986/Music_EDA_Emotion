function [ HeadPos_Model ] = Funct_HeadPoseAngleSeg( Path_poseModels )
%%this function extract the headpose angle (from Intraface) for each video
%%segment (e.g. Kid Talking, NaoTalking) and then put them into a single
%%structure.


    %%Name of models for corresponding frams
    FrameList = ls ([Path_poseModels '\*.jpg']);
    %FrameList = ls ([Path_poseModels '\*.mat']);
    NumFrames = length(FrameList);
     try 
        ind = strfind(Path_poseModels,'NaoExperiment');
        SubjSessInfo = Path_poseModels(ind:end);
        ind = strfind(Path_poseModels,'\');
        GameInfo = Path_poseModels(ind(end)+1 : end);
        itr = 1;
        for (i_frame = 1: NumFrames)
            FrameID = [FrameList(i_frame,1:end-4) '.mat'];%%loa the output of intraface
    %         load(fullfile(Path_poseModels,FrameID))

            OldCD = cd;
            cd(Path_poseModels);
            load(FrameID);
            cd (OldCD);


            if (AngleExist(output) == 1)%%if face has been detected
                headPoseAngle(i_frame,:)=output.pose.angle;
                IntraFaceConfidence(i_frame) = output.conf;
                IntraFace_LndPnt{i_frame} = output.pred;
                IntraFace_PoseInfo{i_frame} = output.pose;
            else%%if face has NOT been detected
                headPoseAngle(i_frame,:)=[0 0 0];
                IntraFaceConfidence(i_frame) = 0;
                IntraFace_LndPnt{i_frame} = 0;
                IntraFace_PoseInfo{i_frame} = 0 ;
            end
        end
    
   
        HeadPos_Model. headPoseAngle =headPoseAngle; 
        HeadPos_Model.SubjSessInfo = SubjSessInfo;
        HeadPos_Model.FrameList =FrameList;
        HeadPos_Model.IntraFace_Confidence =IntraFaceConfidence;
        HeadPos_Model.IntraFace_LndPnt =IntraFace_LndPnt;
        HeadPos_Model.IntraFace_PoseInfo =IntraFace_PoseInfo;
        HeadPos_Model.GameInfo = GameInfo;
        HeadPos_Model.Info ='HeadPos_Model =[0,0,0] means the face has not been detected similarly the model, angle,pose,etc';
    
    catch exception
            disp('No Frame found')
            HeadPos_Model= [];
            HeadPos_Model.GameInfo = GameInfo;
    end


       %%stroe the structure HeadPos_Model, for games kids talking, nao talkin
    %%in the same folder their data is.
    save  (fullfile(Path_poseModels,['Head_Pose_Orientation_' GameInfo]), 'HeadPos_Model')
end


function flag = AngleExist(output);
    flag = 0;
    if exist('output') 
        %disp('output is in the MATLAB workspace')
        if isstruct(output)
            %disp('output is a structure')
            if isfield(output,'pose')
                %disp('pose is a field of the structure output')
                if isfield(output.pose,'angle')
                    flag = 1;
                end
            end
        end
    end
end
