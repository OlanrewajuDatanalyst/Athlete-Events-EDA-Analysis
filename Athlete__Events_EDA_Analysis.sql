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




-- Total olympics games that have been held
select 
	count(distinct games) 
from athlete_events



-- List of all Olympics games held so far.
select 
	count(distinct games) as Total_no_of_games 
from athlete_events



-- Total no of nations who participated in each olympics game
select 
	games, 
	count(distinct(n.region)) as Total_nations 
from athlete_events a
join noc_regions n
		on a.noc = n.noc
group by 1
order by 2 desc



-- Year with the highest and lowest no of countries participating in olympics
with all_countries as
              (select games, region
              from athlete_events a
              join noc_regions n on n.noc = a.noc
              group by games, region),
          tot_countries as
              (select games, count(1) as total_countries
              from all_countries
              group by games)
      select distinct
      concat(first_value(games) over(order by total_countries)
      , ' - '
      , first_value(total_countries) over(order by total_countries)) as Lowest_Countries,
      concat(first_value(games) over(order by total_countries desc)
      , ' - '
      , first_value(total_countries) over(order by total_countries desc)) as Highest_Countries
      from tot_countries
      order by 1;




-- Nation that has participated in all of the olympic games
with tot_games as (
					select 
						count(distinct games) as total_games
              		from athlete_events),
     countries as (
		 			select 
		 				games, 
		 				region as country
              		from athlete_events a
              		join noc_regions n 
			  			on n.noc = a.noc
              		group by 1, 2),
     countries_participated as (
		 			select 
		 				country, 
		 				count(1) as total_participated_games
              		from countries
              		group by 1)
select c.*
from countries_participated c
      join tot_games t 
	  		on t.total_games = c.total_participated_games
      order by 1;




-- The sport which was played in all summer olympics.
with t1 as (
	 	select 
			 count(distinct games) as total_games
        from athlete_events
	 	where season = 'Summer'),
      t2 as (
		 select 
		 	distinct games, 
		  	sport
         from athlete_events 
		 where season = 'Summer'),
      t3 as (
		  select 
			 sport, 
		  	 count(1) as no_of_games
          	from t2
          	group by 1)
select *
from t3
    join t1 
		on t1.total_games = t3.no_of_games;


		
-- Sports played only once in the olympics
with t1 as
          	(select 
			 	distinct games, 
			 	sport
          	from athlete_events),
     t2 as
          	(select 
				sport, 
			 	count(1) as no_of_games
          	from t1
          	group by sport)
select t2.*, t1.games
from t2
join t1 
	on t1.sport = t2.sport
where t2.no_of_games = 1
order by t1.sport;



-- Total no of sports played in each olympic games.
select 
	games,
	 count(distinct(sport)) as Total_sports
from athlete_events
group by 1

-- Oldest athletes to win a gold medal.
select 
	*
from athlete_events
where medal = 'Gold' and age <> 'NA'
order by age desc
limit 2



-- Ratio of male and female athletes participated in all olympic games.
with cte as (
Select 
	count(male) as male_count,
	count(Female) as female_count
from (
	select 
		case 
			when sex = 'M' then 'M'
		end Male,
		case 
			when sex = 'F' then 'F'
		end Female
	from athlete_events
))
select 
	concat ('1 :', round(male_count::decimal / female_count, 2)) as ratio
from cte



-- Top 5 athletes who have won the most gold medals.
with cte as (
			select 
				*,
				dense_rank() over(order by Gold_medal_num desc) as rnk
			from (
				select 
					name,
					region,
					count (medal) as Gold_medal_num	
				from athlete_events a
				join noc_regions n
					on a.noc = n.noc
				where medal = 'Gold'
				group by 1, 2
	              )
			)
select name,
		region,
		Gold_medal_num
from cte 
where rnk <= 5




-- Top 5 athletes who have won the most medals (gold/silver/bronze).
with cte as (
			select 
				*,
				dense_rank() over(order by  total_medals desc) as rnk
			from (
				select 
					name,
					region,
					count (medal) as total_medals	
				from athlete_events a
				join noc_regions n
					on a.noc = n.noc
				where medal in ('Gold', 'Silver', 'Bronze')
				group by 1, 2
				order by 3
	              )
			)
select name,
		region,
		 total_medals
from cte 
where rnk <= 5




-- Top 5 most successful countries in olympics. Success is defined by no of medals won.
with cte as (
			select 
				*,
				dense_rank() over(order by  total_medals desc) as rnk
			from (
				select 
					region,
					count (medal) as total_medals	
				from athlete_events a
				join noc_regions n
					on a.noc = n.noc
				where medal in ('Gold', 'Silver', 'Bronze')
				group by 1
				order by 2
	              )
			)
select
	region,
	total_medals
from cte 
where rnk <= 5



-- Total gold, silver and bronze medals won by each country.
with Gold as (
			select 
				region,
				count(medal) as Gold_Medals
			from athlete_events a
			join noc_regions n
				on a.noc = n.noc
			where medal = 'Gold'
			group by 1
				),
	Silver as (
			select 
				region,
				count(medal) as Silver_Medals
			from athlete_events a
			join noc_regions n
				on a.noc = n.noc
			where medal = 'Silver'
			group by 1
			), 
	Bronze as (
			select 
				region,
				count(medal) as Bronze_Medals
			from athlete_events a
			join noc_regions n
				on a.noc = n.noc
			where medal = 'Bronze'
			group by 1
			) 
select 
	g.region, 
	Gold_Medals, 
	Silver_Medals, 
	Bronze_Medals 
from Gold g
left join Silver s
			on g.region = s.region
left join Bronze b
			on s.region = b.region
order by 2 desc

