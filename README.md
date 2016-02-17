# IH4armadillo2

## Synopsis

This script will help programmers to prepare all program files  needed in NetBeans IDE.

## Code Example

Path to Armadillo directory -d [PATH/TO/ARMADILLO] (needed if -t is not used) \
File -f [PATH/FILENAME] (needed) \
Set Columns File separator -s "|"  \
(default is | the pipe, don't forget the quote if it's necessary)  \
Constructions options -c [all,e,j,f] (default all)  \
	e   for Editor files,  \
	j   for Program file,  \
	f   for Properties file,  \
	all for ejf files,  \
 Outputs as a test in ./test/ -t (default is without -t)  \
 Set Author Name (alphanumeric or "_") with -a (Default : John Doe)  \
  \
 Standard Command line looks like:  \
	perl install_programs.pl -f EMBOSS_sizeseq -t -a John Doe -c ej -s "|"  \

## Motivation

After several programs added by hand in netbeans ide, it tools to much time. This scrip was born. \

## Installation

Need perl.\
Doesn't need specific installation

## Tests

WARNING Not completely Idiot Proof. So, test it in test zone before ;) \
Test zone \
perl install_programs.pl -f ../struturedfiles/EMBOSS_sizeseq -t -a John Doe -c ej -s "|"  \
Production \
perl install_programs.pl -f /PATH/TO/STRUCTURED/FILES/EMBOSS_sizeseq -d ../PATH/TO/armadillo -a John Doe -c ej -s "|"  \


## License

MIT

## How to structure a file

The structured file should looks like that : \
(needed) = (*) \
NB: | is the column separator. \

##### Program informations (*)
P   |Program name|NormalExitValue|[Linux<>Path]/[Mac<>Path]/[Windows<>Path]|Armadillo Menu/Type|number of box's inputs|OutputPath|Publication Reference|Help|Descriptions|[Website]/[WebServices]|Save output Files from outputPath to dest<>dest<>(ect.)
0|P \
1|Program name \
Add programm name (*) \
2|NormalExitValue \
Add programm Normal exit value \
3|[Linux<>Path]/[Mac<>Path]/[Windows<>Path] \
Add path for each os as the patern \
4|Armadillo Menu/Type \
Add the menu for the program \
5|number of box's inputs \
Add the number of inputs for your box \
6|OutputPath \
Path to find output program files \
7|Publication Reference \
Add a program publication reference \
8|Help \
Add a program help \
9|Descriptions \
Add a program description \
10|[WebServices]/[Website] \
Not setted yet \
11|Save output Files from outputPath to dest<>dest<>(ect.) \
Not realy used \

#### Docker informations
D   |docker image name|Command to execute in the container|Shared folder path in docker|docker Name (if not here will be the docker name link)|Remarks|Copy Dockers Files Directories source<>source<>(etc.) to sharedfolder \
0|D \
1|docker image name \
Add The docker image like needed by docker (*) \
2|Command to execute in the container \
Add the command to execute in docker (*) \
3|Shared folder path in docker \
Add the shared folder path (*) \
4|docker Name (if not here will be the docker name link) \
Add a docker if you want \
5|Remarks \
Add other informations \
6|Copy Dockers Files Directories source<>source<>(etc.) to sharedfolder \
Usefull when you want to move data references, or reference genome modified by a docker program \

##### Input Options (*)
0   |1         |2           |3             |4                                           |5                 |6 \
I   |Input type|[true,2,3,4]|Connector Name|OneConnectorOnlyFor || (OR) SolelyConnectors|Command if needeed|Extention \
Choose Input type between all types from ./src/biologic : Alignment, Ancestor, BamFile, Biologic, Blast, BlastDB, BlastHit, DataSet, FastaFile, FastqFile, Genome, GenomeFile, HTML, ImageFile, InfoAlignment, InfoMultipleSequences, InfoSequence, Input, ListSequence, Matrix, Model, MultipleAlignments, MultipleSequences, MultipleTrees, Outgroup, Output, OutputText, Phylip, Phylip_Distance, Phylip_Seqboot, PositionToSequence, ProteinAlignment, Results, RootedTree, SamFile, Sample, Sequence, SOLIDFile, Text, TextFile, Tree, Unknown, UnrootedTree, Workflows \
(update in 2015/12/01) \

##### Output Options
0   |1           |2             |3                 |4 \
O   |Output type |Connector Name|Command if needeed|Extention  (see if several extention options add a list) \

##### Menu Options (*)
0   |1           |2 \
M   |Menu option |Tab/Panel linked (enabled or disabled if selected)| \

##### Title Name (*)
0   |1 \
T   |Name \

##### Subtitle Name
0   |1 \
S   |Name \

##### Command options (*)
C   |Command name|shortName  |( r )button or box |*list*|value for *list*|Help |Label|*Opposite To*|Parents of|selected by default (true|(falseORempty))
0|C \
1|Command name \
Add the command name generaly starts with -- or - \
2|shortName \
Add shortName for the command name (could be empty) \
3|( r )button or box \
Choose between : box (prefer this one) or rbutton (radiobutton) or button \
4|*list* \
Choose between : int (integer), flo (float), lon (long), sho (short), dou (double), te?xt, dirFile, dirFiles, dirRep, boo (boolean), list, listDir (not yet implemented) \
5|values for 4  \
if 4 is (int|integer|float|long|short|double) a range set as this default<>min<>max<>jump. \
Int     ex: |int|1<>-inf<>50<>10| \
Boolean ex: |boo|1 \
double  ex: |dou|1.0<>-inf<>50.0<>10.0 \
*te?xt* it's a string \
*dir*   it's a canonical or relative string to the directory. It's used for dirFile, dirFiles, dirRep \
dirFile  (choose a file in a list) /path/to/the/file \
dirFiles (choose files in a list) /path/to/files \
dirRep   (select a directory) /path/to/directory \
*list*  it's a combobox with options, just one selection option1<>option2<>option3<>etc. \
*listDir* it's a combobox with options, just one selection /path/to/directory <>[.filesExtention1<>.filesExtention2] (not yet implemented) \
6|Help \
Add : Help information \
7|Label \
Add a label on the right \
8|*Opposite To*
*Opposite To* can have several command like opposite to command1<>command2<>command3 remove the - or -- in front of the command \
It will remove and deactivated the command(s) \
9|Parents of \
It will be accessible only if the parent is activated. If it's not, it will be desactivated and remove from the object properties \
10| selected by default (true|(falseORempty))\
It will add this value in the default pogram options \

Ex : \
C|--fristCommand|-f|box|bool|0|My First command|Label|*Opposite To*|Parents of|selected by default (true|(falseORempty)) \
