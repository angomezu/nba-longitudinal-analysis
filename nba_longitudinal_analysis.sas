OPTIONS LOCALE=en_US DFLANG=LOCALE;

/* Import the dataset */
PROC IMPORT DATAFILE="/home/u64031030/Advanced Data Analysis/all_seasons.csv"
    OUT=nba_data_raw
    DBMS=CSV
    REPLACE;
    GETNAMES=YES;
RUN;

/* Cleaning the data and prepare numeric season */
DATA nba_clean;
    SET nba_data_raw;
    season_numeric = INPUT(SUBSTR(season, 1, 4), 4.);
    IF nmiss(player_id, age, pts, season_numeric) = 0;
RUN;

/* Step 3: Sort by player and season */
PROC SORT DATA=nba_clean;
    BY player_id season_numeric;
RUN;

/* Step 4: Fit a GEE model (population-averaged) */
PROC GENMOD DATA=nba_clean;
    CLASS player_id;
    MODEL pts = age season_numeric / DIST=NORMAL LINK=IDENTITY;
    REPEATED SUBJECT=player_id / TYPE=EXCH;
RUN;

/* Createing Visualizations */
ODS GRAPHICS ON;
ODS LISTING GPATH="/home/u64031030/Advanced Data Analysis/plots";  /* Change if needed */
ODS PDF FILE="/home/u64031030/Advanced Data Analysis/plots/nba_plots.pdf"; /* Optional if you want all visuals in one PDF */

/* Plot 1: Mean points per game by age */
PROC SGPLOT DATA=nba_clean;
    TITLE "Average Points per Game by Age";
    VLINE age / RESPONSE=pts STAT=MEAN LINEATTRS=(THICKNESS=2);
    YAXIS LABEL="Mean Points per Game";
    XAXIS LABEL="Age";
RUN;

/* Plot 2: Mean points per game by season */
PROC SGPLOT DATA=nba_clean;
    TITLE "Average Points per Game by Season";
    VLINE season_numeric / RESPONSE=pts STAT=MEAN LINEATTRS=(THICKNESS=2);
    YAXIS LABEL="Mean Points per Game";
    XAXIS LABEL="Season";
RUN;

ODS PDF CLOSE;
ODS GRAPHICS OFF;
