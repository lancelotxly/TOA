clear all;clc;close all;
temp=textread('sample_case005_input.txt');
BS=temp([4:23],[1:3]);
TOA=temp([24:1023],[1:20]);
Coordinates_BS=BS;
N_BS=length(Coordinates_BS);%��վ��Ŀ
r_BS_to_User=TOA.*300000000;
temp=textread('sample_case005_ans.txt');
Nub=0;
Coordinates_BS(:,3)=Coordinates_BS(:,3);
temp(:,3)=temp(:,3);
figure(1);plot3(Coordinates_BS(:,1),Coordinates_BS(:,2),Coordinates_BS(:,3),'o');hold on;%��ͼ��ʾ��վλ��3D
figure(2);plot(Coordinates_BS(:,1),Coordinates_BS(:,2),'o');hold on;%X-Yƽ��
figure(3);plot(Coordinates_BS(:,1),Coordinates_BS(:,3),'o');hold on;%X-Zƽ��
for k=1:1000;
A_matrix=[];
R_vector=[];
for n=1:N_BS-1
    A_matrix=[A_matrix;-2*Coordinates_BS(n,1)+2*Coordinates_BS(n+1,1),-2*Coordinates_BS(n,2)+2*Coordinates_BS(n+1,2),-2*Coordinates_BS(n,3)+2*Coordinates_BS(n+1,3),r_BS_to_User(k,n+1)^2-r_BS_to_User(k,n)^2];%���Է��̲�������
    R_vector=[R_vector;-Coordinates_BS(n,1)^2+Coordinates_BS(n+1,1)^2-Coordinates_BS(n,2)^2+Coordinates_BS(n+1,2)^2-Coordinates_BS(n,3)^2+Coordinates_BS(n+1,3)^2];%���Է��̰������
end
A=(A_matrix'*A_matrix+Nub^2*eye(4))^-1;
%A=pinv(A_matrix'*A_matrix);
Coordinates_User_estimated=A*(A_matrix'*R_vector);%��С����
Coordinates_User_ans(:,k)=Coordinates_User_estimated;
end
dataoutput=(Coordinates_User_ans)';
figure(1);plot3(dataoutput(:,1),dataoutput(:,2),dataoutput(:,3),'rx');hold on;%3Dλ�ù���
figure(1);plot3(temp(:,1),temp(:,2),temp(:,3),'g+');hold on;
grid on;legend('Base Stations','Estimated User Position','Exact User Position');hold on;     
figure(2);plot(dataoutput(:,1),dataoutput(:,2),'r+');hold on;%X-Yƽ��
figure(2);plot(temp(:,1),temp(:,2),'gx');hold on;           
grid on;legend('Base Stations','Estimated User Position','Exact User Position');hold on;
figure(3);plot(dataoutput(:,1),dataoutput(:,3),'rx');hold on;%X-Zƽ��
figure(3);plot(temp(:,1),temp(:,3),'g+');hold on;
grid on;legend('Base Stations','Estimated User Position','Exact User Position');hold on;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
sum1=0;sum2=0;sum3=0;
eth1=1;eth2=1;

for i=1:1000
    d1=sqrt((dataoutput(i,1)-temp(i,1))^2+(dataoutput(i,2)-temp(i,2))^2);
    if d1<eth1
        sum1=sum1+1;
    end
    d2=sqrt((dataoutput(i,1)-temp(i,1))^2+(dataoutput(i,3)-temp(i,3))^2);
    if d2<eth2
        sum2=sum2+1;
    end
    d3=sqrt((dataoutput(i,1)-temp(i,1))^2+(dataoutput(i,2)-temp(i,2))^2+(dataoutput(i,3)-temp(i,3))^2);
    if d3<eth2
        sum3=sum3+1;
    end
end
estimate_XY=sum1/1000;
estimate_XZ=sum2/1000;
estimate_3D=sum3/1000;