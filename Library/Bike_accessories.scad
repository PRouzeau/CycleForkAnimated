//Seats, lights, Bike wheel and fenders modelisation are extrated from Velassi simulation (Velassi not published)
// Copyright 2018-2022 Pierre ROUZEAU AKA PRZ
// Program license GPL 4.0
// documentation licence cc BY-SA 3 and GFDL 1.2
// First version: 0.0 - November 2018
//Feb 2020: Add ICE mesh seat, Hardshell seat, corrected Rans seat frame width
//Dec 2020: Corrected hardshell viewing artifacts 
//2021: Added DIY foldable seat, designed to use ICE Mesh
//2022: Export part for DIY seat
// To work, this module requires my OpenSCAD library, attached, but you can find details here:
// https://github.com/PRouzeau/OpenScad-Library
//2023: Update DIY Foldable seat 

//dcheck = false;

use <Z_library2.scad>

//DIY tube external diameter: 25-25.4
seatde = 25;
//Internal seat tube diameter (for plugs)
seatdi = 22;
//External flag guide tube diameter: 12-12.5)
flagdtub = 12.2;
//== Test of the accessories ===
//Testing seat
test_seat = 0; //[0:no seat view, 1:Rans mesh, 2:ICE mesh, 3: Hardshell, 4:DIY foldable mesh seat, 5:DIY seat with folded back, 6:DIY seat with beak, 7:DIY seat parts, 8:DIY seat with beak parts, 9:Saddle, 12:DIY beak seat side view, 15:15-Seat back top plugs, 16:16-Seat beak plugs, 17:17-Seat crest plugs, 18:18-Seat bottom plug, 19:19-Seat riser, 20:Seat center support ensemble, 21:21-Seat center support part 1,22:22-Seat center support part 2,23:23-Seat center support part 3, 25:25-Back link tube connection, 27:27-Seat support collar guide, 28:Kickstand plug -misplaced..]
//Seat angle
seat_a = 50; // [15:85]
//Flag attached to seat
seat_f=true;
//Rear light attached to seat
seat_l=true;
//View ICE seat superposed
Disp_ICE = true;  
  
//Testing wheel
test_wheel = 0; //[0:no wheel, 1:Symetrical wheel, 2:Wheel hub offset, 3:Radial spokes, 4:Disc wheel, 5:Wheel with fender]
spoke_test = 32; // [0,3,4,5,6,8,20,24,28,32,36,42]

//Testing fork
test_fork = 0; //[0:No fork, 1:Rigid fork, 2:Suspended fork, 3:Experimental Lefty, 4:User fork]
//test viewing handlebar

//Testing handlebar
test_hdl = 0; // [0:none, 1:Trike direct, 2:Cruiser 400mm long, 6:Cruiser flat 80 mm, 3:Hamster, 4:U Bar, 5:Underseat U bar with center bend]

//Testing pannier
test_pannier = 0; // [0:none,1:Default pannier, 2:Pannier with back cut, 3:Symmetrical high pannier, 4:Pannier flush with luggage rack]
//Testing shock
test_shock = 0; //[0:none, 1:shock 190x50, sag = 10 so length = 180]

diamNut3 = 6.1; // checked
Nut3thk = 2.3;
diamNut4 = 8.1; // checked
Nut4thk = 3.2;

//== Tests ====================
if(test_seat==12)
  projifrender()
    r(90)
      b_seat(6,seat_a,0,0,"");
else if(test_seat==15)
  seatback_plug();
else if(test_seat==16)
  beak_plug();
else if(test_seat==17)
  beak_plug(10,flagdtub, 6);
else if(test_seat==18)
  seatback_plug(seatdi,0,28,5);
else if(test_seat==19)
  r(90) seat_riser();
else if(test_seat==20)
  seat_centersup();
else if(test_seat==21)
  r(0,180)
    seat_centersup(1);
else if(test_seat==22)
  seat_centersup(2);
else if(test_seat==23)
  r(0,90)seat_centersup(3);
else if(test_seat==25)
  r(0,3.5)
  seat_backpush(3.5);
else if(test_seat==27)
  half_collar();
else if(test_seat==28)
  beak_plug(7,16, 8);
else if(test_seat)
  b_seat(test_seat,seat_a,0,seat_f?1000:0, seat_l?"black":"");
//-----------------------------------
if(test_wheel==1)
  wheel(spoke_nbr=spoke_test);
else if(test_wheel==2)
  wheel(hub_offset=10, hubdia=28, spa=10);
else if(test_wheel==3)
  wheel(hub_offset=0, hubdia=28, spa=0, spoke_nbr=28, tire=25);
else if(test_wheel==4)
    wheel(spoke_nbr=0);
else if(test_wheel==5) {
  wheel(hub_offset=0, hubdia=60, spa=10.6, spoke_nbr=32);
  fender(wire_space=110, rear_angle=195, front_angle=75);
}
  
//-- Test viewing wheel --
if(test_fork) {
 caster_angle=12;
 perp_axis_offset=40;
 fwheel_hdia=320;
 steerer_tube_length=200; 
  
  fork(test_fork-1,0,400,fwheel_hdia,caster_angle,perp_axis_offset,100,steerer_tube_length,clrf="dimgray");
}  
//-- Test handlebar --
hdla = test_hdl==5?-110:test_hdl==4?40:test_hdl==1?10:50;
hdl_typ = test_hdl==6?1:test_hdl==5?3:test_hdl-1;
if(test_hdl)
  handlebar(hdl_typ, stem_length=test_hdl==1?90:test_hdl==4?-80:40,stem_ang=test_hdl==4?-15:15, hdl_ang=hdla, hdl_lg=test_hdl==6?80:400, hdl_centbend=test_hdl==5?30:0,hdl_centor=test_hdl==5?60:0);

//== test pannier ============
if(test_pannier)  pannier(test_pannier-1);
//== test shock ============
if(test_shock==1)  shock();

