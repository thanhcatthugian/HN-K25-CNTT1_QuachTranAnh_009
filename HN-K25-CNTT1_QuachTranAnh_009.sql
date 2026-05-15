drop database if exists finalsql;
create database finalsql;
use finalsql;

	-- PHẦN 1: DDL – THIẾT KẾ CSDL 

/*
Tạo bảng employees
*/

create table employees(
employee_id int primary key auto_increment,
full_name varchar(50) not null,
email varchar(50) not null unique,
phone_number varchar(15) unique,
hire_date date default(current_date()),
salary decimal(18,2) check(salary > 0)
);

/*
Tạo bảng employee_details
*/

create table employee_details(
detail_id int primary key auto_increment,
employee_id int,
foreign key(employee_id)references employees(employee_id),
citizen_id int not null unique,
address varchar(50) not null,
working_status enum('Active','Inactive')
);

/*
Tạo bảng departments
*/

create table departments (
department_id int primary key auto_increment,
department_name varchar(50) not null unique,
description text
);

/*
Tạo bảng projects
*/

create table projects(
project_id int primary key auto_increment,
project_name varchar(50) not null,
department_id int,
foreign key(department_id)references departments(department_id),
budget decimal(18,2) check(budget>0),
project_status enum('Pending','Doing','Done')
);

/*
Tạo bảng work_assignments
*/

create table work_assignments(
assignment_id int primary key,
employee_id int,
foreign key(employee_id)references employees(employee_id),
project_id int,
foreign key(project_id)references projects(project_id),
start_date date not null,
deadline date not null,
completed_date date,
constraint check(deadline > start_date)
);

	-- PHẦN 2: DML – INSERT, UPDATE, DELETE

/*
Viết câu lệnh chèn dữ liệu cho employees
*/

insert into employees(full_name,email,phone_number,hire_date,salary)
values
('Nguyen Van A','anv@gmail.com','0901234567','2022-01-15',12000000),
('Tran Thi B','btt@gmail.com','0912345678','2021-05-20',18000000),
('Le Van C','cle@yahoo.com','0922334455','2023-02-10',9500000),
('Pham Minh D','dpham@hotmail.com','0933445566','2020-11-05',22000000),
('Hoang Anh E','ehoang@gmail.com','0944556677','2023-01-12',15000000);

/*
Viết câu lệnh chèn dữ liệu cho employee_details
*/

insert into employee_details(employee_id,citizen_id,address,working_status)
values
(1,123456789,'Ha Noi','Active'),
(2,234567890,'Hai Phong','Active'),
(3,345678901,'Da Nang','Inactive'),
(4,456789012,'Ho Chi Minh','Active'),
(5,567890123,'Can Tho','Active');

/*
Viết câu lệnh chèn dữ liệu cho departments
*/

insert into departments(department_name,description)
values
('IT','Phòng công nghệ thông tin'),
('HR','Phòng nhân sự'),
('Marketing','Phòng marketing'),
('Finance','Phòng tài chính'),
('Sales','Phòng kinh doanh');

/*
Viết câu lệnh chèn dữ liệu cho projects
*/

insert into projects(project_name,department_id,budget,project_status)
values
('Website Company',1,50000000,'Doing'),
('Recruitment 2025',2,20000000,'Pending'),
('Ads Campaign',3,30000000,'Doing'),
('Accounting System',4,45000000,'Done'),
('Customer Expansion',5,25000000,'Pending');

/*
Viết câu lệnh chèn dữ liệu cho work_assignments
*/

insert into work_assignments(assignment_id,employee_id,project_id,start_date,deadline,completed_date)
values
(101,1,1,'2024-01-10','2024-02-10',null),
(102,2,2,'2024-02-01','2024-03-01','2024-02-25'),
(103,3,3,'2024-03-05','2024-04-05',null),
(104,4,4,'2023-10-10','2023-12-10','2023-12-05'),
(105,5,5,'2024-04-01','2024-05-01',null);

	-- UPDATE & DELETE

/*
Viết câu lệnh tăng thêm 5.000.000 VNĐ ngân sách cho các dự án thỏa mãn đồng thời:
Thuộc phòng ban 'IT'.
*/

