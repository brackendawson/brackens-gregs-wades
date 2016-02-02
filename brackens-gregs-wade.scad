// Greg's Wade Extruder. 
// It is licensed under the Creative Commons - GNU GPL license. 
// � 2010 by GregFrost
// Extruder based on prusa git repo.
// http://www.thingiverse.com/thing:6713

include<configuration.scad>

// Define the hotend_mounting style you want by specifying hotend_mount=style1+style2 etc.
malcolm_hotend_mount=1;
groovemount=2;
peek_reprapsource_mount=4;
arcol_mount=8;
mendel_parts_v6_mount=16; 
grrf_peek_mount=32;
wildseyed_mount=64;


//Set the hotend_mount to the sum of the hotends that you want the extruder to support:
//e.g. wade(hotend_mount=groovemount+peek_reprapsource_mount);


wade(hotend_mount=groovemount);

//Place for printing
//translate([78,-10,15.25])
//rotate([0,-90,0])

//Place for assembly.
//wadeidler(); 

//===================================================
// Parameters defining the wade body:
wade_block_height=56;
wade_block_width=24;
wade_block_depth=28;

block_bevel_r=6;

base_thickness=7;
base_length=70;
base_leadout=25;

nema17_hole_spacing=1.2*25.4; 
nema17_width=1.7*25.4;
nema17_support_d=nema17_width-nema17_hole_spacing;

screw_head_recess_diameter=7.2;
screw_head_recess_depth=3;

motor_mount_rotation=25;
motor_mount_translation=[50.5,34,0];
motor_mount_thickness=12;

m8_clearance_hole=8.8;
hole_for_608=22.6;
608_diameter=22;

block_top_right=[wade_block_width,wade_block_height];

layer_thickness=0.4;
filament_feed_hole_d=4;
filament_diameter=3;
filament_feed_hole_offset=filament_diameter+0.5;


gear_separation=7.4444+32.0111+0.25;

function motor_hole(hole)=[
	motor_mount_translation[0],
	motor_mount_translation[1]]+
	rotated(45+motor_mount_rotation+hole*90)*nema17_hole_spacing/sqrt(2);

// Parameters defining the idler.
idler_axle_offset_depth = 2.5; //sets the pinch, make larger for deeper cut hobbed bolts, 3 is pretty big. This setting only affects the idler.
idler_axle_offset = 20;
idler_hinge_radius = 6;
idler_bolt_height = 36;
idler_bolt_depth = 10.4;
idler_block_spaceing = 17.0;

