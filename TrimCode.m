function [ Tx , Alpha , elevator ] = TrimCode(VTAS,altitude)
 


%     Thrust , alpha        , elevator 
lb = [ 0     ; deg2rad(-10) ; deg2rad(-10) ];
ub = [ 2000  ; deg2rad(30)  ; deg2rad(10) ];
  
options = optimoptions('fmincon','Display','iter','OptimalityTolerance',1e-12,'StepTolerance',1e-12);
% options = optimoptions('fmincon','Display','none','OptimalityTolerance',1e-10,'StepTolerance',1e-10);
    

X0 = [ 5 deg2rad(0) deg2rad(0) ];  % ( Tx(N) delta_alpha, delta_e  ) Initial guess
[ x , ~ ] = fmincon( @(x) plsTrim(x,VTAS,altitude),X0,[],[],[],[],lb,ub,[],options);
 

TrimThrust   = x(1)
TrimAOA      = rad2deg( x(2) )
TrimElevator = rad2deg( x(3) )
Tx        = x(1) ;
Alpha     = x(2) ;
elevator  = x(3) ;
[dxnorm, dx]  = plsTrim(x,VTAS,altitude)
end




function [ J , dx ] = plsTrim( x , VTAS , altitude )
Tx     = x(1); 
dalpha = x(2);
deltae = x(3);

gamma = deg2rad(0);

U0     = VTAS*cos( dalpha ); 
W0     = VTAS*sin( dalpha );
 
g           = 9.81;
[~,a,~,rho] = atmosisa(altitude);
Mach        = VTAS/a;
  
m     = 0.587;
Jyy   = 0.0040; 
cbar  = 0.0862;  % m
S     = 0.0174;   % m2    


pd0      = 1/2*rho*( U0^2 + W0^2 );

load('aerodataSDM.mat'); 

CX_cur = interp3( dEBP , alphaBP , machBP , CFx        , deltae    , dalpha  , Mach , 'linear' );
CZ_cur = interp3( dEBP , alphaBP , machBP , CFz        , deltae    , dalpha  , Mach , 'linear' );
[ CD_cur  , CL_cur ] = rotate2wind( CX_cur , CZ_cur , dalpha );
Cm_cur = interp3( dEBP , alphaBP , machBP , CMmShifted , deltae    , dalpha  , Mach , 'linear' );


pd0S     = pd0*S; 
pd0Scbar = pd0*S*cbar;

D_Force  = ( CD_cur )*pd0S;
L_Force  = ( CL_cur )*pd0S;

m_Moment = ( Cm_cur )*pd0Scbar;

params.m     = m;
params.g     = g;
params.D0    = D_Force;
params.L0    = L_Force;
params.m_m   = m_Moment;
params.Jyy   = Jyy;
params.Tx    = Tx;
params.gamma = gamma;


x(1) = U0;
x(2) = W0;
x(3) = 0;
dx   = f(x,params);
J    = norm(dx); 
end





function xdot = f( x , params )
m       = params.m;
g       = params.g;
D0      = params.D0;
L0      = params.L0;
Jyy     = params.Jyy;
Tx      = params.Tx;
m_mom   = params.m_m;
gamma   = params.gamma;

U       = x(1);
W       = x(2);

Alpha   = atan2(W,U);               %[rad]

sA  = sin(Alpha);
cA  = cos(Alpha);

% theta = gamma + alpha 
Theta = gamma + Alpha;
sT = sin(Theta);
cT = cos(Theta);

xdot = zeros(3,1);

xdot(1) = ( - cA*D0 + sA*L0 - m*g*sT + Tx )/m ; %U
xdot(2) = ( - sA*D0 - cA*L0 + m*g*cT )/m; %W
xdot(3) = ( m_mom )/Jyy ; %Q
end


function [ D , L ] = rotate2wind( FX , FZ, alpha  )
Osa = [ cos(alpha) sin(alpha);
       -sin(alpha) cos(alpha)];

FW  = -1*Osa*[FX;FZ];
D = FW(1);
L = FW(2);

end