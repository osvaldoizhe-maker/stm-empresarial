-- STM cloud multiempresa. Revisar en staging antes de producción.
create extension if not exists pgcrypto;
create type public.app_role as enum ('owner','admin','planner','technician','viewer');
create type public.work_order_status as enum ('pending','in_progress','completed','cancelled');
create type public.work_order_priority as enum ('low','medium','high','critical');
create type public.equipment_status as enum ('operational','maintenance','out_of_service');
create type public.preventive_status as enum ('scheduled','in_progress','completed','overdue');

create table public.companies (
 id uuid primary key default gen_random_uuid(),
 name text not null check(length(trim(name)) between 2 and 160),
 timezone text not null default 'America/Mexico_City',
 currency char(3) not null default 'MXN',
 created_at timestamptz not null default now(),
 created_by uuid references auth.users(id) on delete set null
);
create table public.memberships (
 company_id uuid not null references public.companies(id) on delete cascade,
 user_id uuid not null references auth.users(id) on delete cascade,
 role public.app_role not null default 'viewer',
 active boolean not null default true,
 created_at timestamptz not null default now(),
 primary key(company_id,user_id)
);
create index memberships_user_idx on public.memberships(user_id,active);

create or replace function public.is_company_member(p_company_id uuid)
returns boolean language sql stable security definer set search_path=''
as $$ select exists(select 1 from public.memberships m where m.company_id=p_company_id and m.user_id=(select auth.uid()) and m.active=true); $$;
create or replace function public.has_company_role(p_company_id uuid,p_roles public.app_role[])
returns boolean language sql stable security definer set search_path=''
as $$ select exists(select 1 from public.memberships m where m.company_id=p_company_id and m.user_id=(select auth.uid()) and m.active=true and m.role=any(p_roles)); $$;
revoke all on function public.is_company_member(uuid) from public;
revoke all on function public.has_company_role(uuid,public.app_role[]) from public;
grant execute on function public.is_company_member(uuid) to authenticated;
grant execute on function public.has_company_role(uuid,public.app_role[]) to authenticated;

create table public.equipment (
 id uuid primary key default gen_random_uuid(),
 company_id uuid not null references public.companies(id) on delete cascade,
 code text not null check(length(trim(code)) between 1 and 64),
 name text not null check(length(trim(name)) between 1 and 200),
 category text, location text, manufacturer text, model text, serial_number text,
 status public.equipment_status not null default 'operational',
 installed_at date, last_maintenance_at date, notes text,
 created_by uuid not null default auth.uid() references auth.users(id),
 created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
 unique(company_id,code), unique(company_id,id)
);
create index equipment_company_status_idx on public.equipment(company_id,status);

create table public.work_orders (
 id uuid primary key default gen_random_uuid(),
 company_id uuid not null references public.companies(id) on delete cascade,
 folio text not null,
 title text not null check(length(trim(title)) between 3 and 200),
 description text, equipment_id uuid,
 status public.work_order_status not null default 'pending',
 priority public.work_order_priority not null default 'medium',
 requested_by uuid not null default auth.uid() references auth.users(id),
 assigned_to uuid references auth.users(id) on delete set null,
 planned_start timestamptz, due_at timestamptz, started_at timestamptz, completed_at timestamptz,
 labor_minutes integer not null default 0 check(labor_minutes>=0),
 parts_cost numeric(12,2) not null default 0 check(parts_cost>=0),
 labor_cost numeric(12,2) not null default 0 check(labor_cost>=0),
 other_cost numeric(12,2) not null default 0 check(other_cost>=0),
 created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
 unique(company_id,folio), unique(company_id,id),
 foreign key(company_id,equipment_id) references public.equipment(company_id,id) on delete restrict
);
create index work_orders_company_status_due_idx on public.work_orders(company_id,status,due_at);
create index work_orders_assigned_idx on public.work_orders(company_id,assigned_to);

create table public.preventive_plans (
 id uuid primary key default gen_random_uuid(),
 company_id uuid not null references public.companies(id) on delete cascade,
 code text not null, name text not null check(length(trim(name)) between 3 and 200),
 equipment_id uuid, frequency_days integer not null check(frequency_days between 1 and 3650),
 responsible_id uuid references auth.users(id) on delete set null,
 last_run_at timestamptz, next_run_at timestamptz not null,
 status public.preventive_status not null default 'scheduled',
 task_list jsonb not null default '[]'::jsonb check(jsonb_typeof(task_list)='array'),
 created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
 unique(company_id,code),
 foreign key(company_id,equipment_id) references public.equipment(company_id,id) on delete restrict
);
create index preventive_due_idx on public.preventive_plans(company_id,next_run_at);

