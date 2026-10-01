
select count(distinct id) as total_loan_count_month11
from financial_loan
where month(issue_date) = 11 and YEAR(issue_date) = 2021;

select sum(total_payment) as 12_total_payment from financial_loan
where month(issue_date) = 12 and year(issue_date) = 2021;

select sum(total_payment) as 11_total_payment from financial_loan
where month(issue_date) = 11 and year(issue_date) = 2021;

select round(avg(int_rate) * 100,5) as 12_avg_int_rate from financial_loan
where month(issue_date) = 12 and year(issue_date) = 2021;

select round(avg(dti) * 100, 4) as avg_dti from financial_loan
where month(issue_date) = 12 and year(issue_date) = 2021;

select distinct loan_status from financial_loan;

# Good Loan Issue
select 
	count(case when loan_status = 'Fully Paid' or loan_status = 'Current' then id end) /
	count(id) * 100 as good_loan_percentage
from financial_loan;

select count(id) as good_loan_count from financial_loan
where loan_status = 'Fully Paid' or loan_status = 'Current';

select sum(loan_amount) as good_loan_landed from financial_loan
where loan_status = 'Fully Paid' or loan_status = 'Current';

select sum(total_payment) as good_loan_received_payment from financial_loan
where loan_status = 'Fully Paid' or loan_status = 'Current';


#----- Bad Loan Issue ------------
select 
	count(case when loan_status = 'Charged Off' then id end) /
	count(id) * 100.0 as bad_loan_percentage
from financial_loan;

select count(id) as bad_loan_applications from financial_loan
where loan_status = 'Charged Off';

select sum(loan_amount) as bad_loan_funded_amount from financial_loan
where loan_status = 'Charged Off';

select sum(total_payment) as bad_loan_amount_received from financial_loan
where loan_status = 'Charged Off';

# Loan Status
select loan_status,
	count(id) as LoanCount,
	sum(total_payment) as Total_Amount_Received,
	sum(loan_amount) as Total_Funded_Amount,
	avg(int_rate) * 100.0 as Interest_Rate,
	avg(dti) * 100.0 as DTI
from financial_loan
group by loan_status;

select loan_status,
	sum(total_payment) as MTD_Total_Amount_Received,
	sum(loan_amount) as MTD_Total_Funded_Amount
from financial_loan
where month(issue_date) = 12
group by loan_status;

# BANK LOAN REPORT | OVERVIEW
select MONTH(issue_date) as Month_Number,
	count(id) as Total_Loan_Applications,
	sum(loan_amount) as Total_Funded_Amount,
	sum(total_payment) as Total_Amount_Received
from Bank_Loan.financial_loan 
group by month(issue_date)
order by month(issue_date);

select address_state as State,
	count(id) as Total_Loan_Applications,
	sum(loan_amount) as Total_Funded_Amount,
	sum(total_payment) as Total_Amount_Received
from financial_loan
group by address_state
order by address_state;

select term as Term,
	count(id) as Total_Loan_Applications,
	sum(loan_amount) as Total_Funded_Amount,
	sum(total_payment) as Total_Amount_Received
from financial_loan
group by Term 
order by Term;

select emp_length as Employee_Length,
	count(id) as Total_Loan_Applications,
	sum(loan_amount) as Total_Funded_Amount,
	sum(total_payment) as Total_Amount_Received
from financial_loan
group by Employee_Length 
order by Employee_Length ;

select purpose as Purpose,
	count(id) as Total_Loan_Applications,
	sum(loan_amount) as Total_Funded_Amount,
	sum(total_payment) as Total_Amount_Received
from financial_loan
group by Purpose 
order by Purpose ;

select home_ownership as Home_Ownership,
	count(id) as Total_Loan_Application,
	sum(loan_amount) as Total_Funded_Amount,
	sum(total_payment) as Total_Amount_Received
from financial_loan
group by Home_Ownership 
order by Home_Ownership ;

select purpose as Purpose,
	count(id) as Total_Loan_Applications,
	sum(loan_amount) as Total_Funded_Amount,
	sum(total_payment) as Tota_Amount_Received
from financial_loan
where grade = 'A'
group by Purpose 
order by Purpose ;

select * from Bank_Loan.financial_loan fl 
limit 10;

SELECT
    SUM(CASE WHEN annual_income IS NULL THEN 1 ELSE 0 END) AS income_null,
    SUM(CASE WHEN emp_title IS NULL THEN 1 ELSE 0 END) AS emp_title_null,
    SUM(CASE WHEN dti IS NULL THEN 1 ELSE 0 END) AS dti_null,
    SUM(CASE WHEN loan_amount IS NULL THEN 1 ELSE 0 END) AS loan_amount_null
FROM Bank_Loan.financial_loan fl ;

select 
	sum(case when dti is null then 1 else 0 end) as null_dti
from Bank_Loan.financial_loan fl ;




