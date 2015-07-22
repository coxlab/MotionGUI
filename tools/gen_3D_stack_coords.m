track_velocity=.003;
nFields=9;

X=1.0207 ; Y=0.4002 ; Z=0.6301
power=70;
center=[X Y Z];
power_level(2)=power;

X=1.0208 ; Y=0.4002 ; Z=0.4115
power=39;
top=[X Y Z];
power_level(1)=power;

X=1.0208 ; Y=0.4002 ; Z=0.8462
power=100;
bottom =[X Y Z];
power_level(3)=power;


FOV_size=[336 430]/1000;
overlap_factor=.80;

scaling_factor=1;
P1=center+[-FOV_size(2)*scaling_factor FOV_size(1)*scaling_factor -center(3)+top(3)];
P2=center+[+FOV_size(2)*scaling_factor -FOV_size(1)*scaling_factor -center(3)+bottom(3)];

power_level=power_level-min(power_level);
power_level=power_level/max(power_level);
clear power
exponents=linspace(.8,3,100);
est=power(.5,exponents);
exponent_estimate=exponents(close2(est,power_level(2)))
stack_size=abs(diff([P1 ; P2]));
time_overhead_factor=1.0150;
frame_rate=2.97;
est_time=stack_size(3)/track_velocity*nFields*time_overhead_factor;
est_frames=round(est_time*frame_rate) % 3877 actual is (3877+3935-3877)/3877
fprintf('X=%3.4f ; Y=%3.4f ; Z=%3.4f\n',[P1 P2])