flag_img = "flag_image.dxf";
flag_scale = 3.2;
//---------------------------------
module half_collar (de=seatde) {
  sectorz(-20,200)
    diff() {
      hull() {
        cylz(-de-2-5,9, 0,0,0, 64);
        //cylz(-de-2-6,6);
      } //::::::::::::::::
      r(6)  //????????
        cylz(-de,33, 0,0,0, 64);
      rotz(-21) {
      tore(5,de+5+2.5, 0,300, qual=100); 
        tz(0.3)  
          tore(7,de+5+6.3, 0,300, qual=100); 
      }  
    }  
}
//-----------------------------
module seatback_plug (di=seatdi,gde=flagdtub, de=seatde, lg=35) {
  diff() {
    u() {
      hull() {
        cylx(di,lg-1.5, 0,0,0, 64); 
        cylx(di-1,lg, 0,0,0, 64); 
        tz(-di/2)
          ncube(lg,di/2.4,1, 1,0,1);
      }
      hull() {
        diff() {
          u() {
            cylx(de,-1.5);    
            cylx(de-0.5,-2);    
            cylx(de-2,-2.5);    
          } //:::::::::
          if(!gde)
            ncube(11,44,22, 0,0,-1);
        }  
        ncube(2.5,gde?di/1.75:9.5,di/2, -1,0,-1);
      }
    } //:::::::::::::::::::::::::
    //bottom cut
    t(-10,0,-di/2.2)
      ncube(lg+20,di,10, 1,0,-1);    
    //-----------------
    if(gde)
      hull() t(-7){
        cylx(gde,lg+5);   
        ncube(lg+5,4.4,gde/2+0.2, 1,0,1);
      }  
    dmirrory()
      cylx(1.8,20, -5,di/2-3);
    t(-5,0,-di/2)
      ncube(lg+10,di,10, 1,0,-1);    
    hull() 
      duplz(-25)
        cylx(1.2,lg+10, -5,0,3);
  }
}
//----------------------------
module beak_plug (di=seatdi,detub=seatde, lg=12.5) {
  diff() {
    u() {
      hull() {
        cylx(di,lg-1.5, 0,0,0, 64); 
        cylx(di-1,lg, 0,0,0, 64); 
        tz(-di/2)
          ncube(lg,di/2.4,1, 1,0,1);
      }
      diff() {
        scale([0.7,1,1]) 
          sphere(detub/2, $fn=64);
        ncube (15,30,30, 1,0,0);
      }  
    } //:::::::::::::::::::::::::
    t(-10,0,-di/2.2)
      ncube(lg+20,detub,10, 1,0,-1);    
    hull() 
      duplz(-25)
        cylx(1.5,lg+10, -3,0,2);
    if (di>15)
      hull() t(-4){
        cylx(0.6*detub,lg+15);   
        ncube(lg+10,6,(detub-10)/2, 1,0,1);
      }  
  }
}

//------------------------------
module seat_riser (r1=18,r2=20) {
  wd = 11;
  diff() {
    u() {
      
      ncube(40,wd,seatde, 0,0,0);
      cyly(-seatde-10,wd, 0,0,0, 64);
      
     * tz(-seatde/2-18)
        ncube(42,wd,7, 0,0,1);
    } //::::::::::::::::
    cyly(-seatde,33, 0,0,0, 64);
    ncube(66,33,2, 0,0,0);
    dmirrorx(true,seatde/2+3) {
      cylz(-4.1,99);
      //nutM4 space 
      rotz(30)
      cylz(diamNut4,Nut4thk+0.3,0,0,-seatde/2-18.1, 6);
      dmirrorz(true, seatde/2)
        cylz(8.5,10);
    }
  }  
}
//-------------------------------
module seat_centersup(part=0) {
  wd = 8;
  sp = 50;
  ang = -40;
  cdp = 12;
  ht = 85;
  arti_ht = ht-flagdtub/2-8;
  if(!part||part==1)
    diff() {
      u() {
        dmirrory(true, sp/2)
          hull() {
            cyly(-seatde-7,wd, 0,0,2);
            ncube(8,wd,seatde/2+8, 0,0,1);
          } 
        ncube(6,sp,seatde/2+8, 0,0,1);
      }//:::::::::::   
      cyly(-seatde+1,99, 0,0,0, 48);
      hull() {
        ncube(1,sp+33,33, 0,0,-1);
        dmirrorx(true, 20)  
        tz(-9)
          ncube(1,sp+33,33, 0,0,-1);
      }
      dmirrory(true, sp/2)  
        cylz(2.3,22);
    }  
  if(!part||part==2)   
  t(-2,0,ht)
    diff() {
      u() {
        hull() {
          cylx(-flagdtub-6,cdp+5);
          ncube(cdp,12,12, 0,0,-1);
        }  
        dmirrorx()
          r(0,ang)
            cylz(7,-8, 0,0,-5);
        tz(-8)
          ncube(cdp+0.8,14,11.5, 0,0,-1);
      }//:::::::::::   
      //set screw
      dmirrorx()
        r(0,ang)
          cylz(-2.3,33, 0,0,-5);
      
      //plate space
      hull() 
        duplz(-30,1,arti_ht-ht)
          cyly(-cdp-1,6);
      tz(arti_ht-ht)
        ncube(33,6,5.6, 0,0,0);
      //Attach screw holes
      tz(arti_ht-ht)
        cyly(-4,66);
      //Tube space
      t(-6) {
        cylx(-flagdtub+0.5,99, 0,0,0, 24);
        hull() {
          ncube(33,1,33, 0,0,1);
          dmirrory(true, 20)  
          tz(9)
            ncube(33,1,33, 0,0,1);
        }  
      }
    }
  if(!part||part==3) {
    diff() {
      u() {
        tz(seatde/2+8) {
          ncube(8,sp+wd,4, 0,0,1);
          hull() {
            ncube(8,sp-7,4, 0,0,1); 
            t(1.5)
              ncube(5,sp-15,10, 0,0,1); 
          }
          hull() 
            t(1.5) {
              ncube(5,sp-15,10, 0,0,1); 
              tz(ht-45)
                ncube(5,6,4, 0,0,-1); 
            }  
        }     
        hull() {  
          tz(seatde/2+12) 
            ncube(8,6,1, 0,0,1); 
          tz(ht-11.5) 
            ncube(8,6,1, 0,0,-1); 
          cyly(-cdp,6, -cdp/2+4,0,arti_ht);
        }  
      } //:::::::::::  
      //Attach screw holes
      cyly(-4,66, -2,0,arti_ht);
      dmirrory(true, sp/2)  
        cylz(3.5,44);
    }  
  }     
}
//-------------------------------
module seat_backpush(ang = 3.5) {
  ul = 15.6;
  ui = 12.4;
  diff() {
    u() {  
      hull() {
        t(5) 
        ncube(3,20,20, 1,0,0);  
          ncube(seatde/2+4,20,ul+3, 1,0,0);  
      }  
      ncube(40,ui,ui, 1,0,0);  
      ncube(40,ui,ui, 1,0,-1);
    } //:::::::::::: 
    cyly(-seatde,10.2, 0,0,0,48);
    dmirrory() hull() {
       cyly(seatde,1, 0,5,0, 48);
       cyly(seatde*1.2,-1, 0,15,0,48);
    }
    //u 
    t(seatde/2+3) {
      diff() {
        ncube(44,ul,ul, 1,0,0);  
        t(-1) {
          ncube(44,ui,ui, 1,0,0);  
          ncube(44,ui,ui, 1,0,-1);  
        }  
      }  
    }
    t(40.1,0,-ul/2) 
      r(0,-ang)
        ncube (99,33,33, -1,0,-1);
    duplx(12,1,23)
      cylz(-4,33);  
  }  
}
//=============================================
function tire_diam (rim=559, tire=40) = rim+2*tire+4;
//-- Spoked wheel --------------
//add parameter to simulate single and double spoke crossing for small wheels
module wheel (rim=559, tire=40, hubdia=60, hubwidth=60, spa=7.5, spoke_nbr=36, shaft_width = 140, clr_rim= "darkgray", clr_tire="dimgray", hub_offset=0) {
	wh_d=rim+2*tire+4; 
	spd = 2.2; // spoke diameter
  spf = 6; // spokes faces number (for fast rendering)
	spr = hubdia/2+5; // spoke radius
	spoke_ang = 4*360/spoke_nbr;
  radial = (spa==0) || (spoke_nbr<20);
	check() tubey(-(rim-65),0.5,78, 0,0,0,48); //???
	scolor(clr_tire) //Tire
		r(90)
			rotate_extrude(convexity = 10, $fn=48) 
				t(wh_d/2-tire/2, 0, 0) 
					circle(r = tire/2, $fn=24); 
	//-- Rim --
	scolor(clr_rim) {
    tubey(-(wh_d-tire*2+10),17.5,0.6*tire, 0,0,0, 48); //rim
		cyly(-9,shaft_width); // shaft
    if(spoke_nbr) { // wheel with spokes
      cyly(-hubdia,hubwidth, 0,hub_offset); 	//hub
      t(0,hub_offset)  //hub flanges
        if(spoke_nbr>=20)  
          dmirrory()
            cyly(hubdia+20,-3, 0,hubwidth/2);
      //-- Spokes --
      lgspoke = rim/2-(spa?10:hubdia/2+15);
      spangle  = atan((hubwidth/2+2+hub_offset)/lgspoke);
      spangle2 = atan((hubwidth/2-5+hub_offset)/lgspoke);
      spangle3 = atan((hubwidth/2+2-hub_offset)/lgspoke);
      spangle4 = atan((hubwidth/2-5-hub_offset)/lgspoke);
      t(0,hub_offset)
        if(!radial)
          droty(spoke_ang,spoke_nbr/4-1) {
           // one side 
            r(0,-spa) rotz(-spangle)
              cylx(spd, lgspoke, 0,hubwidth/2+1,spr,spf);
            r(0,spa+30) rotz(-spangle2)
              cylx(spd, lgspoke, 0,hubwidth/2-5,-spr,spf);
            // other side
            r(0,360/spoke_nbr) {
              r(0,-spa) rotz(spangle3)
                cylx(spd, lgspoke, 0,-hubwidth/2-1,spr,spf);
              r(0,spa+30) rotz(spangle4)
                cylx(spd, lgspoke, 0,-hubwidth/2+5,-spr,spf);
            }
          }
        else // Radial spokes
          if(spoke_nbr>=20)
            droty(spoke_ang*0.5,spoke_nbr/2-1){
              t(0,hubwidth/2+1,spr)
                rot(spangle)
                  cylz(spd, lgspoke, 0,0,0, spf);
              r(0,360/spoke_nbr)
                t(0,-hubwidth/2-1,spr)
                  rot(-spangle)
                    cylz(spd, lgspoke, 0,0,0, spf);
            }
          else // Large radial spokes (not wire)
            droty(spoke_ang*0.25,spoke_nbr-1)
              hull() {
                cylz(45,0.01);
                scale([1,0.3,1])
                  cylz(60*pow(0.9,spoke_nbr),0.01, 0,0,lgspoke+spr);
              }
    }
    else // No spoke gives plain wheel
      hull() {
        cyly(-hubdia-35,hubwidth+12, 0,hub_offset,0, 48);
        cyly(-rim-30,35, 0,0,0, 48);
      }
	} //scolor
} //-- wheel --