module wade (hotend_mount=0)
{
	difference ()
	{
		union()
		{
            // The idler
            %translate(motor_mount_translation) translate([-gear_separation-idler_block_spaceing,-idler_axle_offset,wade_block_depth]) rotate([180,0,90]) bracken_idler();
            translate([40,-20,0]) rotate([0,0,0]) bracken_idler(scaffold=true);
           
           // Bearing and hobbed bolt for tuning idler_bolt_offset_depth
           %translate(motor_mount_translation) translate([-gear_separation-idler_block_spaceing+idler_axle_offset_depth,0,wade_block_depth/2-3.5]) cylinder(d=22,h=7);
           %translate(motor_mount_translation) translate([-gear_separation,0,0]) cylinder(d=8, h=wade_block_depth);
            
			// The wade block.
			cube([wade_block_width,wade_block_height,wade_block_depth]);
            
            //The hinge block
            mirror([1,0,0]) cube([-motor_mount_translation[0]+gear_separation+idler_block_spaceing+idler_hinge_radius*1.5,motor_mount_translation[1]-idler_axle_offset+idler_hinge_radius/2,wade_block_depth]);

			// Filler between wade block and motor mount.
			translate([10,motor_mount_translation[1]-hole_for_608/2,0])
			cube([wade_block_width,
				wade_block_height-motor_mount_translation[1]+hole_for_608/2,
				motor_mount_thickness]);

			// Connect block to top of motor mount.
			linear_extrude(height=motor_mount_thickness)
			barbell(block_top_right-[0,5],motor_hole(0),5,nema17_support_d/2,100,60);

			//Connect motor mount to base.
			linear_extrude(height=motor_mount_thickness)
			barbell([base_length-base_leadout,
				base_thickness/2],motor_hole(2),base_thickness/2,
				nema17_support_d/2,100,60);

			// Round the ends of the base
			translate([base_length-base_leadout,base_thickness/2,0])
			cylinder(r=base_thickness/2,h=wade_block_depth,$fn=20);

			translate([-base_leadout,base_thickness/2,0])
			cylinder(r=base_thickness/2,h=wade_block_depth,$fn=20);

			//Provide the bevel betweeen the base and the wade block.
			render()
			difference()
			{
				translate([+motor_mount_translation[0]-gear_separation-idler_block_spaceing-idler_hinge_radius*1.5-block_bevel_r,0,0])
				cube([block_bevel_r*2+wade_block_width-motor_mount_translation[0]+gear_separation+idler_block_spaceing+idler_hinge_radius*1.5,
					base_thickness+block_bevel_r,wade_block_depth]);				
				translate([wade_block_width+block_bevel_r,
					block_bevel_r+base_thickness])
				cylinder(r=block_bevel_r,h=wade_block_depth,$fn=60);
                translate([+motor_mount_translation[0]-gear_separation-idler_block_spaceing-idler_hinge_radius*1.5-block_bevel_r,
					block_bevel_r+base_thickness])
				cylinder(r=block_bevel_r,h=wade_block_depth,$fn=60);
			}

			//The base.
			translate([-base_leadout,0,0])
			cube([base_length,base_thickness,wade_block_depth]);

			motor_mount ();
		}

		block_holes();
		motor_mount_holes ();

		translate([motor_mount_translation[0]-gear_separation-filament_feed_hole_offset,
			0,wade_block_depth/2])
		rotate([-90,0,0])
		{
			if (in_mask (hotend_mount,malcolm_hotend_mount))
				malcolm_hotend_holes ();
			if (in_mask (hotend_mount,groovemount))
				groovemount_holes ();
			if (in_mask (hotend_mount,peek_reprapsource_mount))
				peek_reprapsource_holes ();
			if (in_mask (hotend_mount,arcol_mount))
				arcol_mount_holes ();
			if (in_mask (hotend_mount,mendel_parts_v6_mount)) 
				mendel_parts_v6_hotend ();
			if (in_mask(hotend_mount,grrf_peek_mount))
				grrf_peek_mount_holes();
			if (in_mask(hotend_mount,wildseyed_mount))
				wildseyed_mount_holes();
		}
	}
}

function in_mask(mask,value)=(mask%(value*2))>(value-1); 

module block_holes()
{
	//Round off the top of the block.
    translate([wade_block_width-2*block_bevel_r,wade_block_height-block_bevel_r,motor_mount_thickness])
	render()
	difference()
	{
		translate([block_bevel_r,0,0])
		cube([block_bevel_r+1,block_bevel_r+1,wade_block_depth+2]);
		translate([block_bevel_r,0,0])
		cylinder(r=block_bevel_r,h=wade_block_depth+2,$fn=40);
	}

	// Round the top front corner.
	translate ([-base_leadout-base_thickness/2,-1,wade_block_depth-block_bevel_r])
	render()
	difference() 
	{
		translate([-1,0,0])
		cube([block_bevel_r+1,base_thickness+2,block_bevel_r+1]);
		rotate([-90,0,0])
		translate([block_bevel_r,0,-1])
		cylinder(r=block_bevel_r,h=base_thickness+4);
	}
    
    //Cut the hinge
    translate([+motor_mount_translation[0]-gear_separation-idler_block_spaceing,motor_mount_translation[1]-idler_axle_offset,-0.01])
    hull() {
        cylinder(r=idler_hinge_radius+0.2, h=wade_block_depth+0.02);
        translate([0,10,0]) cylinder(r=idler_hinge_radius+0.2, h=wade_block_depth+0.02);
    }
    
