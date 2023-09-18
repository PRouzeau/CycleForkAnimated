//OpenSCAD library modules - written from scratch - 
// (c) Pierre ROUZEAU(aka PRZ)2015-2021 Licence:  LGPL V3 
// Rev. 7 may 2017 : corrected ldupln function, which was making wrong count, so wrong tenons/slots
// Rev 2021: Add profiles, misc. modifications, add 'dark' color.	Add Assertions on some parameters, not yet generalised		 
/*OpenSCAD primitives gives a priority to z axis, which needs a lot of subsequent rotations. So, you quickly find yourself lost between your axis, which have been swapped by the rotations. That drive for complex objects to build them on a X/Y plane, then to rotate the ensemble. It is tedious and unpractical.
  Also, OpenSCAD is using a lot of brackets, which are hard to get on some non-QWERTY keyboards.
  This library is aimed to ease openSCAD programming and improve readability. Also, primitive names are short. This is not the todays trend, but I find it useful, whithout real penalty. 
So in the proposed library:
a) Nearly all primitives could be used for all three axis. This is  simply done by having the axis name being the last letter of the primitive (primx, primy, primz...). 
b) The translation parameters are part of most primitive (not all)
c) You could use negative extrusion and where physically sound, negative dimensions.
d) Setting the main dimension parameter negative will center the extrusion, saving the 'CENTER' parameter - for dimensions which could not be physically negative (a diameter...)
e) No vector use, so no brackets
  With that, you have the primitive and associated movements done in one go. Designed for my own purpose, I find that useful and a wrist saver.
*/
//== PART I  : PRIMITIVES : Cylinders, rounded cubes
//== PART II : DEVELOPPED PRIMITIVES Bolt, extruded profiles, text display, partial tores
//== PART III : OPERATORS Rotation, translation, mirrors, quad multipliers, line multipliers
//== PART IV : MISCELLANEOUS 
//include <surcharge.scad> Now included in library

/* [Computation] */
// Circle smoothness
$fn=$preview?24:36; // [4:6:8:24:48] 
//  final smoothness - reduced for visualisation
//Below is hole play to take into account manufacturing. Note that this is for diameter, not radius (or for complete sides).
// Play for hole (+ for printing, - for laser cut)
$holeplay=0; // [0:0.025:0.25]  //?????????
//Note: modification of these parameters are not taken into account if library called with <use> and not <include> ???

/* [Hidden] */
// Play for routing opening (+)
bithole=0; // [0:0.025:0.25] 

//$holeplay = ($holeplay)?$holeplay:0; //diameter play  for holes- applies for 'cyl' primitives and others hole primitives. This means that the diameter of a solid cylinder will also be affected, as the system cannot distinguish a hole from a solid.
// The play shall be positive for additive manufacturing (FDM). - value 'addplay' shall be defined
// shall be negative for laser cut (~ -0.2) - value 'cutplay' shall be defined.
// This play is also used by the slotting system.
// There are (globally positive) side-effects for primitives using cyl primitives (like 'rcube') 
//!WARNING!: to have the possibility to override this parameter from your configuration file, you shall <include> the utility file, and not <use> it. 

//next defines cube type in mcube module ??
function solidxy() = [1,1,0];
function solidxz() = [1,0,1];
function solidyz() = [0,1,1];
//---------------------
function deprecated() = true;
//display message for functions which are deprecated, to stop these message, just set in your program function deprecated() =false;

//== Legacy ================================
//When a duplicate mirror is neutralised, simple mirror (if set to false, do nothing)
//It is recommended to have the below variable false, but the legacy behaviour was always mirroring
dmirr_s = false;

function hlplay() = is_undef($holeplay)?0:$holeplay;

module decho (a,rep) {
  if(deprecated()) 
    echo (str(a," module is deprecated, use: ",rep)); 
}

//== PART 0 : Orientation ================
//base axis = z (because extrusion goes in Z), so it is simpler to design stuff along Z axis
//'dir' parameter change direction, default 1, setting to -1 reverse direction)
//example: a bolt is designed with Z orientation, redirect it in x:  x() bolt(n1,n2); and for the other direction: x(-1) bolt(n1,n2);

module x (dir=1) {
  assert(dir==1 || dir==-1,"Direction shall be 1 or -1 - default to 1");
  r(0,dir*90) children();  
}
//******
module y (dir=1) {
  assert(dir==1 || dir==-1,"Direction shall be 1 or -1 - default to 1");
  r(dir*-90) children();  
}
//******
module z (dir=1) {
  assert(dir==1 || dir==-1,"Direction shall be 1 or -1 - default to 1");
  mirrorz(dir==-1) children();  
}

//== PART I  : PRIMITIVES ==================
// cylinder, first parameter is diameter, then extrusion length
// Negative Diameter CENTER extrusion, Negative extrusions are Ok
// usage: cyly (12,-40); -- cyly (12,-40, 8, 10, 9, 6); (hexagon)
module cylx (diam,length,x=0,y=0,z=0,div=$fn, fh=1) {//Cylinder on X axis
  assert_xyz(x,y,z);
  // fh is a coefficient for $holeplay - default 1 for cylinders
  mv=(length<0)?length:0;					// not ok if diam AND length are negative. who cares ? 
  center=(diam<0)?true:false;
  if(length && diam) //avoid warning when h==0
	  t(x+mv,y,z)
			r(0,90,0)
				scylinder(abs(length),(abs(diam)+fh*hlplay())/2, $fn=div, center=center);
	//next to allow sequential operations
  t(x+(diam<0?0:length),y,z)
		children();
}
//--------------------------------------
module cyly (diam,length,x=0,y=0,z=0,div=$fn, fh=1) {//Cylinder on Y axis
  assert_xyz(x,y,z);
  // fh is a coefficient for hlplay() - default 1 for cylinders
  mv=(length<0)?length:0; // accept negative height		
  center=(diam<0)?true:false;
	if(length && diam)
		t(x,y+mv,z) 
			r(-90,0,0)
				scylinder(abs(length),(abs(diam)+fh*hlplay())/2, $fn=div, center=center);
	//next to allow sequential operations
	t(x,y+(diam<0?0:length),z)
		children();
}