//- Fenders / Mudguards ------
//if front_angle = 0, no mudguard
//angle 0 = horizontal
//w_width is width of attach point of wire supports, if 0, there is no support, which is located on rear, at 8 deg from start
module fender (wheel_rim = 559, tire_w = 47, front_angle=8, rear_angle=170, wire_space=110, clr_fender="black") {
	fender_dia = tire_w+26;
	angtot = rear_angle-front_angle;
	//becho("fender angtot",angtot);
	wheel_dia = tire_diam(wheel_rim, tire_w);
	if(front_angle!=0) {
		scolor(clr_fender)
			r(90, -front_angle)
				rotate_extrude(angle=angtot, convexity = 10, $fn=48)
					diff() {
						t(wheel_rim/2+tire_w/2)
							circle(r=fender_dia/2, $fn=48);
						//::::::::::
						t(wheel_rim/2+tire_w/2) 
              circle(r=(fender_dia/2-1), $fn=16); 
						square([wheel_rim+tire_w,100], center=true);
						//side cut, width 10mm more than tire
						dmirrory() 
							t(0,tire_w/2+5)
								square([wheel_rim+tire_w+100,100]);
					}
	  // wire supports
		supy = wire_space/2;
		ags = -atan((supy-tire_w/2-3)/(wheel_dia/2-20));
		if(wire_space) 
			silver() 
				r(0,-rear_angle+20)
					dmirrory()
						t(15,supy,-4)
							rotz(ags)
								cylx(4,wheel_dia/2-16, 0,0,0, 6);
	}
} //fender 
//------------------------------
module seat_light (x=-70,z=515,s_ang, light_color, vert_ext = 80) {
  if(light_color)
  mirrorx()
	t(x,0,z+42) {
		if(light_color) 
		t(-75)
			r(0,79-s_ang) t(-10,0,vert_ext){
				rear_light(light_color);
				dmirrory() 
					silver()
						cubez(3,15,-20-vert_ext, 10,25,20);
			}
	}
}

/*/-- seat tests
b_seat(1);
b_seat(2);
b_seat(3);
*projection()	r(90) b_seat(2,55,0,false,"");
cyly (-50,380,350,0,400); // width test
//*/

