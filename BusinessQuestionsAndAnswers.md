Total olympics games that have been held
```sql
select 
	count(distinct games) 
from athlete_events
```


-- List of all Olympics games held so far.
```sql
select 
	count(distinct games) as Total_no_of_games 
from athlete_events
```


Total no of nations who participated in each olympics game
```sql
select 
	games, 
	count(distinct(n.region)) as Total_nations 
from athlete_events a
join noc_regions n
		on a.noc = n.noc
group by 1
order by 2 desc
```


-- Year with the highest and lowest no of countries participating in olympics[
```sql
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
```



-- Nation that has participated in all of the olympic games
```sql
with tot_games as (
		select 
			ount(distinct games) as total_games
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
```



-- The sport which was played in all summer olympics.
```sql
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
```

		
-- Sports played only once in the olympics
```sql
with t1 as (
	select 
		distinct games, 
		sport
        from athlete_events),
     t2 as (
	select 
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
```


-- Total no of sports played in each olympic games.
```sql
select 
	games,
	count(distinct(sport)) as Total_sports
from athlete_events
group by 1
```

-- Oldest athletes to win a gold medal.
```sql
select 
	*
from athlete_events
where medal = 'Gold' and age <> 'NA'
order by age desc
limit 2
```


-- Ratio of male and female athletes participated in all olympic games.
```sql
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
```


-- Top 5 athletes who have won the most gold medals.
```sql
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
select
	name,
	region,
	Gold_medal_num
from cte 
where rnk <= 5
```



-- Top 5 athletes who have won the most medals (gold/silver/bronze).
```sql
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
select
	name,
	region,
	total_medals
from cte 
where rnk <= 5
```



-- Top 5 most successful countries in olympics. Success is defined by no of medals won.
```sql
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
```


-- Total gold, silver and bronze medals won by each country.
```sql
--OR
select 
	country,
	coalesce(gold, 0) as gold,
	coalesce(silver, 0) as silver,
	coalesce(bronze, 0) as bronze
from crosstab(
		'select
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
```


-- Total gold, silver and broze medals won by each country corresponding to each olympic games.
```sql
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
```


-- Country that won the most gold, most silver and most bronze medals in each olympic games.
```sql
with temp as (
		select 
			substring(games_country, 1, position(' - ' in games_country) - 1) as games,
			substring(games_country, position(' - ' in games_country) + 3) as country,
			coalesce(gold, 0) as gold,
			coalesce(silver, 0) as silver,
			coalesce(bronze, 0) as bronze
		from crosstab(
				'select
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
```


-- Countries that won the most gold, most silver, most bronze medals and the most medals in each olympic games.
```sql
with temp as (
		select 
			substring(games_country, 1, position(' - ' in games_country) - 1) as games,
			substring(games_country, position(' - ' in games_country) + 3) as country,
			coalesce(gold, 0) as gold,
			coalesce(silver, 0) as silver,
			coalesce(bronze, 0) as bronze
		from crosstab(
				'select
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
```

games | gold	| silver	| bronze	| total_medals
-- | -- | -- | --
1896 Summer	| Germany - 25	| Greece - 18	| Greece - 20	| Greece - 62
1900 Summer	| UK - 59	| France - 101	| France - 82	France - 228
1904 Summer	| USA - 128	| USA - 141	| USA - 125	| USA - 173
1906 Summer	| Greece - 24	| Greece - 48	| Greece - 30	| Greece - 157
1908 Summer	| UK - 147	| UK - 131	| UK - 90	| UK - 294
1912 Summer	| Sweden - 103	| UK - 64	| UK - 59	| UK - 326
1920 Summer	| USA - 111	| France - 71	| Belgium - 66	| Belgium - 493
1924 Summer	| USA - 97	| France - 51	| USA - 49	| USA - 281
1924 Winter	| UK - 16	| USA - 10	| UK - 11	| UK - 55
1928 Summer	| USA - 47	| Netherlands - 29	| Germany - 41	| Germany - 250




-- Countries that have never won gold medal but have won silver/bronze medals
```sql
select * from (
    	select
		country, 
		coalesce(gold, 0) as gold,
		coalesce(silver, 0) as silver,
		coalesce(bronze, 0) as bronze
    	from crosstab(
			'select
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
```


### Output:
country	| gold | silver | bronze
-- | -- | -- | --
Paraguay | 0 | 17 | 0
Iceland | 0 | 15 | 2
Montenegro | 0 | 14 | 0
Malaysia | 0 | 11 | 5
Namibia | 0 | 4 | 0
Philippines | 0 | 3 | 7
Moldova | 0 | 3 | 5
Lebanon | 0 | 2 | 2
Sri Lanka | 0 | 2 | 0
Tanzania | 0 | 2 | 0
Ghana | 0 | 1 | 22
Saudi Arabia | 0 | 1 | 5