module cylz (diam,height,x=0,y=0,z=0,div=$fn, fh=1) { // Cylinder  on Z axis
  assert_xyz(x,y,z);  
  // fh is a coefficient for hlplay() - default yes for cylinders
  mv=(height<0)?height:0; 	// accept negative height	
  center=(diam<0)?true:false;
	if(height && diam)
		t(x,y,mv+z) 
			scylinder(abs(height),(abs(diam)+fh*hlplay())/2, $fn=div, center=center);
	//next to allow sequential operations
	t(x,y,z+(diam<0?0:height))
		children();
}
//-------------------------------------
//-- New cube module -------------------
module ncube (x,y,z, px=0,py=0,pz=0, fh=0) {
//cube all centered
//parameters px, px,pz: 0 is centered,-1,1 decides on what edge they are aligned for each axis
//fh is an entry for $holeplay (which default to 0 for a cube)  
  mx = px>0? x/2: px<0? -x/2: 0;
  my = py>0? y/2: py<0? -y/2: 0;
  mz = pz>0?   0: pz<0?   -z: -z/2;
  if (fh==true) 
    echo ("ncube() : change $holeplay parameter to numeric");
  mz2=(z<0)?z:0;
  t(mx-x/2-fh*hlplay()/2,my-y/2-fh*hlplay()/2,mz2+mz)
    scube([abs(x)+fh*hlplay(),abs(y)+fh*hlplay(),abs(z)]);
  //cubez (x,y,z, mx,my,mz);
}
//--------------------------------------
module mcube (sx,sy,sz,center=false,x=0,y=0,z=0, solid=[-1,-1,-1]) { // accept negative coordinates but only if center==false else result is wrong
  // take into account hlplay() according to solid vector (default is a hole)
  cfc=(center)?0:1; // no play movement if centered
  mx=(sx<0)?cfc*(sx+solid[0]*hlplay()/2):solid[0]*cfc*hlplay()/2; 
  my=(sy<0)?cfc*(sy+solid[1]*hlplay()/2):solid[1]*cfc*hlplay()/2;
  mz=(sz<0)?cfc*(sz+solid[2]*hlplay()/2):+solid[2]*cfc*hlplay()/2;
  dx = abs(sx)-solid[0]*hlplay();
  dy = abs(sy)-solid[1]*hlplay();
  dz = abs(sz)-solid[2]*hlplay(); 
  t(x+mx,y+my,z+mz)
    scube([dx,dy,dz], center=center);
} //*/

module cuben (sx,sy,sz,x=0,y=0,z=0, center=false) { // same as mcube, but with center after position, for homogeneity with cuben modules - NO hlplay() so NO solid
  cfc=(center)?0:1; // no play movement if centered
  mx=(sx<0)?cfc*sx:0; 
  my=(sy<0)?cfc*sy:0;
  mz=(sz<0)?cfc*sz:0;
  t(x+mx,y+my,z+mz)
    scube([abs(sx),abs(sy),abs(sz)], center=center);
}

module cubex (xd,yd,zd,x=0,y=0,z=0, fh=0) { // centered on y anz z, not centered on x, negative extrusion possible
  // fh is a coefficient for hlplay() - default 0 for cubes
  cfh = (xd<0)?-1:1;
  mx=(xd<0)?xd:0;
  t(mx+x,y-yd/2-fh*hlplay()/2,z-zd/2-fh*hlplay()/2)
    scube([abs(xd),abs(yd)+fh*hlplay(),abs(zd)+fh*hlplay()]);
}

module cubey (xd,yd,zd,x=0,y=0,z=0, fh=0) { // centered on x anz z, not centered on y
  // fh is a coefficient for hlplay() - default 0 for cubes
  cfh = (yd<0)?-1:1;
  my=(yd<0)?yd:0;
  t(x-xd/2-fh*hlplay()/2,my+y,z-zd/2-fh*hlplay()/2)
    scube([abs(xd)+fh*hlplay(),abs(yd),abs(zd)+fh*hlplay()]);
}

module cubez (xd,yd,zd,x=0,y=0,z=0, fh=0) { // centered on x anz y, not centered on z
  // fh is a coefficient for hlplay()  - default 0 for cubes
  cfh = (zd<0)?-1:1; // what is done with that ??? 
  mz=(zd<0)?zd:0;
  t(x-xd/2-fh*hlplay()/2,y-yd/2-fh*hlplay()/2,mz+z)
    scube([abs(xd)+fh*hlplay(),abs(yd)+fh*hlplay(),abs(zd)]);
}

/*extrusion of rounded rectangular profile (centered), first param radius. p1 & p2 = rectangular side size (not half as above)
  Translation only on main axis, others are the rectangle parameters
  negative radius center around main axis 
//usage: rcubex (5,12,40,60,20)  */

module rcubex (radius,length,x=0,y,z) {
  assert_xyz(x,y,z);
  hull() 
    quadx (x,y/2-abs(radius),z/2-abs(radius)) 
      cylx(2*radius,length);
}

module hrcubex (radius,length,x=0,y,z) { // 'special' - rounded below, flat on top
  assert_xyz(x,y,z);
  hull() {
    t(x) 
      cubex (length,y,z/2,0,0,z/4);
    dmirrory() 
      cylx(2*radius,length,x,y/2-abs(radius),-z/2+abs(radius),32);
  }  
}

//hrcubex (7, 5, 40, 40,30);
//rcubex (7, 5, 20, 40,30);

module rcubey (radius,length,x,y=0,z) {
  assert_xyz(x,y,z);
  hull() 
    quady (x/2-abs(radius),y,z/2-abs(radius)) 
      cyly(2*radius,length);
}

module rcubez (radius,length,x,y,z=0) {
  assert_xyz(x,y,z);
  hull() 
    quadz (x/2-abs(radius),y/2-abs(radius), z) 
      cylz(2*radius,length);
}

//tubex (20,2,-100, 50,60,80);

module tubex (diam, thickness, length, x=0,y=0,z=0, div=$fn, fh=1) {
  assert_xyz(x,y,z);
  dt = (length<0)?-1:1;
  dtx = (diam<0)?0:dt;
  cf = (diam<0)?-1:1;
  difference() {
     cylx(diam, length, x,y,z, div, 0); // neutralise the hlplay() 
     cylx(cf*(abs(diam)-2*thickness), length+dt+dt, x-dtx,y,z, div, fh);
   }  
}

module tubey (diam, thickness, length, x=0,y=0,z=0,div=$fn, fh=1) {
  assert_xyz(x,y,z);
  dt = (length<0)?-1:1;
  dty = (diam<0)?0:dt;
  cf = (diam<0)?-1:1;
  difference() {
     cyly(diam, length, x,y,z,div, 0);
     cyly(cf*(abs(diam)-2*thickness), length+dt+dt, x,y-dty,z,div, fh);
   }  
}

module tubez (diam, thickness, length, x=0,y=0,z=0, div=$fn, fh=1) {
  assert_xyz(x,y,z);
  dt = (length<0)?-1:1;
  dtz = (diam<0)?0:dt;
  cf = (diam<0)?-1:1;
  difference() {
     cylz(diam, length, x,y,z, div,0);
     cylz(cf*(abs(diam)-2*thickness), length+dt+dt, x,y,z-dtz, div, fh);
   }  
}

//eqtrianglez (-100, 15);  cylz (100, 5);
module eqtrianglez (dim, length, x=0,y=0,z=0) { // dim positive is base, dim negative is external circle diameter. Centered
  assert_xyz(x,y,z);
  mz = (length<0)?-length:0; 
  base = (dim<0)? -dim/cos(30)*3/4: dim;
  t(x,y-base*cos(30)/3,z+mz)
    slinear_extrude(height=abs(length))
      polygon(points=[[-base/2,0],[base/2,0],[0,base*cos(30)]]);		
}