//== Rans recumbent back mesh seat ==
module rans_seat (s_ang=45, fold=0, width=400, sflag=true, light_color="black"){
	//Width at base, top of seat have less width than the base (~ 30mm)
	prec = 12;
	dt = 22; // frame tube diameter, thickness is 2.03 mm
	//cubez (500,500,1,0,0,700); 
	//check height
	cx=-6; cz=112; // rotation centre at hip
  //---------------------------
  t(cx,0,cz) {
    //cyly(-5,600);
    //nominal width of 380 will give bottom width of 400 
    mirrorx()
    r(0,s_ang) 
    t(cz,0,-cx)
    t(30,0,10) r(0,-79) {
      scale ([1,width/400,1]) {
        black()
          hull() {
            cylz (20,1, 85,0,0, prec);
            cylz (30,1, 85,0,-10, prec);
            dmirrory()
              cylz (20,10, 0,28,0, prec);
          }
      t(-174,0,155) {
        red()
          cyly(-3,420, 0,0,0, prec);
        r(0,-fold) {
          mirrorx()
          seat_light(-60,455,s_ang,light_color, 60);
          //flag
          if(sflag) t(-110,-175,540) 
            r(0,50-s_ang) flag();
          // width check
          //cyly(-20,372,-106,0,535, 6);
          //cyly(-20,400,10,0,-40, 4);
        }
      }
      gray()
        dmirrory() 
          tb_yx(dt,-75,48, prec)
          cyly(dt,84, 0,0,0, prec)
          r(0,-90)
          tb_yx(dt,75,45, prec)
          cyly(dt,57.6, 0,0,0,prec) {
            r(28,26)
              cylz(15,150, 0,0,0, prec)
              tb_zx(15,250,6, prec);
            tb_yx(dt,75,45, prec)
            cyly(dt,40, 0,0,0, prec)
            r(0,41.8)
            rotz(fold) r(1.5){
              //back
              cyly(dt,40, 0,0,0, prec) {
                tb_yx(dt,-500,20, prec)
                cyly(dt,30, 0,0,0, prec)
                tb_yx(dt,500,3, prec) {
                  //medium transversal bar
                  r(-5,69.5) 
                  t(0,0,-4)
                  tb_xz(12,500,21.6, prec);
                  tb_yx(dt,500,17, prec)
                  cyly(dt,30, 0,0,0, prec)
                  tb_yx(dt,-120,30, prec)
                  cyly(dt,20, 0,0,0, prec){
                    cyly(dt,20, 0,0,0, prec);
                    //top transversal bar
                    r(-5,70) 
                    t(0,0,-4)
                    tb_xz(12,500,20.9, prec);
                  };
                }
              }
            }
          }
      }
    }
  }
}
//== ICE recumbent mesh seat ============================
//ICE frame designed from photo, so accuracy may be limited
//From the mesh I bought height is excessive by ~  25 mm
module ICE_seat (seat_angle=45,width=380, sflag=true, light_color="black") {
	prec= 12;
	dt = 25.4;
	wd = width-dt;
  //----------------------------
	module cxl (d,l) {
		cylx (d,l,0,0,0,prec)
			children();
	}
  //----------------------------
	module transv (dx=0) {
		t(dx)
		//render()
			r(45)
				cyly(dt+1,-60, 0,0,0, prec)
					tb_yz(dt,-50,-45, prec)
						//t(0,0.1) // stop CGAL error
						cyly(dt,-wd/2+50, 0,0,0, prec) 
							children();
	} 
  //----------------------------
	cx=-6; //cx, cz rotation center coord
	cz=112;
	t(cx,0,cz) {
		//red()cyly(-5,600);
		r(0,-seat_angle+52.8,0)
			t(-cx,0,-cz) {
			//-- rear light ----------
			seat_light(-370,375,seat_angle+26,light_color, 60);
			//-- seat ----------------
			scolor("gray")
			mirrorx() 
				//render()
			dmirrory() 
				t(185,wd/2,10)
				r(0,24)
				tb_xz(dt,-200,40, prec)
				cxl(dt,-50){
					transv(15);
					//back bend
					tb_xz(dt,100,78, prec)
					cxl(dt,-100){
						transv(65);
						tb_xz(dt,-200,14, prec)
						cxl(dt,-190){
							transv(60);
							tb_xz(dt,200,20, prec)
							cxl(dt,-150)
							transv(80);
						}
					}
				}
			//flag
		if(sflag) t(410,-wd/2,525)
			r(0,-25+seat_angle,0) rotz(180) flag();
		} //r, t
	} // -t
}

//== DIY recumbent mesh seat ===
//Back foldable frame designed to use ICE mesh, but the seat support is different due to the possibility to fold the back Bending radiuses of common manual bender D25: 110, D22: 110, D19/20: 90
//-- Developped length of a bend --
function blg (bend_rad,ang) = round(PI*bend_rad*ang/180);

