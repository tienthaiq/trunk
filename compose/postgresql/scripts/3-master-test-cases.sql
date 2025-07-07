-- Insert 2 record
insert into public.actor (first_name, last_name) values ('user-1', 'bar');
insert into public.actor (first_name, last_name) values ('user-2', 'bar');

-- Insert 1 record and then update 1
insert into public.actor (first_name, last_name) values ('user-3', 'bar');
update public.actor set last_name = 'bar-2' where first_name = 'user-2';

-- Delete 1
delete from public.actor where first_name = 'user-2';

-- Change replica identity to full
alter table public.actor replica identity full;


-- Add 1 column & insert 1
alter table public.actor add column description text default 'barbar';
insert into public.actor (first_name, last_name) values ('user-4', 'bar');

-- Drop column, insert 1 & update 1
alter table public.actor drop column description;
insert into public.actor (first_name, last_name) values ('user-5', 'bar');
update public.actor set last_name = 'bar-2' where first_name = 'user-4';

-- Create table and insert 1
create table demo (id int, name text);
insert into public.demo (id, name) values (1, 'foo');