//=== Tenon and mortise/slots library, for laser/router cut 
// Beware of the axis name. The first axis is the direction of propagation of the slots/tenon
// The second axis name is the second plane axis, slot plate wise. This is done to have the same name for the connecting modules, hence, the slotxy  will be in an horizontal plate, with propagation in x, while the connecting tenonxy will be for a vertical plate, oriented on x
// library is yet limited to xy and zx combos. Use rotations for other axis
// As the slots are holes, the slot module is not only a primive but also an operator, so it COULD be used to MODIFY your plate objects. The location coordinates are the last two parameters (x,y or x,z). Typical use will be slotxy(slotlength, interval, tlength, thktenonplate,x,y) myplate(); Alternatively, if not used as an operator, it just creates the holes.
//You shall define the 'cutplay' and 'bithole' parameters (look configuration file) to take into account the width of the laser cut or diameter of the bit. The global hlplay() variable will so be set to a negative value equalling the laset beam cut diameter (approx 0.2mm diameter), while doing the exportation to dxf files. Such play make the slots invisibles in your model (the slots are smaller than the tenons), if you are not defining a protrusion.
// So, during the development of your model, a positive value for hlplay() shall be defined (1~2). Note that the visible play is double in length than in width. This is normal, as the plate thickness will not be affected by the cut.
//Neither the slot nor the tenon are centered. Negative thicknesses or negative length could be used, but with caution. 
//As for line primitive, the use of a negative interval will adjust (round) the intervals to fit the allowed space, however in this primitive as the tenon length is known, there will be no part overpassing the length. 

module tenonxy (slotlength, interval, totlength, thkplate, height) { //creates tenons of length slotlength on totlength (does not go over length) - raise in 'z' axis
  sll=abs(slotlength);
  // echo (hlplay()=hlplay());
  cfl=(totlength<0)?-1:1;
  mvh= (height<0)?height:-0.2;
  mvl= (totlength<0)?-sll+hlplay()/2:hlplay()/2;
  lduplx (interval, cfl*(abs(totlength)-sll)) 
    t(mvl,0,mvh) //-0.2 to avoid merging surface-no play as //cuts will equal height
      scube([sll-hlplay(), thkplate, abs(height)+0.2]);
}

module tenonbitxy (slotlength, interval, totlength, thkplate, height) { //cut the bit room aside tenons - parameters shall be identical to tenonxy, and this function shall be set in substraction block
  sll= abs(slotlength);
  cfl= (totlength<0)?-1:1;
  mvh= (height<0)?-0.1*bithole :0.1*bithole;
  mvl= (totlength<0)?-sll:0;
  lduplx (interval, cfl*(abs(totlength)-sll)) 
    t(mvl,0,mvh) { 
      cyly(-bithole,66,-0.48*bithole);
      cyly(-bithole,66,sll+0.48*bithole);
    }  
}

module tenonzx (slotlength, interval, totlength, thkplate, height) { //creates slots of length slotlength on totlength (does not go over length) -  raise in 'y' axis
  sll=abs(slotlength);
  //echo ($holeplay=$holeplay);
  cfl=(totlength<0)?-1:1;
  mvh= (height<0)?height:-0.2;
  mvl= (totlength<0)?-sll+hlplay()/2:hlplay()/2;
  lduplz (interval, cfl*(abs(totlength)-sll)) 
    t(0,mvh,mvl)
      scube([thkplate, abs(height)+0.2,sll-hlplay()]);
}

// As slots are full through holes, no depth defined 
module slotxy (slotlength, interval, totlength, thkplate,x=0,y=0) {
  sll= abs(slotlength);
  cfl= (totlength<0)?-1:1;
  mvt= (thkplate<0)?thkplate-hlplay()/2:-hlplay()/2;
  mvl= (totlength<0)?-sll-hlplay()/2:-hlplay()/2;
  difference () {
    children();
    t(x,y)
      lduplx (interval, cfl*(abs(totlength)-sll)) 
        t(mvl,mvt,-5) {
          scube([sll+hlplay(), abs(thkplate)+hlplay(), 100]); 
          if (bithole) 
            t(sll/2, thkplate/2) dmirrorx() dmirrory() 
              cylz (-bithole,66,sll/2-bithole*.485,thkplate/2-bithole*0.1); 
        }
  }
}
//-------------------------------------
module slotzx (slotlength, interval, totlength, thkplate,z=0,x=0) {
  //-- not checked --- ???
  sll= abs(slotlength);
  cfl= (totlength<0)?-1:1;
  mvt= (thkplate<0)?thkplate-hlplay()/2:-hlplay()/2;
  mvl= (totlength<0)?-sll-hlplay()/2:-hlplay()/2;
  difference () {
    children();
    t(x,0,z)
      lduplz (interval, cfl*(abs(totlength)-sll)) 
        t(mvt,-5,mvl) {
          scube([abs(thkplate)+hlplay(), 100, sll+hlplay()]); 
          if (bithole) 
            t(thkplate/2,0,sll/2) dmirrorx() dmirrorz() 
              cylz(-bithole,66,thkplate/2-bithole*0.1,0,sll/2-bithole*.485); 
        }  
  }
}

module conex (diam1, diam2, ht, x=0,y=0,z=0,div=$fn, fh=1) {
  mv = (ht<0)?ht:0;
  di1 = (ht<0)?diam2:diam1;
  di2 = (ht<0)?diam1:diam2;
  t(x+mv,y,z)
  r(0,90,0)
    scone(abs(ht), (di1+fh*hlplay())/2, (di2+fh*hlplay())/2,$fn=div);  
}

module coney (diam1, diam2, ht, x=0,y=0,z=0,div=$fn, fh=1) {
  mv = (ht<0)?ht:0;
  di1 = (ht<0)?diam2:diam1;
  di2 = (ht<0)?diam1:diam2;
  t(x,y+mv,z)
  r(-90,0)
    scone(abs(ht),(di1+fh*hlplay())/2, (di2+fh*hlplay())/2, $fn=div);  
}

module conez (diam1, diam2, ht,  x=0,y=0,z=0,div=$fn, fh=1) {
  assert_xyz(x,y,z);
  mz  = (ht<0)?ht:0;
  di1 = (ht<0)?diam2:diam1;
  di2 = (ht<0)?diam1:diam2;
  t(x,y,z+mz)
    scone(abs(ht),(di1+fh*hlplay())/2, (di2+fh*hlplay())/2, $fn=div);  
} 

//coney (10, 5, 3);

//cone3n
//diam 1 & diam2 shall be > 0
// if ht1 negative, ref is end of cylinder
// then if ht2 negative, ref is end of cone
// then if ht3 negative, ref is end of 2nd cylinder

