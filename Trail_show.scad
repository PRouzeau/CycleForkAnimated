//This small program is here to show how evolve fork geometry for a given trail when the trail angle change
//And also how trail evolve when offset change for a given angle
// I have a 'reversed' fork on my Velassi V2 bike (this is allowed by an indirect steering -rod actuated), which permit more optimal geometry as I am no longer bound by my arms length. Most people don't understand the geometry and keep asking if if have a negative trail, so I made this visual short demo as an explanation.
// Copyright 2019-2023 Pierre ROUZEAU,  AKA PRZ
// Program license GPL V3
// documentation licence cc BY-SA 4.0 and GFDL 1.2
// First version: 0.0 - Sept, 12, 2023
// Source: https://github.com/PRouzeau/CycleForkAnimated
// See the attached text file for references to bike geometry design
//*****************************
include <Library/Bike_accessories.scad> //also include Z_library2.scad
/*[Geometry]*/ 
//Demonstration type 
demotype = 0; // [0:Constant trail, 1: Constant angle]
//front steering caster angle (10~12° for trikes with 406 wheels)
//Trail for fixed trail show
fixed_trail = 80;
//Front wheel axis offset (rake - if steering axis is not in same plane as wheel shaft) - perpendicular to steering axis
//perp_axis_offset = 37;
//Steering angle for fixed angle show
fixed_steerangle = 72;
//steering angle
strot=0; 
/*[Fork description]*/ 
//Fork style (1 wheel)
fork_style = 0; //[0:Rigid, 1:Suspended, 2: Experimental lefty, 3: User defined]
//Frame head tube length (1 or 2 wheels)
head_tube_height = 90;
//Steerer tube length atop bearing seat plane (1 wheel)
steerer_tube_length = 120;
//Fork/pivot perpendicular height - from wheel axis line to bottom bearing seat. (1 or 2 wheels)
frame_pivot_height =385;
//Steering bottom bearing vertical space (1 wheel)
steer_bbht = 5;
//Display full wheels (else wire model)
display_wheels = 1; //[0:No wheel, 1:Plain wheels, 2: Wireframe wheels]
/*[Presentation]*/ 
//Language 
lang = 0; //[0:English, 1:French, 2:Spanish, 3:Italian]
//Fork color
c_fork="Green";
//View type
view_type = 0; // [0:3D view, 1:Blueprint projection, 2:Side projection, 3:Top projection, 4:Front projection, 5:Fairing projection]
/*[Wheel]*/ 
//Front wheel rim diameter
front_wheel_rim = 559; //[203,305,349,355,406,455,507,540,559,584,622]
//Front tire width
front_wheel_tire = 47; //[22:125]

/*[Hidden]*/ 
//Impose camera position if rotation vector is default - to detect first startup
Cimp = $vpr==[55,0,25]; 
//Camera translation 
$vpt=Cimp?[25,0,365]:$vpt; 
//Camera rotation
$vpr=Cimp?[90,0,0]:$vpr; 
//Camera distance
$vpd=Cimp?2700:$vpd; 
//echo_camera();

//======================================================
//Changing parameters
//For fixed trail
caster_angle = 30*(1-($t<0.5?2*$t:2-2*$t)); // use 60 steps
//For fixed angle
fperp_axis_offset = 50*(1-($t<0.5?2*$t:2-2*$t)); // use 40 steps

wheel_hdia= wheel_diam(front_wheel_rim,front_wheel_tire)/2;


fcast_angle = 90-fixed_steerangle;
fground_length = wheel_hdia/cos(fcast_angle);
ftrail_base = fground_length*sin(fcast_angle);

//ground axis offset for fixed angle
faxis_offset= fperp_axis_offset/cos(fcast_angle);
//Resulting trail for fixed angle
ftrail = ftrail_base-faxis_offset;
//trail2 = wheel_hdia*tan(caster_angle)-perp_axis_offset/cos(caster_angle);
//Results for fixed trail
taxis_offset = wheel_hdia*tan(caster_angle)-fixed_trail; 
tperp_axis_offset = taxis_offset*cos(caster_angle);