module DIY_seat (seat_angle=45,width=380, sflag=true, light_color="black", fold=0, flat = false,beak=false) {
  //fold contain the folding value
  //flat does set seat part on flat
	prec= 12;
  //Tube diameter
	tubed = 20;
	wd = width-tubed;
  //Articulation bracket thickness
  arti_thk = 1.5;
  //Junction bracket thickness
  junc_thk = 1.2;
  //Articulation params
  arti_xoffset = 2;
  // arti_xoffset = 0;
  arti_zoffset = 16;
  arti_wd = 40; // articulation plate length
  //Transversal beams params
  transv_rad = 110; // bending radius
  transv_ang=30;
  transv_lg=40;
  transv_ang1=35;
  transv_lg1=40;
  transv_so1 = beak?4.5:0;
  transv_ang2=45;
  transv_lg2=40;
  transv_so2 = beak?11:0;
  //Seat bending radius (back and bottom)
  seat_rad = 110; // use a shape radius 100
  //bottom params
  beak_ang = beak?45:0; 
  //bot_lg = beak?145:159;
  bot_lg = beak?159:159;
  bot_lgb = beak?30:40; 
  bot_ang = beak?60:32;
  //back params
  //seat_rad = 110; // bending radius
  back_lg = 170; // first section length
  back_ang = 14;
  back_lg2 = 215;
  back_ang2 = 20;
  back_lg3 = 150;
  module cxl (d,l) {
		cylx (d,l,0,0,0,prec)
			children();
	}
  //-- flattened articulation plate --
  module arti_flat (beak=false, arti_wd=50) {
    rdex = (tubed+arti_thk)*PI/4;
    rotz(90)
      diff() {
        hull() {
          cubex(arti_wd,arti_thk,rdex*2);
          dmirrorz()
            cyly(-12,arti_thk,arti_wd-6,0,rdex);    
          cyly(-18,arti_thk,
            arti_xoffset,0,arti_zoffset+rdex);  
          cyly(-18,arti_thk,
            arti_xoffset-(beak?6:0),0,-arti_zoffset-rdex);    
        } //:::::::::::::::::::::::
        //hole
        cyly(-1,44,
            arti_xoffset,0,arti_zoffset+rdex);
        //No second hole (drill direct due to angle)
        *cyly(-1,44,
             arti_xoffset-(beak?6:0),0,-arti_zoffset-rdex);      
        hull() {
          cubex(-20,10,rdex*2);
          cyly(-5,10,
              -11,0,arti_zoffset+rdex);
          cyly(-5,10,
              -11-(beak?7:0),0,-arti_zoffset-rdex);    
        }  
        t(10)
        r(0,-90,-90)
        tz(-5)
          linear_extrude(9) 
            text(str("thk: ",arti_thk),8, halign="center");  
      } //diff
  }
  //-- Symetrical junction plate, flattened --
  module sym_plate (lg=50, thk=arti_thk) {
    rdex = (tubed+junc_thk)*PI/4;
    diff() {
      hull() {
        cubex(thk,lg,rdex*2);
        dmirrorz()  
          cylx(16,thk, 0,0,rdex+32+(lg==50?4:0));
      } //:::::::::::::::::
      r(0,-90)
       tz(-5)
          linear_extrude(9) 
            text(str("thk: ",thk),8, halign="center");  
    }  
  }
  //-- Asymetrical junction plate ----
  module asym_plate (thk=arti_thk) {
    lg=50;
    rdex = (tubed+thk)*PI/4;
    diff() {
      hull() {
        cubex(thk,lg,rdex*2);
        t(0,lg/2-12.5)
          dmirrorz() dmirrory() 
            cylx(16,thk, 0,0,rdex+40);
        dmirrorz()
          cylx(12,thk, 0,-lg/2+6,rdex); 
      }//:::::::::::::::::
      r(0,-90)
        tz(-5)
          linear_extrude(9) 
            text(str("thk: ",arti_thk),8, halign="center");  
    }  
  }
  //-------------------------------
  module arti (dx=0) {
    t(dx) diff() {
      hull() {
        diff() { // half cylinder
          cylx(tubed+2*arti_thk,arti_wd);
          //::::::::::
          cylx(tubed,arti_wd+10,-5);
          cubex(arti_wd+5,30,30, -5,0,15);
        }  
        //articulation
        cyly(-18,tubed+2*arti_thk,
            arti_xoffset,0,arti_zoffset);
        cyly(-1,tubed+2*arti_thk, arti_wd,0,6);
      } //:::::::::
      cyly(-6,99,
          arti_xoffset,0,arti_zoffset);
      hull()duplz(50)
        cylx(tubed,99, -22);
    }
  }
  //---------------------------------
  function transclg(lg,a) = round(2*(wd/2-lg*cos(a)-transv_rad*sin(a)));
  //---------------------------------
  module transv (dx=0, straight = transv_lg, tang=transv_ang) {
		t(dx) // position along the frame
		//render()
			r(tang)
				cyly(tubed+1,-straight, 0,0,0, prec)
					tb_yz(tubed,-transv_rad,-tang, prec)
						//t(0,0.1) // stop CGAL error
						cyly(tubed+1,-wd/2+40+straight, 0,0,0, prec) 
							children();
	}
  //-------------------------------- 
  if(test_seat && !flat && Disp_ICE)
  t(-1) red() ICE_seat(seat_angle,width, false,""); 
	cx=-6; //cx, cz rotation center coord
	cz=112;
	t(cx,0,cz) {
		//red()cyly(-5,600);
		r(0,-seat_angle+52.8,0)
			t(-cx,0,-cz) {
			//-- rear light -------
      if(!flat)
        seat_light(-370,375,seat_angle+26,light_color, 60);
			//-- seat -------------
			scolor("gray")
			mirrorx() 
			//render()
			dmirrory(!flat) 
				t(185,0,10)	r(0,24) {
        //bottom
        t(-222.5,flat?0:wd/2,-121.5){
          r(0,-37){ 
          rotz((beak&&!flat)?-5:0)  
            r(flat?0:-beak_ang)
          cxl(tubed,bot_lg)
          tb_xz(tubed,-seat_rad,-bot_ang, prec)   cxl(tubed,bot_lgb);
          if(!flat) {
            arti();
            //Rear transversal
            t(0,-transv_so1) 
            transv(54, transv_lg1,transv_ang1);    
            //Front transversal
            t(0,-transv_so2,beak?1:0) 
              transv(150, transv_lg2,transv_ang2);
          }  
        }
        //back
        rback = 0; // rotate back tube to have thinner back on top. Not with ICE mesh
        backtube_lg = back_lg+back_lg2+back_lg3+PI*seat_rad*(back_ang+back_ang2)/180;
        echo (str("Back tube length: ",round(backtube_lg)));
        //----------------
        r(0,-37)
        t(arti_xoffset, 0,arti_zoffset) r(0,38+37+fold){
          if(!flat) cyly(-2,66);  
          t(arti_xoffset, 0,-arti_zoffset) { 
            if(!flat) mirrorx() arti();  
            r(-rback)  
            cxl(tubed,-back_lg){
              if(!flat)
                r(rback) transv(75);
              tb_xz(tubed,-seat_rad,back_ang, prec)
                cxl(tubed,-back_lg2){
                  if(!flat) 
                    r(rback) transv(75);
                  tb_xz(tubed,seat_rad,back_ang2, prec)
                  cxl(tubed,-back_lg3)
                  if(!flat) 
                    r(rback) transv(80);
                }
            }
          } 
        }
      }  
      } // r(0,24)
			//flag
		if(sflag&&!flat) t(410,-wd/2,525)
			r(0,-25+seat_angle,0) rotz(180) flag();
		} //r, t
    if(flat) {
      rotz(90) dmirrory() t(0,wd/2) {
        t(0,-transv_so1,25)
          diff() { //rear bottom transversal
            transv(0,transv_lg1, transv_ang1);
            //:::::
            cylx(-tubed,99);
          }  
        t(0,-transv_so2,102) 
          diff() { //front bottom transversal
            transv(0,transv_lg2, transv_ang2);
            //:::::::::::  
            cylx(-tubed,99);
          }  
        //Back transversal
        tz(150) diff() {
          transv();
          cylx(-tubed,99);
        }  
      }
      //== Plates ===============
      rotz(90)
      tz(240) {
        t(0,120) {
          dmirrorz() 
            t(0,0,-71) r(90)
              arti_flat();  
          dmirrory() 
            t(0,-71)
              arti_flat(beak,45);
        }      
        t(0,16)
          sym_plate(50,arti_thk);
        duply(-44,1,-33)
          sym_plate(40,junc_thk);  
        duply(-54,1,-126)
          asym_plate();
      }
      //Seat type text 
      t(-105,0,-50) r(90) 
        txa((beak?"Seat with pointy bottom - bike":"Seat with parallel bottom beams - trike"),8);
      //Bottom beam text
      t(-110,0,-150) r(90) 
      txa(str("d:",tubed," end lg=", bot_lgb, " angle=",bot_ang,"° bend lg:",blg(seat_rad,bot_ang)," start lg:", bot_lg," t length:",bot_lgb+bot_lg+blg(seat_rad,bot_ang)),7);
      //back beam
      t(-510,0,-95) r(90) 
      txa(str("end lg=", back_lg3, "  angle 2=",back_ang2,"° bend lg:",blg(seat_rad,back_ang2)," mid lg=", back_lg2, " angle=",back_ang,"° bend lg:",blg(seat_rad,back_ang)," start lg=", back_lg," t length=",back_lg+back_lg2+back_lg3+blg(seat_rad,back_ang+back_ang2)),7);
    //bottom rear transversal beam    
      tz(12) r(90) {
        txa(str("end lg=", transv_lg1, "  angle=",transv_ang1,"° bend lg:",blg(transv_rad,transv_ang1)," cent lg=",transclg(transv_lg1,transv_ang1)-transv_so1*2," t length:",blg(transv_rad,transv_ang1*2)+2*transv_lg1+transclg(transv_lg1,transv_ang1)-transv_so1*2),7,"center");
        t(0,-12)
          txa("Rear bottom transv. beam",8,"center");
     }  
  //bottom front transversal beam    
      tz(85) r(90) {
        txa(str("end lg=", transv_lg2, "  angle=",transv_ang2,"° bend lg:",blg(transv_rad,transv_ang2)," cent lg=",transclg(transv_lg2,transv_ang2)-transv_so2*2," t length:",blg(transv_rad,transv_ang2*2)+2*transv_lg2+transclg(transv_lg2,transv_ang2)-transv_so2*2),7,"center");
        t(0,-20)
          txa("Front bottom transv. beam",8,"center");
      }  
   //Back transversal beam    
      tz(150) r(90) {
        txa(str("d:",tubed," end lg=", transv_lg, "  angle=",transv_ang,"° bend lg:",blg(transv_rad,transv_ang)," cent lg=",transclg(transv_lg,transv_ang)," t length:",blg(transv_rad,transv_ang*2)+2*transv_lg+transclg(transv_lg,transv_ang)),7,"center");   
        t(0,-15)
        txa("Back transv. beam",8,"center");
      }
    }
	} // -t
}
//---------------------------
module hardshell_seat (seat_angle=45,wd=300, sflag=true, light_color="black", thk = 16) {
	$wd = wd;
	$prec=64;
	reinf_dist = 80;
	