module cone3x (diam1, diam2, ht1, ht2, ht3=0, x=0,y=0,z=0,div=$fn, fh=1) {
  assert_xyz(x,y,z);
  mov1 = (ht1<0)?ht1:0;
  mov2 = (ht2<0)?ht2+mov1:mov1;
  mov3 = (ht3<0)?ht3+mov2:mov2;
  t(mov3) {
    cylx (diam1, abs(ht1)+0.02, x,y,z,div,fh);
    t(abs(ht1)+x,y,z)
      r(0,90)
        scone(abs(ht2),(diam1+fh*hlplay())/2, (diam2+fh*hlplay())/2,  $fn=div); 
    cylx(diam2, abs(ht3)+0.02, x+abs(ht1)+abs(ht2)-0.02,y,z,div,fh);
  }  
}

module cone3y (diam1, diam2, ht1, ht2, ht3=0, x=0,y=0,z=0,div=$fn, fh=1) {
  assert_xyz(x,y,z);
  mov1 = (ht1<0)?ht1:0;
  mov2 = (ht2<0)?ht2+mov1:mov1;
  mov3 = (ht3<0)?ht3+mov2:mov2;
  t(0,mov3) {
    cyly (diam1, abs(ht1)+0.02, x,y,z,div,fh);
    t(x, y+abs(ht1),z)
      r(-90)
        scone(abs(ht2),(diam1+fh*hlplay())/2, (diam2+fh*hlplay())/2,  $fn=div); 
    cyly(diam2, abs(ht3)+0.02, x, y+abs(ht1)+abs(ht2)-0.02,z,div,fh);
  }  
}

module cone3z (diam1, diam2, ht1, ht2, ht3=0, x=0,y=0,z=0,div=$fn, fh=1) {
  mov1 = (ht1<0)?ht1:0;
  mov2 = (ht2<0)?ht2+mov1:mov1;
  mov3 = (ht3<0)?ht3+mov2:mov2;
  t(0,0,mov3) {
    cylz (diam1, abs(ht1)+0.02, x,y,z, div,fh);
    t(x, y,z+abs(ht1))
      scone(abs(ht2),(diam1+fh*hlplay())/2, (diam2+fh*hlplay())/2,  $fn=div); 
    cylz(diam2, abs(ht3)+0.02, x,y,z+abs(ht1)+abs(ht2)-0.02, div,fh);
  }  
}

module ncone3 (diam1, diam2, ht1, ht2, ht3,div=$fn, fh=1) {
  mov1 = (ht1<0)?ht1:0;
  mov2 = (ht2<0)?ht2+mov1:mov1;
  mov3 = (ht3<0)?ht3+mov2:mov2;
  tz(mov3) {
    cylz (diam1, abs(ht1)+0.02, 0,0,0, div,fh);
    tz(abs(ht1))
      scone(abs(ht2),(diam1+fh*hlplay())/2, (diam2+fh*hlplay())/2,  $fn=div); 
    cylz(diam2, abs(ht3)+0.02, 0,0,abs(ht1)+abs(ht2)-0.02, div,fh);
  }  
}

/*
$holeplay=0.2;
cone3x (2, 4, 4, 2, 6);
cone3x (2, 4, -4, 2, 6, 0,-8);
cone3x (2, 4, -4, -2, 6,0,-16);
cone3x (2, 4, -4, -2, -6,0,-24);
cone3x (4, 2, -4, 2, -6,0,-32);

cone3y (2, 4, 4, 2, 6,  0,0,0, $fn,0);
cone3y (2, 4, -4, 2, 6, -8,0);
cone3y (2, 4, -4, -2, 6,-16,0);
cone3y (2, 4, -4, -2, -6,-24,0);
cone3y (4, 2, -4, 2, -6,-32,0);

cone3z (2, 4,  4, 2,  6,  20);
cone3z (2, 4, -4, 2,  6,  20,-8);
cone3z (2, 4, -4, -2, 6,  20,-16);
cone3z (2, 4, -4, -2, -6, 20,-24);
cone3z (4, 2, -4, 2,  -6, 20,-32);
//*/

// cconen primitives may be deprecated in favor of cone3n primitives - avoid using them
module cconex (diam1, diam2, ht, htcyl=-1, x=0,y=0,z=0,div=$fn, fh=1) {
  // if htcyl negative, go from reference plan
  // if htcyl positive, cone atop cylinder
  assert_xyz(x,y,z);
  decho("cconex","cone3x");
  mcyl = (htcyl>0) ?(htcyl-0.02)*sign(ht):-0.02*sign(ht);
  t(mcyl) conex (diam1, diam2, ht, x,y,z,div, fh);
  cylx (diam1, abs(htcyl)*sign(ht)*sign(htcyl),x,y,z, div, fh);
}

module cconey (diam1, diam2, ht, htcyl=-1, x=0,y=0,z=0,div=$fn, fh=1) {
  // if htcyl negative, go from reference plan
  // if htcyl positive, cone atop cylinder
  assert_xyz(x,y,z);
  decho("cconey","cone3y");
  mcyl = (htcyl>0) ?(htcyl-0.02)*sign(ht):-0.02*sign(ht);
  t(0,mcyl) coney (diam1, diam2, ht, x,y,z,div, fh);
  cyly (diam1, abs(htcyl)*sign(ht)*sign(htcyl),x,y,z, div, fh);
}

module cconez (diam1, diam2, ht, htcyl=-1, x=0,y=0,z=0,div=$fn, fh=1) {
  // if htcyl negative, go from reference plan
  // if htcyl positive, cone atop cylinder
  assert_xyz(x,y,z);
  decho("cconez","cone3z");
  mcyl = (htcyl>0) ?(htcyl-0.02)*sign(ht):-0.02*sign(ht);
  t(0,0,mcyl) conez (diam1, diam2, ht, x,y,z,div, fh);
  cylz (diam1, abs(htcyl)*sign(ht)*sign(htcyl),x,y,z, div, fh);
}

// filleting primitives - the fillet is an independant volume
module filletx (rad, lg, x=0,y=0,z=0) {
  assert_xyz(x,y,z);
  mv = (rad<0)?rad+0.02:0;
  mv2 = (rad<0)?rad:0;
  mlg = (lg<0)?lg:0;  
  t(x+mlg, y-0.02+mv, z-0.02)
    difference() {
      scube([abs(lg), abs(rad),abs(rad)]);
      cylx (abs(rad)*2,abs(lg)+2,  -1,rad-mv2,abs(rad));
    } 
} 

module fillety (rad, lg, x=0,y=0,z=0) {
  assert_xyz(x,y,z);
  mv = (rad<0)?rad+0.02:0;
  mv2 = (rad<0)?rad:0;
  mlg = (lg<0)?lg:0;  
  t(x-0.02+mv, y+mlg,z-0.02)
    difference() {
      scube([abs(rad), abs(lg),abs(rad)]);
      cyly (abs(rad)*2,abs(lg)+2,rad-mv2,-1,abs(rad));
    } 
}

