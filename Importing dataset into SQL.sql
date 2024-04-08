create table Athlete_Events
(
ID integer,
Name varchar,
Sex	varchar,
Age integer,
Height varchar,
Weight varchar,	
Team varchar,		
NOC	varchar,
Games varchar,		
Year int,		
Season varchar,	
City varchar,
Sport varchar,	
Event varchar,
Medal varchar
);

Create table Noc_regions
(	
	NOC	varchar,
	region varchar,	
	notes varchar
);


copy athlete_events FROM 'C:\Users\Benedicta Martins\OneDrive\Documents\LANRE\BUSINESS TRAINING\My Portfolio\archive (4)\athlete_events.csv' DELIMITER ',' CSV HEADER;

copy noc_regions FROM 'C:\Users\Benedicta Martins\OneDrive\Documents\LANRE\BUSINESS TRAINING\My Portfolio\archive (4)\noc_regions.csv' DELIMITER ',' CSV HEADER;