	module shape (wd=$wd,mirr=true) {
    u() {
      hull() {
        dmirrory(mirr)
          t(0,wd/2-thk/2)
            circle (d=thk, $fn=12);
        if(!mirr)
          square([thk,thk],center=true);
      }
      dmirrory(mirr)
        hull() {
          t(25,reinf_dist)
            circle (d=25, $fn=12);
          t(5,reinf_dist)
            square ([25,25],center=true);
        }
    }  
	}
  //-----------------------	
	module rshp (radius=100,ang=90, wd=$wd,mirr=true) {
		sang = radius<0?ang:-ang;
		dx = (1-cos(sang))*radius;
		dy = sin(sang)*-radius;
		t(radius)
			rotate_extrude(angle=sang, $fn=$prec, convexity=4)
				t(-radius,0,0)
					shape(wd,mirr);
		t(dx,dy-0.1) 
      rotz(sang) 
        mirrorz()children();
	}
	
	module srt (a=-25,wd=$wd) {
		diff() {
      tz(-sign(a)*wd/2)
        r(a)
          tz(sign(a)*wd/2)
            children();
			//::::::::::::
			cubey(99,-199,999);
			cubez(99,399,sign(a)*399, 0,99);
		}
	}
	//Convexity 4 required to eliminate viewing artifacts
	module tshp (lg,wd=$wd,mirr=true) {
		r(-90) 
      linear_extrude(height=lg,center=false, convexity=4)
        shape(wd,mirr);
		t(0,lg-0.1)
			children();
	}
//------------------	
	cx=-6; cz=112; // rotation centre at hip
//---------------------------
 t(cx,0,cz) {
	//red() cyly(-5,600);

  r(0,-seat_angle+60)
  t(-cx,0,-cz)
  t(-130,0,-10) {
    //-- rear light ---------
    seat_light(-415,540,seat_angle+19,light_color, 25);
    //-- flag ----
    if(sflag) 
      mirrorx()
        t(-492,-97,590) 
          r(0,-seat_angle+32) flag();  
    // shell
    gray()
    r(90,90)
      rotz(32+5) diff() {
        rshp(100,40)
        tshp(55)
        rshp(-150,70)
        tshp(100)
        rshp(200,14)
        tshp(100) 
        rshp(-400,42)
        ;
        //:::::::::::
        //headrest cut
        dmirrorz()  
          t(-200,680,100)
            rotz(60)
              r(-21)
                cubez(199,399,399);
      //Base nose cut 
        dmirrorz() 
          t(40,60,90)
            rotz(-30)
              r(40)
              cubez(88,255,99, 0);
      }
	}
 }
}

//-- Utilities ------------------
module projifrender () {
  if($preview) children();
  else projection() r(-90) children();
}
//Extrude (for projected text in particular)
module lex (h=1) {
  linear_extrude(h) children();
}  

//---------------------------
module b_seat (type=2,s_ang=55,fold=0, sflag=1000, light_color="black", wd=380){
	if(type==1) //rans mesh
		rans_seat(s_ang, fold, wd, sflag, light_color); 
	else if(type==2) //ICE mesh
		ICE_seat(s_ang, wd, sflag, light_color); 
	else if(type==3) //Hard shell
		hardshell_seat(s_ang, 300, sflag,light_color); 
  else if(type==4) //DIY mesh seat
		DIY_seat(s_ang, wd, sflag,light_color, fold); 
  else if(type==5) //DIY mesh seat
		DIY_seat(s_ang, wd, sflag,light_color, 110); 
  else if(type==6) //DIY mesh seat with beak
		DIY_seat(s_ang, wd, sflag,light_color, fold, false, true); 
  else if(type==7) //DIY seat parts
    projifrender()
      DIY_seat(65.8, wd, sflag,light_color, 105, true, false); 
  else if(type==8) //DIY seat with beak parts 
    projifrender()
      DIY_seat(65.8, wd, sflag,light_color, 105, true, true); 
	else if (type==9) //saddle
    tz(15)
		mirrorx()
			saddle("saddlebrown", light_color);
}
//== Saddle =================
module saddle(seat_color="saddlebrown", light_color="black") {
	scolor(seat_color)
		hull() {
			dmirrory() 
				t(-80,60)
					sphere (r=25, $fn=24);
			t(115,0,3)
				sphere (r=20, $fn=24);	
		}
	if(light_color)
		t(-100,0,-60) {
			rear_light(light_color);
			black()
				dmirrory() {
					cubez(2.5,15,25, 9,25,10);
					cubex(20,15,2.5, 9,25,34);
				}
		}
}

//-----------------------------
module flag (lg=1000, imgfile=flag_img, imgscale=flag_scale, fclr = ["orangered","lime"]) {

	module imp_img(imgfile) {
		linear_extrude(height=2, center=true)
		import(file=imgfile);
	}
	//pole
	silver() {
		cyly(-22,10, 0,0,0, 12);
		cylz(6,lg, 0,0,0, 6);
	}
	//flag
	t(12,0,lg){
		scolor(fclr[0]) 
			hull() {
				cylz(2,-160, -12,0,0,4);
				cylz(2,2, -250,0,0, 4);
			}
	//Image set on flag
		t(-108,2, -88)
		r(90) scolor(fclr) 
			scale([imgscale,imgscale,1]) {
				imp_img(imgfile);
				t(0,0,4)
					imp_img(imgfile);
			}
	}
}