--OR
select 
	country,
	coalesce(gold, 0) as gold,
	coalesce(silver, 0) as silver,
	coalesce(bronze, 0) as bronze
from crosstab('select
					n.region as country,
					medal, 
					count(1) as total_medals
				from athlete_events a
				join noc_regions n
					 on a.noc = n.noc
				where medal <> ''NA''
				group by 1, 2
				order by 1, 2',
	            'values (''Bronze''), (''Gold''), (''Silver'')')
                -- Pass our real query as a string 
		as result (country varchar, bronze bigint, gold bigint, silver bigint)
order by 2 desc, 3 desc, 4 desc


-- Total gold, silver and broze medals won by each country corresponding to each olympic games.
with Gold as (
			select 
				games,
				region,
				count(medal) as Gold_Medals
			from athlete_events a
			join noc_regions n
				on a.noc = n.noc
			where medal = 'Gold'
			group by 1, 2
				),
	Silver as (
			select 
				region,
				count(medal) as Silver_Medals
			from athlete_events a
			join noc_regions n
				on a.noc = n.noc
			where medal = 'Silver'
			group by 1
			), 
	Bronze as (
			select 
				region,
				count(medal) as Bronze_Medals
			from athlete_events a
			join noc_regions n
				on a.noc = n.noc
			where medal = 'Bronze'
			group by 1
			) 
select 
	games,
	g.region, 
	Gold_Medals, 
	Silver_Medals, 
	Bronze_Medals 
from Gold g
left join Silver s
			on g.region = s.region
left join Bronze b
			on s.region = b.region
order by 1, 2


-- Country that won the most gold, most silver and most bronze medals in each olympic games.
with temp as (
		select 
			substring(games_country, 1, position(' - ' in games_country) - 1) as games,
			substring(games_country, position(' - ' in games_country) + 3) as country,
			coalesce(gold, 0) as gold,
			coalesce(silver, 0) as silver,
			coalesce(bronze, 0) as bronze
		from crosstab('select
							concat(games, '' - '', n.region) as games_country,
							medal, 
							count(1) as total_medals
						from athlete_events a
						join noc_regions n
							 on a.noc = n.noc
						where medal <> ''NA''
						group by 1, 2
						order by 1, 2',
						'values (''Bronze''), (''Gold''), (''Silver'')')
				as result (games_country varchar, bronze bigint, gold bigint, silver bigint)
		order by 1 
)
select 
	distinct games,
	concat(
			first_value(country) over(partition by games order by gold desc),
			' - ' ,
			first_value(gold) over(partition by games order by gold desc)
		  ) as Gold,
	concat(
			first_value(country) over(partition by games order by Silver desc),
			' - ' ,
			first_value(Silver) over(partition by games order by Silver desc)
		  ) as Silver,
concat(
			first_value(country) over(partition by games order by Bronze desc),
			' - ' ,
			first_value(bronze) over(partition by games order by Bronze desc)
		  ) as Bronze
from temp
order by 1



-- Countries that won the most gold, most silver, most bronze medals and the most medals in each olympic games.
with temp as (
		select 
			substring(games_country, 1, position(' - ' in games_country) - 1) as games,
			substring(games_country, position(' - ' in games_country) + 3) as country,
			coalesce(gold, 0) as gold,
			coalesce(silver, 0) as silver,
			coalesce(bronze, 0) as bronze
		from crosstab('select
							concat(games, '' - '', n.region) as games_country,
							medal, 
							count(1) as total_medals
						from athlete_events a
						join noc_regions n
							 on a.noc = n.noc
						where medal <> ''NA''
						group by 1, 2
						order by 1, 2',
						'values (''Bronze''), (''Gold''), (''Silver'')')
						-- Pass our real query as a string 
				as result (games_country varchar, bronze bigint, gold bigint, silver bigint)
		order by 1 
),
	temp2 as (
		select 
			games, 
			medal, 
			count(1) as total_medals 
		from athlete_events a
		join noc_regions n
			on a.noc = n.noc
		where medal <> 'NA'
		group by 1, 2
		order by 1, 2
)
select 
	distinct t1.games,
	concat(
			first_value(country) over(partition by t1.games order by gold desc),
			' - ' ,
			first_value(gold) over(partition by t1.games order by gold desc)
		  ) as Gold,
	concat(
			first_value(country) over(partition by t1.games order by Silver desc),
			' - ' ,
			first_value(Silver) over(partition by t1.games order by Silver desc)
		  ) as Silver,
concat(
			first_value(country) over(partition by t1.games order by Bronze desc),
			' - ' ,
			first_value(bronze) over(partition by t1.games order by Bronze desc)
		  ) as Bronze,
concat(
			first_value(country) over(partition by t2.games order by Bronze desc),
			' - ' ,
			first_value(total_medals) over(partition by t2.games order by total_medals desc)
		  ) as total_medals
from temp t1
join temp2 t2
	on t1.games = t2.games
order by 1


-- Countries that have never won gold medal but have won silver/bronze medals
select * from (
    	select
			country, 
			coalesce(gold, 0) as gold,
			coalesce(silver, 0) as silver,
			coalesce(bronze, 0) as bronze
    		from crosstab('select
								n.region as country,
								medal, 
								count(1) as total_medals
							from athlete_events a
							join noc_regions n
								 on a.noc = n.noc
							where medal <> ''NA''
							group by 1, 2
							order by 1, 2',
							'values (''Bronze''), (''Gold''), (''Silver'')') 
    		as result 
					(country varchar, bronze bigint, gold bigint, silver bigint)) x
    where gold = 0 and (silver > 0 or bronze > 0)
    order by gold desc nulls last, silver desc nulls last, bronze desc nulls last;
