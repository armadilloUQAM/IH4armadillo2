#!/bin/perl
# Author : JG
# Date   : 17 fev 2016
# Install Helper for Armadillo2

use strict;
use warnings;
use Data::Dumper;

# TO DO
# Ajouter FILES et ajouter le chargement des fichiers
# Add activation by default $initiales."_ActivatedByDefault"
# Add list option(s)

# ======================================================================
# Structured File options
# ======================================================================
=begin comment
The structured file should looks like that :
(needed) = (*)

NB: | is the column separator.


# Program informations (*)
0   |1           |2              |3                                        |4                  |5                     |6         |7                    |8   |9           |10                     |11
P   |Program name|NormalExitValue|[Linux<>Path]/[Mac<>Path]/[Windows<>Path]|Armadillo Menu/Type|number of box's inputs|OutputPath|Publication Reference|Help|Descriptions|[Website]/[WebServices]|Save output Files from outputPath to dest<>dest<>(ect.)

# Docker informations
0   |1                |2                                  |3                           (|4                                                     )|5      |6
D   |docker image name|Command to execute in the container|Shared folder path in docker(|docker Name (if not here will be the docker name link))|Remarks|Copy Dockers Files Directories source<>source<>(etc.) to sharedfolder

# Input Options (*)
0   |1         |2           |3             |4                                           |5                 |6
I   |Input type|[true,2,3,4]|Connector Name|OneConnectorOnlyFor || (OR) SolelyConnectors|Command if needeed|Extention
Choose Input type between all types from ./src/biologic : Alignment, Ancestor, BamFile, Biologic, Blast, BlastDB, BlastHit, DataSet, FastaFile, FastqFile, Genome, GenomeFile, HTML, ImageFile, InfoAlignment, InfoMultipleSequences, InfoSequence, Input, ListSequence, Matrix, Model, MultipleAlignments, MultipleSequences, MultipleTrees, Outgroup, Output, OutputText, Phylip, Phylip_Distance, Phylip_Seqboot, PositionToSequence, ProteinAlignment, Results, RootedTree, SamFile, Sample, Sequence, SOLIDFile, Text, TextFile, Tree, Unknown, UnrootedTree, Workflows
(update in 2015/12/01)

# Output Options
0   |1           |2             |3                 |4
O   |Output type |Connector Name|Command if needeed|Extention  (see if several extention options add a list)

# Menu Options (*)
0   |1           |2
M   |Menu option |Tab/Panel linked (enabled or disabled if selected)|

# Title Name (*)
0   |1
T   |Name

# Subtitle Name
0   |1
S   |Name

# Command options (*)
0   |1           |2          |3                |4     |5                                  |6    |7    |8            |9         |10
C   |Command name|shortName  |(r)button or box |*list*|value for *int* or *te?xt* or *dir*|Help |Label|*Opposite To*|Parents of|selected by default (true|(falseORempty))
*list* are : int (integer), flo (float), lon (long), sho (short), dou (double), te?xt, dirFile, dirFiles, dirRep, boo (boolean), list, listDir (not yet implemented)
*int* if it's (int|integer|float|long|short|double) a range set as this default<>min<>max<>jump.
Int     ex: |int|1<>-inf<>50<>10|
Boolean ex: |boo|1
double  ex: |dou|1.0<>-inf<>50.0<>10.0
*te?xt* it's a string
*dir*   it's a canonical or relative string to the directory. It's used for dirFile, dirFiles, dirRep
dirFile  (choose a file in a list) /path/to/the/file
dirFiles (choose files in a list) /path/to/files
dirRep   (select a directory) /path/to/directory
*list*  it's a combobox with options, just one selection option1<>option2<>option3<>etc.
*listDir* it's a combobox with options, just one selection /path/to/directory <>[.filesExtention1<>.filesExtention2] (not yet implemented)
*Opposite To* can have several command like opposite to command1<>command2<>command3 remove the - or -- in front of the command

=end comment
=cut

# ======================================================================
# Variables
# ======================================================================

# Gobal Variables
my $pTAEdit = "";
my $pTAProg = "";
my $pTAProp = "";
my $pTABiol = "";

# Date obtention
my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);
my @months = qw(Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec);
my $date = $months[$mon]." ".($year+1900);

# ======================================================================
# Programme
# ======================================================================

# ARGV infos extractor
my ($file,$test,$author,$arg,$help,$sepf,$dir) = &getArgv(\@ARGV);

if ($help !=1){
    
    ($pTAEdit,$pTAProg,$pTAProp,$pTABiol) = &setOutputPath($test,$dir);
    
    print "#################################################################\n".
          "# Program $0 starts\n".
          "#################################################################\n";
    print "Test file\n";
    my $boolFile = &testFile($file,$sepf);
    if ($boolFile==0) {
        &printDone();
        print "Extract Data from file\n";
        my %commands = &extractPgrmOrganisation($file);
        &printDone();
        if ($arg=~/e/ ||$arg=~/all/) {
            print "Create Editor Java File Start\n";
            %commands = &createJavaEditorFile($file,\%commands);
            &printDone();
            print "Create Editor Java Form Start\n";
            %commands = &createJavaEditorForm($file,\%commands);
            &printDone();
        }
        if ($arg=~/j/ ||$arg=~/all/) {
            print "Create Program Java File Start\n";
            %commands = &createProgramsFile($file,\%commands);
            &printDone();
        }
        if ($arg=~/f/ ||$arg=~/all/) {
            print "Create Properties File Start\n";
            %commands = &createPropertiesFile($file,\%commands);
            &printDone();
        }
        print "Programme $0 has finished without trouble\n";
    } else {
        print "\nEach Previous line(s) has (have) a problem.\n".
              "Ex: P|Hello|World\n";
        print "The file $file can't be used in this program\n";
    }
} else {
    print "Programme $0 has finished with help presentation\n";
}
# ======================================================================
# Fonctions :
# ======================================================================

# Print done
sub printDone {
    print "\n\t\t> Done\n";
}

# ===============================
#
# ARGV Extractor
#
# ===============================

sub getArgv {
    my @ARGV = @{$_[0]};
    # Default Options
    my $file    = "";
    my $test    = 0;
    my $author  = "John Doe";
    my $arg     = "all";
    my $sep     = "|";
    my $help    = 0;
    my $helpAdd = "";
    my $dir     = "";
    my $aArg  = join (" ",@ARGV);
    my @aArgs = split ("-",$aArg);
    
    for (my $i=0;$i<scalar @aArgs;$i++) {
        $aArgs[$i] =~ s/\s*$// if ($aArgs[$i]=~ /\s*$/);
        $aArgs[$i] = "." if ($aArgs[$i] eq "");
        ($help)   = 1                                if ($aArgs[$i]=~/^[help|h]/);
        ($helpAdd)= $aArgs[$i]=~/^[help|h] (\w{1})/  if ($aArgs[$i]=~/^[help|h] \w{1}/);
        ($test)   = 1                                if ($aArgs[$i]=~/^t/);
        ($file)   = $aArgs[$i]=~/^f (.*)$/           if ($aArgs[$i]=~/^f/);
        ($arg)    = $aArgs[$i]=~/^c (\w{1,3})/       if ($aArgs[$i]=~/^c \w{1,3}/);
        ($author) = $aArgs[$i]=~/^a ([\w|\s]+)/      if ($aArgs[$i]=~/^a [\w|\s]+/);
        ($sep)    = $aArgs[$i]=~/^s (.*)$/           if ($aArgs[$i]=~/^s/);
        ($dir)    = $aArgs[$i]=~/^d (.*)$/           if ($aArgs[$i]=~/^d/);
    }
    
    # Program setting
    if ($arg!~/all/) {
        my $val = $arg;
        $val =~ s/[ejf]//g;
        if (length($val)>0) {
            print   "\nThis ".$arg." is not a good argument";
            $help = 1;
        }
    }
        
    # File setting
    if ($file eq "") {
        $help = 1;
    }
    
    if ($helpAdd ne "") {
#        print "yes\n";
#        die;
    }
    
    # Armadillo dir and test zone
    if ($dir eq "" && $test==0) {
        $help = 1;
    } elsif ($dir ne "" && $test!=0) {
        $dir =~ s/[\/,\\]$//;
    }
    

    
    # Test help
    if ($help == 1) {
        print   "\n\n########".
                "\n# HELP #".
                "\n########".
                "\n# Path to Armadillo -d [PATH/TO/ARMADILLO] (needed if -t is not used)".
                "\n# File -f [PATH/FILENAME] (needed)".
                "\n# Set Columns File separator -s \"|\"".
                "\n(default is | the pipe, don't forget the quote if it's necessary)".
                "\n# Constructions options -c [all,e,j,f] (default all)".
                "\n\te   for Editor files,".
                "\n\tj   for Program file,".
                "\n\tf   for Properties file,".
                "\n\tall for ejf files,".
                "\n# Outputs as a test in ./test/ -t (default is without -t)".
                "\n# Set Author Name (alphanumeric or \"_\") with -a (Default : John Doe)".
                "\n\n# Standard Command line looks like:".
                "\n\tperl install_programs.pl -f RNAfold.csv -t -a John Doe -c ej -s \"|\"\n\n";
    }
    return $file,$test,$author,$arg,$help,$sep,$dir;
}

# ===============================
#
# Set OutPutPath
#
# ===============================

sub setOutputPath {
    my $test = $_[0];
    my $dir  = $_[1];
    
    if ($test == 0) {
        $pTAEdit = $dir."/src/editors/";
        $pTAProg = $dir."/src/programs/";
        $pTAProp = $dir."/data/properties/";
    } else {
        $pTAEdit = "./test/";
        $pTAProg = "./test/";
        $pTAProp = "./test/";
    }
    my $pTABiol  = $dir."/src/biologic/";
    
    return ($pTAEdit,$pTAProg,$pTAProp,$pTABiol);
}


# ===============================
#
# Test csv file
#
# ===============================

sub testFile {
    my $file = $_[0];
    my $sep  = $_[1];
    # Open the file and test lines
    open my $in , $file or die $!;
    my $b_file = 0;
    my $count = 0;
    while (my $line = <$in>){
        chomp $line;
        $count++;
        if ($line ne "") {
            my @tab = split ($sep,$line);
            if (scalar @tab == 0) {
                print ">>".$line."<<\n";
                print "\nLine number : ".$count."\n";
                $b_file = 1;
            }
        }
    }
    close $in;
    return $b_file;
}

# ===============================
#
# Create a new program Editor interface
#
# ===============================


=begin comment





========================================================================
                    EXTRACT PROGRAM ORGANISATION
========================================================================





=end comment
=cut


