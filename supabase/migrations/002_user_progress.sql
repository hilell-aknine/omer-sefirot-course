-- omer portal: per-user progress sync (optional login feature)
-- One row per authenticated user. Stores completed lessons, notes, and last lesson.
-- Site stays fully usable without login; this only syncs across devices when logged in.

create table if not exists user_progress (
  user_id     uuid primary key references auth.users(id) on delete cascade,
  completed   jsonb not null default '[]'::jsonb,   -- array of lesson ids
  notes       jsonb not null default '{}'::jsonb,   -- { lessonId: "note text" }
  last_lesson text,
  updated_at  timestamptz not null default now()
);

alter table user_progress enable row level security;

-- A user can read and write ONLY their own row.
create policy "read own progress"   on user_progress for select using (auth.uid() = user_id);
create policy "insert own progress" on user_progress for insert with check (auth.uid() = user_id);
create policy "update own progress" on user_progress for update using (auth.uid() = user_id) with check (auth.uid() = user_id);
