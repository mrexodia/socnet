-- RESTRICTIVE SELECT RLS for users that are blocked by other users

---------
--users--
---------

create policy blocked_select_policy
on users
as restrictive
for select
to socnet_user
using(
  users.id not in (
    select util.blocker_ids(util.jwt_user_id())
  )
);

-----------------
--users_details--
-----------------

create policy blocked_select_policy
on users_details
as restrictive
for select
to socnet_user
-- could be ignored for friends and friends_blacklist
-- since they are already filtered by accepted friendships
using(
  users_details.user_id not in (
    select util.blocker_ids(util.jwt_user_id())
  )
);

------------------------
--users_details_access--
------------------------

create policy blocked_select_policy
on users_details_access
as restrictive
for select
to socnet_user
using(
  users_details_access.user_details_id not in (
    select util.blocker_ids(util.jwt_user_id())
  )
);

---------------
--friendships--
---------------

create policy blocked_select_policy
on friendships
as restrictive
for select
to socnet_user
-- can see all friendships except the blocked ones
using(
  case status
    when 'blocked'
      then
        blockee_id is null or
        blockee_id <> util.jwt_user_id()
    else true
  end
);

---------
--posts--
---------

create policy blocked_select_policy
on posts
as restrictive
for select
to socnet_user
-- could be ignored for friends and friends_blacklist
-- since they are already filtered by accepted friendships
using(
  posts.creator_id not in (
    select util.blocker_ids(util.jwt_user_id())
  )
);

----------------
--posts_access--
----------------

create policy blocked_select_policy
on posts_access
as restrictive
for select
to socnet_user
using(
  posts_access.creator_id not in (
    select util.blocker_ids(util.jwt_user_id())
  )
);

------------
--comments--
------------

create policy blocked_select_policy
on comments
as restrictive
for select
to socnet_user
using (
  comments.user_id not in (
    select util.blocker_ids(util.jwt_user_id())
  )
);