# ===============================================
#     FUNCTION to extract program organisation from csv file
# in  : csv file
# out : several hash tab with informations
# ===============================================
sub extractPgrmOrganisation {
    my $file      = $_[0];
    my ($i,$o,$m,$t,$s,$c) = (0)x6;
    my %structPgrm = ();
    
    # Additional informations
    my (@tab_value,@tab_text,@tab_comb,@tab_box,@tab_RButton,@tab_button,@event);
    my (%h_menu,%h_bv,%h_bl,%h_bh,%h_bo,%h_bp,%h_ba,%h_in,%h_ou,%initials) = ();
    # h_bv = hash table with link between button or box and value;
    # h_bl = hash table with link between button or box and label; 
    # h_bh = hash table with link between button or box and help; 
    # h_bo = hash table with link between button or box and opposite; 
    # h_do = hash table with docker informations; 
    # h_ba = hash table with Default Selection; 
    # h_in = hash table with input informations; 
    # h_ou = hash table with output informations; 
    # initials = hash table of all initials; 
    
    # Link type options
    my %linkType = (
        "_BooValue" => "JSpinner",
        "_BytValue" => "JSpinner",
        "_IntValue" => "JSpinner",
        "_FloValue" => "JSpinner",
        "_LonValue" => "JSpinner",
        "_ShoValue" => "JSpinner",
        "_DouValue" => "JSpinner",
        "_Text"     => "JTextField",
        "_DirFile"  => "JButton",
        "_DirFiles" => "JButton",
        "_DirRep"   => "JButton",
        "_List"     => "JComboBox",
        "_Label"    => "JLabel",
        "_Dir"      => "JButton",
        "_RButton"  => "JRadioButton",
        "_button"   => "JButton",
        "_jButton"  => "JButton",
        "_Box"      => "JCheckBox",
        "_jLabel"   => "JLabel"
    );
    
    # Colors options
    my @colorModeOptions   = ("BLUE","GREEN","ORANGE","CYAN","RED","PURPLE");
    my %colorModeRelations = (
        "Alignments"=>"BLUE",
        "Tree"=>"GREEN",
        "NGS"=>"ORANGE",
        "System"=>"RED"
    );
    
    #DockerKeyWord is armadilloWF
    my $kword = "armadilloWF";
    
    # Open the file and extract the value
    open my $in , $file or die $!;
    
    my $count = 0;
    my $tp_c  = 0;
    my $boolean_die = 0;
    
    while (my $line = <$in>){
        my $val = "";
        my @tab = ();
        
        if ($line=~/^[P,D,I,O,M,T,S,C].*$/) {
            
            ($val)=$line=~/^\w(.*)$/i;
            $val =~ s/^\Q$sepf\E//;
            $val =~ s/\Q$sepf\E\Q$sepf\E/\Q$sepf\E\.\Q$sepf\E/g;
            @tab = split (/\Q$sepf\E/,$val) ;
            $tab[0]=~ s/ /_/g if ($line=~/^[P,D,I,O,M,T,S].*$/);
            foreach my $v (@tab) {
                $v =~ s /\\// if ($v=~/\\$/);
                $v = "" if ($v eq ".");
            }
            if ($tab[0] eq "") {
                print "A line can't have an empty name\n";
                die;
            }
        }
        
        my $lg_tab = scalar @tab; #tab length
        
        # Program structure checkpoint
        if ($s >= 2 && $t > 0 && exists $initials{$t}) {
            $structPgrm{$initials{$t}."_tabpanel"} = $t;
        } elsif ($s <=1 && $t > 0 && exists $initials{$t}) {
            $structPgrm{$initials{$t}."_panel"} = $t;
        }
        
        # Program Informations
        if ($line=~/^P.*/i) { #PGRM INFO
            if ($lg_tab < 4) {
                print "\tThe Program need to have at least 5 columns. P|Name|NormalExitValue|Paths|ArmadilloMenu\n";
                die;
            }
            for (my $j=0;$j<$lg_tab;$j++) {
                if ($tab[$j] ne ""){
                    $structPgrm{"0"}         = $tab[$j] if ($j==0);  # Program name
                    $structPgrm{"0_exitVal"} = $tab[$j] if ($j==1);  # Normal Exit Value
                    $structPgrm{"0_pgrPath"} = $tab[$j] if ($j==2);  # [Linux<>Path]/[Mac<>Path]/[Windows<>Path]
                    $structPgrm{"0_menu"}    = $tab[$j] if ($j==3);  # Armadillo menu
                    $structPgrm{"0_nbInputs"}= $tab[$j] if ($j==4);  # Number of inputs
                    $structPgrm{"0_outPath"} = $tab[$j] if ($j==5);  # [Output Path]
                    $structPgrm{"0_pub"}     = $tab[$j] if ($j==6);  # Publication reference
                    $structPgrm{"0_help"}    = $tab[$j] if ($j==7);  # Help informations
                    $structPgrm{"0_desc"}    = $tab[$j] if ($j==8);  # Description
                    $structPgrm{"0_web"}     = $tab[$j] if ($j==9);  # Web infos
                    $structPgrm{"0_save"}    = $tab[$j] if ($j==10); # Saved during output files from to
                }
            }
            ($i,$o,$m,$t,$s,$c) = (0)x6;
        }
        elsif ($line=~/^D.*/i) { #DOCKER INFO
            #"docker image link";"Path to the program in the container";"Shared folder path in docker";"docker Name" (if not here will be the docker name link)
            for (my $j=0;$j<$lg_tab;$j++) {
                if ($tab[$j] ne ""){
                    $structPgrm{"0_doImage"}        = $tab[$j] if ($j==0); # docker image link
                    $structPgrm{"0_doPgrmPath"}     = $tab[$j] if ($j==1); # Path to the program in the container
                    $structPgrm{"0_doSharedFolder"} = $tab[$j] if ($j==2); # Shared folder path in docker
                    $structPgrm{"0_doName"}         = $tab[$j] if ($j==3); # docker Name
                    $structPgrm{"0_doCopyFiles"}    = $tab[$j] if ($j==4); # Docker remarks
                    $structPgrm{"0_doCopyFiles"}    = $tab[$j] if ($j==5); # Copy files from docker to local file (copy, change chmod, delete)
                }
            }
            if (!($structPgrm{"0_doPgrmPath"})){
                $structPgrm{"0_doPgrmPath"}="./";
            }
            if (!($structPgrm{"0_doSharedFolder"})){
                $structPgrm{"0_doSharedFolder"}="\$HOME";
            }
            if (exists $structPgrm{"0_doName"} && $structPgrm{"0_doImage"}!~/_armadilloWF_/) {
                $structPgrm{"0_doName"} = $structPgrm{"0_doName"}."_".$structPgrm{"0"}."_".$kword."_0";
            } elsif (!(exists $structPgrm{"0_doName"})) {
                if ($structPgrm{"0_doImage"}=~/\//){
                    ($structPgrm{"0_doName"}) = $structPgrm{"0_doImage"} =~ /\w+\/(\w+)$/;
                    $structPgrm{"0_doName"} = $structPgrm{"0_doName"}."_".$structPgrm{"0"}."_".$kword."_0";
                } else {
                    $structPgrm{"0_doName"} = $structPgrm{"0_doImage"}."_".$structPgrm{"0"}."_".$kword."_0";
                }
            }
        }
        elsif ($line=~/^I.*/i) { #INPUT INFO
            $i++;
            for (my $j=0;$j<$lg_tab;$j++) {
                if ($tab[$j] ne ""){
                    $h_in{$i."_type"}        = $tab[$j] if ($j==0); # Choose Input type between all types from ./src/biologic : Alignment, Ancestor, BamFile, Biologic, Blast, BlastDB, BlastHit, DataSet, FastaFile, FastqFile, Genome, GenomeFile, HTML, ImageFile, InfoAlignment, InfoMultipleSequences, InfoSequence, Input, ListSequence, Matrix, Model, MultipleAlignments, MultipleSequences, MultipleTrees, Outgroup, Output, OutputText, Phylip, Phylip_Distance, Phylip_Seqboot, PositionToSequence, ProteinAlignment, Results, RootedTree, SamFile, Sample, Sequence, SOLIDFile, Text, TextFile, Tree, Unknown, UnrootedTree, Workflows
                    $h_in{$i."_connectNum"}  = $tab[$j] if ($j==1); # True/ConnectorNum
                    $h_in{$i."_connectName"} = $tab[$j] if ($j==2); # Connector Name
                    $h_in{$i."_connectType"} = $tab[$j] if ($j==3); # OneConnectorOnlyFor/All/SolelyConnectors
                    $h_in{$i."_command"}     = $tab[$j] if ($j==4); # Command if needded
                    $h_in{$i."_extention"}   = $tab[$j] if ($j==5); # Extention file
                    
                    #if (!(exists $h_in{$i."_command"}) || $h_in{$i."_command"} eq "") {
                }
            }
            if (exists $h_in{$i."_extention"} && $h_in{$i."_extention"}!~/^\..*/) {
                $h_in{$i."_extention"} = ".".$h_in{$i."_extention"};
            }
        }
        elsif ($line=~/^O.*/i) { #OUTPUT INFO
            $o++;
            for (my $j=0;$j<$lg_tab;$j++) {
                if ($tab[$j] ne ""){
                    $h_ou{$o."_type"}        = $tab[$j] if ($j==0); # Choose Input type between all types from ./src/biologic : Alignment, Ancestor, BamFile, Biologic, Blast, BlastDB, BlastHit, DataSet, FastaFile, FastqFile, Genome, GenomeFile, HTML, ImageFile, InfoAlignment, InfoMultipleSequences, InfoSequence, Input, ListSequence, Matrix, Model, MultipleAlignments, MultipleSequences, MultipleTrees, Outgroup, Output, OutputText, Phylip, Phylip_Distance, Phylip_Seqboot, PositionToSequence, ProteinAlignment, Results, RootedTree, SamFile, Sample, Sequence, SOLIDFile, Text, TextFile, Tree, Unknown, UnrootedTree, Workflows
                    $h_ou{$o."_connectName"} = $tab[$j] if ($j==1); # Connector Name
                    $h_ou{$o."_command"}     = $tab[$j] if ($j==2); # Command if Needed
                    $h_ou{$o."_extention"}   = $tab[$j] if ($j==3); # Extention file
                }
            }
            if (exists $h_ou{$o."_extention"} && $h_ou{$o."_extention"}!~/^\..*/) {
                $h_ou{$o."_extention"}  = ".".$h_ou{$o."_extention"};
            }
        }
        # Program structure
        elsif ($line=~/^M.*/i) { #MENU INFO
            $structPgrm{"0_".$m} =$tab[0]."_RButton";
            
            if (scalar @tab > 1 && $tab[1] ne "") {
                $tab[1] =~ s/ /_/g;
                $h_menu{"0_".$m} =$tab[1];
            } else {
                print "\n\t\"WARNING\"".
                      "\n\tThe ".$tab[0]." is not assign to enabled something. It's ok if it's the default option\n";
            }
            $m++;
        }
        elsif ($line=~/^T.*/i) { #TITLE (OR TABLE) INFO
            if ($s == 1) {
                print "\tThe title $structPgrm{$t} have just one subtitle.\nIt's not relevant.\nPlease remove it and relaunch\n";
                die;
            }
            $t++;
            $s=0;
            $c=0;
            
            &obtainInitials(\%initials,$tab[0],1,$t);
            $structPgrm{$t}=$tab[0];
            
            # Count Solution
            $count = $tp_c if ($tp_c > $count);
            $tp_c  = 0;
            $structPgrm{"numberOfTitle"} = $t;
        }
        elsif ($line=~/^S.*/i) { #SUBTITLE (OR TAB-TABLE) INFO
            $s++;
            $c=0;
            
            my $ref = $t."_".$s;
            &obtainInitials(\%initials,$tab[0],1,$ref);
            my $initiales = $initials{$ref};
            $structPgrm{$initiales."_Spanel"} = $ref;
            $structPgrm{$ref}=$tab[0];
        }
        elsif ($line=~/^C.*/i) { #COMMAND LINE INFO
            $c++;
            
            if ( scalar @tab < 7) {
                print "\nThe commands ".$tab[0]." don't respect the minimum of six columns. It has ".scalar @tab." columns and 7, after [\"C\";], are needed. The program will die.\n\n";
                $boolean_die = 1;
            }
            my $prefix = 1;
            $prefix = 2 if ($tab[0]=~/^--/);
            $tab[0]=~s/^-?-//;
            $tab[0]=~s/-([a-z,A-Z])/\u$1/g;
            $tab[0]=~s/_([a-z,A-Z])/\u$1/g;
            $tab[0]=~s/-//g;
            
            # Add info tab[0 to 2] Prepare initials informations START
            my $initiales = "";
            if ($s==0) {
                $initiales = $initials{$t};
            } else {
                $initiales = $initials{$t."_".$s};
            }
            $initiales = $initiales."_".$tab[0]  if ($prefix ==1);
            $initiales = $initiales."__".$tab[0] if ($prefix ==2);
            
            if ($tab[2]eq"box") {
                $initiales = $initiales."_Box";
                push (@tab_box,$initiales);
            } elsif ($tab[2]eq"rbu") {
                $initiales = $initiales."_RButton";
                push (@tab_RButton,$initiales);
            } elsif ($tab[2]eq"bu") {
                $initiales = $initiales."_Button";
                push (@tab_button,$initiales);
            }
            
            if (exists ($initials{$t."_".$s."_".$c})) {
                print "".$tab[0]." already exists. Please remove one of them\n";
            } else {
                $initials{$t."_".$s."_".$c} = $initiales;
            }
                
            $structPgrm{$t."_".$s."_".$c} = $initiales;
            if ($tab[1] ne "") {
                $structPgrm{$initiales} = $tab[0]."/".$tab[1] ;
            } else {
                $structPgrm{$initiales} = $tab[0];
            }
            # Prepare initials informations END
            
            # Add info tab[3 & 4] for value or text or dir
            my $string = "";
            if (scalar @tab > 4 && &goodTab4Values(\@tab)) {
                if ($tab[3] =~/(byt|int|dou|flo|lon|sho|boo)/i) {
                    my ($k) = $tab[3]=~/^(.{3})/;
                    $k =~ s/^(.)(.*)/\u$1$2/;
                    $string = $initiales."_".$k."Value";
                    push (@tab_value,$string);
                } elsif ($tab[3] =~/te?xt/i) {
                    $string = $initiales."_Text";
                    push (@tab_text,$string);
                } elsif ($tab[3] =~/(dirFiles|dirFile|dirRep)/i) {
                    my ($k) = $tab[3]=~/^(.{5,8})/;
                    $k =~ s/^(.)(.{2})(.)(.*)/\u$1$2\u$3$4/;
                    $string = $initiales."_".$k; # For button
                    $structPgrm{$string} = $k;
                    $string = $initiales."_Text"; # For text
                    push (@tab_text,$string);
                } elsif ($tab[3] =~/list/) {
                    $string = $initiales."_List";
                    push (@tab_comb,$string);
                } else {
                    $structPgrm{$string} = "";
                }
                if ($tab[4]ne"" && $tab[3]ne""){
                    $structPgrm{$string} = $tab[4];
                    $h_bv{$initiales}=$string;
                }
            } else {
                print "\nWrong values for ".$tab[0]."\n";
                print ">>>".$tab[3]."\n";
                print ">>>".$tab[4]."\n";
                $boolean_die = 1;
            }
            # Add info tab[5] for help
            if (scalar @tab > 5) {
                $structPgrm{$initiales."_Help"} = $tab[5];
                $h_bh{$initiales} = $initiales."_Help";
            }
            # Add info tab[6] remarks
            if (scalar @tab > 6 && $tab[6] ne "") {
                $structPgrm{$initiales."_Label"} = $tab[6];
                $h_bl{$initiales} = $initiales."_Label";
            }
            # Add info tab[7] opposite
            if (scalar @tab > 7 && $tab[7] ne "") {
                $structPgrm{$initiales."_OppositeTo"} = $tab[7];
                $h_bo{$initiales} = $initiales."_OppositeTo";
            }
            # Add info tab[8] Parent of
            if (scalar @tab > 8 && $tab[8] ne "") {
                $structPgrm{$initiales."_ParentsOf"} = $tab[8];
                $h_bp{$initiales} = $initiales."_ParentsOf";
            }
            
            # Add info tab[8] Parent of
            if (scalar @tab > 9 && $tab[9] =~/[true]/i) {
                $structPgrm{$initiales."_ActivatedByDefault"} = $tab[9];
                $h_ba{$initiales} = $initiales."_ActivatedByDefault";
            }
            
            # Count number of Commands for vertical size
            $tp_c++;
        }
    }
    close $in;
    
    # Extract Reorganisation and tests
    &findInitialsFromValues(\%structPgrm,\%h_bo,\%initials);
    &findInitialsFromValues(\%structPgrm,\%h_bp,\%initials);
    &testPgrmSaved(\%structPgrm);
    # Test and Add fiofiles extentions
    my %bioFiles = &testInputsSaved(\%structPgrm,\%h_in);
    &testOutputSaved(\%structPgrm,\%h_ou,\%bioFiles);
    
    # Count for editor size
    $count = $tp_c if ($tp_c > $count);
    $structPgrm{"number"} = $count;
    $structPgrm{"numberOfTitle"} = 0 if ($t == 0);
    $structPgrm{"numberOfTitle"} = $t if ($t > $structPgrm{"numberOfTitle"});
    
    # Prepare h_tabPanel
    my %h_tabPanel = &prepareH_tabPanel(\%structPgrm,\%initials);
    
    # Prepare inputs
    &inputsConcat(\%h_in);
    
    # Add Array values in program structure
    $structPgrm{"colorModeOptions"} = &fromAtoV(\@colorModeOptions); #Initials of value
    $structPgrm{"tab_value"}        = &fromAtoV(\@tab_value); #Initials of value
    $structPgrm{"tab_text"}         = &fromAtoV(\@tab_text); #Initials of text
    $structPgrm{"tab_comb"}         = &fromAtoV(\@tab_comb); #Initials of combobox
    $structPgrm{"tab_box"}          = &fromAtoV(\@tab_box); #Initials of box
    $structPgrm{"tab_RButton"}      = &fromAtoV(\@tab_RButton); #Initials of RButtons
    $structPgrm{"tab_button"}       = &fromAtoV(\@tab_button); #Initials of buttons
    
    # Add Hash values in program structure
    $structPgrm{"bioFiles"}    = &fromHtoV(\%bioFiles); #Biologic Files used in that program
    $structPgrm{"h_bv"}        = &fromHtoV(\%h_bv); #Button -> Value (Initials)
    $structPgrm{"h_bl"}        = &fromHtoV(\%h_bl); #Button -> Label (Initials)
    $structPgrm{"h_bh"}        = &fromHtoV(\%h_bh); #Button -> Help (Initials)
    $structPgrm{"h_bo"}        = &fromHtoV(\%h_bo); #Button -> Opposite to (Initials)
    $structPgrm{"h_bp"}        = &fromHtoV(\%h_bp); #Button -> Parent of
    $structPgrm{"h_ba"}        = &fromHtoV(\%h_ba); #Button -> Default Selection; 
    $structPgrm{"h_in"}        = &fromHtoV(\%h_in); #In Num -> Infos
    $structPgrm{"h_ou"}        = &fromHtoV(\%h_ou); #Out Num -> Infos
    $structPgrm{"h_tabPanel"}  = &fromHtoV(\%h_tabPanel); #TabPanel -> Tab && Panel -> TabPanel
    $structPgrm{"initials"}    = &fromHtoV(\%initials); #Initials -> Infos
    $structPgrm{"linkType"}    = &fromHtoV(\%linkType); #Link between type and java extension
    
    # Menu Creation
    %h_menu = &findRefForMenu(\%structPgrm,\%h_menu);
    $structPgrm{"h_menu"}      = &fromHtoV(\%h_menu);#Menu -> enabled part
    
    # Event values Extractions
    &getEventTabValues(\@event,\%structPgrm);
    $structPgrm{"event"}       = &fromAtoV(\@event); #EventsDataType
    
    # Program killer
    die if ($boolean_die ==1);
    
    return %structPgrm;
}

        # From Hash to Value
        sub fromHtoV{
            my %h = %{$_[0]};
            my $v = "";
            
            foreach my $k (keys %h) {
                if ($v eq "") {
                    $v = "$k;$h{$k}";
                } else {
                    $v = $v.";"."$k;$h{$k}";
                }
            }
            return $v;
        }

        # From Value to Hash
        sub fromVtoH{
            my $v = $_[0];
            my %h;
            my $y=0;
            my @t = split (";",$v);
            for (my $i = 0; $i < scalar @t ; $i=$i+2) {
                $y = $i+1;
                $h{$t[$i]}=$t[$y];
            }
            return %h;
        }

        # From Array to Value
        sub fromAtoV{
            my @a = @{$_[0]};
            my $v = join ("<>",@a);
            return $v;
        }

        # From Value to Array
        sub fromVtoA{
            my $v = $_[0];
            my @t = split ("<>",$v);
            return @t;
        }

        # Fix component size
        sub getComponentsHeight {
            my %structPgrm  = %{$_[0]};
            my $val = 0;
            $val = ($structPgrm{"numberOfTitle"}*$structPgrm{"number"}*20+50);
            $val += 50 if (exists $structPgrm{"0_0"});
            $val = 125 if ($val < 125);
            return $val;
        }

    # ===============================================
    #     SUB FUNCTION OF extractPgrmOrganisation
    # in  : $val = text to extract Initials,
    #       $num = value for number extractions
    #       $ref = the reference (title, sub title, commande) to know if the value already exist
    # out : create a unique and new initial if it doesnt exist for the reference
    # ===============================================

    sub obtainInitials {
        my $initials = $_[0];
        my $val      = $_[1];
        my $num      = $_[2];
        my $ref      = $_[3];
        
        #my (@tab) = $val=~ /([A-Z0-9])/g;
        my (@tab) = $val=~ /([\s\-_]|^)([a-zA-Z0-9-_]{$num})/g;
        my $j= join ("",@tab);
        $j =~ s/_//g;
        if ($ref =~ /_/) {
            my ($t,$s) = $ref=~ /^(\d+)_(\d+)$/;
            $j = $initials->{$t}."_".$j;
        }
        
        # Recursivity to found an initials
        if (exists $initials->{$j}) {
            my $num1 = $num+1;
            if ($num1 < length $val) {
                &obtainInitials($initials,$val,$num1,$ref);
                $j = $initials->{$ref};
            } else {
                print "Please change title or subtitle $val. It's too close to another one !\n";
                die;
            }
        }
        
        $initials->{$j}   = $ref;
        $initials->{$ref} = $j;
        return;
    }
    
    # ===============================================
    #     SUB FUNCTION OF extractPgrmOrganisation
    # Object : find the reference for the menu witch will enabled what
    # in  : 
    # out : 
    # ===============================================

    sub findRefForMenu {
        my %s1 = %{$_[0]};
        my %h2 = %{$_[1]};
        
        my %h3 =();
        
        foreach my $k1 (keys %s1) {
            foreach my $f2 (keys %h2) {
                if ($s1{$k1} eq $h2{$f2}) {
                    $h3{$f2} = $k1;
                }
            }
        }
        return %h3;
    }

    # ===============================================
    #     SUB FUNCTION OF extractPgrmOrganisation
    # Object : Valid extention values
    # in  : tab[3] and tab[4]
    # out : true 1 false 0
    # ===============================================

    sub goodTab4Values {
        my $tab = $_[0];
        my $t   = $tab->[3];
        my $v   = $tab->[4];
        my $boo = 1;
        # Tests numeric values
        if ($t =~/(byt|int|dou|flo|lon|sho|boo)/) {
            if ($v =~ /^-?\d+(\.\d+)?(<>(-?\d+)?(\.\d+)?){0,3}$/) {
                while ($v =~ /<><>/){
                    $v =~ s/<><>/<>\.<>/;
                }
                my @vs = split ("<>",$v);
                if (scalar @vs ==4) {
                    if ($vs[1]ne"." && $vs[2]ne"." && $vs[1]>$vs[2]) {
                        my $o = $vs[1];
                        $vs[1] = $vs[2];
                        $vs[2] = $o;
                    } elsif ($vs[3]ne"." &&
                            (($vs[1] ne "." && $vs[3]>$vs[1]) ||
                            ($vs[2] ne "." && $vs[3]>$vs[2]))
                    ) {
                        $vs[3] = 1;
                    }
                    foreach my $vss (@vs) {$vss="" if ($vss eq ".");}
                    $tab->[4] = join("<>",@vs);
                } elsif ($vs[0] eq $v) {
                    return $boo;
                } else {
                    $boo = 0;
                }
            } else {
                $boo = 0;
            }
        }
        if ($boo == 0) {
            print "$t has a wrong value $v. Please fix it to continue";
            return 0;
        } else {
            return 1;
        }
    }


    # ===============================================
    #     SUB FUNCTION OF extractPgrmOrganisation
    # Object : transform opposite's value(s) in initials of this value(s)
    # in  : 
    # out : 
    # ===============================================

    sub findInitialsFromValues {
        my $structPgrm = $_[0];
        my %h          = %{$_[1]};
        my %initials   = %{$_[2]};
        
        foreach my $k (keys %h) {
            my $v = $structPgrm->{$h{$k}};
            if ($v =~ /<>/) {
                my @tab = split ("<>",$v);
                for (my $i =0; $i<scalar @tab;$i++) {
                    my $tp = $tab[$i];
                    $tab[$i] = &getInitialsFromVal(\%initials,$tp);
                    &testValNewVal($tp,$tab[$i]);
                }
                $structPgrm->{$h{$k}} = join ("<>",@tab);
            } else {
                my $tp = $v;
                $structPgrm->{$h{$k}} = &getInitialsFromVal(\%initials,$v);
                &testValNewVal($tp,$structPgrm->{$h{$k}});
            }
        }
        return;
    }
    
        # Sub of previous function
        sub getInitialsFromVal {
            my %initials = %{$_[0]};
            my $val = $_[1];
            
            foreach my $k (keys %initials) {
                if ($initials{$k} =~ /\_\Q$val\E\_/) {
                    return $initials{$k};
                }
            }
            return $val;
        }
            
        sub testValNewVal {
            my $t1 = $_[0];
            my $t2 = $_[1];
            
            if ($t1 eq $t2) {
                print "Impossible to find the initials of $t1\nThe program will die\nPlease Fix it\n";
                die;
            }
        }
    
    # ===============================================
    #     Prepare event table values
    # ===============================================
    sub getEventTabValues {
        my $event      = $_[0];
        my $structPgrm = $_[1];
        
        # Retrieve variables
        my %initials    = &fromVtoH($structPgrm->{"initials"}); #Initials -> Infos
        my %linkType    = &fromVtoH($structPgrm->{"linkType"}); #Link between type and java extension
        
        for (my $m=0;$m<keys $structPgrm;$m++){
            if (exists $structPgrm->{"0_".$m}) {
                my $l = $structPgrm->{"0_".$m};
                if ($l !~/_j?label$/i) {
                    push ($event,$l."_ActionPerformed");
                }
            }
        }
    
        for (my $t=1;$t<keys $structPgrm;$t++){
            for (my $s=0;$s<keys $structPgrm;$s++){
                for (my $c=0;$c<keys $structPgrm;$c++){
                    if (exists $structPgrm->{$t."_".$s."_".$c}) {
                        my $l = $structPgrm->{$t."_".$s."_".$c};
                        if ($l !~/_j?label$/i) {
                            push ($event,$l."_ActionPerformed");
                        }
                        foreach my $lt (keys %linkType) {
                            my $llt  = $l."".$lt;
                            if (exists $structPgrm->{$llt}) {
                                my $sllt = $structPgrm->{$llt};
                                if ($llt =~/value$/i) {
                                    push ($event,$llt."_StateChanged");
                                } elsif ($llt =~ /_Dir[a-z,A-Z]{3,5}$/) {
                                    push ($event,$llt."_ActionPerformed");
                                } elsif ($llt =~ /_Text$/) {
                                    push ($event,$llt."_FocusLost");
                                } elsif ($llt =~ /_List$/) {
                                    push ($event,$llt."_ActionPerformed");
                                }
                            }
                        }
                    }
                }
            }
        }
        return;
    }
    
    # ===============================================
    #     Prepare h_tabpanel
    # ===============================================
    sub prepareH_tabPanel {
        my %s = %{$_[0]};
        my %i = %{$_[1]};
        my %h =();
        
        for (my $tp=1;$tp<keys %s;$tp++){
            # For title panel and tab panel
            if (exists $s{$tp}) {
                # TabPanel
                my $l = $i{$tp}."_tabpanel";
                my @tab_Vals = ();
                if (exists $s{$l}) {
                    for (my $st=1;$st<keys %s;$st++){
                        if (exists $s{$tp."_".$st}) {
                            if ($i{$i{$tp."_".$st}}=~/^\Q$s{$l}\E_\d+$/) {
                            push (@tab_Vals,$i{$tp."_".$st}."_Spanel");
                        }}
                    }
                }
                if (scalar @tab_Vals == 1) {
                    print "The title $s{$tp} have just one subtitle.\nIt's not relevant.\nPlease Add another sub title or remove it and relaunch\n";
                    die;
                }
                $h{$l} = join ("<>",@tab_Vals);
                foreach my $tv (@tab_Vals) {
                    $h{$tv} = $l;
                }
            }
        }
        return %h;
    }
    
    # ===============================================
    #     Concat input values for connector names
    #     Connector types values
    # ===============================================
    sub inputsConcat {
        my $v  = $_[0];
        
        my %h = (
            "2_connectNames"      => "",
            "3_connectNames"      => "",
            "4_connectNames"      => "",
            "true_connectNames"   => "",
            "OneConnectorOnlyFor" => "",
            "SolelyConnectors"    => ""
        );
        
        my %h_test = ();
        
        for (my $i=0;$i<scalar keys $v;$i++){
            my $type  = $i."_type";
            my $cType = $i."_connectType";
            my $cNum  = $i."_connectNum";
            my $cName = $i."_connectName";
            
            if (exists $v->{$cNum} && exists $v->{$cName}){
                my $num  = $v->{$cNum};
                my $name = $v->{$cName};
                
                if ($num =~ /[true,2,3,4]/) {
                    my $st = $num."_connectNames";
                    $h{$st} .= ", ".$name if ($h{$st} ne "");
                    $h{$st}  = $name      if ($h{$st} eq "");
                } else {
                    print "\n\t\"WARNING\"".
                          "\n\tThe input $name has an wrong connector number.";
                }
            }
            if (exists $v->{$cType} && exists $v->{$cNum} && $v->{$cType} ne ""){
                if ($v->{$cType}=~ /^OneConnectorOnlyFor|SolelyConnectors$/){
                    my $t    = $v->{$cType};
                    my $num  = $v->{$cNum};
                    $h{$t} .= ",".$num if ($h{$t} ne "");
                    $h{$t}  = $num     if ($h{$t} eq "");
                } else {
                    print "\n\t\"WARNING\"".
                          "\n\tThe input $type has an wrong connector type.\n\tIt will not be used";
                }
            }
            
            if (exists $v->{$cNum} && exists $v->{$type}){
                my $val = $v->{$type};
                if (exists $h_test{$v->{$type}}) {
                    if ($h_test{$v->{$type}} =~ /\Q$v->{$cNum}\E/) {
                    print "\n\t\"WARNING\"".
                          "\n\tTwo inputs have the same name and the same attribution number ".$type." and $val.";
                    } else {
                        $h_test{$v->{$type}} .= ",".$v->{$cNum} if ($h_test{$v->{$type}} ne "");
                    }
                } else {
                    $h_test{$v->{$type}}  = $v->{$cNum};
                }
            }
        }
        $v->{"2_connectNames"}      = $h{"2_connectNames"}      if ($h{"2_connectNames"} ne "");
        $v->{"3_connectNames"}      = $h{"3_connectNames"}      if ($h{"3_connectNames"} ne "");
        $v->{"4_connectNames"}      = $h{"4_connectNames"}      if ($h{"4_connectNames"} ne "");
        $v->{"true_connectNames"}   = $h{"true_connectNames"}   if ($h{"true_connectNames"} ne "");
        $v->{"OneConnectorOnlyFor"} = $h{"OneConnectorOnlyFor"} if ($h{"OneConnectorOnlyFor"} ne "");
        $v->{"SolelyConnectors"}    = $h{"SolelyConnectors"}    if ($h{"SolelyConnectors"} ne "");
        return;
    }

    # ===============================================
    #     Test Data Saved FUNCTIONS
    # ===============================================
    
    sub testPgrmSaved {
        my $s = $_[0];
        
        my $bool = 1;
        # number of box Inputs test
        if (exists $s->{"0_nbInputs"}) {
            my $val = $s->{"0_nbInputs"};
            if ($val!~/\d/ || $val < 1 || $val > 3) {
                print "\n\t\"WARNING\"".
                      "\n\tThe number of inputs is not a number. It will be set as the default value 1 or at the max value from the imput\n";
                $bool = 0;
            }
        } else {
            print "\n\t\"WARNING\"".
                  "\n\tThe number of inputs is not set. The number of inputs for the box will be the default value \"1\" or setted from imputs value.\n";
            $bool = 0;
        }
        if ($bool == 0) {
            $s->{"0_nbInputs"} = 1;
        }
        
        # Pgrm path test
        if (exists $s->{"0_pgrPath"}) {
            my @paths = split (/\]\/\[/,$s->{"0_pgrPath"});
            if (scalar @paths != 3) {
                print "\n\t\"WARNING\"".
                      "\n\tThe program path didn't respect the template. Defaults values will be used.\n";
            }
        }

        # Web info test
        if (exists $s->{"0_web"}) {
            my @paths = split (/\]\/\[/,$s->{"0_web"});
            if (scalar @paths != 2) {
                print "\n\t\"WARNING\"".
                      "\n\tThe web path didn't respect the template. Defaults values will be used.\n";
            }
        }

        return;
    }
    
    sub testInputsSaved {
        my $s = $_[0];
        my $h = $_[1];
        my %bioFiles = ();
        my $val = $s->{"0_nbInputs"} if (exists $s->{"0_nbInputs"});
        
        for (my $i =0 ; $i < scalar keys $h ; $i++) {
            if (exists $h->{$i."_type"}) {
                my $t = $h->{$i."_type"};
                my %tfs = &getArmadilloBiologicFiles();
                if (exists $tfs{$t}) {
                    $bioFiles{$t} = "";
                    my $cNum = "";
                    $cNum = $h->{$i."_connectNum"} if (exists $h->{$i."_connectNum"});
                    
                    if ($cNum=~/^[2-4]{1}$/ && $cNum > $val+1) {
                        $s->{"0_nbInputs"} = $cNum-1;
                        print "\n\n\t\"WARNING\"".
                              "\n\tThe number of inputs is now ".$s->{"0_nbInputs"};
                    } elsif ($cNum!~/[true,2-4]{1}/) {
                        print "\n\n\t\"WARNING\"".
                              "\n\tThe inputs (num $i and ".$h->{$i."_type"}.") connector number will be set has the default value (true).\n";
                        $h->{$i."_connectNum"} = "true";
                    }
                    if (exists $h->{$i."_connectType"}){
                        my $t = $h->{$i."_connectType"};
                        if ($t ne "OneConnectorOnlyFor" && $t ne "SolelyConnectors") {
                            print "\n\n\t\"WARNING\"".
                                  "\n\tThe inputs (num $i and ".$h->{$i."_connectType"}.") connector type is not a good type. It will be deleted.\n";
                            delete ($h->{$i."_connectType"});
                        }
                    }
                } else {
                    print "\n\n\t\"WARNING WRONG INPUT TYPE\"".
                          "\n\tInput Type : ".$t." is an unknown input type.".
                          " Please add (or correct) this type in ./src/biologic.".
                          " It won't be added in the program file.\n";
                    delete($h->{$i."_type"});
                    delete($h->{$i."_connectNum"})  if (exists $h->{$i."_connectNum"});
                    delete($h->{$i."_connectName"}) if (exists $h->{$i."_connectName"});
                    delete($h->{$i."_connectType"}) if (exists $h->{$i."_connectType"});
                    delete($h->{$i."_command"})     if (exists $h->{$i."_command"});
                    delete($h->{$i."_extention"})   if (exists $h->{$i."_extention"});
                }
            }
        }
        return %bioFiles;
    }
    
    sub testOutputSaved {
        my $s = $_[0];
        my $h = $_[1];
        my $bioFiles = $_[2];
        
        for (my $i =0 ; $i < scalar keys $h ; $i++) {
            if (exists $h->{$i."_type"}) {
                my $t = $h->{$i."_type"};
                my %tfs = &getArmadilloBiologicFiles();
                if (exists $tfs{$t}) {
                    $bioFiles->{$t} = "";
                } else {
                    print "\n\n\t\"WARNING WRONG OUTPUT TYPE\"".
                          "\n\tOutput Type : ".$t." is an unknown output type.".
                          " Please add (or correct) this type in ./src/biologic.".
                          " It won't be added in the program file.\n";
                    delete($h->{$i."_type"});
                    delete($h->{$i."_connectName"}) if (exists $h->{$i."_connectName"});
                    delete($h->{$i."_command"})     if (exists $h->{$i."_command"});
                    delete($h->{$i."_extention"})   if (exists $h->{$i."_extention"});
                }
            }
        }
        $bioFiles->{"Results"}="";
        return;
    }
    
        sub getArmadilloBiologicFiles {
            opendir(DIR,$pTABiol);
            my @ts = readdir(DIR);
            closedir(DIR);
            my %tfs = ();
            foreach my $t (@ts) {
                if ($t=~/\.java$/) {
                    my ($v) = $t=~/(.*)\.java$/;
                    $tfs{$v} = "";
                }
            }
            return %tfs;
        }
    
    
