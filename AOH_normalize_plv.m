function Z=AOH_normalize_plv(plv_data,plv_ref)

if (size(plv_data,1)~=size(plv_ref,1))
	error;
end;
%fprintf(1,'Normalize PLV\n');
%size (plv_ref)

s_ref1=std(plv_ref(:,:)')';
m_ref1=mean(plv_ref(:,:),2);

%size(s_ref1)
%size(m_ref1)

%size(plv_data)
%m_ref1=mean(plv_ref,2);
%s_ref1=std(plv_ref')';
%size(m_ref1)
%size(s_ref1)

%size(m_ref1*ones(1,size(plv_data,2)))
%size(s_ref1*ones(1,size(plv_data,2)))
%size(plv_data)
Z=(plv_data-m_ref1*ones(1,size(plv_data,2)))./(s_ref1*ones(1,size(plv_data,2)));
%size(Z)
%fprintf(1,'=======\n');