update projects
set budget = budget + 5000000
where department_id = (
select department_id
from departments
where department_name = 'IT'
);

/*
Viết câu lệnh xóa các bản ghi trong Work_Assignments thỏa mãn:
Đã hoàn thành (completed_date IS NOT NULL) và có ngày bắt đầu trước năm 2024.
*/

delete from work_assignments where completed_date is not null and year(start_date) < 2024;

	-- PHẦN 3: TRUY VẤN CƠ BẢN

/*
Liệt kê các thông tin dự án gồm project_id, project_name, budget 
của những dự án thuộc phòng ban 'IT' và có ngân sách lớn hơn 30.000.000.
*/

select project_id,project_name,budget
from projects 
where department_id = (select department_id
from departments
where department_name = 'IT'
);

/*
Liệt kê các thông tin nhân viên gồm employee_id, full_name, email 
của những nhân viên có ngày vào làm trong năm 2022 và email thuộc tên miền 
'@gmail.com'.
*/

select employee_id, full_name, email
from employees
where year(hire_date) = 2022 and email like'%@gmail.com%';

/*
Liệt kê danh sách nhân viên gồm employee_id, full_name, salary, 
trong đó danh sách được sắp xếp theo lương giảm dần và chỉ hiển thị 3 nhân viên 
bắt đầu từ người thứ 2 (bỏ qua người lương cao nhất).
*/

select employee_id, full_name, salary
from employees
order by salary desc
limit 3 offset 1;

	-- PHẦN 4: TRUY VẤN NÂNG CAO

/*
Liệt kê các thông tin phân công gồm mã phân công, tên 
nhân viên, tên dự án, ngày bắt đầu, hạn hoàn thành, với dữ liệu được lấy từ các bảng liên quan và 
chỉ hiển thị các công việc chưa hoàn thành (completed_date IS NULL).
*/

select a.assignment_id,e.full_name,p.project_name,a.start_date,a.deadline
from employees as e inner join projects as p inner join work_assignments as a
on e.employee_id = a.employee_id and a.project_id  = p.project_id
where completed_date is null;

/*
Liệt kê tổng ngân sách dự án theo từng phòng ban gồm 
department_name và total_budget, chỉ hiển thị những phòng ban có tổng ngân 
sách lớn hơn 40.000.000.
*/

select d.department_name, sum(p.budget) as total_budget
from departments as d inner join projects as p
on d.department_id = p.department_id
group by d.department_name
having total_budget > 40000000;

/*
Liệt kê các thông tin nhân viên gồm employee_id, full_name, 
working_status của những nhân viên có trạng thái làm việc là 'Active' nhưng chưa 
từng tham gia dự án nào có ngân sách lớn hơn 40.000.000.
*/

select e.employee_id, e.full_name, ed.working_status
from employees as e inner join projects as p inner join work_assignments as a inner join employee_details as ed
on e.employee_id = a.employee_id and a.project_id  = p.project_id and ed.employee_id = e.employee_id
where ed.working_status = 'Active' and p.budget < 40000000;

	-- PHẦN 5: INDEX & VIEW

/*
Tạo một chỉ mục (index) tên idx_assignment_dates trên bảng 
Work_Assignments dựa trên hai cột start_date và completed_date nhằm tối ưu 
truy vấn.
*/

create index idx_assignment_dates on work_assignments(start_date,completed_date);

/*
Tạo một khung nhìn (view) tên vw_overdue_assignments hiển thị mã 
phân công, tên nhân viên, tên dự án, ngày bắt đầu và hạn hoàn thành, trong đó chỉ 
chứa các công việc chưa hoàn thành và đã quá hạn so với ngày hiện tại 
(CURDATE()).
*/

create or replace view vw_overdue_assignments as
select a.assignment_id,e.full_name,p.project_name,a.start_date,a.deadline
from employees as e inner join projects as p inner join work_assignments as a
on e.employee_id = a.employee_id and a.project_id  = p.project_id
where completed_date is null or completed_date > current_date();

select * from vw_overdue_assignments;

	-- PHẦN 6: TRIGGER