# ======================================================================
#
#                           Other Functions
#
# ======================================================================

    # ===============================================
    # Function to get test if dir.{0,3} name is present
    # ===============================================
        sub dirActivation{
            my %st = %{$_[0]};
            my $k  = $_[1];
            my $dir = "";
            
            foreach my $key (keys %st) {
                if ($st{$key} =~/^(dirFiles|dirFile|dirRep)$/i && $key =~ /\Q$k\E/) {
                    $dir = $key;
                }
            }
            return $dir;
        }

    # ===============================================
    # Function to get menu values
    # ===============================================
        sub getMenuValues{
            my %s = %{$_[0]};
            my @menu=();
            for (my $k=0;$k<keys %s;$k++) {
                if (exists $s{"0_".$k}){
                    my $l = $s{"0_".$k};
                    push (@menu,$l);
                }
            }
            return @menu;
        }


=begin comment





========================================================================
                    JAVA FILE EDITOR CREATION
========================================================================





=end comment
=cut


# ===============================================
#     FUNCTION create Java File Editor
# in  : get infos from csv
# out : print infos in java file
# return new struct programe
# ===============================================
sub createJavaEditorFile {
    my $fileSource = $_[0];
    my %structPgrm = %{$_[1]};
    
    my $programmeName = $structPgrm{"0"}."Editors";
    my %initials      = &fromVtoH($structPgrm{"initials"}); #Initials -> Infos
    
    my @menu     = &getMenuValues(\%structPgrm);
    my @helpMenu =(
        "name_jTextField<>",
        "rename_jButton<>",
        "reset_jButton<>",
        "close_jButton<>",
        "stop_jButton<>",
        "run_jButton<>"
    );
    foreach my $m (@menu) {
        my $l = $m."<>";
        push (@helpMenu,$l);
    }
    
    #Local Variables will be used for functions USP and ennabled

    my $file=">".$pTAEdit."".$programmeName.".java";
    open (my $out , $file) or die $!;
    print $out  "/**\n".
                "* To change this license header, choose License Headers in Project Properties.\n".
                "* To change this template file, choose Tools | Templates\n".
                "* and open the template in the editor.\n".
                "*/\n".
                "package editors;\n".
                "\n".
                "import configuration.Config;\n".
                "import configuration.Util;\n".
                "import editor.EditorInterface;\n".
                "import java.awt.Dimension;\n".
                "import java.awt.Frame;\n".
                "import java.awt.Robot;\n".
                "import java.awt.Toolkit;\n".
                "import java.awt.image.BufferedImage;\n".
                "import java.io.File;\n".
                "import javax.imageio.ImageIO;\n".
                "import javax.swing.JFileChooser;\n".
                "import program.*;\n".
                "import workflows.armadillo_workflow;\n".
                "import workflows.workflow_properties;\n".
                "import workflows.workflow_properties_dictionnary;\n".
                "\n".
                "/**\n".
                " *\n".
                " * \@author : $author\n".
                " * \@Date   : $date\n".
                " */\n".
                "\n".
                "public class $programmeName extends javax.swing.JDialog implements EditorInterface  {\n".
                "\n".
                "    /**\n".
                "     * Creates new form $programmeName\n".
                "     */\n".
                "    Config config=new Config();\n".
                "    //ConnectorInfoBox connectorinfobox;\n".
                "    workflow_properties_dictionnary dict=new workflow_properties_dictionnary();\n".
                "    String selected = \"\";             // Selected properties\n".
                "    Frame frame;\n".
                "    workflow_properties properties;\n".
                "    armadillo_workflow  parent_workflow;\n".
                "\n".
                "    public final String defaultNameString=\"Name\";\n".
                "    static final boolean default_map=true;\n".
                "\n".
                "    public $programmeName(java.awt.Frame parent, armadillo_workflow parent_workflow) {\n".
                "        super(parent, false);\n".
                "        this.parent_workflow=parent_workflow;\n".
                "        //--Set variables and init\n".
                "        frame=parent;\n".
                "    }\n".
                "\n".
                "\n".
                "    /**\n".
                "     * This method is called from within the constructor to initialize the form.\n".
                "     * WARNING: Do NOT modify this code. The content of this method is always\n".
                "     * regenerated by the Form Editor.\n".
                "     */\n".
                "    \@SuppressWarnings(\"unchecked\")\n".
                "    // <editor-fold defaultstate=\"collapsed\" desc=\"Generated Code\">//GEN-BEGIN:initComponents\n".
                "    private void initComponents() {\n".
                "    \n";
    print $out  "        Menu_Buttons = new javax.swing.ButtonGroup();\n" if (scalar @menu>0);
                if (exists $structPgrm{"0_doImage"}) {
    print $out  "        docker_jButton = new javax.swing.JButton();\n";
                }
    print $out  "        how_jButton = new javax.swing.JButton();\n".
                "        ".$programmeName."2 = new javax.swing.JTabbedPane();\n".
                "        general_jPanel1 = new javax.swing.JPanel();\n".
                "        name_jLabel = new javax.swing.JLabel();\n".
                "        name_jTextField = new javax.swing.JTextField();\n".
                "        rename_jButton = new javax.swing.JButton();\n".
                "        reset_jButton = new javax.swing.JButton();\n".
                "        close_jButton = new javax.swing.JButton();\n".
                "        stop_jButton = new javax.swing.JButton();\n".
                "        run_jButton = new javax.swing.JButton();\n";
    
    &addJavaVariables($out,\%structPgrm,"start",\%initials);
    
    print $out  "\n        setDefaultCloseOperation(javax.swing.WindowConstants.DISPOSE_ON_CLOSE);\n\n";
    
    # Add default buttons and box
    addBoxANDButton($out,"how_jButton","?",$structPgrm{"0_help"});
                if (exists $structPgrm{"0_doImage"}) {
    addBoxANDButton($out,"docker_jButton","Docker Editor","Access to docker Editor");
                }
                
    print $out  "        ".$programmeName."2.addComponentListener(new java.awt.event.ComponentAdapter() {\n".
                "            public void componentShown(java.awt.event.ComponentEvent evt) {\n".
                "                ".$programmeName."2ComponentShown(evt);\n".
                "            }\n".
                "        });\n".
                "\n".
                "        general_jPanel1.setName(\"general_jPanel1\");\n".
                "        general_jPanel1.setPreferredSize(new java.awt.Dimension(459, ".&getComponentsHeight(\%structPgrm)."));\n".
                "\n";

    addBoxANDButton($out,"name_jLabel","Name","");
    addBoxANDButton($out,"name_jTextField",$structPgrm{"0"},"");
    addBoxANDButton($out,"rename_jButton","Rename","Rename the box");
    addBoxANDButton($out,"reset_jButton","Reset","Reset default value");
    addBoxANDButton($out,"close_jButton","Close","Close this window");
    addBoxANDButton($out,"stop_jButton","Stop","Stop the program");
    addBoxANDButton($out,"run_jButton","Run","Run the program");
    
    # Add program data
    &addPgrmBoxAndButton($out,\%structPgrm,\%initials);
    
#    print $out  "\n".
#                "\n".
    print $out  "        javax.swing.GroupLayout general_jPanel1Layout = new javax.swing.GroupLayout(general_jPanel1);\n".
                "        general_jPanel1.setLayout(general_jPanel1Layout);\n".
                "        general_jPanel1Layout.setHorizontalGroup(\n".
                "            general_jPanel1Layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)\n".
                "            .addGroup(general_jPanel1Layout.createSequentialGroup()\n".
#                "                .addGroup(general_jPanel1Layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)\n".
#                "                    .addGroup(general_jPanel1Layout.createSequentialGroup()\n".
                "                .addComponent(name_jLabel)\n".
                "                .addGap(18, 18, 18)\n".
                "                .addComponent(name_jTextField, javax.swing.GroupLayout.PREFERRED_SIZE, 248, javax.swing.GroupLayout.PREFERRED_SIZE)\n".
                "                .addGap(18, 18, 18)\n".
                "                .addComponent(rename_jButton))\n";
    print $out  "            .addGroup(general_jPanel1Layout.createSequentialGroup()\n" if (scalar @menu>0);
    for (my $k=0;$k<scalar @menu;$k++) {
        if ($k == (scalar @menu -1)){
            print $out  "                .addComponent(".$menu[$k]."))\n";
        } else {
            print $out  "                .addComponent(".$menu[$k].")\n".
                        "                .addGap(18, 18, 18)\n";
        }
    }
    for (my $t=1;$t<keys %structPgrm;$t++) {
        if (exists $initials{$t}) {
            my $tName = $initials{$t}."_panel";
    print $out  "            .addComponent(".$tName.", javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)\n";
        }
    }
    print $out  "            .addGroup(general_jPanel1Layout.createSequentialGroup()\n".
                "                .addComponent(reset_jButton)\n".
                "                .addGap(18, 18, 18)\n".
                "                .addComponent(stop_jButton)\n".
                "                .addGap(18, 18, 18)\n".
                "                .addComponent(run_jButton)\n".
                "                .addGap(18, 18, 18)\n".
                "                .addComponent(close_jButton))\n".
#                "                .addContainerGap()\n".
                "        );\n".
                "        general_jPanel1Layout.setVerticalGroup(\n".
                "            general_jPanel1Layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)\n".
                "            .addGroup(general_jPanel1Layout.createSequentialGroup()\n".
                "                .addContainerGap()\n".
                "                .addGroup(general_jPanel1Layout.createParallelGroup(javax.swing.GroupLayout.Alignment.BASELINE)\n".
                "                    .addComponent(name_jLabel)\n".
                "                    .addComponent(name_jTextField, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)\n".
                "                    .addComponent(rename_jButton))\n";
    if (scalar @menu>0) {
    print $out  "                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)\n".
                "                .addGroup(general_jPanel1Layout.createParallelGroup(javax.swing.GroupLayout.Alignment.BASELINE)\n";
    }
    for (my $k=0;$k<scalar @menu;$k++) {
        if ($k == (scalar @menu -1)){
            print $out  "                    .addComponent(".$menu[$k]."))\n";
        } else {
            print $out  "                    .addComponent(".$menu[$k].")\n";
        }
    }
    for (my $t=1;$t<keys %structPgrm;$t++) {
        if (exists $initials{$t}) {
            my $tName = $initials{$t}."_panel";
    print $out  "                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)\n";
    print $out  "                .addComponent(".$tName.", javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)\n";
#                "                    .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)\n";
        }
    }
    print $out  "                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)\n".
                "                .addGroup(general_jPanel1Layout.createParallelGroup(javax.swing.GroupLayout.Alignment.BASELINE)\n".
                "                    .addComponent(reset_jButton)\n".
                "                    .addComponent(stop_jButton)\n".
                "                    .addComponent(run_jButton)\n".
                "                    .addComponent(close_jButton)))\n".
                "        );\n".
                "\n";
                &addHelp($out,\@helpMenu);
    print $out  "        ".$programmeName."2.addTab(\"".$structPgrm{"0"}."Editors"."\", general_jPanel1);\n".
                "\n".
                "        javax.swing.GroupLayout layout = new javax.swing.GroupLayout(getContentPane());\n".
                "        getContentPane().setLayout(layout);\n".
                "        layout.setHorizontalGroup(\n".
                "            layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)\n".
                "            .addGroup(layout.createSequentialGroup()\n";
                if (exists $structPgrm{"0_doImage"}) {
    print $out  "                .addContainerGap(javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)\n".
                "                .addComponent(docker_jButton)\n".
                "                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)\n";
                } else {
    print $out  "                .addContainerGap(javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)\n";
                }
    print $out  "                .addComponent(how_jButton))\n".
#                "            .addGroup(layout.createSequentialGroup()\n".
                "            .addComponent(".$programmeName."2, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)\n".
                "        );\n".
                "        layout.setVerticalGroup(\n".
                "            layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)\n".
                "            .addGroup(layout.createSequentialGroup()\n";
                if (exists $structPgrm{"0_doImage"}) {
    print $out  "                        .addGroup(layout.createParallelGroup(javax.swing.GroupLayout.Alignment.BASELINE)\n".
                "                            .addComponent(docker_jButton)\n"    ;
                }
    print $out  "                .addComponent(how_jButton)\n";
                if (exists $structPgrm{"0_doImage"}) {
    print $out  "                   )\n";
                }
    print $out  "                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)\n".
                "                .addComponent(".$programmeName."2, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE))\n".
                "        );\n".
                "\n".
                "        how_jButton.getAccessibleContext().setAccessibleDescription(\"".$structPgrm{"0_help"}."\");\n".
                "        ".$programmeName."2.getAccessibleContext().setAccessibleName(\"".$structPgrm{"0"}."Editors\");\n".
                "\n".
                "        pack();\n".
#                "\n".
                "    }// </editor-fold>//GEN-END:initComponents\n".
                "\n".
                "    private void ".$programmeName."2ComponentShown(java.awt.event.ComponentEvent evt) {//GEN-FIRST:event_".$programmeName."2ComponentShown\n".
                "        // TODO add your handling code here:\n".
                "    }//GEN-LAST:event_".$programmeName."2ComponentShown\n".
                "    \n";
                if (exists $structPgrm{"0_doImage"}) {
    print $out  "    private void docker_jButton_ActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_docker_jButton_ActionPerformed\n".
                "        // TODO add your handling code here:\n".
                "        dockerEditor dock = new dockerEditor(this.frame, false, properties);\n".
                "        dock.setVisible(true);\n".
                "    }//GEN-LAST:event_docker_jButton_ActionPerformed\n".
                "    \n";
                }
    print $out  "    private void how_jButton_ActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_how_jButton_ActionPerformed\n".
                "        // TODO add your handling code here:\n".
                "        HelpEditor help = new HelpEditor(this.frame, false, properties);\n".
                "        help.setVisible(true);\n".
                "    }//GEN-LAST:event_how_jButton_ActionPerformed\n".
                "\n".
                "    private void close_jButton_ActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_close_jButton_ActionPerformed\n".
                "        // TODO add your handling code here:\n".
                "        this.setVisible(false);\n".
                "    }//GEN-LAST:event_close_jButton_ActionPerformed\n".
                "\n".
                "    private void run_jButton_ActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_run_jButton_ActionPerformed\n".
                "        // TODO add your handling code here:\n".
                "        if (this.properties.isSet(\"ClassName\")) {\n".
                "            this.parent_workflow.workflow.updateDependance();\n".
                "            programs prog=new programs(parent_workflow.workbox.getCurrentWorkflows());\n".
                "            prog.Run(properties);\n".
                "        }\n".
                "    }//GEN-LAST:event_run_jButton_ActionPerformed\n".
                "\n".
                "    private void stop_jButton_ActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_stop_jButton_ActionPerformed\n".
                "        // TODO add your handling code here:\n".
                "        properties.put(\"Status\", Config.status_nothing);\n".
                "        properties.killThread();\n".
                "    }//GEN-LAST:event_stop_jButton_ActionPerformed\n".
                "\n".
                "    private void reset_jButton_ActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_reset_jButton_ActionPerformed\n".
                "        // TODO add your handling code here:\n".
                "        properties.load();             //--reload current properties from file\n".
                "        this.setProperties(properties);//--Update current field\n".
                "        this.display(properties);\n".
                "    }//GEN-LAST:event_reset_jButton_ActionPerformed\n".
                "\n".
                "    private void rename_jButton_ActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_rename_jButton_ActionPerformed\n".
                "        // TODO add your handling code here:\n".
                "        properties.put(\"Name\", this.name_jTextField.getText());\n".
                "    }//GEN-LAST:event_rename_jButton_ActionPerformed\n".
                "\n".
                "    private void name_jTextField_ActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_name_jTextField_ActionPerformed\n".
                "        // TODO add your handling code here:\n".
                "    }//GEN-LAST:event_name_jTextField_ActionPerformed\n".
                "    \n";
    
    &addEventData($out,\%structPgrm);
    
    print $out  "    /*******************************************************************\n".
                "    * Enabled Function\n".
                "    *******************************************************************/\n".
                "    \n";
    
    &createEnabledFunction($out,\%structPgrm);
        
    print $out  "\n    /*******************************************************************\n".
                "    * Update Saved Properties => usp_functions\n".
                "    *******************************************************************/\n".
                "\n".
                "    private void updateSavedProperties(workflow_properties properties) {\n".
                "        usp_valueANDtext (properties);\n".
                "        usp_boxANDbutton (properties);\n".
                "    }\n    \n";
    
    &createUSPFunctions($out,\%structPgrm);
    
    print $out  "\n    /*******************************************************************\n".
                "     * Set the configuration properties for this object\n".
                "     ******************************************************************/\n".
                "\n".
                "    \@Override\n".
                "    public void display(workflow_properties properties) {\n".
                "        this.properties=properties;\n".
                "        initComponents();\n".
                "        setIconImage(Config.image);\n".
                "        // Set position\n".
                "        Dimension screenSize = Toolkit.getDefaultToolkit().getScreenSize();\n".
                "        Dimension d = getSize();\n".
                "        setLocation((screenSize.width-d.width)/2,\n".
                "                (screenSize.height-d.height)/2);\n".
                "        \n".
                "        // Set the program properties\n".
                "        this.setProperties(properties);\n".
                "        \n".
                "        // Update Saved Properties => usp\n".
                "        this.updateSavedProperties(properties);\n".
                "        \n".
                "        this.setAlwaysOnTop(true);\n".
                "        this.setVisible(true);\n".
                "    }\n".
                "\n".
                "    /*******************************************************************\n".
                "     * Sets for Properties\n".
                "     ******************************************************************/\n".
                "\n".
                "    /**\n".
                "     * Set Properties\n".
                "     * \@param properties\n".
                "     */\n".
                "\n".
                "    public void setProperties(workflow_properties properties) {\n".
                "        this.properties=properties;\n".
                "        setTitle(properties.getName());\n".
                "        //if (this.properties.isSet(\"Description\")) this.Notice.setText(properties.get(\"Description\"));\n".
                "        \n".
                "        // Properties Default Options\n".
                "        this.defaultPgrmValues(properties);\n";
    if (exists $structPgrm{"0_0"}) {
        print $out  "        // Set the menu\n".
                    "        this.menuFields(properties);\n";
    }
    print $out  "    }\n".
                "\n".
                "    public void setProperties(String filename, String path) {\n".
                "        workflow_properties tmp=new workflow_properties();\n".
                "        tmp.load(filename, path);\n".
                "        this.properties=tmp;\n".
                "        setTitle(properties.getName());\n".
                "    }\n".
                "\n".
                "    /*******************************************************************\n".
                "     * Set With default program values present in properties file\n".
                "     ******************************************************************/\n";
    &defaultPgrmValues($out,\%structPgrm);
    
    if (exists $structPgrm{"0_0"}) {
        &menuFields($out,\%structPgrm);
    }
    
    print $out  "\n    /*******************************************************************\n".
                "     * Save Image\n".
                "     ******************************************************************/\n".
                "\n".
                "    public void saveImage(String filename) {\n".
                "        BufferedImage bi;\n".
                "        try {\n".
                "            bi = new Robot().createScreenCapture(this.getBounds());\n".
                "            ImageIO.write(bi, \"png\", new File(filename));\n".
                "            this.setVisible(false);\n".
                "        } catch (Exception ex) {\n".
                "            Config.log(\"Unable to save \"+filename+\" dialog image\");\n".
                "        }\n".
                "    }\n".
                "\n".
                "    // Variables declaration - do not modify//GEN-BEGIN:variables\n".
                "    private javax.swing.JButton how_jButton;\n";
                if (exists $structPgrm{"0_doImage"}) {
    print $out  "    private javax.swing.JButton docker_jButton;\n";
                }
    print $out  "    private javax.swing.JTabbedPane ".$programmeName."2;\n".
                "    private javax.swing.JPanel general_jPanel1;\n".
                "    private javax.swing.JLabel name_jLabel;\n".
                "    private javax.swing.JTextField name_jTextField;\n".
                "    private javax.swing.JButton rename_jButton;\n".
                "    private javax.swing.JButton reset_jButton;\n".
                "    private javax.swing.JButton close_jButton;\n".
                "    private javax.swing.JButton stop_jButton;\n".
                "    private javax.swing.JButton run_jButton;\n";
    print $out  "    private javax.swing.ButtonGroup Menu_Buttons;\n" if (scalar @menu>0);

    &addJavaVariables($out,\%structPgrm,"end",\%initials);

    print $out  "    // End of variables declaration//GEN-END:variables\n".
                "    }\n".
                "\n";
    close $out;
    return %structPgrm;
}

    # ===============================================
    #     SUB FUNCTION OF createJavaEditorFile
    # in  : get box or but informations from csv file
    # out : print infos in java file
    # ===============================================
    sub addJavaVariables {
        my $out        = $_[0];
        my $structPgrm = $_[1];
        my $where      = $_[2];
        my %initials   = %{$_[3]};
        # Retrieve variables
        my %linkType    = &fromVtoH($structPgrm->{"linkType"}); #Link between type and java extension
        
        
        for (my $m=0;$m<keys $structPgrm;$m++){ #Menu options
            if (exists $structPgrm->{"0_".$m}) {
                my $l = $structPgrm->{"0_".$m};
                print $out "        ".$l." = new javax.swing.JRadioButton();\n" if ($where eq "start");
                print $out "    private javax.swing.JRadioButton ".$l.";\n" if ($where eq "end");
            }
        }
        
        for (my $t=1;$t<keys $structPgrm;$t++){
            if (exists $initials{$t}) {
                my $tName = $initials{$t}."_panel";
                print $out "        ".$tName." = new javax.swing.JPanel();\n" if ($where eq "start");
                print $out "    private javax.swing.JPanel ".$tName.";\n" if ($where eq "end");
            }

            for (my $s=0;$s<keys $structPgrm;$s++){
                if (exists $initials{$t."_".$s}){
                    if ($s == 1 && exists $structPgrm->{$initials{$t}."_tabpanel"}) {
                        my $tabName = $initials{$t}."_tabpanel";
                        print $out "        ".$tabName." = new javax.swing.JTabbedPane();\n" if ($where eq "start");
                        print $out "    private javax.swing.JTabbedPane ".$tabName.";\n" if ($where eq "end");
                    }
                    my $sName = $initials{$t."_".$s}."_Spanel";
                    print $out "        ".$sName." = new javax.swing.JPanel();\n" if ($where eq "start");
                    print $out "    private javax.swing.JPanel ".$sName.";\n" if ($where eq "end");
                }
                
                for (my $c=0;$c<keys $structPgrm;$c++){
                    my $tsc = $t."_".$s."_".$c;
                    if (exists $structPgrm->{$tsc}) {
                        my $l = $structPgrm->{$tsc};
                        if ($l=~/_button$/i){
                            print $out "        ".$l." = new javax.swing.JButton();\n" if ($where eq "start");
                            print $out "    private javax.swing.JButton ".$l.";\n" if ($where eq "end");
                        }
                        if ($l=~/_RButton$/i){
                            print $out "        ".$l." = new javax.swing.JRadioButton();\n" if ($where eq "start");
                            print $out "    private javax.swing.JRadioButton ".$l.";\n" if ($where eq "end");
                        }
                        if ($l=~/_box$/i){
                            print $out "        ".$l." = new javax.swing.JCheckBox();\n" if ($where eq "start");
                            print $out "    private javax.swing.JCheckBox ".$l.";\n" if ($where eq "end");
                        }
                        foreach my $lt (keys %linkType) {
                            if (exists $structPgrm->{$l."".$lt}) {
                                print $out "        ".$l."".$lt." = new javax.swing.".$linkType{$lt}."();\n" if ($where eq "start");
                                print $out "    private javax.swing.".$linkType{$lt}." ".$l."".$lt.";\n" if ($where eq "end");
                            }
                        }
                    }
                }
            }
        }
    }

    # ===============================================
    #     SUB FUNCTION OF createJavaEditorFile
    # in  : get box or but informations from csv file
    # out : print infos in java file
    # ===============================================
    sub addBoxANDButton {
        my $out   = $_[0];
        my $cName = $_[1];
        my $text  = $_[2];
        my $desc  = $_[3];
        
        if ($cName =~/_j?label$/i) {
            print $out  "        ".$cName.".setFont(new java.awt.Font(\"Ubuntu\", 3, 15)); // NOI18N\n";
        }
        print $out  "        ".$cName.".setText(\"".$text."\");\n".
                    "        ".$cName.".setName(\"".$cName."\"); // NOI18N\n";
        if ($cName !~/_j?label$/i) {
            print $out  "        ".$cName.".addActionListener(new java.awt.event.ActionListener() {\n".
                        "            public void actionPerformed(java.awt.event.ActionEvent evt) {\n".
                        "                ".$cName."_ActionPerformed(evt);\n".
                        "            }\n".
                        "        });\n";
        }
        print $out  "\n";
        return;
    }

    # ===============================================
    #     SUB FUNCTION OF createJavaEditorFile
    # in  : get spinner or text informations from csv file
    # out : print infos in java file
    # ===============================================
    sub addTypeLinked {
        my $out   = $_[0];
        my $cName = $_[1];
        my $value = $_[2];
        my $help  = $_[3];
        
        if ($cName=~/value$/i) {
            my $values = &fixSpinnerValues($cName,$value,"ej");
            print $out  "        ".$cName.".setModel(new javax.swing.SpinnerNumberModel(".$values."));\n";
            print $out  "        ".$cName.".setName(\"".$cName."\"); // NOI18N\n".
                        "        ".$cName.".setPreferredSize(new java.awt.Dimension(115, 28));\n".
                        "        ".$cName.".addChangeListener(new javax.swing.event.ChangeListener() {\n".
                        "            public void stateChanged(javax.swing.event.ChangeEvent evt) {\n".
                        "                ".$cName."_StateChanged(evt);\n".
                        "            }\n".
                        "        });\n";
        } elsif ($cName=~/_List$/) {
            $value=~s/<>/", "/g;
            $value="\"".$value."\"";
            print $out  "        ".$cName.".setModel(new javax.swing.DefaultComboBoxModel(new String[] { ".$value." }));\n";
            print $out  "        ".$cName.".setName(\"".$cName."\"); // NOI18N\n".
                        "        ".$cName.".addActionListener(new java.awt.event.ActionListener() {\n".
                        "            public void actionPerformed(java.awt.event.ActionEvent evt) {\n".
                        "                ".$cName."_ActionPerformed(evt);\n".
                        "            }\n".
                        "        });\n";
        } else {
            print $out  "        ".$cName.".setText(\"".$value."\");\n";
            print $out  "        ".$cName.".setName(\"".$cName."\"); // NOI18N\n".
                        "        ".$cName.".setPreferredSize(new java.awt.Dimension(220, 27));\n";
            if ($cName !~ /_Dir[a-z,A-Z]{3,5}$/) {
                print $out  "        ".$cName.".addFocusListener(new java.awt.event.FocusAdapter() {\n".
                            "            public void focusLost(java.awt.event.FocusEvent evt) {\n".
                            "                ".$cName."_FocusLost(evt);\n".
                            "            }\n".
                            "        });\n";
            }
            if ($cName =~ /_Dir[a-z,A-Z]{3,5}$/) {
                print $out  "        ".$cName.".addActionListener(new java.awt.event.ActionListener() {\n".
                            "            public void actionPerformed(java.awt.event.ActionEvent evt) {\n".
                            "                ".$cName."_ActionPerformed(evt);\n".
                            "            }\n".
                            "        });\n";
            }
        }
        print $out  "\n";
        return;
    }
    
    # ===============================================
    #     SUB FUNCTION OF createJavaEditorFile
    # in  : get spinner or text informations from csv file
    # out : print infos in java file
    # ===============================================
    sub addHelp {
        my $out   = $_[0];
        my @help  = @{$_[1]};
        
        for (my $h = 0;$h<scalar @help;$h++){
            my ($cName,$help) = split ("<>",$help[$h]);
            if ($cName !~/_j?label$/i && $cName !~/^how_jButton$/i) {
                print $out "        ".$cName.".getAccessibleContext().setAccessibleDescription(\"".$help."\");\n";
            }
        }
        print $out "\n";
        return;
    }
    
        # ===============================================
        #     SUB FUNCTION OF addTypeLinked
        # in  : value
        # table position 0 = def, 1 = min, 2 = max, 3 = jump
        # out : return tab with default values
        # ===============================================
        sub fixSpinnerValues {
            my $cName    = $_[0];
            my $val  = $_[1];
            my $or   = $_[2];
            my @vals = ("","","","","");
            
            @vals = ($val,"","","","") if ($val!~/<>/);
            @vals = split ("<>",$val) if ($val=~/<>/);
            
            my $t ="";
            ($t) = $cName =~/_(.{3})Value$/ if ($cName =~/_.{3}Value$/);
            
            my %h_val =(
                "Byt0" => 1,    #init
                "Byt1" => -128, #min
                "Byt2" => 127,  #max
                "Byt3" => 1,    #jump
                "Int0" => 1,
                "Int1" => -2147483648,
                "Int2" => 2147483647,
                "Int3" => 1,
                "Lon0" => 1,
                "Lon1" => -9223372036854775808,
                "Lon2" => 9223372036854775807,
                "Lon3" => 1,
                "Sho0" => 1,
                "Sho1" => -32768,
                "Sho2" => 32767,
                "Sho3" => 1,
                "Flo0" => "1.0f",
                "Flo1" => "-1f/0f",
                "Flo2" => "1f/0f",
                "Flo3" => "1.0f",
                "Dou0" => "1.0d",
                "Dou1" => "-1d/0d",
                "Dou2" => "1d/0d",
                "Dou3" => "1.0d",
                "Boo0" => 0,
                "Boo1" => 0,
                "Boo2" => 1,
                "Boo3" => 1
            );
            
            my %h_val_ef =(
                "0" => "1.0",
                "1" => "-Infinity",
                "2" => "Infinity",
                "3" => "1.0"
            );
            
            my %h_t_j =(
                "Byt" => "Byte",
                "Int" => "Integer",
                "Lon" => "Long",
                "Sho" => "Short",
                "Flo" => "Float",
                "Dou" => "Double",
                "Boo" => "Integer"
            );
            
            for (my $i=0;$i<scalar @vals;$i++){
                if ($vals[$i] eq "" || $vals[$i] =~/inf/i) {
                    $vals[$i] = $h_val{$t."".$i} if (exists $h_val{$t."".$i});
                }
            }
            if ($or eq "ef" && $t=~/(Dou|Flo)/i) {
                for (my $i=0;$i<scalar @vals;$i++){
                    if ($vals[$i] eq "" || $vals[$i] =~/(f|d)/i) {
                        $vals[$i] = $h_val_ef{$i} if (exists $h_val{$t."".$i});
                    }
                }
            }
            
            if (exists $h_t_j{$t}) {
                if ($or eq "ef") {
                    return "initial=\"".$vals[0]."\" maximum=\"".$vals[2]."\" minimum=\"".$vals[1]."\" numberType=\"java.lang.".$h_t_j{$t}."\" stepSize=\"".$vals[3]."\"";
                } else {
                    return "".$vals[0].", ".$vals[1].", ".$vals[2].", ".$vals[3]."";
                }
            }
            return join (", ",@vals);
        }
    
    # ===============================================
    #     SUB FUNCTION OF createJavaEditorFile
    # in  : 
    # out : 
    # ===============================================
    sub addPgrmBoxAndButton {
        my $out        = $_[0];
        my $structPgrm = $_[1];
        my %initials   = %{$_[2]};
        
        # Retrieve variables
        my %linkType    = &fromVtoH($structPgrm->{"linkType"}); #Link between type and java extension
        my %h_bv        = &fromVtoH($structPgrm->{"h_bv"}); #Button -> Value
        my %h_tabPanel  = &fromVtoH($structPgrm->{"h_tabPanel"}); #TabPanel -> Tab and Panel -> TabPanel
        
        for (my $m=0;$m<keys $structPgrm;$m++){ #Menu options
            if (exists $structPgrm->{"0_".$m}) {
                my $l = $structPgrm->{"0_".$m};
                my ($text) = $l=~/(.*)_RButton$/;
                $text =~ s/_/ /g;
                print $out  "        Menu_Buttons.add(".$l.");\n";
                addBoxANDButton($out,$l,$text,$l);
            }
        }
        
        my $tName = "";
        my $sName = "";
        for (my $t=1;$t<keys $structPgrm;$t++){
            my @tCom = ();
            
            # For title panel and tab panel
            if (exists $structPgrm->{$t}) {
                # Panel
                $tName = $initials{$t}."_panel";
                print $out  "        ".$tName.".setBorder(javax.swing.BorderFactory.createTitledBorder(\"".$structPgrm->{$t}."\"));\n\n";
            }
            
            # For subtitles
            for (my $s=0;$s<keys $structPgrm;$s++){
                my @sCom = ();
                if (exists $structPgrm->{$t."_".$s}) {
                    $sName = $initials{$t."_".$s}."_Spanel";
                }
                
                # For commands
                for (my $c=0;$c<keys $structPgrm;$c++){
                    if (exists $structPgrm->{$t."_".$s."_".$c}) {
                        my $cName = $structPgrm->{$t."_".$s."_".$c};
                        if ($cName=~/_button$/i || $cName=~/_RButton$/i || $cName=~/_box$/i){
                            my $cHelp = $structPgrm->{$cName."_Help"} if (exists $structPgrm->{$cName."_Help"});
                            if ($s == 0){
                                push (@tCom,$cName."<>".$cHelp);
                            } else {
                                push (@sCom,$cName."<>".$cHelp);
                            }
                            addBoxANDButton($out,$cName,$structPgrm->{$cName});
                        }
                        foreach my $lt (keys %linkType) {
                            my $llt  = $cName."".$lt;
                            
                            if (exists $structPgrm->{$llt}) {
                                my $sllt = $structPgrm->{$llt};
                                if ($linkType{$lt} =~ /jbutton$/i || $lt eq "_Label") {
                                    addBoxANDButton($out,$llt,$sllt) ;
                                } else {
                                    addTypeLinked($out,$llt,$sllt);
                                }
                                if ($lt ne "_Label") {
                                    my $slh  = $structPgrm->{$cName."_Help"};
                                    if ($s == 0){
                                        push (@tCom,$llt."<>".$slh);
                                    } else {
                                        push (@sCom,$llt."<>".$slh);
                                    }
                                }
                            }
                        }
                    }
                }
                if ($sName ne "") {
                    &addTitlePanel($out,$structPgrm,\%initials,\%h_bv,$sName,\%h_tabPanel);
                    print $out "\n";
                    &addHelp($out,\@sCom);
                    if (exists $h_tabPanel{$sName}) {
                        print $out  "        ".$initials{$t}."_tabpanel.addTab(\"".$initials{$t."_".$s}."\", ".$sName.");\n\n";
                    }
                    $sName = "";
                    @sCom = ();
                }
            }
            if ($tName ne "") {
                &addTitlePanel($out,$structPgrm,\%initials,\%h_bv,$tName,\%h_tabPanel);
                print $out "\n";
                &addHelp($out,\@tCom);
                $tName = "";
                @tCom = ();
            }
        }
        return;
    }

        # ===============================================
        #     SUB FUNCTIONS FOR createPanelSetting
        # ===============================================
        sub getSubData {
            my %s    = %{$_[0]};
            my %h_bv = %{$_[1]};
            my $ini  = $_[2];
            
            my %h_bl = &fromVtoH($s{"h_bl"});

            my @values = ();
            for (my $i=0;$i<keys %s;$i++){
                my $b   = "";
                my $val = "";
                my $lab = "";
                my $dir = "";
                if (exists $s{$ini."_".$i}) {
                    $b = $s{$ini."_".$i};
                    if (exists $h_bv{$b}){
                        $val = $h_bv{$b};
                    }
                    if (exists $s{$b."_Label"}){
                        $lab = $b."_Label";
                    }
                }
                if ($b ne "") {
                    $dir = &dirActivation(\%s,$b);
                    my @valTps = ($b,$val,$lab,$dir);
                    foreach my $valTp (@valTps) { $valTp = "." if ($valTp eq "");}
                    my $end = join ("<>",@valTps);
                    push (@values,$end);
                }
            }
            return @values;
        }
    
        # ===============================================
        #     SUB FUNCTIONS FOR createPanelSetting
        # ===============================================
        sub addTitlePanel {
            my $out        = $_[0];
            my %structPgrm = %{$_[1]};
            my %initials   = %{$_[2]};
            my %h_bv       = %{$_[3]};
            my $t          = $_[4];
            my %h_tabPanel = %{$_[5]};
            
            my @s = split ("_",$t);
            
            my $ini = "";
            my $tabPanel = "";
            if (scalar @s==2) {
                $ini = $initials{$s[0]}."_0";
                $tabPanel = exists $structPgrm{$s[0]."_tabpanel"};
            } elsif (scalar @s==3) {
                $ini = $initials{$s[0]."_".$s[1]};
            }

            my @values = &getSubData(\%structPgrm,\%h_bv,$ini);
            print $out  "        javax.swing.GroupLayout ".$t."Layout = new javax.swing.GroupLayout(".$t.");\n".
                        "        ".$t.".setLayout(".$t."Layout);\n".
                        #Horizontal
                        "        ".$t."Layout.setHorizontalGroup(\n".
                        "            ".$t."Layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)\n".
                        "            .addGroup(".$t."Layout.createSequentialGroup()\n".
                        "                .addContainerGap()\n".
                        "                .addGroup(".$t."Layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)\n";
            my $boolGroupH = 0;
            for (my $c=0;$c<scalar @values;$c++) {
                my ($b,$val,$lab,$dir) = split ("<>",$values[$c]);
                if ($b ne "." && $c<(scalar @values -1)) {
                    if ($val ne "." || $lab ne "." || $dir ne "."){
                        print $out  "                    .addGroup(".$t."Layout.createSequentialGroup()\n    ";
                    }
                    print $out  "                    .addComponent(".$b.")";
                    if ($val ne "."){
                        print $out  "\n                        .addGap(18, 18, 18)".
                                    "\n                        .addComponent(".$val.", javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)";
                    }
                    if ($lab ne ".") {
                        print $out  "\n                        .addGap(18, 18, 18)".
                                    "\n                        .addComponent(".$lab.")";
                    }
                    if ($dir ne ".") {
                        print $out  "\n                        .addGap(18, 18, 18)".
                                    "\n                        .addComponent(".$dir.")";
                    }
                    if ($val ne "." || $lab ne "." || $dir ne "."){
                        print $out  ")\n";
                    }
                } elsif ($b ne "." && $c==(scalar @values -1)) {
                    if ($val ne "." || $lab ne "." || $dir ne "."){
                        print $out  "                    .addGroup(".$t."Layout.createSequentialGroup()\n    ";
                        $boolGroupH=1;
                    }
                    print $out  "                    .addComponent(".$b.")";
                    if ($val ne "."){
                        print $out  "\n                        .addGap(18, 18, 18)".
                                    "\n                        .addComponent(".$val.", javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)";
                    }
                    if ($lab ne ".") {
                        print $out  "\n                        .addGap(18, 18, 18)".
                                    "\n                        .addComponent(".$lab.")";
                    }
                    if ($dir ne ".") {
                        print $out  "\n                        .addGap(18, 18, 18)".
                                    "\n                        .addComponent(".$dir.")";
                    }
                    if ($val ne "." || $lab ne "." || $dir ne "."){
                        print $out  ")\n" if ($tabPanel);
                        print $out  "))\n                .addContainerGap())\n" if (!$tabPanel);
                    } else{
                        if ($tabPanel) {
#                            print $out  "\n                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)";
                        } else {
                            print $out  ")" if ($boolGroupH);
                        }
                    }
                }
            }
            if ($tabPanel) {
                print $out  "\n" if (!$boolGroupH);
                print $out  "                    .addComponent(".$s[0]."_tabpanel, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)"; # Valeurs pour les panels titres
                print $out  ")\n";
                print $out  "                .addContainerGap())\n";
            } else {
                print $out  ")\n" if (!$boolGroupH);
                print $out  "                .addContainerGap())\n" if (!$boolGroupH);
            }
            print $out  "        );\n";
            #Vertical
            print $out  "        ".$t."Layout.setVerticalGroup(\n".
                        "            ".$t."Layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)\n".
                        "            .addGroup(".$t."Layout.createSequentialGroup()\n";
            my $boolGroupV = 0;
            for (my $c=0;$c<scalar @values;$c++) {
                my ($b,$val,$lab,$dir) = split ("<>",$values[$c]);
                if ($b ne "." && $c<(scalar @values -1)) {
                    print $out  "                .addContainerGap()\n";
                    if ($val ne "." || $lab ne "." || $dir ne "."){
                        print $out  "                .addGroup(".$t."Layout.createParallelGroup(javax.swing.GroupLayout.Alignment.BASELINE)\n    ";
                    }
                    print $out  "                .addComponent(".$b.")";
                    if ($val ne "."){
                        print $out  "\n                    .addComponent(".$val.", javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)";
                    }
                    if ($lab ne ".") {
                        print $out  "\n                    .addComponent(".$lab.")";
                    }
                    if ($dir ne ".") {
                        print $out  "\n                    .addComponent(".$dir.")";
                    }
                    if ($val ne "." || $lab ne "." || $dir ne "."){
                        print $out  ")\n".
                                    "                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)\n";
                    }
                } elsif ($b ne "." && $c==(scalar @values -1)) {
                    if ($val ne "." || $lab ne "." || $dir ne "."){
                        print $out  "                .addGroup(".$t."Layout.createParallelGroup(javax.swing.GroupLayout.Alignment.BASELINE)\n    ";
                        $boolGroupV = 1;
                    }
                    print $out  "                .addComponent(".$b.")";
                    if ($val ne "."){
                        print $out  "\n                    .addComponent(".$val.", javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)";
                    }
                    if ($lab ne ".") {
                        print $out  "\n                    .addComponent(".$lab.")";
                    }
                    if ($dir ne ".") {
                        print $out  "\n                    .addComponent(".$dir.")";
                    }
                    if ($val ne "." || $lab ne "." || $dir ne "."){
                        print $out  ")\n";
                        print $out  "                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)\n" if ($tabPanel);
                    } else{
                        if ($tabPanel) {
                            print $out  "\n" if (!$boolGroupV);
                            print $out  "                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)\n";
                        } else {
                            print $out  "\n";
                        }
                    }
                }
            }
            if ($tabPanel) {
            print $out  "                .addComponent(".$s[0]."_tabpanel, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)\n". # Valeurs pour les panels titres
                        "                .addContainerGap())\n".
                        "        );\n";
            }
            if (!$tabPanel) {
            print $out  "                .addContainerGap())\n".
                        "        );\n";
            }
        }
        
    # ===============================================
    #     SUB FUNCTION OF createJavaEditorFile
    # in  : get spinner or text informations from csv file
    # out : print infos of panel creation in java file
    # ===============================================
    sub addEventData {
        my $out        = $_[0];
        my $structPgrm = $_[1];
        
        # Retrieve variables
        my %h_bv        = &fromVtoH($structPgrm->{"h_bv"}); #Button -> Value
        my %h_bp        = &fromVtoH($structPgrm->{"h_bp"}); #Button -> Parent of
        my %h_bo        = &fromVtoH($structPgrm->{"h_bo"}); #Button -> Opposite to
        my %linkType    = &fromVtoH($structPgrm->{"linkType"}); #Link between type and java extension
        my @event       = &fromVtoA($structPgrm->{"event"}); #Link between type and java extension
        my @menu       = &getMenuValues($structPgrm);
        
        for (my $i = 0 ; $i < scalar @event; $i++) {
            
            my $type = "";
            if ($event[$i] =~ /.*_dir_ActionPerformed$/i) {
                $type="button";
            } elsif ($event[$i] =~ /box/i) {
                $type="box";
            } elsif ($event[$i] =~ /button/i) {
                $type="button";
            } else {
                print "We have a problem for ".$event[$i]."\n";
            }
            
            my ($str) = $event[$i] =~ /^(.*)_[a-z,A-Z]+$/;

            # Type button, box ou rbox
            if ($event[$i] =~ /^.*_ActionPerformed$/ && $str!~/_list$/i) {
                
                # START Type bouton, box ou rbox
                print $out "\n    private void ".$event[$i]."(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_".$event[$i]."\n".
                           "        // TODO add your handling code here:\n";
                # if selected is opposite to something else remove all something else before setting the new one.
                if (exists $h_bo{$str}) {
                    my $oppo  = $structPgrm->{$str."_OppositeTo"};
                    my @oppos = ();
                    if ($oppo=~/<>/) {
                        @oppos = split ("<>",$oppo) if ($oppo=~/<>/);
                    } else {
                        push (@oppos, $oppo);
                    }
                    print $out  "        if (properties.isSet(".$oppos[0].".getName())";
                    for (my $z = 1; $z < scalar @oppos; $z++) {
                        print $out  " &&\n            properties.isSet(".$oppos[$z].".getName())";
                    }
                    print $out  "\n        ){\n            properties.remove(".$oppos[0].".getName());\n".
                                "            ".$oppos[0].".setSelected(false);\n";
                    print $out  "            ".$h_bv{$oppos[0]}.".setEnabled(false);\n" if (exists $h_bv{$oppos[0]}); # Find in value or text
                    for (my $z = 1; $z < scalar @oppos; $z++) {
                        print $out  "\n            properties.remove(".$oppos[$z].".getName());\n";
                                    "            ".$oppos[$z].".setSelected(false);\n";
                        print $out  "            ".$h_bv{$oppos[$z]}.".setEnabled(false);\n" if (exists $h_bv{$oppos[$z]}); # Find in value or text
                    }
                    print $out  "        }\n";
                }
                
                # if one menu is selected remove the other
                if (scalar @menu>0 && $event[$i] =~/_RButton_ActionPerformed$/) {
                    print $out  "        if (properties.isSet(".$menu[0].".getName())";
                    for (my $z = 1; $z < scalar @menu; $z++) {
                        print $out  " &&\n            properties.isSet(".$menu[$z].".getName())";
                    }
                    print $out  "\n        ){\n            properties.remove(".$menu[0].".getName());\n".
                                "            ".$menu[0].".setSelected(false);\n";
                    for (my $z = 1; $z < scalar @menu; $z++) {
                        print $out  "\n            properties.remove(".$menu[$z].".getName());\n";
                                    "            ".$menu[$z].".setSelected(false);\n";
                    }
                    print $out  "        }\n";
                }
                
                # Add the event
                my $val = "null";
                
                
                if (exists $h_bv{$str}) {
                    $val = $h_bv{$str};
                }
                my $val_type = "Spinner";
                
                if ($val =~ /_text$/i) {
                    $val_type = "Text";
                } elsif ($val=~/_List$/i){
                    $val_type = "ComboBox";
                }
                if ($val_type=~/(Spinner|Text|ComboBox)/ &&
                    $str !~ /_Dir.{0,5}?$/i) { # Classic options
                    print $out  "        Util.".$type."Event".$val_type."(properties,".$str.",".$val.");\n";
                }
                
                # Add dir.{3,5} activation
                my $dir = &dirActivation($structPgrm,$str);
                
                if ($dir ne "" && $str !~ /_Dir.{0,5}?$/i) {
                    print $out  "        if (properties.isSet(".$str.".getName()))\n".
                                "            ".$dir.".setEnabled(true);\n".
                                "        else\n".
                                "            ".$dir.".setEnabled(false);\n";
                }
                 # Dir/File(s) options
                 # Dir box gestion !!
                 
                if ($str =~ /_Dir[a-z,A-Z]{3,5}$/i) { # Dir/File(s) options
                    
                    
                    print ">>>>>>>>".$str."\n";
                    
                    
                    my ($ori) = $str =~ /(.*)_Dir[a-z,A-Z]{3,5}$/;
                    my $text = $ori."_Text";
                    
                    print $out  "        JFileChooser d;\n".
                                "        if (this.".$text.".getText().isEmpty()) {\n".
                                "            d=new JFileChooser(config.getExplorerPath());\n".
                                "        } else {\n".
                                "            d=new JFileChooser(this.".$text.".getText());\n".
                                "        }\n";
                                if ($val =~ /_DirRep$/) {
                    print $out  "        d.setFileSelectionMode(JFileChooser.DIRECTORIES_ONLY);\n";
                                } else {
                    print $out  "        d.setFileSelectionMode(JFileChooser.FILES_ONLY);\n";
                                }
                    print $out  "        d.setAcceptAllFileFilterUsed(false);\n";
                                if ($val =~ /_DirFiles$/) {
                    print $out  "        d.setMultiSelectionEnabled(true);\n";
                                } else {
                    print $out  "        d.setMultiSelectionEnabled(false);\n";
                                }
                    print $out  "        int result = d.showOpenDialog(this);\n".
                                "        \n".
                                "        if (result==JFileChooser.APPROVE_OPTION) {\n".
                                "            File dir = d.getSelectedFile();\n".
                                "            \n".
                                "            // Set the text\n".
                                "            String s = dir.getAbsolutePath();\n".
                                "            ".$text.".setText(s);\n".
                                "            properties.remove(".$text.".getName());\n".
                                "            Util.".$type."EventText(properties,".$ori.",".$text.");\n".
                                "        }\n";
                }
                if (exists $structPgrm->{$str."_Dir"}) {
                    print $out  "        if (properties.isSet(".$str.".getName())) {\n".
                                "            ".$str."_Dir.setVisible(true);\n".
                                "        } else {\n".
                                "            ".$str."_Dir.setVisible(false);\n".
                                "        }\n";
                }
                
                # if selected is parents of something else, set this thing enabled or desabled
                if (exists $h_bp{$str}) {
                    my $par  = $structPgrm->{$h_bp{$str}};
                    my @pars = ();
                    if ($par=~/<>/) {
                        @pars = split ("<>",$par) if ($par=~/<>/);
                    } else {
                        push (@pars, $par);
                    }
                    
                    print $out  "        if (properties.isSet(".$str.".getName())) {\n";
                    for (my $z = 0; $z < scalar @pars; $z++) {
                        print $out  "            ".$pars[$z].".setEnabled(true);\n";
                    }
                    
                    print $out  "        } else {\n";
                    
                    for (my $z = 0; $z < scalar @pars; $z++) {
                        print $out  "            ".$pars[$z].".setEnabled(false);\n";
                        if (exists $h_bv{$pars[$z]}) {
                            print $out  "            ".$h_bv{$pars[$z]}.".setEnabled(false);\n";
                        }
                    }
                    print $out  "        }\n";
                }
                
                if (scalar @menu>0  && $event[$i] =~/_RButton_ActionPerformed$/) {
                    print $out "        menuFields(properties);\n";
                }
                # Closed Type bouton, box ou rbox or combobox
                print $out  "    }//GEN-LAST:event_".$event[$i]."\n";
            }
            
            # Type button, box ou rbox
            elsif ($event[$i] =~ /^.*_ActionPerformed$/ && $str=~/_list$/i) {
                # START Type list
                print $out "\n    private void ".$event[$i]."(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_".$event[$i]."\n".
                           "        // TODO add your handling code here:\n";
                my $st = "";
                foreach my $k (keys %h_bv) {
                    if ($h_bv{$k} eq $str) {
                        $st = $k;
                    }
                }
                print $out  "        Util.".$type."EventComboBox(properties,".$st.",".$str.");\n".
                            "    }//GEN-LAST:event_".$event[$i]."\n";
            }

            # Type text
            elsif ($event[$i] =~ /^.*_FocusLost$/) {
                print $out "\n    private void ".$event[$i]."(java.awt.event.FocusEvent evt) {//GEN-FIRST:event_".$event[$i]."\n".
                           "        // TODO add your handling code here:\n";
                my $st = "";
                foreach my $k (keys %h_bv) {
                    if ($h_bv{$k} eq $str) {
                        $st = $k;
                    }
                }
                
                print $out "        Util.".$type."EventText(properties,".$st.",".$str.");\n"
                          ."    }//GEN-LAST:event_".$event[$i]."\n";
            }
            
            # Type value
            elsif ($event[$i] =~ /^.*_StateChanged$/) {
                print $out "\n    private void ".$event[$i]."(javax.swing.event.ChangeEvent evt) {//GEN-FIRST:event_".$event[$i]."\n".
                           "        // TODO add your handling code here:\n";
                my $st = "";
                foreach my $k (keys %h_bv) {
                    if ($h_bv{$k} eq $str) {
                        $st = $k;
                    }
                }
                print $out "        Util.".$type."EventSpinner(properties,".$st.",".$str.");\n".
                           "    }//GEN-LAST:event_".$event[$i]."\n";
            }
        }
        return;
    }
    

    # ===============================================
    #     SUB FUNCTION OF createJavaEditorFile
    #     Create USP functions
    # ===============================================
    sub createUSPFunctions {
        my $out         = $_[0];
        my $structPgrm  = $_[1];
        
        # Retrieve variables
        my @tab_value   = &fromVtoA($structPgrm->{"tab_value"}); #Initials of value
        my @tab_text    = &fromVtoA($structPgrm->{"tab_text"}); #Initials of text
        my @tab_comb    = &fromVtoA($structPgrm->{"tab_comb"}); #Initials of combobox
        my @tab_box     = &fromVtoA($structPgrm->{"tab_box"}); #Initials of box
        my @tab_button  = &fromVtoA($structPgrm->{"tab_button"}); #Initials of buttons
        my @tab_RButton = &fromVtoA($structPgrm->{"tab_RButton"}); #Initials of RButtons
        my %h_bv        = &fromVtoH($structPgrm->{"h_bv"}); #Button -> Value
        my %h_bp        = &fromVtoH($structPgrm->{"h_bp"}); #Button -> Parent of
        
        print $out "    private void usp_valueANDtext (workflow_properties properties) {\n";
        &createValueAndTextFunction($out,\@tab_value,"value");
        &createValueAndTextFunction($out,\@tab_text,"text",$structPgrm);
        &createValueAndTextFunction($out,\@tab_comb,"comb");
        print $out "    }\n    \n";
        print $out "    private void usp_boxANDbutton (workflow_properties properties) {\n";
        &createBoxAndButtonFunction($out,\@tab_box,\%h_bv,\%h_bp,$structPgrm);
        &createBoxAndButtonFunction($out,\@tab_RButton,\%h_bv,\%h_bp,$structPgrm);
        &createBoxAndButtonFunction($out,\@tab_button,\%h_bv,\%h_bp,$structPgrm);
        print $out "    }\n    \n";
        return;
    }

        # For Value and text
        sub createValueAndTextFunction {
            my $o    = $_[0];
            my @t    = @{$_[1]};
            my $type = $_[2];
            my $st   = $_[3];
            
            my %h_t_j =(
                "Byt" => "Byte",
                "Int" => "Integer,Int",
                "Lon" => "Long",
                "Sho" => "Short",
                "Flo" => "Float",
                "Dou" => "Double",
                "Boo" => "Integer,Int"
            );
            
            for (my $i =0; $i < scalar @t ; $i++){
                print $o "        if (properties.isSet($t[$i].getName())){\n";
                if ($t[$i] =~/_(byt|int|dou|flo|lon|sho|boo)Value$/i) {
                    print $o "            this.$t[$i].setValue(";
                    my ($op) = $t[$i] =~/_(Byt|Int|Dou|Flo|Lon|Sho|Boo)Value$/i;
                    my @ops = split (",", $h_t_j{$op});
                    if (scalar @ops == 2) {
                        print $o $ops[0].".parse".$ops[1];
                    } else {
                        print $o $ops[0].".parse".$ops[0];
                    }
                    print $o "(properties.get($t[$i].getName())));\n";
                } elsif ($type eq "text") {
                    my ($str)=$t[$i]=~/(.+)_Text/i;
                    my $dir = &dirActivation($st,$str);
                    print $o "            this.$t[$i].setText(properties.get($t[$i].getName()));\n" ;
                    print $o "            this.$dir.setEnabled(false);\n" if ($dir ne"");
                } elsif ($type eq "comb") {
                    print $o "            this.$t[$i].setSelectedItem(properties.get($t[$i].getName()));\n";
                }
                print $o "            this.$t[$i].setEnabled(false);\n";
                print $o  "        }\n";
            }
            return;
        }

        # For Box and button
        sub createBoxAndButtonFunction {
            my $o   = $_[0];
            my @t   = @{$_[1]};
            my %h_b = %{$_[2]};
            my %h_p = %{$_[3]};
            my $s   = $_[4];

            for (my $i =0; $i < scalar(@t) ; $i++){
                print $o "        if (properties.isSet($t[$i].getName())){\n".
                      "            this.$t[$i].setSelected(true);\n";
                my $dir = &dirActivation($s,$t[$i]);
                if ($dir ne ""){
                    print $o "            this.".$dir.".setEnabled(true);\n";
                }
                if((exists($h_b{$t[$i]}))){
                    if ($h_b{$t[$i]}ne""){
                        print $o "            this.".$h_b{$t[$i]}.".setEnabled(true);\n";
                    }
                }
                if((exists($h_p{$t[$i]}))){
                    my @tps = split ("<>",$s->{$h_p{$t[$i]}});
                    foreach my $tp (@tps) {
                        print $o "            this.".$tp.".setEnabled(true);\n";
                    }
                    print $o "        } else {\n";
                    foreach my $tp (@tps) {
                        print $o "            this.".$tp.".setEnabled(false);\n";
                    }
                }
                print $o "        }\n";
            }
            return;
        }
        
    # ===============================================
    #     SUB FUNCTION OF createJavaEditorFile
    #     Create Enabled functions
    # ===============================================
    sub createEnabledFunction {
        my $out         = $_[0];
        my $structPgrm  = $_[1];
        my @tab_box     = &fromVtoA($structPgrm->{"tab_box"}); #Initials of box
        my @tab_button  = &fromVtoA($structPgrm->{"tab_button"}); #Initials of buttons
        my @tab_RButton = &fromVtoA($structPgrm->{"tab_RButton"}); #Initials of RButtons
        my %h_bv        = &fromVtoH($structPgrm->{"h_bv"}); #Button -> Value
        
        my $bool = 0;
        
        my @tabs_enabled = &foundEnabledvalues($structPgrm);
        
        foreach my $t (@tabs_enabled) {
            print $out "    private void enabledFunctionFor".$structPgrm->{$t}."(boolean e) {\n";
            $t = $t."_0" if ($t =~ /^\d*$/);
            &createEnabledTabFunction($out,\@tab_box,\%h_bv,$structPgrm,$t);
            &createEnabledTabFunction($out,\@tab_button,\%h_bv,$structPgrm,$t);
            &createEnabledTabFunction($out,\@tab_RButton,\%h_bv,$structPgrm,$t);
            print $out "    }\n    \n";
        }
        
    }
    
    sub foundEnabledvalues {
        my %structPgrm  = %{$_[0]};
        my @ts = ();
        my $tp = "";
        
        for (my $t=1;$t<keys %structPgrm;$t++){
            my $bool = 0;
            for (my $s=0;$s<keys %structPgrm;$s++){
                $tp = $t."_".$s;
                if (exists $structPgrm{$tp}) {
                    $bool = 1;
                    push (@ts,$tp);
                }
            }
            if ($bool == 0 && exists $structPgrm{$t}) {
                push (@ts,$t);
            }
        }
        return @ts;
    }

    sub createEnabledTabFunction {
        my $o  = $_[0];
        my @t  = @{$_[1]};
        my %h  = %{$_[2]};
        my %st = %{$_[3]};
        my $tp = $_[4];
        
        my $tp2 = "";
        for (my $c=0;$c<keys %st;$c++){
            $tp2 = $tp."_".$c;
            for (my $i =0; $i < scalar(@t) ; $i++){
                if (exists $st{$tp2} && $st{$tp2} eq $t[$i]) {
                    print $o "        this.$t[$i].setEnabled(e);\n";
                    # Add dir.{3,5} activation
                    my $dir = &dirActivation(\%st,$t[$i]);
                    if((exists($h{$t[$i]})) && $h{$t[$i]} ne ""){
                        print $o "        if (properties.isSet($t[$i].getName()) && e==true) {\n";
                        print $o "            this.".$h{$t[$i]}.".setEnabled(true);\n";
                        print $o "            this.".$dir.".setEnabled(true);\n" if ($dir ne "");
                        print $o "        } else {\n".
                                 "            this.".$h{$t[$i]}.".setEnabled(false);\n";
                        print $o "            this.".$dir.".setEnabled(false);\n" if ($dir ne "");
                        print $o "        }\n\n";
                    }
                }
            }
        }
        return;
    }
    
    # ===============================================
    #     SUB FUNCTION OF createJavaEditorFile
    #     Create default defaultPgrmValues functions
    # ===============================================
    sub defaultPgrmValues {
        my $o = $_[0];
        my %s = %{$_[1]};
        
        my @menu = &getMenuValues(\%s);
        
        print $o "    private void defaultPgrmValues(workflow_properties properties) {\n";
        if (scalar@menu>0) {
            print $o  "        boolean b = true;\n".
                      "        if (";
            for (my $m=0;$m<scalar@menu;$m++){
                print $o  "        && " if ($m >0);
                print $o  "!(properties.isSet(".$menu[$m].".getName()))\n";
            }
            print $o  "        ) {\n".
                      "            b = false;\n".
                      "        }\n".
                      "        \n".
                      "        Util.getDefaultPgrmValues(properties,b);\n";
        } else {
            print $o  "        //Util.getDefaultPgrmValues(properties,boolean to test the presence of a default value);\n";
        }
        print $o  "    }\n".
            "    \n";
        return;
    }
    
    # ===============================================
    #     SUB FUNCTION OF createJavaEditorFile
    #     Create default defaultPgrmValues functions
    # ===============================================
    sub menuFields {
        my $o = $_[0];
        my %h = %{$_[1]};
        my %h_menu = &fromVtoH($h{"h_menu"}); #Menu Link
        
        my @ts = &foundEnabledvalues(\%h);
        
        # Menu Fields Options setting
        if (exists $h{"0_0"}) {
            print $o  "    /*******************************************************************\n".
                      "     * Set Menu fields\n".
                      "     ******************************************************************/\n".
                      "\n".
                      "    private void menuFields(workflow_properties properties) {\n".
                      "        if (properties.isSet(".$h{"0_0"}.".getName())) {\n".
                      "            ".$h{"0_0"}.".setSelected(true);\n";
            foreach my $t (@ts) {
               print $o  "            enabledFunctionFor".$h{$t}."(false);\n";
            }
            print $o  "        }\n";
            foreach my $h_m (keys %h_menu) {
                foreach my $t (@ts) {
                    if ($t eq $h_menu{$h_m}) {
                        print $o  "        else if (properties.isSet(".$h{$h_m}.".getName())) {\n".
                                  "            ".$h{$h_m}.".setSelected(true);\n";
                        print $o  "            enabledFunctionFor".$h{$t}."(true);\n" ;
                        print $o  "        }\n";
                    }
                }
            }
        print $o  "    }\n";
        }
    }


