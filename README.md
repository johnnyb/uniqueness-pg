uniqueness-pg
=============

A collection of functions such as cantor pairing which help make unique identifiers for PostgreSQL.

What is a Cantor Pair?  Let's say that you have a table which is uniquely identified by two numeric foreign keys.  However, let's say that you need a single, unique key to refer to the row externally.  Probably a better approach is to create a new primary key, but, if you can't, you can use a Cantor Pairing function to create a single number from the two.

  select cantorPair(23, 50);

  -- yields 2751

  select cantorUnpair(2751);

  -- yields {23,50};

Remember, in Postgres, you can even create indexes on these functions.

  create table cantortest(a int, b int, c text, primary key(a, b));
  create index on cantortest(cantorPair(a, b));
  insert into cantortest values (1, 5, 'hello');
  insert into cantortest values (3, 18, 'there');

  select cantorPair(3, 18); -- =>  (yields 249)

  select * from cantortest where cantorPair(a, b) = 249; -- uses index on large enough tables, or if enable_seqscan set to no.

  select * from cantortest where cantorUnpair(249)[1] = 3; -- parses number out into a foreign key that can be looked up on its own

You can use more than two values with an array and the cantorTuple function:

  select cantorTuple(ARRAY[5, 16, 9, 25]);

  -- yields 20643596022

  select cantorUntuple(20643596022, 4); -- NOTE - the 4 tells how many components

  -- yields {5,16,9,25}

Additional functions include:

  cantorPairBI - the regular cantorPair uses DECIMALs, which can be slow.  If you know the final value will fit in a BIGINT, this version should be a little bit faster.
 
  cantorUnpairBI - same as above but for unpairing

  uniquenessSpace(key, spaces, space_index) - this is useful for when you need to UNION tables which each have their own PKs, but you want all of the rows to also have their own PKs.  It is a super-simple function (key * spaces + space_index), but it is helpful because people can better see what/why you are doing things.  So, for instance, if we had an employees tables and a customers table, but wanted a people view that had a unique PK, we can do:

  CREATE VIEW people AS 
     SELECT uniquenessSpace(employee_id, 2, 0), employee_name from employees
     UNION ALL
     SELECT uniquenessSpace(customer_id, 2, 1), customer_name from customers;

To retrieve the original ID, use uniquenessUnspace:

  select * from employees where employee_id = uniquenessUnspace(person_id, 2, 0); -- use same arguments as used on uniquenessSpace

These are both horrid names, and I am open to renaming them.

I am currently working on another uniquenessSpace, which doesn't require the number of tables to be known, only the index.  However, this function is problematic because it relies on exponentials.  The current version doesn't work because I need a prime filter.  However, the goal is to overcome the problem in the previous example that if the number of tables change (i.e. we add on an additional supplier table or something), then all of the generated keys have to change (because there are more tables, which affects the second parameter).  In an ideal setting, you will be able to do:

CREATE VIEW people AS 
     SELECT uniquenessSpace(employee_id, 0), employee_name from employees
     UNION ALL
     SELECT uniquenessSpace(customer_id, 1), customer_name from customers;

And then add on additional tables as necessary, without ever having to worry about changing keys.  This can work by generating a key which is p0^employee_id, and p1^customer_id, where p0 is the first prime (2) and p1 is the second prime (3).  As you can see, this gets out of hand pretty quickly, but PostgreSQL is surprisingly accomodative to this.  Anyway, this is probably a generally bad idea, but I thought it should be included for completeness.  I should probably rename this function as well.

