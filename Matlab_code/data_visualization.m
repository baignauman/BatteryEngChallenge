clc
close all
clear all
%% Data Read section
M=csvread('2018-04-12_batch8_CH33.csv',1,0);
cycle_index=M(:,6);
start_indx=min(find(cycle_index==1));
M=M([start_indx:end],:);
cycle_index=M(:,6);
data_point=M(:,1);
test_time=M(:,2);
datetime=M(:,3);
step_time=M(:,4);
step_index=M(:,5);
current=M(:,7);
voltage=M(:,8);
chg_cap=M(:,9);
dis_cap=M(:,10);
chg_energy=M(:,11);
dcg_energy=M(:,12);
dv_dt=M(:,13);
rint=M(:,14);
temp=M(:,15);
aux_vol=M(:,16);
test_time_days=test_time/(24*3600);
step_time_days=step_time/(24*3600);
%%
%Single cycle data
sin_cyc_indx=find(cycle_index>=1 & cycle_index<2);
test_time_hrs_sin=test_time_days(sin_cyc_indx)*60;
current_sin=current(sin_cyc_indx);
voltage_sin=voltage(sin_cyc_indx);
f=figure('Name','single_cycle_data')
subplot(2,1,1)
plot(test_time_hrs_sin-test_time_hrs_sin(1),current_sin)
xlabel('Time[hrs]')
ylabel('Current')
legend('Current')
grid on
subplot(2,1,2)
plot(test_time_hrs_sin-test_time_hrs_sin(1),voltage_sin)
xlabel('Time[hrs]')
ylabel('Voltage')
legend('Voltage')
grid on
saveas(gcf,'Single_cycle_data.pdf')
%%
% Max Charge / discharge capacity per cycle
dch_cap_max_arr=[];
ch_cap_max_arr=[];
rint_max_arr=[];
for i=1:max(cycle_index)-1

sin_cyc_indx=find(cycle_index>=i & cycle_index<i+1);
test_time_hrs_sin=test_time_days(sin_cyc_indx)*60;
current_sin=current(sin_cyc_indx);
voltage_sin=voltage(sin_cyc_indx);
dch_cap_max_arr=[dch_cap_max_arr,max(dis_cap(sin_cyc_indx))];
ch_cap_max_arr=[ch_cap_max_arr,max(chg_cap(sin_cyc_indx))];
rint_max_arr=[rint_max_arr,max(rint(sin_cyc_indx))];
end
%%
% (Plots) capcaity vs cycles
cyc_idx=1:max(cycle_index)-1;
f=figure('Name','Capacity vs N')
subplot(2,1,1)
plot(cyc_idx,ch_cap_max_arr)
grid on
xlabel('Ncycle')
ylabel('Capacity')
legend('Charging')
subplot(2,1,2)
plot(cyc_idx,dch_cap_max_arr)
xlabel('Ncycle')
ylabel('Capacity')
legend('Discharging')
grid on
saveas(gcf,'cap_vs_cycles.pdf')
f=figure('Name','SOHr_vs_cycles')
subplot(2,1,1)
soh_ch=(ch_cap_max_arr/ch_cap_max_arr(1))*100;
plot(cyc_idx,soh_ch)
grid on
xlabel('Ncycle')
ylabel('SOHr[%]')
legend('Charging')
subplot(2,1,2)
soh_dch=(dch_cap_max_arr/dch_cap_max_arr(1))*100;
plot(cyc_idx,soh_dch)
xlabel('Ncycle')
ylabel('SOHr[%]')
legend('Discharging')
grid on
saveas(gcf,'SOHr.pdf')

% Rint_max over cycles
f=figure('Name','Rint')
plot(cyc_idx,rint_max_arr)
grid on
xlabel('Ncycle')
ylabel('Rint')
legend('Rint')
saveas(gcf,'Rint_vs_cycles.pdf')

%% Polynomial fitting approach
sys=tf(1,[1 1]);
dch_energy_max_arr_smth=lsim(sys,dch_cap_max_arr,cyc_idx)*100;
%fitting result
       x=[1:2189];
       a =  -0.0005829  
       b =     0.00426  
       c =       106.6  
       d =  -2.755e-05  

  poly= a*exp(b*x) + c*exp(d*x);
  
  figure('Name','Actual vs fitted Capacity')
  subplot(2,1,1)
  plot(x,poly,cyc_idx,dch_cap_max_arr*100)
  grid on
  legend('Fitted Dch Cap','Actual Dch Cap ')
  xlabel('Ncycle')
  ylabel('SOHr[%]')
  grid on
  subplot(2,1,2)
  plot(x,(poly-dch_cap_max_arr*100)./(dch_cap_max_arr*100)*100)
  xlabel('Ncycle')
  ylabel('Relative error[%]')
  grid on
  saveas(gcf,'actual_vs_fitted_data poly.pdf')
  
  %% Neural Network approach
  
  % Solve an Input-Output Fitting problem with a Neural Network
% Script generated by Neural Fitting app
% Created 17-Mar-2021 15:31:37
%
% This script assumes these variables are defined:
%
%   cyc_idx - input data.
%   dch_cap_max_arr - target data.

x = cyc_idx;
t = dch_cap_max_arr;

% Choose a Training Function
% For a list of all training functions type: help nntrain
% 'trainlm' is usually fastest.
% 'trainbr' takes longer but may be better for challenging problems.
% 'trainscg' uses less memory. Suitable in low memory situations.
trainFcn = 'trainlm';  % Levenberg-Marquardt backpropagation.

% Create a Fitting Network
hiddenLayerSize = 10;
net = fitnet(hiddenLayerSize,trainFcn);

% Setup Division of Data for Training, Validation, Testing
net.divideParam.trainRatio = 70/100;
net.divideParam.valRatio = 15/100;
net.divideParam.testRatio = 15/100;

% Train the Network
[net,tr] = train(net,x,t);

% Test the Network
y = net(x);
e = gsubtract(t,y);
performance = perform(net,t,y)

% View the Network
view(net)

figure('Name','Actual vs fitted Capacity NN')
subplot(2,1,1)
plot(x,y*100,x,dch_cap_max_arr*100)
grid on
xlabel('Ncycle')
ylabel('SOHr[%]')
legend('Fitted Dch Cap','Actual Dch Cap ')
subplot(2,1,2)

subplot(2,1,2)
plot(x,(y*100-dch_cap_max_arr*100)./(dch_cap_max_arr*100)*100)
xlabel('Ncycle')
ylabel('Relative error[%]')
grid on
saveas(gcf,'actual_vs_fitted_data NN.pdf')
