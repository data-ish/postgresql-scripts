######################################################################
# This is a simple smoke test
#
# It just checks that for all of the queries provided they can be executed in a fresh database without any of the extensions or changes from the other scripts.
# It doesn't check the server / instance level config. It assumes that is set up and configured, but it does recreate a test database for each query.
#
######################################################################

import os
import psycopg2

# Retrieve password from environment variables
password = os.getenv('POSTGRES_PASSWORD')

# Get a connection to the postgres database to perform database  drop & create commands from
pg_con = psycopg2.connect("dbname=postgres user=postgres password=" + password)
pg_con.autocommit = True
pg = pg_con.cursor()


# Iterate through all the scripts & queries provided. 
for root, dirs, files in os.walk('..'):
    for name in files:
        if root[:4] != '..\.' and name[-4:]== '.sql':
            # Create a new test database
            pg.execute(open("terminate-sessions.sql", "r").read())
            pg.execute(open("drop-db.sql", "r").read())
            pg.execute(open("create-db.sql", "r").read())
            # Validate the query executes successfully on its own
            
            try:
                pg_test = psycopg2.connect("dbname=a22ab1c62604a user=postgres password=" + password)
                pg_test.autocommit = True
                test = pg_test.cursor()
                test.execute(open(os.path.join(root, name), "r").read())
            except Exception as e:
                print("Error executing file:    {}".format(os.path.join(root, name)))
                print(e)
            finally:
                test.close()
                pg_test.close()