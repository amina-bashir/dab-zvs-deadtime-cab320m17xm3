run('coss_setup.m');

f_sw  = 20e3;
Vi    = 800;
Vo    = 800;
D1    = 0.70;
D2    = 0.40;
D3    = 0.35;
tdead = 200e-9;

Ri = 0.1;      Ro = 0.1;
Li = 25e-6;    Lo = 25e-6;
Ci = 75e-6;    Co = 110e-6;
n  = 1.7;
Ls = 37.5e-6;  Rs = 25e-3;

Rds = 1e-6;  Vth = 0.5;  G_mosfet = 1e-5;  Vf_diode = 0.01;
Tsolver = 20e-9;

T  = 1/f_sw;
PD = mod([0, 1, D1, 1+D1, D3, 1+D3, D3+D2, 1+D3+D2]*T/2 + tdead, T);
PD_S1 = PD(1);  PD_S2 = PD(2);  PD_S3 = PD(3);  PD_S4 = PD(4);
PD_S5 = PD(5);  PD_S6 = PD(6);  PD_S7 = PD(7);  PD_S8 = PD(8);
PW_PCT = 100*(0.5 - tdead*f_sw);