    //Round the hinge
    translate([+motor_mount_translation[0]-gear_separation-idler_block_spaceing-idler_hinge_radius*1.5,motor_mount_translation[1]-idler_axle_offset+idler_hinge_radius/2,0])
    render()
    difference()
    {
        translate([-2,-2-0.01,-0.01]) cube([4,4,wade_block_depth+0.02]);
        translate([2,-2,-0.01]) cylinder(r=2, h=wade_block_depth+0.02, $fn=8);
    }

	// Round the top back corner.
	translate ([base_length-base_leadout+base_thickness/2-block_bevel_r,
		-1,wade_block_depth-block_bevel_r])
	render()
	difference() 
	{
		translate([0,0,0])
		cube([block_bevel_r+1,base_thickness+2,block_bevel_r+1]);
		rotate([-90,0,0])
		translate([0,0,-1])
		cylinder(r=block_bevel_r,h=base_thickness+4);
	}

	// Round the bottom front corner.
	translate ([-base_leadout-base_thickness/2,-1,-2])
	render()
	difference() 
	{
		translate([-1,0,-1])
		cube([block_bevel_r+1,base_thickness+2,block_bevel_r+1]);
		rotate([-90,0,0])
		translate([block_bevel_r,-block_bevel_r,-1])
		cylinder(r=block_bevel_r,h=base_thickness+4);
	}

	translate(motor_mount_translation)
	{
		translate([-gear_separation,0,0])
		{
%			rotate([0,180,0])
			translate([0,0,1])
			import("large_gear.stl");

			translate([0,0,-1])
			b608(h=9);
		
			translate([0,0,20])
			b608(h=9);
		
			translate([-13,0,9.5])
			b608(h=wade_block_depth/3);
            
            translate([0,0,8+layer_thickness])
			cylinder(r=m8_clearance_hole/2,h=wade_block_depth-(8+layer_thickness)+2);
		
			// Filament feed.
			translate([-filament_feed_hole_offset,0,wade_block_depth/2])
			rotate([90,0,0])
			rotate(360/16)
			cylinder(r=filament_feed_hole_d/2,h=wade_block_depth*3,center=true,$fn=8);	

			// Mounting holes on the base.
			for (mount=[0:1])
			{
				translate([-filament_feed_hole_offset+25*((mount<1)?1:-1),
					-motor_mount_translation[1]-1,wade_block_depth/2])
				rotate([-90,0,0])
				rotate(360/16)
				cylinder(r=m4_diameter/2,h=wade_block_height*mount+base_thickness+2,$fn=8);	
	
				translate([-filament_feed_hole_offset+25*((mount<1)?1:-1),
					-motor_mount_translation[1]+base_thickness/2,
					wade_block_depth/2])
				rotate([-90,0,0])
				cylinder(r=m4_nut_diameter/2,h=wade_block_height*mount+base_thickness+2,$fn=6);	
			}

		}
%		translate([0,0,-8])
		import("small_gear.stl");
	}

	// Idler mounting hole
    translate([-1,idler_bolt_height+motor_mount_translation[1]-idler_axle_offset+0.5,wade_block_depth-idler_bolt_depth]) rotate([0,90,0]) cylinder(d=m4_diameter, h=wade_block_width+2);
    translate([wade_block_width-3,idler_bolt_height+motor_mount_translation[1]-idler_axle_offset+0.5,wade_block_depth-idler_bolt_depth]) rotate([0,90,0]) cylinder(d=m4_nut_diameter, h=wade_block_width, $fn=6);
}

module motor_mount()
{
	linear_extrude(height=motor_mount_thickness)
	{
		barbell (motor_hole(0),motor_hole(1),nema17_support_d/2,
			nema17_support_d/2,20,160);
		barbell (motor_hole(1),motor_hole(2),nema17_support_d/2,
			nema17_support_d/2,20,160);
	}
}

module motor_mount_holes()
{
	radius=4/2;
	slot_left=1;
	slot_right=2;

