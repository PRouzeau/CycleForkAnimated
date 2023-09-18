#Utility for CycleForkAnimated.  Pierre ROUZEAU   //github/Prouzeau/CycleForkAnimated
#This routine cannot control timing and result is of poor quality, so this is only 
# used for preliminary tests
#For final production of gif images, I use the site ezgif.com, which allow me to control
# the timing. Delay is set at 20/100 sec. between images, but I modify the 1rst and 
# middle image timing to 130/100 for better understanding, say image 1 and 26 for the
# constant angle animation et image 1 and 31 for constant trail animation.
#I then optimize the image with lossy compression set to 100.
#I assume the the site retain some rights on the images, but as they are open source
# anyway, I don't care much. They set some information in the metadata, which I 
# replace with my own info with XnView. 

ffmpeg -framerate 5  -pattern_type glob -i 'Images/Fk_Trail_En/*.png'  Images/Fork_constant_Trail_En.gif 
ffmpeg -framerate 5  -pattern_type glob -i 'Images/Fk_Trail_Fr/*.png'  Images/Fork_constant_Trail_Fr.gif 
ffmpeg -framerate 5  -pattern_type glob -i 'Images/Fk_Trail_Es/*.png'  Images/Fork_constant_Trail_Es.gif 
ffmpeg -framerate 5  -pattern_type glob -i 'Images/Fk_Trail_It/*.png'  Images/Fork_constant_Trail_It.gif 
ffmpeg -framerate 5  -pattern_type glob -i 'Images/Fk_Ang_En/*.png'  Images/Fork_constant_Ang_En.gif 
ffmpeg -framerate 5  -pattern_type glob -i 'Images/Fk_Ang_Fr/*.png'  Images/Fork_constant_Ang_Fr.gif 
ffmpeg -framerate 5  -pattern_type glob -i 'Images/Fk_Ang_Es/*.png'  Images/Fork_constant_Ang_Es.gif 
ffmpeg -framerate 5  -pattern_type glob -i 'Images/Fk_Ang_It/*.png'  Images/Fork_constant_Ang_It.gif 

#obsolete stuff
#convert -delay 20 -loop 0 Images/Fk_Trail_En/* Images/Fork_constant_Trail_En.gif
#ffmpeg -i 'Images/Fk_Trail_Fr/00001.png' -filter_complex "[0:v] palettegen" Images/palette.png
#ffmpeg -framerate 25 -pattern_type glob -i 'Images/Fk_Trail_Fr/*.png' -i Images/palette.png -filter_complex "[0:v][1:v] paletteuse" Images/Fork_constant_Trail_Fr.gif

