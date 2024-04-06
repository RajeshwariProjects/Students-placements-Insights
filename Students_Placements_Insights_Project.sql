                                   ----------  STUDENTS PLACEMENTS INSIGHTS -------------

--- Student Information:

-- Retrieve the details (name, email, contact) of all students who joined after a 2021.

select stud_name, stud_Email_ID, stud_contact_no 
from students 
where extract(year from stud_join_dt) < 2021;


-- Get the count of male and female students in the database.

select stud_gender, count(*) as count
from students
group by stud_gender;


--- Payment Management:

-- Calculate the total amount paid by all students.

select 
   sum(payment_amt) as Total_amt_paid
from payments;

-- Find the student(s) who made the highest payment -- top 10.

select s.stud_id, s.stud_name
from students s
join payments p 
on s.Stud_id = p.Stud_id; 


-- Identify any payments made below a certain threshold. below 20k

select s.stud_id, s.stud_name
from students s
join payments p 
on s.Stud_id = p.Stud_id
where p.payment_amt < 20000;

--- Placements:

-- List all placements along with the corresponding company names and job titles.

select stud_id, company_name, job_title
from placements;

-- Find the average placement CTC (Cost to Company).

select round(avg(placement_ctc),2)  as avg_ctc
from placements;

-- Retrieve the details of students who got placed in a infoys;

select s.stud_name, s.stud_name
from students s
join placements p 
on s.stud_id = p.stud_id;

--- Miscellaneous:

-- Determine the branch with the highest number of students.

select  b.branch_name, count(s.stud_id) as stud_count
from students s 
join branches b
on s.stud_branch_id = b.branch_id
group by b.branch_name;

-- Find the student(s) with the highest educational qualification.
-- as i have only b.sc and m.sc degree in my dataset we can filter out the m.sc students

select stud_id, stud_name, stud_ed_qualification
from students
where stud_ed_qualification = "Master's Degree";


--- Course Enrollment:

-- Retrieve the count of students enrolled in each course.

select c.course_name, count(*) as stud_count
from students s
join courses c
on s.stud_course_id = c.course_id
group by c.course_name;

-- Determine which courses have the highest and lowest enrollment.

select course_name,
       no_of_studs as enrollment_rate
from
(select count(s.stud_id) as no_of_studs, c.course_name
from students s
join courses c
on s.stud_course_id = c.course_id
group by c.course_name
order by no_of_studs desc
limit 1) as high

union all
select course_name,
       no_of_studs as enrollment_rate
from 
(select count(s.stud_id) as no_of_studs, c.course_name
from students s
join courses c
on s.stud_course_id = c.course_id
group by c.course_name
order by no_of_studs 
limit 1) as low;


--- Payment Analysis:

-- Calculate the average payment amount made by students.

select s.stud_id, s.stud_name, avg(p.payment_amt)
from students s 
join payments p 
on s.stud_id = p.stud_id
group by s.stud_id, s.stud_name;

-- Identify any students who have outstanding payments (payments_due > 0).

select stud_id 
from payments
where payment_due != 0;

--- Placement Statistics:

-- Determine the percentage of students placed out of the total number of students.

select 
     round(count(p.stud_id) / count(*) * 100,2) as percentage
from students s 
left join placements p 
on s.stud_id = p.stud_id;

-- Find the companies offering the highest CTC (Cost to Company) for placements.

select company_name 
from placements
order by (select distinct placement_ctc 
from placements) desc;

--- Branch Performance:

-- Calculate the average fee collected per student for each branch.

select  b.branch_name, round(sum(p.payment_amt)/count(distinct s.stud_id),2) as avg_per_stud
from students s
join branches b
on s.stud_branch_id = b.branch_id
join payments p
on s.stud_id = p.stud_id
group by b.branch_name;


-- Identify branches with the highest and lowest fee collection.

select 
    branch_name,
    total_fee_collection
