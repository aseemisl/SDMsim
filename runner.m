clear all
clc

time = 60; 
VTAS     = 400;
altitude = 1000;
Ts       = 0.01; % data logging sampling time
[ tTrim , alpha , deTrim ] = TrimCode(VTAS,altitude);
[~,a,~,~] = atmosisa(altitude);
Mach        = VTAS/a

thrust = [ 0 tTrim;
           2 tTrim;
           200 13.6991]; %decreasing thrust  


params.S    = 0.0174;
params.c    = 0.0862;
params.m    = 0.587;
params.g    = 9.81; 
params.Jyy  = 0.0040; 

params.udotlim   = 40; 
params.zeta_act  = 0.7; 
params.omega_act = 4*2*pi; %[rad/s]  % [Hz]*2pi = [rad/s]


U0 = VTAS*cos( alpha ); 
W0 = VTAS*sin( alpha );
Q0 = 0;
Theta0 = alpha;
Z0 = -altitude;
x0 = [ U0 ; W0 ; Q0 ; Theta0 ; Z0 ; deTrim ; 0 ];
 
 
load("aerodataSDM.mat") 
simOut = sim('flightSDM','SaveOutput','on','StopTime',num2str(time) );


%% Plots 
figure(1)
clf
subplot(3,2,1)
stairs( simOut.y.time , squeeze( simOut.y.signals.values(:,1) ) , 'b' , 'linewidth' , 2 )
ylabel( '$V$ (m/s)','Interpreter','latex','FontSize',14)
grid on
axis tight
subplot(3,2,2)
stairs( simOut.y.time , rad2deg( squeeze( simOut.y.signals.values(:,2) ) ) , 'b' , 'linewidth' , 2 )
ylabel( '$\alpha\ (^\circ)$','Interpreter','latex','FontSize',14)
grid on
axis tight
subplot(3,2,3)
stairs( simOut.y.time , rad2deg( squeeze( simOut.y.signals.values(:,3) ) ) , 'b' , 'linewidth' , 2 )
hold on
stairs( simOut.r.time , rad2deg(   simOut.r.signals.values ) , 'r-.' , 'linewidth' , 2 )
hold off
ylabel( '$Q\ (^\circ/{\rm s})$','Interpreter','latex','FontSize',14)
legend( '$Q$','$Q_{\rm command}$','Interpreter','latex','FontSize',12)
grid on
axis tight
subplot(3,2,4)
stairs( simOut.x.time , rad2deg( squeeze( simOut.x.signals.values(:,4) ) ) , 'b' , 'linewidth' , 2 )
ylabel( '$\Theta(^\circ)$','Interpreter','latex','FontSize',14)
grid on
axis tight
subplot(3,2,5)
stairs( simOut.x.time ,  - squeeze( simOut.x.signals.values(:,5) )  , 'b' , 'linewidth' , 2 )
ylabel( '$h$ (m)','Interpreter','latex','FontSize',14)
grid on
axis tight
xlabel( '$t$ (s)','Interpreter','latex','FontSize',14)
subplot(3,2,6)
stairs( simOut.gamma.time ,   rad2deg( simOut.gamma.signals.values )   , 'b' , 'linewidth' , 2 )
ylabel( '$\gamma \ (^\circ)$','Interpreter','latex','FontSize',14) 
grid on
axis tight
xlabel( '$t$ (s)','Interpreter','latex','FontSize',14)






figure(2)
clf
subplot(4,1,1)
stairs( simOut.thrust.time ,   simOut.thrust.signals.values   , 'b' , 'linewidth' , 2 )
ylabel( '$T$ (N)','Interpreter','latex','FontSize',14) 
grid on
axis tight
subplot(4,1,2)
stairs( simOut.x.time ,  rad2deg(  squeeze( simOut.x.signals.values(:,6) ) )   , 'b' , 'linewidth' , 2 )
hold on
stairs( simOut.u.time ,  rad2deg( squeeze( simOut.u.signals.values ) )   , 'r-.' , 'linewidth' , 2 )
hold off
ylabel( '$\delta_{\rm e}(^\circ)$','Interpreter','latex','FontSize',14)
legend( 'Actual','Demanded','Interpreter','latex','FontSize',12)
grid on
axis tight
subplot(4,1,3)
stairs( simOut.Mach.time ,  simOut.Mach.signals.values  , 'b' , 'linewidth' , 2 )
hold on
stairs(  simOut.Mach.time ,   1+0*simOut.Mach.signals.values  , 'r-.' , 'linewidth' , 2 )
hold off
ylabel( 'M','Interpreter','latex','FontSize',14) 
grid on
axis tight
subplot(4,1,4)
stairs( simOut.Cmalpha.time ,   simOut.Cmalpha.signals.values  , 'b' , 'linewidth' , 2 )
hold on
stairs( simOut.Cmalpha.time ,   0*simOut.Cmalpha.signals.values  , 'r-.' , 'linewidth' , 2 )
hold off
ylabel( '$C_{m\alpha}$','Interpreter','latex','FontSize',14) 
grid on
axis tight
xlabel( '$t$ (s)','Interpreter','latex','FontSize',14)