create table public.audit_events (
 id bigint generated always as identity primary key,
 company_id uuid not null references public.companies(id) on delete cascade,
 actor_id uuid references auth.users(id) on delete set null,
 action text not null check(length(action) between 1 and 100),
 entity_type text not null check(length(entity_type) between 1 and 100),
 entity_id text, occurred_at timestamptz not null default now(),
 request_id text, metadata jsonb not null default '{}'::jsonb check(jsonb_typeof(metadata)='object')
);
create index audit_company_time_idx on public.audit_events(company_id,occurred_at desc);

create table public.attachments (
 id uuid primary key default gen_random_uuid(),
 company_id uuid not null references public.companies(id) on delete cascade,
 work_order_id uuid references public.work_orders(id) on delete cascade,
 storage_path text not null, original_name text not null, content_type text not null,
 size_bytes bigint not null check(size_bytes between 1 and 26214400),
 uploaded_by uuid not null default auth.uid() references auth.users(id),
 created_at timestamptz not null default now(), unique(company_id,storage_path)
);

alter table public.companies enable row level security;
alter table public.memberships enable row level security;
alter table public.equipment enable row level security;
alter table public.work_orders enable row level security;
alter table public.preventive_plans enable row level security;
alter table public.audit_events enable row level security;
alter table public.attachments enable row level security;

create policy company_read_member on public.companies for select to authenticated using(public.is_company_member(id));
create policy company_update_admin on public.companies for update to authenticated using(public.has_company_role(id,array['owner','admin']::public.app_role[])) with check(public.has_company_role(id,array['owner','admin']::public.app_role[]));
create policy membership_read_member on public.memberships for select to authenticated using(public.is_company_member(company_id));
-- Importante: no se permite gestionar roles desde el cliente. Onboarding/invitaciones requieren backend confiable.

create policy equipment_read_member on public.equipment for select to authenticated using(public.is_company_member(company_id));
create policy equipment_insert_planner on public.equipment for insert to authenticated with check(public.has_company_role(company_id,array['owner','admin','planner']::public.app_role[]));
create policy equipment_update_planner on public.equipment for update to authenticated using(public.has_company_role(company_id,array['owner','admin','planner']::public.app_role[])) with check(public.has_company_role(company_id,array['owner','admin','planner']::public.app_role[]));
create policy equipment_delete_admin on public.equipment for delete to authenticated using(public.has_company_role(company_id,array['owner','admin']::public.app_role[]));

create policy orders_read_member on public.work_orders for select to authenticated using(public.is_company_member(company_id));
create policy orders_insert_authorized on public.work_orders for insert to authenticated with check(public.has_company_role(company_id,array['owner','admin','planner','technician']::public.app_role[]));
create policy orders_update_authorized on public.work_orders for update to authenticated using(public.has_company_role(company_id,array['owner','admin','planner']::public.app_role[]) or (assigned_to=(select auth.uid()) and public.is_company_member(company_id))) with check(public.has_company_role(company_id,array['owner','admin','planner']::public.app_role[]) or (assigned_to=(select auth.uid()) and public.is_company_member(company_id)));
create policy orders_delete_admin on public.work_orders for delete to authenticated using(public.has_company_role(company_id,array['owner','admin']::public.app_role[]));

create policy preventive_read_member on public.preventive_plans for select to authenticated using(public.is_company_member(company_id));
create policy preventive_insert_planner on public.preventive_plans for insert to authenticated with check(public.has_company_role(company_id,array['owner','admin','planner']::public.app_role[]));
create policy preventive_update_planner on public.preventive_plans for update to authenticated using(public.has_company_role(company_id,array['owner','admin','planner']::public.app_role[])) with check(public.has_company_role(company_id,array['owner','admin','planner']::public.app_role[]));
create policy preventive_delete_admin on public.preventive_plans for delete to authenticated using(public.has_company_role(company_id,array['owner','admin']::public.app_role[]));

create policy audit_read_admin on public.audit_events for select to authenticated using(public.has_company_role(company_id,array['owner','admin']::public.app_role[]));
-- Sin política cliente de INSERT/UPDATE/DELETE en auditoría: registrar mediante lógica confiable de servidor.
create policy attachments_read_member on public.attachments for select to authenticated using(public.is_company_member(company_id));
create policy attachments_insert_member on public.attachments for insert to authenticated with check(public.is_company_member(company_id) and uploaded_by=(select auth.uid()));
create policy attachments_delete_admin_uploader on public.attachments for delete to authenticated using(public.has_company_role(company_id,array['owner','admin']::public.app_role[]) or uploaded_by=(select auth.uid()));

revoke all on public.companies,public.memberships,public.equipment,public.work_orders,public.preventive_plans,public.audit_events,public.attachments from anon;
grant select,update on public.companies to authenticated;
grant select on public.memberships to authenticated;
grant select,insert,update,delete on public.equipment,public.work_orders,public.preventive_plans,public.attachments to authenticated;
grant select on public.audit_events to authenticated;
grant usage,select on sequence public.audit_events_id_seq to authenticated;