module filletz (rad, lg, x=0,y=0,z=0) {
  assert_xyz(x,y,z);
  mv = (rad<0)?rad+0.02:0;
  mv2 = (rad<0)?rad:0;
  mlg = (lg<0)?lg:0;  
  t(x-0.02+mv, y-0.02,z+mlg)
    difference() {
      scube([abs(rad), abs(rad), abs(lg)]);
      cylz (abs(rad)*2, abs(lg)+2,  rad-mv2, abs(rad),-1);
    } 
}

//cubez (20,20,20,10);
//fillety (-5,-50);

/*
$holeplay=0; 
bithole=3.5; // to cut bit room 
slotxy (12,-30,200,10,25,35)  
   mcube (250,120,10,false, 20,20); //*/
/*
$holeplay=0; 
bithole=3.5; // to cut bit room 
t(25,35) {
  difference() { 
    union() {
      mcube (250,10,-100); 
      tenonxy (12,-30,200,10,10);  
    } 
    tenonbitxy (12,-30,200,10,10);   
  } 
} //*/

//== PART II : DEVELOPPED PRIMITIVES =================
// Rather basic bolt routines // head size is realistic only in metric
// Bolts type are "HEX", "SH" (socket head), "DOME" and "FLAT" - all uppercase-
// dome shown is medium size, default "HEX"
// Washer types are 'S','M','L','LL', corresponding washer size, default none for one below nut. For two '2S', '2M', etc.
// Length is between the head and washer base. bolt total length not defined - this is a weakness
// Negative length are allowed, this reverse the bolt
// Normal reference point is under head
// NEGATIVE diameter center the bolt - reference point is middle of bolt
// Head size as shown is fictive, as in the ISO standard, they are rounded to the nearest plain number and not the direct result of a coefficient.
// usage: boltx(5,12); -- boltz(-5,20,8,0,30,"SH");
// washer not yet implemented...

//boltx(-5, 20, 10,20,50);
module boltx (d,l,x=0,y=0,z=0,type="HEX", washer="") {//bolt on X axis	
  assert_xyz(x,y,z);
  dia=abs(d);
  lg=abs(l);	// accept negative height
  mi= (l<0)?[1,0,0]:[0,0,0];
  mvc=(d<0)?-lg/2:0;//negative diameter CENTER the bolt 
  t(x,y,z)
  mirror (mi) 
    t(mvc,0,0) {
      if (abs(lg)>2) { // only show head if lg<2 (decoration) - allow negative for returning the head
        cylx (dia,lg+dia*1.2);
        cylx (dia*1.8,dia*0.8,lg,0,0,6); // nut
      }  
      // bolt head
      if (type=="DOME") { // domed head
        cylx (dia*2,-dia*0.16);
	difference (){
          r(0,-90,0) 
            dome (dia*2, dia/2,0,0,dia*0.16);
          cylx (dia*0.92,-dia,-dia*0.2,0,0,6);
        }
      }
      else if (type=="SH") //socket head
        difference () {
          cylx ((1/dia+1.5)*dia,-dia);
          cylx (dia*0.92,-dia,-dia*0.2,0,0,6);
        }
        else if (type=="FLAT") difference () {
          cylx (dia*2.4,-dia*0.5);
          cylx (dia*0.92,-dia,-dia*0.2,0,0,6);
        }
        else  // hexagonal
          cylx (dia*1.8,-dia*0.8,0,0,0,6);	
      } //tr
} //boltx

module bolty (d,l,x=0,y=0,z=0,type="HEX", washer) {
  assert_xyz(x,y,z);
  t(x,y,z)
    r(0,0,90)
      boltx(d,l,0,0,0,type, washer); 
}

module boltz (d,l,x=0,y=0,z=0,type="HEX", washer) {
  assert_xyz(x,y,z);
  t(x,y,z)
    r(0,90,0)
      boltx(d,l,0,0,0,type, washer); 
}

//--- Text display -------------------
module textz (txt,size,h,bold,x=0,y=0,z=0, hal="left", val ="baseline") { // position text normal to z axis
  assert_xyz(x,y,z);
  assert(hal=="center"||hal=="left"||hal=="right", "Horizontal alignement shall be 'left' or 'right' or 'center'");
  assert(val=="baseline"||val=="bottom"||val=="top"||val=="center", "Vertical  alignement shall be 'baseline' or 'bottom' or 'top' or 'center'");
  a =(h<0)?180:0;
  st=(bold)? "Liberation Sans:style=Bold":"Liberation Sans";
  t(x,y,z) r(a,0,0)
      slinear_extrude(height = abs(h)) text (str(txt), size, font=st, halign=hal, valign=val);
}

module textx (txt,size,h,bold,x=0,y=0,z=0, hal="left", val ="baseline") { // position text normal to x axis
  assert_xyz(x,y,z);
  assert(hal=="center"||hal=="left"||hal=="right", "Horizontal alignement shall be 'left' or 'right' or 'center'");
  assert(val=="baseline"||val=="bottom"||val=="top"||val=="center", "Vertical  alignement shall be 'baseline' or 'bottom' or 'top' or 'center'");
  a =(h<0)?-90:90;
  t(x,y,z) r(90,0,a)
    textz(txt,size,abs(h),bold,0,0,0,hal,val);
}

//tore (10, 50, 15, 220); 

module tore (dia, ldia, angstart, angend, qual=100) {
  // first diameter is the small diameter, qual defines segment numbers (on 360 °)->$fn
  sectorz(angstart,angend, -ldia*2)
    srotate_extrude($fn=qual)
      t(ldia/2)
         circle(dia/2);
}
//tore (10, 50, 220, 290);