	{
		translate([0,0,screw_head_recess_depth+layer_thickness])
		for (hole=[0:2])
		{
			translate([motor_hole(hole)[0]-slot_left,motor_hole(hole)[1],0])
			cylinder(h=motor_mount_thickness-screw_head_recess_depth,r=radius,$fn=16);
			translate([motor_hole(hole)[0]+slot_right,motor_hole(hole)[1],0])
			cylinder(h=motor_mount_thickness-screw_head_recess_depth,r=radius,$fn=16);

			translate([motor_hole(hole)[0]-slot_left,motor_hole(hole)[1]-radius,0])
			cube([slot_left+slot_right,radius*2,motor_mount_thickness-screw_head_recess_depth]);
		}

		translate([0,0,-1])
		for (hole=[0:2])
		{
			translate([motor_hole(hole)[0]-slot_left,motor_hole(hole)[1],0])
			cylinder(h=screw_head_recess_depth+1,
				r=screw_head_recess_diameter/2,$fn=16);
			translate([motor_hole(hole)[0]+slot_right,motor_hole(hole)[1],0])
			cylinder(h=screw_head_recess_depth+1,
				r=screw_head_recess_diameter/2,$fn=16);

			translate([motor_hole(hole)[0]-slot_left,
				motor_hole(hole)[1]-screw_head_recess_diameter/2,0])
			cube([slot_left+slot_right,
				screw_head_recess_diameter,
				screw_head_recess_depth+1]);
		}
	}
}

module b608(h=8)
{
	translate([0,0,h/2]) cylinder(r=hole_for_608/2,h=h,center=true,$fn=60);
}

module barbell (x1,x2,r1,r2,r3,r4) 
{
	x3=triangulate (x1,x2,r1+r3,r2+r3);
	x4=triangulate (x2,x1,r2+r4,r1+r4);
	render()
	difference ()
	{
		union()
		{
			translate(x1)
			circle (r=r1);
			translate(x2)
			circle(r=r2);
			polygon (points=[x1,x3,x2,x4]);
		}
		
		translate(x3)
		circle(r=r3,$fa=5);
		translate(x4)
		circle(r=r4,$fa=5);
	}
}

function triangulate (point1, point2, length1, length2) = 
point1 + 
length1*rotated(
atan2(point2[1]-point1[1],point2[0]-point1[0])+
angle(distance(point1,point2),length1,length2));

function distance(point1,point2)=
sqrt((point1[0]-point2[0])*(point1[0]-point2[0])+
(point1[1]-point2[1])*(point1[1]-point2[1]));

function angle(a,b,c) = acos((a*a+b*b-c*c)/(2*a*b)); 

function rotated(a)=[cos(a),sin(a),0];

module bracken_idler(scaffold = 0) {
    mount_clear = 0;
    fudge = 0.1;
    
