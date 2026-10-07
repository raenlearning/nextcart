-- Admin can delete any profile; users can delete their own.
create policy "profiles_admin_delete" on profiles
  for delete to authenticated
  using (
    id = auth.uid()
    or exists (
      select 1 from profiles p where p.id = auth.uid() and p.role = 'admin'
    )
  );
