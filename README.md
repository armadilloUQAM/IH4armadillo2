# IH4armadillo2

## Synopsis

This script will help programmers to prepare all program files  needed in NetBeans IDE.

## Code Example

P|EMBOSS chips||[/usr/bin/docker]/[docker]/["C:\Program Files\Git\bin\bash.exe" --login -i "C:\Program Files\Docker Toolbox\start.sh"]|./results/EMBOSS/chips/|Codon usage statistics Nucleotide sequence(s) filename and optional format, or reference (input USA)|http://emboss.sourceforge.net/apps/cvs/emboss/apps/chips.html|NGS: EMBOSS<br/>
D|jego/emboss|chips --auto|/data<br/>
I|FastaFile|2|Sequence||--seqall|.fasta<br/>
O|ChipsFile|ChipsFile|-outfile|.chips<br/>
M|default<br/>
M|Advanced Options|Standard qualifiers<br/>
T|Standard qualifiers<br/>
C|-nosum||box|||Not Sum codons over all sequences||sum||<br/>
C|-sum||box|||Sum codons over all sequences||nosum||<br/>


## Helper

Path to Armadillo directory -d [PATH/TO/ARMADILLO] (needed if -t is not used)<br/>
File -f [PATH/FILENAME] (needed)<br/>
Set Columns File separator -s "|" <br/>
(default is | the pipe, don't forget the quote if it's necessary) 
Constructions options -c [all,e,j,f] (default all) <br/>
	e   for Editor files, <br/>
	j   for Program file, <br/>
	f   for Properties file, <br/>
	all for ejf files, <br/>
 Outputs as a test in ./test/ -t (default is without -t) <br/>
 Set Author Name (alphanumeric or "_") with -a (Default : John Doe) <br/>
 <br/>
 Standard Command line looks like: <br/>
	perl install_programs.pl -f EMBOSS_sizeseq -t -a John Doe -c ej -s "|" <br/>

## Motivation

After several programs added by hand in netbeans ide, it tools to much time. This scrip was born.<br/>

## Installation

Need perl.\
Doesn't need specific installation

## Tests

WARNING Not completely Idiot Proof. So, test it in test zone before ;)<br/>
Test zone<br/>
perl install_programs.pl -f ../struturedfiles/EMBOSS_sizeseq -t -a John Doe -c ej -s "|" <br/>
Production<br/>
perl install_programs.pl -f /PATH/TO/STRUCTURED/FILES/EMBOSS_sizeseq -d ../PATH/TO/armadillo -a John Doe -c ej -s "|" <br/>


## License

MIT

## How to structure a file

The structured file should looks like that :<br/>
(needed) = (*)<br/>
NB: | is the column separator.<br/>

##### Program informations (*)
P   |Program name|NormalExitValue|[Linux<>Path]/[Mac<>Path]/[Windows<>Path]|Armadillo Menu/Type|number of box's inputs|OutputPath|Publication Reference|Help|Descriptions|[Website]/[WebServices]|Save output Files from outputPath to dest<>dest<>(ect.)
0|P<br/>
1|Program name<br/>
Add programm name (*)<br/>
2|NormalExitValue<br/>
Add programm Normal exit value<br/>
3|[Linux<>Path]/[Mac<>Path]/[Windows<>Path]<br/>
Add path for each os as the patern<br/>
4|Armadillo Menu/Type<br/>
Add the menu for the program<br/>
5|number of box's inputs<br/>
Add the number of inputs for your box<br/>
6|OutputPath<br/>
Path to find output program files<br/>
7|Publication Reference<br/>
Add a program publication reference<br/>
8|Help<br/>
Add a program help<br/>
9|Descriptions<br/>
Add a program description<br/>
10|[WebServices]/[Website]<br/>
Not setted yet<br/>
11|Save output Files from outputPath to dest<>dest<>(ect.)<br/>
Not realy used<br/>

