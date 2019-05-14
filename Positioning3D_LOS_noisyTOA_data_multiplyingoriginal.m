clear all;clc;close all;
temp=textread('sample_case005_input.txt');
BS=temp([4:23],[1:3]);
TOA=temp([24:1023],[1:20]);
Coordinates_BS=BS; 
Coordinates_BS(:,3)=Coordinates_BS(:,3);
N_BS=length(Coordinates_BS);%基站数目
Nub=15;
temp=textread('sample_case005_ans.txt');
temp_a=temp([1:100],[1:3]);
temp_a(:,3)=temp_a(:,3);
%plot3(Coordinates_BS(:,1),Coordinates_BS(:,2),Coordinates_BS(:,3),'o');hold on%作图显示基站位置
for k=1:100
    k
r_BS_to_User_est=3*10^8*TOA(k,:);
r_BS_to_User_est1=r_BS_to_User_est(find(r_BS_to_User_est<5000));%选择距离近的基站
N_BS_near=length(r_BS_to_User_est);
N_selected_BS=5;%选择的基站数量
Combinations_of_BS=nchoosek(1:N_BS_near,N_selected_BS);%从所有基站中选择出N_selected_BS个基站的可能组合
LMS_difference_least=inf;%用于存储最小误差的标量
for m=1:nchoosek(N_BS_near,N_selected_BS)%循环所有的组合
    Selected_BS_index=Combinations_of_BS(m,:);%此次循环对应的基站下标
A_matrix=[];
R_vector=[];

for n=1:N_selected_BS-1
    A_matrix=[A_matrix;-Coordinates_BS(Selected_BS_index(n),1)+Coordinates_BS(Selected_BS_index(n+1),1),-Coordinates_BS(Selected_BS_index(n),2)+Coordinates_BS(Selected_BS_index(n+1),2),-Coordinates_BS(Selected_BS_index(n),3)+Coordinates_BS(Selected_BS_index(n+1),3),(r_BS_to_User_est(Selected_BS_index(n))^2-r_BS_to_User_est(Selected_BS_index(n+1))^2)/2];%线性方程参数矩阵
    R_vector=[R_vector;-(Coordinates_BS(Selected_BS_index(n),1)^2-Coordinates_BS(Selected_BS_index(n+1),1)^2+Coordinates_BS(Selected_BS_index(n),2)^2-Coordinates_BS(Selected_BS_index(n+1),2)^2+Coordinates_BS(Selected_BS_index(n),3)^2-Coordinates_BS(Selected_BS_index(n+1),3)^2)/2];%线性方程伴随矩阵
end
A=(A_matrix'*A_matrix+Nub^2*eye(4))^-1;
Coordinates_User_estimated=A*A_matrix'*R_vector;%最小二乘

LMS_difference_temp=norm(R_vector-A_matrix*Coordinates_User_estimated);%计算误差

if LMS_difference_temp<LMS_difference_least%如果误差小于以往所有的误差
    LMS_difference_least=LMS_difference_temp;%更新最小误差
    Coordinates_User_estimated_optimal=Coordinates_User_estimated;%更新最优估计位置
    BS_optimal=Selected_BS_index;%保存最优基站（LOS）下标
end

end
Coordinates_User_estimated_optimal2(:,k)=Coordinates_User_estimated_optimal;
for i=1:N_selected_BS
    plot3(Coordinates_BS(BS_optimal(i),1),Coordinates_BS(BS_optimal(i),2),Coordinates_BS(BS_optimal(i),3),'o');
end

LMS_difference_least;
plot3(Coordinates_User_estimated_optimal2(1,:),Coordinates_User_estimated_optimal2(2,:),Coordinates_User_estimated_optimal2(3,:),'r+');hold on;%作图显示估计的用户位置
grid on
end
plot3(temp_a(:,1),temp_a(:,2),temp_a(:,3),'gx');hold on;
legend('定位位置','基站位置');



dataoutput=Coordinates_User_estimated_optimal2';
figure(2);plot(Coordinates_BS(:,1),Coordinates_BS(:,3),'o');hold on;%X-Y平面
figure(2);plot(dataoutput(:,1),dataoutput(:,3),'r+');hold on;
figure(2);plot(temp_a(:,1),temp_a(:,3),'gx');hold on;
grid on


figure(3);plot(Coordinates_BS(:,1),Coordinates_BS(:,2),'o');hold on;%X-Y平面
figure(3);plot(dataoutput(:,1),dataoutput(:,2),'r+');hold on;
figure(3);plot(temp_a(:,1),temp_a(:,2),'gx');hold on;
grid on

sum1=0;sum2=0;sum3=0;eth=2;
for i=1:100
    d1=sqrt((dataoutput(i,1)-temp(i,1))^2+(dataoutput(i,2)-temp(i,2))^2);
    if d1<eth
        sum1=sum1+1;
    end
    d2=sqrt((dataoutput(i,1)-temp(i,1))^2+(dataoutput(i,3)-temp(i,3))^2);
    if d2<eth
        sum2=sum2+1;
    end
    d3=sqrt((dataoutput(i,1)-temp(i,1))^2+(dataoutput(i,2)-temp(i,2))^2+(dataoutput(i,3)-temp(i,3))^2);
    if d3<eth
        sum3=sum3+1;
    end
end
estimate_XY=sum1/100;
estimate_XZ=sum2/100;
estimate_3D=sum3/100;