module cylsectz (di, height, thickness, angstart,angend) { // cylindrical sector
  sectorz (angstart,angend)
    difference () {
      cylz(di+2*thickness, height,0,0,0,120);
      cylz(di, height+2,0,0,-1,120);
    }  
}
//------------------------------------
module cylsectx (di, height, thickness, angstart,angend) { // cylindrical sector
  sectorx (angstart,angend)
    difference () {
      cylx(di+2*thickness,height,    0,0,0,120);
      cylx(di,            height+2, -1,0,0,120);
    }  
}
//cylsectz  (100,25,10,100,160);
//------------------------------------
module sectorz (angstart,angend, radius=-1000,depth=2000 ) { //cut a sector in any shape, z axis  
  // negative radius will equilibrate the depth on z axis
  // angstart could be negative, angend could not
mvz = radius<0?-abs(depth)/2:depth<0?depth:0;  
sectang =  angend-angstart;
cutang = 360-sectang; 
  module cutcube() { 
    t(-0.02,-abs(radius),mvz-0.1)  
      scube([abs(radius),abs(radius),abs(depth)], center =false);
  }  
  module cutsect () {
    if (sectang >270) {
      difference () {
        cutcube();
        rotz(-cutang) 
          cutcube();
      }
    }  
    else {
      cutcube();
      rotz(-cutang+90) 
        cutcube();
      if(cutang > 180) 
        rotz(-90) 
          cutcube();
      if (cutang > 270)   
        rotz(-180) 
          cutcube();
    }
  } // cutsect
  difference () {
    children();
    rotz(angstart) 
      cutsect();
  }
}
//----------------------------------
module sectorx (angstart,angend, radius=-1000,depth=2000 ) { //cut a sector in any shape, z axis  
  // negative radius will equilibrate the depth on z axis
  // angstart could be negative, angend could not
mvx = radius<0?-abs(depth)/2:depth<0?depth:0;  
sectang =  angend-angstart;
cutang = 360-sectang; 
  module cutcube() { 
    t(mvx-0.1,-0.02,-abs(radius))  
      scube([abs(depth), abs(radius),abs(radius)], center =false);
  }  
  module cutsect () {
    if(sectang >270) {
      difference() {
        cutcube();
        r(-cutang) 
          cutcube();
      }
    }  
    else {
      cutcube();
      r(-cutang+90) 
        cutcube();
      if(cutang > 180) 
        r(-90) 
          cutcube();
      if(cutang > 270)   
        r(-180) 
          cutcube();
    }
  } // cutsect
  difference () {
    children();
    r(angstart) 
      cutsect();
  }
}

//== Profiles =====================
// profile_angle (30, 30, 2, -80) ;
//-- Profile on Z axis (legacy) ----
module profile_angle (legW, legH, thickness, length) { // length could be negative
  mv = (length<0)?length:0;
  t(0,0,mv)
    slinear_extrude(height=abs(length)) 
      difference() {
        square([legW,legH]);
        t(thickness,thickness) 
          square([legW,legH]);
      }
}
//-- Profile on x axis ----------
module prof_angle (legW, legH, thickness, length, intrad=3) {
  //r(90,0,90)
  //  profile_angle(legW, legH, thickness, //length);
  diff() {
    cubex(length,legW,legH, 0,legW/2,legH/2);
   //:::::::::: 
    hull() 
      duply(legW) duplz(legH)
        cylx(intrad*2,length+sign(length)*10,
    -5*sign(length),thickness+intrad,thickness+intrad);
  }
}
//profile_T(20,20,1.5, 100);
//-- Profile on Z axis (legacy) ----
module profile_T (width, height, thickness, length) { // length could be negative
  mv = (length<0)?length:0;
  w=width/2;
  t(0,0,mv)
    slinear_extrude (height=abs(length)) 
      polygon(points=[[-w,0],[w,0],[w,thickness],[thickness/2,thickness],[thickness/2,height],[-thickness/2,height],[-thickness/2,thickness],[-w,thickness]]);
}
//-- Profile on X axis ----------
module prof_T (width, height, thickness, length) {
  r(90,0,90)
    profile_T(width, height, thickness, length);
}

//-- Profile on Z axis (legacy) ----
module profile_rectangle (wd,ht, thk, length) { // length could be negative
  mv = (length<0)?length:0;
  t(0,0,mv)
    slinear_extrude (height=abs(length)) 
      difference () {
        square ([ht,wd]);
        t(thk,thk) 
          square ([ht-2*thk,wd-2*thk]);
      }  
}
//-- Profile on x axis -------------
module prof_rectangle (wd,ht, thk, length) {
  mirrorx() r(0,-90)
    profile_rectangle(wd,ht, thk, length);  
}
//-- Profile on Z axis (legacy) ----
module profile_u (wd,ht, thk, length) { // length could be negative
  mv = (length<0)?length:0;
  t(0,0,mv)
    slinear_extrude (height=abs(length)) 
      difference () {
        square ([ht,wd]);
        t(thk,thk) 
          square ([ht-2*thk,wd]);
      }  
}
//-- Profile on x axis ----------
module prof_U (wd,ht, thk, length) {
  r(90,0,90)
  profile_u(ht,wd, thk, length);
}
module prof_u (wd,ht, thk, length) {
  prof_U(wd,ht, thk, length);
}

//== PART III : OPERATORS =======   
//aliases
module u() {union() children();} // union alias
 
module diff () {  // difference alias
  difference() {
    children(0); 
    if ($children>1) for(i=[1:$children-1]) children(i);
  }  
}

//rotation and translations without brackets - 
module rot (ax,ay=0,az=0) {
  assert_xyz(ax,ay,az);
  decho("rot","r(ax,ay,az)");
  rotate([ax,ay,az]) 
  //srotate([ax,ay,az]) 
    children();
}
module r (ax,ay=0,az=0) {
  assert_xyz(ax,ay,az);
  //srotate([ax,ay,az])
  rotate([ax,ay,az])
    children();
}
module rotz (az=90) {
  assert(is_num(az),str("z angle shall be a number, actual value: ",az));
  rotate([0,0,az]) 
  //srotate([0,0,az]) 
    children();
}
module t (mx,my=0,mz=0) {
  assert_xyz(mx,my,mz);
  //stranslate([mx,my,mz]) 
  translate([mx,my,mz]) 
    children();
}
module tsl (mx,my=0,mz=0) {
  assert_xyz(mx,my,mz);
  decho("tsl","t(mx,my,mz)");
  //stranslate([mx,my,mz]) 
  translate([mx,my,mz]) 
    children();
}
module tslz (mz) {
  assert(is_num(mz),str("z movement shall be a number, actual value: ",mz));
  //stranslate([0,0,mz]) 
  translate([0,0,mz]) 
    children();
}
//-----------
module tz (mz) {
  assert(is_num(mz),str("z movement shall be a number, actual value: ",mz));
  //stranslate([0,0,mz]) 
  translate([0,0,mz]) 
    children();
}

// for a delta, everything is rotated three times at 120°, so an operator for that 
module rot120 (a=0) {
  assert(is_num(a),str("z angle shall be a number, actual value: ",a));
  for(i=[0,120,240]) 
    rotate([0,0,i+a]) 
    //srotate([0,0,i+a]) 
      children();
}

module mirrorx (mi=true) { // parameter helps in conditional mirroring
  mm = (mi)?1:0;
  mirror([mm,0,0]) children();
}
module mirrory (mi=true) {
  mm = (mi)?1:0;
  mirror([0,mm,0]) children();
}
module mirrorz (mi=true) {
  mm = (mi)?1:0;
  mirror([0,0,mm]) children();
}

