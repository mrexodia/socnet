begin;

select no_plan();

set local search_path = core, public;

set local role socnet_user;

\echo ============
\echo comments RLS
\echo ============

set local "request.jwt.claim.user_id" to 5;

select
  is_empty(
    $$
    select * from comments where post_id = 1;
    $$,
    'an user cannot see the comments of a post he cannot see'
  );

set local "request.jwt.claim.user_id" to 2;

select
  lives_ok(
    $$
    insert into comments(post_id, user_id, body)
    values(2, 2, 'My comment');
    $$,
    'an user can insert comment from himself'
  );

select
  throws_ok(
    $$
    insert into comments(post_id, user_id, body)
    values(2, 3, 'Comment for other user');
    $$,
    '42501',
    'new row violates row-level security policy for table "comments"',
    'an user cannot insert a comment for other user'
  );

select
  results_eq(
    $$
    update comments set body = 'First comment! Edited!' where id = 1
    returning body;
    $$,
    $$
    values('First comment! Edited!')
    $$,
    'an user can update a comment he owns'
  );

select
  is_empty(
    $$
    update comments set body = 'Second comment! Edited!' where id = 2
    returning body;
    $$,
    'an user cannot update other user comment'
  );

select
  results_eq(
    $$
    delete from comments where id = 1 returning 1;
    $$,
    $$
    values(1);
    $$,
    'an user can delete his own comment'
  );

select
  is_empty(
    $$
    delete from comments where id = 2 returning *;
    $$,
    'an user cannot delete other user comment'
  );

select * from finish();
do $$ begin assert num_failed() = 0; end $$;

rollback;