    difference() {
      union() {
        cylinder(r = idler_hinge_radius, h = wade_block_depth);
        difference() {
          translate([0,-4,0]) cube([wade_block_height-motor_mount_translation[1]+idler_axle_offset,10+fudge,wade_block_depth]);
          translate([idler_axle_offset,-4-fudge,-fudge]) cube([wade_block_height,3 + fudge,wade_block_depth + 2*fudge]);
        }
        hull() {
          translate([idler_axle_offset,idler_axle_offset_depth,0]) cylinder(r = 10, h = wade_block_depth);
          translate([idler_axle_offset+15,-1,0]) cube([fudge,fudge,wade_block_depth]);
        }
        translate([idler_bolt_height,0,idler_bolt_depth]) rotate([90,0,0]) cylinder(r = 4.5, h = 3);
      }
      rotate([0,0,55]) translate([-6,4.24,-fudge]) cube([12,12, wade_block_depth+ 2*fudge]);
      translate([idler_axle_offset,idler_axle_offset_depth,-fudge]) cylinder(d = m8_diameter-0.8, h = wade_block_depth + 2*fudge);
      translate([-50,6,-fudge]) cube([100,50,wade_block_depth + 2 * fudge]);
      translate([20 - 12,-50,wade_block_depth/2-4.5]) cube([24,100,9]);
      hull() {
        translate([idler_bolt_height,-50,8.2 + 2.2]) rotate([-90,0,0]) cylinder(d=m4_diameter, h=100);
        translate([idler_bolt_height+20,-50,8.2 + 2.2]) rotate([-90,0,0]) cylinder(d=m4_diameter, h=100);
      }
      difference() {
        translate([wade_block_height-motor_mount_translation[1]+idler_axle_offset - 3,-8,-fudge]) cube([10,10,wade_block_depth + 2*fudge]);
        translate([wade_block_height-motor_mount_translation[1]+idler_axle_offset - 3,2,-fudge]) cylinder(r = 3, h = wade_block_depth + 2*fudge);
      }
      if(mount_clear) {
        translate([-7,0,14 - 2.5 - 1.5/2]) rotate([90,0,30]) hull() {
          translate([0,0,-50]) cylinder(r = 3, h = 100);
          translate([0,5,-50]) cylinder(r = 3, h = 100);
        }
      }
    }
    difference () {
      translate([idler_axle_offset,idler_axle_offset_depth,0]) cylinder(r = 6.5, h = wade_block_depth);
      translate([idler_axle_offset,idler_axle_offset_depth,-fudge]) cylinder(d=m8_diameter-0.8, h=wade_block_depth + 2*fudge);
      translate([-50,6,-fudge]) cube([100,50,wade_block_depth + 2*fudge]);
      translate([20 - 12,-50,wade_block_depth/2-3.5]) cube([24,100,7]);
    }
    if(scaffold) {
      difference() {
        union() {
          difference() {
            translate([idler_axle_offset,idler_axle_offset_depth,0]) cylinder(r = 10, h = wade_block_depth);
            translate([idler_axle_offset,idler_axle_offset_depth,-fudge]) cylinder(r = 9.7, h = wade_block_depth + 2*fudge);
          }
          difference() {
            translate([idler_axle_offset,idler_axle_offset_depth,0]) cylinder(r = 4.4, h = wade_block_depth);
            translate([idler_axle_offset,idler_axle_offset_depth,-fudge]) cylinder(r = 4.1, h = wade_block_depth + 2*fudge);
          }
          difference() {
            translate([idler_axle_offset,idler_axle_offset_depth,0]) cylinder(r = 6.5, h = wade_block_depth);
            translate([idler_axle_offset,idler_axle_offset_depth,-fudge]) cylinder(r = 6.2, h = wade_block_depth + 2*fudge);
          }
        }
        translate([-50,6,-fudge]) cube([100,50,wade_block_depth + 2*fudge]);
        for(a = [90, 135, 180, 225, 270]) {
          translate([idler_axle_offset,idler_axle_offset_depth,-fudge]) rotate([0,0,a]) translate([-0.5,0,0]) cube([1,50,wade_block_depth + 2 * fudge]);
        }
      }
      translate([idler_bolt_height-1,-3,0]) cube([0.3,3,idler_bolt_depth-3]);
      translate([idler_bolt_height+1,-3,0]) cube([0.3,3,idler_bolt_depth-3]);
      translate([idler_bolt_height+2.7,-3,8.2]) cube([0.3,2.3,4.4]);
      difference() {
        translate([wade_block_height-motor_mount_translation[1]+idler_axle_offset-3,3 - 1,idler_bolt_depth-m4_diameter/2]) cylinder(r=3, h=m4_diameter);
        translate([wade_block_height-motor_mount_translation[1]+idler_axle_offset-3,3 - 1,-fudge,]) cylinder(r = 2.7, h = wade_block_depth + 2*fudge);
        translate([wade_block_height-motor_mount_translation[1]+idler_axle_offset-3 - 6,3 - 1 - 3,-fudge]) cube([6,6,wade_block_depth + 2*fudge]);
        translate([wade_block_height-motor_mount_translation[1]+idler_axle_offset-3-fudge,2,-fudge]) cube([6,6,wade_block_depth + 2*fudge]);
      }
      translate([wade_block_height-motor_mount_translation[1]+idler_axle_offset-0.3,2,idler_bolt_depth-m4_diameter/2]) cube([0.3,4,m4_diameter]);
    }
}

//========================================================
// Modules for defining holes for hotend mounts:
// These assume the extruder is verical with the bottom filament exit hole at [0,0,0].

