#Utility for CycleForkAnimated.  Pierre ROUZEAU   //github/Prouzeau/CycleForkAnimated
#This routine creates all individual images as png files from OpenSCAD to be later
#assembled to create '.gif' file with an online gif generator.
#Each set of image is created in a dedicated directory.

mkdir Images/Fk_Trail_En
mkdir Images/Fk_Trail_Fr
mkdir Images/Fk_Trail_Es
mkdir Images/Fk_Trail_It
mkdir Images/Fk_Ang_En
mkdir Images/Fk_Ang_Fr
mkdir Images/Fk_Ang_Es
mkdir Images/Fk_Ang_It

openscad -o Images/Fk_Trail_En/.png -D 'lang=0' -D 'demotype=0' --animate 60 --camera 70,0,390,90,0,0,2430 --imgsize 1024,1024 --colorscheme Tomorrow --projection o Trail_show.scad
openscad -o Images/Fk_Trail_Fr/.png -D 'lang=1' -D 'demotype=0' --animate 60 --camera 70,0,390,90,0,0,2430 --imgsize 1024,1024 --colorscheme Tomorrow --projection o Trail_show.scad
openscad -o Images/Fk_Trail_Es/.png -D 'lang=2' -D 'demotype=0' --animate 60 --camera 70,0,390,90,0,0,2430 --imgsize 1024,1024 --colorscheme Tomorrow --projection o Trail_show.scad
openscad -o Images/Fk_Trail_It/.png -D 'lang=3' -D 'demotype=0' --animate 60 --camera 70,0,390,90,0,0,2430 --imgsize 1024,1024 --colorscheme Tomorrow --projection o Trail_show.scad
openscad -o Images/Fk_Ang_En/.png -D 'lang=0' -D 'demotype=1' --animate 50 --camera 70,0,390,90,0,0,2430 --imgsize 1024,1024 --colorscheme Tomorrow --projection o Trail_show.scad
openscad -o Images/Fk_Ang_Fr/.png -D 'lang=1' -D 'demotype=1' --animate 50 --camera 70,0,390,90,0,0,2430 --imgsize 1024,1024 --colorscheme Tomorrow --projection o Trail_show.scad
openscad -o Images/Fk_Ang_Es/.png -D 'lang=2' -D 'demotype=1' --animate 50 --camera 70,0,390,90,0,0,2430 --imgsize 1024,1024 --colorscheme Tomorrow --projection o Trail_show.scad
openscad -o Images/Fk_Ang_It/.png -D 'lang=3' -D 'demotype=1' --animate 50 --camera 70,0,390,90,0,0,2430 --imgsize 1024,1024 --colorscheme Tomorrow --projection o Trail_show.scad