from (
    select 
        b.branch_name, 
        SUM(p.payment_amt) AS total_fee_collection
    from 
        students s 
    join 
        branches b ON s.stud_branch_id = b.branch_id
    join 
        payments p ON s.stud_id = p.stud_id
    group by 
        b.branch_name
    order by 
        total_fee_collection DESC
    limit 1
) AS max_fee_collection
UNION ALL
select  
    branch_name,
    total_fee_collection
from (
    select 
        b.branch_name, 
        SUM(p.payment_amt) AS total_fee_collection
    from 
        students s 
    join 
        branches b ON s.stud_branch_id = b.branch_id
    join 
        payments p ON s.stud_id = p.stud_id
    group by 
        b.branch_name
    order by 
        total_fee_collection 
    limit 1
) AS min_fee_collection;


--- Student Progression:

-- Determine the duration between a student joining and making their first payment.

select
    datediff(p.payment_dt,s.stud_join_dt) as duration_bet
from students s
join payments p
on s.stud_id = p.stud_id;

-- Find students who made payments within a specific date range after joining.betweeen(jan 2021 to june 2023)

select stud_id, stud_name
from students 
where stud_join_dt between '2021-01-01' and '2023-06-30';

--- Gender Analysis:

-- Calculate the percentage of male and female students in each course.

select s.stud_gender, c.course_name, round(count(*)/(select count(*) from students) *100,2) as count
from students s
join courses c
on s.stud_course_id = c.course_id
group by s.stud_gender, c.course_name;

-- Determine if there is any significant difference in the average payment amount between male and female students.

select  s.stud_gender, round(avg(p.payment_amt)) as avg_payment_amt
from students s 
join payments p 
on s.stud_id = p.stud_id
group by s.stud_gender;

--- Placement Success Rate:

-- Calculate the percentage of students placed from each course.

select c.course_name, 
	   round(count(p.stud_id)/(select count(*) from students)*100) as percentage
from students s
join courses c 
on stud_course_id = c.course_id 
join placements p 
on s.stud_id = p.stud_id
group by c.course_name;
       
-- Retrieve the contact details of students who have completed their courses.

-- since there is no particular data indicating the compeletion so we can refer to students who completed the payments.

select s.stud_id, s.stud_name, s.stud_Email_ID, s.stud_contact_no, s.stud_Address
from students s
left join payments p 
on s.stud_id = p.stud_id
where Remarks = 'completed';

-- Analyze the trend of payments over time (monthly or quarterly).

SELECT 
    DATE_FORMAT(payment_dt, '%Y-%m') AS month,
    COUNT(*) AS num_payments,
    SUM(payment_amt) AS total_payments,
    AVG(payment_amt) AS average_payment
FROM 
    payments
GROUP BY 
    DATE_FORMAT(payment_dt, '%Y-%m')
ORDER BY 
    month;
    
--- Branch Performance Comparison:

-- Compare the total fee collection and the number of students placed among different branches.


select  b.branch_name, sum(p.payment_amt) as total_amt, count(s.stud_id) as no_of_studs
from students s 
join branches b
on s.stud_branch_id = b.branch_id 
join payments p
on s.stud_id = p.stud_id
group by b.branch_name;


-- Determine which branch has the highest and lowest fee collection and placement rates.

select branch_name,
       no_of_studs as placement_rate
from
(select count(p.stud_id) as no_of_studs, b.branch_name
from students s
join branches b
on s.stud_branch_id = b.branch_id
left join placements p 
on s.stud_id = p.stud_id
group by b.branch_name
order by no_of_studs desc
limit 1) as high

union all
select branch_name,
       no_of_studs as placement_rate
from 
(select count(p.stud_id) as no_of_studs, b.branch_name
from students s
join branches b
on s.stud_branch_id = b.branch_id
left join placements p 
on s.stud_id = p.stud_id
group by b.branch_name
order by no_of_studs 
limit 1) as low;


--- Payment Trends Over Time:

-- Analyze the trend of payments over different time intervals (e.g., monthly, quarterly, yearly).

select extract(year from payment_dt) as yr,
       payment_amt
from payments;
       
select extract(month from payment_dt) as mnth,
       payment_amt
from payments;

       

-- in last 5 years which branch have the highest placements;