//malcolm_hotend_holes ();
module malcolm_hotend_holes ()
{
	extruder_recess_d=16; 
	extruder_recess_h=3.5;

	// Recess in base
	translate([0,0,-1])
	cylinder(r=extruder_recess_d/2,h=extruder_recess_h+1);	
}

//groovemount_holes ();
module groovemount_holes ()
{
	extruder_recess_d=16; 
	extruder_recess_h=5.5;

	// Recess in base
	translate([0,0,-1])
	cylinder(r=extruder_recess_d/2,h=extruder_recess_h+1);	
}

//peek_reprapsource_holes ();
module peek_reprapsource_holes ()
{
	extruder_recess_d=11;
	extruder_recess_h=19; 

	// Recess in base
	translate([0,0,-1])
	cylinder(r=extruder_recess_d/2,h=extruder_recess_h+1);	

	// Mounting holes to affix the extruder into the recess.
	translate([0,0,min(extruder_recess_h/2, base_thickness)])
	rotate([-90,0,0])
	cylinder(r=m4_diameter/2-0.5/* tight */,h=wade_block_depth+2,center=true); 
}

//arcol_mount_holes();
module arcol_mount_holes() 
{ 
	hole_axis_rotation=42.5; 
	hole_separation=30;
	hole_slot_height=4;
	for(mount=[-1,1])
	translate([hole_separation/2*mount,-7,0]) 
	{
		translate([0,0,-1])
		cylinder(r=m4_diameter/2,h=base_thickness+2,$fn=8);
		
		translate([0,0,base_thickness/2])
		//rotate(hole_axis_rotation)
		{
			cylinder(r=m4_nut_diameter/2,h=base_thickness/2+hole_slot_height,$fn=6);
			translate([0,-m4_nut_diameter,hole_slot_height/2+base_thickness/2]) 
			cube([m4_nut_diameter,m4_nut_diameter*2,hole_slot_height],
			center=true);
		}
	}
}

//mendel_parts_v6_hotend ();
module mendel_parts_v6_hotend () 
{
	extruder_recess_d=13.4;
	extruder_recess_h=10; 
	hole_axis_rotation=42.5; 
	hole_separation=30;
	hole_slot_height=5;
	
	// Recess in base
	translate([0,0,-1])
	cylinder(r=extruder_recess_d/2,h=extruder_recess_h+1); 
	
	for(mount=[-1,1])
	rotate([0,0,hole_axis_rotation+90+90*mount])
	translate([hole_separation/2,0,0])
	{
		translate([0,0,-1])
		cylinder(r=m4_diameter/2,h=base_thickness+2,$fn=8);

		translate([0,0,base_thickness/2])
		rotate(-hole_axis_rotation+180)
		{
//			rotate(30)
			cylinder(r=m4_nut_diameter/2,h=base_thickness/2+hole_slot_height,$fn=6);
			translate([0,-m4_nut_diameter,hole_slot_height/2+base_thickness/2]) 
			cube([m4_nut_diameter,m4_nut_diameter*2,hole_slot_height],
					center=true);
		}
	}
}

//grrf_peek_mount_holes();
module grrf_peek_mount_holes()  
{  
	extruder_recess_d=16.5;
	extruder_recess_h=10;

	// Recess in base
	translate([0,0,-1])
	cylinder(r=extruder_recess_d/2,h=extruder_recess_h+1);
	
	for (hole=[-1,1])
	rotate(90,[1,0,0])
	translate([hole*(extruder_recess_d/2-1.5),3+1.5,-wade_block_depth/2-1])
	cylinder(r=1.5,h=wade_block_depth+2,$fn=10);
}

//wildseyed_mount_holes();
module wildseyed_mount_holes()  
{  
	extruder_recess_d=13.4;
	extruder_recess_h=10;

	// Recess in base
	translate([0,0,-1])
	cylinder(r=extruder_recess_d/2,h=extruder_recess_h+1);
	
	for (hole=[-1,1])
	rotate(90,[1,0,0])
	translate([hole*(extruder_recess_d/2-1.5),3+1.5,-wade_block_depth/2-1])
	cylinder(r=1.5,h=wade_block_depth+2,$fn=10);
}