=begin comment





========================================================================
                    JAVA FILE EDITOR FORM CREATION
========================================================================





=end comment
=cut

# ===============================================
#     FUNCTION create Java File Editor Form
# in  : get infos from csv
# out : print infos in java file
# ===============================================
sub createJavaEditorForm {
    my $fileSource = $_[0];
    my %structPgrm = %{$_[1]};
    my %linkType   = &fromVtoH($structPgrm{"linkType"}); #Link between type and java extension
    my @event;
    
    my @menu   = &getMenuValues(\%structPgrm);
    my $nbMenu = scalar @menu;
    
    my $programmeName = $structPgrm{"0"}."Editors";
    
    my $file=">".$pTAEdit."".$programmeName.".form";
    open (my $out , $file) or die $!;
    print $out  "<?xml version=\"1.0\" encoding=\"UTF-8\" ?>\n".
                "\n".
                "<Form version=\"1.5\" maxVersion=\"1.9\" type=\"org.netbeans.modules.form.forminfo.JDialogFormInfo\">\n";
    if ($nbMenu > 0) {
    print $out  "    <NonVisualComponents>\n".
                "        <Component class=\"javax.swing.ButtonGroup\" name=\"Menu_Buttons\">\n".
                "        </Component>\n".
                "    </NonVisualComponents>\n";
    }
    print $out  "    <Properties>\n".
                "        <Property name=\"defaultCloseOperation\" type=\"int\" value=\"2\"/>\n".
                "    </Properties>\n".
                "    <SyntheticProperties>\n".
                "        <SyntheticProperty name=\"formSizePolicy\" type=\"int\" value=\"1\"/>\n".
                "        <SyntheticProperty name=\"generateCenter\" type=\"boolean\" value=\"false\"/>\n".
                "    </SyntheticProperties>\n".
                "    <AuxValues>\n".
                "        <AuxValue name=\"FormSettings_autoResourcing\" type=\"java.lang.Integer\" value=\"0\"/>\n".
                "        <AuxValue name=\"FormSettings_autoSetComponentName\" type=\"java.lang.Boolean\" value=\"false\"/>\n".
                "        <AuxValue name=\"FormSettings_generateFQN\" type=\"java.lang.Boolean\" value=\"true\"/>\n".
                "        <AuxValue name=\"FormSettings_generateMnemonicsCode\" type=\"java.lang.Boolean\" value=\"false\"/>\n".
                "        <AuxValue name=\"FormSettings_i18nAutoMode\" type=\"java.lang.Boolean\" value=\"false\"/>\n".
                "        <AuxValue name=\"FormSettings_layoutCodeTarget\" type=\"java.lang.Integer\" value=\"1\"/>\n".
                "        <AuxValue name=\"FormSettings_listenerGenerationStyle\" type=\"java.lang.Integer\" value=\"0\"/>\n".
                "        <AuxValue name=\"FormSettings_variablesLocal\" type=\"java.lang.Boolean\" value=\"false\"/>\n".
                "        <AuxValue name=\"FormSettings_variablesModifier\" type=\"java.lang.Integer\" value=\"2\"/>\n".
                "    </AuxValues>\n".
                "\n".
                "    <Layout>\n".
                "        <DimensionLayout dim=\"0\">\n".
                "            <Group type=\"103\" groupAlignment=\"0\" attributes=\"0\">\n".
                "                <Group type=\"102\" attributes=\"0\">\n";
                if (exists $structPgrm{"0_doImage"}) {
    print $out  "                    <EmptySpace max=\"32767\" attributes=\"0\"/>\n".
                "                    <Component id=\"docker_jButton\" min=\"-2\" max=\"-2\" attributes=\"0\"/>\n";
                }
    print $out  "                    <EmptySpace max=\"32767\" attributes=\"0\"/>\n".
                "                    <Component id=\"how_jButton\" min=\"-2\" max=\"-2\" attributes=\"0\"/>\n".
                "                </Group>\n".
                "                <Component id=\"".$programmeName."\" min=\"-2\" max=\"-2\" attributes=\"0\"/>\n".
                "            </Group>\n".
                "        </DimensionLayout>\n".
                "        <DimensionLayout dim=\"1\">\n".
                "            <Group type=\"103\" groupAlignment=\"0\" attributes=\"0\">\n".
                "                <Group type=\"102\" attributes=\"0\">\n";
                if (exists $structPgrm{"0_doImage"}) {
    print $out  "                    <Group type=\"103\" groupAlignment=\"3\" attributes=\"0\">\n    ".
                "                    <Component id=\"docker_jButton\" min=\"-2\" max=\"-2\" attributes=\"0\"/>\n    ";
                }
    print $out  "                    <Component id=\"how_jButton\" min=\"-2\" max=\"-2\" attributes=\"0\"/>\n";
                if (exists $structPgrm{"0_doImage"}) {
    print $out  "                                    </Group>\n";
                }    
    print $out  "                    <EmptySpace max=\"-2\" attributes=\"0\"/>\n".
                "                    <Component id=\"".$programmeName."\" min=\"-2\" max=\"32767\" attributes=\"0\"/>\n".
                "                </Group>\n".
                "            </Group>\n".
                "        </DimensionLayout>\n".
                "    </Layout>\n".
                "\n".
                "    <SubComponents>\n";
                if (exists $structPgrm{"0_doImage"}) {
    print $out  "        <Component class=\"javax.swing.JButton\" name=\"docker_jButton\">\n".
                "            <Properties>\n".
                "                <Property name=\"text\" type=\"java.lang.String\" value=\"Docker Editor\"/>\n".
                "                <Property name=\"name\" type=\"java.lang.String\" value=\"docker_jButton\" noResource=\"true\"/>\n".
                "            </Properties>\n".
                "            <AccessibilityProperties>\n".
                "                <Property name=\"AccessibleContext.accessibleDescription\" type=\"java.lang.String\" value=\"Access to the docker editor\"/>\n".
                "            </AccessibilityProperties>\n".
                "            <Events>\n".
                "                <EventHandler event=\"actionPerformed\" listener=\"java.awt.event.ActionListener\" parameters=\"java.awt.event.ActionEvent\" handler=\"docker_jButton_ActionPerformed\"/>\n".
                "            </Events>\n".
                "        </Component>\n".
                "    \n";
                }
    print $out  "        <Component class=\"javax.swing.JButton\" name=\"how_jButton\">\n".
                "            <Properties>\n".
                "                <Property name=\"text\" type=\"java.lang.String\" value=\"?\"/>\n".
                "                <Property name=\"name\" type=\"java.lang.String\" value=\"how_jButton\" noResource=\"true\"/>\n".
                "            </Properties>\n".
                "            <AccessibilityProperties>\n".
                "                <Property name=\"AccessibleContext.accessibleDescription\" type=\"java.lang.String\" value=\"".&cleanHelpText($structPgrm{"0_help"})."\"/>\n".
                "            </AccessibilityProperties>\n".
                "            <Events>\n".
                "                <EventHandler event=\"actionPerformed\" listener=\"java.awt.event.ActionListener\" parameters=\"java.awt.event.ActionEvent\" handler=\"how_jButton_ActionPerformed\"/>\n".
                "            </Events>\n".
                "        </Component>\n".
                "\n".
                "        <Container class=\"javax.swing.JTabbedPane\" name=\"".$programmeName."2\">\n".
                "            <AccessibilityProperties>\n".
                "                <Property name=\"AccessibleContext.accessibleName\" type=\"java.lang.String\" value=\"".$programmeName."\"/>\n".
                "            </AccessibilityProperties>\n".
                "            <Events>\n".
                "                <EventHandler event=\"componentShown\" listener=\"java.awt.event.ComponentListener\" parameters=\"java.awt.event.ComponentEvent\" handler=\"".$programmeName."2ComponentShown\"/>\n".
                "            </Events>\n".
                "            <AuxValues>\n".
                "                <AuxValue name=\"JavaCodeGenerator_SerializeTo\" type=\"java.lang.String\" value=\"".$programmeName."\"/>\n".
                "            </AuxValues>\n\n".
                "            <Layout class=\"org.netbeans.modules.form.compat2.layouts.support.JTabbedPaneSupportLayout\"/>\n". #pas fermés
                "            <SubComponents>\n".
                "                <Container class=\"javax.swing.JPanel\" name=\"general_jPanel1\">\n".
                "                    <Properties>\n".
                "                        <Property name=\"name\" type=\"java.lang.String\" value=\"general_jPanel1\" noResource=\"true\"/>\n".
                "                        <Property name=\"preferredSize\" type=\"java.awt.Dimension\" editor=\"org.netbeans.beaninfo.editors.DimensionEditor\">\n".
                "                            <Dimension value=\"[459,".&getComponentsHeight(\%structPgrm)."]\"/>\n".
                "                        </Property>\n".
                "                    </Properties>\n".
                "                    <Constraints>\n".
                "                        <Constraint layoutClass=\"org.netbeans.modules.form.compat2.layouts.support.JTabbedPaneSupportLayout\" value=\"org.netbeans.modules.form.compat2.layouts.support.JTabbedPaneSupportLayout\$JTabbedPaneConstraintsDescription\">\n".
                "                            <JTabbedPaneConstraints tabName=\"".$programmeName."\">\n".
                "                                <Property name=\"tabTitle\" type=\"java.lang.String\" value=\"".$programmeName."\"/>\n".
                "                            </JTabbedPaneConstraints>\n".
                "                        </Constraint>\n".
                "                    </Constraints>\n".
                "\n".
                "                    <Layout>\n".
                "                        <DimensionLayout dim=\"0\">\n".
                "                            <Group type=\"103\" groupAlignment=\"0\" attributes=\"0\">\n".
                "                                <Group type=\"102\" alignment=\"0\" attributes=\"0\">\n".
#                "                                    <EmptySpace type=\"separate\" max=\"-2\" attributes=\"0\"/>\n".
                "                                    <Component id=\"name_jLabel\" min=\"-2\" max=\"-2\" attributes=\"0\"/>\n".
                "                                    <EmptySpace type=\"separate\" max=\"-2\" attributes=\"0\"/>\n".
                "                                    <Component id=\"name_jTextField\" min=\"-2\" pref=\"248\" max=\"-2\" attributes=\"0\"/>\n".
                "                                    <EmptySpace type=\"separate\" max=\"-2\" attributes=\"0\"/>\n".
                "                                    <Component id=\"rename_jButton\" min=\"-2\" max=\"-2\" attributes=\"0\"/>\n".
                "                                </Group>\n";
    if ($nbMenu>0) {
        print $out "                                <Group type=\"102\" alignment=\"0\" attributes=\"0\">\n";
        for (my $i=0; $i<$nbMenu;$i++){
            if ($i==($nbMenu-1)) {
                print $out  "                                    <Component id=\"".$menu[$i]."\" alignment=\"0\" min=\"-2\" max=\"-2\" attributes=\"0\"/>\n";
            } else {
                print $out  "                                    <Component id=\"".$menu[$i]."\" alignment=\"0\" min=\"-2\" max=\"-2\" attributes=\"0\"/>\n".
                            "                                    <EmptySpace type=\"separate\" max=\"-2\" attributes=\"0\"/>\n";
            }
        }
        print $out "                                </Group>\n";
    }

    &addTitlePanelSetting($out,\%structPgrm,0);
    print $out  "                                <Group type=\"102\" alignment=\"0\" attributes=\"0\">\n".
                "                                    <Component id=\"reset_jButton\" min=\"-2\" max=\"-2\" attributes=\"0\"/>\n".
                "                                    <EmptySpace type=\"separate\" max=\"-2\" attributes=\"0\"/>\n".
                "                                    <Component id=\"stop_jButton\" min=\"-2\" max=\"-2\" attributes=\"0\"/>\n".
                "                                    <EmptySpace type=\"separate\" max=\"-2\" attributes=\"0\"/>\n".
                "                                    <Component id=\"run_jButton\" min=\"-2\" max=\"-2\" attributes=\"0\"/>\n".
                "                                    <EmptySpace type=\"separate\" max=\"-2\" attributes=\"0\"/>\n".
                "                                    <Component id=\"close_jButton\" min=\"-2\" max=\"-2\" attributes=\"0\"/>\n".
                "                                </Group>\n".
                "                            </Group>\n".
                "                        </DimensionLayout>\n".
                "                        <DimensionLayout dim=\"1\">\n".
                "                            <Group type=\"103\" groupAlignment=\"0\" attributes=\"0\">\n".
                "                                <Group type=\"102\" alignment=\"0\" attributes=\"0\">\n".
                "                                    <EmptySpace max=\"-2\" attributes=\"0\"/>\n".
                "                                    <Group type=\"103\" groupAlignment=\"3\" attributes=\"0\">\n".
                "                                        <Component id=\"name_jLabel\" alignment=\"3\" min=\"-2\" max=\"-2\" attributes=\"0\"/>\n".
                "                                        <Component id=\"name_jTextField\" alignment=\"3\" min=\"-2\" max=\"-2\" attributes=\"0\"/>\n".
                "                                        <Component id=\"rename_jButton\" alignment=\"3\" min=\"-2\" max=\"-2\" attributes=\"0\"/>\n".
                "                                    </Group>\n";
    if ($nbMenu>0) {
        print $out "                                    <EmptySpace max=\"-2\" attributes=\"0\"/>\n";
        print $out "                                    <Group type=\"103\" groupAlignment=\"3\" attributes=\"0\">\n";
        for (my $i=0; $i<$nbMenu;$i++){
            print $out  "                                        <Component id=\"".$menu[$i]."\" alignment=\"3\" min=\"-2\" max=\"-2\" attributes=\"0\"/>\n";
        }
        print $out "                                    </Group>\n";
    }
    &addTitlePanelSetting($out,\%structPgrm,1);
    print $out "                                     <EmptySpace max=\"-2\" attributes=\"0\"/>\n";
    print $out  "                                    <Group type=\"103\" groupAlignment=\"3\" attributes=\"0\">\n".
                "                                        <Component id=\"reset_jButton\" alignment=\"3\" min=\"-2\" max=\"-2\" attributes=\"0\"/>\n".
                "                                        <Component id=\"stop_jButton\" alignment=\"3\" min=\"-2\" max=\"-2\" attributes=\"0\"/>\n".
                "                                        <Component id=\"run_jButton\" alignment=\"3\" min=\"-2\" max=\"-2\" attributes=\"0\"/>\n".
                "                                        <Component id=\"close_jButton\" alignment=\"3\" min=\"-2\" max=\"-2\" attributes=\"0\"/>\n".
                "                                    </Group>\n".
                "                                </Group>\n".
                "                            </Group>\n".
                "                        </DimensionLayout>\n".
                "                    </Layout>\n".
                "\n".
                "                    <SubComponents>\n";
    &addComponentClass($out,"name_jLabel","NULL","Name",\%linkType,"","");
    print $out  "                        <Component class=\"javax.swing.JTextField\" name=\"name_jTextField\">\n".
                "                            <Properties>\n".
                "                                <Property name=\"text\" type=\"java.lang.String\" value=\"".$structPgrm{"0"}."\"/>\n".
                "                                <Property name=\"name\" type=\"java.lang.String\" value=\"name_jTextField\" noResource=\"true\"/>\n".
                "                            </Properties>\n".
                "                            <AccessibilityProperties>\n".
                "                                <Property name=\"AccessibleContext.accessibleDescription\" type=\"java.lang.String\" value=\"\"/>\n".
                "                            </AccessibilityProperties>\n".
                "                            <Events>\n".
                "                                <EventHandler event=\"actionPerformed\" listener=\"java.awt.event.ActionListener\" parameters=\"java.awt.event.ActionEvent\" handler=\"name_jTextField_ActionPerformed\"/>\n".
                "                            </Events>\n".
                "                        </Component>\n";

    &addComponentClass($out,"rename_jButton","NULL","Rename",\%linkType,"","");
    &addComponentClass($out,"reset_jButton","NULL","Reset",\%linkType,"","");
    &addComponentClass($out,"close_jButton","NULL","Close",\%linkType,"","");
    &addComponentClass($out,"stop_jButton","NULL","Stop",\%linkType,"","");
    &addComponentClass($out,"run_jButton","NULL","Run",\%linkType,"","");
    for (my $i=0; $i<$nbMenu;$i++){
        my ($text) = $menu[$i] =~ /(.*)_RButton$/ ;
        $text =~ s/_/ /g;
        &addComponentClass($out,$menu[$i],"NULL",$text,\%linkType,"menu","");
    }
    
    # Add Panel
    for (my $t=1; $t<keys %structPgrm;$t++) {
        if (exists $structPgrm{$t}) {
            &createPanelFormSetting($out,\%structPgrm,$t);
        }
    }
    print $out  "                    </SubComponents>\n".
                "                </Container>\n".
                "            </SubComponents>\n".
                "        </Container>\n".
                "    </SubComponents>\n".
                "</Form>\n";
    close $out;
    return %structPgrm;
}

    # ===============================================
    #     SUB FUNCTION OF createJavaEditorForm
    # ===============================================
    sub addTitlePanelSetting {
        my $out = $_[0];
        my %s = %{$_[1]};
        my $d = $_[2];
        
        my @p = ();
        foreach my $k (keys %s) {
            if ($k=~/_panel/) {
                my ($v) = $k =~ /(.*)_panel/;
                my @t   = split ("_",$v);
                if (scalar @t ==1){
                    push (@p,$k);
                }
            }
        }
        @p = sort (@p);
        for (my $i =0 ; $i < scalar @p ; $i++) {
            print $out "                                        <EmptySpace max=\"-2\" attributes=\"0\"/>\n    " if ($d == 1);
            print $out "                                    <Component id=\"".$p[$i]."\" alignment=\"0\" min=\"-2\" max=\"-2\" attributes=\"0\"/>\n";
        }
    }


    # ===============================================
    #     SUB FUNCTION OF createJavaEditorForm
    # ===============================================
    sub addComponentClass {
        my $out      = $_[0];
        my $nom      = $_[1];
        my $val      = $_[2];
        my $text     = $_[3];
        my %linkType = %{$_[4]};
        my $menu     = $_[5];
        my $help     = $_[6];
        
        my $type = "";

        # Prepare values
        foreach my $lt (keys %linkType) {
            if ($nom=~/$lt$/) {
                $type = $linkType{$lt};
            }
        }
      
        my $vals = "";
        $vals = &fixSpinnerValues($nom,$val,"ef") if ($val ne "NULL");
        
        # Start component
        print $out  "                        <Component class=\"javax.swing.".$type."\" name=\"".$nom."\">\n";
        # Properties part
        print $out  "                            <Properties>\n";
        if ($nom=~/value$/i) { #numberType="java.lang.Integer"
            print $out  "                                <Property name=\"model\" type=\"javax.swing.SpinnerModel\" editor=\"org.netbeans.modules.form.editors2.SpinnerModelEditor\">\n".
                        "                                    <SpinnerModel ".$vals." type=\"number\"/>\n".
                        "                                </Property>\n";
        }
        if ($menu ne "") {
                print $out  "                                <Property name=\"buttonGroup\" type=\"javax.swing.ButtonGroup\" editor=\"org.netbeans.modules.form.RADComponent\$ButtonGroupPropertyEditor\">\n".
                            "                                    <ComponentRef name=\"Menu_Buttons\"/>\n".
                            "                                </Property>\n";
        }
        if ($nom=~/j?label$/i) {
            print $out  "                                <Property name=\"font\" type=\"java.awt.Font\" editor=\"org.netbeans.beaninfo.editors.FontEditor\">\n".
                        "                                    <Font name=\"Ubuntu\" size=\"15\" style=\"3\"/>\n".
                        "                                </Property>\n";
        }
        if ($nom!~/value$/i && $nom!~/_List$/i && $nom!~/_Te?xt$/i) {
            print $out "                                <Property name=\"text\" type=\"java.lang.String\" value=\"".$text."\"/>\n";
        }
        if ($nom=~/Te?xt$/i) {
            print $out "                                <Property name=\"text\" type=\"java.lang.String\" value=\"".$val."\"/>//2\n";
        }
        if ($nom!~/jButton\d+$/){
            print $out "                                <Property name=\"name\" type=\"java.lang.String\" value=\"".$nom."\" noResource=\"true\"/>\n";
        }
        if ($type eq "JTextField" || $type eq "JSpinner") {
            print $out "                                <Property name=\"preferredSize\" type=\"java.awt.Dimension\" editor=\"org.netbeans.beaninfo.editors.DimensionEditor\">\n";
            if ($type eq "JTextField") {
                print $out "                                    <Dimension value=\"[220, 27]\"/>\n";
            }
            if ($type eq "JSpinner") {
                print $out "                                    <Dimension value=\"[115, 28]\"/>\n";
            }
            print $out "                                </Property>\n";
        }
        
        if ($nom=~/_List$/i) {
            print $out "                                <Property name=\"model\" type=\"javax.swing.ComboBoxModel\" editor=\"org.netbeans.modules.form.editors2.ComboBoxModelEditor\">\n";
            my @comboTexts = split (", ",$vals);
            print $out "                                      <StringArray count=\"".scalar @comboTexts."\">\n";
            for (my $i = 0; $i < scalar @comboTexts;$i++) {
                print $out "                                          <StringItem index=\"$i\" value=\"".$comboTexts[$i]."\"/>\n";
            }
            print $out "                                      </StringArray>\n".
                       "                                  </Property>\n";
        }
        print $out "                            </Properties>\n";
        
        if ($nom!~/j?label/i) {
            print $out  "                            <AccessibilityProperties>\n".
                        "                                <Property name=\"AccessibleContext.accessibleDescription\" type=\"java.lang.String\" value=\"".$help."\"/>\n".
                        "                            </AccessibilityProperties>\n";
        }

        # Events part
        if ($nom!~/j?label/i) {
            print $out "                            <Events>\n";
            if ($nom=~/_(RB|b|JB)utton(\d+)?$/i || $nom=~/_box$/i || $nom=~/_Dir[a-z,A-Z]{3,5}$/i || $nom=~/_List$/i) {
                print $out "                                <EventHandler event=\"actionPerformed\" listener=\"java.awt.event.ActionListener\" parameters=\"java.awt.event.ActionEvent\" handler=\"".$nom."_ActionPerformed\"/>\n";
            }
            if ($nom=~/Text$/i) {
                print $out "                                <EventHandler event=\"focusLost\" listener=\"java.awt.event.FocusListener\" parameters=\"java.awt.event.FocusEvent\" handler=\"".$nom."_FocusLost\"/>\n";
            }
            if ($nom=~/value$/i) {
                print $out "                                <EventHandler event=\"stateChanged\" listener=\"javax.swing.event.ChangeListener\" parameters=\"javax.swing.event.ChangeEvent\" handler=\"".$nom."_StateChanged\"/>\n";
            }
        print $out "                            </Events>\n";
        }
        # END component
        print $out "                        </Component>\n";
    }


    sub getInsideData {
        my %structPgrm = %{$_[0]};
        my %h_bv       = %{$_[1]};
        my $ini        = $_[2];
        my @data       = ();
        
        for (my $c=0;$c<keys %structPgrm;$c++){
            my $str = $ini."_".$c;
            my $nom = ".";
            my $text= ".";
            my $b_v = ".";
            my $b_l = ".";
            my $b_d = ".";
            if (exists $structPgrm{$str}) {
                $nom = $structPgrm{$str};
                $text= $structPgrm{$nom};
                $b_v = $h_bv{$nom}   if (exists $h_bv{$nom});
                $b_l = $nom."_Label" if (exists $structPgrm{$nom."_Label"});
                $b_d = &dirActivation(\%structPgrm,$nom);
                $b_d = "." if ($b_d eq "");
                push (@data,$nom."<>".$text."<>".$b_v."<>".$b_l."<>".$b_d."<>".$str);
            }
        }
        return @data;
    }

    # ===============================================
    #     SUB FUNCTION OF createJavaEditorForm
    # ===============================================
    sub createPanelFormSetting {
        my $out        = $_[0];
        my %structPgrm = %{$_[1]};
        my $t          = $_[2];
        my $p_tabPanel = ""; # Search for tabpanel presence
        
        # Retrieve variables
        my %h_bv       = &fromVtoH($structPgrm{"h_bv"});
        my %initials   = &fromVtoH($structPgrm{"initials"});
        my %linkType   = &fromVtoH($structPgrm{"linkType"}); #Link between type and java extension
        my %h_tabPanel = &fromVtoH($structPgrm{"h_tabPanel"}); #TabPanel -> Tab and Panel -> TabPanel
        
        if (exists $structPgrm{$initials{$t}."_tabpanel"}) {
            $p_tabPanel = $initials{$t}."_tabpanel"; # Search for tabpanel presence
        }
        my $bool = $t=~/^\d+$/;
        my @data = ();
        if ($bool) {
            @data = &getInsideData(\%structPgrm,\%h_bv,$t."_0") ; # Inside $t
        } else {
            @data = &getInsideData(\%structPgrm,\%h_bv,$t);       # Inside $st
        }
        
        if ($bool) {
        print $out  "                        <Container class=\"javax.swing.JPanel\" name=\"".$initials{$t}."_panel\">\n".
                    "                            <Properties>\n".
                    "                                <Property name=\"border\" type=\"javax.swing.border.Border\" editor=\"org.netbeans.modules.form.editors2.BorderEditor\">\n".
                    "                                    <Border info=\"org.netbeans.modules.form.compat2.border.TitledBorderInfo\">\n".
                    "                                        <TitledBorder title=\"".$structPgrm{$t}."\"/>\n".
                    "                                    </Border>\n".
                    "                                </Property>\n".
                    "                            </Properties>\n\n";
        } else {
            print $out  "                        <Container class=\"javax.swing.JPanel\" name=\"".$initials{$t}."_Spanel\">\n".
                        "                            <Constraints>\n".
                        "                                <Constraint layoutClass=\"org.netbeans.modules.form.compat2.layouts.support.JTabbedPaneSupportLayout\" value=\"org.netbeans.modules.form.compat2.layouts.support.JTabbedPaneSupportLayout\$JTabbedPaneConstraintsDescription\">".
                        "                                    <JTabbedPaneConstraints tabName=\"".$initials{$t}."\">".
                        "                                    <Property name=\"tabTitle\" type=\"java.lang.String\" value=\"".$initials{$t}."\"/>".
                        "                                </JTabbedPaneConstraints>".
                        "                            </Constraint>".
                        "                            </Constraints>";
        }
        print $out  "                            <Layout>\n".
                    "                                <DimensionLayout dim=\"0\">\n".
                    "                                    <Group type=\"103\" groupAlignment=\"0\" attributes=\"0\">\n".
                    "                                        <Group type=\"102\" alignment=\"0\" attributes=\"0\">\n".
                    "                                            <EmptySpace max=\"-2\" attributes=\"0\"/>\n".
                    "                                            <Group type=\"103\" groupAlignment=\"0\" attributes=\"0\">\n";
        for (my $c=0;$c<scalar @data;$c++){
            my ($nom,$text,$b_v,$b_l,$b_d,$str) = split ("<>",$data[$c]);
            if ($nom ne ".") {
                if ( $b_v ne "." || $b_l ne "." || $b_d ne "."){
                    print $out  "                                                <Group type=\"102\" groupAlignment=\"0\" attributes=\"0\">\n";
                }
                print $out  "                                                    <Component id=\"".$nom."\" min=\"-2\" max=\"-2\" attributes=\"0\"/>\n";
                if ($b_v ne ".") {
                    print $out  "                                                    <EmptySpace type=\"separate\" max=\"-2\" attributes=\"0\"/>\n".
                                "                                                    <Component id=\"".$b_v."\" min=\"-2\" max=\"-2\" attributes=\"0\"/>\n";
                }
                if ($b_l ne ".") {
                    print $out  "                                                    <EmptySpace type=\"separate\" max=\"-2\" attributes=\"0\"/>\n".
                                "                                                    <Component id=\"".$b_l."\" min=\"-2\" max=\"-2\" attributes=\"0\"/>\n";
                }
                if ($b_d ne ".") {
                    print $out  "                                                    <EmptySpace type=\"separate\" max=\"-2\" attributes=\"0\"/>\n".
                                "                                                    <Component id=\"".$b_d."\" min=\"-2\" max=\"-2\" attributes=\"0\"/>\n";
                }
                print $out  "                                                </Group>\n" if ( $b_v ne "." || $b_l ne "." || $b_d ne ".");
            }
        }
        if ($p_tabPanel ne "") {
            print $out  "                                                <Component id=\"".$p_tabPanel."\" min=\"-2\" max=\"-2\" attributes=\"0\"/>\n";
        }
        print $out  "                                            </Group>\n".
                    "                                            <EmptySpace max=\"-2\" attributes=\"0\"/>\n".
                    "                                        </Group>\n".
                    "                                    </Group>\n".
                    "                                </DimensionLayout>\n".
                    "                                <DimensionLayout dim=\"1\">\n".
                    "                                    <Group type=\"103\" groupAlignment=\"0\" attributes=\"0\">\n".
                    "                                        <Group type=\"102\" attributes=\"0\">\n";
        for (my $c=0;$c<scalar @data;$c++){
            my ($nom,$text,$b_v,$b_l,$b_d,$str) = split ("<>",$data[$c]);
            if ($nom ne ".") {
                print $out  "                                            <EmptySpace max=\"-2\" attributes=\"0\"/>\n";
                print $out  "                                            <Group type=\"103\"  groupAlignment=\"3\"  attributes=\"0\">\n" if ( $b_v ne "." || $b_l ne "." || $b_d ne ".");
                print $out  "                                                <Component id=\"".$nom."\" alignment=\"3\" min=\"-2\" max=\"-2\" attributes=\"0\"/>\n";
                print $out  "                                                <Component id=\"".$b_v."\" alignment=\"3\" min=\"-2\" max=\"-2\" attributes=\"0\"/>\n" if ($b_v ne ".");
                print $out  "                                                <Component id=\"".$b_d."\" alignment=\"3\" min=\"-2\" max=\"-2\" attributes=\"0\"/>\n" if ($b_d ne ".");
                print $out  "                                                <Component id=\"".$b_l."\" alignment=\"3\" min=\"-2\" max=\"-2\" attributes=\"0\"/>\n" if ($b_l ne ".");
                print $out  "                                            </Group>\n" if ( $b_v ne "." || $b_l ne "." || $b_d ne ".");
            }
        }
        if ($p_tabPanel ne "") {
            print $out  "                                            <EmptySpace max=\"-2\" attributes=\"0\"/>\n".
                        "                                            <Component id=\"".$p_tabPanel."\" min=\"-2\" max=\"-2\" attributes=\"0\"/>\n";
        }
        print $out  "                                            <EmptySpace max=\"-2\" attributes=\"0\"/>\n".
                    "                                        </Group>\n".
                    "                                    </Group>\n".
                    "                                </DimensionLayout>\n".
                    "                            </Layout>\n\n".
                    "                            <SubComponents>\n";
        for (my $c=0;$c<scalar @data;$c++){
            my ($nom,$text,$b_v,$b_l,$b_d,$str) = split ("<>",$data[$c]);
            if ($nom ne "." && $text ne ".") {
                my $help="";
                if ($str ne "." && exists $structPgrm{$initials{$str}."_Help"}){
                    $help=$structPgrm{$initials{$str}."_Help"};
                }
                if ($nom=~/_box$/i  || $nom=~/_r?button$/i ){
                    &addComponentClass($out,$nom,"NULL",$text,\%linkType,"",$help);
                    if ($b_v ne ".") {
                        my $v = $structPgrm{$b_v};
                        &addComponentClass($out,$b_v,$v,$text,\%linkType,"",$help);
                    }
                    if ($b_l ne ".") {
                        my $v = $structPgrm{$b_l};
                        &addComponentClass($out,$b_l,$v,$v,\%linkType,"",$help);
                    }
                    if ($b_d ne ".") {
                        my $v = $structPgrm{$b_d};
                        &addComponentClass($out,$b_d,$v,$text,\%linkType,"",$help);
                    }
                } else {
                    &addComponentClass($out,$nom,"NULL",$nom,\%linkType,"",$help);
                }
            }
        }
        
        if ($p_tabPanel ne "") {
            print $out  "                                <Container class=\"javax.swing.JTabbedPane\" name=\"".$p_tabPanel."\">\n".
                        "                                    <Layout class=\"org.netbeans.modules.form.compat2.layouts.support.JTabbedPaneSupportLayout\"/>\n".
                        "                                    <SubComponents>\n";
            my @subPanels = split ("<>",$h_tabPanel{$p_tabPanel});
            for (my $s=0;$s<scalar @subPanels;$s++){
                    &createPanelFormSetting($out,\%structPgrm,$structPgrm{$subPanels[$s]});
            }
            print $out  "                                    </SubComponents>\n";
            print $out  "                                </Container>\n";
        }
            
            
            print $out  "                            </SubComponents>\n";
            print $out  "                        </Container>\n";

    }
    
    sub cleanHelpText {
        my $t = $_[0];
        my %s = ("á" => "&aacute;","Á" => "&Aacute;","â" => "&acirc;","Â" => "&Acirc;","à" => "&agrave;","À" => "&Agrave;","å" => "&aring;","Å" => "&Aring;","ã" => "&atilde;","Ã" => "&Atilde;","ä" => "&auml;","Ä" => "&Auml;","æ" => "&aelig;","Æ" => "&AElig;","ç" => "&ccedil;","Ç" => "&Ccedil;","é" => "&eacute;","É" => "&Eacute;","ê" => "&ecirc;","Ê" => "&Ecirc;","è" => "&egrave;","È" => "&Egrave;","ë" => "&euml;","Ë" => "&Euml;","í" => "&iacute;","Í" => "&Iacute;","î" => "&icirc;","Î" => "&Icirc;","ì" => "&igrave;","Ì" => "&Igrave;","ï" => "&iuml;","Ï" => "&Iuml;","ñ" => "&ntilde;","Ñ" => "&Ntilde;","ó" => "&oacute;","Ó" => "&Oacute;","ô" => "&ocirc;","Ô" => "&Ocirc;","ò" => "&ograve;","Ò" => "&Ograve;","ø" => "&oslash;","Ø" => "&Oslash;","õ" => "&otilde;","Õ" => "&Otilde;","ö" => "&ouml;","Ö" => "&Ouml;","œ" => "&oelig;","Œ" => "&OElig;","š" => "&scaron;","Š" => "&Scaron;","ß" => "&szlig;","ð" => "&eth;","Ð" => "&ETH;","þ" => "&thorn;","Þ" => "&THORN;","ú" => "&uacute;","Ú" => "&Uacute;","û" => "&ucirc;","Û" => "&Ucirc;","ù" => "&ugrave;","Ù" => "&Ugrave;","ü" => "&uuml;","Ü" => "&Uuml;","ý" => "&yacute;","Ý" => "&Yacute;","ÿ" => "&yuml;","ÿ" => "&Yuml;","-" => "&shy;","«" => "&laquo;","»" => "&raquo;","‹" => "&lsaquo;","›" => "&rsaquo;","“" => "&ldquo;","”" => "&rdquo;","„" => "&bdquo;","’" => "&rsquo;","‚" => "&sbquo;","…" => "&hellip;","!" => "!","¡" => "&iexcl;","?" => "?","¿" => "&iquest;","(" => "(",")" => ")","[" => "[","]" => "]","{" => "{","}" => "}","¨" => "&uml;","´" => "&acute;","`" => "`","^" => "^","ˆ" => "&circ;","~" => "~","˜" => "&tilde;","¸" => "&cedil;","#" => "#","*" => "*","," => ",","." => ".",":" => ":",";" => ";","·" => "&middot;","•" => "&bull;","¯" => "&macr;","‾" => "&oline;","-" => "-","–" => "&ndash;","—" => "&mdash;","_" => "_","|" => "|","¦" => "&brvbar;","†" => "&dagger;","†" => "&Dagger;","§" => "&sect;","¶" => "&para;","©" => "&copy;","®" => "&reg;","™" => "&trade;","&" => "&amp;","@" => "@","/" => "/","\\" => "\\","◊" => "&loz;","♠" => "&spades;","♣" => "&clubs;","♥" => "&hearts;","♦" => "&diams;","←" => "&larr;","↑" => "&uarr;","→" => "&rarr;","↓" => "&darr;","↔" => "&harr;","¤" => "&curren;","€" => "&euro;","\$" => "\$","¢" => "&cent;","£" => "&pound;","¥" => "&yen;","ƒ" => "&fnof;","°" => "&deg;","µ" => "&micro;","<" => "&lt;",">" => "&gt;","≤" => "&le;","≥" => "&ge;","Err :520" => "Err :520","≈" => "&asymp;","≠" => "&ne;","≡" => "&equiv;","±" => "&plusmn;","−" => "&minus;","+" => "+","×" => "&times;","÷" => "&divide;","⁄" => "&frasl;","%" => "%","‰" => "&permil;","¼" => "&frac14;","½" => "&frac12;","¾" => "&frac34;","¹" => "&sup1;","²" => "&sup2;","³" => "&sup3;","º" => "&ordm;","ª" => "&ordf;","ƒ" => "&fnof;","′" => "&prime;","′" => "&Prime;","∂" => "&part;","∏" => "&prod;","∑" => "&sum;","√" => "&radic;","∞" => "&infin;","¬" => "&not;","∩" => "&cap;","∫" => "&int;","→" => "&rArr;","↔" => "&hArr;","∀" => "&forall;","∃" => "&exist;","∇" => "&nabla;","∈" => "&isin;","∋" => "&ni;","∝" => "&prop;","∠" => "&ang;","⊥" => "&and;","⊦" => "&or;","∪" => "&cup;","∴" => "&there4;","∼" => "&sim;","⊂" => "&sub;","⊃" => "&sup;","⊆" => "&sube;","⊇" => "&supe;","⊥" => "&perp;","α" => "&alpha;","Α" => "&Alpha;","β" => "&beta;","Β" => "&Beta;","γ" => "&gamma;","Γ" => "&Gamma;","δ" => "&delta;","Δ" => "&Delta;","ε" => "&epsilon;","Ε" => "&Epsilon;","ζ" => "&zeta;","Ζ" => "&Zeta;","η" => "&eta;","Η" => "&Eta;","θ" => "&theta;","Θ" => "&Theta;","ι" => "&iota;","Ι" => "&Iota;","κ" => "&kappa;","Κ" => "&Kappa;","λ" => "&lambda;","Λ" => "&Lambda;","μ" => "&mu;","Μ" => "&Mu;","ν" => "&nu;","Ν" => "&Nu;","ξ" => "&xi;","Ξ" => "&Xi;","ο" => "&omicron;","Ο" => "&Omicron;","π" => "&pi;","Π" => "&Pi;","ρ" => "&rho;","Ρ" => "&Rho;","σ" => "&sigma;","ς" => "&sigmaf;","Σ" => "&Sigma;","τ" => "&tau;","Τ" => "&Tau;","υ" => "&upsilon;","Υ" => "&Upsilon;","φ" => "&phi;","Φ" => "&Phi;","χ" => "&chi;","Χ" => "&Chi;","ψ" => "&psi;","Ψ" => "&Psi;","ω" => "&omega;","Ω" => "&Omega;","\""=>"&quot","‘"=>"&lsquo");
        
        foreach my $k (keys %s) {
            $t =~ s/\Q$k\E/$s{$k}/g;
        }
        return $t;
    }
    
    
