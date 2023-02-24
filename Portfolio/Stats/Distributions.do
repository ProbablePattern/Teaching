

clear all
collect clear
version 17

capture cd "$GoogleDriveWork"
capture cd "$GoogleDriveLaptop"
capture cd "$Presentations"
capture cd ".\Stata\Twitter\distributions\graphs"


// set the graph scheme 
set scheme s1color
global Width16x9  = 1920*2
global Height16x9 = 1080*2
global Width4x3   = 1440*2
global Height4x3  = 1080*2
global WidthTall  = 1440*2
global HeightTall = 1080*2*3

// Delete all .png files from the "graphs" folder
shell erase *.png /Q


local GraphScale = 1.0

forvalues n = 1/1000 {
    
    
    // Normal and Binomial
    // ========================================================================================================    
    local p     = 0.5
    local mean  = `n'*`p'
    local sd    = sqrt(`n'*`p'*(1-`p'))
    local lower = `mean' - 4*`sd'
    local upper = `mean' + 4*`sd'

    #delimit ;
    twoway (function normalden(x,`mean',`sd'), range(`lower' `upper')  lcolor(green) lwidth(thick))    
           (function binomialp(`n',x,`p'),     range(`lower' `upper')  lcolor(orange) lwidth(thick))  
           , xtitle("x", size(medium) margin(medium))               xlabel(none)                           
             ytitle("f(x|n, {&pi})", size(medium) margin(medium))   ylabel(none)                      
             legend(order(1 "Normal(x, n{&pi}, sqrt(n{&pi}(1-{&pi}))" 2 "Binomial(x,n,{&pi}=0.5)") rows(1) position(12))
             name(binom, replace) scale(`GraphScale') nodraw
    ;         
    #delimit cr
    
    // Normal and Poisson
    // ========================================================================================================  
    local sd   = sqrt(`n'*`p') 
    local lower = `mean' - 4*`sd'
    local upper = `mean' + 4*`sd'
    #delimit ;
    twoway (function normalden(x,`mean',`sd'), range(`lower' `upper')  lcolor(green) lwidth(thick))   
           (function poissonp(`mean',x),       range(`lower' `upper')  lcolor(orange) lwidth(thick))
           , xtitle("x", size(medium) margin(medium))                  xlabel(none)                    
             ytitle("f(x|n,{&lambda})", size(medium) margin(medium))   ylabel(none)                        
             legend(order(1 "Normal(x, {&lambda}, sqrt({&lambda}))" 2 "Poisson(x, {&lambda}=n/2)") rows(1) position(12))
             name(poisson, replace) scale(`GraphScale') nodraw
    ;
    #delimit cr
 
    // Normal and Student's t
    // ========================================================================================================    
    #delimit ;
    twoway (function normalden(x,0,1),  range(-4 4)  lcolor(green) lwidth(thick))   
           (function tden(`n',x),       range(-4 4)  lcolor(orange) lwidth(thick))
           , xtitle("x", size(medium) margin(medium))         xlabel(none)                    
             ytitle("f(x|df)", size(medium) margin(medium))   ylabel(none)                        
             legend(order(1 "Normal(x, 0, 1)" 2 "t Distribution(x, df=n)") rows(1) position(12))
             name(tdist, replace) scale(`GraphScale') nodraw
    ;
    #delimit cr    
 
 
    // Combine graphs and save them
    // =========================================================================
    graph combine binom poisson tdist, cols(1) xsize(4) ysize(9)  ///
                  title(Distributions for n = `n')
                  
    if inrange(`n', 1, 50) {              
        local GraphCounterString = string(`n', "%04.0f")      
        graph export "N50_`GraphCounterString'.png", as(png)   ///
                  width($WidthTall) height($HeightTall) replace
    }
    else if inrange(`n', 51, 100) {
        local GraphCounterString = string(`n'-50, "%04.0f")      
        graph export "N100_`GraphCounterString'.png", as(png)   ///
                  width($WidthTall) height($HeightTall) replace   
    }
    else if inrange(`n', 101, 1000) {
        local GraphCounterString = string(`n'-100, "%04.0f")      
        graph export "N1000_`GraphCounterString'.png", as(png)   ///
                  width($WidthTall) height($HeightTall) replace   
    }   
}           
       
       
// Delete the old video files 
// ==========================     
capture erase Dist50.mp4
capture erase Dist100.mp4
capture erase Dist1000.mp4
capture erase Distributions.mp4


// Use FFMpeg to combine the .png files into .mp4 files
// ====================================================
// Frames 1-50 are rendered at 2 frames per second
shell "C:\Program Files\ffmpeg\bin\ffmpeg.exe" -framerate 1/.5 -i N50_%04d.png	-c:v libx264 -r 30 -pix_fmt yuv420p Dist50.mp4
// Frames 51-100 are rendered at 10 frames per second
shell "C:\Program Files\ffmpeg\bin\ffmpeg.exe" -framerate 1/0.1 -i N100_%04d.png	-c:v libx264 -r 30 -pix_fmt yuv420p Dist100.mp4
// Frames 101-1000 are rendered at 100 frames per second
shell "C:\Program Files\ffmpeg\bin\ffmpeg.exe" -framerate 1/0.01 -i N1000_%04d.png	-c:v libx264 -r 30 -pix_fmt yuv420p Dist1000.mp4
     
       

// Use FFMpeg to combine the three .mp4 file into a single .mp4 file
// =================================================================
// https://ffmpeg.org/ffmpeg-filters.html#concat
// -i Dist50.mp4 -i Dist100.mp4 -i Dist1000.mp4     <- List of files to combine
// -filter_complex concat=n=2:v=1:a=0               <- 'n' is the number of input files
//                                                     'v' is the number of output video files
//                                                     'a' is the number of output audio files 
// -map 0:v -map 1:v -map 2:v                       <- 0:v get all of the video from the first input file
//                                                     1:v get all of the video from the second input file
//                                                     2:v get all of the video from the third input file
// output.mp4                                       <- name of the output file
shell "C:\Program Files\ffmpeg\bin\ffmpeg.exe" -i Dist50.mp4 -i Dist100.mp4 -i Dist1000.mp4 -filter_complex concat=n=3:v=1:a=0 -map 0:v -map 1:v -map 2:v Distributions.mp4   







  