#!/usr/bin/perl
# Library headers
my $libdir;
BEGIN {
 #find path to Physics-OPC-x.x.x/lib directory containing the OPC perl modules.
 use Cwd 'cwd';                      # to retrieve current working dir
 use File::Spec qw/splitdir catdir/; # to split or combine directory names
 #first check if environment variable is set
 $libdir = File::Spec->catdir($ENV{OPC_HOME}, 'lib');

 unless (-d $libdir) {
   #not found, now check in path to directory from which script is run 
   my @mydirs =  File::Spec->splitdir( Cwd->cwd() );
   while (@mydirs) {
     $libdir = File::Spec->catdir (@mydirs, $OPC_VERSION, 'lib');
     last if -d $libdir;
     pop @mydirs;
   }
 }
}

use lib "$libdir";
use Physics::OPC;
$VERBOSE = 0;

$field = field file => '6microns_aperp_41_x.dfl';
    
$optics = optics "
    # 1st propagation
	fresnel z=6.59481145 M=5
	
    diaphragm r=0.025
	hole r=0.0025 (
		 # Path outside the resonator
		 dump var=output
		 fresnel z=2.0
		 dump var=far )
	mirror r=7.49481145 R=98%
	dump var = mirror1
	
	fresnel z=14.989622

	diaphragm r=0.025
	mirror r=7.49481145 R=98%
	dump var = mirror2
	
	fresnel z=6.59481145 M=0.2";
   
run $optics;
move $mirror1 => "M1.dfl";
move $output => "output.dfl";
move $far => "far.dfl";
move $mirror2 => "M2.dfl";
# zshift $field -2.409316010064E-04;
move $field => "entrance.dfl";

# remove temporary files
unlink glob "op* var1* var2*";
