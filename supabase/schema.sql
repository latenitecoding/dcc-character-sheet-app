-- Run this in the Supabase SQL editor (Project > SQL Editor > New query).
-- Stores one row per character sheet, keyed by the same string key the
-- sheet used to use for localStorage (e.g. "dcc-char-v13-ben").

create table if not exists characters (
  id text primary key,
  value text not null default '',
  updated_at timestamptz not null default now()
);

-- Keep updated_at current on every write.
create or replace function set_updated_at()
returns trigger as $$
begin
  new.updated_at = now();
  return new;
end;
$$ language plpgsql;

drop trigger if exists characters_set_updated_at on characters;
create trigger characters_set_updated_at
  before update on characters
  for each row execute function set_updated_at();

-- No auth for this app: anyone with the anon key can read/write.
-- Fine for a private hobby app not shared beyond your table's URL,
-- but note the anon key is public in the HTML source.
alter table characters enable row level security;

create policy "anon can read characters"
  on characters for select
  to anon
  using (true);

create policy "anon can insert characters"
  on characters for insert
  to anon
  with check (true);

create policy "anon can update characters"
  on characters for update
  to anon
  using (true)
  with check (true);

create policy "anon can delete characters"
  on characters for delete
  to anon
  using (true);

-- Enable realtime so all players see updates live.
alter publication supabase_realtime add table characters;