select  b.branch_name, count(p.stud_id) as No_of_stud_placed
from students s
inner join branches b 
on s.stud_branch_id = b.branch_id
inner join placements p
on s.stud_id = p.stud_id
group by b.branch_name
order by No_of_stud_placed desc;

-- placements records year wise;

select extract(year from placement_dt) as placed_year, count(p.stud_id) as No_of_stud_placed
from students s
inner join branches b 
on s.stud_branch_id = b.branch_id
inner join placements p
on s.stud_id = p.stud_id
group by  placed_year
order by No_of_stud_placed desc;

-- -- placements records year wise for each branch;

select extract(year from placement_dt) as placed_year, b.branch_name, count(p.stud_id) as No_of_stud_placed
from students s
inner join branches b 
on s.stud_branch_id = b.branch_id
inner join placements p
on s.stud_id = p.stud_id
group by  b.branch_name, placed_year
order by No_of_stud_placed desc;

-- Which students, belonging to which branches and courses, made payments and were placed in companies with pending payment dues;

select s.stud_name, b.branch_name, c.course_name, p2.company_name, p1.payment_due
 from students s
inner join payments p1
     on s.stud_id = p1.stud_id
left join placements p2     
    on s.stud_id = p2.stud_id
inner join courses c 
    on s.stud_course_id = c.course_id
inner join branches b
	on s.stud_branch_id = b.branch_id;

-- For each year, branch, and course, what is the number of students who joined;

select extract(year from stud_join_dt) as stud_year, b.branch_name, c.course_name, count(s.stud_id) as No_of_studs
from students s
inner join branches b 
on s.stud_branch_id = b.branch_id
inner join courses c
on s.stud_course_id = c.course_id
group by  b.branch_name,c.course_name, stud_year
order by No_of_studs desc;

-- What is the total revenue generated from payments in each year for each branch;

select extract(year from stud_join_dt) as stud_year, b.branch_name, sum(payment_amt) as Total_revenue
 from students s
inner join branches b
     on s.stud_branch_id = b.branch_id
inner join payments p    
    on s.stud_id = p.stud_id
group by stud_year, b.branch_name;

-- For each year, branch, and course, what is the total revenue generated from payments;

select extract(year from stud_join_dt) as stud_year, b.branch_name, c.course_name, sum(payment_amt) as Total_revenue
 from students s
inner join branches b
     on s.stud_branch_id = b.branch_id
inner join courses c
     on s.stud_course_id = c.course_id
inner join payments p    
     on s.stud_id = p.stud_id
group by stud_year, b.branch_name, c.course_name;

-- For each year, branch, and course, how many students were placed;

select extract(year from p.placement_dt) as stud_year, b.branch_name, c.course_name, count(p.stud_id) as No_of_studs_placed
 from students s
inner join branches b
     on s.stud_branch_id = b.branch_id
inner join courses c
     on s.stud_course_id = c.course_id
inner join placements p    
     on s.stud_id = p.stud_id
group by stud_year, b.branch_name, c.course_name;


-- For each year, branch, and course, what is the maximum placement CTC (Cost to Company);

select extract( year from stud_join_dt) as stud_year, b.branch_name, c.course_name, max(placement_ctc)
from students s
inner join branches b
 on s.stud_branch_id = b.branch_id
inner join courses c
 on s.stud_course_id = c.course_id
inner join placements p
group by stud_year, b.branch_name, c.course_name;

-- For each year, company, and course, how many students were placed;

select extract(year from placement_dt) as stud_year, p.company_name, c.course_name, count(p.stud_id) as stud_placed
from students s
inner join courses c
  on s.stud_course_id = c.course_id
inner join placements p
  on s.stud_id = p.stud_id
group by stud_year, p.company_name, c.course_name;



--- For each month and branch, what is the count of students who joined;

select monthname(s.stud_join_dt) as month_name, count(*) as stud_count, b.branch_name
from students s
join courses c
on s.stud_course_id = c.course_id
join branches b
on s.stud_branch_id = b.branch_id
group by month_name, b.branch_name
order by stud_count desc;