module dmirrorx (dup=true, x=0, nmirr=dmirr_s) { // duplicate and mirror
  if(dup||!nmirr)
		t(x) children();
	if(dup||nmirr) {
    $ismirr = true;
		mirror([1,0,0]) t(x) children();  
  }  
}
module dmirrory (dup=true, y=0, nmirr=dmirr_s) {
  if(dup||!nmirr)
		t(0,y) children();
	if(dup||nmirr) {
    $ismirr = true;
		mirror([0,1,0])
			t(0,y) children();
  }  
}
module dmirrorz (dup=true, z=0, nmirr=dmirr_s) {
	if(dup||!nmirr)
		tz(z) children();
	if(dup||nmirr) {
    $ismirr = true;
		mirror ([0,0,1])
			tz(z) children();
  }  
}
module dmirrorxy(x=0,y=0) {
  dmirrorx(true,x)
    dmirrory(true,y)
      children();
}

module duplMirror (x,y,z) {//mirror AND maintain the base- beware, OpenSCAD is not iterative
  children();
  $ismirr = true;
  mirror([x,y,z]) children();
}

module dupl (vect, nb=1) { // duplicate object at vector distance
  for (i=[0:abs(nb)]) {
    $isdup = i!=0?true:is_undef($isdup)?false:$isdup;
    translate(vect*sign(nb)*i) 
      children();
  }  
  //stranslate(vect*i) children();
}

module duplx (dx, nb=1, startx=0) { // duplicate object at distance 'dx', times nb
  for(i=[0:abs(nb)]) {
    $isdup = i!=0?true:is_undef($isdup)?undef:$isdup;
    t(dx*sign(nb)*i+startx) children();
  }  
}

module duply (dy, nb=1, starty=0) { // duplicate object at distance 'dy',  times nb
  for (i=[0:abs(nb)]) {
    $isdup = i!=0?true:is_undef($isdup)?undef:$isdup;
    t(0,dy*sign(nb)*i+starty) children();
  }  
}

module duplz (dz, nb=1, startz=0) { // duplicate object at distance 'dz',  times nb
  for(i=[0:abs(nb)]) {
    $isdup = i!=0?true:is_undef($isdup)?undef:$isdup;
    tz(dz*sign(nb)*i+startz) children();
  }  
}

// Duplicates children on a given length at intervals following axis. Number is calculated
// x,y,z are for translation of the ensemble
// module linex (interval, length, x=0,y=0,z=0) {lduplx (interval, length, x,y,z);}
module lduplx (interval, length, x=0,y=0,z=0) { // if distance negative, optimize space to have a children at the end, else, the interval is respected
  nb = sign(length)*floor(abs(length)/abs(interval));
  sp=(interval<0)?length/nb:interval;
  for(i=[0:nb]) {
    $isdup = i!=0?true:is_undef($isdup)?undef:$isdup;
    t(i*sp+x,y,z) children();
  }  
}
//----------------------------------
module lduply (interval, length, x=0,y=0,z=0) {
  nb = sign(length)*floor(abs(length)/abs(interval));
  sp=(interval<0)?length/nb:interval;
  for (i=[0:nb]) {
    $isdup = i!=0?true:is_undef($isdup)?undef:$isdup;
    t(x,y+i*sp,z) children();
  }  
}

module lduplz (interval, length, x=0,y=0,z=0) {
  nb = sign(length)*floor(abs(length)/abs(interval));
  sp=(interval<0)?length/nb:interval;
  for (i=[0:nb]) {
    $isdup = i!=0?true:is_undef($isdup)?undef:$isdup;
    t(x,y,z+i*sp) children();
  }  
}

module drotz (angle, nb=1, initial=0) { // polar duplication rotating around Z axis
  for (i=[0:nb]) {
    $isdup = i!=0?true:is_undef($isdup)?undef:$isdup;
    rotz (angle*i+initial) children();
  }  
}

module droty (angle, nb=1, initial=0) {
  for (i=[0:nb]) {
    $isdup = i!=0?true:is_undef($isdup)?undef:$isdup;
    r(0,angle*i+initial) children();
  }  
}

module drotx (angle, nb=1, initial=0) {
  for (i=[0:nb]) {
    $isdup = i!=0?true:is_undef($isdup)?undef:$isdup;
    r(angle*i+initial) children();
  }  
}

//segz (2,2, 0,-5,200,-5);
//linez (31, 200) cylz (2,2);

//-- rectangular quad multiplier operator +p1/-p1, +p2/-p2
//Translation only on main axis, others are the rectangle parameters
//usage: quady (20,0,50) cylx(3,5); 
module quadx (x,y,z) {
  assert_xyz(x,y,z);
  duplMirror(0,0,1) {
    t(x,y,z) children();
    mirror ([0,1,0])
      t(x,y,z) children();
  }    
}

module quady (x,y,z) {
  assert_xyz(x,y,z);
  duplMirror(0,0,1) {
    t(x,y,z) children();
    mirror([1,0,0])
      t(x,y,z) children();
  }  
}
module quadz (x,y,z=0) { // create four blocs at -x/-x and +y/-y (mirrored)
  assert_xyz(x,y,z);
  duplMirror(0,1,0) {
    t(x,y,z) children();
    mirror ([1,0,0])
      t(x,y,z) children();
  }
}
//== PART IV : HOLES UTILITIES ==========
//These modules are used to have center points on holes when rendering a part. As cylinders in OpenSCAD are polygons with no known center, this help to draft a properly placed center. This hole mark can be replaced with a cross if $hcross is set to true (could be local). This can be used to designate some holes (notably threaded holes but it could be another purpose). The center mark can be removed by setting the variable '$noholecenter' to true. Holes have a default length of 99 which can be modified. Another important purpose is to move the position of children() to the hole position, which allow a hole of a part to be propagated in other part. This requires that the part is drafted in position, in order to align with the other components, so when exporting the part, you have to reposition it to an appropriate place.
//To use the hole propagation, the $holes shall be set to a positive length (can also be done with 'holes()' module). The discimination is done at the start of your component module. Typically, the holes are isolated in a module c_holes() (but you can use any name and the isolation might look like:
/* Exemple 
module mycomponent() {
  if ($holes) c_holes() children();
  else diff() {
    u() {... component design}  
    c_holes();
  }
  //component holes
  module c_holes() {
    t(x,y,z)
      dholex() children();
    t(x2,y2,z2)
      dholey() children();
    ...  
  }
}
*/
//With the holes library, using 'children()' in the holes module or when calling it is required if you use the holes to position other assembly components (typically screws) 
//The big limitation here is that you can only use one screw type and length for a given component
/* example
  holes(1) //(1) stop the hole component, only using moves 
    mycomponent() // important to not use ';' here
      socketM6(25); //could be any other screw/component
*/
//Using the dhole_() need programming discipline but is very powerful
//Limit the holes segment number, which is time consuming on render
hole_def = 12;
//Same for medium holes (5 to 8)
mhole_def = 16;
//same for large holes (> 8)
lhole_def = 24;
//defines the center mark diameter
$holecenterdia = 0.6;
//Defines cross lines thickness
$crossmarkwidth = 0.5;
//Isolate holes of a component
module holes (lg = 99) {
  $holes = lg;
  children();  
}
// make a cross within the hole instead of a point, e.g. to mark a threaded hole
module hcross (lg = 99) {
  $hcross = true;
  $holes  = lg;
  children();
}
//base axis = z (because extrusion goes in Z)
//parameter change direction, default 1, setting to -1 reverse direction)
module x(dir=1) {
  assert (dir==1 || dir==-1,"Direction shall be 1 or -1 - default to 1");
  r(0,dir*90) children();  
}
//******
module y(dir=1) {
  assert (dir==1 || dir==-1,"Direction shall be 1 or -1 - default to 1");
  r(dir*-90) children();  
}
//******
module z(dir=1) {
  assert (dir==1 || dir==-1,"Direction shall be 1 or -1 - default to 1");
  mirrorz(dir==-1) children();  
}
//******
module dholex (dia=1) {
  x() dholez(dia) children();
}
//******
module dholey (dia=1) {
  y() dholez(dia) children();
}
//****
module dholez (dia=1) {
  lghole = is_undef($holes)||!$holes?66:$holes;
  hdef = dia<8 ? (dia<5?hole_def:mhole_def): lhole_def;
  if (lghole!=1)
    diff() { 
      if(is_undef($view_holes)||!$view_holes)
        cylz(-dia,lghole, 0,0,0, hdef);
      else
        #cylz(-dia,lghole, 0,0,0, hdef);
      //::::::::::::
      if(is_undef($no_hole_center) || !$no_hole_center)
        if(is_undef($hcross)||!$hcross)
          cylz(-$holecenterdia,lghole+2, 0,0,0, 6);
        else { // cross mark
          ncube($crossmarkwidth,3,lghole+2, 0,0,0); 
          ncube(3,$crossmarkwidth,lghole+2, 0,0,0); 
        }  
    } 
  children();
}
//== PART V : MISCELLANEOUS ==========
//-- Miscellaneous Modules ---------------
module dome (d,ht,x,y,z){ // origin base of dome - rise in 'z' axis
  assert_xyz(x,y,z);
  mv = (z==undef)?0:z;
  Sph_Rd = (ht*ht + d*d/4) / (2*ht);
  t(x,y,-Sph_Rd+ht+mv)
    difference() {
      ssphere(Sph_Rd, $fn=64);
      t(0,0,-ht) // remove the useless sphere portion
        scube([2*Sph_Rd,2*Sph_Rd,2*Sph_Rd],center=true);
    }
}