//== SHOCK  with eyes ===========
//Dist = length eye to eye without compression, travel = compression travel, sag = compression at nominal load {~20% of travel)
module shock (dist = 190, travel=50, sag=10) {
	gray() {
		duplx(dist-sag) {
			diff() {
				u(){
					cyly(-23,14);
					cyly(-18,24);
				}//::::::::::
				cyly(-8,99);
			}
			cyly(-8,55);
		}
		cylx(15,dist-sag-16, 8);
		cylx(28,dist-sag-30, 15);
		cylx(48,20, 20);
		cylx(47,dist*0.5, 18);
	}
}

//== FORK ======================
//Fork parameters:style= fork type, stro = steering rotation angle, flg = perpendicular distance between bearing bottom and wheel axis, casta = caster_angle, pao = perpendicular axis offset, fwhd = wheel hald diameter, stl= steerer tube length, stb = steering bottom bearing height space, htb = header tube height, clrf= fork color

module fork (style=0, stro=0, flg=380, fwhd=325,  casta=18, pao=47, OLD=100, stl = 180, stb=5, htb=115, clrf = "black") {
  steerdia = 28.6;
	rad = 125; //dropout bend radius
  toprad = 100; //top bend radius
	//pao = perp_axis_offset;
	sgn = sign(pao);
	fang = acos((rad-abs(pao))/rad);
	//fwhd = fwheel_hdia;
  //move to wheel center and tilt of caster_angle value 
	t(0,0,fwhd) 
		r(0,casta)
			t(pao) rotz(stro) t(-pao){
        if (style==3) //User programmed fork 
          user_fork1(); 
        else if (style==2) //Experimental lefty
          xlefty();
        else if (style==1) //suspended fork 
          stsusp();
        else
          st();
        //steerer tube
        gray()
          cylz(steerdia,stl, pao,0,flg);
      }  
  //rigid fork - bent dropout style
  module st () {
    lgstr = flg-88-rad*sin(fang);
    hhang = atan((8+OLD/2-50)/lgstr);
    scolor(clrf)
    mirrorx(pao<0)
      dmirrory() {
        t(0,OLD/2+4,0)
          diff() {
            r(hhang)
              r(0,fang-90) 
                tb_xz(24,rad,-fang)
                  cylx(24,lgstr)
                    tb_xy(24,-toprad,-60);
            //:::::::::::::
            cyly(-24,66);
          } 
        cyly(-32,8, 0,OLD/2+4);  
      }     
    scolor(clrf)
      cylz(steerdia+5,-40, pao,0,flg);
  }
  //suspended fork
  module stsusp () {
    tubsp = 106;
    tubdia = 28;
    postube = pao-sign(pao)*20;
    dmirrory() {
      scolor(clrf) {
        cylz(tubdia+15,250, postube,tubsp/2,5);
        hull() {
          cylz(steerdia+15,-40, pao,0,flg);
          cylz(tubdia+12,-40, postube,tubsp/2,flg-20);
        }
        hull() {
          cyly(-32,8, 0,OLD/2+4);  
          cylz (12,50, postube,tubsp/2,5); 
        }  
      }  
      silver()
        cylz(tubdia,flg-60, postube,tubsp/2,20);
    }
  }
  // Experimental 'lefty' fork
  module xlefty (sideoff=-60, shock_ang=-38) {
    //stb = steer_bbht==undef?5:steer_bbht;
    //htb = head_tube_height==undef?stl-50:head_tube_height;
    harm_ang = 15; // articulated arm angle from horizontal
    hang = -casta+harm_ang;
    bang=32;  
    armlg = -220; // axis to axis arm length
    sa = sign(armlg);
    vrad = 200;
    vdia=50;
    // first length segment calc
    xar = armlg*cos(hang);
    xb=(1-cos(bang))*vrad*sa;
    stlg = (xar-xb-pao)/sin(bang);
    //top segment
    yar = armlg*sin(hang);
    yb = sin(bang)*vrad;
    vlgb = flg+yar-yb-sa*stlg*cos(bang);
    vlg = vlgb+2*stb+htb+20;
    //Attach to pivot
    module side_plate () {
      hull() {
        cylz(vdia+12,-8, pao);
        cylz(40,-8, pao,-sideoff);
      }
    }
    
    //Bottom tube segment
    silver() 
      cylz(28.6,-10, pao,0,flg-8);
    // fork
    t(0, sideoff) {
      scolor(clrf) {
        cyly(-18,60);  
        r(0,hang) {
          //arm
          cylx(50,armlg+sa*40,-sa*20)
          cyly(-18,60,-sa*20);
          //support tube
          t(armlg) {
            diff() {  
              r(0,-sa*bang-hang-90)
                cylx(vdia,sa*stlg-30,30)
                tb_xz(vdia,-sa*vrad,-bang)
                cylx(vdia,vlg)
              ;
             //::::::::::::::: 
              r(0,sa*15)
                cylx(-80,166);
            }
            //arm axis fork
            mirrorx (sa<0)
            hull() {
              cyly(-30,80);
              r(0,15)
              diff() {
                cylx(-80,87, -35);
                //::::::::::::
                cubez(222,111,-111, 0,0,10);
                r(0,40)
                  cubez(222,111,-111, 0,0,-20);
                cylx(-70,222);
              }  
            }
          }
        } 
      } 
      //shafts
      gray() { 
        cyly(-14,70);  
        r(0,hang)
        cyly(-14,90, armlg);
      }  
      // Attach plates 
      scolor(clrf) {
        tz(flg)
          side_plate();
        tz(flg+2*stb+htb)
          mirrorz()
            side_plate();
      }
      //shock
      r(0,hang)
        t(armlg*0.6,0,40) {
          r(0,-90+sa*harm_ang+sa*shock_ang) {
            shock(190,50,15);
            scolor(clrf)
            mirrorz(sa<0)
              dmirrory() 
                t(190-15)
                  hull() {
                    cyly(28,5, 0,12);
                    cubey(60,5,1, 16,12,-45);
                  }
          }  
        scolor(clrf)
          dmirrory() 
            hull() {
              cyly(28,5, 0,12);
              cubey(60,5,1, 0,12,-30);
            }
      }  
    } // sideoff
  } //xlefty
} //fork