#### Docker informations
D   |docker image name|Command to execute in the container|Shared folder path in docker|docker Name (if not here will be the docker name link)|Remarks|Copy Dockers Files Directories source<>source<>(etc.) to sharedfolder<br/>
0|D<br/>
1|docker image name<br/>
Add The docker image like needed by docker (*)<br/>
2|Command to execute in the container<br/>
Add the command to execute in docker (*)<br/>
3|Shared folder path in docker<br/>
Add the shared folder path (*)<br/>
4|docker Name (if not here will be the docker name link)<br/>
Add a docker if you want<br/>
5|Remarks<br/>
Add other informations<br/>
6|Copy Dockers Files Directories source<>source<>(etc.) to sharedfolder<br/>
Usefull when you want to move data references, or reference genome modified by a docker program<br/>

##### Input Options (*)
0   |1         |2           |3             |4                                           |5                 |6<br/>
I   |Input type|[true,2,3,4]|Connector Name|OneConnectorOnlyFor || (OR) SolelyConnectors|Command if needeed|Extention<br/>
Choose Input type between all types from ./src/biologic : Alignment, Ancestor, BamFile, Biologic, Blast, BlastDB, BlastHit, DataSet, FastaFile, FastqFile, Genome, GenomeFile, HTML, ImageFile, InfoAlignment, InfoMultipleSequences, InfoSequence, Input, ListSequence, Matrix, Model, MultipleAlignments, MultipleSequences, MultipleTrees, Outgroup, Output, OutputText, Phylip, Phylip_Distance, Phylip_Seqboot, PositionToSequence, ProteinAlignment, Results, RootedTree, SamFile, Sample, Sequence, SOLIDFile, Text, TextFile, Tree, Unknown, UnrootedTree, Workflows<br/>
(update in 2015/12/01)<br/>

##### Output Options
0   |1           |2             |3                 |4<br/>
O   |Output type |Connector Name|Command if needeed|Extention  (see if several extention options add a list)<br/>

##### Menu Options (*)
0   |1           |2<br/>
M   |Menu option |Tab/Panel linked (enabled or disabled if selected)|<br/>

##### Title Name (*)
0   |1<br/>
T   |Name<br/>

##### Subtitle Name
0   |1<br/>
S   |Name<br/>

##### Command options (*)
C   |Command name|shortName  |( r )button or box |*list*|value for *list*|Help |Label|*Opposite To*|Parents of|selected by default (true|(falseORempty))
0|C<br/>
1|Command name<br/>
Add the command name generaly starts with -- or -<br/>
2|shortName<br/>
Add shortName for the command name (could be empty)<br/>
3|( r )button or box<br/>
Choose between : box (prefer this one) or rbutton (radiobutton) or button<br/>
4|*list*<br/>
Choose between : int (integer), flo (float), lon (long), sho (short), dou (double), te?xt, dirFile, dirFiles, dirRep, boo (boolean), list, listDir (not yet implemented)<br/>
5|values for 4 <br/>
if 4 is (int|integer|float|long|short|double) a range set as this default<>min<>max<>jump.<br/>
Int     ex: |int|1<>-inf<>50<>10|<br/>
Boolean ex: |boo|1<br/>
double  ex: |dou|1.0<>-inf<>50.0<>10.0<br/>
*te?xt* it's a string<br/>
*dir*   it's a canonical or relative string to the directory. It's used for dirFile, dirFiles, dirRep<br/>
dirFile  (choose a file in a list) /path/to/the/file<br/>
dirFiles (choose files in a list) /path/to/files<br/>
dirRep   (select a directory) /path/to/directory<br/>
*list*  it's a combobox with options, just one selection option1<>option2<>option3<>etc.<br/>
*listDir* it's a combobox with options, just one selection /path/to/directory <>[.filesExtention1<>.filesExtention2] (not yet implemented)<br/>
6|Help<br/>
Add : Help information<br/>
7|Label<br/>
Add a label on the right<br/>
8|*Opposite To*
*Opposite To* can have several command like opposite to command1<>command2<>command3 remove the - or -- in front of the command<br/>
It will remove and deactivated the command(s)<br/>
9|Parents of<br/>
It will be accessible only if the parent is activated. If it's not, it will be desactivated and remove from the object properties<br/>
10| selected by default (true|(falseORempty))\
It will add this value in the default pogram options<br/>

Ex :<br/>
C|--fristCommand|-f|box|bool|0|My First command|Label|*Opposite To*|Parents of|selected by default (true|(falseORempty)) <br/>