=begin comment





========================================================================
                    JAVA PROGRAM FILE CREATION
========================================================================





=end comment
=cut

# ===============================================
#     FUNCTION create Java File Program
# in  : get infos from csv
# out : print infos in java file
# ===============================================
sub createProgramsFile {
    my $fileSource = $_[0];
    my %structPgrm = %{$_[1]};
    my @event;
    
    my @menu = &getMenuValues(\%structPgrm);
    
    # Retrieve variables
    my %h_bv = &fromVtoH($structPgrm{"h_bv"});
    my %h_in = &fromVtoH($structPgrm{"h_in"});
    my %h_ou = &fromVtoH($structPgrm{"h_ou"});
    my %bioFiles = &fromVtoH($structPgrm{"bioFiles"}); #Biologic Files used in that program
    
    my $programmeName = $structPgrm{"0"};
    
    my %portToName = (
        "true"=>"PortInputDOWN",
        3=>"PortInputUP",
        2=>"PortInputDOWN",
        4=>"PortInputDOWN2"
    );
    
    my $file=">".$pTAProg."".$programmeName.".java";
    open (my $out , $file) or die $!;
    print $out  "/*\n".
                "* To change this license header, choose License Headers in Project Properties.\n".
                "* To change this template file, choose Tools | Templates\n".
                "* and open the template in the editor.\n".
                "* Author : $author\n".
                "* Date   : $date\n".
                "*/\n".
                "\n".
                "package programs;\n".
                "\n";
    foreach my $bfile (keys %bioFiles) {
        print $out "import biologic.".$bfile.";\n";
    }
    if (exists $structPgrm{"0_doImage"}) {
        print $out  "import configuration.Docker;\n";
    }
    print $out  "import configuration.Util;\n".
                "import java.io.File;\n".
                "import java.util.Vector;\n".
                "import java.util.Hashtable;\n".
                "import java.util.Map;\n".
                "import java.util.Iterator;\n".
                "import program.RunProgram;\n".
                "import static program.RunProgram.PortInputUP;\n".
                "import static program.RunProgram.df;\n".
                "import static program.RunProgram.status_error;\n".
                "import workflows.workflow_properties;\n".
                "import java.io.IOException;\n".
                "import java.util.ArrayList;\n".
                "import java.util.logging.Level;\n".
                "import java.util.logging.Logger;\n".
                "\n".
                "\n".
                "/**\n".
                " *\n".
                " * \@author $author\n".
                " * \@date $date\n".
                " *\n".
                " */\n".
                "public class ".$programmeName." extends RunProgram {\n".
                "    // CREATE VARIABLES HERE\n";
    if (exists $structPgrm{"0_doImage"}) {
        print $out  "    private String doImage        = \"".$structPgrm{"0_doImage"}."\";\n".
                    "    private String doPgrmPath     = \"".$structPgrm{"0_doPgrmPath"}."\";\n".
                    "    private String doSharedFolder = \"".$structPgrm{"0_doSharedFolder"}."\";\n".
                    "    private String doName         = \"".$structPgrm{"0_doName"}."\";\n";
    }
    print $out  "    //INPUTS\n";
    if (keys %h_in > 0) {
        for (my $z=0;$z<keys %h_in;$z++){
            if (exists $h_in{$z."_type"}) {
                print $out "    private String input".$z."       =\"\";\n" ;
                print $out "    private String inputPath".$z."   =\"\";\n" ;
                
                if (exists $structPgrm{"0_doImage"}) {
                    print $out "    private String inputInDo".$z."   =\"\";\n" ;
                    print $out "    private String inputPathDo".$z." =\"\";\n" ;
                }
            }
        }
    } else {
        print $out  "    //private String input1      =\"\";\n".
                    "    //private String inputPath1  =\"\";\n" ;
        
        if (exists $structPgrm{"0_doImage"}) {
            print $out "    //private String inputInDo1   =\"\";\n" ;
            print $out "    //private String inputPathDo1 =\"\";\n" ;
        }
    }
    print $out  "    //OUTPUTS\n";
    if (keys %h_ou > 0) {
        for (my $z=0;$z<keys %h_ou;$z++){
            if (exists $h_ou{$z."_type"}) {
                print $out "    private String output".$z."       =\"\";\n";
                if (exists $structPgrm{"0_doImage"}) {
                    print $out "    private String outputInDo".$z."   =\"\";\n" ;
                    print $out "    private String outputPathDo".$z." =\"\";\n" ;
                }
            }
        }
    } else {
        print $out "    //private String output1   =\"\";\n";
        if (exists $structPgrm{"0_doImage"}) {
            print $out "    //private String outputInDo1   =\"\";\n" ;
            print $out "    //private String outputPathDo1 =\"\";\n" ;
        }
    }
    
    print $out  "    //PATHS\n";
    if (exists $structPgrm{"0_outPath"}) {
        my $str = $structPgrm{"0_outPath"};
        $str =~ s/[\/,\\]/"+File.separator+"/g;
        $str = "\"".$str."\"";
        print $out "    private static final String outputPath = ".$str.";\n".
                   "    private static final String inputPath  = outputPath+File.separator+\"INPUTS\";\n\n";
    } else {
        print $out "    private static final String outputPath = \".\"+File.separator+\"results\"+File.separator+\"".$programmeName."\";\n".
                   "    private static final String inputPath  = outputPath+File.separator+\"INPUTS\";\n\n";
    }
    
    my @tabPerPanel = &getAndPrintTabPerPanel($out,\%structPgrm,\%h_bv);
    
    print $out  "\n    public ".$programmeName."(workflow_properties properties) {\n".
                "        this.properties=properties;\n".
                "        execute();\n".
                "    }\n".
                "\n".
                "    \@Override\n".
                "    public boolean init_checkRequirements() {\n";
                    &testInputsVariables($out,\%h_in,\%portToName,\%structPgrm);
    print $out  "\n";
                    if (exists $structPgrm{"0_doImage"}) {
                        &testDockerInfos($out);
                    }
    print $out  "        return true;\n".
                "    }\n".
                "\n".
                "    \@Override\n".
                "    public String[] init_createCommandLine() {\n".
                "\n".
                "        // In case program is started without edition\n".
                "        pgrmStartWithoutEdition(properties);\n".
                "\n";
                        &createOutputs($out,\%h_ou,\%h_in,\%structPgrm);
    print $out  "        \n".
                "        // Program and Options\n".
                "        String options = \"\";\n";
    if (scalar @tabPerPanel > 0) {
    print $out  "        if (!properties.isSet(\"".$structPgrm{"0_0"}."\")) {\n";
    }
    for  (my $i=0;$i<scalar @tabPerPanel;$i++){
        print $out  "            options += Util.findOptionsNew(".$tabPerPanel[$i].",properties);\n";
    }
    if (scalar @tabPerPanel > 0) {
    print $out  "        }\n";
    }
    print $out  "        \n".
                "        // Command line creation\n".
                "        String[] com = new String[30];\n".
                "        for (int i=0; i<com.length;i++) com[i]=\"\";\n".
                "        \n";
                my $i = 0;
    print $out  "        com[".$i."]=\"cmd.exe\"; // Windows will de remove if another os is used\n".
                "        com[".++$i."]=\"/C\";      // Windows will de remove if another os is used\n". 
                "        com[".++$i."]=properties.getExecutable();\n";
    if (exists $structPgrm{"0_doImage"}) {
    print $out  "        com[".++$i."]= \"exec \"+doName+\" \"+doPgrmPath ;\n";
    }
    print $out  "        com[".++$i."]=options;\n";
    if (keys %h_in > 0) {
        for (my $z=0;$z<keys %h_in;$z++){
            if (exists $h_in{$z."_type"}) {
                my $com = "";
                $com = $h_in{$z."_command"} if (exists $h_in{$z."_command"});
                print $out "        com[".++$i."]= \"".$com." \"+input";
                if (exists $structPgrm{"0_doImage"}) {
                    print $out "InDo" ;
                }else{
                    print $out "Path";
                }
                print $out $z.";\n";
            }
        }
    } else {
        print $out  "        com[".++$i."]=inputPath1;\n";
    }
    if (keys %h_ou > 0) {
        for (my $z=0;$z<keys %h_ou;$z++){
            if (exists $h_ou{$z."_type"}) {
                my $com = "";
                $com = $h_ou{$z."_command"} if (exists $h_ou{$z."_command"});
                print $out "        com[".++$i."]= \"".$com." \"+output";
                if (exists $structPgrm{"0_doImage"}) {
                    print $out "InDo" ;
                }else{
                    print $out "Path";
                }
                print $out $z.";\n";
            }
        }
    } else {
        print $out  "        //com[".++$i."]=output1;\n";
    }
    print $out  "        return com;\n".
                "    }\n".
                "\n".
                "        // Sub functions for init_createCommandLine\n".
                "        // In case program is started without edition and params need to be setted\n".
                "        private void pgrmStartWithoutEdition (workflow_properties properties) {\n";
    if (scalar @menu>0){
        print $out  "            if (";
        for (my $m=0;$m<scalar@menu;$m++){
            print $out  "                && " if ($m >0);
            print $out  "!(properties.isSet(\"".$menu[$m]."\"))\n";
        }
        print $out  "            ) {\n".
                    "                Util.getDefaultPgrmValues(properties,false);\n".
                    "            }\n";
    } else {
        print $out  "           //if (!properties.isSet(\"\")) Util.getDefaultPgrmValues(properties, true);\n";
    }
                
    print $out  "        }\n".
                "\n".
                "    /*\n".
                "    * Output Parsing\n".
                "    */\n".
                "\n".
                "    \@Override\n".
                "    public void post_parseOutput() {\n";
    if (exists $structPgrm{"0_doImage"}) {
                &removeInputDoFiles($out);
    }
    if (exists $structPgrm{"0_doCopyFiles"}) {
                &copyDockerFiles($out,\%structPgrm);
    }
    if (exists $structPgrm{"0_save"}) {
                &saveFiles($out,\%structPgrm);
    }
                &setOutputResults($out,\%h_ou,$programmeName);
    print $out  "        Results.saveResultsPgrmOutput(properties,this.getPgrmOutput(),\"".$programmeName."\");\n";
    print $out  "    }\n".
                "}\n";
    return %structPgrm;
}


    # ===============================================
    #     SUB FUNCTION OF createProgramsFile
    # ===============================================
    sub getAndPrintTabPerPanel {
        my $out        = $_[0];
        my %structPgrm = %{$_[1]};
        my %h_bv       = %{$_[2]};
        
        my @tabPerPanel = ();
        foreach my $k (keys %structPgrm) {
            if ($k=~/_panel/) {
                my $s = $structPgrm{$k};
                $s = $s."_0" if ($s =~ /^\d+$/);
                my @tab = ();
                for (my $i=1;$i<keys %structPgrm;$i++){
                    my $e = $s."_".$i;
                    if (exists $structPgrm{$e}) {
                        push (@tab,$structPgrm{$e});
                    }
                }
                if (scalar @tab > 0) {
                    push (@tabPerPanel,$k);
                    print $out  "    private static final String[] ".$k." = {\n";
                    for (my $i=0;$i<scalar @tab;$i++){
                        if ($i==(scalar @tab-1)) {
                            print $out  "        \"".$tab[$i]."\"";
                            if (exists $h_bv{$tab[$i]}) {
                                print $out  "//,\n        //\"".$h_bv{$tab[$i]}."\"\n";
                            } else {
                                print $out  "\n";
                            }
                        } else {
                            print $out  "        \"".$tab[$i]."\",\n";
                            if (exists $h_bv{$tab[$i]}) {
                                print $out  "        //\"".$h_bv{$tab[$i]}."\",\n";
                            }
                        }
                    }
                    print $out  "    };\n\n";
                }
            }
        }
        return @tabPerPanel;
    }
    
    sub testDockerInfos {
        my $out    = $_[0];
        print $out  "        // TEST Docker initialisation\n".
                    "        doName = Docker.getContainersVal(doName);\n".
                    "        if (!dockerInit(outputPath,doSharedFolder,doName,doImage)) {\n".
                    "            Docker.cleanContainers(doName);\n".
                    "            return false;\n".
                    "        } else {\n".
                    "            properties.put(\"DOCKERName\",doName);\n".
                    "        }\n".
                    "\n";
    }
    
    sub testInputsVariables {
        my $out        = $_[0];
        my %h_in       = %{$_[1]};
        my %portToName = %{$_[2]};
        my %structPgrm = %{$_[3]};
        
        print $out "        // TEST INPUT VARIABLES HERE les ports sont PortInputUp, PortInputDOWN, PortInputDOWN2\n";
        if (keys %h_in > 0) {
            for (my $z=0;$z<keys %h_in;$z++){
                if (exists $h_in{$z."_type"}) {
                    print $out "\n        Vector<Integer>".$h_in{$z."_type"}."_".$z."    = properties.getInputID(\"".$h_in{$z."_type"}."\",".$portToName{$h_in{$z."_connectNum"}}.");\n".
                               "        inputPath".$z." = ".$h_in{$z."_type"}.".get".$h_in{$z."_type"}."Path(".$h_in{$z."_type"}."_".$z.");\n".
                               "        input".$z."     = Util.getFileNameAndExt(inputPath".$z.");\n";
                }
            }
        } else {
            print $out "        // No imput : Example\n".
                       "        Vector<Integer>Fastq1    = properties.getInputID(\"FastqFile\",PortInputDOWN);\n".
                       "        inputPath1 = FastqFile.getFastqPath(Fastq1);\n".
                       "        input1     = Util.getFileNameAndExt(inputPath1);\n";
        }
        print $out  "\n";
        &insertYourTestHere($out,\%h_in);
        print $out  "\n";
        &insertSharedFiles($out,\%h_in,\%structPgrm);
        return;
    }

        sub insertYourTestHere {
            my $out  = $_[0];
            my %h_in = %{$_[1]};
            print $out  "        //INSERT YOUR TEST HERE\n";
            if (keys %h_in > 0) {
                for (my $z=0;$z<keys %h_in;$z++){
                    if (exists $h_in{$z."_type"}) {
                        if ($z==1) {
                            print $out  "        if (".$h_in{$z."_type"}."_".$z.".isEmpty()||input".$z.".equals(\"Unknown\")||input".$z.".equals(\"\")) {\n".
                                        "            setStatus(status_BadRequirements,\"No ".$h_in{$z."_type"}." found.\");\n".
                                        "            return false;\n".
                                        "        }\n";
                        } else {
                            print $out  "        else if (".$h_in{$z."_type"}."_".$z.".isEmpty()||input".$z.".equals(\"Unknown\")||input".$z.".equals(\"\")) {\n".
                                        "            setStatus(status_BadRequirements,\"No ".$h_in{$z."_type"}." found.\");\n".
                                        "            return false;\n".
                                        "        }\n";
                        }
                    }
                }
            } else {
                print $out  "        // No imput : Example\n".
                            "        if (Fastq1.isEmpty()||input1.equals(\"Unknown\")||input1.equals(\"\")) {\n".
                            "            setStatus(status_BadRequirements,\"No sequence found.\");\n".
                            "            return false;\n".
                            "        }\n";
            }
            return;
        }

        sub insertSharedFiles {
            my $out  = $_[0];
            my %h_in = %{$_[1]};
            my %structPgrm = %{$_[2]};
            print $out  "        //INSERT DOCKER SHARED FILES COPY HERE\n";
            if (exists $structPgrm{"0_doImage"}) {
                print $out "        if (!Util.CreateDir(inputPath) && !Util.DirExists(inputPath)){\n".
                           "            setStatus(status_BadRequirements,\"Not able to create INPUTS directory files\");\n".
                           "            return false;\n".
                           "        }\n".
                           "        if (!Util.CreateDir(outputPath) && !Util.DirExists(outputPath)){\n".
                           "            setStatus(status_BadRequirements,\"Not able to create OUTPUTS directory files\");\n".
                           "            return false;\n".
                           "        }\n";
                if (keys %h_in > 0) {
                    for (my $z=0;$z<keys %h_in;$z++){
                        if (exists $h_in{$z."_type"}) {
                            print $out "\n        inputPathDo".$z." = outputPath+File.separator+\"INPUTS\"+File.separator+input".$z.";\n".
                                       "        if (!(Util.copy(inputPath".$z.",inputPathDo".$z."))) {\n".
                                       "            setStatus(status_BadRequirements,\"Not able to copy files\");\n".
                                       "            return false;\n".
                                       "        }\n".
                                       "        inputInDo".$z." = doSharedFolder+File.separator+\"INPUTS\"+File.separator+input".$z.";\n".
                                       "        input".$z." = Util.getFileName(inputPath".$z.");\n";

                        }
                    }
                } else {
                    print $out "\n        inputPathDo1 = Util.getCanonicalPath(outputPath+File.separator+input1);\n".
                               "        if (!(Util.copy(inputPath1,inputPathDo1))) {\n".
                               "            setStatus(status_BadRequirements,\"Not able to copy files\");\n".
                               "            return false;\n".
                               "        }\n".
                               "        inputDo1 = doSharedFolder+File.separator+input1;\n".
                               "        input1   = Util.getFileName(inputPath1);\n";
                }
            } 
            return;
        }

    sub createOutputs {
        my $out        = $_[0];
        my %h_ou       = %{$_[1]};
        my %h_in       = %{$_[2]};
        my %structPgrm = %{$_[3]};

        print $out  "        //Create ouputs\n";
        if (keys %h_ou > 0) {
            for (my $z=0;$z<keys %h_ou;$z++){
                if (exists $h_ou{$z."_type"}) {
                    if (exists $h_in{$z."_type"}) {
                        print $out "        output".$z." = outputPath+File.separator+\"OutpuOf_\"+input".$z."+\"".$h_ou{$z."_extention"}."\";\n";
                        if (exists $structPgrm{"0_doImage"}) {
                            print $out "        outputInDo".$z." = doSharedFolder+File.separator+\"OutpuOf_\"+input".$z."+\"".$h_ou{$z."_extention"}."\";\n";
                        }
                    } else {
                        print $out "        output".$z." = outputPath+File.+\"OutpuOf_\"+input1+\"".$h_ou{$z."_extention"}."\";\n" if (exists $h_in{$z."_type"});
                        if (exists $structPgrm{"0_doImage"}) {
                            print $out "        outputInDo".$z." = doSharedFolder+File.separator+\"OutpuOf_\"+input1+\"".$h_ou{$z."_extention"}."\";\n";
                        }
                    }
                }
            }
        } else {
            print $out  "        // No output : Example\n".
                        "        //output1 = outputPath+File.separator+\"OutpuOf_\"+input1+\".outputExtention\";\n";
            if (exists $structPgrm{"0_doImage"}) {
                print $out "        //outputInDo1 = doSharedFolder+File.separator+\"OutpuOf_\"+input1+\".outputExtention\";\n";
            }
        }
        return;
    }
    
    sub copyDockerFiles {
        my $out        = $_[0];
        my %structPgrm = %{$_[1]};
        
        my @t = split ("<>",$structPgrm{"0_doCopyFiles"});
        foreach my $i (@t) {
            print $out  "        boolean b1 = Docker.copyDockerDirToSharedDir(\"".$i."\",doSharedFolder+\"".$structPgrm{"0"}."\",doName);\n".
                        "        if (!b1) setStatus(status_BadRequirements,\"Docker Files Copy Failed\");\n";
        }
    }
    
    sub saveFiles {
        my $out        = $_[0];
        my %structPgrm = %{$_[1]};
        
        my @t = split ("<>",$structPgrm{"0_save"});
        foreach my $i (@t) {
            print $out  "        boolean b2 = Util.copyDirectory(doSharedFolder+\"".$structPgrm{"0"}."\",\"".$i."".$structPgrm{"0"}."\");\n".
                        "        if (!b2) setStatus(status_BadRequirements,\"Saved Files Copy Failed\");\n";
        }
    }
    
    sub setOutputResults {
        my $out           = $_[0];
        my %h_ou          = %{$_[1]};
        my $programmeName = $_[2];
        
        if (keys %h_ou > 0) {
            for (my $z=0;$z<keys %h_ou;$z++){
                if (exists $h_ou{$z."_type"}) {
                    print $out "        ".$h_ou{$z."_type"}.".save".$h_ou{$z."_type"}."(properties,output".$z.",\"".$programmeName."\");\n";
                }
            }
        } else {
            print $out  "        //SAMPLE OF OUTPUT as SAMFILE\n".
                        "        //SamFile.saveSamFile(properties,output1,\"".$programmeName."\");\n";
        }
    }
    
    sub removeInputDoFiles {
        my $out           = $_[0];
        print $out  "        Util.deleteDir(outputPath+File.separator+\"INPUTS\");\n".
                    "        ArrayList<String> a = new ArrayList<String>();\n".
                    "        a.add(doName);\n".
                    "        Docker.cleanContainers(a);\n";
    }
    
    