//== Handlebar =================
module handlebar (hdl_type=0, stem_length=40,stem_height=40,stem_ang=15,hdl_ang=60,hdl_lg=400,hdl_bend=37.5, hdl_width_central_extent=0,
hdl_centbend=0,hdl_centor=0,hdl_lg2=200, dcheck=false, d_line=1) {
	//sgo = sign(stem_length);
  sgo = stem_length>0?1:-1;
	//stem_ang = OSS_handlebar?20:0;
	sto = sign(stem_height)*27; // stem shaft axis offset
	//depending its length 'cruiser' handlebar go from chopper type to near flat mountain bike bar through town type.
		crui_a = hdl_lg>150?90:20+(hdl_lg-50)*0.70;
	if (dcheck)
		red()
			cubez(d_line,666,555);
	silver() {
		//stem pivot shaft
		cylz(25,-stem_height-sto, 0,0,sto);
		cylz(-36,40);
		r(0,-stem_ang) {
			//stem
			cylx(32,sgo*(abs(stem_length)+40),-sgo*20);
			//handlebar
			t(stem_length)
				r(0,hdl_ang+stem_ang)
					dmirrory() 
						if(hdl_type==0){ //trike direct
							cylz(22,10)
							cylz(30,120);
						}
						else if(hdl_type==1){ //cruiser
							cyly(22,40)
							tb_yz(22,-70,crui_a)
							r(0,-20)
							cyly(22,abs(hdl_lg-140))
							tb_yz(22,70,crui_a)
							cyly(22,10)
							cyly(32,120);
						}
						else if(hdl_type==2) { // Hamster
							cylz(22,hdl_lg)
							tb_yx(22,80,18)
							cyly(22,40)
							cyly(30,120);
						}
						else if(hdl_type==3) { //U Bar
						// if handlebar length = 420, this is a metabike Ubar
              centpart = hdl_width_central_extent>0||hdl_centbend; // if true, central bent part
              cyly(25,30)
              cyly(25,hdl_width_central_extent/2)
              r(0,hdl_centor)
							tb_yx(25,50,hdl_centbend/2)
              r(0,-hdl_centor)
              cyly(25,centpart?120:0)
              cyly(22,centpart?27:147)
							tb_yx(22,50,80)
							cyly(22,hdl_lg-270)
							r(0,90)
							tb_yx(22,50,hdl_bend)
							cyly(22,(hdl_lg2-120)/2)
							cyly(30,120)
							cyly(22,(hdl_lg2-120)/2);
						}
				}
			}
}

//== Lighting ==================
module rear_light (clr="black", z=15) {
	//light
  tz(z) {
    scolor(clr)
    hull() dmirrory() {
      cylx(45,-10, 0,30);
      cylx(30,8, 0,30);
    }
    red()
      hull() dmirrory() 
        cylx(44,10, -20,30);
    glass()
      hull() dmirrory()
        cylx(44,2, -22,30);
  } 
}

//front_light (-20, false);
//----------------------------
module front_light (st_ang=0, steer_bracket=0, clr = "black"){
	//support (normal type on fork)
	if(steer_bracket==1) {
		t(25)
			r(0,st_ang) 
				flight();
		//steering bracket
		silver() {
			hull(){
				cylz(34,2.5, 0,0,-1);
				cyly(-2.5,26, 25);
			}
			t(25)
				r(0,st_ang)
					hull() {
						cyly(-2.5,26);
						cylx (-12,2.5, 0,0, 10);
					}
		}
	}
	//on top of fork
	else if(steer_bracket==2) {
		tz(-10-20)
      flight(st_ang);
	}
	//above boom
	else if(steer_bracket==3) {
		silver() { 
			cubez(3,20,60, 22);
			dmirrory()
			cubez(10,3,60, 22-5,8.5);
		}
		t(22,0,42) flight();
	}
	else // simple light
		flight();
	//-- light with own bracket --
	module flight(an=0) {
		//light bracket
		silver() 
			hull() {
				cyly(-14,10, 20,0,35);
				cylx(-12,2.5, 3,0, 10);
			}
		//light
		t(33,0,40) r(0,an) {
			scolor(clr)
				hull() {
					cylx(50,20,0,0,15);
					cylx(30,-20,0,0,15);
				}
			silver()
				cylx(48,1, 20,0,15);
			glass()
				cylx(48,2, 22,0,15);
		}
	}
}

//=== Miscellaneous utilities ===
//tube bend AND displacement
module tb_yx (dtube=25,radius=100,ang=90, prec=24) {
	sang = radius<0?ang:-ang;
	dx = -(1-cos(sang))*-radius;
	dy = sin(sang)*-radius;
	t(radius)
		rotate_extrude(angle=sang, $fn=64, convexity=10)
			t(-radius)
				circle(d=dtube, $fn=prec);
	t(dx,dy) 
		rotz(sang)
			children();
}

module tb_xy (dtube=25,radius=100,ang=90, prec=24) {
	r(0,0,90)
		tb_yx(dtube,radius,ang, prec)
			rotz(-90) children();
}

module tb_xz (dtube=25,radius=100,ang=90, prec=24) {
	r(90) rotz(90)
		tb_yx(dtube,radius,ang, prec)
			r(-90,0,-90) children();
}

module tb_yz (dtube=25,radius=100,ang=90, prec=24) {
	r(0,90) 
		tb_yx(dtube,radius,ang, prec)
			r(0,-90) 
				children();
}

module tb_zx (dtube=25,radius=100,ang=90, prec=24) {
	r(90)
		tb_yx(dtube,radius,ang, prec)
			r(-90) children();
}

module txa (txt,sz=10,hln="left") {
 linear_extrude(1) 
   text(txt,sz, halign=hln);  
}

module tb_zy (dtube=25,radius=100,ang=90, prec=24) {
	r(0,90) rotz(90)
		tb_yx(dtube,radius,ang, prec)
			r(0,0,-90) 
				r(0,-90) 
					children();
}

//----------------------------
module check () {
	if(!is_undef(dcheck)&&dcheck)
		red()
			children();
}

//-- Pannier -----------------
module pannier (std=0, ht= 440, lg = 340, blg = 200, bottomshift = 60, wd = 120, vshift = 60, sideshift = 0, cornerdia=50) {
  //0: parameters, 1:back cut, 2:symmetrical, 3:Flush with rack
  
  height = !std?ht:std==1?460:std==2?460:380;
  width = !std?wd:160;
  length = !std?lg:std==1?340:std==2?320:380;
  blength = !std?blg:std==1?220:std==2?220:380;
  bshift = !std?bottomshift:std==1?60:0;
  vertshift = !std?vshift:std==1?60:std==2?60:0;
  
	crd = cornerdia/2;
	midh = -height*0.4;
	pr = 16;
	cubex (length-cornerdia,16,3, crd-length,sideshift-8);
	t(-length,sideshift, vertshift) {
		hull() 
			duply(width-cornerdia)
				duplx(length-cornerdia) {
					t(crd,crd,-crd)
						sphere(crd, $fn=pr);
					cylz(cornerdia,1, crd,crd,midh, pr);
				}
		hull() {
			duply(width-cornerdia) {
				duplx(length-cornerdia) 
					cylz(cornerdia,1, crd,crd,midh, pr);
				
				t(bshift+(length-blength)/2, 0,-height+crd)
					duplx(blength-cornerdia) 
						t(crd,crd,vertshift-crd)
							sphere(crd);
			}
		}
	}
}
