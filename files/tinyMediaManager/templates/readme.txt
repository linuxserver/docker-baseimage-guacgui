tinyMediaManager uses the Java Minimal Template Engine (JMTE) to construct the exported page.
JMTE Reference: http://jmte.googlecode.com/svn/trunk/doc/index.html

If you want to edit or create a new template make a copy of the template folder you would like to build upon. Do not edit the default templates; the default templates will be overwritten each time you start tMM and you will lose your changes.

If you create a nice template contact tMM and we will check it out for distribution with the program.
Contact: http://www.tinymediamanager.org/index.php/contact-us/

Templates rely on three files to export successfully. All other files you create will also be exported, retaining their directory structure, when the page is built by tMM; this allows for the inclusion of style sheets, images and scripts.
    | template.conf     -> This configuration file tells tMM where to find the other two required files.
    | list.jmte         -> This may be renamed as long as you also reflect the change in template.conf.
    | detail.jmte       -> This may be renamed as long as you also reflect the change in template.conf. detail.jmte is required only if you want tMM to build individual <movie>.xxx files for inclusion into index.html either through an .ajax() call or iframe.
    | episode.jmte      -> This may be renamed as long as you also reflect the change in template.conf. episode.jmte is required only if you want tMM to build individual <episode>.xxx files for inclusion into index.html/detail.html either through an .ajax() call or iframe.

Each template must be in its own directory and include a template.conf file. The contents of template.conf must include:
    | name=<name of template>       -> The name that will display to the user when exporting through the UI._ ||
    | type={movie, tv_show}         -> Currently only movie/tv show templates are supported._ ||
    | list=<path to list.jmte>      -> (default: list.jmte) This is the template which will be used to build index.html or movielist.xml/csv.
    | detail=<path to detail.jmte>  -> (default: detail.jmte) Remove this line if you do not require individual <movie>.html pages._ ||
    | episode<path to episode.jmte> -> (default: episode.jmte) Only for TV show exporting! This is the template for episode data export._ ||
    | extension={html|xml|csv}      -> (default: html) This is the format tMM will export.
    | description=<text>            -> Write a short description that will print in the tMM exporter UI. Newlines (\n) should be used to insert paragraph breaks.
    | url=<url to homepage>         -> The URL to the page that hosts this template or to the author's homepage. Remove this line if you have neither.

Using the above information write your template.conf file. It may resemble this example:
    name=Jelly is Delicious
    type=movie
    list=list.jmte
    detail=detail.jmte
    extension=html
    description=Created by William Shatner\n\nThis template has jelly in its gears.
    url=https://github.com/TheShatner/jelly_template

list.jmte and detail.jmte are HTML pages. The JMTE syntax is used to insert variables like movie name, cast, genre and file information. All of the variables are stored in the list array movies. To access each movies' variables you must itterate over the entire list array.

In the following code the list array movies is iterated over. For each movie entry we assign the variable movie to hold its details and append the name of a variable to print individual attributes.
    <div class="movie details">
    ${foreach movies movie}
        <span class="bold">Title</span>: ${movie.name}
        <span class="bold">Year</span>: ${movie.year}
    ${end}
    </div>

As you can see, the name variable in ${movie.name} tells JMTE to print the name of the movie. The variable name is a string, but some movie variables are also list arrays. Print the list array genres with the following code:
    ${foreach movies movie}
        ${movie.name}
        <span class="genreList">
        ${foreach movie.genres genre , }       // " , " comma is used here as genre seperator
            ${genre}
        ${end}
        </span>
    ${end}

In this example we iterated over the movies list array like in the previous example. Then, from within the first foreach loop, we iterated over the genres list array and printed them. We told JMTE to separate each entry with a comma by putting a comma at the end of the foreach instance.

Following variables can be used:

***********************************************************************************************************
* MOVIES
***********************************************************************************************************
Movie:
Date                  dateAdded
List<MediaFile>       mediaFiles
List<MediaGenres>     genres
List<MediaTrailer>    trailer
List<MovieCast>       actors        
List<String>          extraThumbs
List<String>          tags
MovieSet              movieSet;
String                dataSource
String                director
String                fanart
String                fanartUrl
String                imdbId
String                title
String                titleSortable
String                nfoFilename
String                originalTitle
String                plot
String                path
String                poster
String                posterUrl
String                productionCompany
String                sortTitle
String                spokenLanguages
String                tagline
String                writer
String                year
boolean               duplicate
boolean               isDisc
boolean               scraped
boolean               watched
float                 rating
int                   runtime
int                   tmdbId
int                   votes

MovieCast:
String                character
String                name
String                thumbUrl

MediaFile:
String                path
String                filename
String                filesize
String                videoCodec      
String                audioCodec      
String                audioChannels   
String                containerFormat  
String                videoFormat      
String                exactVideoFormat 
int                   videoWidth       
int                   videoHeight      
int                   overallBitRate   
int                   duration         

MediaTrailer:
String                name
String                url
String                provider

***********************************************************************************************************
* TV SHOWS
***********************************************************************************************************
TV show:
Date                  dateAdded
List<TvShowEpisode>   episodes
List<TvShowSeason>    seasons
List<MediaFile>       mediaFiles
List<MediaGenres>     genres
List<TvShowActor>     actors        
List<String>          tags
String                dataSource
String                fanart
String                fanartUrl
String                tvdbId
String                title
String                titleSortable
String                nfoFilename
String                originalTitle
String                plot
String                path
String                poster
String                posterUrl
String                banner
String                bannerUrl
String                studio
String                sortTitle
Date                  firstAired
String                year
boolean               duplicate
boolean               scraped
boolean               watched
float                 rating
int                   votes

TvShowSeason:
int                   season
List<TvShowEpisode>   episodes

TvShowEpisode:
List<TvShowActor>     actors
List<MediaFile>       mediaFiles
List<String>          tags
int                   season
int                   episode
Date                  firstAired
String                director
String                writer 
boolean               disc   
boolean               watched 
float                 rating
int                   votes    
     
TvShowActor:
String                character
String                name
String                thumbUrl

MediaFile:
String                path
String                filename
String                filesize
String                videoCodec      
String                audioCodec      
String                audioChannels   
String                containerFormat  
String                videoFormat      
String                exactVideoFormat 
int                   videoWidth       
int                   videoHeight      
int                   overallBitRate   
int                   duration         