/* Welcome to the SQL mini project. For this project, you will use
Springboard' online SQL platform, which you can log into through the
following link:

https://sql.springboard.com/
Username: student
Password: learn_sql@springboard

The data you need is in the "country_club" database. This database
contains 3 tables:
    i) the "Bookings" table,
    ii) the "Facilities" table, and
    iii) the "Members" table.

Note that, if you need to, you can also download these tables locally.

In the mini project, you'll be asked a series of questions. You can
solve them using the platform, but for the final deliverable,
paste the code for each solution into this script, and upload it
to your GitHub.

Before starting with the questions, feel free to take your time,
exploring the data, and getting acquainted with the 3 tables. */



/* Q1: Some of the facilities charge a fee to members, but some do not.
Please list the names of the facilities that do. */
select name
from Facilities
where membercost > 0


/* Q2: How many facilities do not charge a fee to members? */
select count(name)
from Facilities
where membercost = 0


/* Q3: How can you produce a list of facilities that charge a fee to members,
where the fee is less than 20% of the facility's monthly maintenance cost?
Return the facid, facility name, member cost, and monthly maintenance of the
facilities in question. */
select facid,
	name,
	membercost,
	monthlymaintenance
from Facilities
where membercost > 0
	and membercost < 0.2*monthlymaintenance


/* Q4: How can you retrieve the details of facilities with ID 1 and 5?
Write the query without using the OR operator. */
select *
from Facilities
where facid in (1, 5)


/* Q5: How can you produce a list of facilities, with each labelled as
'cheap' or 'expensive', depending on if their monthly maintenance cost is
more than $100? Return the name and monthly maintenance of the facilities
in question. */
select name,
	monthlymaintenance,
	case when monthlymaintenance>100 then 'expensive'
	else 'cheap' end label
from Facilities


/* Q6: You'd like to get the first and last name of the last member(s)
who signed up. Do not use the LIMIT clause for your solution. */
select firstname,
	surname
from
Members
where joindate = (select max(joindate) from Members)


/* Q7: How can you produce a list of all members who have used a tennis court?
Include in your output the name of the court, and the name of the member
formatted as a single column. Ensure no duplicate data, and order by
the member name. */
select 
F.name,
concat(M.firstname, ' ', M.surname) member_name
from Bookings B
left join Facilities F
	on B.facid = F.facid
left join Members M
	on B.memid = M.memid
where F.facid in (0, 1) and M.memid != 0
group by 2
order by 2


/* Q8: How can you produce a list of bookings on the day of 2012-09-14 which
will cost the member (or guest) more than $30? Remember that guests have
different costs to members (the listed costs are per half-hour 'slot'), and
the guest user's ID is always 0. Include in your output the name of the
facility, the name of the member formatted as a single column, and the cost.
Order by descending cost, and do not use any subqueries. */
select
	F.name,
	case when M.memid = 0 then 'Guest'
		else concat(M.firstname, ' ', M.surname)
		end member_name,
	case when M.memid = 0 then F.guestcost * B.slots
		else F.membercost * B.slots
		end cost
from Bookings B
left join Facilities F
	on B.facid = F.facid
left join Members M
	on B.memid = M.memid
where B.starttime >= '2012-09-14' and B.starttime < '2012-09-15'
	and (
		(M.memid=0 and F.guestcost * B.slots > 30) or
		(M.memid!=0 and F.membercost * B.slots > 30)
	)
order by 3 desc


/* Q9: This time, produce the same result as in Q8, but using a subquery. */
select
*
from
(select
	F.name,
	case when M.memid = 0 then 'Guest'
		else concat(M.firstname, ' ', M.surname)
		end member_name,
	case when M.memid = 0 then F.guestcost * B.slots
		else F.membercost * B.slots
		end cost
from Bookings B
left join Facilities F
	on B.facid = F.facid
left join Members M
	on B.memid = M.memid
where B.starttime >= '2012-09-14' and B.starttime < '2012-09-15'
) temp
where temp.cost > 30
order by cost desc


/* Q10: Produce a list of facilities with a total revenue less than 1000.
The output of facility name and total revenue, sorted by revenue. Remember
that there's a different cost for guests and members! */
select
	F.name,
	sum(
		case when M.memid = 0 then F.guestcost * B.slots
			else F.membercost * B.slots end
	) total_revenue
from Bookings B
left join Facilities F
	on B.facid = F.facid
left join Members M
	on B.memid = M.memid
group by 1
having revenue<1000
order by 2