=begin comment





========================================================================
                    JAVA PROPERTIES FILE CREATION
========================================================================





=end comment
=cut


# ===============================================
#     FUNCTION create Java File Properties
# in  : get infos from csv
# out : print infos in java file
# ===============================================
sub createPropertiesFile {
    my $fileSource = $_[0];
    my %structPgrm = %{$_[1]};
    
    # Retreive variables
    my %b_v       = &fromVtoH($structPgrm{"h_bv"});
    my %h_in      = &fromVtoH($structPgrm{"h_in"});
    my %h_ou      = &fromVtoH($structPgrm{"h_ou"});
    
    my @colorModeOptions = &fromVtoA($structPgrm{"colorModeOptions"});

    my $programmeName = $structPgrm{"0"};
    
    my $file=">".$pTAProp."".$programmeName.".properties";
    open (my $out , $file) or die $!;
    print $out  "#Armadillo Workflow Platform 1.1 (c) Etienne Lord, Mickael Leclercq, Alix Boc,  Abdoulaye Baniré Diallo, Vladimir Makarenkov".
                "\n#$author".
                "\n#$date".
                "\n#Pgrogram info".
                "\nClassName=programs.".$programmeName."".
                "\nEditorClassName=editors.".$programmeName."Editors";
    if (exists $structPgrm{"0_pgrPath"}) {
        my @paths = split (/\]\/\[/,$structPgrm{"0_pgrPath"});
        if (scalar @paths == 3) {
            $paths[2]=~s/\]$//;
            $paths[0]=~s/^\[//;
            print $out  "\nExecutable=".$paths[2]."".
                        "\nExecutableLinux=".$paths[0]."".
                        "\nExecutableMacOSX=".$paths[1]."";
        } elsif (exists $structPgrm{"0_doImage"}) {
            print $out  "\nExecutable=\"C:\\Program Files\\Git\\bin\\bash.exe\" --login -i \"C:\\Program Files\\Docker Toolbox\\start.sh\"".
                        "\nExecutableLinux=/usr/bin/docker".
                        "\nExecutableMacOSX=??docker??";
        } else {
            print $out  "\nExecutable=executable".
                        "\nExecutableLinux=./Executable/Linux/".
                        "\nExecutableMacOSX=Executable/MACOSX/";
        }
    } 
    print $out  "\nHelpSupplementary=" ;
    print $out  $structPgrm{"0_help"} if (exists $structPgrm{"0_help"});
    print $out  "\nPublication= ";
    print $out  $structPgrm{"0_pub"} if (exists $structPgrm{"0_pub"});
    print $out  "\nName= ";
    if (exists $structPgrm{"0"}) {
        my $val = $structPgrm{"0"};
        $val =~ s/_/ / if ($val=~/_/);
        print $out $val;
    }
    print $out  "\nDescription= ";
    print $out  $structPgrm{"0_desc"} if (exists $structPgrm{"0_desc"});
    
    my $ObjectID = "";
    for (my $i = 0; $i < 9; $i++) {$ObjectID = $ObjectID."".(int(rand(10))+1);}
    print $out  "\nObjectID=".$programmeName."_".$ObjectID."".
                "\nObjectType=Program".
                "\nNoThread=false";
    print $out  "\nType=" ;
    print $out  $structPgrm{"0_menu"} if (exists $structPgrm{"0_menu"});
    
    print $out  "\nNormalExitValue=" ;
    print $out  $structPgrm{"0_exitVal"} if (exists $structPgrm{"0_exitVal"});
    
    print $out  "\nVerifyExitValue=" ;
    print $out  "true"  if (exists $structPgrm{"0_exitVal"});
    print $out  "false" if (!exists $structPgrm{"0_exitVal"});
    
    if (exists $structPgrm{"0_web"}) {
        my @w = split (/\]\/\[/,$structPgrm{"0_web"});
        if (scalar @w == 2) {
            print $out  "\nWebServices = ".$w[1]."".
                        "\nWebsite = ".$w[0]."";
        } else {
            print $out  "\nWebServices =".
                        "\nWebsite =";
        }
    }
    # Color options
    my $color = $colorModeOptions[int(rand(scalar @colorModeOptions))];
    print $out  "\ncolorMode    = ".$color."".
                "\ndefaultColor = ".$color."";
    # Other options
    print $out  "\ndebug        = false".
                "\nfilename=C\:\\armadillo2\\data\\properties\\".$programmeName.".properties";
    # Inputs types
    print $out  "\n#INPUTS TYPES";
    if (keys %h_in > 0) {
        for (my $z=0;$z<keys %h_in;$z++){
            if (exists $h_in{$z."_type"}) {
                print $out "\nInput".$h_in{$z."_type"}."=";
                if ($h_in{$z."_connectNum"}=~/[2-4]/) {
                    print $out "Connector".$h_in{$z."_connectNum"};
                } elsif ($h_in{$z."_connectNum"}=~/true/) {
                    print $out $h_in{$z."_connectNum"};
                }
                
            }
        }
    } else {
        print $out  "\nNO IMPUTS ARE PRESENT\n";
    }
    # Inputs types
    print $out  "\n#INPUTS Connector text"; # Came from inputs Concat
    for (my $i = 2 ; $i < 5 ; $i++) {
        my $val = "";
        my $all = "";
        $all = $h_in{"true_connectNames"} if (exists $h_in{"true_connectNames"});
        $val = $h_in{$i."_connectNames"}  if (exists $h_in{$i."_connectNames"});
        if ($val ne "" || ($all ne "" && $i == 2)) {
            print $out  "\nConnector$i=";
            print $out  "$val" if ($val ne "") ;
            print $out  ","    if ($val ne "" && $all ne "") ;
            print $out  "$all" if ($all ne "" && $i == 2) ;
        }
    }
    # Inputs options
    print $out  "\n#INPUTS OPTIONS";
        # One Connector Only For values
    if (exists $h_in{"OneConnectorOnlyFor"} && $h_in{"OneConnectorOnlyFor"} ne "") {
        print $out  "\nOneConnectorOnlyFor= ".$h_in{"OneConnectorOnlyFor"}; # Came from inputs Concat
    }
        # SolelyConnectors
    if (exists $h_in{"SolelyConnectors"} && $h_in{"SolelyConnectors"} ne "") {
        print $out  "\nSolelyConnectors= ".$h_in{"SolelyConnectors"}; # Came from inputs Concat
    }
        # Number of inputs
    print $out  "\nnbInput=" ;
    if (exists $structPgrm{"0_nbInputs"}) {
        print $out  $structPgrm{"0_nbInputs"};
    }
    # Outputs values
    print $out  "\n#OUTPUTS OPTIONS".
                "\nConnector0Output=True".
                "\nOutputResults=Connector0".
                "\nOutputOutputText=Connector0";
    if (keys %h_ou > 0) {
        for (my $z=0;$z<keys %h_ou;$z++){
            if (exists $h_ou{$z."_type"}) {
                print $out "\nOutput".$h_ou{$z."_type"}."=Connector0";
            }
        }
    }
    # Default Values
    print $out  "\n#DEFAULT VALUES".
                "\ndefaultPgrmValues=";
                my @vals;
                if (exists $structPgrm{"0_0"}) {
                    print $out $structPgrm{"0_0"}."<>true<>";
                }
                foreach my $k (keys %b_v) {
                    my $string = $structPgrm{$b_v{$k}};
                    my @v;
                    push (@v, $string)        if ($string!~/<>/);
                    @v = split ("<>",$string) if ($string=~/<>/);
                    if ($v[0]ne"") {
                        push (@vals,"".$b_v{$k}."<>".$v[0]."");
                    }
                }
                for (my $i = 0 ; $i<scalar @vals;$i++) {
                    if ($i==(scalar @vals-1)) {
                        print $out $vals[$i];
                    } else {
                        print $out $vals[$i]."<>";
                    }
                }
                
                ####################################
                # to be added
                #
                # $initiales."_ActivatedByDefault"
                ####################################
                
    return %structPgrm;
}