module echo_camera () { // Echo camera variables on console
  echo ("Camera distance: ",$vpd); 
  echo ("Camera translation vector: ",$vpt);  
  echo ("Camera rotation vector: ",$vpr);
}

module segz (d,depth, x1,y1,x2,y2) { //extrude rounded segment
  slinear_extrude(height=depth, center=false)  
    hull () {t(x1,y1) circle (d=d); t(x2,y2) circle(d=d);}
}

//-- color modules ---------------------------
module black () {scolor("black") children();}
//black color is problematic in OpenScad as you can't view shapes, so a not completely black color is created and called 'dark'
function dark() = "#383838";
//----
module dark () {scolor(dark()) children();}
module white () {scolor("white") children();}
module ivory (){scolor("ivory") children();}
module silver (){scolor("silver") children();}
module gray ()  {scolor("gray") children();}
module lightgray () {scolor("lightgray") children();}
module red ()   {scolor("red") children();}
module green () {scolor("green") children();}
module blue ()  {scolor("blue") children();}
module yellow (){scolor("yellow") children();}
module orange (){scolor("orange") children();}
module lime ()  {scolor("lime") children();}
module limegreen (){scolor("limegreen") children();}
module burlywood (){scolor("burlywood") children();}
//'Glass' is a special color with transparency
//Remember transparency know only parts which have already been defined, so for it to work properly, 'transparent' parts shall be defined the last.
$glass = [0.69,0.69,0.87,0.3];
module glass (){scolor("#AFAFDF",0.3) children();}
//glass() cylz(200,200);

//== Assertions on parameters ========
//Assertions volontarily crash program in order to help debugging. The big advantage here is that the crash return the module calls stack which help track the root cause.
//Typical assertions
module assert_xyz(x,y,z) {
  assert(is_num(x)&&is_num(y)&&is_num(z),str("x,y,z coordinates/angles shall be numbers, actual values: ",x,";",y,";",z));
}

//-- Surcharging library for color/assembly selection --
// by Pierre ROUZEAU, known as 'PRZ' on Internet
//== selecting module ==================
//Selecting with colors
module scolor (c, alpha=1) {
  if (is_undef($select_color) || strtolower($select_color)==strtolower(c) || $select_color=="")  {
    color(c,alpha) 
      children(); 
  }
}
//Selecting parts (include movements) 
//-----------------------------------------
module zsel () {
  if(is_undef($select) || $select)
    children();
}
//-----------------------------------
module scube (a, center=false) {
  zsel() cube(a, center);
}
//-----------------------------------
module ssphere (r) {
  zsel() sphere(r);
}  
//------------------------------------  
module scylinder (h,r,center=false) {
  zsel() cylinder(h=h, r=r, center=center);
} 
//------------------------------
module scone (h,r1,r2,center=false) {
  zsel() cylinder(h=h, r1=r1, r2=r2, center=center);
}
//-----------------------------
module slinear_extrude (height, center = false, convexity = 10, slices = 20, scale = 1.0, $fn = 16, origin=0) {
  zsel()
    linear_extrude(height=height, center=center, convexity=convexity,  slices=slices, scale=scale, $fn=$fn)
      children();
}  
//------------------------------
module srotate_extrude (angle=360, convexity = 2, $fn=$fn) {
  zsel()
    rotate_extrude(angle=angle,convexity=convexity, $fn=$fn)
      children();  
}
//-------------------------------
module srotate (a) {
  if(is_undef($move) || $move) 
    rotate(a)
      children();
  else 
    children();  
}
//-------------------------------
module stranslate (a) {
  if(is_undef($move) || $move) 
    translate(a)
      children();
  else 
    children();  
}
//== Round a number to the minimum above, according parameter ==
function zround (n, rnd=10) =
  ceil(n/rnd)*rnd;  
//========================================
//-- String function ---------------------
function strtolower (string) = chr([for(s=string) let(c=ord(s)) c<91 && c>64 ?c+32:c]);
//-- Replace char(not string) in a string  
function char_replace (s,old=" ",new="_") = 
  chr([for(i=[0:len(s)-1]) s[i]==old?ord(new):ord(s[i])]);
//-- Replace last chars of a string (used for file extension replacement) work only with same length extension
function str_rep_last (s,new=".stl") = str(chr([for(i=[0 :len(s)-len(new)-1])ord(s[i])]),new);
//-- integer value from string ----------  
function strtoint(s, ret=0, i=0) =
    i >= len(s)
    ? ret
    : strtoint(s, ret*10 + ord(s[i]) - ord("0"), i+1);
//== The End =============================