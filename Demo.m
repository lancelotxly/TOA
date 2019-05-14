clear all;clc;close all;
ax=-25;
ay=-200;
l=50;
w=400;
x=[ax,ax+l,ax+l,ax,ax];
y=[ay,ay,ay+w,ay+w,ay];
plot(x,y);hold on;
axis equal;
ax=-200;
ay=250;
x=[ax,ax+w,ax+w,ax,ax];
y=[ay,ay,ay+l,ay+l,ay];
plot(x,y);hold on;
ax=-200;
ay=-300;
x=[ax,ax+w,ax+w,ax,ax];
y=[ay,ay,ay+l,ay+l,ay];
plot(x,y);hold on;
User=[200,10];
pUser=plot(User(:,1),User(:,2),'d'); hold on;
temp=textread('data.txt');
pBaseStations=plot(temp(:,1),temp(:,2),'go');hold on;
axis([-1000,1000,-800,800]);
grid on;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
BS=temp(:,[1:3]);
TOA=temp(:,4);
N_BS=length(BS);
r_BS_to_User_est=3e8*TOA;
N_select_BS=5;
Combination_of_BS=nchoosek(1:N_BS,N_select_BS);
LMS_least=inf;
Nub=0;
for m=1:nchoosek(N_BS,N_select_BS)
    Selected_BS_index=Combination_of_BS(m,:);
    A_matrix=[];
    R_vector=[];
    for n=1:N_select_BS-1
        A_matrix=[A_matrix;-BS(Selected_BS_index(n),1)+BS(Selected_BS_index(n+1),1),...
                           -BS(Selected_BS_index(n),2)+BS(Selected_BS_index(n+1),2),...
                           ...
                           (r_BS_to_User_est(Selected_BS_index(n),:)^2-r_BS_to_User_est(Selected_BS_index(n+1),:)^2)/2];
        R_vector=[R_vector;-(BS(Selected_BS_index(n),1)^2-BS(Selected_BS_index(n+1),1)^2+...
                             BS(Selected_BS_index(n),2)^2-BS(Selected_BS_index(n+1),2)^2)/2];
                       
    end
    A=(A_matrix'*A_matrix+Nub^2*eye(3))^-1;
    Coordinates_User_estimated=A*A_matrix'*R_vector;
    LMS_temp=norm(R_vector-A_matrix*Coordinates_User_estimated);
    if LMS_temp<LMS_least
        LMS_least=LMS_temp;
        Coordinates_User_estimated_optimal=Coordinates_User_estimated;
        BS_optimal=Selected_BS_index;
    end
end
for i=1:N_select_BS-1
    pLOS=plot(BS(BS_optimal(i),1),BS(BS_optimal(i),2),'*');
end
pEstimate=plot(Coordinates_User_estimated(1,:),Coordinates_User_estimated(2,:),'r+');
legend([pUser,pBaseStations,pLOS,pEstimate],'Exact User Position','Base Stations','Base Stations of LOS','Estimate User Location');