//echo (trail, trail2);
//echo (axis_offset, axis_offset2);
c_angle = demotype==1?fcast_angle:caster_angle;
trail = demotype==1?ftrail:fixed_trail;
perp_axis_offset = demotype==1?fperp_axis_offset:tperp_axis_offset;
axis_offset = demotype==1?faxis_offset:taxis_offset;

//=================================================
mirrorx() {
  //-- Wheel --
  fwheel();
  //-- Fork --
  fork(fork_style,-strot, frame_pivot_height,wheel_hdia, c_angle, perp_axis_offset, 100, steerer_tube_length,steer_bbht,head_tube_height,c_fork);
  //-- Vertical marker --
  color("lime") 
    cylz(5,wheel_hdia, 0,-70,0, 4);
  //-- Steering axis marker --
  red() 
    diff() {
      t(axis_offset,0, wheel_hdia)
        r(0,c_angle)
          cylz(5,940, 0,-72,-400, 4);
      ncube(299,199,99, 0,0,-1); 
    }
  //-- Trail colored mark --  
  yellow() 
    ncube(trail,1,25, -1,0,-1);
  //-- Fork offset marker --  
  t(0,-70, wheel_hdia)
    r(0,c_angle) 
      if(perp_axis_offset) { //shall not be zero
        blue()
          ncube(abs(perp_axis_offset),1,16, sign(perp_axis_offset),0,-1);
        black()
          ncube(abs(perp_axis_offset),1,1.5, sign(perp_axis_offset),0,0);
      }
  //-- Trail mark --    
  black() {
    ncube (450,150,1.5, 0,0,-1);
    duplx(-trail)
      ncube(2,150,25, 0,0,-1);
  }  
}

//== Text ===========================================
txt_s = [28,24,24,23];
txtsize = txt_s[lang]; // smaller size for more verbose language

Wheel_txt = ["Wheel diameter 26\"","Roue diamètre 26\"","Rueda diametro 26\"","Ruota diametro 26\""];
Unit_txt = ["Unit: mm","Unités: mm","Unidad: mm","Unità: mm"];
Trail_txt = ["Trail: ","Chasse: ","Avance: ","Avancorsa: "];
Steering_ang_txt = ["Steering angle: ","Angle de direction: ","Ángulo del cabezal: ","Angolo di sterzo: "];
Fork_offset_txt = ["Fork offset: ","Déport de fourche: ","Desplazamiento: ","Offset della Forcella: "];

t(120,0,700) r(90) 
   text(Wheel_txt[lang],txtsize);  
t(-350,0,16) r(90) 
   text(Unit_txt[lang],txtsize*0.8);  
t(0,0,-38) r(90) 
   text(str(Trail_txt[lang],0.1*round(trail*10)),txtsize,valign="top");  
t(-350,0,-15) r(90) 
   text(str(Steering_ang_txt[lang],round(90-c_angle)),txtsize,valign="top");  
t(185,0,15) r(90) 
   text(str(Fork_offset_txt[lang],round(perp_axis_offset)),txtsize);  

//====================================================
  module fwheel (top_symb=true) {
    tslz(wheel_hdia)
      if(display_wheels==1) 
        wheel(front_wheel_rim,front_wheel_tire,30,shaft_width=130, spa=14,spoke_nbr=32, hub_offset=0, clr_rim="silver",clr_tire="gray");
      else if(display_wheels==2)
        wheel_wireframe(wheel_hdia*2,top_symb);
	}

//== Calculation =================
function wheel_diam (rim,tire)= rim+2*tire+4;
  
//Not yet used,can steer the wheel/fork
//Can be used to show that with a reclined steering, the frome go down  stro is steering right/left angle
module steer (stro) {
	t(axis_offset,0, pivot_height)
		r(0,caster_angle)
			stx(stro) children();
			
	module stx(str1) 
		rotz(str1)
			r(0,-caster_angle)
				t(-axis_offset,0, -pivot_height)
          children();
}

