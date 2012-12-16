// layout.scad

// To flag a module to generate an STL file, add '/* OUTPUT */'
// after the module definition and before the opening brace ({).

// ----- Measurements ---------------------------------------------------------

TOM_BEDX = 120;
TOM_BEDY = 120;

// ----- Utilities ------------------------------------------------------------

/* tom_print_bed -- lay down markers for the TOM printable area */
module tom_print_bed() {
	LINE = 0.25;

	% translate( [0,0,LINE/2] )
		difference() {
			cube( [ TOM_BEDX, TOM_BEDY, LINE ], center=true );
			cube( [ TOM_BEDX-2*LINE, TOM_BEDY-2*LINE, 2*LINE ], center=true );
		}
}

/* n_up -- copy a child multiple times */
module n_up( x_qty=1, y_qty=1, xkern=0, ykern=0 ) {
	x_max = TOM_BEDX - xkern;
	y_max = TOM_BEDY - ykern;
	x_size = x_max / x_qty;
	y_size = y_max / y_qty;
	x_start = x_size/2 - x_max/2;
	y_start = y_size/2 - y_max/2;

	for (x = [0 : x_qty-1] ) {
		for (y = [0 : y_qty-1] ) {
			for (i = [0 : $children-1]) {
				translate( [x_start+x*x_size, y_start+y*y_size,0] )
					child(i);
			}
		}
	}
}

module place( translation=[0,0,0], angle=0, hue="gold" ) {
	for (i = [0 : $children-1]) {
		color( hue ) 
			translate( translation ) 
				rotate( a=angle ) 
					child(i);
	}
}

// ----- Imported Parts -------------------------------------------------------

EPSILON = 0.1;
THICKNESS = 1.5;
PRECISION = 1;
PEDASTAL  = 6;

module half_sphere( radius, thickness) {
	difference() {
		sphere( radius, center=true, $fa=PRECISION );
		sphere( radius-thickness-EPSILON, center=true, $fa=PRECISION );
		translate( [0,0,-radius/2 ] )
			cube( [2*radius+1, 2*radius+1, radius ], center=true );
	} 
}

module orb( radius=25, wall=2 ) {
	difference() {
		half_sphere( radius );
		sphere( radius-wall, center=true);
	}
}

module rim( size=25, wall=2 ) {
	translate( [0,0,1] ) {
		difference() {
			cube( [2*size, 2*size, wall ], center=true );
		}
	}
}

module screw_posts( radius=25, wall=2 ) {
	difference() {
		union() {
			for ( i=[0:90:270] ) {
				rotate( [0,0,i] ) translate( [radius-3.5,0,radius/2] ) 
					cube( [PEDASTAL+1,PEDASTAL,radius], center=true ); 
			}
		}
		half_sphere( radius+100, 100-EPSILON );
	}
}

module alignment_posts( radius=25, wall=2,height=2) {
	for ( i=[22.5:45:360] ) {
		rotate( [0,0,i] )
			translate( [radius-5,0,0] )
				cylinder( h=height, r=1, center=true , $fs=1); 
	}
}

module top_orb( radius=25, wall=2) {
	difference() {
		orb( 35, 2 );
		rim( 35, 2.1 );
	}
}

module ring( radius=25, wall=2 ) {
	union() {
		translate( [0,0,2] ) {
			alignment_posts(radius, wall,2);
		}
		difference() {
			sphere( radius, center=true, $fa=PRECISION );
			translate( [0,0,18.5] ) {
				rim(radius, radius);
			}
			translate( [0,0,-18.5] ) {
				rim(radius, radius);
			}
		
			door_blank( radius, wall, 4 );
			translate( [0,0,5] ) {
				alignment_posts(radius, wall);
			}
		}
	}
}

module inner_ring( radius=25, wall=2 ) {
	difference() {

		sphere( radius-wall, center=true );

		translate( [0,0,2]) {
			union() {
				translate( [0,0,18.5] ) {
					rim(radius, radius);
				}
				translate( [0,0,-18.5] ) {
					rim(radius, radius);
				}
				for ( i=[0:45:270] ) {
					rotate( [0,0,i] )
						translate( [0,0,1] )
						cube( [2*radius-10*wall,21,4], center=true ); 
				}
			}
		}
		screw_holes(radius, wall);
		translate( [0,0,3] ) {
			alignment_posts(radius, wall, 5);
		}
	}
}

module door_blank( radius=25, wall=2, thickness=2) {
	difference() {
		union() {
			for ( i=[0:90:270] ) {
				rotate( [0,0,i] )
					translate( [0,0,1] )
					cube( [2*radius-2-wall,8,thickness], center=true ); 
			}
			for ( i=[22.5:45:270] ) {
				rotate( [0,0,i] )
					translate( [0,0,1] )
					cube( [2*radius-8*wall,22.5,thickness], center=true ); 
			}
		}
	}
}

module screw_holes( radius=25, wall=2, size=3 ) {
	for ( i=[0:90:270] ) {
		rotate( [0,0,i] )
			translate( [radius-5,0,0] )
				cylinder( h=10, r=size/2, center=true , $fs=1); 
	}
}

module door( radius=25, wall=2, thickness=2 ) {
	union() {
		difference() {
			door_blank(radius, wall, thickness);
			screw_holes(radius,2);
			cylinder( h=2, r=3, center=true , $fs=1);
			for ( i=[0:90:180] ) {
					rotate( [0,0,i] )
						translate( [radius-15,0,0] )
							cylinder( h=10, r=1.5, center=true , $fs=1); 
			}
		}
		translate( [0,0,thickness] )
			cylinder( h=2, r=5, center=true, $fs=1);
		for ( i=[0:90:180] ) {
				rotate( [0,0,i] )
					translate( [radius-15,0,thickness] )
						cylinder( h=2, r=3, center=true , $fs=1); 
		}
	}
}



module breakout(radius, wall) {
	translate( [0,0,0] ) {
		color ( "yellow" )  top_orb( radius, wall );	
	}
	
	translate( [0,0,-5] ) {
		color ("blue") inner_ring(radius, wall);
	}

	translate( [0,0,-10] ) {
		color ("green")  ring( radius, wall );
	}

	translate( [0,0,-15] ) {
		color ("red") door( radius, wall );
	}
}

// ----- Plates ---------------------------------------------------------------

tom_print_bed();

breakout(35, 2);

// top_orb(35,2);
// inner_ring(35,2);
// ring(35,2);
// door(35, 2);

