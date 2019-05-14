clear all;clc;close all;
temp=textread('sample_case005_input.txt');
BS=temp([4:23],[1:3]);
TOA=temp([24:1023],[1:20]);
Coordinates_BS=BS;           
N_BS=length(Coordinates_BS);%��վ��Ŀ
Nub1=1;
Nub2=1;
temp=textread('sample_case005_ans.txt');
temp_a=temp([1:100],[1:3]);
for k=1:100
    k
    A_matrix=[];
    R_vector=[];
    r_BS_to_User(k,:)=3*10^8*TOA(k,:);
    for n=1:N_BS-1
    A_matrix=[A_matrix;-2*Coordinates_BS(n,1)+2*Coordinates_BS(n+1,1),-2*Coordinates_BS(n,2)+2*Coordinates_BS(n+1,2),-2*Coordinates_BS(n,3)+2*Coordinates_BS(n+1,3),r_BS_to_User(k,n+1)^2-r_BS_to_User(k,n)^2];%���Է��̲�������
    R_vector=[R_vector;-Coordinates_BS(n,1)^2+Coordinates_BS(n+1,1)^2-Coordinates_BS(n,2)^2+Coordinates_BS(n+1,2)^2-Coordinates_BS(n,3)^2+Coordinates_BS(n+1,3)^2];%���Է��̰������
    end
    A=(A_matrix'*A_matrix+Nub1^2*eye(4))^-1;
    %A=pinv(A_matrix'*A_matrix);
    Coordinates_User_estimated=A*A_matrix'*R_vector;%��С����
    Coordinates_User_ans(:,k)=Coordinates_User_estimated;
    for n=1:N_BS
        Distance(:,n)=sqrt((Coordinates_User_estimated(1,:)-Coordinates_BS(n,1))^2+(Coordinates_User_estimated(2,:)-Coordinates_BS(n,2))^2);
    end
    Distance_mean=mean(Distance);
    r_BS_to_User_est=r_BS_to_User(find(r_BS_to_User(k,:)<Distance_mean));
    N_BS_near=length(r_BS_to_User_est);
    N_selected_BS=5;%ѡ��Ļ�վ����
    Combinations_of_BS=nchoosek(1:N_BS_near,N_selected_BS);%�����л�վ��ѡ���N_selected_BS����վ�Ŀ������
    LMS_difference_least=inf;%���ڴ洢��С���ı���
for m=1:nchoosek(N_BS_near,N_selected_BS)%ѭ�����е����
    Selected_BS_index=Combinations_of_BS(m,:);%�˴�ѭ����Ӧ�Ļ�վ�±�
    A_matrix=[];
    R_vector=[];
for n=1:N_selected_BS-1
    A_matrix=[A_matrix;-Coordinates_BS(Selected_BS_index(n),1)+Coordinates_BS(Selected_BS_index(n+1),1),-Coordinates_BS(Selected_BS_index(n),2)+Coordinates_BS(Selected_BS_index(n+1),2),-Coordinates_BS(Selected_BS_index(n),3)+Coordinates_BS(Selected_BS_index(n+1),3),(r_BS_to_User_est(Selected_BS_index(n))^2-r_BS_to_User_est(Selected_BS_index(n+1))^2)/2];%���Է��̲�������
    R_vector=[R_vector;-(Coordinates_BS(Selected_BS_index(n),1)^2-Coordinates_BS(Selected_BS_index(n+1),1)^2+Coordinates_BS(Selected_BS_index(n),2)^2-Coordinates_BS(Selected_BS_index(n+1),2)^2+Coordinates_BS(Selected_BS_index(n),3)^2-Coordinates_BS(Selected_BS_index(n+1),3)^2)/2];%���Է��̰������
end
    A=(A_matrix'*A_matrix+Nub2^2*eye(4))^-1;
    Coordinates_User_estimated=A*A_matrix'*R_vector;%��С����
    LMS_difference_temp=norm(R_vector-A_matrix*Coordinates_User_estimated);%�������

if LMS_difference_temp<LMS_difference_least%������С���������е����
    LMS_difference_least=LMS_difference_temp;%������С���
    Coordinates_User_estimated_optimal=Coordinates_User_estimated;%�������Ź���λ��
    BS_optimal=Selected_BS_index;%�������Ż�վ��LOS���±�
end

end
Coordinates_User_estimated_optimal2(:,k)=Coordinates_User_estimated_optimal;
for i=1:N_selected_BS
    plot3(Coordinates_BS(BS_optimal(i),1),Coordinates_BS(BS_optimal(i),2),Coordinates_BS(BS_optimal(i),3),'o');
end

LMS_difference_least;
plot3(Coordinates_User_estimated_optimal2(1,:),Coordinates_User_estimated_optimal2(2,:),Coordinates_User_estimated_optimal2(3,:),'r+');hold on;%��ͼ��ʾ���Ƶ��û�λ��
grid on
end
plot3(temp_a(:,1),temp_a(:,2),temp_a(:,3),'gx');hold on;
legend('��λλ��','��վλ��');

dataoutput=Coordinates_User_estimated_optimal2';
figure(2);plot(Coordinates_BS(:,1),Coordinates_BS(:,3),'o');hold on;%X-Yƽ��
figure(2);plot(dataoutput(:,1),dataoutput(:,3),'r+');hold on;
figure(2);plot(temp_a(:,1),temp_a(:,3),'gx');hold on;
grid on


figure(3);plot(Coordinates_BS(:,1),Coordinates_BS(:,2),'o');hold on;%X-Yƽ��
figure(3);plot(dataoutput(:,1),dataoutput(:,2),'r+');hold on;
figure(3);plot(temp_a(:,1),temp_a(:,2),'gx');hold on;
grid on

sum1=0;sum2=0;sum3=0;eth=10;
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