/*
Viết một trigger tên trg_after_assignment_insert sao cho khi thêm 
mới một phân công vào bảng Work_Assignments, hệ thống tự động cập nhật 
trạng thái dự án tương ứng thành 'Doing'.
*/

delimiter //
create trigger trg_after_assignment_insert
after insert on work_assignments
for each row
begin
	update projects
    set project_status = 'Doing'
    where project_id = new.project_id;
end
// delimiter ;
insert into work_assignments(assignment_id,employee_id,project_id,start_date,deadline,completed_date)
values
(106,5,2,'2024-02-01','2024-03-01','2024-02-25');
select * from projects;

/*Viết một trigger tên trg_prevent_delete_employee ngăn chặn việc 
xóa nhân viên nếu nhân viên đó vẫn còn công việc chưa hoàn thành 
(completed_date IS NULL).
*/

delimiter //
create trigger trg_prevent_delete_employee
before delete on employees
for each row
begin
	declare checking int;
    select employee_id into checking
    from work_assignments
    where completed_date is null and old.employee_id = employee_id;
	if old.employee_id = checking then
    signal sqlstate '45000'
    set message_text = 'Nhân viên đó vẫn còn công việc chưa hoàn thành';
    end if;
end
// delimiter ;

delete from employees where employee_id = 1;

	-- PHẦN 7: STORED PROCEDURE 

/*Viết một stored procedure tên sp_check_project_budget nhận vào p_project_id và trả về p_message, trong đó:
Nếu ngân sách < 20.000.000 → 'Ngân sách thấp'
Nếu ngân sách từ 20.000.000 – 40.000.000 → 'Ngân sách trung bình'
Nếu ngân sách > 40.000.000 → 'Ngân sách cao'*/

delimiter //
create procedure sp_check_project_budget(
	in p_project_id int,
    out p_message varchar(100)
)
begin
	declare checking decimal(18,2);
    select budget into checking
    from projects
    where project_id = p_project_id;
    
    if checking < 20000000 then
    set p_message = 'Ngân sách thấp';
    elseif checking between 20000000 and 40000000 then
    set p_message = 'Ngân sách trung bình';
    elseif checking > 40000000 then
    set p_message = 'Ngân sách cao';
    end if;
end
// delimiter ;
set @ann = '';
call sp_check_project_budget(1,@ann);
select @ann as p_message;

call sp_check_project_budget(2,@ann);
select @ann as p_message;

call sp_check_project_budget(3,@ann);
select @ann as p_message;

/*
 Viết một stored procedure tên sp_complete_assignment_transaction để xử lý hoàn thành công việc bằng Transaction, nhận vào p_assignment_id, gồm các bước:
Bước 1: Bắt đầu giao dịch (START TRANSACTION)
Bước 2: Kiểm tra công việc đã hoàn thành chưa — nếu completed_date IS NOT NULL → ROLLBACK + báo lỗi 'Công việc đã hoàn thành rồi'
Bước 3: Cập nhật completed_date = CURDATE()
Bước 4: Nếu tất cả công việc của dự án đã hoàn thành → cập nhật project_status = 'Done'
Bước 5: COMMIT nếu thành công, ROLLBACK nếu có lỗi

*/

delimiter //
create procedure sp_complete_assignment_transaction(
	in p_assignment_id int,
	out p_ann varchar(100)
)
begin
	declare checking varchar(50);
    declare doubcheck int;
    
    select completed_date into checking
    from work_assignments
    where assignment_id = p_assignment_id;
    
    select project_id into doubcheck
    from work_assignments
    where assignment_id = p_assignment_id;
    
	start transaction;
    
    if checking is not null then 
    set p_ann = 'Công việc đã hoàn thành rồi';
    rollback;
    else
    update work_assignments
    set completed_date = current_date()
    where assignment_id = p_assignment_id;
    
    update projects
    set project_status = 'Done'
    where project_id = doubcheck;
    set p_ann = 'Công việc đã xong';
    end if;
    commit;
end
// delimiter ;

set @ann = '';
call sp_complete_assignment_transaction(101,@ann);
select @ann;

call sp_complete_assignment_transaction(106,@ann);
select @ann;

select * from projects;
select * from work_assignments;